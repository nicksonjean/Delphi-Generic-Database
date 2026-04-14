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
    procedure ApplyDemoChrome;
  public
  end;

var
  FGenericDemoForm: TGenericDemoForm;

implementation

uses
  Frame.Connection,
  Frame.Connector,
  Frame.DataTypes,
  Frame.PagNav,
  BootstrapStyle;

{$R *.fmx}

const
  SIDEBAR_WIDTH = 280;

{ TGenericDemoForm }

procedure TGenericDemoForm.ApplyDemoChrome;
begin
  TBootstrapStyle.ApplyLabelTypography(LblAppTitle);
  TBootstrapStyle.ApplyLabelTypography(LblSectionName);
  TBootstrapStyle.ApplyLabelTypography(LblHamburger);
  TBootstrapStyle.ApplyLabelTypography(LblSidebarTitle);
  TBootstrapStyle.ApplyLabelTypography(LblSidebarSubtitle);
  TBootstrapStyle.ApplyLabelTypography(LblMenuConnectionIcon);
  TBootstrapStyle.ApplyLabelTypography(LblMenuConnectionText);
  TBootstrapStyle.ApplyLabelTypography(LblMenuConnectorIcon);
  TBootstrapStyle.ApplyLabelTypography(LblMenuConnectorText);
  TBootstrapStyle.ApplyLabelTypography(LblMenuDataTypesIcon);
  TBootstrapStyle.ApplyLabelTypography(LblMenuDataTypesText);
  TBootstrapStyle.ApplyLabelTypography(LblMenuPagNavIcon);
  TBootstrapStyle.ApplyLabelTypography(LblMenuPagNavText);

  TBootstrapStyle.ApplyBootstrapIconLabel(LblSidebarTitle, 'database-fill');
  TBootstrapStyle.ApplyBootstrapIconLabel(LblMenuConnectionIcon, 'plug-fill');
  TBootstrapStyle.ApplyBootstrapIconLabel(LblMenuConnectorIcon, 'arrow-left-right');
  TBootstrapStyle.ApplyBootstrapIconLabel(LblMenuDataTypesIcon, 'braces');
  TBootstrapStyle.ApplyBootstrapIconLabel(LblMenuPagNavIcon, 'table');

  TBootstrapStyle.StretchSidebarMenuPills([
    RectMenuConnectionActive,
    RectMenuConnectorActive,
    RectMenuDataTypesActive,
    RectMenuPagNavActive]);
end;

procedure TGenericDemoForm.FormCreate(Sender: TObject);
begin
  FSidebarOpen := False;
  FActiveSection := msNone;
  FActiveFrame := nil;
  ReportMemoryLeaksOnShutdown := True;
  ApplyDemoChrome;
  NavigateTo(msConnection);
end;

procedure TGenericDemoForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FActiveFrame) then
    FreeAndNil(FActiveFrame);
end;

procedure TGenericDemoForm.FormResize(Sender: TObject);
begin
  TBootstrapStyle.StretchSidebarMenuPills([
    RectMenuConnectionActive,
    RectMenuConnectorActive,
    RectMenuDataTypesActive,
    RectMenuPagNavActive]);
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
  TBootstrapStyle.ApplyNavPillState(ARectActive, ALblIcon, ALblText, AActive);
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
  TBootstrapStyle.StretchSidebarMenuPills([
    RectMenuConnectionActive,
    RectMenuConnectorActive,
    RectMenuDataTypesActive,
    RectMenuPagNavActive]);
end;

end.
