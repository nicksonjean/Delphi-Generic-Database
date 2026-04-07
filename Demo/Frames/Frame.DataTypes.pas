unit Frame.DataTypes;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.StrUtils,
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
  FMX.Memo,
  FMX.Memo.Types,
  FMX.TabControl,
  Connection;

type
  TFrameDataTypes = class(TFrame)
    RectDataTypesBg: TRectangle;
    RectDTHeader: TRectangle;
    LblDTTitle: TLabel;
    TabControlDataTypes: TTabControl;
    TabArrays: TTabItem;
    GridPanelArrayTab: TGridPanelLayout;
    RectArraySelectors: TRectangle;
    RectArraySelectHeader: TRectangle;
    RectArraySelectHeaderFill: TRectangle;
    LblArraySelectTitle: TLabel;
    GridPanelArraySelectors: TGridPanelLayout;
    GroupBoxArrayString: TGroupBox;
    ComboBoxDataTypeTArrayString: TComboBox;
    GroupBoxArrayVariant: TGroupBox;
    ComboBoxDataTypeTArrayVariant: TComboBox;
    GroupBoxArrayField: TGroupBox;
    ComboBoxDataTypeTArrayField: TComboBox;
    MemoDataTypeArrayResult: TMemo;
    RectArrayConfig: TRectangle;
    RectArrayConfigHeader: TRectangle;
    RectArrayConfigHeaderFill: TRectangle;
    LblArrayConfigTitle: TLabel;
    ScrollArrayConfig: TVertScrollBox;
    LblArrayHost: TLabel;
    EditArrayHost: TEdit;
    LblArrayPort: TLabel;
    EditArrayPort: TEdit;
    LblArrayDatabase: TLabel;
    EditArrayDatabase: TEdit;
    LblArrayUsername: TLabel;
    EditArrayUsername: TEdit;
    LblArrayPassword: TLabel;
    EditArrayPassword: TEdit;
    TabFloats: TTabItem;
    GridPanelFloatsTab: TGridPanelLayout;
    GroupBoxFloatFormat: TGroupBox;
    GridPanelFloatFormat: TGridPanelLayout;
    LayoutFloatTest1: TLayout;
    EditLength1: TEdit;
    EditDecimal1: TEdit;
    LayoutFloatTest2: TLayout;
    EditLength2: TEdit;
    EditDecimal2: TEdit;
    LayoutFloatTest3: TLayout;
    ComboBoxResult1: TComboBox;
    LayoutFloatTest4: TLayout;
    EditLength3: TEdit;
    EditDecimal3: TEdit;
    LayoutFloatTest5: TLayout;
    EditLength4: TEdit;
    EditDecimal4: TEdit;
    LayoutFloatTest6: TLayout;
    ComboBoxResult2: TComboBox;
    LayoutFloatTest7: TLayout;
    EditLength5: TEdit;
    EditDecimal5: TEdit;
    GridPanelFloatActions: TGridPanelLayout;
    FormatExplicit: TButton;
    FormatImplicit: TButton;
    MemoResultFormat: TMemo;
    GroupBoxFloatCalculate: TGroupBox;
    ScrollFloatCalc: TVertScrollBox;
    GridPanelFloatCalcInputs: TGridPanelLayout;
    EditCalculate1: TEdit;
    EditAmount1: TEdit;
    EditOperation1: TEdit;
    EditCalculate2: TEdit;
    EditAmount2: TEdit;
    EditOperation2: TEdit;
    EditCalculate3: TEdit;
    EditAmount3: TEdit;
    EditOperation3: TEdit;
    EditCalculate4: TEdit;
    EditAmount4: TEdit;
    EditOperation4: TEdit;
    EditCalculate5: TEdit;
    EditAmount5: TEdit;
    EditOperation5: TEdit;
    Calculate: TButton;
    MemoResultCalculate: TMemo;
    TabStrings: TTabItem;
    LblStringsComingSoon: TLabel;
    TabDateTime: TTabItem;
    LblDateTimeComingSoon: TLabel;
    procedure ComboBoxDataTypeTArrayStringChange(Sender: TObject);
    procedure ComboBoxDataTypeTArrayVariantChange(Sender: TObject);
    procedure ComboBoxDataTypeTArrayFieldChange(Sender: TObject);
    procedure FormatExplicitClick(Sender: TObject);
    procedure FormatImplicitClick(Sender: TObject);
    procedure CalculateClick(Sender: TObject);
  private
    function GetDBConnection: TConnection;
    function ArrayStringTest(const AMethodName: String): String;
    function ArrayVariantTest(const AMethodName: String): String;
    function ArrayFieldTest(const AMethodName: String): String;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  DictionaryHelper,
  &Type.DateTime,
  &Type.Float,
  &Type.&Array,
  &Type.&Array.&String,
  &Type.&Array.&String.Helper,
  &Type.&Array.Variant,
  &Type.&Array.Variant.Helper,
  &Type.&Array.Field,
  &Type.&Array.Field.Helper,
  &Type.&Array.Assoc,
  Connection.Types,
  Query,
  QueryBuilder;

{$R *.fmx}

const
  Methods: array of String = ['Fetch','Copy','Clone','ToList','ToTags','ToXML','ToJSON'];

{ TFrameDataTypes }

constructor TFrameDataTypes.Create(AOwner: TComponent);
begin
  inherited;
  ReportMemoryLeaksOnShutdown := True;
end;

function TFrameDataTypes.GetDBConnection: TConnection;
begin
  Result := TConnection.Create(TEngine.FireDAC);
  try
    Result.Driver    := TDriver.MySQL;
    Result.Host      := EditArrayHost.Text;
    Result.Port      := StrToIntDef(EditArrayPort.Text, 3306);
    Result.Database  := EditArrayDatabase.Text;
    Result.Username  := EditArrayUsername.Text;
    Result.Password  := EditArrayPassword.Text;
    Result.Connected := True;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TFrameDataTypes.ArrayStringTest(const AMethodName: String): String;
var
  Array1, Array2: TArrayString;
  QBuilder: TQueryBuilder;
  SQL: TQuery;
  DB: TConnection;
begin
  DB := nil;
  DB := GetDBConnection;
  try
    QBuilder := TQueryBuilder.ForConnection(DB.GetConnectionStrategy);
    Array1 := TArrayString.Create();
    try
      Array1.Clear;
      if AMethodName <> 'Fetch' then
      begin
        SQL := QBuilder.View('SELECT * FROM test_fields');
        Array1['field_inc']       := SQL.Query.FieldByName('field_inc').Value;
        Array1['field_int']       := SQL.Query.FieldByName('field_int').Value;
        Array1['field_char']      := SQL.Query.FieldByName('field_char').Value;
        Array1['field_varchar']   := SQL.Query.FieldByName('field_varchar').Value;
        Array1['field_date']      := SQL.Query.FieldByName('field_date').Value;
        Array1['field_datetime']  := SQL.Query.FieldByName('field_datetime').Value;
        Array1['field_decimal']   := SQL.Query.FieldByName('field_decimal').Value;
        Array1['field_float']     := SQL.Query.FieldByName('field_float').Value;
        Array1['field_null']      := System.StrUtils.IfThen(SQL.Query.FieldByName('field_null').Value = NULL, 'null', SQL.Query.FieldByName('field_null').Value);
      end;

      case AnsiIndexStr(AMethodName, Methods) of
        0: begin
          QBuilder.FetchOne('SELECT * FROM test_fields', Array1);
          Result := Array1.ToList(True);
        end;
        1: begin
          Array2 := TArrayString.Create;
          Array2.Clear;
          Array2['field_copied'] := 'field_copied';
          Array2.Assign(Array1);
          Result := Array2.ToList(True);
          FreeAndNil(Array2);
        end;
        2: begin
          Array2 := TArrayString.Create(Array1);
          Result := Array2.ToList(True);
          FreeAndNil(Array2);
        end;
        3: Result := Array1.ToList(True);
        4: Result := Array1.ToTags(True);
        5: Result := Array1.ToXML(True);
        6: Result := Array1.ToJSON(True);
      end;
    finally
      FreeAndNil(Array1);
    end;
  finally
    FreeAndNil(DB);
  end;
end;

function TFrameDataTypes.ArrayVariantTest(const AMethodName: String): String;
var
  Array1, Array2: TArrayVariant;
  QBuilder: TQueryBuilder;
  SQL: TQuery;
  DB: TConnection;
begin
  DB := nil;
  DB := GetDBConnection;
  try
    QBuilder := TQueryBuilder.ForConnection(DB.GetConnectionStrategy);
    Array1 := TArrayVariant.Create;
    try
      Array1.Clear;
      if AMethodName <> 'Fetch' then
      begin
        SQL := QBuilder.View('SELECT * FROM test_fields');
        Array1['field_inc']      := SQL.Query.FieldByName('field_inc').Value;
        Array1['field_int']      := SQL.Query.FieldByName('field_int').Value;
        Array1['field_char']     := SQL.Query.FieldByName('field_char').Value;
        Array1['field_varchar']  := SQL.Query.FieldByName('field_varchar').Value;
        Array1['field_date']     := SQL.Query.FieldByName('field_date').Value;
        Array1['field_datetime'] := SQL.Query.FieldByName('field_datetime').Value;
        Array1['field_decimal']  := SQL.Query.FieldByName('field_decimal').Value;
        Array1['field_float']    := SQL.Query.FieldByName('field_float').Value;
        Array1['field_null']     := SQL.Query.FieldByName('field_null').Value;
      end;

      case AnsiIndexStr(AMethodName, Methods) of
        0: begin
          QBuilder.FetchOne('SELECT * FROM test_fields', Array1);
          Result := Array1.ToList(True);
        end;
        1: begin
          Array2 := TArrayVariant.Create;
          Array2.Clear;
          Array2['field_copied'] := 'field_copied';
          Array2.Assign(Array1);
          Result := Array2.ToList(True);
          FreeAndNil(Array2);
        end;
        2: begin
          Array2 := TArrayVariant.Create(Array1);
          Result := Array2.ToList(True);
          FreeAndNil(Array2);
        end;
        3: Result := Array1.ToList(True);
        4: Result := Array1.ToTags(True);
        5: Result := Array1.ToXML(True);
        6: Result := Array1.ToJSON(True);
      end;
    finally
      FreeAndNil(Array1);
    end;
  finally
    FreeAndNil(DB);
  end;
end;

function TFrameDataTypes.ArrayFieldTest(const AMethodName: String): String;
var
  Array1, Array2: TArrayField;
  Array3: TArrayVariant;
  QBuilder: TQueryBuilder;
  SQL: TQuery;
  DB: TConnection;
begin
  DB := nil;
  DB := GetDBConnection;
  try
    QBuilder := TQueryBuilder.ForConnection(DB.GetConnectionStrategy);
    Array1 := TArrayField.Create;
    try
      Array1.Clear;
      if AMethodName <> 'Fetch' then
      begin
        SQL := QBuilder.View('SELECT * FROM test_fields');
        Array1['field_inc']      := SQL.Query.FieldByName('field_inc');
        Array1['field_int']      := SQL.Query.FieldByName('field_int');
        Array1['field_char']     := SQL.Query.FieldByName('field_char');
        Array1['field_varchar']  := SQL.Query.FieldByName('field_varchar');
        Array1['field_date']     := SQL.Query.FieldByName('field_date');
        Array1['field_datetime'] := SQL.Query.FieldByName('field_datetime');
        Array1['field_decimal']  := SQL.Query.FieldByName('field_decimal');
        Array1['field_float']    := SQL.Query.FieldByName('field_float');
        Array1['field_null']     := SQL.Query.FieldByName('field_null');
      end;

      case AnsiIndexStr(AMethodName, Methods) of
        0: begin
          QBuilder.FetchOne('SELECT * FROM test_fields', Array1);
          Result := Array1.ToList(True);
        end;
        1: begin
          Array3 := TArrayVariant.Create;
          Array3.Clear;
          Array3['field_cloned'] := 'cloned_field';
          Array3.Assign(Array1);
          Result := Array3.ToList(True);
          FreeAndNil(Array3);
        end;
        2: begin
          Array2 := TArrayField.Create(Array1);
          Result := Array2.ToList(True);
          FreeAndNil(Array2);
        end;
        3: Result := Array1.ToList(True);
        4: Result := Array1.ToTags(True);
        5: Result := Array1.ToXML(True);
        6: Result := Array1.ToJSON(True);
      end;
    finally
      FreeAndNil(Array1);
    end;
  finally
    FreeAndNil(DB);
  end;
end;

procedure TFrameDataTypes.ComboBoxDataTypeTArrayStringChange(Sender: TObject);
begin
  try
    MemoDataTypeArrayResult.Text := ArrayStringTest(TComboBox(Sender).Selected.Text);
  except
    on E: Exception do
      MemoDataTypeArrayResult.Text := 'Error: ' + E.Message;
  end;
end;

procedure TFrameDataTypes.ComboBoxDataTypeTArrayVariantChange(Sender: TObject);
begin
  try
    MemoDataTypeArrayResult.Text := ArrayVariantTest(TComboBox(Sender).Selected.Text);
  except
    on E: Exception do
      MemoDataTypeArrayResult.Text := 'Error: ' + E.Message;
  end;
end;

procedure TFrameDataTypes.ComboBoxDataTypeTArrayFieldChange(Sender: TObject);
begin
  try
    MemoDataTypeArrayResult.Text := ArrayFieldTest(TComboBox(Sender).Selected.Text);
  except
    on E: Exception do
      MemoDataTypeArrayResult.Text := 'Error: ' + E.Message;
  end;
end;

procedure TFrameDataTypes.FormatExplicitClick(Sender: TObject);
const
  SEP = '------------------------------------------------------------------------';
begin
  MemoResultFormat.Lines.Clear;
  MemoResultFormat.Lines.Append('Original: ' + EditLength1.Text + ' | Result: ' +
    TFloat.ToString(EditLength1.Text, StrToIntDef(EditDecimal1.Text, 2), TResultMode(ComboBoxResult1.ItemIndex)));
  MemoResultFormat.Lines.Append(SEP);
  MemoResultFormat.Lines.Append('Original: ' + EditLength2.Text + ' | Result: ' +
    TFloat.ToString(EditLength2.Text, StrToIntDef(EditDecimal2.Text, 3), TResultMode(ComboBoxResult2.ItemIndex)));
  MemoResultFormat.Lines.Append(SEP);
  MemoResultFormat.Lines.Append('Original: ' + EditLength3.Text + ' | Result: ' +
    TFloat.ToString(EditLength3.Text, StrToIntDef(EditDecimal3.Text, 4)));
  MemoResultFormat.Lines.Append(SEP);
  MemoResultFormat.Lines.Append('Original: ' + EditLength4.Text + ' | Result: ' +
    TFloat.ToString(EditLength4.Text, StrToIntDef(EditDecimal4.Text, 2)));
  MemoResultFormat.Lines.Append(SEP);
  MemoResultFormat.Lines.Append('Original: ' + EditLength5.Text + ' | Result: ' +
    TFloat.ToString(EditLength5.Text, StrToIntDef(EditDecimal5.Text, 5)));
end;

procedure TFrameDataTypes.FormatImplicitClick(Sender: TObject);
const
  SEP = '------------------------------------------------------------------------';
begin
  MemoResultFormat.Lines.Clear;
  MemoResultFormat.Lines.Append('Original: ' + EditLength1.Text + ' | Result: ' + TFloat.ToString(EditLength1.Text));
  MemoResultFormat.Lines.Append(SEP);
  MemoResultFormat.Lines.Append('Original: ' + EditLength2.Text + ' | Result: ' + TFloat.ToString(EditLength2.Text));
  MemoResultFormat.Lines.Append(SEP);
  MemoResultFormat.Lines.Append('Original: ' + EditLength3.Text + ' | Result: ' + TFloat.ToString(EditLength3.Text));
  MemoResultFormat.Lines.Append(SEP);
  MemoResultFormat.Lines.Append('Original: ' + EditLength4.Text + ' | Result: ' + TFloat.ToString(EditLength4.Text));
  MemoResultFormat.Lines.Append(SEP);
  MemoResultFormat.Lines.Append('Original: ' + EditLength5.Text + ' | Result: ' + TFloat.ToString(EditLength5.Text));
end;

procedure TFrameDataTypes.CalculateClick(Sender: TObject);
const
  SEP = '------------------------------------------------------------------------';
begin
  MemoResultCalculate.Lines.Clear;
  MemoResultCalculate.Lines.Append(
    'ToCurrency: ' + TFloat.ToString(EditCalculate1.Text) + ' * ' + TFloat.ToString(EditAmount1.Text) +
    ' | Truncate: ' + TFloat.ToString(CurrToStr(TFloat.ToCurrency(EditCalculate1.Text) * TFloat.ToCurrency(EditAmount1.Text)), 4, TResultMode.Truncate) +
    ' | Round: '   + TFloat.ToString(CurrToStr(TFloat.ToCurrency(EditCalculate1.Text) * TFloat.ToCurrency(EditAmount1.Text)), 4, TResultMode.Round));
  MemoResultCalculate.Lines.Append(SEP);
  MemoResultCalculate.Lines.Append(
    'ToDouble:   ' + TFloat.ToString(EditCalculate2.Text) + ' * ' + TFloat.ToString(EditAmount2.Text) +
    ' | Truncate: ' + TFloat.ToString(FloatToStr(TFloat.ToDouble(EditCalculate2.Text) * TFloat.ToDouble(EditAmount2.Text)), 4, TResultMode.Truncate) +
    ' | Round: '   + TFloat.ToString(FloatToStr(TFloat.ToDouble(EditCalculate2.Text) * TFloat.ToDouble(EditAmount2.Text)), 4, TResultMode.Round));
  MemoResultCalculate.Lines.Append(SEP);
  MemoResultCalculate.Lines.Append(
    'ToExtended: ' + TFloat.ToString(EditCalculate3.Text) + ' * ' + TFloat.ToString(EditAmount3.Text) +
    ' | Truncate: ' + TFloat.ToString(FloatToStr(TFloat.ToExtended(EditCalculate3.Text) * TFloat.ToExtended(EditAmount3.Text)), 4, TResultMode.Truncate) +
    ' | Round: '   + TFloat.ToString(FloatToStr(TFloat.ToExtended(EditCalculate3.Text) * TFloat.ToExtended(EditAmount3.Text)), 4, TResultMode.Round));
  MemoResultCalculate.Lines.Append(SEP);
  MemoResultCalculate.Lines.Append(
    'ToMoney:    ' + TFloat.ToString(EditCalculate4.Text) + ' * ' + TFloat.ToString(EditAmount4.Text) +
    ' | Truncate: ' + TFloat.ToMoney(FloatToStr(TFloat.ToCurrency(EditCalculate4.Text) * TFloat.ToCurrency(EditAmount4.Text)), 4, TResultMode.Truncate) +
    ' | Round: '   + TFloat.ToMoney(FloatToStr(TFloat.ToCurrency(EditCalculate4.Text) * TFloat.ToCurrency(EditAmount4.Text)), 4, TResultMode.Round));
  MemoResultCalculate.Lines.Append(SEP);
  MemoResultCalculate.Lines.Append(
    'ToSQL:      ' + TFloat.ToString(EditCalculate5.Text) + ' * ' + TFloat.ToString(EditAmount5.Text) +
    ' | Truncate: ' + TFloat.ToSQL(FloatToStr(TFloat.ToCurrency(EditCalculate5.Text) * TFloat.ToCurrency(EditAmount5.Text)), 4, TResultMode.Truncate) +
    ' | Round: '   + TFloat.ToSQL(FloatToStr(TFloat.ToCurrency(EditCalculate5.Text) * TFloat.ToCurrency(EditAmount5.Text)), 4, TResultMode.Round));
end;

end.
