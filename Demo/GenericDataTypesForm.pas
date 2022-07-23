unit GenericDataTypesForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.ListBox, FMX.Edit, FMX.Layouts,
  FMX.Controls.Presentation, FMX.TabControl, System.StrUtils;

type
  TGenericDataTypesForm = class(TForm)
    TabControl: TTabControl;
    TabDataTypes: TTabItem;
    TabControlDataTypes: TTabControl;
    TabStrings: TTabItem;
    TabFloats: TTabItem;
    GridPanelLayoutFloats: TGridPanelLayout;
    TabDateTime: TTabItem;
    TabArrays: TTabItem;
    GroupBoxDataTypeArray: TGroupBox;
    GridPanelLayoutDataTypeArray: TGridPanelLayout;
    LabelDataTypeArrayString: TLabel;
    LabelDataTypeArrayVariant: TLabel;
    LabelDataTypeArrayField: TLabel;
    ComboBoxDataTypeTArrayString: TComboBox;
    ComboBoxDataTypeTArrayVariant: TComboBox;
    ComboBoxDataTypeTArrayField: TComboBox;
    MemoDataTypeArrayResult: TMemo;
    GroupBoxFloatFormat: TGroupBox;
    GridPanelLayoutFloatFormat: TGridPanelLayout;
    LayoutFloatFormatTest1: TLayout;
    EditLength1: TEdit;
    EditDecimal1: TEdit;
    ComboBoxResult1: TComboBox;
    LayoutFloatFormatTest2: TLayout;
    EditLength2: TEdit;
    EditDecimal2: TEdit;
    ComboBoxResult2: TComboBox;
    LayoutFloatFormatTest3: TLayout;
    EditLength3: TEdit;
    EditDecimal3: TEdit;
    ComboBoxResult3: TComboBox;
    LayoutFloatFormatTest4: TLayout;
    EditLength4: TEdit;
    EditDecimal4: TEdit;
    ComboBoxResult4: TComboBox;
    LayoutFloatFormatTest5: TLayout;
    EditLength5: TEdit;
    EditDecimal5: TEdit;
    ComboBoxResult5: TComboBox;
    LayoutFloatFormatTest6: TLayout;
    EditLength6: TEdit;
    EditDecimal6: TEdit;
    ComboBoxResult6: TComboBox;
    LayoutFloatFormatTest7: TLayout;
    EditLength7: TEdit;
    EditDecimal7: TEdit;
    ComboBoxResult7: TComboBox;
    MemoResultFormat: TMemo;
    GridPanelLayoutFloatFormatActions: TGridPanelLayout;
    FormatExplicit: TButton;
    FormatImplicit: TButton;
    GroupBoxFloatCalculate: TGroupBox;
    GridPanelLayoutFloatCalculate: TGridPanelLayout;
    Calculate: TButton;
    MemoResultCalculate: TMemo;
    GridPanelLayoutFloatCalculate1: TGridPanelLayout;
    EditCalculate1: TEdit;
    EditAmount1: TEdit;
    EditOperation1: TEdit;
    GridPanelLayoutFloatCalculate2: TGridPanelLayout;
    EditCalculate2: TEdit;
    EditAmount2: TEdit;
    EditOperation2: TEdit;
    GridPanelLayoutFloatCalculate3: TGridPanelLayout;
    EditCalculate3: TEdit;
    EditAmount3: TEdit;
    EditOperation3: TEdit;
    GridPanelLayoutFloatCalculate4: TGridPanelLayout;
    EditCalculate4: TEdit;
    EditAmount4: TEdit;
    EditOperation4: TEdit;
    GridPanelLayoutFloatCalculate5: TGridPanelLayout;
    EditCalculate5: TEdit;
    EditAmount5: TEdit;
    EditOperation5: TEdit;
    GridPanelLayoutFloatCalculate6: TGridPanelLayout;
    EditCalculate6: TEdit;
    EditAmount6: TEdit;
    EditOperation6: TEdit;
    GridPanelLayoutFloatCalculate7: TGridPanelLayout;
    EditCalculate7: TEdit;
    EditAmount7: TEdit;
    EditOperation7: TEdit;
    Button1: TButton;
    procedure ComboBoxDataTypeTArrayStringChange(Sender: TObject);
    procedure ComboBoxDataTypeTArrayVariantChange(Sender: TObject);
    procedure ComboBoxDataTypeTArrayFieldChange(Sender: TObject);
    procedure FormatExplicitClick(Sender: TObject);
    procedure FormatImplicitClick(Sender: TObject);
    procedure CalculateClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function ArrayStringTest(const MethodName : String) : String;
    function ArrayVariantTest(const MethodName : String) : String;
    function ArrayFieldTest(const MethodName : String) : String;
  end;

var
  FGenericDataTypesForm: TGenericDataTypesForm;

implementation

uses
  DictionaryHelper,
  TimeDate,
  Float,
  IArray,
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

{ TGenericDataTypesForm }

const
  Methods: Array of String = ['Fetch','Copy','Clone','ToList','ToTags','ToXML','ToJSON','ToYAML'];

function TGenericDataTypesForm.ArrayStringTest(const MethodName: String): String;
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

    Array1 := TArrayString.Create();
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
        //Array1['field_blob'] := TBase64.ToEncode(TEncoding.UTF8.GetString(SQL.Query.FieldByName('field_blob').Value)); // Gravação
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

function TGenericDataTypesForm.ArrayVariantTest(const MethodName: String): String;
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

procedure TGenericDataTypesForm.Button1Click(Sender: TObject);
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

function TGenericDataTypesForm.ArrayFieldTest(const MethodName: String): String;
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

procedure TGenericDataTypesForm.ComboBoxDataTypeTArrayStringChange(Sender: TObject);
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

procedure TGenericDataTypesForm.ComboBoxDataTypeTArrayVariantChange(Sender: TObject);
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

procedure TGenericDataTypesForm.ComboBoxDataTypeTArrayFieldChange(Sender: TObject);
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

procedure TGenericDataTypesForm.FormatExplicitClick(Sender: TObject);
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

procedure TGenericDataTypesForm.FormatImplicitClick(Sender: TObject);
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

procedure TGenericDataTypesForm.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
end;

procedure TGenericDataTypesForm.CalculateClick(Sender: TObject);
begin
  MemoResultCalculate.Lines.Clear;
  MemoResultCalculate.Lines.Append(
    'Cálculo com ToCurrency: ' + TFloat.ToString(EditCalculate1.Text) + ' * ' + TFloat.ToString(EditAmount1.Text)
     + ' - Truncando: ' + TFloat.ToString(CurrToStr(TFloat.ToCurrency(EditCalculate1.Text) * TFloat.ToCurrency(EditAmount1.Text)), 4, TResultMode.Truncate)
     + ' - Arredondando: ' + TFloat.ToString(CurrToStr(TFloat.ToCurrency(EditCalculate1.Text) * TFloat.ToCurrency(EditAmount1.Text)), 4, TResultMode.Round)
  );
  MemoResultCalculate.Lines.Append('------------------------------------------------------------------------------');
  MemoResultCalculate.Lines.Append(
    'Cálculo com Double: ' + TFloat.ToString(EditCalculate2.Text) + ' * ' + TFloat.ToString(EditAmount2.Text)
     + ' - Truncando: ' + TFloat.ToString(FloatToStr(TFloat.ToDouble(EditCalculate2.Text) * TFloat.ToDouble(EditAmount2.Text)), 4, TResultMode.Truncate)
     + ' - Arredondando: ' + TFloat.ToString(FloatToStr(TFloat.ToDouble(EditCalculate2.Text) * TFloat.ToDouble(EditAmount2.Text)), 4, TResultMode.Round)
  );
  MemoResultCalculate.Lines.Append('------------------------------------------------------------------------------');
  MemoResultCalculate.Lines.Append(
    'Cálculo com Extended: ' + TFloat.ToString(EditCalculate3.Text) + ' * ' + TFloat.ToString(EditAmount3.Text)
     + ' - Truncando: ' + TFloat.ToString(FloatToStr(TFloat.ToExtended(EditCalculate3.Text) * TFloat.ToExtended(EditAmount3.Text)), 4, TResultMode.Truncate)
     + ' - Arredondando: ' + TFloat.ToString(FloatToStr(TFloat.ToExtended(EditCalculate3.Text) * TFloat.ToExtended(EditAmount3.Text)), 4, TResultMode.Round)
  );
  MemoResultCalculate.Lines.Append('------------------------------------------------------------------------------');
  MemoResultCalculate.Lines.Append(
    'Cálculo com ToMoney: ' + TFloat.ToString(EditCalculate4.Text) + ' * ' + TFloat.ToString(EditAmount4.Text)
     + ' - Truncando: ' + TFloat.ToMoney(FloatToStr(TFloat.ToCurrency(EditCalculate4.Text) * TFloat.ToCurrency(EditAmount4.Text)), 4, TResultMode.Truncate)
     + ' - Arredondando: ' + TFloat.ToMoney(FloatToStr(TFloat.ToCurrency(EditCalculate4.Text) * TFloat.ToCurrency(EditAmount4.Text)), 4, TResultMode.Round)
  );
  MemoResultCalculate.Lines.Append('------------------------------------------------------------------------------');
  MemoResultCalculate.Lines.Append(
    'Cálculo com ToSQL: ' + TFloat.ToString(EditCalculate5.Text) + ' * ' + TFloat.ToString(EditAmount5.Text)
     + ' - Truncando: ' + TFloat.ToSQL(FloatToStr(TFloat.ToCurrency(EditCalculate5.Text) * TFloat.ToCurrency(EditAmount5.Text)), 4, TResultMode.Truncate)
     + ' - Arredondando: ' + TFloat.ToSQL(FloatToStr(TFloat.ToCurrency(EditCalculate5.Text) * TFloat.ToCurrency(EditAmount5.Text)), 4, TResultMode.Round)
  );
end;

end.
