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
  { Bootstrap-like dark navbar on sidebar }
  COLOR_MENU_ACTIVE_ICON   = $FFFFFFFF;
  COLOR_MENU_ACTIVE_TEXT   = $FFFFFFFF;
  COLOR_MENU_ACTIVE_BG     = $FF0D6EFD;
  COLOR_MENU_INACTIVE_ICON = $FFADB5BD;
  COLOR_MENU_INACTIVE_TEXT = $FFF8F9FA;
  COLOR_MENU_INACTIVE_BG   = $00000000;

{ TGenericDemoForm }

procedure TGenericDemoForm.ApplyWindowsTextTheming;
  procedure UnstickFontColor(const AControl: TControl);
  begin
    if AControl is TLabel then
      TLabel(AControl).StyledSettings :=
        TLabel(AControl).StyledSettings - [TStyledSetting.FontColor];
    if AControl is TButton then
      TButton(AControl).StyledSettings :=
        TButton(AControl).StyledSettings - [TStyledSetting.FontColor];
  end;
begin
  UnstickFontColor(LblAppTitle);
  UnstickFontColor(LblSectionName);
  UnstickFontColor(LblHamburger);
  UnstickFontColor(LblSidebarTitle);
  UnstickFontColor(LblSidebarSubtitle);
  UnstickFontColor(LblMenuConnectionIcon);
  UnstickFontColor(LblMenuConnectionText);
  UnstickFontColor(LblMenuConnectorIcon);
  UnstickFontColor(LblMenuConnectorText);
  UnstickFontColor(LblMenuDataTypesIcon);
  UnstickFontColor(LblMenuDataTypesText);
  UnstickFontColor(LblMenuPagNavIcon);
  UnstickFontColor(LblMenuPagNavText);
end;

procedure TGenericDemoForm.ApplyIconFont;
  procedure SetIcon(ALabel: TLabel; AGlyph: Char);
  begin
    // Remove Family from StyledSettings so FMX does not override our custom
    // font with the system theme font at render time.
    ALabel.StyledSettings := ALabel.StyledSettings - [TStyledSetting.Family];
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
  NavigateTo(msConnection);
end;

procedure TGenericDemoForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FActiveFrame) then
    FreeAndNil(FActiveFrame);
end;

procedure TGenericDemoForm.FormResize(Sender: TObject);
begin
  // Content area adjusts automatically via Align=Client
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
var
  LBgColor: TAlphaColor;
begin
  ARectActive.Visible := False;
  if AActive then
  begin
    ALblIcon.TextSettings.FontColor := COLOR_MENU_ACTIVE_ICON;
    ALblText.TextSettings.FontColor := COLOR_MENU_ACTIVE_TEXT;
    LBgColor := COLOR_MENU_ACTIVE_BG;
  end
  else
  begin
    ALblIcon.TextSettings.FontColor := COLOR_MENU_INACTIVE_ICON;
    ALblText.TextSettings.FontColor := COLOR_MENU_INACTIVE_TEXT;
    LBgColor := COLOR_MENU_INACTIVE_BG;
  end;
  TRectangle(ARectActive.Parent).Fill.Color := LBgColor;
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

end.
