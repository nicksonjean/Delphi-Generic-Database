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

    class procedure SetActive(AActive: Boolean); static;
    class function  GetActive: Boolean; static;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FMX.Objects,
  FMX.Graphics,
  FMX.TextLayout,
  BootstrapStyle.Colors;

{ ── Types ─────────────────────────────────────────────────────────────────── }

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

const
  BS_FORM_BG_NAME = '__BSFormBg__';

{ Finds the persistent __BSFormBg__ TRectangle child, or nil. }
function FindFormBg(const C: TStyledControl): TRectangle;
var
  I:   Integer;
  Obj: TFmxObject;
begin
  Result := nil;
  for I := 0 to C.ChildrenCount - 1 do
  begin
    Obj := C.Children[I];
    if (Obj is TRectangle) and
       (TRectangle(Obj).TagString = BS_FORM_BG_NAME) then
    begin
      Result := TRectangle(Obj);
      Exit;
    end;
  end;
end;

{ Finds or creates the persistent __BSFormBg__ background TRectangle.
  Because it is NOT a style child it survives FMX style rebuilds. }
function EnsureFormBg(const C: TStyledControl): TRectangle;
var
  R: TRectangle;
begin
  Result := FindFormBg(C);
  if Result <> nil then Exit;

  R           := TRectangle.Create(C);
  R.Parent    := C;
  R.TagString := BS_FORM_BG_NAME;
  R.HitTest   := False;
  R.Align     := TAlignLayout.Client;   { Client = full bounds; Contents is inset }
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

{ Makes the FMX style's own "background" resource invisible so our persistent
  __BSFormBg__ shows through.

  TRectangle path: set Fill.Kind/Stroke.Kind = None.  TBrushKind is an enum
  and is NOT animated by FMX trigger effects, so this survives all state
  transitions (focus, hover, pressed, enabled).

  Non-TRectangle path (TActiveStyleObject, TBitmapStyleObject, etc.): set
  Visible=False + Opacity=0.  The dropdown button for TComboBox/TComboEdit is
  a style sibling of "background" (not a child), so hiding background is safe
  for all standard FMX Windows controls. }
procedure MakeStyleBackgroundTransparent(const C: TStyledControl);
var
  Obj:  TFmxObject;
  R:    TRectangle;
  Ctrl: TControl;
begin
  Obj := C.FindStyleResource('background');
  if Obj is TRectangle then
  begin
    R             := TRectangle(Obj);
    R.Fill.Kind   := TBrushKind.None;
    R.Stroke.Kind := TBrushKind.None;
  end
  else if Obj is TControl then
  begin
    Ctrl         := TControl(Obj);
    Ctrl.Visible := False;
    Ctrl.Opacity := 0;
  end;
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
    R.Stroke.Thickness := 2;
  end
  else
  begin
    R.Stroke.Color     := BS_FORM_BORDER;
    R.Stroke.Thickness := 1;
  end;
  R.XRadius := 6;
  R.YRadius := 6;
end;

{ ══════════════════════════════════════════════════════════════════════════════
  STYLE-RESOURCE helpers — shared by all controls
  ══════════════════════════════════════════════════════════════════════════════ }

{ Reduces the "content" layout inner-padding to Bootstrap values (12 px L/R,
  6 px T/B).  FMX's Windows styled TEdit can have a wider default inset. }
procedure ApplyContentPadding(C: TStyledControl);
var
  Obj: TFmxObject;
begin
  Obj := C.FindStyleResource('content');
  if Obj is TControl then
  begin
    TControl(Obj).Padding.Left   := 12;
    TControl(Obj).Padding.Top    := 6;
    TControl(Obj).Padding.Right  := 12;
    TControl(Obj).Padding.Bottom := 6;
  end;
end;

{ Colours the "prompt" style resource (placeholder / hint text) with
  Bootstrap's muted text colour #6c757d and Segoe UI. }
procedure ApplyPromptResource(C: TStyledControl);
var
  Obj: TFmxObject;
begin
  Obj := C.FindStyleResource('prompt');
  if Obj is TText then
  begin
    TText(Obj).Color       := BS_FORM_PLACEHOLDER;
    TText(Obj).Font.Family := 'Segoe UI';
  end
  else if Obj is TLabel then
  begin
    TLabel(Obj).StyledSettings := TLabel(Obj).StyledSettings -
      [TStyledSetting.FontColor, TStyledSetting.Family];
    TLabel(Obj).TextSettings.FontColor   := BS_FORM_PLACEHOLDER;
    TLabel(Obj).TextSettings.Font.Family := 'Segoe UI';
  end;
end;

{ Colours the "text" style resource used by TComboBox to display the
  selected item.  Applies Segoe UI at the requested size. }
procedure ApplyComboSelectedText(C: TStyledControl; AFontSize: Single);
var
  Obj: TFmxObject;
begin
  Obj := C.FindStyleResource('text');
  if Obj is TText then
  begin
    TText(Obj).Color       := BS_FORM_TEXT;
    TText(Obj).Font.Family := 'Segoe UI';
    TText(Obj).Font.Size   := AFontSize;
    TText(Obj).Font.Style  := [];
  end
  else if Obj is TLabel then
  begin
    TLabel(Obj).StyledSettings := [];
    TLabel(Obj).TextSettings.Font.Family := 'Segoe UI';
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

{ Colours the dropdown arrow in TComboBox / TComboEdit.
  Tries "button" and "arrow" resource names (name varies across FMX styles). }
procedure ApplyComboArrow(C: TStyledControl);
begin
  ColorPathsInObj(C.FindStyleResource('button'));
  ColorPathsInObj(C.FindStyleResource('arrow'));
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
    Item.TextSettings.Font.Family := 'Segoe UI';
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
  Ed.TextSettings.Font.Family := 'Segoe UI';
  Ed.TextSettings.Font.Size   := AFontSize;
  Ed.TextSettings.Font.Style  := [];
  Ed.TextSettings.FontColor   := BS_FORM_TEXT;
  { The styled presentation layer reads DefaultTextSettings.FontColor, which
    the FMX style may have set to white during ApplyStyleLookup.  Override it
    here so the text colour is always dark (#212529) regardless of theme. }
  if Supports(Ed, ITextSettings, ITS) then
    ITS.DefaultTextSettings.FontColor := BS_FORM_TEXT;
end;

procedure ApplyBsFontComboEdit(CE: TComboEdit; AFontSize: Single);
var
  ITS: ITextSettings;
begin
  CE.StyledSettings := CE.StyledSettings - [
    TStyledSetting.Family, TStyledSetting.Size,
    TStyledSetting.Style,  TStyledSetting.FontColor];
  CE.TextSettings.Font.Family := 'Segoe UI';
  CE.TextSettings.Font.Size   := AFontSize;
  CE.TextSettings.Font.Style  := [];
  CE.TextSettings.FontColor   := BS_FORM_TEXT;
  if Supports(CE, ITextSettings, ITS) then
    ITS.DefaultTextSettings.FontColor := BS_FORM_TEXT;
end;

procedure ApplyBsFontMemo(Mo: TMemo; AFontSize: Single);
begin
  Mo.Font.Family := 'Segoe UI';
  Mo.Font.Size   := AFontSize;
  Mo.Font.Style  := [];
  Mo.FontColor   := BS_FORM_TEXT;
end;

procedure ApplyBsFontSearchBox(SB: TSearchBox; AFontSize: Single);
var
  ITS: ITextSettings;
begin
  SB.StyledSettings := SB.StyledSettings - [
    TStyledSetting.Family, TStyledSetting.Size,
    TStyledSetting.Style,  TStyledSetting.FontColor];
  SB.TextSettings.Font.Family := 'Segoe UI';
  SB.TextSettings.Font.Size   := AFontSize;
  SB.TextSettings.Font.Style  := [];
  SB.TextSettings.FontColor   := BS_FORM_TEXT;
  if Supports(SB, ITextSettings, ITS) then
    ITS.DefaultTextSettings.FontColor := BS_FORM_TEXT;
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
    Item.TextSettings.Font.Family := 'Segoe UI';
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
  Obj := C.FindStyleResource('background');
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
    end;
    bsfkMemo:
      TMemo(E.Control).FontColor := BS_FORM_TEXT;
  end;
end;

{ ── Per-kind apply / reset (forward declarations) ─────────────────────────── }

procedure DoApplyEntry(const E: TBSFormEntry); forward;
procedure DoResetEntry(const E: TBSFormEntry); forward;

{ ══════════════════════════════════════════════════════════════════════════════
  TEdit  — overlay path
  ══════════════════════════════════════════════════════════════════════════════ }

procedure DoApplyEdit(const E: TBSFormEntry);
var
  Ed: TEdit;
  R:  TRectangle;
begin
  Ed := TEdit(E.Control);
  R  := EnsureFormBg(Ed);
  MakeStyleBackgroundTransparent(Ed);
  StyleFormBg(R, False, Ed.Enabled);
  ApplyContentPadding(Ed);
  ApplyPromptResource(Ed);
  ApplyBsFontEdit(Ed, E.FontSize);
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
  ACombo.NeedStyleLookup;
  ACombo.ApplyStyleLookup;
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
  StyleFormBg(R, False, CE.Enabled);
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
  R  := FindBgRect(LB);
  if R <> nil then
  begin
    R.Fill.Kind        := TBrushKind.Solid;
    R.Fill.Color       := BS_FORM_BG;
    R.Stroke.Kind      := TBrushKind.Solid;
    R.Stroke.Color     := BS_FORM_BORDER;
    R.Stroke.Thickness := 1;
    R.XRadius          := 6;
    R.YRadius          := 6;
  end;
  ApplyBsListItems(LB, E.FontSize);
end;

procedure DoResetListBox(const E: TBSFormEntry);
var
  LB: TListBox;
begin
  LB := TListBox(E.Control);
  if csDestroying in LB.ComponentState then Exit;
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
  StyleFormBg(R, False, Mo.Enabled);
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
  AMo.NeedStyleLookup;
  AMo.ApplyStyleLookup;
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
  StyleFormBg(R, False, SB.Enabled);
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
  ASB.NeedStyleLookup;
  ASB.ApplyStyleLookup;
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
  R  := FindBgRect(LV);
  if R <> nil then
  begin
    R.Fill.Kind        := TBrushKind.Solid;
    R.Fill.Color       := BS_FORM_BG;
    R.Stroke.Kind      := TBrushKind.Solid;
    R.Stroke.Color     := BS_FORM_BORDER;
    R.Stroke.Thickness := 1;
    R.XRadius          := 6;
    R.YRadius          := 6;
  end;
end;

procedure DoResetListView(const E: TBSFormEntry);
var
  LV: TListView;
begin
  LV := TListView(E.Control);
  if csDestroying in LV.ComponentState then Exit;
  LV.NeedStyleLookup;
  LV.ApplyStyleLookup;
end;

{ ══════════════════════════════════════════════════════════════════════════════
  TGrid / TStringGrid
  ══════════════════════════════════════════════════════════════════════════════ }

procedure DoApplyGridCommon(const C: TStyledControl; AFontSize: Single);
var
  G:    TGrid;
  BG:   TFmxObject;
  R:    TRectangle;
  Hdr:  TFmxObject;
  HdrR: TRectangle;
begin
  G := TGrid(C);

  if G.Model <> nil then
  begin
    G.Model.DefaultTextSettings.Font.Family := 'Segoe UI';
    G.Model.DefaultTextSettings.Font.Size   := AFontSize;
    G.Model.DefaultTextSettings.Font.Style  := [];
    G.Model.DefaultTextSettings.FontColor   := BS_FORM_TEXT;
  end;

  BG := G.FindStyleResource('background');
  if BG is TRectangle then
  begin
    R                  := TRectangle(BG);
    R.Fill.Kind        := TBrushKind.Solid;
    R.Fill.Color       := BS_FORM_BG;
    R.Stroke.Kind      := TBrushKind.Solid;
    R.Stroke.Color     := BS_TABLE_BORDER;
    R.Stroke.Thickness := 1;
    R.XRadius          := 0;
    R.YRadius          := 0;
  end;

  Hdr := G.FindStyleResource('header');
  if Hdr is TRectangle then
  begin
    HdrR              := TRectangle(Hdr);
    HdrR.Fill.Kind    := TBrushKind.Solid;
    HdrR.Fill.Color   := BS_TABLE_HEADER_BG;
    HdrR.Stroke.Kind  := TBrushKind.Solid;
    HdrR.Stroke.Color := BS_TABLE_BORDER;
  end;
end;

procedure DoResetGridCommon(const C: TStyledControl);
var
  G: TGrid;
begin
  G := TGrid(C);
  if csDestroying in G.ComponentState then Exit;
  if G.Model <> nil then
  begin
    G.Model.DefaultTextSettings.Font.Family := '';
    G.Model.DefaultTextSettings.Font.Size   := 0;
    G.Model.DefaultTextSettings.Font.Style  := [];
    G.Model.DefaultTextSettings.FontColor   := TAlphaColors.Black;
  end;
  G.NeedStyleLookup;
  G.ApplyStyleLookup;
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
  I: Integer;
  E: TBSFormEntry;
begin
  FActive := AActive;
  for I := 0 to FEntries.Count - 1 do
  begin
    E := FEntries[I];
    if csDestroying in E.Control.ComponentState then Continue;
    E.Control.NeedStyleLookup;
    E.Control.ApplyStyleLookup;
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

class procedure TBootstrapForms.SetActive(AActive: Boolean);
begin
  GFormRegistry.SetActive(AActive);
end;

class function TBootstrapForms.GetActive: Boolean;
begin
  Result := GFormRegistry.GetActive;
end;

initialization
  GFormRegistry := TBSFormRegistry.Create(nil);

finalization
  FreeAndNil(GFormRegistry);

end.
