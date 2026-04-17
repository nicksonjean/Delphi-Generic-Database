unit BootstrapStyle.Buttons;

{
  Bootstrap 5 button styling for FireMonkey — fully code-defined, no StyleBook.

  Zero-leak / zero-AV / zero-border architecture
  ────────────────────────────────────────────────
  • ControlType := TControlType.Styled
      Disables native Win32 rendering; FMX owns ONE ApplyStyleLookup lifecycle.
      We NEVER call ApplyStyleLookup ourselves → no double-allocation → no leaks.

  • OnApplyStyleLookup → HideStyleChildren
      After FMX applies its own style, we hide every FMX-generated child control.
      This removes the rectangular FMX border that would otherwise bleed through
      the rounded corners of our __BSBg__ rectangle on ALL events (normal, hover,
      press, focus).  Our BS-named children are explicitly skipped.

  • TRectangle "__BSBg__" (Align=Client, XRadius/YRadius=6)
      Provides the solid Bootstrap background with proper rounded corners.
      Stroke.Kind=None so no extra border line appears on any state.

  • TColorAnimation on __BSBg__.Fill.Color (0.15 s)
      Drives the Bootstrap hover transition without any FMX style involvement.

  • TLabel "__BSIcon__" — bootstrap-icons glyph (HitTest=False).
  • TLabel "__BSText__" — caption text (HitTest=False).
  • TLayout "__BSInner__" — horizontal container when both icon + text are used.

  • All child objects owned by the button → freed automatically on destroy.
  • GBootstrapHoverHook singleton created in initialization, freed in finalization.
}

interface

uses
  System.UITypes,
  FMX.Types,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts,
  FMX.Ani,
  BootstrapStyle.Consts,
  BootstrapStyle.Core;

type
  TBootstrapButtons = class
  private
    class function  ButtonPaint(AVariant: TBootstrapVariant): TBootstrapButtonPaint; static;
    class function  TryVariantFromTag(const ATag: Integer; out V: TBootstrapVariant): Boolean; static;
    class procedure RemoveBSChildren(const C: TControl); static;
    class function  FindBSBackground(const C: TControl): TRectangle; static;
    class function  FindBSAnimation(const R: TRectangle): TColorAnimation; static;
    class procedure AttachHover(const C: TControl; AVariant: TBootstrapVariant); static;
    class procedure HideStyleChildren(const C: TStyledControl); static;
    class procedure ShowStyleChildren(const C: TStyledControl); static;
    class procedure BuildButtonVisuals(const C: TControl; const P: TBootstrapButtonPaint; const AIconName, ACaption: string; AFontSize: Single); static;
  public
    { Called by the internal TBootstrapHoverHook singleton. }
    class procedure ProcessHoverEnter(Sender: TObject); static;
    class procedure ProcessHoverLeave(Sender: TObject); static;
    class procedure ProcessApplyStyle(Sender: TObject); static;

    { AIconName is optional — empty string means text-only button. }
    class procedure ApplyButton(const ABtn: TButton; AVariant: TBootstrapVariant; const ACaption: string; AFontSize: Single = 15; const AIconName: string = ''); static;

    { Icon-only TButton (no caption). }
    class procedure ApplyButtonIconOnly(const ABtn: TButton; AVariant: TBootstrapVariant; const ABootstrapIconName: string; AFontSize: Single = 18); static;

    { TCornerButton with a single bootstrap-icons glyph. }
    class procedure ApplyCornerButtonGlyph(const ABtn: TCornerButton; AVariant: TBootstrapVariant; const ABootstrapIconName: string; AFontSize: Single = 14); static;

    { Runtime toggle — applies or reverts ALL registered buttons. }
    class procedure SetActive(AActive: Boolean); static;
    class function  GetActive: Boolean; static;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FMX.Graphics,
  BootstrapStyle.Colors,
  BootstrapStyle.Icons;

{ ── Button registry ────────────────────────────────────────────────────────── }

type
  TBSButtonKind = (bsbkButton, bsbkCornerButton);

  TBSButtonEntry = record
    Control:  TControl;
    Kind:     TBSButtonKind;
    Variant:  TBootstrapVariant;
    Caption:  string;   { saved for restore on toggle-off }
    IconName: string;   { icon name (icon-only and corner-button glyph) }
    FontSize: Single;
  end;

  TBSButtonRegistry = class(TComponent)
  private
    FEntries: TList<TBSButtonEntry>;
    FActive:  Boolean;
    function  FindIndex(AControl: TControl): Integer;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Register(
      AControl:  TControl;
      AKind:     TBSButtonKind;
      AVariant:  TBootstrapVariant;
      const ACaption, AIconName: string;
      AFontSize: Single);
    procedure SetActive(AActive: Boolean);
    function  GetActive: Boolean;
  end;

var
  GButtonRegistry: TBSButtonRegistry;

{ TBSButtonRegistry }

constructor TBSButtonRegistry.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEntries := TList<TBSButtonEntry>.Create;
  FActive  := True;
end;

destructor TBSButtonRegistry.Destroy;
begin
  FEntries.Free;
  inherited;
end;

procedure TBSButtonRegistry.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
begin
  inherited;
  if Operation = opRemove then
    for I := FEntries.Count - 1 downto 0 do
      if FEntries[I].Control = AComponent then
        FEntries.Delete(I);
end;

function TBSButtonRegistry.FindIndex(AControl: TControl): Integer;
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

procedure TBSButtonRegistry.Register(
  AControl:  TControl;
  AKind:     TBSButtonKind;
  AVariant:  TBootstrapVariant;
  const ACaption, AIconName: string;
  AFontSize: Single);
var
  E:   TBSButtonEntry;
  Idx: Integer;
begin
  Idx := FindIndex(AControl);
  if Idx >= 0 then
  begin
    { Already registered — update fields (variant may change, e.g. nav primary/secondary). }
    E          := FEntries[Idx];
    E.Kind     := AKind;
    E.Variant  := AVariant;
    E.Caption  := ACaption;
    E.IconName := AIconName;
    E.FontSize := AFontSize;
    FEntries[Idx] := E;
    Exit;
  end;
  E.Control  := AControl;
  E.Kind     := AKind;
  E.Variant  := AVariant;
  E.Caption  := ACaption;
  E.IconName := AIconName;
  E.FontSize := AFontSize;
  FEntries.Add(E);
  AControl.FreeNotification(Self);
end;

procedure TBSButtonRegistry.SetActive(AActive: Boolean);
var
  I:    Integer;
  E:    TBSButtonEntry;
  Ctrl: TControl;
begin
  FActive := AActive;
  for I := 0 to FEntries.Count - 1 do
  begin
    E    := FEntries[I];
    Ctrl := E.Control;
    if csDestroying in Ctrl.ComponentState then Continue;

    if AActive then
    begin
      { Re-apply Bootstrap visuals. }
      if E.Kind = bsbkButton then
        TBootstrapButtons.ApplyButton(TButton(Ctrl), E.Variant, E.Caption, E.FontSize, E.IconName)
      else
        TBootstrapButtons.ApplyCornerButtonGlyph(TCornerButton(Ctrl), E.Variant, E.IconName, E.FontSize);
    end
    else
    begin
      { Remove Bootstrap visuals — let FMX render its default styled look. }
      Ctrl.OnMouseEnter := nil;
      Ctrl.OnMouseLeave := nil;
      Ctrl.Tag          := 0;
      if Ctrl is TStyledControl then
        TStyledControl(Ctrl).OnApplyStyleLookup := nil;
      TBootstrapButtons.RemoveBSChildren(Ctrl);
      { Restore caption so the FMX-styled button has visible text. }
      if E.Kind = bsbkButton then
        TButton(Ctrl).Text := E.Caption;
      { TCornerButton: Text stays empty — Windows mode shows a blank corner button. }
      { HideStyleChildren left FMX style resources invisible (Opacity=0).  A fresh
        ApplyStyleLookup rebuilds them; hook stays nil until ApplyButton runs again. }
      if Ctrl is TStyledControl then
      begin
        { FMX may reuse style children; restore visibility explicitly. }
        TBootstrapButtons.ShowStyleChildren(TStyledControl(Ctrl));
        TStyledControl(Ctrl).NeedStyleLookup;
        TStyledControl(Ctrl).ApplyStyleLookup;
        TBootstrapButtons.ShowStyleChildren(TStyledControl(Ctrl));
      end;
    end;
  end;
end;

function TBSButtonRegistry.GetActive: Boolean;
begin
  Result := FActive;
end;

{ ── Internal hover/style hook ─────────────────────────────────────────────── }

type
  TBootstrapHoverHook = class
  public
    procedure ControlMouseEnter(Sender: TObject);
    procedure ControlMouseLeave(Sender: TObject);
    procedure ControlApplyStyle(Sender: TObject);
  end;

var
  GBootstrapHoverHook: TBootstrapHoverHook;

procedure TBootstrapHoverHook.ControlMouseEnter(Sender: TObject);
begin
  TBootstrapButtons.ProcessHoverEnter(Sender);
end;

procedure TBootstrapHoverHook.ControlMouseLeave(Sender: TObject);
begin
  TBootstrapButtons.ProcessHoverLeave(Sender);
end;

procedure TBootstrapHoverHook.ControlApplyStyle(Sender: TObject);
begin
  TBootstrapButtons.ProcessApplyStyle(Sender);
end;

{ ── TBootstrapButtons — private helpers ────────────────────────────────────── }

class function TBootstrapButtons.ButtonPaint(AVariant: TBootstrapVariant): TBootstrapButtonPaint;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Solid     := True;
  Result.TextColor := BS_TEXT_ON_DARK;
  case AVariant of
    bsPrimary:
      begin
        Result.Normal := BS_PRIMARY;
        Result.Hover  := BS_PRIMARY_HOVER;
      end;
    bsSecondary:
      begin
        Result.Normal := BS_SECONDARY;
        Result.Hover  := BS_SECONDARY_HOVER;
      end;
    bsSuccess:
      begin
        Result.Normal := BS_SUCCESS;
        Result.Hover  := BS_SUCCESS_HOVER;
      end;
    bsDanger:
      begin
        Result.Normal := BS_DANGER;
        Result.Hover  := BS_DANGER_HOVER;
      end;
    bsWarning:
      begin
        Result.Normal    := BS_WARNING;
        Result.Hover     := BS_WARNING_HOVER;
        Result.TextColor := BS_TEXT_ON_LIGHT;
      end;
    bsInfo:
      begin
        Result.Normal    := BS_INFO;
        Result.Hover     := BS_INFO_HOVER;
        Result.TextColor := BS_TEXT_ON_LIGHT;
      end;
    bsLight:
      begin
        Result.Normal    := BS_LIGHT;
        Result.Hover     := BS_LIGHT_HOVER;
        Result.TextColor := BS_TEXT_ON_LIGHT;
      end;
    bsDark:
      begin
        Result.Normal := BS_DARK;
        Result.Hover  := BS_DARK_HOVER;
      end;
    bsLink:
      begin
        Result.Solid     := False;
        Result.Normal    := TAlphaColors.Null;
        Result.Hover     := TAlphaColors.Null;
        Result.TextColor := BS_LINK;
      end;
  end;
end;

class function TBootstrapButtons.TryVariantFromTag(const ATag: Integer; out V: TBootstrapVariant): Boolean;
var
  O: Integer;
begin
  O := ATag - BS_HOVER_TAG_BASE;
  if (O < 0) or (O > Ord(High(TBootstrapVariant))) then
    Exit(False);
  V := TBootstrapVariant(O);
  Result := True;
end;

class procedure TBootstrapButtons.RemoveBSChildren(const C: TControl);
var
  I: Integer;
  Ch: TFmxObject;
begin
  for I := C.ChildrenCount - 1 downto 0 do
  begin
    Ch := C.Children[I];
    if Ch is TRectangle then
    begin
      if TRectangle(Ch).Name = BS_BG_NAME then
        Ch.Free;
    end
    else if Ch is TLayout then
    begin
      if TLayout(Ch).Name = BS_INNER_NAME then
        Ch.Free;
    end
    else if Ch is TLabel then
    begin
      if (TLabel(Ch).Name = BS_ICON_NAME) or (TLabel(Ch).Name = BS_TEXT_NAME) then
        Ch.Free;
    end;
  end;
end;

class function TBootstrapButtons.FindBSBackground(const C: TControl): TRectangle;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to C.ChildrenCount - 1 do
    if (C.Children[I] is TRectangle) and
       (TRectangle(C.Children[I]).Name = BS_BG_NAME) then
    begin
      Result := TRectangle(C.Children[I]);
      Exit;
    end;
end;

class function TBootstrapButtons.FindBSAnimation(const R: TRectangle): TColorAnimation;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to R.ChildrenCount - 1 do
    if R.Children[I] is TColorAnimation then
    begin
      Result := TColorAnimation(R.Children[I]);
      Exit;
    end;
end;

class procedure TBootstrapButtons.AttachHover(const C: TControl; AVariant: TBootstrapVariant);
begin
  C.Tag          := BS_HOVER_TAG_BASE + Ord(AVariant);
  C.OnMouseEnter := GBootstrapHoverHook.ControlMouseEnter;
  C.OnMouseLeave := GBootstrapHoverHook.ControlMouseLeave;
end;

class procedure TBootstrapButtons.HideStyleChildren(const C: TStyledControl);
var
  I: Integer;
  Child: TFmxObject;
  CC: TControl;
begin
  { Iterate current children.  The FMX style object was just applied (SendToBack
    means it's at index 0).  Our BS-named children were added before style
    application, so they are also present.  We hide everything that is NOT one
    of our known BS children so the rectangular FMX border never bleeds through
    the rounded corners of __BSBg__ on any state (normal, hover, press, focus). }
  for I := 0 to C.ChildrenCount - 1 do
  begin
    Child := C.Children[I];
    if not (Child is TControl) then
      Continue;
    CC := TControl(Child);
    if (CC.Name = BS_BG_NAME)    or
       (CC.Name = BS_INNER_NAME) or
       (CC.Name = BS_ICON_NAME)  or
       (CC.Name = BS_TEXT_NAME)  then
      Continue;
    { FMX-generated style child — collapse it on every axis so it never shows. }
    CC.Visible  := False;
    CC.HitTest  := False;
    CC.Opacity  := 0;
  end;
end;

class procedure TBootstrapButtons.ShowStyleChildren(const C: TStyledControl);
var
  I: Integer;
  Child: TFmxObject;
  CC: TControl;
begin
  for I := 0 to C.ChildrenCount - 1 do
  begin
    Child := C.Children[I];
    if not (Child is TControl) then
      Continue;
    CC := TControl(Child);
    if (CC.Name = BS_BG_NAME)    or
       (CC.Name = BS_INNER_NAME) or
       (CC.Name = BS_ICON_NAME)  or
       (CC.Name = BS_TEXT_NAME)  then
      Continue;
    CC.Visible := True;
    CC.Opacity := 1;
    { Ensure style children don't steal input from the button itself. }
    CC.HitTest := False;
  end;
end;

class procedure TBootstrapButtons.BuildButtonVisuals(
  const C: TControl;
  const P: TBootstrapButtonPaint;
  const AIconName, ACaption: string;
  AFontSize: Single);
var
  BGRect:      TRectangle;
  Anim:        TColorAnimation;
  InnerLayout: TLayout;
  IconLbl:     TLabel;
  TextLbl:     TLabel;
  HasIcon:     Boolean;
  HasCaption:  Boolean;
begin
  HasIcon    := (AIconName <> '') and (TBootstrapIcons.Glyph(AIconName) <> '');
  HasCaption := (ACaption <> '');

  { ── Background rectangle ─────────────────────────────────────────────── }
  if P.Solid then
  begin
    BGRect             := TRectangle.Create(C);
    BGRect.Name        := BS_BG_NAME;
    BGRect.Parent      := C;
    BGRect.Align       := TAlignLayout.Client;
    BGRect.HitTest     := False;
    BGRect.Fill.Kind   := TBrushKind.Solid;
    BGRect.Fill.Color  := P.Normal;
    BGRect.Stroke.Kind := TBrushKind.None;  { no extra border line on any state }
    BGRect.XRadius     := BS_BTN_RADIUS;
    BGRect.YRadius     := BS_BTN_RADIUS;

    { Smooth hover animation — 0.15 s matches Bootstrap 5 default transition. }
    Anim               := TColorAnimation.Create(BGRect);
    Anim.Parent        := BGRect;
    Anim.PropertyName  := 'Fill.Color';
    Anim.Duration      := BS_BTN_HOVER_DURATION;
    Anim.StartValue    := P.Normal;
    Anim.StopValue     := P.Hover;
    Anim.AutoReverse   := False;
    Anim.Loop          := False;
    { Do not call Enabled/Start here: that spins up FMX.TAniThread + platform
      timers that may not tear down cleanly on app exit.  Hover uses Anim.Start. }
  end;

  { ── Content layout: icon+text / icon-only / text-only ───────────────── }
  if HasIcon and HasCaption then
  begin
    { Horizontal row: [icon label | text label] }
    InnerLayout                := TLayout.Create(C);
    InnerLayout.Name           := BS_INNER_NAME;
    InnerLayout.Parent         := C;
    InnerLayout.Align          := TAlignLayout.Client;
    InnerLayout.HitTest        := False;
    InnerLayout.Margins.Left   := BS_BTN_CONTENT_MARGINX;
    InnerLayout.Margins.Right  := BS_BTN_CONTENT_MARGINX;

    IconLbl                               := TLabel.Create(C);
    IconLbl.Name                          := BS_ICON_NAME;
    IconLbl.Parent                        := InnerLayout;
    IconLbl.Align                         := TAlignLayout.Left;
    IconLbl.Width                         := AFontSize + BS_BTN_ICON_TEXT_EXTRA_WIDTH;
    IconLbl.HitTest                       := False;
    IconLbl.AutoSize                      := False;
    IconLbl.StyledSettings                := [];
    IconLbl.TextSettings.Font.Family      := TBootstrapIcons.FontFamily;
    IconLbl.TextSettings.Font.Size        := AFontSize;
    IconLbl.TextSettings.Font.Style       := [];
    IconLbl.TextSettings.HorzAlign        := TTextAlign.Center;
    IconLbl.TextSettings.VertAlign        := TTextAlign.Center;
    IconLbl.TextSettings.FontColor        := P.TextColor;
    IconLbl.Text                          := TBootstrapIcons.Glyph(AIconName);

    TextLbl                               := TLabel.Create(C);
    TextLbl.Name                          := BS_TEXT_NAME;
    TextLbl.Parent                        := InnerLayout;
    TextLbl.Align                         := TAlignLayout.Client;
    TextLbl.HitTest                       := False;
    TextLbl.AutoSize                      := False;
    TextLbl.StyledSettings                := [];
    TextLbl.TextSettings.Font.Family      := BS_FONT_FAMILY_UI;
    TextLbl.TextSettings.Font.Size        := AFontSize;
    TextLbl.TextSettings.Font.Style       := [];
    TextLbl.TextSettings.HorzAlign        := TTextAlign.Leading;
    TextLbl.TextSettings.VertAlign        := TTextAlign.Center;
    TextLbl.TextSettings.FontColor        := P.TextColor;
    TextLbl.Text                          := ACaption;
  end
  else if HasIcon then
  begin
    { Icon-only: centred in the full button area. }
    IconLbl                               := TLabel.Create(C);
    IconLbl.Name                          := BS_ICON_NAME;
    IconLbl.Parent                        := C;
    IconLbl.Align                         := TAlignLayout.Client;
    IconLbl.HitTest                       := False;
    IconLbl.AutoSize                      := False;
    IconLbl.StyledSettings                := [];
    IconLbl.TextSettings.Font.Family      := TBootstrapIcons.FontFamily;
    IconLbl.TextSettings.Font.Size        := AFontSize;
    IconLbl.TextSettings.Font.Style       := [];
    IconLbl.TextSettings.HorzAlign        := TTextAlign.Center;
    IconLbl.TextSettings.VertAlign        := TTextAlign.Center;
    IconLbl.TextSettings.FontColor        := P.TextColor;
    IconLbl.Text                          := TBootstrapIcons.Glyph(AIconName);
  end
  else if HasCaption then
  begin
    { Text-only: centred in the full button area. }
    TextLbl                               := TLabel.Create(C);
    TextLbl.Name                          := BS_TEXT_NAME;
    TextLbl.Parent                        := C;
    TextLbl.Align                         := TAlignLayout.Client;
    TextLbl.HitTest                       := False;
    TextLbl.AutoSize                      := False;
    TextLbl.StyledSettings                := [];
    TextLbl.TextSettings.Font.Family      := BS_FONT_FAMILY_UI;
    TextLbl.TextSettings.Font.Size        := AFontSize;
    TextLbl.TextSettings.Font.Style       := [];
    TextLbl.TextSettings.HorzAlign        := TTextAlign.Center;
    TextLbl.TextSettings.VertAlign        := TTextAlign.Center;
    TextLbl.TextSettings.FontColor        := P.TextColor;
    TextLbl.Text                          := ACaption;
  end;
end;

{ ── TBootstrapButtons — public ─────────────────────────────────────────────── }

class procedure TBootstrapButtons.ProcessHoverEnter(Sender: TObject);
var
  V:    TBootstrapVariant;
  P:    TBootstrapButtonPaint;
  Ctrl: TControl;
  BG:   TRectangle;
  Anim: TColorAnimation;
begin
  if not (Sender is TControl) then Exit;
  Ctrl := TControl(Sender);
  if csDestroying in Ctrl.ComponentState then Exit;
  if not TryVariantFromTag(Ctrl.Tag, V) then Exit;
  P    := ButtonPaint(V);
  BG   := FindBSBackground(Ctrl);
  if BG = nil then Exit;
  Anim := FindBSAnimation(BG);
  if Anim <> nil then
  begin
    Anim.StartValue := BG.Fill.Color;   { animate from current (may be mid-anim) }
    Anim.StopValue  := P.Hover;
    Anim.Inverse    := False;
    Anim.Start;
  end
  else
    BG.Fill.Color := P.Hover;
end;

class procedure TBootstrapButtons.ProcessHoverLeave(Sender: TObject);
var
  V:    TBootstrapVariant;
  P:    TBootstrapButtonPaint;
  Ctrl: TControl;
  BG:   TRectangle;
  Anim: TColorAnimation;
begin
  if not (Sender is TControl) then Exit;
  Ctrl := TControl(Sender);
  if csDestroying in Ctrl.ComponentState then Exit;
  if not TryVariantFromTag(Ctrl.Tag, V) then Exit;
  P    := ButtonPaint(V);
  BG   := FindBSBackground(Ctrl);
  if BG = nil then Exit;
  Anim := FindBSAnimation(BG);
  if Anim <> nil then
  begin
    Anim.StartValue := BG.Fill.Color;   { animate from current }
    Anim.StopValue  := P.Normal;
    Anim.Inverse    := False;
    Anim.Start;
  end
  else
    BG.Fill.Color := P.Normal;
end;

class procedure TBootstrapButtons.ProcessApplyStyle(Sender: TObject);
begin
  if not (Sender is TStyledControl) then Exit;
  if csDestroying in TStyledControl(Sender).ComponentState then Exit;
  HideStyleChildren(TStyledControl(Sender));
end;

class procedure TBootstrapButtons.ApplyButton(
  const ABtn: TButton;
  AVariant: TBootstrapVariant;
  const ACaption: string;
  AFontSize: Single;
  const AIconName: string);
var
  P: TBootstrapButtonPaint;
begin
  P := ButtonPaint(AVariant);
  RemoveBSChildren(ABtn);
  { Force FMX style engine (no native Win32 rendering).
    FMX manages ONE ApplyStyleLookup lifecycle — no manual call → no leaks. }
  ABtn.ControlType := TControlType.Styled;
  { Hide the button's own styled text; we render it via our TLabel child. }
  ABtn.Text           := '';
  ABtn.Padding.Left   := 0;
  ABtn.Padding.Top    := 0;
  ABtn.Padding.Right  := 0;
  ABtn.Padding.Bottom := 0;
  { Register hook for future style re-applications (theme change, etc.). }
  ABtn.OnApplyStyleLookup := GBootstrapHoverHook.ControlApplyStyle;
  BuildButtonVisuals(ABtn, P, AIconName, ACaption, AFontSize);
  { If the FMX style was already applied before ApplyButton was called (the
    common case when styling buttons in FormCreate after the form is visible),
    OnApplyStyleLookup will never fire retroactively.  Call HideStyleChildren
    directly so buttons that are already on-screen are fixed immediately. }
  HideStyleChildren(ABtn);
  AttachHover(ABtn, AVariant);
  { Register for runtime toggle support. }
  GButtonRegistry.Register(ABtn, bsbkButton, AVariant, ACaption, AIconName, AFontSize);
end;

class procedure TBootstrapButtons.ApplyButtonIconOnly(
  const ABtn: TButton;
  AVariant: TBootstrapVariant;
  const ABootstrapIconName: string;
  AFontSize: Single);
begin
  ApplyButton(ABtn, AVariant, '', AFontSize, ABootstrapIconName);
end;

class procedure TBootstrapButtons.ApplyCornerButtonGlyph(
  const ABtn: TCornerButton;
  AVariant: TBootstrapVariant;
  const ABootstrapIconName: string;
  AFontSize: Single);
var
  P: TBootstrapButtonPaint;
begin
  P := ButtonPaint(AVariant);
  RemoveBSChildren(ABtn);
  ABtn.ControlType := TControlType.Styled;
  ABtn.Text           := '';
  ABtn.Padding.Left   := 0;
  ABtn.Padding.Top    := 0;
  ABtn.Padding.Right  := 0;
  ABtn.Padding.Bottom := 0;
  ABtn.OnApplyStyleLookup := GBootstrapHoverHook.ControlApplyStyle;
  BuildButtonVisuals(ABtn, P, ABootstrapIconName, '', AFontSize);
  HideStyleChildren(ABtn);
  AttachHover(ABtn, AVariant);
  { Register for runtime toggle support. Caption is empty (icon-only). }
  GButtonRegistry.Register(ABtn, bsbkCornerButton, AVariant, '', ABootstrapIconName, AFontSize);
end;

{ ── TBootstrapButtons — toggle ─────────────────────────────────────────────── }

class procedure TBootstrapButtons.SetActive(AActive: Boolean);
begin
  GButtonRegistry.SetActive(AActive);
end;

class function TBootstrapButtons.GetActive: Boolean;
begin
  Result := GButtonRegistry.GetActive;
end;

initialization
  GBootstrapHoverHook := TBootstrapHoverHook.Create;
  GButtonRegistry     := TBSButtonRegistry.Create(nil);

finalization
  FreeAndNil(GButtonRegistry);
  FreeAndNil(GBootstrapHoverHook);

end.
