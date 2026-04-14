unit BootstrapStyle;

{
  Bootstrap 5 look for FireMonkey — fully code-defined, no StyleBook.

  Zero-leak architecture
  ─────────────────────
  Previous approach called ApplyStyleLookup explicitly, which cloned the FMX
  style graph BEFORE FMX cloned it naturally on first paint → two allocations,
  one never freed → the AV/leak report.

  New approach:
  • ControlType := TControlType.Styled  →  disables native Win32 rendering,
    lets FMX own the style lifecycle (one natural ApplyStyleLookup, properly
    freed when the button is destroyed).
  • We NEVER call ApplyStyleLookup ourselves.
  • A TRectangle child ("__BSBg__") provides the solid Bootstrap background.
    FMX calls FStyleObject.SendToBack() inside its own ApplyStyleLookup, so
    FStyleObject is always behind our rect regardless of call order.
  • TLabel "__BSIcon__" renders the bootstrap-icons glyph on the left.
  • TLabel "__BSText__" (inside a TLayout) renders the caption on the right.
  • Both labels have HitTest=False so clicks fall through to the TButton.
  • Hover: TColorAnimation on the rect Fill.Color (0.15 s, Bootstrap colours).
  • All child objects owned by the button → freed automatically on destroy.
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
  FMX.Ani;

type
  TBootstrapVariant = (
    bsPrimary,
    bsSecondary,
    bsSuccess,
    bsDanger,
    bsWarning,
    bsInfo,
    bsLight,
    bsDark,
    bsLink);

  TBootstrapButtonPaint = record
    Normal, Hover: TAlphaColor;
    TextColor: TAlphaColor;
    Solid: Boolean;
  end;

  TBootstrapStyle = class
  private
    const
      HoverTagBase  = 910000000;
      BS_BG_NAME    = '__BSBg__';
      BS_INNER_NAME = '__BSInner__';
      BS_ICON_NAME  = '__BSIcon__';
      BS_TEXT_NAME  = '__BSText__';

    class function  ButtonPaint(AVariant: TBootstrapVariant): TBootstrapButtonPaint; static;
    class function  TryVariantFromTag(const ATag: Integer; out V: TBootstrapVariant): Boolean; static;
    class procedure RemoveBSChildren(const C: TControl); static;
    class function  FindBSBackground(const C: TControl): TRectangle; static;
    class function  FindBSAnimation(const R: TRectangle): TColorAnimation; static;
    class procedure AttachHover(const C: TControl; AVariant: TBootstrapVariant); static;
    class procedure StretchMenuPill(const APill: TRectangle); static;

    class procedure BuildButtonVisuals(
      const C: TControl;
      const P: TBootstrapButtonPaint;
      const AIconName, ACaption: string;
      AFontSize: Single); static;

  public
    { Used by TBootstrapHoverHook (TNotifyEvent requires a method pointer). }
    class procedure ProcessHoverEnter(Sender: TObject); static;
    class procedure ProcessHoverLeave(Sender: TObject); static;

    class procedure ApplyLabelTypography(const ALabel: TLabel); static;
    class procedure ApplyBootstrapIconLabel(const ALabel: TLabel; const ABootstrapIconName: string); static;

    class procedure ApplyNavPillState(
      const ARectActive: TRectangle;
      const ALblIcon, ALblText: TLabel;
      AActive: Boolean); static;

    class procedure StretchSidebarMenuPills(const APills: array of TRectangle); static;

    { AIconName is optional — empty string means text-only button. }
    class procedure ApplyButton(
      const ABtn: TButton;
      AVariant: TBootstrapVariant;
      const ACaption: string;
      AFontSize: Single = 15;
      const AIconName: string = ''); static;

    { Icon-only TButton (no caption). }
    class procedure ApplyButtonIconOnly(
      const ABtn: TButton;
      AVariant: TBootstrapVariant;
      const ABootstrapIconName: string;
      AFontSize: Single = 18); static;

    { TCornerButton with a single bootstrap-icons glyph. }
    class procedure ApplyCornerButtonGlyph(
      const ABtn: TCornerButton;
      AVariant: TBootstrapVariant;
      const ABootstrapIconName: string;
      AFontSize: Single = 14); static;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  FMX.Graphics,
  BootstrapStyle.Colors,
  BootstrapStyle.Icons;

type
  TBootstrapHoverHook = class
  public
    procedure ControlMouseEnter(Sender: TObject);
    procedure ControlMouseLeave(Sender: TObject);
  end;

var
  GBootstrapHoverHook: TBootstrapHoverHook;

{ TBootstrapHoverHook }

procedure TBootstrapHoverHook.ControlMouseEnter(Sender: TObject);
begin
  TBootstrapStyle.ProcessHoverEnter(Sender);
end;

procedure TBootstrapHoverHook.ControlMouseLeave(Sender: TObject);
begin
  TBootstrapStyle.ProcessHoverLeave(Sender);
end;

{ TBootstrapStyle — private helpers }

class function TBootstrapStyle.ButtonPaint(AVariant: TBootstrapVariant): TBootstrapButtonPaint;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Solid := True;
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

class function TBootstrapStyle.TryVariantFromTag(const ATag: Integer; out V: TBootstrapVariant): Boolean;
var
  O: Integer;
begin
  O := ATag - HoverTagBase;
  if (O < 0) or (O > Ord(High(TBootstrapVariant))) then
    Exit(False);
  V := TBootstrapVariant(O);
  Result := True;
end;

class procedure TBootstrapStyle.RemoveBSChildren(const C: TControl);
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

class function TBootstrapStyle.FindBSBackground(const C: TControl): TRectangle;
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

class function TBootstrapStyle.FindBSAnimation(const R: TRectangle): TColorAnimation;
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

class procedure TBootstrapStyle.AttachHover(const C: TControl; AVariant: TBootstrapVariant);
begin
  C.Tag := HoverTagBase + Ord(AVariant);
  C.OnMouseEnter := GBootstrapHoverHook.ControlMouseEnter;
  C.OnMouseLeave := GBootstrapHoverHook.ControlMouseLeave;
end;

class procedure TBootstrapStyle.BuildButtonVisuals(
  const C: TControl;
  const P: TBootstrapButtonPaint;
  const AIconName, ACaption: string;
  AFontSize: Single);
var
  BGRect: TRectangle;
  Anim: TColorAnimation;
  InnerLayout: TLayout;
  IconLbl: TLabel;
  TextLbl: TLabel;
  HasIcon: Boolean;
  HasCaption: Boolean;
begin
  HasIcon    := (AIconName <> '') and (TBootstrapIcons.Glyph(AIconName) <> '');
  HasCaption := (ACaption <> '');

  { ── Background rectangle ── }
  if P.Solid then
  begin
    BGRect := TRectangle.Create(C);
    BGRect.Name     := BS_BG_NAME;
    BGRect.Parent   := C;
    BGRect.Align    := TAlignLayout.Client;
    BGRect.HitTest  := False;
    BGRect.Fill.Kind  := TBrushKind.Solid;
    BGRect.Fill.Color := P.Normal;
    BGRect.Stroke.Kind := TBrushKind.None;
    BGRect.XRadius  := 6;
    BGRect.YRadius  := 6;

    { Smooth hover animation (0.15 s — Bootstrap default transition). }
    Anim := TColorAnimation.Create(BGRect);
    Anim.Parent       := BGRect;
    Anim.PropertyName := 'Fill.Color';
    Anim.Duration     := 0.15;
    Anim.StartValue   := P.Normal;
    Anim.StopValue    := P.Hover;
    Anim.AutoReverse  := False;
    Anim.Loop         := False;
    Anim.Enabled      := True;
  end;

  { ── Content: icon-left + text-right, icon-only, or text-only ── }
  if HasIcon and HasCaption then
  begin
    { Horizontal layout: [icon label][text label] }
    InnerLayout := TLayout.Create(C);
    InnerLayout.Name    := BS_INNER_NAME;
    InnerLayout.Parent  := C;
    InnerLayout.Align   := TAlignLayout.Client;
    InnerLayout.HitTest := False;
    InnerLayout.Margins.Left  := 12;
    InnerLayout.Margins.Right := 12;

    IconLbl := TLabel.Create(C);
    IconLbl.Name    := BS_ICON_NAME;
    IconLbl.Parent  := InnerLayout;
    IconLbl.Align   := TAlignLayout.Left;
    IconLbl.Width   := AFontSize + 8;
    IconLbl.HitTest := False;
    IconLbl.AutoSize := False;
    IconLbl.StyledSettings := [];
    IconLbl.TextSettings.Font.Family := TBootstrapIcons.FontFamily;
    IconLbl.TextSettings.Font.Size   := AFontSize;
    IconLbl.TextSettings.Font.Style  := [];
    IconLbl.TextSettings.HorzAlign   := TTextAlign.Center;
    IconLbl.TextSettings.VertAlign   := TTextAlign.Center;
    IconLbl.TextSettings.FontColor   := P.TextColor;
    IconLbl.Text := TBootstrapIcons.Glyph(AIconName);

    TextLbl := TLabel.Create(C);
    TextLbl.Name    := BS_TEXT_NAME;
    TextLbl.Parent  := InnerLayout;
    TextLbl.Align   := TAlignLayout.Client;
    TextLbl.HitTest := False;
    TextLbl.AutoSize := False;
    TextLbl.StyledSettings := [];
    TextLbl.TextSettings.Font.Family := 'Segoe UI';
    TextLbl.TextSettings.Font.Size   := AFontSize;
    TextLbl.TextSettings.Font.Style  := [];
    TextLbl.TextSettings.HorzAlign   := TTextAlign.Leading;
    TextLbl.TextSettings.VertAlign   := TTextAlign.Center;
    TextLbl.TextSettings.FontColor   := P.TextColor;
    TextLbl.Text := ACaption;
  end
  else if HasIcon then
  begin
    { Icon-only: centred }
    IconLbl := TLabel.Create(C);
    IconLbl.Name    := BS_ICON_NAME;
    IconLbl.Parent  := C;
    IconLbl.Align   := TAlignLayout.Client;
    IconLbl.HitTest := False;
    IconLbl.AutoSize := False;
    IconLbl.StyledSettings := [];
    IconLbl.TextSettings.Font.Family := TBootstrapIcons.FontFamily;
    IconLbl.TextSettings.Font.Size   := AFontSize;
    IconLbl.TextSettings.Font.Style  := [];
    IconLbl.TextSettings.HorzAlign   := TTextAlign.Center;
    IconLbl.TextSettings.VertAlign   := TTextAlign.Center;
    IconLbl.TextSettings.FontColor   := P.TextColor;
    IconLbl.Text := TBootstrapIcons.Glyph(AIconName);
  end
  else if HasCaption then
  begin
    { Text-only: centred }
    TextLbl := TLabel.Create(C);
    TextLbl.Name    := BS_TEXT_NAME;
    TextLbl.Parent  := C;
    TextLbl.Align   := TAlignLayout.Client;
    TextLbl.HitTest := False;
    TextLbl.AutoSize := False;
    TextLbl.StyledSettings := [];
    TextLbl.TextSettings.Font.Family := 'Segoe UI';
    TextLbl.TextSettings.Font.Size   := AFontSize;
    TextLbl.TextSettings.Font.Style  := [];
    TextLbl.TextSettings.HorzAlign   := TTextAlign.Center;
    TextLbl.TextSettings.VertAlign   := TTextAlign.Center;
    TextLbl.TextSettings.FontColor   := P.TextColor;
    TextLbl.Text := ACaption;
  end;
end;

{ TBootstrapStyle — public }

class procedure TBootstrapStyle.ProcessHoverEnter(Sender: TObject);
var
  V: TBootstrapVariant;
  P: TBootstrapButtonPaint;
  Ctrl: TControl;
  BG: TRectangle;
  Anim: TColorAnimation;
begin
  if not (Sender is TControl) then Exit;
  Ctrl := TControl(Sender);
  if csDestroying in Ctrl.ComponentState then Exit;
  if not TryVariantFromTag(Ctrl.Tag, V) then Exit;
  P  := ButtonPaint(V);
  BG := FindBSBackground(Ctrl);
  if BG = nil then Exit;
  Anim := FindBSAnimation(BG);
  if Anim <> nil then
  begin
    Anim.StartValue := BG.Fill.Color;   { from current (may be mid-anim) }
    Anim.StopValue  := P.Hover;
    Anim.Inverse    := False;
    Anim.Start;
  end
  else
    BG.Fill.Color := P.Hover;
end;

class procedure TBootstrapStyle.ProcessHoverLeave(Sender: TObject);
var
  V: TBootstrapVariant;
  P: TBootstrapButtonPaint;
  Ctrl: TControl;
  BG: TRectangle;
  Anim: TColorAnimation;
begin
  if not (Sender is TControl) then Exit;
  Ctrl := TControl(Sender);
  if csDestroying in Ctrl.ComponentState then Exit;
  if not TryVariantFromTag(Ctrl.Tag, V) then Exit;
  P  := ButtonPaint(V);
  BG := FindBSBackground(Ctrl);
  if BG = nil then Exit;
  Anim := FindBSAnimation(BG);
  if Anim <> nil then
  begin
    Anim.StartValue := BG.Fill.Color;   { from current }
    Anim.StopValue  := P.Normal;
    Anim.Inverse    := False;
    Anim.Start;
  end
  else
    BG.Fill.Color := P.Normal;
end;

class procedure TBootstrapStyle.ApplyLabelTypography(const ALabel: TLabel);
begin
  ALabel.StyledSettings := ALabel.StyledSettings - [
    TStyledSetting.FontColor,
    TStyledSetting.Size];
end;

class procedure TBootstrapStyle.ApplyBootstrapIconLabel(const ALabel: TLabel; const ABootstrapIconName: string);
begin
  ALabel.StyledSettings := ALabel.StyledSettings - [
    TStyledSetting.Family,
    TStyledSetting.Size];
  ALabel.TextSettings.Font.Family := TBootstrapIcons.FontFamily;
  ALabel.Text := TBootstrapIcons.Glyph(ABootstrapIconName);
end;

class procedure TBootstrapStyle.ApplyNavPillState(
  const ARectActive: TRectangle;
  const ALblIcon, ALblText: TLabel;
  AActive: Boolean);
begin
  ARectActive.Visible := AActive;
  ARectActive.Fill.Color := BS_MENU_ACTIVE_BG;
  if AActive then
  begin
    ALblIcon.TextSettings.FontColor := BS_MENU_ACTIVE_ICON;
    ALblText.TextSettings.FontColor := BS_MENU_ACTIVE_TEXT;
  end
  else
  begin
    ALblIcon.TextSettings.FontColor := BS_MENU_INACTIVE_ICON;
    ALblText.TextSettings.FontColor := BS_MENU_INACTIVE_TEXT;
  end;
end;

class procedure TBootstrapStyle.StretchMenuPill(const APill: TRectangle);
var
  PC: TControl;
begin
  if not (APill.Parent is TControl) then Exit;
  PC := TControl(APill.Parent);
  APill.Align := TAlignLayout.None;
  APill.SetBounds(0, 0, PC.Width, PC.Height);
end;

class procedure TBootstrapStyle.StretchSidebarMenuPills(const APills: array of TRectangle);
var
  I: Integer;
begin
  for I := Low(APills) to High(APills) do
    StretchMenuPill(APills[I]);
end;

class procedure TBootstrapStyle.ApplyButton(
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
  { Hide the button's own styled text (we render it via our TLabel child). }
  ABtn.Text := '';
  ABtn.Padding.Left   := 0;
  ABtn.Padding.Top    := 0;
  ABtn.Padding.Right  := 0;
  ABtn.Padding.Bottom := 0;
  BuildButtonVisuals(ABtn, P, AIconName, ACaption, AFontSize);
  AttachHover(ABtn, AVariant);
end;

class procedure TBootstrapStyle.ApplyButtonIconOnly(
  const ABtn: TButton;
  AVariant: TBootstrapVariant;
  const ABootstrapIconName: string;
  AFontSize: Single);
begin
  ApplyButton(ABtn, AVariant, '', AFontSize, ABootstrapIconName);
end;

class procedure TBootstrapStyle.ApplyCornerButtonGlyph(
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
  ABtn.Text := '';
  ABtn.Padding.Left   := 0;
  ABtn.Padding.Top    := 0;
  ABtn.Padding.Right  := 0;
  ABtn.Padding.Bottom := 0;
  BuildButtonVisuals(ABtn, P, ABootstrapIconName, '', AFontSize);
  AttachHover(ABtn, AVariant);
end;

initialization
  GBootstrapHoverHook := TBootstrapHoverHook.Create;

finalization
  FreeAndNil(GBootstrapHoverHook);

end.
