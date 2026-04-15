unit BootstrapStyle;

(*
  Bootstrap 5 look for FireMonkey — unified public façade, no StyleBook required.

  Architecture
  ────────────
  All implementation lives in focused sub-units.  Callers need only:
    uses BootstrapStyle;          { buttons, nav, labels }
    uses BootstrapStyle.Core;     { for bsPrimary / bsSecondary … enum values }
    uses BootstrapStyle.Forms;    { for form-control Apply methods }

  Sub-units:
    BootstrapStyle.Core     — TBootstrapVariant, TBootstrapButtonPaint, BS_ constants
    BootstrapStyle.Colors   — Bootstrap 5.3 theme colour constants
    BootstrapStyle.Icons    — bootstrap-icons glyph map (TBootstrapIcons)
    BootstrapStyle.Buttons  — button styling engine (TBootstrapButtons)
    BootstrapStyle.Forms    — form control styling engine (TBootstrapForms)

  TBootstrapStyle is a stateless class-method façade that delegates every call
  to the appropriate sub-unit class.  No state, no lifecycle, no leaks.

  Runtime toggle
  ──────────────
    TBootstrapStyle.SetBootstrapActive(False)  — reverts ALL styled controls
                                                 (buttons + form controls)
                                                 to FMX / Windows default look.
    TBootstrapStyle.SetBootstrapActive(True)   — re-applies Bootstrap 5 to all
                                                 registered controls.
    TBootstrapStyle.GetBootstrapActive         — current state.
*)

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
  FMX.Objects,
  FMX.Layouts,
  FMX.Ani,
  FMX.Memo,
  FMX.SearchBox,
  FMX.ListView,
  BootstrapStyle.Core;   { re-exported so callers get TBootstrapVariant in scope }

{ Type aliases — keep TBootstrapVariant and TBootstrapButtonPaint accessible
  through "uses BootstrapStyle" without requiring callers to also list
  BootstrapStyle.Core explicitly. }
type
  TBootstrapVariant     = BootstrapStyle.Core.TBootstrapVariant;
  TBootstrapButtonPaint = BootstrapStyle.Core.TBootstrapButtonPaint;

  TBootstrapStyle = class
  private
    class procedure StretchMenuPill(const APill: TRectangle); static;

  public
    { ── Typography ────────────────────────────────────────────────────── }
    class procedure ApplyLabelTypography(const ALabel: TLabel); static;
    class procedure ApplyBootstrapIconLabel(
      const ALabel: TLabel;
      const ABootstrapIconName: string); static;

    { ── Navigation pills ──────────────────────────────────────────────── }
    class procedure ApplyNavPillState(
      const ARectActive: TRectangle;
      const ALblIcon, ALblText: TLabel;
      AActive: Boolean); static;

    class procedure StretchSidebarMenuPills(
      const APills: array of TRectangle); static;

    { ── Buttons (BootstrapStyle.Buttons) ─────────────────────────────── }

    { Solid button with optional left-side icon. AIconName='' → text-only. }
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

    { Hover callbacks — forwarded to TBootstrapButtons; exposed for backward
      compatibility in case any external code holds a reference to them. }
    class procedure ProcessHoverEnter(Sender: TObject); static;
    class procedure ProcessHoverLeave(Sender: TObject); static;

    { ── Form controls (BootstrapStyle.Forms) ─────────────────────────── }

    { Registers + styles a TEdit as a Bootstrap 5 form-control. }
    class procedure ApplyEdit(
      const AEdit: TEdit;
      AFontSize: Single = 14); static;

    { Registers + styles a TComboBox as a Bootstrap 5 form-select. }
    class procedure ApplyComboBox(
      const ACombo: TComboBox;
      AFontSize: Single = 14); static;

    { Registers + styles a TComboEdit (type-ahead) as Bootstrap 5 form-control. }
    class procedure ApplyComboEdit(
      const AComboEdit: TComboEdit;
      AFontSize: Single = 14); static;

    { Registers + styles a TListBox as a Bootstrap 5 list-group. }
    class procedure ApplyListBox(
      const AListBox: TListBox;
      AFontSize: Single = 14); static;

    { Registers + styles a TGrid as a Bootstrap 5 table. }
    class procedure ApplyGrid(
      const AGrid: TGrid;
      AFontSize: Single = 13); static;

    { Registers + styles a TStringGrid as a Bootstrap 5 table. }
    class procedure ApplyStringGrid(
      const AGrid: TStringGrid;
      AFontSize: Single = 13); static;

    { Registers + styles a TMemo as a Bootstrap 5 textarea. }
    class procedure ApplyMemo(
      const AMemo: TMemo;
      AFontSize: Single = 14); static;

    { Registers + styles a TSearchBox as a Bootstrap 5 search input. }
    class procedure ApplySearchBox(
      const ASearchBox: TSearchBox;
      AFontSize: Single = 14); static;

    { Registers + styles a TListView as a Bootstrap 5 list. }
    class procedure ApplyListView(
      const AListView: TListView;
      AFontSize: Single = 13); static;

    { ── Global runtime toggle ─────────────────────────────────────────── }

    { Switches ALL registered controls (buttons + form controls) between
      Bootstrap 5 styling and the FMX / Windows default look at runtime. }
    class procedure SetBootstrapActive(AActive: Boolean); static;
    class function  GetBootstrapActive: Boolean; static;
  end;

implementation

uses
  FMX.Graphics,
  BootstrapStyle.Colors,
  BootstrapStyle.Icons,
  BootstrapStyle.Buttons,
  BootstrapStyle.Forms;

{ ── TBootstrapStyle — typography ──────────────────────────────────────────── }

class procedure TBootstrapStyle.ApplyLabelTypography(const ALabel: TLabel);
begin
  ALabel.StyledSettings := ALabel.StyledSettings - [
    TStyledSetting.FontColor,
    TStyledSetting.Size];
end;

class procedure TBootstrapStyle.ApplyBootstrapIconLabel(
  const ALabel: TLabel;
  const ABootstrapIconName: string);
begin
  ALabel.StyledSettings := ALabel.StyledSettings - [
    TStyledSetting.Family,
    TStyledSetting.Size];
  ALabel.TextSettings.Font.Family := TBootstrapIcons.FontFamily;
  ALabel.Text := TBootstrapIcons.Glyph(ABootstrapIconName);
end;

{ ── TBootstrapStyle — navigation pills ────────────────────────────────────── }

class procedure TBootstrapStyle.ApplyNavPillState(
  const ARectActive: TRectangle;
  const ALblIcon, ALblText: TLabel;
  AActive: Boolean);
begin
  ARectActive.Visible    := AActive;
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

class procedure TBootstrapStyle.StretchSidebarMenuPills(
  const APills: array of TRectangle);
var
  I: Integer;
begin
  for I := Low(APills) to High(APills) do
    StretchMenuPill(APills[I]);
end;

{ ── TBootstrapStyle — buttons (delegate to TBootstrapButtons) ─────────────── }

class procedure TBootstrapStyle.ApplyButton(
  const ABtn: TButton;
  AVariant: TBootstrapVariant;
  const ACaption: string;
  AFontSize: Single;
  const AIconName: string);
begin
  TBootstrapButtons.ApplyButton(ABtn, AVariant, ACaption, AFontSize, AIconName);
end;

class procedure TBootstrapStyle.ApplyButtonIconOnly(
  const ABtn: TButton;
  AVariant: TBootstrapVariant;
  const ABootstrapIconName: string;
  AFontSize: Single);
begin
  TBootstrapButtons.ApplyButtonIconOnly(ABtn, AVariant, ABootstrapIconName, AFontSize);
end;

class procedure TBootstrapStyle.ApplyCornerButtonGlyph(
  const ABtn: TCornerButton;
  AVariant: TBootstrapVariant;
  const ABootstrapIconName: string;
  AFontSize: Single);
begin
  TBootstrapButtons.ApplyCornerButtonGlyph(ABtn, AVariant, ABootstrapIconName, AFontSize);
end;

class procedure TBootstrapStyle.ProcessHoverEnter(Sender: TObject);
begin
  TBootstrapButtons.ProcessHoverEnter(Sender);
end;

class procedure TBootstrapStyle.ProcessHoverLeave(Sender: TObject);
begin
  TBootstrapButtons.ProcessHoverLeave(Sender);
end;

{ ── TBootstrapStyle — form controls (delegate to TBootstrapForms) ─────────── }

class procedure TBootstrapStyle.ApplyEdit(const AEdit: TEdit; AFontSize: Single);
begin
  TBootstrapForms.ApplyEdit(AEdit, AFontSize);
end;

class procedure TBootstrapStyle.ApplyComboBox(const ACombo: TComboBox; AFontSize: Single);
begin
  TBootstrapForms.ApplyComboBox(ACombo, AFontSize);
end;

class procedure TBootstrapStyle.ApplyComboEdit(const AComboEdit: TComboEdit; AFontSize: Single);
begin
  TBootstrapForms.ApplyComboEdit(AComboEdit, AFontSize);
end;

class procedure TBootstrapStyle.ApplyListBox(const AListBox: TListBox; AFontSize: Single);
begin
  TBootstrapForms.ApplyListBox(AListBox, AFontSize);
end;

class procedure TBootstrapStyle.ApplyGrid(const AGrid: TGrid; AFontSize: Single);
begin
  TBootstrapForms.ApplyGrid(AGrid, AFontSize);
end;

class procedure TBootstrapStyle.ApplyStringGrid(const AGrid: TStringGrid; AFontSize: Single);
begin
  TBootstrapForms.ApplyStringGrid(AGrid, AFontSize);
end;

class procedure TBootstrapStyle.ApplyMemo(const AMemo: TMemo; AFontSize: Single);
begin
  TBootstrapForms.ApplyMemo(AMemo, AFontSize);
end;

class procedure TBootstrapStyle.ApplySearchBox(const ASearchBox: TSearchBox; AFontSize: Single);
begin
  TBootstrapForms.ApplySearchBox(ASearchBox, AFontSize);
end;

class procedure TBootstrapStyle.ApplyListView(const AListView: TListView; AFontSize: Single);
begin
  TBootstrapForms.ApplyListView(AListView, AFontSize);
end;

{ ── TBootstrapStyle — global toggle ───────────────────────────────────────── }

class procedure TBootstrapStyle.SetBootstrapActive(AActive: Boolean);
begin
  { Toggle buttons first, then form controls.  Each registry is independent
    and tracks only the controls it knows about. }
  TBootstrapButtons.SetActive(AActive);
  TBootstrapForms.SetActive(AActive);
end;

class function TBootstrapStyle.GetBootstrapActive: Boolean;
begin
  { Both registries must agree; buttons are the authoritative source since they
    are always styled and their state is updated atomically with forms. }
  Result := TBootstrapButtons.GetActive;
end;

end.
