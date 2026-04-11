unit GenericDemoForm;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.Layouts,
  FMX.Ani,
  FMX.ScrollBox;

type
  TMenuSection = (msNone, msConnection, msConnector, msDataTypes, msPagNav);

  TGenericDemoForm = class(TForm)
    RectBackground: TRectangle;
    RectHeader: TRectangle;
    RectHamburgerSlot: TRectangle;
    LblHamburger: TLabel;
    LayHeaderCenter: TLayout;
    LblAppTitle: TLabel;
    LayHeaderRight: TLayout;
    LblSectionName: TLabel;
    LayBody: TLayout;
    RectSidebar: TRectangle;
    AnimSidebarShow: TFloatAnimation;
    AnimSidebarHide: TFloatAnimation;
    RectSidebarHeader: TRectangle;
    LblSidebarTitle: TLabel;
    LblSidebarSubtitle: TLabel;
    RectSidebarDivider: TRectangle;
    ScrollSidebarMenu: TVertScrollBox;
    LayMenuConnection: TLayout;
    RectMenuConnectionBg: TRectangle;
    RectMenuConnectionActive: TRectangle;
    LblMenuConnectionIcon: TLabel;
    LblMenuConnectionText: TLabel;
    LayMenuConnector: TLayout;
    RectMenuConnectorBg: TRectangle;
    RectMenuConnectorActive: TRectangle;
    LblMenuConnectorIcon: TLabel;
    LblMenuConnectorText: TLabel;
    LayMenuDataTypes: TLayout;
    RectMenuDataTypesBg: TRectangle;
    RectMenuDataTypesActive: TRectangle;
    LblMenuDataTypesIcon: TLabel;
    LblMenuDataTypesText: TLabel;
    LayMenuPagNav: TLayout;
    RectMenuPagNavBg: TRectangle;
    RectMenuPagNavActive: TRectangle;
    LblMenuPagNavIcon: TLabel;
    LblMenuPagNavText: TLabel;
    RectMenuDivider: TRectangle;
    LayContent: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BtnHamburgerClick(Sender: TObject);
    procedure MenuConnectionClick(Sender: TObject);
    procedure MenuConnectorClick(Sender: TObject);
    procedure MenuDataTypesClick(Sender: TObject);
    procedure MenuPagNavClick(Sender: TObject);
    procedure RectSidebarResize(Sender: TObject);
  private
    FSidebarOpen: Boolean;
    FActiveSection: TMenuSection;
    FActiveFrame: TFrame;
    procedure NavigateTo(ASection: TMenuSection);
    procedure UpdateMenuActiveState(ASection: TMenuSection);
    procedure SetMenuItemActive(
      ARectActive: TRectangle;
      ALblIcon: TLabel;
      ALblText: TLabel;
      AActive: Boolean);
    procedure CloseSidebarIfOpen;
    procedure ApplyWindowsTextTheming;
    procedure ApplyIconFont;
    procedure ApplySidebarMenuPillsLayout;
  public
  end;

var
  FGenericDemoForm: TGenericDemoForm;

implementation

uses
  Frame.Connection,
  Frame.Connector,
  Frame.DataTypes,
  Frame.PagNav;

{$R *.fmx}

const
  SIDEBAR_WIDTH = 280;
  { Bootstrap 5 dark sidebar / .nav-pills (docs example) }
  COLOR_MENU_ACTIVE_ICON   = $FFFFFFFF;
  COLOR_MENU_ACTIVE_TEXT   = $FFFFFFFF;
  COLOR_MENU_ACTIVE_BG     = $FF0D6EFD;
  { Inactive: white icon + label like the official dark sidebar }
  COLOR_MENU_INACTIVE_ICON = $FFFFFFFF;
  COLOR_MENU_INACTIVE_TEXT = $FFFFFFFF;

{ TGenericDemoForm }

procedure TGenericDemoForm.ApplyWindowsTextTheming;
  procedure UnstickLabelFont(const ALabel: TLabel);
  begin
    { Without this, Windows / default FMX styles keep FontColor, Size (and
      sometimes Family) from the style — values set in the .fmx are ignored. }
    ALabel.StyledSettings := ALabel.StyledSettings - [
      TStyledSetting.FontColor,
      TStyledSetting.Size];
  end;
begin
  UnstickLabelFont(LblAppTitle);
  UnstickLabelFont(LblSectionName);
  UnstickLabelFont(LblHamburger);
  UnstickLabelFont(LblSidebarTitle);
  UnstickLabelFont(LblSidebarSubtitle);
  UnstickLabelFont(LblMenuConnectionIcon);
  UnstickLabelFont(LblMenuConnectionText);
  UnstickLabelFont(LblMenuConnectorIcon);
  UnstickLabelFont(LblMenuConnectorText);
  UnstickLabelFont(LblMenuDataTypesIcon);
  UnstickLabelFont(LblMenuDataTypesText);
  UnstickLabelFont(LblMenuPagNavIcon);
  UnstickLabelFont(LblMenuPagNavText);
end;

procedure TGenericDemoForm.ApplySidebarMenuPillsLayout;
  procedure StretchPill(const APill: TRectangle);
  var
    PC: TControl;
  begin
    if not (APill.Parent is TControl) then
      Exit;
    PC := TControl(APill.Parent);
    { Avoid Align=Client here: another sibling (caption) also uses Client and FMX
      then gives the pill only the remaining strip — icon sits outside the blue. }
    APill.Align := TAlignLayout.None;
    APill.SetBounds(0, 0, PC.Width, PC.Height);
  end;
begin
  StretchPill(RectMenuConnectionActive);
  StretchPill(RectMenuConnectorActive);
  StretchPill(RectMenuDataTypesActive);
  StretchPill(RectMenuPagNavActive);
end;

procedure TGenericDemoForm.ApplyIconFont;
  procedure SetIcon(ALabel: TLabel; AGlyph: Char);
  begin
    ALabel.StyledSettings := ALabel.StyledSettings - [
      TStyledSetting.Family,
      TStyledSetting.Size];
    ALabel.TextSettings.Font.Family := 'bootstrap-icons';
    ALabel.Text := AGlyph;
  end;
begin
  SetIcon(LblSidebarTitle,       Chr(63678)); // database-fill  (header)
  SetIcon(LblMenuConnectionIcon, Chr(62710)); // plug-fill
  SetIcon(LblMenuConnectorIcon,  Chr(61739)); // arrow-left-right
  SetIcon(LblMenuDataTypesIcon,  Chr(61897)); // braces
  SetIcon(LblMenuPagNavIcon,     Chr(62890)); // table
end;

procedure TGenericDemoForm.FormCreate(Sender: TObject);
begin
  FSidebarOpen := False;
  FActiveSection := msNone;
  FActiveFrame := nil;
  ReportMemoryLeaksOnShutdown := True;
  ApplyWindowsTextTheming;
  ApplyIconFont;
  ApplySidebarMenuPillsLayout;
  NavigateTo(msConnection);
end;

procedure TGenericDemoForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FActiveFrame) then
    FreeAndNil(FActiveFrame);
end;

procedure TGenericDemoForm.FormResize(Sender: TObject);
begin
  ApplySidebarMenuPillsLayout;
end;

procedure TGenericDemoForm.BtnHamburgerClick(Sender: TObject);
begin
  if FSidebarOpen then
  begin
    AnimSidebarHide.Start;
    FSidebarOpen := False;
  end
  else
  begin
    AnimSidebarShow.Start;
    FSidebarOpen := True;
  end;
end;

procedure TGenericDemoForm.CloseSidebarIfOpen;
begin
  if FSidebarOpen then
  begin
    AnimSidebarHide.Start;
    FSidebarOpen := False;
  end;
end;

procedure TGenericDemoForm.SetMenuItemActive(
  ARectActive: TRectangle;
  ALblIcon: TLabel;
  ALblText: TLabel;
  AActive: Boolean);
begin
  ARectActive.Visible := AActive;
  ARectActive.Fill.Color := COLOR_MENU_ACTIVE_BG;
  if AActive then
  begin
    ALblIcon.TextSettings.FontColor := COLOR_MENU_ACTIVE_ICON;
    ALblText.TextSettings.FontColor := COLOR_MENU_ACTIVE_TEXT;
  end
  else
  begin
    ALblIcon.TextSettings.FontColor := COLOR_MENU_INACTIVE_ICON;
    ALblText.TextSettings.FontColor := COLOR_MENU_INACTIVE_TEXT;
  end;
end;

procedure TGenericDemoForm.UpdateMenuActiveState(ASection: TMenuSection);
begin
  SetMenuItemActive(RectMenuConnectionActive, LblMenuConnectionIcon, LblMenuConnectionText, ASection = msConnection);
  SetMenuItemActive(RectMenuConnectorActive,  LblMenuConnectorIcon,  LblMenuConnectorText,  ASection = msConnector);
  SetMenuItemActive(RectMenuDataTypesActive,  LblMenuDataTypesIcon,  LblMenuDataTypesText,  ASection = msDataTypes);
  SetMenuItemActive(RectMenuPagNavActive,     LblMenuPagNavIcon,     LblMenuPagNavText,     ASection = msPagNav);
end;

procedure TGenericDemoForm.NavigateTo(ASection: TMenuSection);
var
  LSectionName: String;
begin
  if ASection = FActiveSection then
  begin
    CloseSidebarIfOpen;
    Exit;
  end;

  // Remove current frame
  if Assigned(FActiveFrame) then
  begin
    LayContent.RemoveObject(FActiveFrame);
    FreeAndNil(FActiveFrame);
  end;

  FActiveSection := ASection;

  // Create the new frame
  case ASection of
    msConnection:
    begin
      FActiveFrame := TFrameConnection.Create(Self);
      LSectionName := 'Connection';
    end;
    msConnector:
    begin
      FActiveFrame := TFrameConnector.Create(Self);
      LSectionName := 'Connector';
    end;
    msDataTypes:
    begin
      FActiveFrame := TFrameDataTypes.Create(Self);
      LSectionName := 'DataTypes';
    end;
    msPagNav:
    begin
      FActiveFrame := TFramePagNav.Create(Self);
      LSectionName := 'PagNav';
    end;
  else
    LSectionName := '';
  end;

  // Embed frame in content area
  if Assigned(FActiveFrame) then
  begin
    FActiveFrame.Parent := LayContent;
    FActiveFrame.Align := TAlignLayout.Client;
  end;

  // Update UI
  LblSectionName.Text := LSectionName;
  UpdateMenuActiveState(ASection);
  CloseSidebarIfOpen;
end;

procedure TGenericDemoForm.MenuConnectionClick(Sender: TObject);
begin
  NavigateTo(msConnection);
end;

procedure TGenericDemoForm.MenuConnectorClick(Sender: TObject);
begin
  NavigateTo(msConnector);
end;

procedure TGenericDemoForm.MenuDataTypesClick(Sender: TObject);
begin
  NavigateTo(msDataTypes);
end;

procedure TGenericDemoForm.MenuPagNavClick(Sender: TObject);
begin
  NavigateTo(msPagNav);
end;

procedure TGenericDemoForm.RectSidebarResize(Sender: TObject);
begin
  ApplySidebarMenuPillsLayout;
end;

end.
