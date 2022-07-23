﻿unit QueryBuilder;

interface

{ Carrega a Interface Padrão }
{$I CNX.Default.inc}

uses
  System.SysUtils,
  System.IOUtils,
  System.StrUtils,
  System.DateUtils,
  System.Classes,
  System.Math,

  System.SyncObjs,
  System.Threading,
  System.Generics.Collections,
  System.RTLConsts,
  System.Variants,
  System.JSON,
  System.RTTI,
  System.TypInfo,
  System.NetEncoding,

  Data.DBConsts,
  Data.DB,
  Data.FMTBcd,
  Data.SqlExpr,
  Data.SqlTimSt,
  Data.DBCommonTypes,

  FMX.Types,
  FMX.Forms,
  FMX.Grid,
  FMX.ComboEdit,
  FMX.ListBox,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.SearchBox,
  FMX.StdCtrls,

  FMX.Dialogs,

  Datasnap.DBClient,
  Datasnap.Provider,

  {dbExpress}
{$IFDEF dbExpressLib}
  Data.DBXSqlite,
{$IFDEF MSWINDOWS}
  Data.DBXMySql,
  Data.DBXMSSQL,
  Data.DBXFirebird,
  Data.DBXInterBase,
{$IFDEF DBXDevartLib}
  DBXDevartPostgreSQL,
  DBXDevartOracle,
{$ENDIF}
{$ENDIF}
{$ENDIF}
  {ZeOSLib}
{$IFDEF MSWINDOWS}
{$IFDEF ZeOSLib}
  ZAbstractConnection,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  ZConnection,
  ZAbstractTable,
  ZDbcConnection,
  ZClasses,
  ZDbcIntfs,
  ZTokenizer,
  ZCompatibility,
  ZGenericSqlToken,
  ZGenericSqlAnalyser,
  ZPlainDriver,
  ZURL,
  ZCollections,
  ZVariant,
{$ENDIF}
{$ENDIF}
  {FireDAC}
{$IFDEF FireDACLib}
  FireDAC.DatS,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.UI,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Stan.Param,
  FireDAC.Stan.ExprFuncs,
  FireDAC.UI.Intf,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  FireDAC.Phys.FB,
  FireDAC.Phys.IBWrapper,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.Oracle,
  FireDAC.Phys.OracleDef,
{$ENDIF}

  Float,
  Strings,
  MimeType,
  ArrayString,
  ArrayStringHelper,
  ArrayVariant,
  ArrayVariantHelper,
  ArrayField,
  ArrayFieldHelper,
  ArrayAssoc,
  Query,
  QueryHelper,

  System.Types,
{$IFDEF MSWINDOWS}
  Winapi.Windows,
  Winapi.Messages,
  FMX.Platform.Win,
{$ELSE}
  System.ByteStrings,
  FMX.Platform.Android,
  FMX.Helpers.Android,
{$ENDIF}
  System.UITypes;

  { Record TQueryBuilder para Criação de Consultas para a Classe TQuery }
type
  TQueryBuilder = record
  const
    FieldTypes: Array [TFieldType] of String = ('ftUnknown', 'ftString', 'ftSmallint', 'ftInteger', 'ftWord', 'ftBoolean', 'ftFloat', 'ftCurrency', 'ftBCD', 'ftDate', 'ftTime', 'ftDateTime', 'ftBytes', 'ftVarBytes', 'ftAutoInc', 'ftBlob', 'ftMemo', 'ftGraphic', 'ftFmtMemo', 'ftParadoxOle', 'ftDBaseOle', 'ftTypedBinary', 'ftCursor', 'ftFixedChar', 'ftWideString', 'ftLargeint', 'ftADT', 'ftArray', 'ftReference', 'ftDataSet', 'ftOraBlob', 'ftOraClob', 'ftVariant', 'ftInterface', 'ftIDispatch', 'ftGuid', 'ftTimeStamp', 'ftFMTBcd', 'ftFixedWideChar', 'ftWideMemo', 'ftOraTimeStamp', 'ftOraInterval', 'ftLongWord', 'ftShortint', 'ftByte', 'ftExtended', 'ftConnection', 'ftParams', 'ftStream', 'ftTimeStampOffset', 'ftObject', 'ftSingle');
    ReservedWords: Array of String = ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP'];
  strict private
    { Strict Private declarations }
    function ReservedWord<T: Class>(Value : String; Helper: String): String; overload;
    function ReservedWord<T: Class>(Key: String; Value : String; Helper: String): String; overload;
    procedure InsertToStr<T: Class>(Columns: T; out FieldsStr: String; out ValuesStr: String);
    procedure UpdateToStr<T: Class>(Columns: T; out ValuesStr: String);
    procedure ReplaceToStr<T: Class>(Columns: T; out ValuesStr: String);
    procedure FiltersToStr<T: Class>(Columns: T; out ValuesStr: String);
  private
    { Private declarations }
    function Query(Input: String; Mode: Boolean = False) : TQuery;
    function FetchOne<T: Class>(Input : String; out &Array: T): TQuery; overload;
    function FetchAll<T: Class>(Input : String; out &Array: T): TQuery; overload;
    function Insert<T: Class>(Table: String; Columns: T; Run: Boolean = False; Ignore: Boolean = False): String; overload;
    function Update<T: Class>(Table: String; Columns: T; Run: Boolean = False): String; overload;
    function Update<T: Class; F: Class>(Table: String; Columns: T; Filters: F; Run: Boolean = False): String; overload;
    function Replace<T: Class>(Table: String; Columns: T; Run: Boolean = False): String; overload;
    function Replace<T: Class; F: Class>(Table: String; Columns: T; Filters: F; Run: Boolean = False): String; overload;
    function Upsert<T: Class>(Table: String; Columns: T; Run: Boolean = False; Ignore: Boolean = False; Duplicate: Boolean = False): String; overload;
    function Delete<T: Class>(Table: String; Run: Boolean = False): String; overload;
    function Delete<T: Class>(Table: String; Filters: T; Run: Boolean = False) : String; overload;
  public
    { Public declarations }
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    function View(Input: String; const Mode: Boolean = False): TQuery;
    function Exec(Input: String; const Mode: Boolean = True): TQuery;
    function ToJSON(Input: String; Prettify : Boolean = False): String;
    function ToXML(Input: String; Prettify : Boolean = False): String;
    function FetchOne(Input: String; out &Array: TArrayString): TQuery; overload;
    function FetchOne(Input: String; out &Array: TArrayVariant): TQuery; overload;
    function FetchOne(Input: String; out &Array: TArrayField): TQuery; overload;
    function FetchAll(Input: String; out &Array: TArrayAssoc): TQuery; overload;
    function Insert(Table: String; Columns: TArrayString; Run: Boolean = False; Ignore: Boolean = False): String; overload;
    function Insert(Table: String; Columns: TArrayVariant; Run: Boolean = False; Ignore: Boolean = False): String; overload;
    function Insert(Table: String; Columns: TArrayField; Run: Boolean = False; Ignore: Boolean = False): String; overload;
    //function Insert(Table: String; Columns: TArrayAssoc; Run: Boolean = False; Ignore: Boolean = False): String; overload;
    function Update(Table: String; Columns: TArrayString; Run: Boolean = False): String; overload;
    function Update(Table: String; Columns: TArrayVariant; Run: Boolean = False) : String; overload;
    function Update(Table: String; Columns: TArrayField; Run: Boolean = False) : String; overload;
    //function Update(Table: String; Columns: TArrayAssoc; Run: Boolean = False) : String; overload;
    function Update(Table: String; Columns: TArrayString; Filters: TArrayString; Run: Boolean = False): String; overload;
    function Update(Table: String; Columns: TArrayVariant; Filters: TArrayVariant; Run: Boolean = False): String; overload;
    function Update(Table: String; Columns: TArrayField; Filters: TArrayVariant; Run: Boolean = False): String; overload;
    //function Update(Table: String; Columns: TArrayAssoc; Filters: TArrayVariant; Run: Boolean = False): String; overload;
    function Replace(Table: String; Columns: TArrayString; Run: Boolean = False) : String; overload;
    function Replace(Table: String; Columns: TArrayVariant; Run: Boolean = False) : String; overload;
    function Replace(Table: String; Columns: TArrayField; Run: Boolean = False) : String; overload;
    //function Replace(Table: String; Columns: TArrayAssoc; Run: Boolean = False) : String; overload;
    function Replace(Table: String; Columns: TArrayString; Filters: TArrayString; Run: Boolean = False): String; overload;
    function Replace(Table: String; Columns: TArrayVariant; Filters: TArrayVariant; Run: Boolean = False): String; overload;
    function Replace(Table: String; Columns: TArrayField; Filters: TArrayVariant; Run: Boolean = False): String; overload;
    //function Replace(Table: String; Columns: TArrayAssoc; Filters: TArrayVariant; Run: Boolean = False): String; overload;
    function Upsert(Table: String; Columns: TArrayString; Run: Boolean = False; Ignore: Boolean = False; Duplicate: Boolean = False): String; overload;
    function Upsert(Table: String; Columns: TArrayVariant; Run: Boolean = False; Ignore: Boolean = False; Duplicate: Boolean = False): String; overload;
    function Upsert(Table: String; Columns: TArrayField; Run: Boolean = False; Ignore: Boolean = False; Duplicate: Boolean = False): String; overload;
    //function Upsert(Table: String; Columns: TArrayAssoc; Run: Boolean = False; Ignore: Boolean = False; Duplicate: Boolean = False): String; overload;
    function Delete(Table: String; Run: Boolean = False): String; overload;
    function Delete(Table: String; Filters: TArrayString; Run: Boolean = False) : String; overload;
    function Delete(Table: String; Filters: TArrayVariant; Run: Boolean = False): String; overload;
  end;

implementation

{ TQueryBuilder }

function TQueryBuilder.Query(Input: String; Mode: Boolean = False): TQuery;
var
  SQL: TQuery;
begin
  SQL := TQuery.Create;
  SQL.Query.Close;
  SQL.Query.SQL.Clear;
  SQL.Query.SQL.Text := Input;
  if not Mode then
    SQL.Query.Open
  else
    SQL.Query.ExecSQL;
  Result := SQL;
end;

function TQueryBuilder.FetchOne<T>(Input : String; out &Array: T): TQuery;
var
  I : Integer;
  SQL: TQuery;
  Query: TQueryBuilder;
begin
  SQL := Query.View(Input);
  if not(SQL.Query.IsEmpty) then
  begin
    if (TypeInfo(T) = TypeInfo(TArrayString)) then
      TArrayString(&Array).Clear
    else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
      TArrayVariant(&Array).Clear
    else
      TArrayField(&Array).Clear;
    while not SQL.Query.Eof do // Linhas
    begin
      for I := 0 to SQL.Query.FieldCount - 1 do // Colunas
      begin
        //Showmessage((I+1).ToString + ' ' + SQL.Query.Fields[I].DisplayName + ' ' + FieldTypes[SQL.Query.Fields[I].DataType]);
        if SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).IsNull then
        begin
          if (TypeInfo(T) = TypeInfo(TArrayString)) then
            TArrayString(&Array).AddKeyValue(SQL.Query.Fields[I].DisplayName, NUL)
          else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
            TArrayVariant(&Array).AddKeyValue(SQL.Query.Fields[I].DisplayName, NUL)
          else
            TArrayField(&Array).AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.Fields[I])
        end
        else
        begin
          if (TypeInfo(T) = TypeInfo(TArrayString)) then
            TArrayString(&Array).AddKeyValue(SQL.Query.Fields[I].DisplayName, TArrayVariantHelper.VarToStr(SQL.Query.FieldValues[SQL.Query.Fields[I].DisplayName], EmptyStr, TBinaryMode.Write))
          else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
            TArrayVariant(&Array).AddKeyValue(SQL.Query.Fields[I].DisplayName, TArrayVariantHelper.VarToStr(SQL.Query.FieldValues[SQL.Query.Fields[I].DisplayName], EmptyStr, TBinaryMode.Write))
          else
            TArrayField(&Array).AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.Fields[I])
        end;
      end;
      SQL.Query.Next;
    end;
  end;
  Result := SQL;
end;

function TQueryBuilder.FetchAll<T>(Input : String; out &Array: T): TQuery;
var
  I, J : Integer;
  SQL: TQuery;
  Query: TQueryBuilder;
begin
  SQL := Query.View(Input);
  if not(SQL.Query.IsEmpty) then
  begin
    if (TypeInfo(T) = TypeInfo(TArrayAssoc)) then
      TArrayAssoc(&Array).Clear;
    while not SQL.Query.Eof do // Linhas
    begin
      for I := 0 to SQL.Query.FieldCount - 1 do // Colunas
      begin
        //Showmessage((I+1).ToString + ' ' + SQL.Query.Fields[I].DisplayName + ' ' + FieldTypes[SQL.Query.Fields[I].DataType]);
        if SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).IsNull then
        begin
          if (TypeInfo(T) = TypeInfo(TArrayAssoc)) then
            TArrayAssoc(&Array)[J][SQL.Query.Fields[I].DisplayName].Val := NUL
        end
        else
        begin
          if (TypeInfo(T) = TypeInfo(TArrayAssoc)) then
            TArrayAssoc(&Array)[J][SQL.Query.Fields[I].DisplayName].Val := TArrayVariantHelper.VarToStr(SQL.Query.FieldValues[SQL.Query.Fields[I].DisplayName], EmptyStr, TBinaryMode.Write)
        end;
      end;
      Inc(J);
      SQL.Query.Next;
    end;
  end;
  Result := SQL;
end;

function TQueryBuilder.Insert<T>(Table: String; Columns: T; Run: Boolean = False; Ignore: Boolean = False): String;
var
  I: Integer;
  Query: TQueryBuilder;
  DBFields, DBValues: String;
begin
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
    Self.InsertToStr<TArrayString>(TArrayString(Columns), DBFields, DBValues)
  else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
    Self.InsertToStr<TArrayVariant>(TArrayVariant(Columns), DBFields, DBValues)
  else
    Self.InsertToStr<TArrayField>(TArrayField(Columns), DBFields, DBValues);

  Result := 'INSERT' + (System.StrUtils.IfThen(Ignore = True, ' IGNORE', EmptyStr)) + ' INTO ' + Trim(Table) + ' (' + Trim(DBFields) + ') VALUES (' + Trim(DBValues) + ');';

  if Run then
    Query.Exec(Result);
end;

function TQueryBuilder.Update<T>(Table: String; Columns: T; Run: Boolean = False): String;
var
  I: Integer;
  Query: TQueryBuilder;
  DBValues: String;
begin
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
    Self.UpdateToStr<TArrayString>(TArrayString(Columns), DBValues)
  else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
    Self.UpdateToStr<TArrayVariant>(TArrayVariant(Columns), DBValues)
  else
    Self.UpdateToStr<TArrayField>(TArrayField(Columns), DBValues);

  Result := 'UPDATE ' + Trim(Table) + ' SET ' + Trim(DBValues);

  if Run then
    Query.Exec(Result);
end;

function TQueryBuilder.Update<T, F>(Table: String; Columns: T; Filters: F; Run: Boolean = False): String;
var
  I: Integer;
  Query: TQueryBuilder;
  DBValues, DBFilters: String;
begin
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
    Self.UpdateToStr<TArrayString>(TArrayString(Columns), DBValues)
  else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
    Self.UpdateToStr<TArrayVariant>(TArrayVariant(Columns), DBValues)
  else
    Self.UpdateToStr<TArrayField>(TArrayField(Columns), DBValues);

  if (TypeInfo(F) = TypeInfo(TArrayString)) then
    Self.FiltersToStr<TArrayString>(TArrayString(Filters), DBFilters)
  else
    Self.FiltersToStr<TArrayVariant>(TArrayVariant(Filters), DBFilters);

  Result := 'UPDATE ' + Trim(Table) + ' SET ' + Trim(DBValues) + ' WHERE ' + Trim(DBFilters);

  if Run then
    Query.Exec(Result);
end;

function TQueryBuilder.Delete<T>(Table: String; Run: Boolean = False) : String;
var
  Query: TQueryBuilder;
begin
  Result := 'DELETE FROM ' + Trim(Table);

  if Run then
    Query.Exec(Result);
end;

function TQueryBuilder.Delete<T>(Table: String; Filters: T; Run: Boolean = False) : String;
var
  I : Integer;
  Query: TQueryBuilder;
  DBFilters: String;
begin
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
    Self.FiltersToStr<TArrayString>(TArrayString(Filters), DBFilters)
  else
    Self.FiltersToStr<TArrayVariant>(TArrayVariant(Filters), DBFilters);

  Result := 'DELETE FROM ' + Trim(Table) + ' WHERE ' + Trim(DBFilters);

  if Run then
    Query.Exec(Result);
end;

function TQueryBuilder.Replace<T>(Table: String; Columns: T; Run: Boolean = False): String;
var
  I: Integer;
  Query: TQueryBuilder;
  DBFields, DBValues: String;
begin
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
    Self.InsertToStr<TArrayString>(TArrayString(Columns), DBFields, DBValues)
  else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
    Self.InsertToStr<TArrayVariant>(TArrayVariant(Columns), DBFields, DBValues)
  else
    Self.InsertToStr<TArrayField>(TArrayField(Columns), DBFields, DBValues);

  Result := 'REPLACE INTO ' + Trim(Table) + ' (' + Trim(DBFields) + ') VALUES (' + Trim(DBValues) + ')';

  if Run then
    Query.Exec(Result);
end;

function TQueryBuilder.Replace<T, F>(Table: String; Columns: T; Filters: F; Run: Boolean = False): String;
var
  I: Integer;
  Query: TQueryBuilder;
  DBFields, DBValues, DBFilters: String;
begin
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
    Self.InsertToStr<TArrayString>(TArrayString(Columns), DBFields, DBValues)
  else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
    Self.InsertToStr<TArrayVariant>(TArrayVariant(Columns), DBFields, DBValues)
  else
    Self.InsertToStr<TArrayField>(TArrayField(Columns), DBFields, DBValues);

  if (TypeInfo(F) = TypeInfo(TArrayString)) then
    Self.FiltersToStr<TArrayString>(TArrayString(Filters), DBFilters)
  else
    Self.FiltersToStr<TArrayVariant>(TArrayVariant(Filters), DBFilters);

  Result := 'REPLACE INTO ' + Trim(Table) + ' (' + Trim(DBFields) + ') VALUES (' + Trim(DBValues) + ')' + ' WHERE ' + Trim(DBFilters);

  if Run then
    Query.Exec(Result);
end;

function TQueryBuilder.Upsert<T>(Table: String; Columns: T; Run: Boolean = False; Ignore: Boolean = False; Duplicate: Boolean = False): String;
var
  I: Integer;
  Query: TQueryBuilder;
  DBFields, DBValues, DBReplaces: String;
begin
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
    Self.InsertToStr<TArrayString>(TArrayString(Columns), DBFields, DBValues)
  else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
    Self.InsertToStr<TArrayVariant>(TArrayVariant(Columns), DBFields, DBValues)
  else
    Self.InsertToStr<TArrayField>(TArrayField(Columns), DBFields, DBValues);

  if (TypeInfo(T) = TypeInfo(TArrayString)) then
    Self.ReplaceToStr<TArrayString>(TArrayString(Columns), DBReplaces)
  else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
    Self.ReplaceToStr<TArrayVariant>(TArrayVariant(Columns), DBReplaces)
  else
    Self.ReplaceToStr<TArrayField>(TArrayField(Columns), DBReplaces);

  Result := 'INSERT' + (System.StrUtils.IfThen(Ignore = True, ' IGNORE', EmptyStr)) + ' INTO ' + Trim(Table) + ' (' + Trim(DBFields) + ') VALUES (' + Trim(DBValues) + ')' + Trim(DBReplaces);

  if Run then
    Query.Exec(Result);
end;

function TQueryBuilder.View(Input: String; const Mode: Boolean = False): TQuery;
begin
  Result := Self.Query(Input, Mode);
end;

function TQueryBuilder.Exec(Input: String; const Mode: Boolean = True): TQuery;
begin
  Result := Self.Query(Input, Mode);
end;

function TQueryBuilder.ToJSON(Input: String; Prettify : Boolean = False): String;
var
  SQL: TQuery;
  JSONObject: TJSONObject;
  JSONArray: TJSONArray;
  I: Integer;
  CollumnName, CollumnValue: String;
begin
  JSONArray := TJSONArray.Create;
  SQL := Self.Query(Input, False);
  with SQL.Query do
  begin
    if (RecordCount > 0) then
    begin
      while not Eof do
      begin
        JSONObject := TJSONObject.Create;
        for I := 0 to FieldDefs.Count - 1 do
        begin
          CollumnName := FieldDefs[I].Name;
          CollumnValue := FieldByName(CollumnName).AsString;
          JSONObject.AddPair(TJSONPair.Create(TJSONString.Create(CollumnName), TJSONString.Create(CollumnValue)));
        end;
        JSONArray.Add(JSONObject);
        Next;
      end;
      Result := JSONArray.ToString;
    end
    else
      Result := '';
  end;
end;

function TQueryBuilder.ToXML(Input: String; Prettify : Boolean = False): String;
var
  S1, S2: String;
  SQL: TQuery;
  I, J: Integer;
  RowData, CollumnData: String;
  CollumnName, CollumnValue: String;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  S2 := System.StrUtils.IfThen(Prettify, DSpace, EmptyStr);
  RowData := EmptyStr;
  SQL := Self.Query(Input, False);
  with SQL.Query do
  begin
    if (RecordCount > 0) then
    begin
      J := 0;
      while not Eof do
      begin
        RowData := RowData + LTag + 'node row="' + J.ToString + '"' + RTag + S1;
        CollumnData := EmptyStr;
        for I := 0 to FieldDefs.Count - 1 do
        begin
          CollumnName := FieldDefs[I].Name;
          CollumnValue := FieldByName(CollumnName).AsString;
          CollumnData := CollumnData + TString.IndentTag(LTag + CollumnName + RTag + CollumnValue + CTag + CollumnName + RTag + S1, S2);
        end;
        RowData := RowData + CollumnData;
        RowData := RowData + CTag + 'node' + RTag;
        Inc(J);
        Next;
      end;
      Result := Result + XML + S1;
      Result := Result + LTag + 'root' + RTag + S1;
      Result := Result + TString.IndentTag(RowData + S1, S2);
      Result := Result + CTag + 'root' + RTag;
    end
    else
      Result := EmptyStr;
  end;
end;

procedure TQueryBuilder.StartTransaction;
begin
  Self.Query('START TRANSACTION', True);
end;

procedure TQueryBuilder.Commit;
begin
  Self.Query('COMMIT', True);
end;

procedure TQueryBuilder.Rollback;
begin
  Self.Query('ROLLBACK', True);
end;

function TQueryBuilder.ReservedWord<T>(Value : String; Helper: String): String;
begin
  case AnsiIndexStr(UpperCase(String(Value)), ReservedWords) of
    0 .. 5: Result := Result + COMMA + Value
  else
    Result := Result + COMMA + Helper;
  end;
end;

function TQueryBuilder.ReservedWord<T>(Key : String; Value : String; Helper: String): String;
begin
  case AnsiIndexStr(UpperCase(String(Value)), ReservedWords) of
    0 .. 5: Result := Result + COMMA + Key + SSPACE + EQUAL + SSPACE + Value
  else
    Result := Result + COMMA + Key + SSPACE + EQUAL + SSPACE + Helper;
  end;
end;

procedure TQueryBuilder.InsertToStr<T>(Columns: T; out FieldsStr: String; out ValuesStr: String);
var
  I : Integer;
begin
  FieldsStr := EmptyStr;
  ValuesStr := EmptyStr;
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
  begin
    for I := 0 to TArrayString(Columns).Count - 1 do
    begin
      FieldsStr := FieldsStr + COMMA + TArrayString(Columns).Names[I] + EmptyStr;
      ValuesStr := Self.ReservedWord<TArrayString>(TArrayString(Columns).ValuesAtIndex[I], TArrayStringHelper.StrToStr(TString.RealEscapeStrings(TArrayString(Columns).ValuesAtIndex[I]), SQUOTE));
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
  begin
    for I := 0 to TArrayVariant(Columns).Count - 1 do
    begin
      FieldsStr := FieldsStr + COMMA + TArrayVariant(Columns).Key[I] + EmptyStr;
      ValuesStr := Self.ReservedWord<TArrayVariant>(TArrayVariant(Columns).ValuesAtIndex[I], TArrayVariantHelper.VarToStr(TString.RealEscapeStrings(TArrayVariant(Columns).ValuesAtIndex[I]), SQUOTE, TBinaryMode.Write));
    end;
  end
  else
  begin
    for I := 0 to TArrayField(Columns).Count - 1 do
    begin
      FieldsStr := FieldsStr + COMMA + TArrayField(Columns).Key[I] + EmptyStr;
      ValuesStr := Self.ReservedWord<TArrayField>(TArrayField(Columns).ValuesAtIndex[I].AsString, TArrayVariantHelper.VarToStr(TString.RealEscapeStrings(TArrayField(Columns).ValuesAtIndex[I].AsVariant), SQUOTE, TBinaryMode.Write));
    end;
  end;
  System.Delete(FieldsStr, 1, 1);
  System.Delete(ValuesStr, 1, 1);
end;

procedure TQueryBuilder.UpdateToStr<T>(Columns: T; out ValuesStr: String);
var
  I : Integer;
begin
  ValuesStr := EmptyStr;
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
    for I := 0 to TArrayString(Columns).Count - 1 do
      ValuesStr := Self.ReservedWord<TArrayString>(TArrayString(Columns).Names[I], TArrayString(Columns).ValuesAtIndex[I], TArrayStringHelper.StrToStr(TString.RealEscapeStrings(TArrayString(Columns).ValuesAtIndex[I]), SQUOTE))
  else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
    for I := 0 to TArrayVariant(Columns).Count - 1 do
      ValuesStr := Self.ReservedWord<TArrayVariant>(TArrayVariant(Columns).Key[I], TArrayVariant(Columns).ValuesAtIndex[I], TArrayVariantHelper.VarToStr(TString.RealEscapeStrings(TArrayVariant(Columns).ValuesAtIndex[I]), SQUOTE, TBinaryMode.Write))
  else
    for I := 0 to TArrayField(Columns).Count - 1 do
      ValuesStr := Self.ReservedWord<TArrayField>(TArrayField(Columns).Key[I], TArrayField(Columns).ValuesAtIndex[I].AsString, TArrayVariantHelper.VarToStr(TString.RealEscapeStrings(TArrayField(Columns).ValuesAtIndex[I].AsVariant), SQUOTE, TBinaryMode.Write));
  System.Delete(ValuesStr, 1, 1);
end;

procedure TQueryBuilder.ReplaceToStr<T>(Columns: T; out ValuesStr: String);
var
  I : Integer;
begin
  ValuesStr := EmptyStr;
  ValuesStr := ' ON DUPLICATE KEY UPDATE';
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
  begin
    for I := 0 to TArrayString(Columns).Count - 1 do
      ValuesStr := ValuesStr + SSPACE + TArrayString(Columns).Names[I] + SSPACE + EQUAL + SSPACE + 'VALUES(' + TArrayString(Columns).Names[I] + '),';
  end
  else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
  begin
    for I := 0 to TArrayVariant(Columns).Count - 1 do
      ValuesStr := ValuesStr + SSPACE + TArrayVariant(Columns).Key[I] + SSPACE + EQUAL + SSPACE + 'VALUES(' + TArrayVariant(Columns).Key[I] + '),';
  end
  else
  begin
    for I := 0 to TArrayField(Columns).Count - 1 do
      ValuesStr := ValuesStr + SSPACE + TArrayField(Columns).Key[I] + SSPACE + EQUAL + SSPACE + 'VALUES(' + TArrayField(Columns).Key[I] + '),';
  end;
  System.Delete(ValuesStr, Length(ValuesStr), 1);
end;

procedure TQueryBuilder.FiltersToStr<T>(Columns: T; out ValuesStr: String);
var
  I : Integer;
begin
  ValuesStr := EmptyStr;
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
    for I := 0 to TArrayString(Columns).Count - 1 do
      ValuesStr := ValuesStr + TArrayString(Columns).Names[I] + SSPACE + TArrayStringHelper.StrToStr(TArrayString(Columns).ValuesAtIndex[I], SQUOTE) + SSPACE
  else
    for I := 0 to TArrayVariant(Columns).Count - 1 do
      ValuesStr := ValuesStr + TArrayVariant(Columns).Key[I] + SSPACE + TArrayVariantHelper.VarToStr(TArrayVariant(Columns).ValuesAtIndex[I], SQUOTE, TBinaryMode.Read) + SSPACE;
  System.Delete(ValuesStr, Length(ValuesStr), 1);
end;

function TQueryBuilder.FetchOne(Input: String; out &Array: TArrayString) : TQuery;
begin
  Result := Self.FetchOne<TArrayString>(Input, &Array);
end;

function TQueryBuilder.FetchOne(Input: String; out &Array: TArrayVariant) : TQuery;
begin
  Result := Self.FetchOne<TArrayVariant>(Input, &Array);
end;

function TQueryBuilder.FetchOne(Input: String; out &Array: TArrayField) : TQuery;
begin
  Result := Self.FetchOne<TArrayField>(Input, &Array);
end;

function TQueryBuilder.FetchAll(Input: string; out &Array: TArrayAssoc) : TQuery;
begin
  Result := Self.FetchAll<TArrayAssoc>(Input, &Array);
end;

function TQueryBuilder.Insert(Table: String; Columns: TArrayString; Run: Boolean = False; Ignore: Boolean = False): String;
begin
  Result := Self.Insert<TArrayString>(Table, Columns, Run, Ignore);
end;

function TQueryBuilder.Insert(Table: String; Columns: TArrayVariant; Run: Boolean = False; Ignore: Boolean = False): String;
begin
  Result := Self.Insert<TArrayVariant>(Table, Columns, Run, Ignore);
end;

function TQueryBuilder.Insert(Table: String; Columns: TArrayField; Run: Boolean = False; Ignore: Boolean = False): String;
begin
  Result := Self.Insert<TArrayField>(Table, Columns, Run, Ignore);
end;

function TQueryBuilder.Update(Table: String; Columns: TArrayString; Run: Boolean = False): String;
begin
  Result := Self.Update<TArrayString>(Table, Columns, Run);
end;

function TQueryBuilder.Update(Table: String; Columns: TArrayVariant; Run: Boolean = False): String;
begin
  Result := Self.Update<TArrayVariant>(Table, Columns, Run);
end;

function TQueryBuilder.Update(Table: String; Columns: TArrayField; Run: Boolean = False): String;
begin
  Result := Self.Update<TArrayField>(Table, Columns, Run);
end;

function TQueryBuilder.Update(Table: String; Columns: TArrayString; Filters: TArrayString; Run: Boolean = False): String;
begin
  Result := Self.Update<TArrayString, TArrayString>(Table, Columns, Filters, Run);
end;

function TQueryBuilder.Update(Table: String; Columns: TArrayVariant; Filters: TArrayVariant; Run: Boolean = False): String;
begin
  Result := Self.Update<TArrayVariant, TArrayVariant>(Table, Columns, Filters, Run);
end;

function TQueryBuilder.Update(Table: String; Columns: TArrayField; Filters: TArrayVariant; Run: Boolean = False): String;
begin
  Result := Self.Update<TArrayField, TArrayVariant>(Table, Columns, Filters, Run);
end;

function TQueryBuilder.Delete(Table: String; Run: Boolean = False): String;
begin
  Result := Self.Delete<TArrayString>(Table, Run);
end;

function TQueryBuilder.Delete(Table: String; Filters: TArrayString; Run: Boolean = False): String;
begin
  Result := Self.Delete<TArrayString>(Table, Filters, Run);
end;

function TQueryBuilder.Delete(Table: String; Filters: TArrayVariant; Run: Boolean = False): String;
begin
  Result := Self.Delete<TArrayVariant>(Table, Filters, Run);
end;

function TQueryBuilder.Replace(Table: String; Columns: TArrayString; Run: Boolean = False): String;
begin
  Result := Self.Replace<TArrayString>(Table, Columns, Run);
end;

function TQueryBuilder.Replace(Table: String; Columns: TArrayVariant; Run: Boolean = False): String;
begin
  Result := Self.Replace<TArrayVariant>(Table, Columns, Run);
end;

function TQueryBuilder.Replace(Table: String; Columns: TArrayField; Run: Boolean = False): String;
begin
  Result := Self.Replace<TArrayField>(Table, Columns, Run);
end;

function TQueryBuilder.Replace(Table: String; Columns: TArrayString; Filters: TArrayString; Run: Boolean = False): String;
begin
  Result := Self.Replace<TArrayString, TArrayString>(Table, Columns, Filters, Run);
end;

function TQueryBuilder.Replace(Table: String; Columns: TArrayVariant; Filters: TArrayVariant; Run: Boolean = False): String;
begin
  Result := Self.Replace<TArrayVariant, TArrayVariant>(Table, Columns, Filters, Run);
end;

function TQueryBuilder.Replace(Table: String; Columns: TArrayField; Filters: TArrayVariant; Run: Boolean = False): String;
begin
  Result := Self.Replace<TArrayField, TArrayVariant>(Table, Columns, Filters, Run);
end;

function TQueryBuilder.Upsert(Table: String; Columns: TArrayString; Run: Boolean = False; Ignore: Boolean = False; Duplicate: Boolean = False): String;
begin
  Result := Self.Upsert<TArrayString>(Table, Columns, Run, Ignore, Duplicate);
end;

function TQueryBuilder.Upsert(Table: String; Columns: TArrayVariant; Run: Boolean = False; Ignore: Boolean = False; Duplicate: Boolean = False): String;
begin
  Result := Self.Upsert<TArrayVariant>(Table, Columns, Run, Ignore, Duplicate);
end;

function TQueryBuilder.Upsert(Table: String; Columns: TArrayField; Run: Boolean = False; Ignore: Boolean = False; Duplicate: Boolean = False): String;
begin
  Result := Self.Upsert<TArrayField>(Table, Columns, Run, Ignore, Duplicate);
end;

end.
