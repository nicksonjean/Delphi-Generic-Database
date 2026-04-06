unit GenericConnectorForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  System.Rtti, FMX.Grid.Style, FMX.ComboEdit, FMX.Grid, FMX.ScrollBox,
  FMX.ListView, FMX.Edit, FMX.SearchBox, FMX.Layouts, FMX.ListBox, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.TabControl, Data.DBXOdbc, Data.DB, Data.SqlExpr,
  FMX.Objects;

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
    ComboEdit1: TComboEdit;
    Edit1: TEdit;
    procedure TabDBSQLiteClick(Sender: TObject);
    procedure TabDBFirebirdClick(Sender: TObject);
    procedure TabDBMySQLClick(Sender: TObject);
    procedure TabDBPostgreSQLClick(Sender: TObject);
    procedure TabDBSQLServerClick(Sender: TObject);
    procedure TabDBOracleClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FGenericConnectorForm: TGenericConnectorForm;

implementation

uses
  FMX.Edit.Helper,
  FMX.Objects.Helper,
  FMX.Edit.Extension,
  FMX.ComboEdit.Extension,
  &Type.&Array,
  &Type.&Array.Field,
  &Type.&Array.&String,
  &Type.&Array.Variant,
  DictionaryHelper,
  Connection,
  Connector,
  Query,
  QueryBuilder,
  Connection.Types,
  SmartPointer.Intf,
  SmartPointer;

{$R *.fmx}

{ TGenericConnectorForm }

procedure TGenericConnectorForm.Button2Click(Sender: TObject);
var
  DB: TSmartPointer<TConnection>;
  SQL: TSmartPointer<TQuery>;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DB := TSmartPointer<TConnection>.Create(TConnection.Create(TEngine.dbExpress));
  DB.Ref.Driver := SQLite;
  DB.Ref.Database :=
  {$IFDEF MSWINDOWS}
    ExtractFilePath(ParamStr(0)) + 'DB.SQLITE';
  {$ELSE}
    TPath.Combine(TPath.GetDocumentsPath, 'DB.SQLITE');
  {$ENDIF}

  if not DB.Ref.Connected then
    DB.Ref.Connected := True;

  Query := TQueryBuilder.ForConnection(DB.Ref.GetConnectionStrategy);
  SQL := TSmartPointer<TQuery>.Create(Query.View('SELECT id AS Codigo, nome AS Estado, sigla AS Sigla FROM estado ORDER BY id'));

  Connector := TConnector.Create(SQL.Ref);
  try
//  Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', 1);
//  Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', 2);
//  Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', 5);
//  Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', 7);
//  Connector.ToGrid(StringGridSQLite, 3);
//  Connector.ToGrid(GridSQLite, 6);
//  Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], 13);
//
//  Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//  Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//  Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//  Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Bahia']]));
//  Connector.ToGrid(StringGridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//  Connector.ToGrid(GridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//  Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

    Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', '{"Index":1}');
    Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
    Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', '{"Index":5}');
    Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', '{"Field":{"Estado":"Bahia"}}');
    Connector.ToGrid(StringGridSQLite, '{"Field":{"Sigla":"AP"}}');
    Connector.ToGrid(GridSQLite, '{"Field":{"Estado":"Distrito Federal"}}');
    Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');
  finally
    Connector.Free;
  end;
end;

procedure TGenericConnectorForm.Button1Click(Sender: TObject);
var
  DB: TSmartPointer<TConnection>;
  SQL: TSmartPointer<TQuery>;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DB := TSmartPointer<TConnection>.Create(TConnection.Create(TEngine.FireDAC));
  DB.Ref.Driver := SQLite;
  DB.Ref.Database :=
  {$IFDEF MSWINDOWS}
    ExtractFilePath(ParamStr(0)) + 'DB.SQLITE';
  {$ELSE}
    TPath.Combine(TPath.GetDocumentsPath, 'DB.SQLITE');
  {$ENDIF}

  if not DB.Ref.Connected then
    DB.Ref.Connected := True;

  Query := TQueryBuilder.ForConnection(DB.Ref.GetConnectionStrategy);
  SQL := TSmartPointer<TQuery>.Create(Query.View('SELECT id AS Codigo, nome AS Estado, sigla AS Sigla FROM estado ORDER BY id'));

  Connector := ISmartPointer<TConnector>(TConnector.Create(SQL.Ref));

//  Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', 1);
//  Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', 2);
//  Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', 5);
//  Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', 7);
//  Connector.ToGrid(StringGridSQLite, 3);
//  Connector.ToGrid(GridSQLite, 6);
//  Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], 13);
//
//  Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//  Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//  Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//  Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Bahia']]));
//  Connector.ToGrid(StringGridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//  Connector.ToGrid(GridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//  Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

  Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', '{"Index":1}');
  Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
  Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', '{"Index":5}');
  Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', '{"Field":{"Estado":"Bahia"}}');
  Connector.ToGrid(StringGridSQLite, '{"Field":{"Sigla":"AP"}}');
  Connector.ToGrid(GridSQLite, '{"Field":{"Estado":"Distrito Federal"}}');
  Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');
end;

procedure TGenericConnectorForm.TabDBFirebirdClick(Sender: TObject);
var
  DB : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DB := TConnection.Create(TEngine.FireDAC);
  try
    DB.Driver := FIREBIRD;
    DB.Host := 'localhost';
    DB.Port := 3050;
    DB.Database :=
    {$IFDEF MSWINDOWS}
      '/firebird/data/DB.FDB';
    {$ELSE}
      TPath.Combine(TPath.GetDocumentsPath, 'DB.FDB');
    {$ENDIF}
    DB.Username := 'sysdba';
    DB.Password := 'masterkey';

    if not DB.Connected then
      DB.Connected := True;

    Query := TQueryBuilder.ForConnection(DB.GetConnectionStrategy);
    SQL := nil;
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
//
//        Connector.ToCombo(ComboBoxFirebird, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//        Connector.ToCombo(EditFirebird, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//        Connector.ToCombo(ComboEditFirebird, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//        Connector.ToListBox(ListBoxFirebird, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Bahia']]));
//        Connector.ToGrid(StringGridFirebird, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridFirebird, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewFirebird, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxFirebird, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditFirebird, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditFirebird, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxFirebird, 'Codigo', 'Estado', '{"Field":{"Estado":"Bahia"}}');
        Connector.ToGrid(StringGridFirebird, '{"Field":{"Sigla":"AP"}}');
        Connector.ToGrid(GridFirebird, '{"Field":{"Estado":"Distrito Federal"}}');
        Connector.ToListView(ListViewFirebird, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');

      finally
        Connector.Destroy;
      end;

    finally
      if Assigned(SQL) then
        SQL.Free;
    end;

  finally
    DB.Destroy;
  end;
end;

procedure TGenericConnectorForm.TabDBMySQLClick(Sender: TObject);
var
  DB : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DB := TConnection.Create(TEngine.FireDAC);
  try
    DB.Driver := MYSQL;
    DB.Host := 'localhost';
    DB.Port := 3306;
    DB.Database := 'demodev';
    DB.Username := 'root';
    DB.Password := 'masterkey';

    if not DB.Connected then
      DB.Connected := True;

    Query := TQueryBuilder.ForConnection(DB.GetConnectionStrategy);
    SQL := nil;
    try
      SQL := Query.View('SELECT id AS Codigo, nome AS Estado, sigla AS Sigla FROM estado ORDER BY id');

      Connector := TConnector.Create(SQL);
      try
//
//        Connector.ToCombo(ComboBoxMySQL, 'Codigo', 'Estado', 1);
//        Connector.ToCombo(EditMySQL, 'Codigo', 'Estado', 2);
//        Connector.ToCombo(ComboEditMySQL, 'Codigo', 'Estado', 5);
//        Connector.ToListBox(ListBoxMySQL, 'Codigo', 'Estado', 7);
//        Connector.ToGrid(StringGridMySQL, 3);
//        Connector.ToGrid(GridMySQL, 6);
//        Connector.ToListView(ListViewMySQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], 13);
//
//        Connector.ToCombo(ComboBoxMySQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//        Connector.ToCombo(EditMySQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//        Connector.ToCombo(ComboEditMySQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//        Connector.ToListBox(ListBoxMySQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Bahia']]));
//        Connector.ToGrid(StringGridMySQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridMySQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewMySQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));
//
        Connector.ToCombo(ComboBoxMySQL, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditMySQL, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditMySQL, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxMySQL, 'Codigo', 'Estado', '{"Field":{"Estado":"Bahia"}}');
        Connector.ToGrid(StringGridMySQL, '{"Field":{"Sigla":"AP"}}');
        Connector.ToGrid(GridMySQL, '{"Field":{"Estado":"Distrito Federal"}}');
        Connector.ToListView(ListViewMySQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');

      finally
        Connector.Destroy;
      end;

    finally
      if Assigned(SQL) then
        SQL.Free;
    end;

  finally
    DB.Destroy;
  end;
end;

procedure TGenericConnectorForm.TabDBOracleClick(Sender: TObject);
var
  DB : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DB := TConnection.Create(TEngine.FireDAC);
  try
    DB.Driver := ORACLE;
    DB.Host := 'localhost';
    DB.Port := 1521;
    DB.Schema := 'freepdb1';
    DB.Username := 'hr';
    DB.Password := 'masterkey';

    if not DB.Connected then
      DB.Connected := True;

    Query := TQueryBuilder.ForConnection(DB.GetConnectionStrategy);
    SQL := nil;
    try
      SQL := Query.View('SELECT "id" AS "Codigo", "nome" AS "Estado", "sigla" AS "Sigla" FROM HR."estado" ORDER BY "id"');

      Connector := TConnector.Create(SQL);
      try
//
//        Connector.ToCombo(ComboBoxOracle, 'Codigo', 'Estado', 1);
//        Connector.ToCombo(EditOracle, 'Codigo', 'Estado', 2);
//        Connector.ToCombo(ComboEditOracle, 'Codigo', 'Estado', 5);
//        Connector.ToListBox(ListBoxOracle, 'Codigo', 'Estado', 7);
//        Connector.ToGrid(StringGridOracle, 3);
//        Connector.ToGrid(GridOracle, 6);
//        Connector.ToListView(ListViewOracle, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], 13);
//
//        Connector.ToCombo(ComboBoxOracle, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//        Connector.ToCombo(EditOracle, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//        Connector.ToCombo(ComboEditOracle, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//        Connector.ToListBox(ListBoxOracle, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Bahia']]));
//        Connector.ToGrid(StringGridOracle, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridOracle, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewOracle, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));
//
        Connector.ToCombo(ComboBoxOracle, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditOracle, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditOracle, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxOracle, 'Codigo', 'Estado', '{"Field":{"Estado":"Bahia"}}');
        Connector.ToGrid(StringGridOracle, '{"Field":{"Sigla":"AP"}}');
        Connector.ToGrid(GridOracle, '{"Field":{"Estado":"Distrito Federal"}}');
        Connector.ToListView(ListViewOracle, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');

       finally
        Connector.Destroy;
      end;

    finally
      if Assigned(SQL) then
        SQL.Free;
    end;

  finally
    DB.Destroy;
  end;
end;

procedure TGenericConnectorForm.TabDBPostgreSQLClick(Sender: TObject);
var
  DB : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DB := TConnection.Create(TEngine.FireDAC);
  try
    DB.Driver := POSTGRESQL;
    DB.Host := 'localhost';
    DB.Port := 5432;
    DB.Database := 'demodev';
    DB.Username := 'postgres';
    DB.Password := 'masterkey';

    if not DB.Connected then
      DB.Connected := True;

    Query := TQueryBuilder.ForConnection(DB.GetConnectionStrategy);
    SQL := nil;
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
//        Connector.ToListBox(ListBoxPostgreSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Bahia']]));
//        Connector.ToGrid(StringGridPostgreSQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridPostgreSQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewPostgreSQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxPostgreSQL, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditPostgreSQL, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditPostgreSQL, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxPostgreSQL, 'Codigo', 'Estado', '{"Field":{"Estado":"Bahia"}}');
        Connector.ToGrid(StringGridPostgreSQL, '{"Field":{"Sigla":"AP"}}');
        Connector.ToGrid(GridPostgreSQL, '{"Field":{"Estado":"Distrito Federal"}}');
        Connector.ToListView(ListViewPostgreSQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');

       finally
        Connector.Destroy;
      end;

    finally
      if Assigned(SQL) then
        SQL.Free;
    end;

  finally
    DB.Destroy;
  end;
end;

procedure TGenericConnectorForm.TabDBSQLServerClick(Sender: TObject);
var
  DB : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DB := TConnection.Create(TEngine.FireDAC);
  try
    DB.Driver := MSSQL;
    DB.Host := 'localhost';
    DB.Port := 1433;
    DB.Database := 'demodev';
    DB.Username := 'sa';
    DB.Password := 'Masterkey@1';

    if not DB.Connected then
      DB.Connected := True;

    Query := TQueryBuilder.ForConnection(DB.GetConnectionStrategy);
    SQL := nil;
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
//
//        Connector.ToCombo(ComboBoxMSSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//        Connector.ToCombo(EditMSSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//        Connector.ToCombo(ComboEditMSSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//        Connector.ToListBox(ListBoxMSSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Bahia']]));
//        Connector.ToGrid(StringGridMSSQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridMSSQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewMSSQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxMSSQL, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditMSSQL, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditMSSQL, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxMSSQL, 'Codigo', 'Estado', '{"Field":{"Estado":"Bahia"}}');
        Connector.ToGrid(StringGridMSSQL, '{"Field":{"Sigla":"AP"}}');
        Connector.ToGrid(GridMSSQL, '{"Field":{"Estado":"Distrito Federal"}}');
        Connector.ToListView(ListViewMSSQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');

       finally
        Connector.Destroy;
      end;

    finally
      if Assigned(SQL) then
        SQL.Free;
    end;

  finally
    DB.Destroy;
  end;
end;

procedure TGenericConnectorForm.TabDBSQLiteClick(Sender: TObject);
var
  DB : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;
begin
  DB := TConnection.Create(TEngine.FireDAC);

  try
    DB.Driver := SQLite;
    DB.Database :=
    {$IFDEF MSWINDOWS}
      ExtractFilePath(ParamStr(0)) + 'DB.SQLITE';
    {$ELSE}
      TPath.Combine(TPath.GetDocumentsPath, 'DB.SQLITE');
    {$ENDIF}

    if not DB.Connected then
      DB.Connected := True;

    Query := TQueryBuilder.ForConnection(DB.GetConnectionStrategy);
    SQL := nil;
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
//
//        Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[1]]));
//        Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Codigo', 3]]));
//        Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[5]]));
//        Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Bahia']]));
//        Connector.ToGrid(StringGridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', '{"Field":{"Estado":"Bahia"}}');
        Connector.ToGrid(StringGridSQLite, '{"Field":{"Sigla":"AP"}}');
        Connector.ToGrid(GridSQLite, '{"Field":{"Estado":"Distrito Federal"}}');
        Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], '{"Field":{"Sigla":"PA"}}');

      finally
        Connector.Destroy;
      end;

    finally
      if Assigned(SQL) then
        SQL.Free;
    end;

  finally
    DB.Destroy;
  end;
end;

end.

