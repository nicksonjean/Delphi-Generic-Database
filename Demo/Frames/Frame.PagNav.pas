unit Frame.PagNav;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IOUtils,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.Layouts,
  FMX.ScrollBox,
  FMX.ListBox,
  FMX.Edit,
  Data.Bind.Controls,
  Fmx.Bind.Navigator,
  System.Rtti,
  FMX.Grid.Style,
  FMX.Grid,
  Data.DB,
  Connection.Types;

type
  TFramePagNav = class(TFrame)
    RectPagNavBg: TRectangle;
    RectPagNavHeader: TRectangle;
    LblPagNavTitle: TLabel;
    LayPagNavConnectBar: TLayout;
    LblPNEngine: TLabel;
    ComboPNEngine: TComboBox;
    LblPNDriver: TLabel;
    ComboPNDriver: TComboBox;
    EditPNDatabase: TEdit;
    BtnPNConnect: TButton;
    GridPanelPagNav: TGridPanelLayout;
    GroupBoxOriginal: TGroupBox;
    GridPanelOriginal: TGridPanelLayout;
    EditPNSearch1: TEdit;
    SearchEditButton1: TSearchEditButton;
    Grid1: TGrid;
    BindNavigator1: TBindNavigator;
    GroupBoxMinimal: TGroupBox;
    GridPanelMinimal: TGridPanelLayout;
    EditPNSearch2: TEdit;
    SearchEditButton2: TSearchEditButton;
    Grid2: TGrid;
    PagPanelLayout: TGridPanelLayout;
    PagButtonFirst: TCornerButton;
    PagButtonPrior: TCornerButton;
    PagButtonNext: TCornerButton;
    PagButtonLast: TCornerButton;
    GroupBoxFull: TGroupBox;
    GridPanelFull: TGridPanelLayout;
    EditPNSearch3: TEdit;
    SearchEditButton3: TSearchEditButton;
    Grid3: TGrid;
    NavPanelLayout: TGridPanelLayout;
    NavButtonFirst: TCornerButton;
    NavButtonPrior: TCornerButton;
    NavButtonNext: TCornerButton;
    NavButtonLast: TCornerButton;
    NavButtonInsert: TCornerButton;
    NavButtonDelete: TCornerButton;
    NavButtonEdit: TCornerButton;
    NavButtonPost: TCornerButton;
    NavButtonCancel: TCornerButton;
    NavButtonRefresh: TCornerButton;
    procedure BtnPNConnectClick(Sender: TObject);
    procedure PagButtonFirstClick(Sender: TObject);
    procedure PagButtonPriorClick(Sender: TObject);
    procedure PagButtonNextClick(Sender: TObject);
    procedure PagButtonLastClick(Sender: TObject);
    procedure NavButtonFirstClick(Sender: TObject);
    procedure NavButtonPriorClick(Sender: TObject);
    procedure NavButtonNextClick(Sender: TObject);
    procedure NavButtonLastClick(Sender: TObject);
    procedure NavButtonInsertClick(Sender: TObject);
    procedure NavButtonDeleteClick(Sender: TObject);
    procedure NavButtonEditClick(Sender: TObject);
    procedure NavButtonPostClick(Sender: TObject);
    procedure NavButtonCancelClick(Sender: TObject);
    procedure NavButtonRefreshClick(Sender: TObject);
  private
    FCurrentPage: Integer;
    FPageSize: Integer;
    FTotalRecords: Integer;
    FActiveDataSet: TDataSet;
    procedure LoadData;
    procedure UpdateNavigationState;
    function GetEngine: TEngine;
    function GetDriver: TDriver;
    procedure ApplyBootstrapChrome;
  protected
    procedure SetParent(const Value: TFmxObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

uses
  BootstrapStyle,
  FMX.Grid.Helper,
  FMX.StringGrid.Helper,
  Connection,
  Connector,
  Query,
  QueryBuilder,
  SmartPointer.Intf,
  SmartPointer;

{$R *.fmx}

{ TFramePagNav }

constructor TFramePagNav.Create(AOwner: TComponent);
begin
  inherited;
  FCurrentPage  := 0;
  FPageSize     := 50;
  FTotalRecords := 0;
  FActiveDataSet := nil;
  ReportMemoryLeaksOnShutdown := True;

  EditPNDatabase.Text :=
    {$IFDEF MSWINDOWS}
    ExtractFilePath(ParamStr(0)) + 'DB.SQLITE';
    {$ELSE}
    TPath.Combine(TPath.GetDocumentsPath, 'DB.SQLITE');
    {$ENDIF}
end;

procedure TFramePagNav.ApplyBootstrapChrome;
begin
  TBootstrapStyle.ApplyButton(BtnPNConnect, bsPrimary, 'Connect && Load', 13, 'plug-fill');
  TBootstrapStyle.ApplyCornerButtonGlyph(PagButtonFirst, bsPrimary, 'skip-start', 15);
  TBootstrapStyle.ApplyCornerButtonGlyph(PagButtonPrior, bsPrimary, 'chevron-left', 15);
  TBootstrapStyle.ApplyCornerButtonGlyph(PagButtonNext, bsPrimary, 'chevron-right', 15);
  TBootstrapStyle.ApplyCornerButtonGlyph(PagButtonLast, bsPrimary, 'skip-end', 15);
  TBootstrapStyle.ApplyCornerButtonGlyph(NavButtonFirst, bsPrimary, 'skip-start', 13);
  TBootstrapStyle.ApplyCornerButtonGlyph(NavButtonPrior, bsPrimary, 'chevron-left', 13);
  TBootstrapStyle.ApplyCornerButtonGlyph(NavButtonNext, bsPrimary, 'chevron-right', 13);
  TBootstrapStyle.ApplyCornerButtonGlyph(NavButtonLast, bsPrimary, 'skip-end', 13);
  TBootstrapStyle.ApplyCornerButtonGlyph(NavButtonInsert, bsPrimary, 'plus-lg', 13);
  TBootstrapStyle.ApplyCornerButtonGlyph(NavButtonDelete, bsPrimary, 'trash', 13);
  TBootstrapStyle.ApplyCornerButtonGlyph(NavButtonEdit, bsPrimary, 'pencil', 13);
  TBootstrapStyle.ApplyCornerButtonGlyph(NavButtonPost, bsPrimary, 'check-lg', 13);
  TBootstrapStyle.ApplyCornerButtonGlyph(NavButtonCancel, bsPrimary, 'x-lg', 13);
  TBootstrapStyle.ApplyCornerButtonGlyph(NavButtonRefresh, bsPrimary, 'arrow-clockwise', 13);
end;

procedure TFramePagNav.SetParent(const Value: TFmxObject);
begin
  inherited SetParent(Value);
  if Value <> nil then
    ApplyBootstrapChrome;
end;

destructor TFramePagNav.Destroy;
begin
  if Assigned(FActiveDataSet) then
    FreeAndNil(FActiveDataSet);
  inherited;
end;

function TFramePagNav.GetEngine: TEngine;
begin
  case ComboPNEngine.ItemIndex of
    0: Result := TEngine.FireDAC;
    1: Result := TEngine.dbExpress;
    2: Result := TEngine.ZeOS;
    3: Result := TEngine.UniDAC;
  else
    Result := TEngine.FireDAC;
  end;
end;

function TFramePagNav.GetDriver: TDriver;
begin
  case ComboPNDriver.ItemIndex of
    0: Result := TDriver.SQLite;
    1: Result := TDriver.MySQL;
    2: Result := TDriver.Firebird;
    3: Result := TDriver.PostgreSQL;
    4: Result := TDriver.MSSQL;
    5: Result := TDriver.Oracle;
  else
    Result := TDriver.SQLite;
  end;
end;

procedure TFramePagNav.LoadData;
var
  DB: TSmartPointer<TConnection>;
  SQL: TSmartPointer<TQuery>;
  QBuilder: TQueryBuilder;
  LConnector: TConnector;
begin
  try
    DB := TSmartPointer<TConnection>.Create(TConnection.Create(GetEngine));
    DB.Ref.Driver   := GetDriver;
    DB.Ref.Database := Trim(EditPNDatabase.Text);

    if not DB.Ref.Connected then
      DB.Ref.Connected := True;

    QBuilder := TQueryBuilder.ForConnection(DB.Ref.GetConnectionStrategy);
    SQL := TSmartPointer<TQuery>.Create(
      QBuilder.View('SELECT id AS Codigo, nome AS Estado, sigla AS Sigla FROM estado ORDER BY id'));

    FTotalRecords := SQL.Ref.RecordCount;
    FCurrentPage  := 0;

    // Bind to all three grids via Connector
    LConnector := TConnector.Create(SQL.Ref);
    try
      LConnector.ToGrid(Grid1, '');
      LConnector.ToGrid(Grid2, '');
      LConnector.ToGrid(Grid3, '');
    finally
      LConnector.Free;
    end;

    UpdateNavigationState;
  except
    on E: Exception do
      ShowMessage('PagNav error: ' + E.Message);
  end;
end;

procedure TFramePagNav.UpdateNavigationState;
var
  LAtFirst, LAtLast: Boolean;
begin
  LAtFirst := (FCurrentPage = 0);
  LAtLast  := (FTotalRecords = 0) or
              ((FCurrentPage + 1) * FPageSize >= FTotalRecords);

  // Minimal navigator
  PagButtonFirst.Enabled := not LAtFirst;
  PagButtonPrior.Enabled := not LAtFirst;
  PagButtonNext.Enabled  := not LAtLast;
  PagButtonLast.Enabled  := not LAtLast;

  // Full navigator
  NavButtonFirst.Enabled := not LAtFirst;
  NavButtonPrior.Enabled := not LAtFirst;
  NavButtonNext.Enabled  := not LAtLast;
  NavButtonLast.Enabled  := not LAtLast;
end;

procedure TFramePagNav.BtnPNConnectClick(Sender: TObject);
begin
  LoadData;
end;

// Minimal navigator
procedure TFramePagNav.PagButtonFirstClick(Sender: TObject);
begin
  FCurrentPage := 0;
  UpdateNavigationState;
end;

procedure TFramePagNav.PagButtonPriorClick(Sender: TObject);
begin
  if FCurrentPage > 0 then
    Dec(FCurrentPage);
  UpdateNavigationState;
end;

procedure TFramePagNav.PagButtonNextClick(Sender: TObject);
begin
  if (FCurrentPage + 1) * FPageSize < FTotalRecords then
    Inc(FCurrentPage);
  UpdateNavigationState;
end;

procedure TFramePagNav.PagButtonLastClick(Sender: TObject);
begin
  if FTotalRecords > 0 then
    FCurrentPage := (FTotalRecords - 1) div FPageSize;
  UpdateNavigationState;
end;

// Full navigator
procedure TFramePagNav.NavButtonFirstClick(Sender: TObject);
begin
  FCurrentPage := 0;
  UpdateNavigationState;
end;

procedure TFramePagNav.NavButtonPriorClick(Sender: TObject);
begin
  if FCurrentPage > 0 then
    Dec(FCurrentPage);
  UpdateNavigationState;
end;

procedure TFramePagNav.NavButtonNextClick(Sender: TObject);
begin
  if (FCurrentPage + 1) * FPageSize < FTotalRecords then
    Inc(FCurrentPage);
  UpdateNavigationState;
end;

procedure TFramePagNav.NavButtonLastClick(Sender: TObject);
begin
  if FTotalRecords > 0 then
    FCurrentPage := (FTotalRecords - 1) div FPageSize;
  UpdateNavigationState;
end;

procedure TFramePagNav.NavButtonInsertClick(Sender: TObject);
begin
  // Future: Insert row
  ShowMessage('Insert: to be implemented');
end;

procedure TFramePagNav.NavButtonDeleteClick(Sender: TObject);
begin
  // Future: Delete row
  ShowMessage('Delete: to be implemented');
end;

procedure TFramePagNav.NavButtonEditClick(Sender: TObject);
begin
  // Future: Edit row
  ShowMessage('Edit: to be implemented');
end;

procedure TFramePagNav.NavButtonPostClick(Sender: TObject);
begin
  // Future: Post changes
  ShowMessage('Post: to be implemented');
end;

procedure TFramePagNav.NavButtonCancelClick(Sender: TObject);
begin
  // Future: Cancel edit
  ShowMessage('Cancel: to be implemented');
end;

procedure TFramePagNav.NavButtonRefreshClick(Sender: TObject);
begin
  LoadData;
end;

end.
