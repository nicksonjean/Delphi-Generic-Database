unit BootstrapStyle.Forms;

{
  Bootstrap 5 form control styling for FireMonkey — code-defined, no StyleBook.

  Supported controls
  ──────────────────
    TEdit        → form-control (text / password / number field)
    TComboBox    → form-select (native drop-down)
    TComboEdit   → form-control with type-ahead / autocomplete drop-down
    TListBox     → list-group
    TGrid        → table (header + body text settings)
    TStringGrid  → table (same as TGrid)
    TMemo        → textarea
    TSearchBox   → search input
    TListView    → list

  Bootstrap 5 form-control visual spec applied
  ─────────────────────────────────────────────
    background     : #fff  (disabled: #e9ecef)
    border         : 1px solid #dee2e6  (rounded 6 px)
    border (focus) : 2px solid #86b7fe
    color          : #212529
    placeholder    : #6c757d
    font           : Segoe UI 14 px

  Architecture — overlay approach (all controls)
  ───────────────────────────────────────────────
  All controls use a persistent child TRectangle ("__BSFormBg__") for the
  Bootstrap background and border.  The FMX style's own "background" resource
  is made visually transparent (Fill.Kind = None, Stroke.Kind = None) so the
  overlay shows through.  Because __BSFormBg__ is a real child — not a style
  resource — it survives FMX style rebuilds and is immune to state-trigger
  overrides (focus, enabled, pressed) that would otherwise reset style resource
  properties after OnApplyStyleLookup fires.

  For TComboBox / TComboEdit the dropdown button and selected-text TText are
  style children rendered in front of __BSFormBg__ (natural z-order); the
  arrow TPath glyphs are recoloured dark via ApplyComboArrow.

  OnApplyStyleLookup is hooked for all controls so Bootstrap visuals survive
  any style rebuild triggered by FMX (theme change, Enabled toggle, DPI change).
}

interface

uses
  System.UITypes,
  FMX.Types,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.ComboEdit,
  FMX.ListBox,
  FMX.Grid,
  FMX.Memo,
  FMX.SearchBox,
  FMX.ListView;

type
  TBootstrapForms = class
  public
    class procedure ApplyEdit(
      const AEdit: TEdit;
      AFontSize: Single = 14); static;

    class procedure ApplyComboBox(
      const ACombo: TComboBox;
      AFontSize: Single = 14); static;

    class procedure ApplyComboEdit(
      const AComboEdit: TComboEdit;
      AFontSize: Single = 14); static;

    class procedure ApplyListBox(
      const AListBox: TListBox;
      AFontSize: Single = 14); static;

    class procedure ApplyGrid(
      const AGrid: TGrid;
      AFontSize: Single = 13); static;

    class procedure ApplyStringGrid(
      const AGrid: TStringGrid;
      AFontSize: Single = 13); static;

    class procedure ApplyMemo(
      const AMemo: TMemo;
      AFontSize: Single = 14); static;

    class procedure ApplySearchBox(
      const ASearchBox: TSearchBox;
      AFontSize: Single = 14); static;

    class procedure ApplyListView(
      const AListView: TListView;
      AFontSize: Single = 13); static;

    class procedure ApplyFormLabel(
      const ALabel: TLabel;
      AFontSize: Single = 14); static;      

    class procedure SetActive(AActive: Boolean); static;
    class function  GetActive: Boolean; static;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.Generics.Collections,
  FMX.Objects,
  FMX.Graphics,
  FMX.TextLayout,
  FMX.Layouts,
  FMX.Forms,
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  FMX.Platform.Win,
  {$ENDIF}
  BootstrapStyle.Consts,
  BootstrapStyle.Colors;

{ ── Types ─────────────────────────────────────────────────────────────────── }

type
  { One-shot timer that fires once after ADelayMs milliseconds, applies the
    Bootstrap prompt inset to AControl, then frees itself.  Used to guarantee
    the prompt is correctly positioned even after FMX's own lazy initialisation
    (HandleCreated, WM_ACTIVATE state-trigger resets, etc.) has finished. }
  TBSPromptFixTimer = class(TObject)
  private
    FTimer:   TTimer;
    FControl: TStyledControl;
    procedure Fired(Sender: TObject);
  public
    constructor Create(AControl: TStyledControl;
      ADelayMs: Cardinal = BS_FORM_PROMPT_REALIGN_DELAY_MS);
    destructor Destroy; override;
  end;

var
  { Pending TBSPromptFixTimer instances are not owned by any component; if the
    process exits before the one-shot fires (e.g. DoneApplication / deactivate),
    finalization frees them so FTimer and Self do not leak. }
  GPromptFixPending: TList<TBSPromptFixTimer>;

type
  TBSFormKind = (
    bsfkEdit,
    bsfkComboBox,
    bsfkComboEdit,
    bsfkListBox,
    bsfkGrid,
    bsfkStringGrid,
    bsfkMemo,
    bsfkSearchBox,
    bsfkListView);

  TBSFormEntry = record
    Control:          TStyledControl;
    Kind:             TBSFormKind;
    FontSize:         Single;
    OrigOnEnter:      TNotifyEvent;
    OrigOnExit:       TNotifyEvent;
    OrigOnApplyStyle: TNotifyEvent;
  end;

{ ══════════════════════════════════════════════════════════════════════════════
  OVERLAY helpers — used by TEdit / TMemo / TSearchBox / TComboEdit
  ══════════════════════════════════════════════════════════════════════════════ }

{ BS_FORM_BG_NAME is defined in BootstrapStyle.Consts }

{ Finds the persistent __BSFormBg__ TRectangle child, or nil. }
function FindFormBg(const C: TStyledControl): TRectangle;
var
  I: Integer;
begin
  Result := nil;
  if C = nil then Exit;

  for I := 0 to C.ChildrenCount - 1 do
  begin
    if (C.Children[I] is TRectangle) and
       (TRectangle(C.Children[I]).TagString = BS_FORM_BG_NAME) then
      Exit(TRectangle(C.Children[I]));
  end;
end;

{ Finds or creates the persistent __BSFormBg__ background TRectangle.
  Because it is NOT a style child it survives FMX style rebuilds. }
function EnsureFormBg(const C: TStyledControl): TRectangle;
var
  R: TRectangle;
begin
  Result := FindFormBg(C);
  if Result = nil then
  begin
    R           := TRectangle.Create(C);
    R.TagString := BS_FORM_BG_NAME;
    R.HitTest   := False;
    R.Parent    := C;
  end
  else
    R := Result;

  R.Align := TAlignLayout.Client;
  { Keep it behind ANY presentation/style objects, even after style rebuilds. }
  R.Index := 0;
  R.SendToBack;
  Result := R;
end;

{ Removes the persistent background rectangle (called on toggle-off). }
procedure RemoveFormBg(const C: TStyledControl);
var
  R: TRectangle;
begin
  R := FindFormBg(C);
  if R <> nil then R.Free;
end;

procedure MakeStyleBackgroundTransparent(const C: TStyledControl);
var
  Bg: TFmxObject;

  procedure StripNativeChrome(Obj: TFmxObject);
  var
    I: Integer;
    Ch: TFmxObject;
    N: string;

    function IsTextOrCaretRelated(const O: TFmxObject): Boolean;
    begin
      Result := (O is TText) or (O is TLabel);
      if Result then Exit;
      if O is TControl then
      begin
        N := LowerCase(Trim(TControl(O).StyleName));
        if N = '' then
          N := LowerCase(Trim(O.Name));
      end
      else
        N := LowerCase(Trim(O.Name));

      { Preserve caret/cursor/selection visuals. Different FMX styles vary. }
      Result :=
        (N.Contains(FMX_NAME_CARET)) or
        (N.Contains(FMX_NAME_CURSOR)) or
        (N.Contains(FMX_NAME_SELECTION)) or
        (N.Contains(FMX_NAME_SEL)) or
        (N.Contains(FMX_NAME_HIGHLIGHT)) or
        (N.Contains(FMX_NAME_TEXT));
    end;
  begin
    if Obj = nil then Exit;

    { Do NOT touch text/caret/selection related objects. }
    if IsTextOrCaretRelated(Obj) then
      Exit;

    { Most Windows-native chrome is expressed as shapes/bitmaps in the style. }
    if Obj is TShape then
    begin
      TShape(Obj).Fill.Kind   := TBrushKind.None;
      TShape(Obj).Stroke.Kind := TBrushKind.None;
      { keep Opacity as-is; some presentations use it for caret blending }
    end
    else if Obj is TImage then
    begin
      { Bitmap borders/backgrounds }
      TImage(Obj).Opacity := 0;
    end;

    { As a fallback, remove visibility of generic chrome controls (panels/rects),
      but keep the object alive if it hosts text/caret (handled above). }
    if (Obj is TControl) and not (Obj is TText) and not (Obj is TLabel) then
    begin
      if (Obj is TPath) then
      begin
        { Keep glyph paths (e.g. arrows) visible; they are recoloured elsewhere. }
      end
      else if (Obj is TScrollBar) then
      begin
        { Preserve scrollbars for memo/list }
      end
      else if (Obj is TScrollBox) then
      begin
        { Preserve scrollbox container }
      end
      else
      begin
        { If it's pure chrome, make it transparent. }
        TControl(Obj).Opacity := 0;
      end;
    end;

    for I := 0 to Obj.ChildrenCount - 1 do
    begin
      Ch := Obj.Children[I];
      StripNativeChrome(Ch);
    end;
  end;
begin
  Bg := C.FindStyleResource(FMX_RES_BACKGROUND);
  if Bg is TShape then
  begin
    TShape(Bg).Fill.Kind   := TBrushKind.None;
    TShape(Bg).Stroke.Kind := TBrushKind.None;
  end
  { IMPORTANT:
    Some FMX styles (especially on Windows) host the text/caret visuals inside
    a non-shape "background" object. Hiding/moving that object can make the
    text invisible even though it is still selectable/copiable.
    For non-TShape backgrounds we keep it, but strip only the native chrome
    (rectangular border/background bitmaps) so our Bootstrap overlay can show. }
  else
    StripNativeChrome(Bg);

  { ComboEdit/ComboBox frequently paints a native-looking button; strip it too
    (paths are preserved so ApplyComboArrow can recolour them). }
  StripNativeChrome(C.FindStyleResource(FMX_RES_BUTTON));
  StripNativeChrome(C.FindStyleResource(FMX_RES_BOX));
end;

{ Paints Bootstrap form-control visuals onto the persistent __BSFormBg__ rect.
  AFocused = True   → focus ring (BS_FORM_BORDER_FOCUS, 2 px)
  AEnabled = False  → disabled background (#e9ecef) }
procedure StyleFormBg(const R: TRectangle; AFocused, AEnabled: Boolean);
begin
  if R = nil then Exit;
  R.Fill.Kind  := TBrushKind.Solid;
  if AEnabled then
    R.Fill.Color := BS_FORM_BG
  else
    R.Fill.Color := BS_FORM_BG_DISABLED;
  R.Stroke.Kind := TBrushKind.Solid;
  if AFocused and AEnabled then
  begin
    R.Stroke.Color     := BS_FORM_BORDER_FOCUS;
    R.Stroke.Thickness := BS_FORM_BORDER_THICKNESS_FOCUS;
  end
  else
  begin
    R.Stroke.Color     := BS_FORM_BORDER;
    R.Stroke.Thickness := BS_FORM_BORDER_THICKNESS;
  end;
  R.XRadius := BS_FORM_RADIUS;
  R.YRadius := BS_FORM_RADIUS;
end;

{ ══════════════════════════════════════════════════════════════════════════════
  STYLE-RESOURCE helpers — shared by all controls
  ══════════════════════════════════════════════════════════════════════════════ }

function BsShellUsesEditPrompt(const Shell: TStyledControl): Boolean;
begin
  Result := (Shell is TEdit) or (Shell is TComboEdit) or (Shell is TSearchBox);
end;

{ Finds a TControl in the styled presentation tree by StyleName or Name
  (case-insensitive).  Used when FindStyleResource on the shell returns nil
  on some FMX / platform builds. }
function FindPresentationChildById(const Root: TFmxObject;
  const CanonicalId: string): TControl;

  function IdMatches(const C: TControl): Boolean;
  var
    S: string;
  begin
    S := Trim(C.StyleName);
    if S = '' then
      S := Trim(C.Name);
    Result := SameText(S, CanonicalId);
  end;

  procedure Walk(const O: TFmxObject);
  var
    I: Integer;
    C: TControl;
  begin
    if Result <> nil then Exit;
    if O is TControl then
    begin
      C := TControl(O);
      if IdMatches(C) then
      begin
        Result := C;
        Exit;
      end;
    end;
    for I := 0 to O.ChildrenCount - 1 do
      Walk(O.Children[I]);
  end;

begin
  Result := nil;
  if Root = nil then Exit;
  Walk(Root);
end;

function FindContentOrPrompt(const Shell: TStyledControl;
  const CanonicalId: string): TControl;
var
  O: TFmxObject;
begin
  Result := nil;
  O := Shell.FindStyleResource(CanonicalId);
  if O is TControl then
    Exit(TControl(O));
  if not BsShellUsesEditPrompt(Shell) then Exit;
  if not (Shell is TPresentedControl) then Exit;
  if not TPresentedControl(Shell).HasPresentationProxy then Exit;
  O := TPresentedControl(Shell).Presentation as TFmxObject;
  Result := FindPresentationChildById(O, CanonicalId);
end;

{ Clears Padding on TText / TLabel descendants so only the prompt root carries
  the horizontal inset (avoids stacked style padding on nested prompt text). }
procedure ZeroTextPaddingUnderPrompt(const PromptRoot: TControl);
var
  Root: TControl;

  procedure Walk(const P: TFmxObject);
  var
    I: Integer;
  begin
    if P = Root then
    begin
      for I := 0 to P.ChildrenCount - 1 do
        Walk(P.Children[I]);
      Exit;
    end;
    if P is TText then
    begin
      TText(P).Padding.Left := 0;
      TText(P).Padding.Top := 0;
      TText(P).Padding.Right := 0;
      TText(P).Padding.Bottom := 0;
    end
    else if P is TLabel then
    begin
      TLabel(P).Padding.Left := 0;
      TLabel(P).Padding.Top := 0;
      TLabel(P).Padding.Right := 0;
      TLabel(P).Padding.Bottom := 0;
    end;
    for I := 0 to P.ChildrenCount - 1 do
      Walk(P.Children[I]);
  end;

begin
  if PromptRoot <> nil then
  begin
    Root := PromptRoot;
    Walk(PromptRoot);
  end;
end;

{ Applies the Bootstrap left inset (12 px) to a prompt control regardless of
  how it is laid out.

  FMX controls use DIFFERENT mechanisms for position depending on their Align:
    Align <> None  → Margins create an outer gap between the control edge and
                     its parent's content rect.  Padding.Left is INNER space
                     (between the control's own bounds and its content), so it
                     does NOT move the control and is zeroed here to prevent
                     double-indentation.
    Align  = None  → The layout engine does not enforce Margins; only Position.X
                     (absolute) moves the control.  Padding.Left is also set as
                     a secondary fallback for the TText/TLabel that lives inside
                     a None-aligned container prompt. }
procedure ApplyPromptInset(const Pr: TControl; const AInset: Single);
begin
  if Pr = nil then Exit;
  if Pr.Align = TAlignLayout.None then
  begin
    Pr.Position.X   := AInset;
    Pr.Padding.Left := AInset;   { inner fallback for TText child }
    Pr.Margins.Left := 0;
  end
  else
  begin
    Pr.Margins.Left := AInset;
    Pr.Padding.Left := 0;        { avoid double-indent on top of Margins }
  end;
  Pr.Padding.Top    := 0;
  Pr.Padding.Right  := 0;
  Pr.Padding.Bottom := 0;
  ZeroTextPaddingUnderPrompt(Pr);
end;

procedure SyncPromptPaddingFromContent(const Shell: TStyledControl;
  const Content: TControl);
var
  Pr: TControl;
begin
  Pr := FindContentOrPrompt(Shell, FMX_RES_PROMPT);
  if (Pr = nil) or (Content = nil) then Exit;
  ApplyPromptInset(Pr, Content.Padding.Left);
end;

{ TBSPromptFixTimer — implementation }

constructor TBSPromptFixTimer.Create(AControl: TStyledControl;
  ADelayMs: Cardinal);
begin
  inherited Create;
  FControl        := AControl;
  FTimer          := TTimer.Create(nil);
  FTimer.Interval := ADelayMs;
  FTimer.OnTimer  := Fired;
  FTimer.Enabled  := True;
  GPromptFixPending.Add(Self);
end;

destructor TBSPromptFixTimer.Destroy;
var
  Idx: Integer;
begin
  if GPromptFixPending <> nil then
  begin
    Idx := GPromptFixPending.IndexOf(Self);
    if Idx >= 0 then
      GPromptFixPending.Delete(Idx);
  end;
  if FTimer <> nil then
  begin
    FTimer.Enabled := False;
    FTimer.OnTimer := nil;
    FTimer.Free;
    FTimer := nil;
  end;
  inherited;
end;

procedure TBSPromptFixTimer.Fired(Sender: TObject);
var
  Pr: TControl;
begin
  FTimer.Enabled := False;
  FTimer.OnTimer := nil;
  if (FControl <> nil) and not (csDestroying in FControl.ComponentState) then
  begin
    Pr := FindContentOrPrompt(FControl, FMX_RES_PROMPT);
    if Pr <> nil then
    begin
      ApplyPromptInset(Pr, BS_FORM_PROMPT_INSET_LEFT);
      FControl.Repaint;
    end;
  end;
  FTimer.Free;
  FTimer := nil;
  Free;          { self-destruct }
end;

{ Deferred prompt realign — runs after FMX style triggers have fired.
  Works even when the 'content' resource is absent (Platform-mode controls).
  After applying the inset, Repaint is called explicitly because changing
  Margins/Position on a style child does not always propagate invalidation
  up to the TEdit's visual layer automatically.

  A TBSPromptFixTimer (120 ms) is also created as a belt-and-suspenders
  guarantee: it fires well after FMX's HandleCreated / WM_ACTIVATE
  state-trigger resets have settled, ensuring the prompt is already in the
  correct position on the very first visible paint. }
procedure QueueDeferredPromptRealign(const C: TStyledControl);
begin
  if (C = nil) or not BsShellUsesEditPrompt(C) then Exit;
  if (Application <> nil) and Application.Terminated then Exit;
  if csDestroying in C.ComponentState then Exit;
  TThread.Queue(nil,
    procedure
    var
      Pr: TControl;
    begin
      if (C = nil) or (csDestroying in C.ComponentState) then Exit;
      Pr := FindContentOrPrompt(C, FMX_RES_PROMPT);
      if Pr <> nil then
        ApplyPromptInset(Pr, BS_FORM_PROMPT_INSET_LEFT);
      { Force repaint so the new prompt position is visible immediately. }
      C.Repaint;
    end);
  { Second path: timer fires 120 ms after scheduling — by then all FMX lazy
    init (presentation creation, WM_ACTIVATE, first Realign cycle) is done.
    The timer self-destructs after firing once. }
  TBSPromptFixTimer.Create(C, BS_FORM_PROMPT_REALIGN_DELAY_MS);
end;

{ Reduces the "content" layout inner-padding to Bootstrap values (12 px L/R,
  6 px T/B).  FMX's Windows styled TEdit can have a wider default inset. }
procedure ApplyContentPadding(C: TStyledControl);
var
  Obj: TFmxObject;
begin
  Obj := C.FindStyleResource(FMX_RES_CONTENT);
  if Obj is TControl then
  begin
    TControl(Obj).Padding.Left   := BS_FORM_CONTENT_PAD_X;
    TControl(Obj).Padding.Right  := BS_FORM_CONTENT_PAD_X;
    if C is TMemo then
    begin
      TControl(Obj).Padding.Top    := BS_FORM_CONTENT_PAD_Y;
      TControl(Obj).Padding.Bottom := BS_FORM_CONTENT_PAD_Y;
    end
    else
    begin
      TControl(Obj).Padding.Top    := 0;
      TControl(Obj).Padding.Bottom := 0;
    end;
    SyncPromptPaddingFromContent(C, TControl(Obj));
  end;
  { Always queue the deferred pass — FMX style triggers fire after
    ApplyStyleLookup and may reset what we just set above. }
  QueueDeferredPromptRealign(C);
end;

{ Colours the "prompt" style resource (placeholder / hint text) with
  Bootstrap's muted text colour #6c757d and Segoe UI. }
procedure ApplyPromptResource(C: TStyledControl);
var
  Obj: TFmxObject;
begin
  Obj := C.FindStyleResource(FMX_RES_PROMPT);
  if Obj is TText then
  begin
    TText(Obj).Color       := BS_FORM_PLACEHOLDER;
    TText(Obj).Font.Family := BS_FONT_FAMILY_UI;
  end
  else if Obj is TLabel then
  begin
    TLabel(Obj).StyledSettings := TLabel(Obj).StyledSettings -
      [TStyledSetting.FontColor, TStyledSetting.Family];
    TLabel(Obj).TextSettings.FontColor   := BS_FORM_PLACEHOLDER;
    TLabel(Obj).TextSettings.Font.Family := BS_FONT_FAMILY_UI;
  end;
end;

{ Re-sync after focus / style triggers (same as post-ApplyContentPadding). }
procedure AlignPromptWithEditText(const C: TStyledControl);
var
  Co: TControl;
begin
  if C = nil then Exit;
  Co := FindContentOrPrompt(C, FMX_RES_CONTENT);
  if Co = nil then Exit;
  SyncPromptPaddingFromContent(C, Co);
  QueueDeferredPromptRealign(C);
end;

{ Colours the "text" style resource used by TComboBox to display the
  selected item.  Applies Segoe UI at the requested size. }
procedure ApplyComboSelectedText(C: TStyledControl; AFontSize: Single);
var
  Obj: TFmxObject;
begin
  Obj := C.FindStyleResource(FMX_RES_TEXT);
  if Obj is TText then
  begin
    TText(Obj).Color       := BS_FORM_TEXT;
    TText(Obj).Font.Family := BS_FONT_FAMILY_UI;
    TText(Obj).Font.Size   := AFontSize;
    TText(Obj).Font.Style  := [];
  end
  else if Obj is TLabel then
  begin
    TLabel(Obj).StyledSettings := [];
    TLabel(Obj).TextSettings.Font.Family := BS_FONT_FAMILY_UI;
    TLabel(Obj).TextSettings.Font.Size   := AFontSize;
    TLabel(Obj).TextSettings.Font.Style  := [];
    TLabel(Obj).TextSettings.FontColor   := BS_FORM_TEXT;
  end;
end;

{ Recursively recolours every TPath inside AObj to BS_FORM_TEXT.
  Colours any TText encountered as well.
  Used to paint the dropdown-arrow glyph dark so it shows on a white field. }
procedure ColorPathsInObj(AObj: TFmxObject);
var
  I:  Integer;
  Ch: TFmxObject;
begin
  if AObj = nil then Exit;
  for I := 0 to AObj.ChildrenCount - 1 do
  begin
    Ch := AObj.Children[I];
    if Ch is TPath then
    begin
      TPath(Ch).Fill.Kind   := TBrushKind.Solid;
      TPath(Ch).Fill.Color  := BS_FORM_TEXT;
      TPath(Ch).Stroke.Kind := TBrushKind.None;
    end
    else if Ch is TText then
      TText(Ch).Color := BS_FORM_TEXT
    else
      ColorPathsInObj(Ch);
  end;
end;

{ Recursively forces BS form font + color into text objects.
  Some FMX styles ignore control TextSettings and instead use the internal
  TText/TEditText resource's own properties (often reset by triggers). }
procedure ForceStyleTextInObj(AObj: TFmxObject; AFontSize: Single);
var
  I: Integer;
  Ch: TFmxObject;
begin
  if AObj = nil then Exit;
  for I := 0 to AObj.ChildrenCount - 1 do
  begin
    Ch := AObj.Children[I];
    if Ch is TText then
    begin
      TText(Ch).Visible     := True;
      TText(Ch).Opacity     := 1;
      TText(Ch).Color       := BS_FORM_TEXT;
      TText(Ch).Font.Family := BS_FONT_FAMILY_UI;
      if AFontSize > 0 then
        TText(Ch).Font.Size := AFontSize;
      TText(Ch).Font.Style := [];
    end
    else if Ch is TLabel then
    begin
      TLabel(Ch).Visible := True;
      TLabel(Ch).Opacity := 1;
      TLabel(Ch).StyledSettings := [];
      TLabel(Ch).TextSettings.Font.Family := BS_FONT_FAMILY_UI;
      if AFontSize > 0 then
        TLabel(Ch).TextSettings.Font.Size := AFontSize;
      TLabel(Ch).TextSettings.Font.Style  := [];
      TLabel(Ch).TextSettings.FontColor   := BS_FORM_TEXT;
    end;
    ForceStyleTextInObj(Ch, AFontSize);
  end;
end;

procedure ForceStyleTextResources(C: TStyledControl; AFontSize: Single);
var
  Obj: TFmxObject;
begin
  if C = nil then Exit;

  { Most presented edits expose a "text" style resource (TEditText/TText). }
  Obj := C.FindStyleResource(FMX_RES_TEXT);
  if Obj <> nil then
    ForceStyleTextInObj(Obj, AFontSize);

  { Memo often nests its text object under "content". }
  Obj := C.FindStyleResource(FMX_RES_CONTENT);
  if Obj <> nil then
    ForceStyleTextInObj(Obj, AFontSize);
end;

{ Colours the dropdown arrow in TComboBox / TComboEdit.
  Tries "button" and "arrow" resource names (name varies across FMX styles). }
procedure ApplyComboArrow(C: TStyledControl);
begin
  ColorPathsInObj(C.FindStyleResource(FMX_RES_BUTTON));
  ColorPathsInObj(C.FindStyleResource(FMX_RES_ARROW));
end;

{ Styles all TListBoxItem instances of a TComboBox dropdown with Segoe UI.
  TComboBox exposes Count + ItemIndex but not a typed ListItems[] array in its
  public API.  We reach items through the style's list-popup resource. }
procedure ApplyComboDropItems(C: TStyledControl; AFontSize: Single);
var
  LBObj: TFmxObject;
  LB:    TListBox;
  I:     Integer;
  Item:  TListBoxItem;
begin
  { FMX TComboBox builds its drop-down into a TComboListBox that is accessible
    via the "list" style resource when the style is currently applied. }
  LBObj := C.FindStyleResource('list');
  if not (LBObj is TListBox) then Exit;
  LB := TListBox(LBObj);
  for I := 0 to LB.Count - 1 do
  begin
    Item := LB.ListItems[I];
    if Item = nil then Continue;
    Item.StyledSettings := Item.StyledSettings - [
      TStyledSetting.Family, TStyledSetting.Size,
      TStyledSetting.Style,  TStyledSetting.FontColor];
    Item.TextSettings.Font.Family := BS_FONT_FAMILY_UI;
    Item.TextSettings.Font.Size   := AFontSize;
    Item.TextSettings.Font.Style  := [];
    Item.TextSettings.FontColor   := BS_FORM_TEXT;
  end;
end;

{ ── Font helpers ───────────────────────────────────────────────────────────── }

procedure ApplyBsFontEdit(Ed: TEdit; AFontSize: Single);
var
  ITS: ITextSettings;
begin
  Ed.StyledSettings := Ed.StyledSettings - [
    TStyledSetting.Family, TStyledSetting.Size,
    TStyledSetting.Style,  TStyledSetting.FontColor];
  Ed.TextSettings.Font.Family := BS_FONT_FAMILY_UI;
  Ed.TextSettings.Font.Size   := AFontSize;
  Ed.TextSettings.Font.Style  := [];
  Ed.TextSettings.FontColor   := BS_FORM_TEXT;
  { The styled presentation layer reads DefaultTextSettings.FontColor, which
    the FMX style may have set to white during ApplyStyleLookup.  Override it
    here so the text colour is always dark (#212529) regardless of theme. }
  if Supports(Ed, ITextSettings, ITS) then
    ITS.DefaultTextSettings.FontColor := BS_FORM_TEXT;
  ForceStyleTextResources(Ed, AFontSize);
end;

procedure ApplyBsFontComboEdit(CE: TComboEdit; AFontSize: Single);
var
  ITS: ITextSettings;
begin
  CE.StyledSettings := CE.StyledSettings - [
    TStyledSetting.Family, TStyledSetting.Size,
    TStyledSetting.Style,  TStyledSetting.FontColor];
  CE.TextSettings.Font.Family := BS_FONT_FAMILY_UI;
  CE.TextSettings.Font.Size   := AFontSize;
  CE.TextSettings.Font.Style  := [];
  CE.TextSettings.FontColor   := BS_FORM_TEXT;
  if Supports(CE, ITextSettings, ITS) then
    ITS.DefaultTextSettings.FontColor := BS_FORM_TEXT;
  ForceStyleTextResources(CE, AFontSize);
end;

procedure ApplyBsFontMemo(Mo: TMemo; AFontSize: Single);
var
  ITS: ITextSettings;
begin
  { TMemo is a presented control; prefer TextSettings/DefaultTextSettings. }
  Mo.StyledSettings := Mo.StyledSettings - [
    TStyledSetting.Family, TStyledSetting.Size,
    TStyledSetting.Style,  TStyledSetting.FontColor];
  Mo.TextSettings.Font.Family := BS_FONT_FAMILY_UI;
  Mo.TextSettings.Font.Size   := AFontSize;
  Mo.TextSettings.Font.Style  := [];
  Mo.TextSettings.FontColor   := BS_FORM_TEXT;
  if Supports(Mo, ITextSettings, ITS) then
  begin
    ITS.DefaultTextSettings.Font.Family := BS_FONT_FAMILY_UI;
    ITS.DefaultTextSettings.Font.Size   := AFontSize;
    ITS.DefaultTextSettings.Font.Style  := [];
    ITS.DefaultTextSettings.FontColor   := BS_FORM_TEXT;
  end;
  ForceStyleTextResources(Mo, AFontSize);
end;

procedure ApplyBsFontSearchBox(SB: TSearchBox; AFontSize: Single);
var
  ITS: ITextSettings;
begin
  SB.StyledSettings := SB.StyledSettings - [
    TStyledSetting.Family, TStyledSetting.Size,
    TStyledSetting.Style,  TStyledSetting.FontColor];
  SB.TextSettings.Font.Family := BS_FONT_FAMILY_UI;
  SB.TextSettings.Font.Size   := AFontSize;
  SB.TextSettings.Font.Style  := [];
  SB.TextSettings.FontColor   := BS_FORM_TEXT;
  if Supports(SB, ITextSettings, ITS) then
    ITS.DefaultTextSettings.FontColor := BS_FORM_TEXT;
  ForceStyleTextResources(SB, AFontSize);
end;

procedure ApplyBsListItems(const LB: TListBox; AFontSize: Single);
var
  I:    Integer;
  Item: TListBoxItem;
begin
  for I := 0 to LB.Count - 1 do
  begin
    Item := LB.ListItems[I];
    Item.StyledSettings := Item.StyledSettings - [
      TStyledSetting.Family, TStyledSetting.Size,
      TStyledSetting.Style,  TStyledSetting.FontColor];
    Item.TextSettings.Font.Family := BS_FONT_FAMILY_UI;
    Item.TextSettings.Font.Size   := AFontSize;
    Item.TextSettings.Font.Style  := [];
    Item.TextSettings.FontColor   := BS_FORM_TEXT;
  end;
end;

procedure RevertBsListItems(const LB: TListBox);
var
  I:    Integer;
  Item: TListBoxItem;
begin
  for I := 0 to LB.Count - 1 do
  begin
    Item := LB.ListItems[I];
    Item.StyledSettings := [
      TStyledSetting.Family, TStyledSetting.Size,
      TStyledSetting.Style,  TStyledSetting.FontColor,
      TStyledSetting.Other];
  end;
end;

{ Returns the style "background" TRectangle resource — for Grid / ListView. }
function FindBgRect(const C: TStyledControl): TRectangle;
var
  Obj: TFmxObject;
begin
  Obj := C.FindStyleResource(FMX_RES_BACKGROUND);
  if Obj is TRectangle then Result := TRectangle(Obj)
  else                       Result := nil;
end;

{ Forces BS_FORM_TEXT onto every text-settings path we know about for a
  given control.  Called on EACH focus enter/exit so FMX state triggers
  (which fire after OnApplyStyleLookup) cannot reset text to white. }
procedure ForceTextColor(const E: TBSFormEntry);
var
  ITS: ITextSettings;
begin
  case E.Kind of
    bsfkEdit, bsfkComboEdit, bsfkSearchBox:
    begin
      if Supports(E.Control, ITextSettings, ITS) then
      begin
        ITS.DefaultTextSettings.FontColor := BS_FORM_TEXT;
        ITS.TextSettings.FontColor        := BS_FORM_TEXT;
      end;
      ForceStyleTextResources(E.Control, E.FontSize);
    end;
    bsfkMemo:
    begin
      if Supports(E.Control, ITextSettings, ITS) then
      begin
        ITS.DefaultTextSettings.FontColor := BS_FORM_TEXT;
        ITS.TextSettings.FontColor        := BS_FORM_TEXT;
      end;
      ForceStyleTextResources(E.Control, E.FontSize);
    end;
  end;
end;

{ ── Per-kind apply / reset (forward declarations) ─────────────────────────── }

procedure DoApplyEntry(const E: TBSFormEntry); forward;
procedure DoResetEntry(const E: TBSFormEntry); forward;

{ ══════════════════════════════════════════════════════════════════════════════
  TEdit  — overlay path
  ══════════════════════════════════════════════════════════════════════════════ }

{$IFDEF MSWINDOWS}
{ On Windows, TEdit with Password = True always runs as a native Win32 EDIT
  control (ControlType = Platform) — FMX style resources are not involved and
  the only way to indent the placeholder is EM_SETMARGINS on the native HWND.

  Regular (non-password) TEdits are typically set to ControlType = Styled, but
  some FMX builds on Windows still use a native HWND internally.  Calling this
  function for all TEdits is safe: if no native child HWND is found at the
  control's screen position the function exits without doing anything.

  The call is always deferred (TThread.Queue) so the HWND is guaranteed to
  exist when this code runs. }
procedure ApplyNativeEditMargin(const Ed: TEdit; const ALeft: Integer);
const
  EM_SETMARGINS_MSG = $00D3;
  EC_LEFTMARGIN     = $0001;
var
  Form:    TCommonCustomForm;
  FormWnd: HWND;
  AbsRect: TRectF;
  CliOrg:  TPoint;
  ScrnPt:  TPoint;
  EditWnd: HWND;
  P:       TFmxObject;
begin
  if (Ed = nil) or (csDestroying in Ed.ComponentState) then Exit;
  { Walk up the parent chain to find the owning TCommonCustomForm.
    Direct interface-to-class casting via Ed.Root is fragile in FMX. }
  Form := nil;
  P := Ed.Parent;
  while P <> nil do
  begin
    if P is TCommonCustomForm then
    begin
      Form := TCommonCustomForm(P);
      Break;
    end;
    P := P.Parent;
  end;
  if (Form = nil) or (Form.Handle = nil) then Exit;
  FormWnd := WindowHandleToPlatform(Form.Handle).Wnd;
  if FormWnd = 0 then Exit;

  { FMX AbsoluteRect is in physical pixels relative to the form client area.
    Convert to screen coordinates by adding the client origin. }
  AbsRect  := Ed.AbsoluteRect;
  CliOrg.X := 0;
  CliOrg.Y := 0;
  ClientToScreen(FormWnd, CliOrg);
  ScrnPt.X := CliOrg.X + Round(AbsRect.Left + AbsRect.Width  * 0.5);
  ScrnPt.Y := CliOrg.Y + Round(AbsRect.Top  + AbsRect.Height * 0.5);

  { Find the native EDIT control at that screen position. }
  EditWnd := WindowFromPoint(ScrnPt);
  if (EditWnd = 0) or (EditWnd = FormWnd) then Exit;

  SendMessage(EditWnd, EM_SETMARGINS_MSG, EC_LEFTMARGIN, MakeLong(ALeft, 0));
end;
{$ENDIF}

procedure DoApplyEdit(const E: TBSFormEntry);
var
  Ed: TEdit;
  R:  TRectangle;
  Pr: TControl;
begin
  Ed := TEdit(E.Control);
  R  := EnsureFormBg(Ed);
  MakeStyleBackgroundTransparent(Ed);
  StyleFormBg(R, Ed.IsFocused, Ed.Enabled);
  ApplyContentPadding(Ed);   { ← also calls QueueDeferredPromptRealign }
  ApplyPromptResource(Ed);
  ApplyBsFontEdit(Ed, E.FontSize);

  { Synchronous fix — ensures the prompt is already positioned correctly for
    the very first paint, even before FMX style triggers might reset it.
    QueueDeferredPromptRealign (called via ApplyContentPadding) takes care of
    re-applying after those triggers and forces a Repaint. }
  Pr := FindContentOrPrompt(Ed, FMX_RES_PROMPT);
  if Pr <> nil then
    ApplyPromptInset(Pr, BS_FORM_PROMPT_INSET_LEFT);

  {$IFDEF MSWINDOWS}
  { Win32 API path — covers TEdits that FMX keeps as native HWNDs (e.g. when
    Password = True).  Safe no-op when no native child HWND is found. }
  TThread.Queue(nil,
    procedure
    begin
      ApplyNativeEditMargin(Ed, BS_FORM_PROMPT_INSET_LEFT);
    end);
  {$ENDIF}
end;

procedure DoResetEdit(const E: TBSFormEntry);
var
  AEdit: TEdit;
begin
  AEdit := TEdit(E.Control);
  if csDestroying in AEdit.ComponentState then Exit;
  RemoveFormBg(AEdit);
  AEdit.StyledSettings := [
    TStyledSetting.Family, TStyledSetting.Size,
    TStyledSetting.Style,  TStyledSetting.FontColor,
    TStyledSetting.Other];
  { Avoid ApplyStyleLookup: runs inside ControlApplyStyle → stack overflow. }
end;

{ ══════════════════════════════════════════════════════════════════════════════
  TComboBox — overlay path (same as TEdit / TMemo)
  ══════════════════════════════════════════════════════════════════════════════ }

procedure DoApplyComboBox(const E: TBSFormEntry);
var
  CB: TComboBox;
  R:  TRectangle;
begin
  CB := TComboBox(E.Control);
  { Use the same __BSFormBg__ overlay approach as TEdit / TMemo.
    The overlay is a persistent child rectangle that survives FMX style
    rebuilds and is immune to state-trigger overrides.  Making the FMX
    "background" style resource transparent lets the overlay show through,
    while all style children (dropdown button, selected-text TText) are
    rendered in front of the overlay as normal style siblings. }
  R := EnsureFormBg(CB);
  MakeStyleBackgroundTransparent(CB);
  StyleFormBg(R, CB.IsFocused, CB.Enabled);
  { Selected item text colour + font. }
  ApplyComboSelectedText(CB, E.FontSize);
  { Dropdown arrow — recolour every TPath inside "button" / "arrow" resource. }
  ApplyComboArrow(CB);
  { Dropdown list items — Segoe UI, same size, dark text. }
  ApplyComboDropItems(CB, E.FontSize);
end;

procedure DoResetComboBox(const E: TBSFormEntry);
var
  ACombo: TComboBox;
begin
  ACombo := TComboBox(E.Control);
  if csDestroying in ACombo.ComponentState then Exit;
  RemoveFormBg(ACombo);
end;

{ ══════════════════════════════════════════════════════════════════════════════
  TComboEdit — overlay path + dropdown arrow fix
  ══════════════════════════════════════════════════════════════════════════════ }

procedure DoApplyComboEdit(const E: TBSFormEntry);
var
  CE: TComboEdit;
  R:  TRectangle;
begin
  CE := TComboEdit(E.Control);
  R  := EnsureFormBg(CE);
  MakeStyleBackgroundTransparent(CE);
  StyleFormBg(R, CE.IsFocused, CE.Enabled);
  ApplyContentPadding(CE);
  ApplyPromptResource(CE);
  ApplyBsFontComboEdit(CE, E.FontSize);
  { TComboEdit has a dropdown button — ensure its arrow path is dark. }
  ApplyComboArrow(CE);
end;

procedure DoResetComboEdit(const E: TBSFormEntry);
var
  ACE: TComboEdit;
begin
  ACE := TComboEdit(E.Control);
  if csDestroying in ACE.ComponentState then Exit;
  RemoveFormBg(ACE);
  ACE.StyledSettings := [
    TStyledSetting.Family, TStyledSetting.Size,
    TStyledSetting.Style,  TStyledSetting.FontColor,
    TStyledSetting.Other];
end;

{ ══════════════════════════════════════════════════════════════════════════════
  TListBox
  ══════════════════════════════════════════════════════════════════════════════ }

procedure DoApplyListBox(const E: TBSFormEntry);
var
  LB: TListBox;
  R:  TRectangle;
begin
  LB := TListBox(E.Control);
  R  := EnsureFormBg(LB);
  MakeStyleBackgroundTransparent(LB);
  StyleFormBg(R, LB.IsFocused, LB.Enabled);
  ApplyBsListItems(LB, E.FontSize);
end;

procedure DoResetListBox(const E: TBSFormEntry);
var
  LB: TListBox;
begin
  LB := TListBox(E.Control);
  if csDestroying in LB.ComponentState then Exit;
  RemoveFormBg(LB);
  RevertBsListItems(LB);
end;

{ ══════════════════════════════════════════════════════════════════════════════
  TMemo — overlay path
  ══════════════════════════════════════════════════════════════════════════════ }

procedure DoApplyMemo(const E: TBSFormEntry);
var
  Mo: TMemo;
  R:  TRectangle;
begin
  Mo := TMemo(E.Control);
  R  := EnsureFormBg(Mo);
  MakeStyleBackgroundTransparent(Mo);
  StyleFormBg(R, Mo.IsFocused, Mo.Enabled);
  ApplyContentPadding(Mo);
  ApplyBsFontMemo(Mo, E.FontSize);
end;

procedure DoResetMemo(const E: TBSFormEntry);
var
  AMo: TMemo;
begin
  AMo := TMemo(E.Control);
  if csDestroying in AMo.ComponentState then Exit;
  RemoveFormBg(AMo);
end;

{ ══════════════════════════════════════════════════════════════════════════════
  TSearchBox — overlay path
  ══════════════════════════════════════════════════════════════════════════════ }

procedure DoApplySearchBox(const E: TBSFormEntry);
var
  SB: TSearchBox;
  R:  TRectangle;
begin
  SB := TSearchBox(E.Control);
  R  := EnsureFormBg(SB);
  MakeStyleBackgroundTransparent(SB);
  StyleFormBg(R, SB.IsFocused, SB.Enabled);
  ApplyContentPadding(SB);
  ApplyPromptResource(SB);
  ApplyBsFontSearchBox(SB, E.FontSize);
end;

procedure DoResetSearchBox(const E: TBSFormEntry);
var
  ASB: TSearchBox;
begin
  ASB := TSearchBox(E.Control);
  if csDestroying in ASB.ComponentState then Exit;
  RemoveFormBg(ASB);
  ASB.StyledSettings := [
    TStyledSetting.Family, TStyledSetting.Size,
    TStyledSetting.Style,  TStyledSetting.FontColor,
    TStyledSetting.Other];
end;

{ ══════════════════════════════════════════════════════════════════════════════
  TListView
  ══════════════════════════════════════════════════════════════════════════════ }

procedure DoApplyListView(const E: TBSFormEntry);
var
  LV: TListView;
  R:  TRectangle;
begin
  LV := TListView(E.Control);
  R  := EnsureFormBg(LV);
  MakeStyleBackgroundTransparent(LV);
  StyleFormBg(R, LV.IsFocused, LV.Enabled);
end;

procedure DoResetListView(const E: TBSFormEntry);
var
  LV: TListView;
begin
  LV := TListView(E.Control);
  if csDestroying in LV.ComponentState then Exit;
  RemoveFormBg(LV);
end;

{ ══════════════════════════════════════════════════════════════════════════════
  TGrid / TStringGrid
  ══════════════════════════════════════════════════════════════════════════════ }

procedure DoApplyGridCommon(const C: TStyledControl; AFontSize: Single);
var
  G:    TGrid;
  R:    TRectangle;
  Hdr:  TFmxObject;
  HdrR: TRectangle;
begin
  G := TGrid(C);

  if G.Model <> nil then
  begin
    G.Model.DefaultTextSettings.Font.Family := BS_FONT_FAMILY_UI;
    G.Model.DefaultTextSettings.Font.Size   := AFontSize;
    G.Model.DefaultTextSettings.Font.Style  := [];
    G.Model.DefaultTextSettings.FontColor   := BS_FORM_TEXT;
  end;

  R := EnsureFormBg(G);
  StyleFormBg(R, G.IsFocused, G.Enabled);

  Hdr := G.FindStyleResource(FMX_RES_HEADER);
  if Hdr is TRectangle then
  begin
    HdrR              := TRectangle(Hdr);
    HdrR.Fill.Kind    := TBrushKind.Solid;
    HdrR.Fill.Color   := BS_TABLE_HEADER_BG;
    HdrR.Stroke.Kind  := TBrushKind.Solid;
    HdrR.Stroke.Color := BS_TABLE_BORDER;
  end;

  MakeStyleBackgroundTransparent(G);
end;

procedure DoResetGridCommon(const C: TStyledControl);
var
  G: TGrid;
begin
  G := TGrid(C);
  if csDestroying in G.ComponentState then Exit;
  RemoveFormBg(G);
  if G.Model <> nil then
  begin
    G.Model.DefaultTextSettings.Font.Family := '';
    G.Model.DefaultTextSettings.Font.Size   := 0;
    G.Model.DefaultTextSettings.Font.Style  := [];
    G.Model.DefaultTextSettings.FontColor   := TAlphaColors.Black;
  end;
end;

procedure DoApplyGrid(const E: TBSFormEntry);
begin
  DoApplyGridCommon(E.Control, E.FontSize);
end;

procedure DoResetGrid(const E: TBSFormEntry);
begin
  DoResetGridCommon(E.Control);
end;

procedure DoApplyStringGrid(const E: TBSFormEntry);
begin
  DoApplyGridCommon(E.Control, E.FontSize);
end;

procedure DoResetStringGrid(const E: TBSFormEntry);
begin
  DoResetGridCommon(E.Control);
end;

{ ── Dispatch ───────────────────────────────────────────────────────────────── }

procedure DoApplyEntry(const E: TBSFormEntry);
begin
  case E.Kind of
    bsfkEdit:       DoApplyEdit(E);
    bsfkComboBox:   DoApplyComboBox(E);
    bsfkComboEdit:  DoApplyComboEdit(E);
    bsfkListBox:    DoApplyListBox(E);
    bsfkGrid:       DoApplyGrid(E);
    bsfkStringGrid: DoApplyStringGrid(E);
    bsfkMemo:       DoApplyMemo(E);
    bsfkSearchBox:  DoApplySearchBox(E);
    bsfkListView:   DoApplyListView(E);
  end;
end;

procedure DoResetEntry(const E: TBSFormEntry);
begin
  case E.Kind of
    bsfkEdit:       DoResetEdit(E);
    bsfkComboBox:   DoResetComboBox(E);
    bsfkComboEdit:  DoResetComboEdit(E);
    bsfkListBox:    DoResetListBox(E);
    bsfkGrid:       DoResetGrid(E);
    bsfkStringGrid: DoResetStringGrid(E);
    bsfkMemo:       DoResetMemo(E);
    bsfkSearchBox:  DoResetSearchBox(E);
    bsfkListView:   DoResetListView(E);
  end;
end;

{ ── TBSFormRegistry ────────────────────────────────────────────────────────── }

type
  TBSFormRegistry = class(TComponent)
  private
    FEntries: TList<TBSFormEntry>;
    FActive:  Boolean;
    function  FindIndex(AControl: TStyledControl): Integer;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Register(
      AControl:  TStyledControl;
      AKind:     TBSFormKind;
      AFontSize: Single);
    procedure ControlEnter(Sender: TObject);
    procedure ControlExit(Sender: TObject);
    procedure ControlApplyStyle(Sender: TObject);
    procedure SetActive(AActive: Boolean);
    function  GetActive: Boolean;
  end;

var
  GFormRegistry: TBSFormRegistry;

constructor TBSFormRegistry.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEntries := TList<TBSFormEntry>.Create;
  FActive  := True;
end;

destructor TBSFormRegistry.Destroy;
begin
  FEntries.Free;
  inherited;
end;

procedure TBSFormRegistry.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  I: Integer;
begin
  inherited;
  if Operation = opRemove then
    for I := FEntries.Count - 1 downto 0 do
      if FEntries[I].Control = AComponent then
        FEntries.Delete(I);
end;

function TBSFormRegistry.FindIndex(AControl: TStyledControl): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FEntries.Count - 1 do
    if FEntries[I].Control = AControl then
    begin
      Result := I;
      Exit;
    end;
end;

procedure TBSFormRegistry.Register(
  AControl:  TStyledControl;
  AKind:     TBSFormKind;
  AFontSize: Single);
var
  Entry: TBSFormEntry;
  Idx:   Integer;
begin
  Idx := FindIndex(AControl);
  if Idx >= 0 then
  begin
    Entry          := FEntries[Idx];
    Entry.FontSize := AFontSize;
    FEntries[Idx]  := Entry;
    Exit;
  end;

  Entry.Control          := AControl;
  Entry.Kind             := AKind;
  Entry.FontSize         := AFontSize;
  Entry.OrigOnEnter      := AControl.OnEnter;
  Entry.OrigOnExit       := AControl.OnExit;
  Entry.OrigOnApplyStyle := AControl.OnApplyStyleLookup;

  FEntries.Add(Entry);

  AControl.FreeNotification(Self);

  AControl.OnEnter            := ControlEnter;
  AControl.OnExit             := ControlExit;
  AControl.OnApplyStyleLookup := ControlApplyStyle;
end;

procedure TBSFormRegistry.ControlEnter(Sender: TObject);
var
  Idx: Integer;
  E:   TBSFormEntry;
begin
  if not (Sender is TStyledControl) then Exit;
  if csDestroying in TStyledControl(Sender).ComponentState then Exit;
  Idx := FindIndex(TStyledControl(Sender));
  if Idx < 0 then Exit;
  E := FEntries[Idx];

  if FActive then
  begin
    StyleFormBg(FindFormBg(E.Control), True, E.Control.Enabled);
    { FMX focus trigger fires after OnApplyStyleLookup and can reset text
      colour.  Re-force it here, after the trigger has had its chance. }
    ForceTextColor(E);
    case E.Kind of
      bsfkEdit, bsfkComboEdit, bsfkSearchBox:
        AlignPromptWithEditText(E.Control);
    end;
  end;

  if Assigned(E.OrigOnEnter) then
    E.OrigOnEnter(Sender);
end;

procedure TBSFormRegistry.ControlExit(Sender: TObject);
var
  Idx: Integer;
  E:   TBSFormEntry;
begin
  if not (Sender is TStyledControl) then Exit;
  if csDestroying in TStyledControl(Sender).ComponentState then Exit;
  Idx := FindIndex(TStyledControl(Sender));
  if Idx < 0 then Exit;
  E := FEntries[Idx];

  if FActive then
  begin
    StyleFormBg(FindFormBg(E.Control), False, E.Control.Enabled);
    ForceTextColor(E);
    case E.Kind of
      bsfkEdit, bsfkComboEdit, bsfkSearchBox:
        AlignPromptWithEditText(E.Control);
    end;
  end;

  if Assigned(E.OrigOnExit) then
    E.OrigOnExit(Sender);
end;

procedure TBSFormRegistry.ControlApplyStyle(Sender: TObject);
var
  Idx: Integer;
  E:   TBSFormEntry;
begin
  if not (Sender is TStyledControl) then Exit;
  if csDestroying in TStyledControl(Sender).ComponentState then Exit;
  Idx := FindIndex(TStyledControl(Sender));
  if Idx < 0 then Exit;
  E := FEntries[Idx];

  if Assigned(E.OrigOnApplyStyle) then
    E.OrigOnApplyStyle(Sender);

  if FActive then
    DoApplyEntry(E)
  else
    DoResetEntry(E);
end;

procedure TBSFormRegistry.SetActive(AActive: Boolean);
var
  I:     Integer;
  E:     TBSFormEntry;
  C:     TStyledControl;
  Saved: TNotifyEvent;
begin
  FActive := AActive;
  for I := 0 to FEntries.Count - 1 do
  begin
    E := FEntries[I];
    C := E.Control;
    if csDestroying in C.ComponentState then Continue;

    Saved := C.OnApplyStyleLookup;
    C.OnApplyStyleLookup := nil;
    try
      if AActive then
      begin
        C.NeedStyleLookup;
        C.ApplyStyleLookup;
        if Assigned(E.OrigOnApplyStyle) then
          E.OrigOnApplyStyle(C);
        DoApplyEntry(E);
      end
      else
      begin
        DoResetEntry(E);
        C.NeedStyleLookup;
        C.ApplyStyleLookup;
        if Assigned(E.OrigOnApplyStyle) then
          E.OrigOnApplyStyle(C);
      end;
    finally
      C.OnApplyStyleLookup := Saved;
    end;
  end;
end;

function TBSFormRegistry.GetActive: Boolean;
begin
  Result := FActive;
end;

{ ── TBootstrapForms — public API ──────────────────────────────────────────── }

class procedure TBootstrapForms.ApplyEdit(const AEdit: TEdit; AFontSize: Single);
begin
  GFormRegistry.Register(AEdit, bsfkEdit, AFontSize);
  AEdit.ControlType := TControlType.Styled;
  AEdit.NeedStyleLookup;
  AEdit.ApplyStyleLookup;
end;

class procedure TBootstrapForms.ApplyComboBox(const ACombo: TComboBox;
  AFontSize: Single);
begin
  GFormRegistry.Register(ACombo, bsfkComboBox, AFontSize);
  { TComboBox is already TControlType.Styled in FMX. }
  ACombo.NeedStyleLookup;
  ACombo.ApplyStyleLookup;
end;

class procedure TBootstrapForms.ApplyComboEdit(const AComboEdit: TComboEdit;
  AFontSize: Single);
begin
  GFormRegistry.Register(AComboEdit, bsfkComboEdit, AFontSize);
  AComboEdit.ControlType := TControlType.Styled;
  AComboEdit.NeedStyleLookup;
  AComboEdit.ApplyStyleLookup;
end;

class procedure TBootstrapForms.ApplyListBox(const AListBox: TListBox;
  AFontSize: Single);
begin
  GFormRegistry.Register(AListBox, bsfkListBox, AFontSize);
  AListBox.NeedStyleLookup;
  AListBox.ApplyStyleLookup;
end;

class procedure TBootstrapForms.ApplyGrid(const AGrid: TGrid; AFontSize: Single);
begin
  GFormRegistry.Register(AGrid, bsfkGrid, AFontSize);
  AGrid.NeedStyleLookup;
  AGrid.ApplyStyleLookup;
end;

class procedure TBootstrapForms.ApplyStringGrid(const AGrid: TStringGrid;
  AFontSize: Single);
begin
  GFormRegistry.Register(AGrid, bsfkStringGrid, AFontSize);
  AGrid.NeedStyleLookup;
  AGrid.ApplyStyleLookup;
end;

class procedure TBootstrapForms.ApplyMemo(const AMemo: TMemo; AFontSize: Single);
begin
  GFormRegistry.Register(AMemo, bsfkMemo, AFontSize);
  AMemo.ControlType := TControlType.Styled;
  AMemo.NeedStyleLookup;
  AMemo.ApplyStyleLookup;
end;

class procedure TBootstrapForms.ApplySearchBox(const ASearchBox: TSearchBox;
  AFontSize: Single);
begin
  GFormRegistry.Register(ASearchBox, bsfkSearchBox, AFontSize);
  ASearchBox.ControlType := TControlType.Styled;
  ASearchBox.NeedStyleLookup;
  ASearchBox.ApplyStyleLookup;
end;

class procedure TBootstrapForms.ApplyListView(const AListView: TListView;
  AFontSize: Single);
begin
  GFormRegistry.Register(AListView, bsfkListView, AFontSize);
  AListView.NeedStyleLookup;
  AListView.ApplyStyleLookup;
end;

class procedure TBootstrapForms.ApplyFormLabel(const ALabel: TLabel;
  AFontSize: Single);
begin
  if ALabel = nil then Exit;
  ALabel.StyledSettings := ALabel.StyledSettings - [
    TStyledSetting.Family, TStyledSetting.Size,
    TStyledSetting.Style,  TStyledSetting.FontColor];
  ALabel.TextSettings.Font.Family := BS_FONT_FAMILY_UI;
  ALabel.TextSettings.Font.Size   := AFontSize;
  ALabel.TextSettings.Font.Style  := [];
  ALabel.TextSettings.FontColor   := BS_FORM_TEXT;
end;

class procedure TBootstrapForms.SetActive(AActive: Boolean);
begin
  GFormRegistry.SetActive(AActive);
end;

class function TBootstrapForms.GetActive: Boolean;
begin
  Result := GFormRegistry.GetActive;
end;

initialization
  GPromptFixPending := TList<TBSPromptFixTimer>.Create;
  GFormRegistry := TBSFormRegistry.Create(nil);

finalization
  if GPromptFixPending <> nil then
  begin
    while GPromptFixPending.Count > 0 do
      GPromptFixPending[0].Free;
    FreeAndNil(GPromptFixPending);
  end;
  FreeAndNil(GFormRegistry);

end.
