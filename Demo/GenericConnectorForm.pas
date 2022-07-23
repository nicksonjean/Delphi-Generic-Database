unit GenericConnectorForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  System.Rtti, FMX.Grid.Style, FMX.ComboEdit, FMX.Grid, FMX.ScrollBox,
  FMX.ListView, FMX.Edit, FMX.SearchBox, FMX.Layouts, FMX.ListBox, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.TabControl, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.DB,
  FireDAC.Comp.Client;

type
  IQuery2 = interface
  end;

type
  IConnection2 = interface
    function GetInstance: IConnection2;
    function GetHost: String;
    procedure SetHost(const Value: String);
    property Host: String read GetHost write SetHost;
    property Instance: IConnection2 read GetInstance;
  end;

{ Classe TConnexion Herdada de IConnexion }
type
  TConnection2 = class(TInterfacedObject, IConnection2)
  strict private
    { Private declarations }
  private
    { Private declarations }
    FInstance: IConnection2;
    FHost: String;
    function GetHost: String;
    procedure SetHost(const Value: String);
    function GetInstance: IConnection2;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    property Host: String read GetHost write SetHost;
    property Instance: IConnection2 read GetInstance;
  end;

type
  TQuery2 = class(TInterfacedObject, IQuery2)
  private
    { Private declarations }
    FConexao: IConnection2;
  public
    { Public declarations }
    constructor Create(Instance: IConnection2);
    destructor Destroy; override;
  end;


type
  TGenericConnectorForm = class(TForm)
    TabControl: TTabControl;
    TabDBConnectors: TTabItem;
    TabControlSQLConnection: TTabControl;
    TabDBSQLite: TTabItem;
    GroupBoxComponentsSQLite: TGroupBox;
    GridPanelLayoutSQLite: TGridPanelLayout;
    LabelComboBoxSQLite: TLabel;
    ComboBoxSQLite: TComboBox;
    LabelListBoxSQLite: TLabel;
    LabelListViewSQLite: TLabel;
    ListBoxSQLite: TListBox;
    SearchBoxSQLite: TSearchBox;
    ListViewSQLite: TListView;
    LabelStringGridSQLite: TLabel;
    LabelGridSQLite: TLabel;
    StringGridSQLite: TStringGrid;
    GridSQLite: TGrid;
    GridPanelLayoutSQLiteAutoCompleteEdit: TGridPanelLayout;
    EditSQLite: TEdit;
    ComboEditSQLite: TComboEdit;
    GridPanelLayoutSQLiteLabels: TGridPanelLayout;
    LabelEditSQLite: TLabel;
    LabelComboEditSQLite: TLabel;
    TabDBFirebird: TTabItem;
    GroupBoxComponentsFirebird: TGroupBox;
    GridPanelLayoutFirebird: TGridPanelLayout;
    LabelComboBoxFirebird: TLabel;
    LabelListBoxFirebird: TLabel;
    LabelListViewFirebird: TLabel;
    LabelStringGridFirebird: TLabel;
    LabelGridFirebird: TLabel;
    ComboBoxFirebird: TComboBox;
    ListBoxFirebird: TListBox;
    SearchBoxFirebird: TSearchBox;
    ListViewFirebird: TListView;
    StringGridFirebird: TStringGrid;
    GridFirebird: TGrid;
    GridPanelLayoutFirebirdLabels: TGridPanelLayout;
    LabelEditFirebird: TLabel;
    LabelComboEditFirebird: TLabel;
    GridPanelLayoutFirebirdAutoCompleteEdit: TGridPanelLayout;
    EditFirebird: TEdit;
    ComboEditFirebird: TComboEdit;
    TabDBMySQL: TTabItem;
    GroupBoxComponentsMySQL: TGroupBox;
    GridPanelLayoutMySQL: TGridPanelLayout;
    LabelComboBoxMySQL: TLabel;
    LabelListBoxMySQL: TLabel;
    LabelListViewMySQL: TLabel;
    LabelStringGridMySQL: TLabel;
    LabelGridMySQL: TLabel;
    ComboBoxMySQL: TComboBox;
    ListBoxMySQL: TListBox;
    SearchBoxMySQL: TSearchBox;
    ListViewMySQL: TListView;
    StringGridMySQL: TStringGrid;
    GridMySQL: TGrid;
    GridPanelLayoutMySQLLabels: TGridPanelLayout;
    LabelEditMySQL: TLabel;
    LabelComboEditMySQL: TLabel;
    GridPanelLayoutMySQLAutoCompleteEdit: TGridPanelLayout;
    ComboEditMySQL: TComboEdit;
    EditMySQL: TEdit;
    TabDBPostgreSQL: TTabItem;
    GroupBoxComponentsPostgreSQL: TGroupBox;
    GridPanelLayoutPostgreSQL: TGridPanelLayout;
    LabelComboBoxPostgreSQL: TLabel;
    LabelListBoxPostgreSQL: TLabel;
    LabelListViewPostgreSQL: TLabel;
    LabelStringGridPostgreSQL: TLabel;
    LabelGridPostgreSQL: TLabel;
    ComboBoxPostgreSQL: TComboBox;
    ListBoxPostgreSQL: TListBox;
    SearchBoxPostgreSQL: TSearchBox;
    ListViewPostgreSQL: TListView;
    StringGridPostgreSQL: TStringGrid;
    GridPostgreSQL: TGrid;
    GridPanelLayoutPostgreSQLLabels: TGridPanelLayout;
    LabelEditPostgreSQL: TLabel;
    LabelComboEditPostgreSQL: TLabel;
    GridPanelLayoutPostgreSQLAutoCompleteEdit: TGridPanelLayout;
    ComboEditPostgreSQL: TComboEdit;
    EditPostgreSQL: TEdit;
    TabDBSQLServer: TTabItem;
    GroupBoxComponentsMSSQL: TGroupBox;
    GridPanelLayoutMSSQL: TGridPanelLayout;
    LabelComboBoxMSSQL: TLabel;
    ComboBoxMSSQL: TComboBox;
    LabelListBoxMSSQL: TLabel;
    LabelListViewMSSQL: TLabel;
    ListBoxMSSQL: TListBox;
    SearchBoxMSSQL: TSearchBox;
    ListViewMSSQL: TListView;
    LabelStringGridMSSQL: TLabel;
    LabelGridMSSQL: TLabel;
    StringGridMSSQL: TStringGrid;
    GridMSSQL: TGrid;
    GridPanelLayoutMSSQLAutoCompleteEdit: TGridPanelLayout;
    EditMSSQL: TEdit;
    ComboEditMSSQL: TComboEdit;
    GridPanelLayoutMSSQLLabels: TGridPanelLayout;
    LabelEditMSSQL: TLabel;
    LabelComboEditMSSQL: TLabel;
    TabDBOracle: TTabItem;
    GroupBoxComponentsOracle: TGroupBox;
    GridPanelLayoutOracle: TGridPanelLayout;
    LabelComboBoxOracle: TLabel;
    ComboBoxOracle: TComboBox;
    LabelListBoxOracle: TLabel;
    LabelListViewOracle: TLabel;
    ListBoxOracle: TListBox;
    SearchBoxOracle: TSearchBox;
    ListViewOracle: TListView;
    LabelStringGridOracle: TLabel;
    LabelGridOracle: TLabel;
    StringGridOracle: TStringGrid;
    GridOracle: TGrid;
    GridPanelLayoutOracleAutoCompleteEdit: TGridPanelLayout;
    ComboEditOracle: TComboEdit;
    EditOracle: TEdit;
    GridPanelLayoutOracleLabels: TGridPanelLayout;
    LabelEditOracle: TLabel;
    LabelComboEditOracle: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure TabDBSQLiteClick(Sender: TObject);
    procedure TabDBFirebirdClick(Sender: TObject);
    procedure TabDBMySQLClick(Sender: TObject);
    procedure TabDBPostgreSQLClick(Sender: TObject);
    procedure TabDBSQLServerClick(Sender: TObject);
    procedure TabDBOracleClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure PresentationNameChoosing(Sender: TObject; var PresenterName: string);
  end;

var
  FGenericConnectorForm: TGenericConnectorForm;

implementation

uses
  FMX.Edit.Helper,
  FMX.Objects.Helper,
  FMX.Edit.Extension,
  ArrayField,
  ArrayString,
  ArrayVariant,
  DictionaryHelper,
  Connection,
  Connector,
  Query,
  QueryHelper,
  QueryBuilder,
  IArray,
  ISmartPointer,
  TSmartPointer;

{$R *.fmx}

constructor TConnection2.Create;
begin
  inherited Create;
end;

destructor TConnection2.Destroy;
begin
  inherited;
end;

function TConnection2.GetHost: String;
begin
  Result := Self.FHost;
end;

procedure TConnection2.SetHost(const Value: String);
begin
  Self.FHost := Value;
end;

function TConnection2.GetInstance: IConnection2;
begin
  if not Assigned(Self.FInstance) then
    Self.FInstance := TConnection2.Create();
  Result := Self.FInstance;
end;

constructor TQuery2.Create(Instance: IConnection2);
begin
  FConexao := Instance;
  showmessage('asdas: ' + FConexao.Host);
end;

destructor TQuery2.Destroy;
begin
  inherited;
end;

{ TGenericConnectorForm }

procedure TGenericConnectorForm.Button3Click(Sender: TObject);
var
  DBSQLite: IConnection2;
  SQL: IQuery2;
begin
  DBSQLite := TConnection2.Create;
  DBSQLite.Host := 'teste';

  SQL := TQuery2.Create(DBSQLite);
end;

procedure TGenericConnectorForm.Button2Click(Sender: TObject);
//var
//  DBSQLite: IConnection;
//  SQL: TQuery;
//  Query: TQueryBuilder;
//  Connector: TConnector;
begin
//  DBSQLite := TConnection.Create;
//  //DBSQLite := TConnectionClass.GetInstance();
//  try
//    DBSQLite.Driver := SQLITE;
//    DBSQLite.Database :=
//    {$IFDEF MSWINDOWS}
//      ExtractFilePath(ParamStr(0)) + 'DB.SQLITE';
//    {$ELSE}
//      TPath.Combine(TPath.GetDocumentsPath, 'DB.SQLITE');
//    {$ENDIF}
//
//    if not DBSQLite.Connected then
//      DBSQLite.Connect := True;
//
//    SQL := TQuery.Create;
//    try
//      SQL := Query.View('SELECT id AS Codigo, nome AS Estado, sigla AS Sigla FROM estado ORDER BY id');

//      Connector := TConnector.Create(SQL);
//      try
//
//        Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', 1);
//        Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', 2);
//        Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', 5);
//        Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', 7);
//        Connector.ToGrid(StringGridSQLite, 3);
//        Connector.ToGrid(GridSQLite, 6);
//        Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], 13);

//        Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//        Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//        Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//        Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Espírito Santo']]));
//        Connector.ToGrid(StringGridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

//        Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', '{"Index":1}');
//        Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
//        Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', '{"Index":5}');
//        Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', '{"Field":{"Estado":"Espírito Santo"}}');
//        Connector.ToGrid(StringGridSQLite, '{"Field":{"Sigla":"AP"}}');
//        Connector.ToGrid(GridSQLite, '{"Field":{"Estado":"Distrito Federal"}}');
//        Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');

//      finally
//        Connector.Destroy;
//      end;

//    finally
//      SQL.Destroy;
//    end;
//
//  finally
//    DBSQLite.Connection2.Destroy;
//  end;
end;

procedure TGenericConnectorForm.Button1Click(Sender: TObject);
var
  DBSQLite: TSmartPointer<TConnection>;
  SQL: TSmartPointer<TQuery>;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DBSQLite.Ref.Driver := SQLITE;
  DBSQLite.Ref.Database :=
  {$IFDEF MSWINDOWS}
    ExtractFilePath(ParamStr(0)) + 'DB.SQLITE';
  {$ELSE}
    TPath.Combine(TPath.GetDocumentsPath, 'DB.SQLITE');
  {$ENDIF}

  if not DBSQLite.Ref.GetInstance.Connection.Connected then
    DBSQLite.Ref.GetInstance.Connection.Connected := True;

  SQL.Ref := Query.View('SELECT id AS Codigo, nome AS Estado, sigla AS Sigla FROM estado ORDER BY id');

  Connector := ISmartPointer<TConnector>(TConnector.Create(SQL.Ref));

//  Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', 1);
//  Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', 2);
//  Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', 5);
//  Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', 7);
//  Connector.ToGrid(StringGridSQLite, 3);
//  Connector.ToGrid(GridSQLite, 6);
//  Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], 13);

//  Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//  Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//  Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//  Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp??rito Santo']]));
//  Connector.ToGrid(StringGridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//  Connector.ToGrid(GridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//  Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

  Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', '{"Index":1}');
  Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
  Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', '{"Index":5}');
  Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp??rito Santo"}}');
  Connector.ToGrid(StringGridSQLite, '{"Field":{"Sigla":"AP"}}');
  Connector.ToGrid(GridSQLite, '{"Field":{"Estado":"Distrito Federal"}}');
  Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');
end;

procedure TGenericConnectorForm.FormCreate(Sender: TObject);
begin
//  ReportMemoryLeaksOnShutdown := True;
end;

procedure TGenericConnectorForm.PresentationNameChoosing(Sender: TObject; var PresenterName: string);
begin
  inherited;
  PresenterName := 'SuggestEdit-Style';
end;

procedure TGenericConnectorForm.TabDBFirebirdClick(Sender: TObject);
var
  DBFirebird : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DBFirebird := TConnection.Create;
  //DBFirebird := TConnectionClass.GetInstance();
  try
    DBFirebird.Driver := FIREBIRD;
    DBFirebird.Host := '127.0.0.1';
    DBFirebird.Port := 3050;
    DBFirebird.Database :=
    {$IFDEF MSWINDOWS}
      ExtractFilePath(ParamStr(0)) + 'DB.FDB';
    {$ELSE}
      TPath.Combine(TPath.GetDocumentsPath, 'DB.FDB');
    {$ENDIF}
    DBFirebird.Username := 'SYSDBA';
    DBFirebird.Password := 'masterkey';

    if not DBFirebird.GetInstance.Connection.Connected then
      DBFirebird.GetInstance.Connection.Connected := True;

    SQL := TQuery.Create;
    try
      SQL := Query.View('SELECT "id" AS "Codigo", "nome" AS "Estado", "sigla" AS "Sigla" FROM "estado" ORDER BY "id"');

      Connector := TConnector.Create(SQL);
      try

//        Connector.ToCombo(ComboBoxFirebird, 'Codigo', 'Estado', 1);
//        Connector.ToCombo(EditFirebird, 'Codigo', 'Estado', 2);
//        Connector.ToCombo(ComboEditFirebird, 'Codigo', 'Estado', 5);
//        Connector.ToListBox(ListBoxFirebird, 'Codigo', 'Estado', 7);
//        Connector.ToGrid(StringGridFirebird, 3);
//        Connector.ToGrid(GridFirebird, 6);
//        Connector.ToListView(ListViewFirebird, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], 13);

//        Connector.ToCombo(ComboBoxFirebird, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//        Connector.ToCombo(EditFirebird, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//        Connector.ToCombo(ComboEditFirebird, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//        Connector.ToListBox(ListBoxFirebird, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp??rito Santo']]));
//        Connector.ToGrid(StringGridFirebird, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridFirebird, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewFirebird, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxFirebird, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditFirebird, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditFirebird, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxFirebird, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp??rito Santo"}}');
        Connector.ToGrid(StringGridFirebird, '{"Field":{"Sigla":"AP"}}');
        Connector.ToGrid(GridFirebird, '{"Field":{"Estado":"Distrito Federal"}}');
        Connector.ToListView(ListViewFirebird, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');


      finally
        Connector.Destroy;
      end;

    finally
      SQL.Destroy;
    end;

  finally
    DBFirebird.Destroy;
  end;
end;

procedure TGenericConnectorForm.TabDBMySQLClick(Sender: TObject);
var
  DBMySQL : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DBMySQL := TConnection.Create;
  //DBMySQL := TConnectionClass.GetInstance();
  try
    DBMySQL.Driver := MYSQL;
    DBMySQL.Host := '127.0.0.1';
    DBMySQL.Port := 3306;
    DBMySQL.Database := 'demodev';
    DBMySQL.Username := 'root';
    DBMySQL.Password := '';

    if not DBMySQL.GetInstance.Connection.Connected then
      DBMySQL.GetInstance.Connection.Connected := True;

    SQL := TQuery.Create;
    try
      SQL := Query.View('SELECT id AS Codigo, nome AS Estado, sigla AS Sigla FROM estado ORDER BY id');

      Connector := TConnector.Create(SQL);
      try

//        Connector.ToCombo(ComboBoxMySQL, 'Codigo', 'Estado', 1);
//        Connector.ToCombo(EditMySQL, 'Codigo', 'Estado', 2);
//        Connector.ToCombo(ComboEditMySQL, 'Codigo', 'Estado', 5);
//        Connector.ToListBox(ListBoxMySQL, 'Codigo', 'Estado', 7);
//        Connector.ToGrid(StringGridMySQL, 3);
//        Connector.ToGrid(GridMySQL, 6);
//        Connector.ToListView(ListViewMySQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], 13);

//        Connector.ToCombo(ComboBoxMySQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//        Connector.ToCombo(EditMySQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//        Connector.ToCombo(ComboEditMySQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//        Connector.ToListBox(ListBoxMySQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp??rito Santo']]));
//        Connector.ToGrid(StringGridMySQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridMySQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewMySQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxMySQL, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditMySQL, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditMySQL, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxMySQL, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp??rito Santo"}}');
        Connector.ToGrid(StringGridMySQL, '{"Field":{"Sigla":"AP"}}');
        Connector.ToGrid(GridMySQL, '{"Field":{"Estado":"Distrito Federal"}}');
        Connector.ToListView(ListViewMySQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');

      finally
        Connector.Destroy;
      end;

    finally
      SQL.Destroy;
    end;

  finally
    DBMySQL.Destroy;
  end;
end;

procedure TGenericConnectorForm.TabDBOracleClick(Sender: TObject);
var
  DBOracle : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DBOracle := TConnection.Create;
  //DBOracle := TConnectionClass.GetInstance();
  try
    DBOracle.Driver := ORACLE;
    DBOracle.Host := 'localhost';
    DBOracle.Port := 1521;
    DBOracle.Schema := 'XE';
    DBOracle.Username := 'hr';
    DBOracle.Password := 'masterkey';

    if not DBOracle.GetInstance.Connection.Connected then
      DBOracle.GetInstance.Connection.Connected := True;

    SQL := TQuery.Create;
    try
      SQL := Query.View('SELECT "id" AS "Codigo", "nome" AS "Estado", "sigla" AS "Sigla" FROM HR."estado" ORDER BY "id"');

      Connector := TConnector.Create(SQL);
      try

//        Connector.ToCombo(ComboBoxOracle, 'Codigo', 'Estado', 1);
//        Connector.ToCombo(EditOracle, 'Codigo', 'Estado', 2);
//        Connector.ToCombo(ComboEditOracle, 'Codigo', 'Estado', 5);
//        Connector.ToListBox(ListBoxOracle, 'Codigo', 'Estado', 7);
//        Connector.ToGrid(StringGridOracle, 3);
//        Connector.ToGrid(GridOracle, 6);
//        Connector.ToListView(ListViewOracle, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], 13);

//        Connector.ToCombo(ComboBoxOracle, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//        Connector.ToCombo(EditOracle, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//        Connector.ToCombo(ComboEditOracle, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//        Connector.ToListBox(ListBoxOracle, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp??rito Santo']]));
//        Connector.ToGrid(StringGridOracle, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridOracle, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewOracle, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxOracle, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditOracle, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditOracle, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxOracle, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp??rito Santo"}}');
        Connector.ToGrid(StringGridOracle, '{"Field":{"Sigla":"AP"}}');
        Connector.ToGrid(GridOracle, '{"Field":{"Estado":"Distrito Federal"}}');
        Connector.ToListView(ListViewOracle, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');

       finally
        Connector.Destroy;
      end;

    finally
      SQL.Destroy;
    end;

  finally
    DBOracle.Destroy;
  end;
end;

procedure TGenericConnectorForm.TabDBPostgreSQLClick(Sender: TObject);
var
  DBPostgreSQL : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DBPostgreSQL := TConnection.Create;
  //DBPostgreSQL := TConnectionClass.GetInstance();
  try
    DBPostgreSQL.Driver := POSTGRESQL;
    DBPostgreSQL.Host := '127.0.0.1';
    DBPostgreSQL.Port := 5432;
    DBPostgreSQL.Database := 'postgres';
    DBPostgreSQL.Schema := 'public';
    DBPostgreSQL.Username := 'postgres';
    DBPostgreSQL.Password := 'masterkey';

    if not DBPostgreSQL.GetInstance.Connection.Connected then
      DBPostgreSQL.GetInstance.Connection.Connected := True;

    SQL := TQuery.Create;
    try
      SQL := Query.View('SELECT "id" AS "Codigo", "nome" AS "Estado", "sigla" AS "Sigla" FROM "estado" ORDER BY "id"');

      Connector := TConnector.Create(SQL);
      try

//        Connector.ToCombo(ComboBoxPostgreSQL, 'Codigo', 'Estado', 1);
//        Connector.ToCombo(EditPostgreSQL, 'Codigo', 'Estado', 2);
//        Connector.ToCombo(ComboEditPostgreSQL, 'Codigo', 'Estado', 5);
//        Connector.ToListBox(ListBoxPostgreSQL, 'Codigo', 'Estado', 7);
//        Connector.ToGrid(StringGridPostgreSQL, 3);
//        Connector.ToGrid(GridPostgreSQL, 6);
//        Connector.ToListView(ListViewPostgreSQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], 13);

//        Connector.ToCombo(ComboBoxPostgreSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//        Connector.ToCombo(EditPostgreSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//        Connector.ToCombo(ComboEditPostgreSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//        Connector.ToListBox(ListBoxPostgreSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp??rito Santo']]));
//        Connector.ToGrid(StringGridPostgreSQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridPostgreSQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewPostgreSQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxPostgreSQL, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditPostgreSQL, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditPostgreSQL, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxPostgreSQL, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp??rito Santo"}}');
        Connector.ToGrid(StringGridPostgreSQL, '{"Field":{"Sigla":"AP"}}');
        Connector.ToGrid(GridPostgreSQL, '{"Field":{"Estado":"Distrito Federal"}}');
        Connector.ToListView(ListViewPostgreSQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');

       finally
        Connector.Destroy;
      end;

    finally
      SQL.Destroy;
    end;

  finally
    DBPostgreSQL.Destroy;
  end;
end;

procedure TGenericConnectorForm.TabDBSQLServerClick(Sender: TObject);
var
  DBSQServer : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DBSQServer := TConnection.Create;
  //DBSQLite := TConnectionClass.GetInstance();
  try
    DBSQServer.Driver := MSSQL;
    DBSQServer.Host := '127.0.0.1';
    DBSQServer.Port := 1433;
    DBSQServer.Database := 'demodev';
    DBSQServer.Username := 'sa';
    DBSQServer.Password := 'masterkey';

    if not DBSQServer.GetInstance.Connection.Connected then
      DBSQServer.GetInstance.Connection.Connected := True;

    SQL := TQuery.Create;
    try
      SQL := Query.View('SELECT "id" AS "Codigo", "nome" AS "Estado", "sigla" AS "Sigla" FROM "estado" ORDER BY "id"');

      Connector := TConnector.Create(SQL);
      try

//        Connector.ToCombo(ComboBoxMSSQL, 'Codigo', 'Estado', 1);
//        Connector.ToCombo(EditMSSQL, 'Codigo', 'Estado', 2);
//        Connector.ToCombo(ComboEditMSSQL, 'Codigo', 'Estado', 5);
//        Connector.ToListBox(ListBoxMSSQL, 'Codigo', 'Estado', 7);
//        Connector.ToGrid(StringGridMSSQL, 3);
//        Connector.ToGrid(GridMSSQL, 6);
//        Connector.ToListView(ListViewMSSQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], 13);

//        Connector.ToCombo(ComboBoxMSSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//        Connector.ToCombo(EditMSSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//        Connector.ToCombo(ComboEditMSSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//        Connector.ToListBox(ListBoxMSSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp??rito Santo']]));
//        Connector.ToGrid(StringGridMSSQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridMSSQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewMSSQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxMSSQL, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditMSSQL, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditMSSQL, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxMSSQL, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp??rito Santo"}}');
        Connector.ToGrid(StringGridMSSQL, '{"Field":{"Sigla":"AP"}}');
        Connector.ToGrid(GridMSSQL, '{"Field":{"Estado":"Distrito Federal"}}');
        Connector.ToListView(ListViewMSSQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');

       finally
        Connector.Destroy;
      end;

    finally
      SQL.Destroy;
    end;

  finally
    DBSQServer.Destroy;
  end;
end;

procedure TGenericConnectorForm.TabDBSQLiteClick(Sender: TObject);
var
  DBSQLite : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DBSQLite := TConnection.Create;
  //DBSQLite := TConnectionClass.GetInstance();

  try
    DBSQLite.Driver := SQLITE;
    DBSQLite.Database :=
    {$IFDEF MSWINDOWS}
      ExtractFilePath(ParamStr(0)) + 'DB.SQLITE';
    {$ELSE}
      TPath.Combine(TPath.GetDocumentsPath, 'DB.SQLITE');
    {$ENDIF}

    if not DBSQLite.GetInstance.Connection.Connected then
      DBSQLite.GetInstance.Connection.Connected := True;

    SQL := TQuery.Create;
    try
      SQL := Query.View('SELECT id AS Codigo, nome AS Estado, sigla AS Sigla FROM estado ORDER BY id');

      Connector := TConnector.Create(SQL);
      try

//        Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', 1);
//        Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', 2);
//        Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', 5);
//        Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', 7);
//        Connector.ToGrid(StringGridSQLite, 3);
//        Connector.ToGrid(GridSQLite, 6);
//        Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], 13);

//        Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//        Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//        Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//        Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp??rito Santo']]));
//        Connector.ToGrid(StringGridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp??rito Santo"}}');
        Connector.ToGrid(StringGridSQLite, '{"Field":{"Sigla":"AP"}}');
        Connector.ToGrid(GridSQLite, '{"Field":{"Estado":"Distrito Federal"}}');
        Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');

      finally
        Connector.Destroy;
      end;

    finally
      SQL.Destroy;
    end;

  finally
    DBSQLite.Destroy;
  end;
end;

end.
