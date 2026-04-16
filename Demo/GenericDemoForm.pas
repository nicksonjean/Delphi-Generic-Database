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
  TMenuSection = (msNone, msBootstrapShowcase, msConnection, msConnector, msDataTypes, msPagNav);

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
    ScrollSidebarMenu: TVertScrollBox;
    LayMenuShowcase: TLayout;
    BtnMenuShowcase: TButton;
    LayMenuConnection: TLayout;
    BtnMenuConnection: TButton;
    LayMenuConnector: TLayout;
    BtnMenuConnector: TButton;
    LayMenuDataTypes: TLayout;
    BtnMenuDataTypes: TButton;
    LayMenuPagNav: TLayout;
    BtnMenuPagNav: TButton;
    LayContent: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnHamburgerClick(Sender: TObject);
    procedure MenuShowcaseClick(Sender: TObject);
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
    procedure CloseSidebarIfOpen;
    procedure ApplyDemoChrome;
  public
  end;

var
  FGenericDemoForm: TGenericDemoForm;

implementation

uses
  Frame.BootstrapShowcase,
  Frame.Connection,
  Frame.Connector,
  Frame.DataTypes,
  Frame.PagNav,
  BootstrapStyle,
  BootstrapStyle.Core;

{$R *.fmx}

const
  SIDEBAR_WIDTH = 280;
  { Same font size as Icon + Text row in Frame.BootstrapShowcase (ApplyButton …, 15, …). }
  SIDEBAR_NAV_FONT = 15;

{ TGenericDemoForm }

procedure TGenericDemoForm.ApplyDemoChrome;
begin
  TBootstrapStyle.ApplyLabelTypography(LblAppTitle);
  TBootstrapStyle.ApplyLabelTypography(LblSectionName);
  TBootstrapStyle.ApplyLabelTypography(LblHamburger);
  TBootstrapStyle.ApplyLabelTypography(LblSidebarTitle);
  TBootstrapStyle.ApplyLabelTypography(LblSidebarSubtitle);

  TBootstrapStyle.ApplyBootstrapIconLabel(LblSidebarTitle, 'database-fill');
end;

procedure TGenericDemoForm.FormCreate(Sender: TObject);
begin
  FSidebarOpen := False;
  FActiveSection := msNone;
  FActiveFrame := nil;
  ReportMemoryLeaksOnShutdown := True;
  ApplyDemoChrome;
  NavigateTo(msBootstrapShowcase);
end;

procedure TGenericDemoForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FActiveFrame) then
    FreeAndNil(FActiveFrame);
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

procedure TGenericDemoForm.UpdateMenuActiveState(ASection: TMenuSection);
  procedure StyleNav(const B: TButton; const ASec: TMenuSection;
    const ACaption, AIcon: string);
  var
    V: TBootstrapVariant;
  begin
    if ASection = ASec then
      V := bsPrimary
    else
      V := bsSecondary;
    TBootstrapStyle.ApplyButton(B, V, ACaption, SIDEBAR_NAV_FONT, AIcon);
  end;
begin
  StyleNav(BtnMenuShowcase, msBootstrapShowcase, 'Bootstrap', 'speedometer2');
  StyleNav(BtnMenuConnection, msConnection, 'Connection', 'plug-fill');
  StyleNav(BtnMenuConnector, msConnector, 'Connector', 'arrow-left-right');
  StyleNav(BtnMenuDataTypes, msDataTypes, 'DataTypes', 'braces');
  StyleNav(BtnMenuPagNav, msPagNav, 'PagNav', 'table');
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
    msBootstrapShowcase:
    begin
      FActiveFrame := TFrameBootstrapShowcase.Create(Self);
      LSectionName := 'Bootstrap';
    end;
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

procedure TGenericDemoForm.MenuShowcaseClick(Sender: TObject);
begin
  NavigateTo(msBootstrapShowcase);
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
