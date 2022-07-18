unit GenericDatabaseForm;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Rtti,
  System.TypInfo,
  System.StrUtils,
  System.DateUtils,
  System.Generics.Collections,
  System.JSON,
  FMX.Styles.Objects,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.TabControl,
  FMX.Grid.Style,
  FMX.ScrollBox,
  FMX.Grid,
  FMX.Bind.DBEngExt,
  FMX.Bind.Grid,
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.ComboEdit,
  FMX.Layouts,
  FMX.Edit,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.Objects,
  FMX.SearchBox,
  FMX.Memo,
  FMX.Pickers,
  Data.Bind.Controls,
  Fmx.Bind.Navigator,
  FMX.Memo.Types;

const
  Methods: Array of String = ['Fetch','Copy','Clone','ToList','ToTags','ToXML','ToJSON','ToYAML'];

type
  TGenericDatabaseForm  = class(TForm)
    TabControl: TTabControl;
    TabSQLConnection: TTabItem;
    TabDataTypes: TTabItem;
    TabQueryBuilder: TTabItem;
    TabControlDataTypes: TTabControl;
    TabStrings: TTabItem;
    TabFloats: TTabItem;
    TabDateTime: TTabItem;
    TabArrays: TTabItem;
    GroupBoxQueryBuilderArrays: TGroupBox;
    GridPanelLayoutQueryBuilderArray: TGridPanelLayout;
    LabelQueryBuilderArrayString: TLabel;
    LabelQueryBuilderArrayVariant: TLabel;
    LabelQueryBuilderArrayField: TLabel;
    ComboBoxQueryBuilderArrayString: TComboBox;
    ComboBoxQueryBuilderArrayVariant: TComboBox;
    ComboBoxQueryBuilderArrayField: TComboBox;
    GroupBoxDataTypeArray: TGroupBox;
    GridPanelLayoutDataTypeArray: TGridPanelLayout;
    LabelDataTypeArrayString: TLabel;
    LabelDataTypeArrayVariant: TLabel;
    LabelDataTypeArrayField: TLabel;
    ComboBoxDataTypeTArrayString: TComboBox;
    ComboBoxDataTypeTArrayVariant: TComboBox;
    ComboBoxDataTypeTArrayField: TComboBox;
    MemoQueryBuilderArrayResult: TMemo;
    MemoDataTypeArrayResult: TMemo;
    GridPanelLayoutFloats: TGridPanelLayout;
    GroupBoxFloatFormat: TGroupBox;
    GridPanelLayoutFloatFormat: TGridPanelLayout;
    LayoutFloatFormatTest1: TLayout;
    EditLength1: TEdit;
    EditDecimal1: TEdit;
    LayoutFloatFormatTest2: TLayout;
    EditLength2: TEdit;
    EditDecimal2: TEdit;
    LayoutFloatFormatTest3: TLayout;
    EditLength3: TEdit;
    EditDecimal3: TEdit;
    LayoutFloatFormatTest4: TLayout;
    EditLength4: TEdit;
    EditDecimal4: TEdit;
    LayoutFloatFormatTest5: TLayout;
    EditLength5: TEdit;
    EditDecimal5: TEdit;
    LayoutFloatFormatTest6: TLayout;
    EditLength6: TEdit;
    EditDecimal6: TEdit;
    LayoutFloatFormatTest7: TLayout;
    EditLength7: TEdit;
    EditDecimal7: TEdit;
    MemoResultFormat: TMemo;
    GroupBoxFloatCalculate: TGroupBox;
    GridPanelLayoutFloatCalculate: TGridPanelLayout;
    Calculate: TButton;
    MemoResultCalculate: TMemo;
    ComboBoxResult1: TComboBox;
    ComboBoxResult2: TComboBox;
    ComboBoxResult3: TComboBox;
    ComboBoxResult4: TComboBox;
    ComboBoxResult5: TComboBox;
    ComboBoxResult6: TComboBox;
    ComboBoxResult7: TComboBox;
    GridPanelLayoutFloatCalculate1: TGridPanelLayout;
    EditCalculate1: TEdit;
    EditAmount1: TEdit;
    GridPanelLayoutFloatCalculate2: TGridPanelLayout;
    EditCalculate2: TEdit;
    EditAmount2: TEdit;
    GridPanelLayoutFloatCalculate3: TGridPanelLayout;
    EditCalculate3: TEdit;
    EditAmount3: TEdit;
    GridPanelLayoutFloatCalculate4: TGridPanelLayout;
    EditCalculate4: TEdit;
    EditAmount4: TEdit;
    GridPanelLayoutFloatCalculate5: TGridPanelLayout;
    EditCalculate5: TEdit;
    EditAmount5: TEdit;
    GridPanelLayoutFloatCalculate6: TGridPanelLayout;
    EditCalculate6: TEdit;
    EditAmount6: TEdit;
    GridPanelLayoutFloatCalculate7: TGridPanelLayout;
    EditCalculate7: TEdit;
    EditAmount7: TEdit;
    EditOperation1: TEdit;
    EditOperation2: TEdit;
    EditOperation3: TEdit;
    EditOperation4: TEdit;
    EditOperation5: TEdit;
    EditOperation6: TEdit;
    EditOperation7: TEdit;
    GridPanelLayoutFloatFormatActions: TGridPanelLayout;
    FormatExplicit: TButton;
    FormatImplicit: TButton;
    GridPanelLayoutPlaceholderMasks: TGridPanelLayout;
    EditKeyDownFloat: TEdit;
    EditKeyDownMoney: TEdit;
    Button1: TButton;
    TabControlSQLConnectors: TTabControl;
    TabDBConnectors: TTabItem;
    TabArrayConnectors: TTabItem;
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
    GridPanelLayoutOracleLabels: TGridPanelLayout;
    LabelEditOracle: TLabel;
    LabelComboEditOracle: TLabel;
    TabDBConnectorsNavigators: TTabItem;
    TabControlArrayConnectors: TTabControl;
    TabArrayString: TTabItem;
    TabArrayVariant: TTabItem;
    TabArrayField: TTabItem;
    TabArrayAssoc: TTabItem;
    GroupBoxComponentsArrayString: TGroupBox;
    GridPanelLayoutArrayString: TGridPanelLayout;
    LabelComboBoxArrayString: TLabel;
    ComboBoxArrayString: TComboBox;
    LabelListBoxArrayString: TLabel;
    LabelListViewArrayString: TLabel;
    ListBoxArrayString: TListBox;
    SearchBoxArrayString: TSearchBox;
    ListViewArrayString: TListView;
    LabelStringGridArrayString: TLabel;
    LabelGridArrayString: TLabel;
    StringGridArrayString: TStringGrid;
    GridArrayString: TGrid;
    GridPanelLayoutArrayStringAutoCompleteEdit: TGridPanelLayout;
    EditArrayString: TEdit;
    ComboEditArrayString: TComboEdit;
    GridPanelLayoutArrayStringLabels: TGridPanelLayout;
    LabelEditArrayString: TLabel;
    LabelComboEditArrayString: TLabel;
    GroupBoxComponentsArrayVariant: TGroupBox;
    GridPanelLayoutArrayVariant: TGridPanelLayout;
    LabelComboBoxArrayVariant: TLabel;
    ComboBoxArrayVariant: TComboBox;
    LabelListBoxArrayVariant: TLabel;
    LabelListViewArrayVariant: TLabel;
    ListBoxArrayVariant: TListBox;
    SearchBoxArrayVariant: TSearchBox;
    ListViewArrayVariant: TListView;
    LabelStringGridArrayVariant: TLabel;
    LabelGridArrayVariant: TLabel;
    StringGridArrayVariant: TStringGrid;
    GridArrayVariant: TGrid;
    GridPanelLayoutArrayVariantAutoCompleteEdit: TGridPanelLayout;
    EditArrayVariant: TEdit;
    ComboEditArrayVariant: TComboEdit;
    GridPanelLayoutArrayVariantLabels: TGridPanelLayout;
    LabelEditArrayVariant: TLabel;
    LabelComboEditArrayVariant: TLabel;
    GroupBoxComponentsArrayField: TGroupBox;
    GridPanelLayoutArrayField: TGridPanelLayout;
    LabelComboBoxArrayField: TLabel;
    ComboBoxArrayField: TComboBox;
    LabelListBoxArrayField: TLabel;
    LabelListViewArrayField: TLabel;
    ListBoxArrayField: TListBox;
    SearchBoxArrayField: TSearchBox;
    ListViewArrayField: TListView;
    LabelStringGridArrayField: TLabel;
    LabelGridArrayField: TLabel;
    StringGridArrayField: TStringGrid;
    GridArrayField: TGrid;
    GridPanelLayoutArrayFieldAutoCompleteEdit: TGridPanelLayout;
    EditArrayField: TEdit;
    ComboEditArrayField: TComboEdit;
    GridPanelLayoutArrayFieldLabels: TGridPanelLayout;
    LabelEditArrayField: TLabel;
    LabelComboEditArrayField: TLabel;
    GroupBoxComponentsArrayAssoc: TGroupBox;
    GridPanelLayoutArrayAssoc: TGridPanelLayout;
    LabelComboBoxArrayAssoc: TLabel;
    ComboBoxArrayAssoc: TComboBox;
    LabelListBoxArrayAssoc: TLabel;
    LabelListViewArrayAssoc: TLabel;
    ListBoxArrayAssoc: TListBox;
    SearchBoxArrayAssoc: TSearchBox;
    ListViewArrayAssoc: TListView;
    LabelStringGridArrayAssoc: TLabel;
    LabelGridArrayAssoc: TLabel;
    StringGridArrayAssoc: TStringGrid;
    GridArrayAssoc: TGrid;
    GridPanelLayoutArrayAssocAutoCompleteEdit: TGridPanelLayout;
    EditArrayAssoc: TEdit;
    ComboEditArrayAssoc: TComboEdit;
    GridPanelLayoutArrayAssocLabels: TGridPanelLayout;
    LabelEditArrayAssoc: TLabel;
    LabelComboEditArrayAssoc: TLabel;
    GridPanelLayout1: TGridPanelLayout;
    GroupBox1: TGroupBox;
    GridPanelLayout2: TGridPanelLayout;
    BindNavigator1: TBindNavigator;
    Edit1: TEdit;
    SearchEditButton1: TSearchEditButton;
    Grid1: TGrid;
    GridPanelLayout3: TGridPanelLayout;
    GroupBox2: TGroupBox;
    GridPanelLayout5: TGridPanelLayout;
    Edit2: TEdit;
    SearchEditButton2: TSearchEditButton;
    Grid2: TGrid;
    PagPanelLayout: TGridPanelLayout;
    PagButtonFirst: TCornerButton;
    PagButtonPrior: TCornerButton;
    PagButtonNext: TCornerButton;
    PagButtonLast: TCornerButton;
    GroupBox3: TGroupBox;
    GridPanelLayout4: TGridPanelLayout;
    Edit3: TEdit;
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
    EditOracle: TEdit;
    Button2: TButton;
    procedure TabDBSQLiteClick(Sender: TObject);
    procedure TabDBFirebirdClick(Sender: TObject);
    procedure TabDBMySQLClick(Sender: TObject);
    procedure TabDBPostgreSQLClick(Sender: TObject);
    procedure ComboBoxDataTypeTArrayStringChange(Sender: TObject);
    procedure ComboBoxDataTypeTArrayVariantChange(Sender: TObject);
    procedure ComboBoxDataTypeTArrayFieldChange(Sender: TObject);
    procedure FormatExplicitClick(Sender: TObject);
    procedure CalculateClick(Sender: TObject);
    procedure FormatImplicitClick(Sender: TObject);
    procedure EditKeyDownMoneyKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure EditKeyDownFloatKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TabDBSQLServerClick(Sender: TObject);
    procedure EditSQLitePresentationNameChoosing(Sender: TObject; var PresenterName: string);
    procedure TabDBOracleClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
    procedure PresentationNameChoosing(Sender: TObject; var PresenterName: string);
    function ArrayStringTest(const MethodName : String) : String;
    function ArrayVariantTest(const MethodName : String) : String;
    function ArrayFieldTest(const MethodName : String) : String;
  end;

var
  FGenericDatabaseForm: TGenericDatabaseForm;

implementation

uses
  FMX.Edit.Helper,
  FMX.Objects.Helper,
  FMX.Edit.Extension,
  DictionaryHelper,
  TimeDate,
  Float,
  &Array,
  ArrayString,
  ArrayStringHelper,
  ArrayVariant,
  ArrayVariantHelper,
  ArrayField,
  ArrayFieldHelper,
  ArrayAssoc,
  MimeType,
  EventDriven,
  Connection,
  Connector;

{$R *.fmx}

function TGenericDatabaseForm.ArrayStringTest(const MethodName : String) : String;
var
  Array1, Array2: TArrayString;
  Query: TQueryBuilder;
  SQL: TQuery;
  DB: TConnection;
begin
  DB := TConnection.Create;
  //DB := TConnectionClass.GetInstance();
  try
    DB.Driver := MYSQL;
    DB.Host := '127.0.0.1';
    DB.Port := 3306;
    DB.Database := 'demodev';
    DB.Username := 'root';
    DB.Password := '';

    if not DB.GetInstance.Connection.Connected then
      DB.GetInstance.Connection.Connected := True;

    Array1 := TArrayString.Create;
    try
      Array1.Clear;

      if MethodName <> 'Fetch' then
      begin
        SQL := Query.View('SELECT * FROM test_fields');
        Array1['field_inc'] := SQL.Query.FieldByName('field_inc').Value;
        Array1['field_int'] := SQL.Query.FieldByName('field_int').Value;
        Array1['field_char'] := SQL.Query.FieldByName('field_char').Value;
        Array1['field_varchar'] := SQL.Query.FieldByName('field_varchar').Value;
        Array1['field_enum'] := SQL.Query.FieldByName('field_enum').Value;
        Array1['field_set'] := SQL.Query.FieldByName('field_set').Value;
        Array1['field_date'] := SQL.Query.FieldByName('field_date').Value;
        Array1['field_time'] := SQL.Query.FieldByName('field_time').Value;
        Array1['field_year'] := SQL.Query.FieldByName('field_year').Value;
        Array1['field_datetime'] := SQL.Query.FieldByName('field_datetime').Value;
        Array1['field_timestamp'] := SQL.Query.FieldByName('field_timestamp').Value;
        Array1['field_decimal'] := SQL.Query.FieldByName('field_decimal').Value;
        Array1['field_float'] := SQL.Query.FieldByName('field_float').Value;
        Array1['field_double'] := SQL.Query.FieldByName('field_double').Value;
        Array1['field_bit'] := SQL.Query.FieldByName('field_bit').Value;
        Array1['field_binary'] := Trim(TEncoding.UTF8.GetString(SQL.Query.FieldByName('field_binary').Value));
        Array1['field_blob'] := Trim(TEncoding.UTF8.GetString(SQL.Query.FieldByName('field_blob').Value)); // Leitura
        //Array1['field_blob'] := TBase64.ToEncode(TEncoding.UTF8.GetString(SQL.Query.FieldByName('field_blob').Value)); // Grava��o
        Array1['field_base64'] := SQL.Query.FieldByName('field_base64').Value;
        Array1['field_varbinary'] := Trim(TEncoding.UTF8.GetString(SQL.Query.FieldByName('field_varbinary').Value));
        Array1['field_null'] := System.StrUtils.IfThen(SQL.Query.FieldByName('field_null').Value = NULL, 'null', SQL.Query.FieldByName('field_null').Value);
      end;

      case AnsiIndexStr(MethodName, Methods) of
        0 :
        begin
          Query.FetchOne('SELECT * FROM test_fields', Array1);
          Result := Array1.ToList(True);
        end;
        1 :
        begin
          Array2 := TArrayString.Create;
          Array2.Clear;
          Array2['field_copied'] := 'field_copied';
          Array2.Assign(Array1);
          Result := Array2.ToList(True);
          FreeAndNil(Array2);
        end;
        2 :
        begin
          Array2 := TArrayString.Create(Array1);
          Result := Array2.ToList(True);
          FreeAndNil(Array2);
        end;
        3 : Result := Array1.ToList(True);
        4 : Result := Array1.ToTags(True);
        5 : Result := Array1.ToXML(True);
        6 : Result := Array1.ToJSON(True);
        7 : Result := '';
      end;

    finally
      FreeAndNil(Array1);
    end;

  finally
    FreeAndNil(DB);
  end;
end;

function TGenericDatabaseForm.ArrayVariantTest(const MethodName : String) : String;
var
  Array1, Array2: TArrayVariant;
  Query: TQueryBuilder;
  SQL: TQuery;
  DB: TConnection;
begin
  DB := TConnection.Create;
  //DB := TConnectionClass.GetInstance();
  try
    DB.Driver := MYSQL;
    DB.Host := '127.0.0.1';
    DB.Port := 3306;
    DB.Database := 'demodev';
    DB.Username := 'root';
    DB.Password := '';

    if not DB.GetInstance.Connection.Connected then
      DB.GetInstance.Connection.Connected := True;

    Array1 := TArrayVariant.Create;
    try
      Array1.Clear;

      if MethodName <> 'Fetch' then
      begin
        SQL := Query.View('SELECT * FROM test_fields');
        Array1['field_inc'] := SQL.Query.FieldByName('field_inc').Value;
        Array1['field_int'] := SQL.Query.FieldByName('field_int').Value;
        Array1['field_char'] := SQL.Query.FieldByName('field_char').Value;
        Array1['field_varchar'] := SQL.Query.FieldByName('field_varchar').Value;
        Array1['field_enum'] := SQL.Query.FieldByName('field_enum').Value;
        Array1['field_set'] := SQL.Query.FieldByName('field_set').Value;
        Array1['field_date'] := SQL.Query.FieldByName('field_date').Value;
        Array1['field_time'] := SQL.Query.FieldByName('field_time').Value;
        Array1['field_year'] := SQL.Query.FieldByName('field_year').Value;
        Array1['field_datetime'] := SQL.Query.FieldByName('field_datetime').Value;
        Array1['field_timestamp'] := SQL.Query.FieldByName('field_timestamp').Value;
        Array1['field_decimal'] := SQL.Query.FieldByName('field_decimal').Value;
        Array1['field_float'] := SQL.Query.FieldByName('field_float').Value;
        Array1['field_double'] := SQL.Query.FieldByName('field_double').Value;
        Array1['field_bit'] := SQL.Query.FieldByName('field_bit').Value;
        Array1['field_binary'] := SQL.Query.FieldByName('field_binary').Value;
        Array1['field_blob'] := SQL.Query.FieldByName('field_blob').Value;
        Array1['field_base64'] := SQL.Query.FieldByName('field_base64').Value;
        Array1['field_varbinary'] := SQL.Query.FieldByName('field_varbinary').Value;
        Array1['field_null'] := SQL.Query.FieldByName('field_null').Value;
      end;

      case AnsiIndexStr(MethodName, Methods) of
        0 :
        begin
          Query.FetchOne('SELECT * FROM test_fields', Array1);
          Result := Array1.ToList(True);
        end;
        1 :
        begin
          Array2 := TArrayVariant.Create;
          Array2.Clear;
          Array2['field_copied'] := 'field_copied';
          Array2.Assign(Array1);
          Result := Array2.ToList(True);
          FreeAndNil(Array2);
        end;
        2 :
        begin
          Array2 := TArrayVariant.Create(Array1);
          Result := Array2.ToList(True);
          FreeAndNil(Array2);
        end;
        3 : Result := Array1.ToList(True);
        4 : Result := Array1.ToTags(True);
        5 : Result := Array1.ToXML(True);
        6 : Result := Array1.ToJSON(True);
        7 : Result := '';
      end;

    finally
      FreeAndNil(Array1);
    end;

  finally
    FreeAndNil(DB);
  end;
end;

procedure TGenericDatabaseForm.Button1Click(Sender: TObject);
var
  Array1 : TArrayAssoc;
  Query: TQueryBuilder;
//  SQL: TQuery;
  DB: TConnection;
//  Item: TPair<Variant, TArrayAssoc>;
//  Enum: TPair<Variant, TArrayAssoc>;
begin
  DB := TConnection.Create;
  //DB := TConnectionClass.GetInstance();
  try
    DB.Driver := MYSQL;
    DB.Host := '127.0.0.1';
    DB.Port := 3306;
    DB.Database := 'demodev';
    DB.Username := 'root';
    DB.Password := '';

    if not DB.GetInstance.Connection.Connected then
      DB.GetInstance.Connection.Connected := True;

    Array1 := TArrayAssoc.Create;
    try
      Array1.Clear;

      Query.FetchAll('SELECT * FROM test_fields', Array1);
      Showmessage(Array1.ToList(True));
      Showmessage(Array1.ToTags(True));
      Showmessage(Array1.ToXML(True));
      Showmessage(Array1.ToJSON(True));

//      for Enum in Array1.ToArray do
//      begin
//        for Item in Enum.Value.ToArray do
//        begin
//          //Showmessage('Property ' + String(Item.Key) + ' = ' + String(Enum.Value[Item.Key].Val));
//        end;
//      end;

    finally
      FreeAndNil(Array1);
    end;

  finally
    FreeAndNil(DB);
  end;
end;

procedure TGenericDatabaseForm.Button2Click(Sender: TObject);
var
  Arr: TArray<TArrayVariant>;
begin
  Arr := TArray<TArrayVariant>.Create;
  Arr['field_copied'] := 'field_copied';
  Showmessage(Arr.ToList(True));
//  Arr.Access['field_copied'] := 'field_copied';
//  Showmessage(Arr.Access.ToList(True));
end;

function TGenericDatabaseForm.ArrayFieldTest(const MethodName : String) : String;
var
  Array1, Array2: TArrayField;
  Array3: TArrayVariant;
  Query: TQueryBuilder;
  SQL: TQuery;
  DB: TConnection;
begin
  DB := TConnection.Create;
  //DB := TConnectionClass.GetInstance();
  try
    DB.Driver := MYSQL;
    DB.Host := '127.0.0.1';
    DB.Port := 3306;
    DB.Database := 'demodev';
    DB.Username := 'root';
    DB.Password := '';

    if not DB.GetInstance.Connection.Connected then
      DB.GetInstance.Connection.Connected := True;

    Array1 := TArrayField.Create;
    try
      Array1.Clear;

      if MethodName <> 'Fetch' then
      begin
        SQL := Query.View('SELECT * FROM test_fields');
        Array1['field_inc'] := SQL.Query.FieldByName('field_inc');
        Array1['field_int'] := SQL.Query.FieldByName('field_int');
        Array1['field_char'] := SQL.Query.FieldByName('field_char');
        Array1['field_varchar'] := SQL.Query.FieldByName('field_varchar');
        Array1['field_enum'] := SQL.Query.FieldByName('field_enum');
        Array1['field_set'] := SQL.Query.FieldByName('field_set');
        Array1['field_date'] := SQL.Query.FieldByName('field_date');
        Array1['field_time'] := SQL.Query.FieldByName('field_time');
        Array1['field_year'] := SQL.Query.FieldByName('field_year');
        Array1['field_datetime'] := SQL.Query.FieldByName('field_datetime');
        Array1['field_timestamp'] := SQL.Query.FieldByName('field_timestamp');
        Array1['field_decimal'] := SQL.Query.FieldByName('field_decimal');
        Array1['field_float'] := SQL.Query.FieldByName('field_float');
        Array1['field_double'] := SQL.Query.FieldByName('field_double');
        Array1['field_bit'] := SQL.Query.FieldByName('field_bit');
        Array1['field_binary'] := SQL.Query.FieldByName('field_binary');
        Array1['field_blob'] := SQL.Query.FieldByName('field_blob');
        Array1['field_base64'] := SQL.Query.FieldByName('field_base64');
        Array1['field_varbinary'] := SQL.Query.FieldByName('field_varbinary');
        Array1['field_null'] := SQL.Query.FieldByName('field_null');
      end;

      case AnsiIndexStr(MethodName, Methods) of
        0 :
        begin
          Query.FetchOne('SELECT * FROM test_fields', Array1);
          Result := Array1.ToList(True);
        end;
        1 :
        begin
          Array3 := TArrayVariant.Create;
          Array3.Clear;
          Array3['field_cloned'] := 'cloned_field';
          Array3.Assign(Array1);
          Result := Array3.ToList(True);
          FreeAndNil(Array3);
        end;
        2 :
        begin
          Array2 := TArrayField.Create(Array1);
          Result := Array2.ToList(True);
          FreeAndNil(Array2);
        end;
        3 : Result := Array1.ToList(True);
        4 : Result := Array1.ToTags(True);
        5 : Result := Array1.ToXML(True);
        6 : Result := Array1.ToJSON(True);
        7 : Result := '';
      end;

    finally
      FreeAndNil(Array1);
    end;

  finally
    FreeAndNil(DB);
  end;
end;

procedure TGenericDatabaseForm.EditKeyDownFloatKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  //TEdit(Sender).SetMaskFloatKeyDown(KeyChar, Key);
end;

procedure TGenericDatabaseForm.EditKeyDownMoneyKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  //TEdit(Sender).SetMaskMoneyKeyDown(KeyChar, Key);
end;

procedure TGenericDatabaseForm.PresentationNameChoosing(Sender: TObject; var PresenterName: string);
begin
  inherited;
  PresenterName := 'SuggestEdit-Style';
end;

procedure TGenericDatabaseForm.EditSQLitePresentationNameChoosing(Sender: TObject; var PresenterName: string);
begin
  Self.PresentationNameChoosing(Sender, PresenterName);
end;

procedure TGenericDatabaseForm.ComboBoxDataTypeTArrayStringChange(Sender: TObject);
var
  Value : String;
begin
  Value := TComboBox(Sender).Selected.Text;
  case AnsiIndexStr(Value, Methods) of
    0 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayStringTest(Value);
    1 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayStringTest(Value);
    2 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayStringTest(Value);
    3 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayStringTest(Value);
    4 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayStringTest(Value);
    5 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayStringTest(Value);
    6 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayStringTest(Value);
    7 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayStringTest(Value);
  end;
end;

procedure TGenericDatabaseForm.ComboBoxDataTypeTArrayVariantChange(Sender: TObject);
var
  Value : String;
begin
  Value := TComboBox(Sender).Selected.Text;
  case AnsiIndexStr(Value, Methods) of
    0 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayVariantTest(Value);
    1 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayVariantTest(Value);
    2 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayVariantTest(Value);
    3 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayVariantTest(Value);
    4 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayVariantTest(Value);
    5 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayVariantTest(Value);
    6 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayVariantTest(Value);
    7 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayVariantTest(Value);
  end;
end;

procedure TGenericDatabaseForm.ComboBoxDataTypeTArrayFieldChange(Sender: TObject);
var
  Value : String;
begin
  Value := TComboBox(Sender).Selected.Text;
  case AnsiIndexStr(Value, Methods) of
    0 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayFieldTest(Value);
    1 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayFieldTest(Value);
    2 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayFieldTest(Value);
    3 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayFieldTest(Value);
    4 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayFieldTest(Value);
    5 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayFieldTest(Value);
    6 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayFieldTest(Value);
    7 : MemoDataTypeArrayResult.Lines.Text := Self.ArrayFieldTest(Value);
  end;
end;

procedure TGenericDatabaseForm.CalculateClick(Sender: TObject);
begin
  MemoResultCalculate.Lines.Clear;
  MemoResultCalculate.Lines.Append(
    'C�lculo com ToCurrency: ' + TFloat.ToString(EditCalculate1.Text) + ' * ' + TFloat.ToString(EditAmount1.Text)
     + ' - Truncando: ' + TFloat.ToString(CurrToStr(TFloat.ToCurrency(EditCalculate1.Text) * TFloat.ToCurrency(EditAmount1.Text)), 4, TResultMode.Truncate)
     + ' - Arredondando: ' + TFloat.ToString(CurrToStr(TFloat.ToCurrency(EditCalculate1.Text) * TFloat.ToCurrency(EditAmount1.Text)), 4, TResultMode.Round)
  );
  MemoResultCalculate.Lines.Append('------------------------------------------------------------------------------');
  MemoResultCalculate.Lines.Append(
    'C�lculo com Double: ' + TFloat.ToString(EditCalculate2.Text) + ' * ' + TFloat.ToString(EditAmount2.Text)
     + ' - Truncando: ' + TFloat.ToString(FloatToStr(TFloat.ToDouble(EditCalculate2.Text) * TFloat.ToDouble(EditAmount2.Text)), 4, TResultMode.Truncate)
     + ' - Arredondando: ' + TFloat.ToString(FloatToStr(TFloat.ToDouble(EditCalculate2.Text) * TFloat.ToDouble(EditAmount2.Text)), 4, TResultMode.Round)
  );
  MemoResultCalculate.Lines.Append('------------------------------------------------------------------------------');
  MemoResultCalculate.Lines.Append(
    'C�lculo com Extended: ' + TFloat.ToString(EditCalculate3.Text) + ' * ' + TFloat.ToString(EditAmount3.Text)
     + ' - Truncando: ' + TFloat.ToString(FloatToStr(TFloat.ToExtended(EditCalculate3.Text) * TFloat.ToExtended(EditAmount3.Text)), 4, TResultMode.Truncate)
     + ' - Arredondando: ' + TFloat.ToString(FloatToStr(TFloat.ToExtended(EditCalculate3.Text) * TFloat.ToExtended(EditAmount3.Text)), 4, TResultMode.Round)
  );
  MemoResultCalculate.Lines.Append('------------------------------------------------------------------------------');
  MemoResultCalculate.Lines.Append(
    'C�lculo com ToMoney: ' + TFloat.ToString(EditCalculate4.Text) + ' * ' + TFloat.ToString(EditAmount4.Text)
     + ' - Truncando: ' + TFloat.ToMoney(FloatToStr(TFloat.ToCurrency(EditCalculate4.Text) * TFloat.ToCurrency(EditAmount4.Text)), 4, TResultMode.Truncate)
     + ' - Arredondando: ' + TFloat.ToMoney(FloatToStr(TFloat.ToCurrency(EditCalculate4.Text) * TFloat.ToCurrency(EditAmount4.Text)), 4, TResultMode.Round)
  );
  MemoResultCalculate.Lines.Append('------------------------------------------------------------------------------');
  MemoResultCalculate.Lines.Append(
    'C�lculo com ToSQL: ' + TFloat.ToString(EditCalculate5.Text) + ' * ' + TFloat.ToString(EditAmount5.Text)
     + ' - Truncando: ' + TFloat.ToSQL(FloatToStr(TFloat.ToCurrency(EditCalculate5.Text) * TFloat.ToCurrency(EditAmount5.Text)), 4, TResultMode.Truncate)
     + ' - Arredondando: ' + TFloat.ToSQL(FloatToStr(TFloat.ToCurrency(EditCalculate5.Text) * TFloat.ToCurrency(EditAmount5.Text)), 4, TResultMode.Round)
  );
end;

procedure TGenericDatabaseForm.FormatExplicitClick(Sender: TObject);
begin
  MemoResultFormat.Lines.Clear;
  MemoResultFormat.Lines.Append('Original: ' + EditLength1.Text + ' - Valor: ' + TFloat.ToString(EditLength1.Text, StrToInt(EditDecimal1.Text), TResultMode(ComboBoxResult1.ItemIndex)));
  MemoResultFormat.Lines.Append('------------------------------------------------------------------------------');
  MemoResultFormat.Lines.Append('Original: ' + EditLength2.Text + ' - Valor: ' + TFloat.ToString(EditLength2.Text, StrToInt(EditDecimal2.Text), TResultMode(ComboBoxResult2.ItemIndex)));
  MemoResultFormat.Lines.Append('------------------------------------------------------------------------------');
  MemoResultFormat.Lines.Append('Original: ' + EditLength3.Text + ' - Valor: ' + TFloat.ToString(EditLength3.Text, StrToInt(EditDecimal3.Text), TResultMode(ComboBoxResult3.ItemIndex)));
  MemoResultFormat.Lines.Append('------------------------------------------------------------------------------');
  MemoResultFormat.Lines.Append('Original: ' + EditLength4.Text + ' - Valor: ' + TFloat.ToString(EditLength4.Text, StrToInt(EditDecimal4.Text), TResultMode(ComboBoxResult4.ItemIndex)));
  MemoResultFormat.Lines.Append('------------------------------------------------------------------------------');
  MemoResultFormat.Lines.Append('Original: ' + EditLength5.Text + ' - Valor: ' + TFloat.ToString(EditLength5.Text, StrToInt(EditDecimal5.Text), TResultMode(ComboBoxResult5.ItemIndex)));
  MemoResultFormat.Lines.Append('------------------------------------------------------------------------------');
  MemoResultFormat.Lines.Append('Original: ' + EditLength6.Text + ' - Valor: ' + TFloat.ToString(EditLength6.Text, StrToInt(EditDecimal6.Text), TResultMode(ComboBoxResult6.ItemIndex)));
  MemoResultFormat.Lines.Append('------------------------------------------------------------------------------');
  MemoResultFormat.Lines.Append('Original: ' + EditLength7.Text + ' - Valor: ' + TFloat.ToString(EditLength7.Text, StrToInt(EditDecimal7.Text), TResultMode(ComboBoxResult7.ItemIndex)));
end;

procedure TGenericDatabaseForm.FormatImplicitClick(Sender: TObject);
begin
  MemoResultFormat.Lines.Clear;
  MemoResultFormat.Lines.Append('Original: ' + EditLength1.Text + ' - Valor: ' + TFloat.ToString(EditLength1.Text));
  MemoResultFormat.Lines.Append('------------------------------------------------------------------------------');
  MemoResultFormat.Lines.Append('Original: ' + EditLength2.Text + ' - Valor: ' + TFloat.ToString(EditLength2.Text));
  MemoResultFormat.Lines.Append('------------------------------------------------------------------------------');
  MemoResultFormat.Lines.Append('Original: ' + EditLength3.Text + ' - Valor: ' + TFloat.ToString(EditLength3.Text));
  MemoResultFormat.Lines.Append('------------------------------------------------------------------------------');
  MemoResultFormat.Lines.Append('Original: ' + EditLength4.Text + ' - Valor: ' + TFloat.ToString(EditLength4.Text));
  MemoResultFormat.Lines.Append('------------------------------------------------------------------------------');
  MemoResultFormat.Lines.Append('Original: ' + EditLength5.Text + ' - Valor: ' + TFloat.ToString(EditLength5.Text));
  MemoResultFormat.Lines.Append('------------------------------------------------------------------------------');
  MemoResultFormat.Lines.Append('Original: ' + EditLength6.Text + ' - Valor: ' + TFloat.ToString(EditLength6.Text));
  MemoResultFormat.Lines.Append('------------------------------------------------------------------------------');
  MemoResultFormat.Lines.Append('Original: ' + EditLength7.Text + ' - Valor: ' + TFloat.ToString(EditLength7.Text));
end;

procedure TGenericDatabaseForm.FormShow(Sender: TObject);
begin
  EditKeyDownMoney.Placeholder('M�scara Monet�ria');
  EditKeyDownFloat.Placeholder('M�scara Decimal[4]');
end;

procedure TGenericDatabaseForm.TabDBFirebirdClick(Sender: TObject);
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
//        Connector.ToListBox(ListBoxFirebird, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp�rito Santo']]));
//        Connector.ToGrid(StringGridFirebird, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridFirebird, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewFirebird, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxFirebird, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditFirebird, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditFirebird, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxFirebird, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp�rito Santo"}}');
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

procedure TGenericDatabaseForm.TabDBMySQLClick(Sender: TObject);
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
//        Connector.ToListBox(ListBoxMySQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp�rito Santo']]));
//        Connector.ToGrid(StringGridMySQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridMySQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewMySQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxMySQL, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditMySQL, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditMySQL, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxMySQL, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp�rito Santo"}}');
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

procedure TGenericDatabaseForm.TabDBOracleClick(Sender: TObject);
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
//        Connector.ToListBox(ListBoxOracle, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp�rito Santo']]));
//        Connector.ToGrid(StringGridOracle, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridOracle, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewOracle, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxOracle, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditOracle, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditOracle, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxOracle, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp�rito Santo"}}');
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

procedure TGenericDatabaseForm.TabDBPostgreSQLClick(Sender: TObject);
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
//        Connector.ToListBox(ListBoxPostgreSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp�rito Santo']]));
//        Connector.ToGrid(StringGridPostgreSQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridPostgreSQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewPostgreSQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxPostgreSQL, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditPostgreSQL, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditPostgreSQL, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxPostgreSQL, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp�rito Santo"}}');
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

procedure TGenericDatabaseForm.TabDBSQLServerClick(Sender: TObject);
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
//        Connector.ToListBox(ListBoxMSSQL, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp�rito Santo']]));
//        Connector.ToGrid(StringGridMSSQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridMSSQL, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewMSSQL, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        Connector.ToCombo(ComboBoxMSSQL, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditMSSQL, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditMSSQL, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxMSSQL, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp�rito Santo"}}');
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

procedure TGenericDatabaseForm.TabDBSQLiteClick(Sender: TObject);
var
  DBSQLite : TConnection;
  SQL: TQuery;
  Query: TQueryBuilder;
  Connector: TConnector;

//  JSONString: String;
//  JSONObject,
//  JSONFields,
//  JSONPagination,
//  JSONNavigation : TJSONObject;
//  I, J : Integer;
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
//        Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Esp�rito Santo']]));
//        Connector.ToGrid(StringGridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'AP']]));
//        Connector.ToGrid(GridSQLite, TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Estado', 'Distrito Federal']]));
//        Connector.ToListView(ListViewSQLite, 'Codigo', 'Estado', ['Codigo', 'Estado', 'Sigla'], TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [['Sigla', 'PA']]));

        //Showmessage(TJSONOptionsHelper.&Set(['Codigo',3], 1, TNavigationType.Pages));

        Connector.ToCombo(ComboBoxSQLite, 'Codigo', 'Estado', '{"Index":1}');
        Connector.ToCombo(EditSQLite, 'Codigo', 'Estado', '{"Field":{"Codigo":3}}');
        Connector.ToCombo(ComboEditSQLite, 'Codigo', 'Estado', '{"Index":5}');
        Connector.ToListBox(ListBoxSQLite, 'Codigo', 'Estado', '{"Field":{"Estado":"Esp�rito Santo"}}');
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
