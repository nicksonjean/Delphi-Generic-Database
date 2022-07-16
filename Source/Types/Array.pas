{
  &Array.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a cria��o de matrizes php-like em Delphi.
  Suporta 1 Tipo de Matriz Associativa Unidimensional Baseada em TStringList;
  Suporta 2 Tipos de Matrizes Associativas Unidimensionais Baseadas em TDicionary;
  Suporte 2 Tipos de Matrizes Associativas Multidimensional Baseadas em TDicionary;
  1 - Matriz de Strings Herdada de TStringList;
  2 - Matriz de Variants Herdada de TDictionary<Variant, Variant>
  3 - Matriz de Fields Herdade de TDictionay<Variant, TField>
  4 - Matriz de Matrizes Herdada de TDicionary<TDictionay<Variant, Variant>>
  5 - Matriz de Matrizes Herdada de TDicionary<TDictionay<Variant, TField>>
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  Colaborador : Ramon Ruan
  ------------------------------------------------------------------------------
  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la
  sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a vers�o 3.29 da Licen�a, ou (a seu crit�rio)
  qualquer vers�o posterior.
  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM
  NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU
  ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor
  do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)
  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto
  com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,
  no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Voc� tamb�m pode obter uma copia da licen�a em:
  http://www.opensource.org/licenses/lgpl-license.php
}

unit &Array;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections,
  System.RegularExpressions,
  System.RTLConsts,
  System.StrUtils,
  System.Variants,
  System.Rtti,
  System.NetEncoding,

  FMX.Dialogs,

  MimeType,
  Data.DB,
  REST.JSON
  ;

{
  TODO 3 -oNickson Jeanmerson -cProgrammer :
  1) Padronizar a Classes TArrayString e TArrayVariant; //OK
  2) Padronizar a Classe TArrayField;
  3) Criar M�todos Ausentes;
}

type
  TArrayString = class(TStringList)
  private
    { Private declarations }
    function GetKey(Index: Integer): String;
    function GetValues(Index: String): string;
    function GetValuesAtIndex(Index: Integer): string;
    procedure SetValues(Index: String; Const Value: String);
    function GetItem(Index: String): String;
    procedure SetItem(Index: String; Const Value: String);
    procedure DoCopy(Collection: TArrayString = nil);
  public
    { Public declarations }
    constructor Create(Collection: TArrayString = nil);
    destructor Destroy; override;
    procedure Assign(Collection: TArrayString); reintroduce;
    function ToKeys(Prettify : Boolean = False): string;
    function ToValues(Prettify : Boolean = False): string;  
    function ToList(Prettify : Boolean = False): string;
    function ToTags(Prettify : Boolean = False): string;
    function ToXML(Prettify : Boolean = False): string;
    function ToJSON(Prettify : Boolean = False): string;
    procedure Add(Key, Value: string); reintroduce; overload;
    procedure AddKeyValue(Key, Value: string);
    property Key[Index: Integer]: String read GetKey;
    property ValuesAtIndex[Index: Integer]: string read GetValuesAtIndex;
    property Values[Index: string]: string read GetValues write SetValues;
    property Item[Index: string]: string read GetItem write SetItem; default;
  end;

type
  TArrayStringHelper = class(TArrayString)
  private
    { Private declarations }
  public
    { Public declarations }
    class function StrToStr(Value: String; Quote : String = #39): String;
  end;

type
  TArrayVariant = class(TDictionary<Variant, Variant>)
  private
    { Private declarations }
    function GetKey(Index: Integer): String;
    function GetValues(Name: String): Variant;
    function GetValuesAtIndex(Index: Integer): Variant;
    procedure SetValues(Name: String; const Value: Variant);
    function GetItem(Index: String): Variant;
    procedure SetItem(Index: String; const Value: Variant);
    procedure DoCopy<T: Class>(Collection : T);
  public
    { Public declarations }
    constructor Create(Collection: TList<TPair<Variant,Variant>>); overload;
    destructor Destroy; override;
    procedure Assign<T: Class>(Collection : T);
    function ToKeys(Prettify : Boolean = False): string;
    function ToValues(Prettify : Boolean = False): string;
    function ToList(Prettify : Boolean = False): string;
    function ToTags(Prettify : Boolean = False): string;
    function ToXML(Prettify : Boolean = False): string;
    function ToJSON(Prettify : Boolean = False): string;
    procedure Add(Key: String; Value: Variant);
    procedure AddKeyValue(Key: String; Value: Variant);
    property Key[Index: Integer]: String read GetKey;
    property ValuesAtIndex[Index: Integer]: Variant read GetValuesAtIndex;
    property Values[Name: string]: Variant read GetValues write SetValues;
    property Item[Index: String]: Variant read GetItem write SetItem; default;
  end;

type
  TArrayVariantHelper = class(TArrayVariant)
  private
    { Private declarations }
  public
    { Public declarations }
    class function IsNullOrEmpty(Text: Variant): Boolean;
    class function VarToStr(Value: Variant; Quote : String = #39; ReadOrWrite: TBinaryMode = TBinaryMode.Read): String;
  end;

type
  TArrayField = class(TDictionary<Variant, TField>)
  private
    { Private declarations }
    function GetKey(Index: Integer): String;
    function GetValues(Name: String): TField;
    function GetValuesAtIndex(Index: Integer): TField;
    procedure SetValues(Name: String; const Value: TField);
    function GetItem(Index: String): TField;
    procedure SetItem(Index: String; const Value: TField);
  public
    { Public declarations }
    constructor Create(Collection: TList<TPair<Variant,TField>>); overload;
    destructor Destroy; override;
    function ToKeys(Prettify : Boolean = False): string;
    function ToValues(Prettify : Boolean = False): string;
    function ToList(Prettify : Boolean = False): string;
    function ToTags(Prettify : Boolean = False): string;
    function ToXML(Prettify : Boolean = False): string;
    function ToJSON(Prettify : Boolean = False): string;
    procedure Add(Key: String; Value: TField);
    procedure AddKeyValue(Key: String; Value: TField);
    property Key[Index: Integer]: String read GetKey;
    property ValuesAtIndex[Index: Integer]: TField read GetValuesAtIndex;
    property Values[Name: string]: TField read GetValues write SetValues;
    property Item[Index: String]: TField read GetItem write SetItem; default;
  end;

type
  TArrayFieldHelper = class(TArrayField)
  private
    { Private declarations }
  public
    { Public declarations }
    class function FieldToStr(Field: TField): String;
  end;

type
  TArrayAssoc = class
  private
    { Private declarations }
    fVal: Variant;
    fStrict: Boolean;
    fDict: TDictionary<Variant,TArrayAssoc>;
    function GetItem(Index: Variant): TArrayAssoc;
    procedure SetVal(Value: Variant);
    function GetVal:Variant;
  public
    { Public declarations }
    constructor Create(StrictRules: Boolean = False);
    destructor Destroy; override;
    function Add(Index: Variant): TArrayAssoc; overload;
    function Add(Index: Variant; Value: Variant): TArrayAssoc; overload;
    function ToList(Prettify : Boolean = False): String;
    function ToTags(Prettify : Boolean = False): String;
    function ToXML(Prettify : Boolean = False): String;
    function ToJSON(Prettify : Boolean = False): String;
    procedure Clear;
    property Items[Index: Variant]: TArrayAssoc read GetItem; default;
    property Val: Variant read GetVal write SetVal;
    property ToArray: TDictionary<Variant,TArrayAssoc> read fDict;
  end;

type
  TArrayAssocEnum = TPair<Variant, TArrayAssoc>;

implementation

uses
  &String,
  Float,
  TimeDate;

{ TArrayString }

constructor TArrayString.Create(Collection: TArrayString = nil);
begin
  NameValueSeparator := PIPE;
  NullStrictConvert := False;
  if Collection <> nil then
    Self.DoCopy(Collection);
end;

destructor TArrayString.Destroy;
begin
  inherited;
end;

procedure TArrayString.Assign(Collection: TArrayString);
begin
  if Collection <> nil then
    Self.DoCopy(Collection);
end;

procedure TArrayString.DoCopy(Collection: TArrayString);
var
  I: Integer;
begin
  if Collection <> nil then
  begin
    for I := 0 to Collection.Count - 1 do
      Self.Add(Collection.Names[I], Collection.ValuesAtIndex[I]);
  end;
end;

function TArrayString.ToKeys(Prettify : Boolean = False): string;
var
  I: Integer;
  S: String;
begin
  Result := EmptyStr;
  S := System.StrUtils.IfThen(Prettify, Comma + EOL, EOL);
  for I := 0 to Count - 1 do
    Result := Result + Names[I] + S;
  Result := TString.RemoveLastCommaEOL(Result);
end;

function TArrayString.ToValues(Prettify : Boolean = False): string;
var
  I: Integer;
  S: String;
begin
  Result := EmptyStr;
  S := System.StrUtils.IfThen(Prettify, Comma + EOL, EOL);
  for I := 0 to Count - 1 do
    Result := Result + SQuote + ValuesAtIndex[I] + SQuote + S;
  Result := TString.RemoveLastCommaEOL(Result);
end;

function TArrayString.ToList(Prettify : Boolean = False): string;
var
  I: Integer;
  S1, S2: String;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, SSpace + LTag + Equal + RTag + SSpace, SSpace);
  S2 := System.StrUtils.IfThen(Prettify, Comma + EOL, EOL);
  for I := 0 to Count - 1 do
  begin
    Result := Result + Names[I] + S1 + TArrayStringHelper.StrToStr(ValuesAtIndex[I]) + S2;
    Result := TString.RemoveLastComma(Result);
  end;
end;

function TArrayString.ToTags(Prettify : Boolean = False): string;
var
  I: Integer;
  S: String;
begin
  Result := EmptyStr;
  S := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  for I := 0 to Count - 1 do
    Result := Result + LTag + Names[I] + RTag + TArrayStringHelper.StrToStr(ValuesAtIndex[I], EmptyStr) + CTag + Names[I] + RTag + S;
  Result := TString.RemoveLastEOL(Result);
end;

function TArrayString.ToXML(Prettify: Boolean = False): string;
var
  S1, S2: String;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  S2 := System.StrUtils.IfThen(Prettify, DSpace, EmptyStr);
  Result := Result + XML + S1;
  Result := Result + LTag + 'root' + RTag + S1;
  Result := Result + TString.IndentTag(Self.ToTags(Prettify), S2);
  Result := Result + CTag + 'root' + RTag;
end;

function TArrayString.ToJSON(Prettify: Boolean = False): string;
var
  I : Integer;
  S1, S2: String;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  S2 := System.StrUtils.IfThen(Prettify, DSpace, EmptyStr);
  Result := Result + LCURLYBRACKET + S1;
  for I := 0 to Count - 1 do
    Result := Result + S2 + DQuote + Names[I] + DQuote + Colon + TArrayStringHelper.StrToStr(ValuesAtIndex[I], DQuote) + Comma + S1;
  Result := TString.RemoveLastComma(Result);
  Result := Result + RCURLYBRACKET;
end;

procedure TArrayString.Add(Key, Value: string);
begin
  if Self.IndexOfName(Key) = -1 then
    Add(Key + NameValueSeparator + Value);
end;

procedure TArrayString.AddKeyValue(Key, Value: string);
begin
  if Self.IndexOfName(Key) = -1 then
    Self.Add(Key, Value);
end;

function TArrayString.GetKey(Index: Integer): String;
begin
  inherited;
end;

function TArrayString.GetValues(Index: String): string;
begin
  Result := inherited Values[Index];
end;

function TArrayString.GetValuesAtIndex(Index: Integer): string;
begin
  Result := inherited Values[Names[Index]];
end;

procedure TArrayString.SetValues(Index: String; Const Value: String);
begin
  inherited Values[Index] := Value;
end;

function TArrayString.GetItem(Index: String): String;
begin
  Result := Self.GetValues(Index);
end;

procedure TArrayString.SetItem(Index: String; const Value: String);
begin
  Self.SetValues(Index, Value);
end;

{ TArrayStringHelper }

class function TArrayStringHelper.StrToStr(Value: String; Quote : String = #39): String;
begin
  if TArrayVariantHelper.IsNullOrEmpty(Value) then
    Result := NUL
  else if TString.IsZeroFilled(Value) then
    Result := TString.Quote(Value, Quote)
  else if TString.IsNumeric(Value) or TString.IsDecimal(Value) then
    Result := TString.Quote(TFloat.ToSQL(Value), Quote)
  else if TTimeDate.IsValid(Value) then
    Result := TString.Quote(TTimeDate.ToSQL(Value), Quote)
  else
  begin
    if Value = EMPTYCHAR then
      if Quote = DQUOTE then
        Result := NUL
      else
        Result := EmptyStr
    else if TString.IsNull(Value) then
      Result := NUL
    else
      Result := TString.Quote(Value, Quote);
  end;
  Result := TString.StringReplace(Result, [SQUOTE+SQUOTE+SQUOTE], [SQUOTE], [rfReplaceAll]);
end;

{ TArrayVariant }

constructor TArrayVariant.Create(Collection: TList<TPair<Variant, Variant>>);
begin
  inherited Create(Collection);
  NullStrictConvert := False;
end;

destructor TArrayVariant.Destroy;
begin
  inherited;

  inherited Values.Free;
  inherited Keys.Free;
end;

procedure TArrayVariant.DoCopy<T>(Collection: T);
var
  I: Integer;
begin
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
  begin
    if TArrayString(Collection) <> nil then
    begin
      for I := 0 to TArrayString(Collection).Count - 1 do
        Self.Add(TArrayString(Collection).Names[I], TArrayString(Collection).ValuesAtIndex[I]);
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
  begin
    if TArrayVariant(Collection) <> nil then
    begin
      for I := 0 to TArrayVariant(Collection).Count - 1 do
        Self.Add(TArrayVariant(Collection).Key[I], TArrayVariant(Collection).ValuesAtIndex[I]);
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TArrayField)) then
  begin
    if TArrayField(Collection) <> nil then
    begin
      for I := 0 to TArrayField(Collection).Count - 1 do
        Self.Add(TArrayField(Collection).Key[I], TArrayField(Collection).ValuesAtIndex[I].AsVariant);
    end;
  end;
end;

procedure TArrayVariant.Assign<T>(Collection: T);
begin
  if (TypeInfo(T) = TypeInfo(TArrayString)) then
  begin
    if TArrayString(Collection) <> nil then
      Self.DoCopy<T>(TArrayString(Collection));
  end
  else if (TypeInfo(T) = TypeInfo(TArrayVariant)) then
  begin
    if TArrayVariant(Collection) <> nil then
      Self.DoCopy<T>(TArrayVariant(Collection));
  end
  else if (TypeInfo(T) = TypeInfo(TArrayField)) then
  begin
    if TArrayField(Collection) <> nil then
      Self.DoCopy<T>(TArrayField(Collection));
  end;
end;

function TArrayVariant.ToKeys(Prettify : Boolean = False): String;
var
  I: Integer;
  S: String;
begin
  Result := EmptyStr;
  S := System.StrUtils.IfThen(Prettify, Comma + EOL, EOL);
  for I := 0 to Count - 1 do
    Result := Result + Key[I] + S;
  Result := TString.RemoveLastCommaEOL(Result);
end;

function TArrayVariant.ToValues(Prettify : Boolean = False): String;
var
  I: Integer;
  S: String;
begin
  Result := EmptyStr;
  S := System.StrUtils.IfThen(Prettify, Comma + EOL, EOL);
  for I := 0 to Count - 1 do
    Result := Result + TArrayVariantHelper.VarToStr(ValuesAtIndex[I]) + S;
  Result := TString.RemoveLastCommaEOL(Result);
end;

function TArrayVariant.ToList(Prettify : Boolean = False): String;
var
  I: Integer;
  S1, S2: String;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, SSpace + LTag + Equal + RTag + SSpace, SSpace);
  S2 := System.StrUtils.IfThen(Prettify, Comma + EOL, EOL);
  for I := 0 to Count - 1 do
  begin
    Result := Result + Key[I] + S1 + TArrayVariantHelper.VarToStr(ValuesAtIndex[I], SQUOTE, TBinaryMode.Write) + S2;
    Result := TString.RemoveLastComma(Result);
  end;
end;

function TArrayVariant.ToTags(Prettify : Boolean = False): string;
var
  I: Integer;
  S: String;
begin
  Result := EmptyStr;
  S := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  for I := 0 to Count - 1 do
    Result := Result + LTag + Key[I] + RTag + TArrayVariantHelper.VarToStr(ValuesAtIndex[I], EmptyStr, TBinaryMode.Write) + CTag + Key[I] + RTag + S;
  Result := TString.RemoveLastEOL(Result);
end;

function TArrayVariant.ToXML(Prettify : Boolean = False): string;
var
  S1, S2: String;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  S2 := System.StrUtils.IfThen(Prettify, DSpace, EmptyStr);
  Result := Result + XML + S1;
  Result := Result + LTag + 'root' + RTag + S1;
  Result := Result + TString.IndentTag(Self.ToTags(Prettify), S2);
  Result := Result + CTag + 'root' + RTag;
end;

function TArrayVariant.ToJSON(Prettify : Boolean = False): string;
var
  I : Integer;
  S1, S2: String;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  S2 := System.StrUtils.IfThen(Prettify, DSpace, EmptyStr);
  Result := Result + LCURLYBRACKET + S1;
  for I := 0 to Count - 1 do
    Result := Result + S2 + DQuote + Key[I] + DQuote + Colon + TArrayVariantHelper.VarToStr(ValuesAtIndex[I], DQUOTE, TBinaryMode.Write) + Comma + S1;
  Result := TString.RemoveLastComma(Result);
  Result := Result + RCURLYBRACKET;
end;

procedure TArrayVariant.Add(Key: String; Value: Variant);
begin
  inherited Add(Key, Value);
end;

procedure TArrayVariant.AddKeyValue(Key: String; Value: Variant);
begin
  inherited AddOrSetValue(Key, Value);
end;

function TArrayVariant.GetKey(Index: Integer): String;
begin
  Result := ToArray[Index].Key;
end;

function TArrayVariant.GetValues(Name: string): Variant;
var
  OutValue: Variant;
begin
  TryGetValue(Name, OutValue);
  Result := OutValue;
end;

function TArrayVariant.GetValuesAtIndex(Index: Integer): Variant;
var
  OutValue: Variant;
begin
  if not TArrayVariantHelper.IsNullOrEmpty(Self.ToArray[Index].Value) then
  begin
    TryGetValue(Self.ToArray[Index].Key, OutValue);
    Result := OutValue;
  end
  else
    Result := TArrayVariantHelper.VarToStr(Self.ToArray[Index].Value);
end;

procedure TArrayVariant.SetValues(Name: String; const Value: Variant);
begin
  Values[Name] := Value;
end;

function TArrayVariant.GetItem(Index: String): Variant;
begin
  Result := Self.GetValues(Index);
end;

procedure TArrayVariant.SetItem(Index: String; const Value: Variant);
begin
  AddOrSetValue(Index, Value);
end;

{ TArrayVariantHelper }

class function TArrayVariantHelper.IsNullOrEmpty(Text: Variant): Boolean;
begin
  Result := VarIsClear(Text) or VarIsEmpty(Text) or VarIsNull(Text) or (VarCompareValue(Text, Unassigned) = vrEqual);
  if (not Result) and VarIsStr(Text) then
    Result := Text = EmptyStr;
end;

class function TArrayVariantHelper.VarToStr(Value: Variant; Quote : String = #39; ReadOrWrite: TBinaryMode = TBinaryMode.Read): String;
begin
  if Self.IsNullOrEmpty(Value) then
    Result := NUL
  else if VarTypeAsText(VarType(Value)) = 'Array Byte' then
    if ReadOrWrite = TBinaryMode.Read then
      Result := TString.Quote(TBase64.ToEncode(TEncoding.UTF8.GetString(Value)), Quote)
    else
      Result := TString.Quote(Trim(TEncoding.UTF8.GetString(Value)), Quote)
  else if TString.IsZeroFilled(Value) then
    Result := TString.Quote(Value, Quote)
  else if TString.IsNumeric(Value) or TString.IsDecimal(Value) then
    Result := TString.Quote(TFloat.ToSQL(Value), Quote)
  else if TTimeDate.IsValid(Value) then
    Result := TString.Quote(TTimeDate.ToSQL(Value), Quote)
  else
  begin
    case TVarData(Value).VType of
      varWord, varShortInt, varSmallInt, varInteger, varInt64:
        Result := IntToStr(Value);
      varUInt32, varUInt64:
        Result := UIntToStr(Value);
      varSingle, varDouble, varCurrency:
        Result := TFloat.ToSQL(Value);
      varDate:
        Result := TString.Quote(TTimeDate.ToSQL(Value), Quote);
      varBoolean:
        if Value then
          Result := 'true'
        else
          Result := 'false';
      varNull:
        Result := NUL;
      varArray:
        Result := TString.Quote(Value, Quote);
      varString, varUString, varOleStr:
        Result := TArrayStringHelper.StrToStr(Value, Quote);
    else
      Result := TString.Quote(Value, Quote);
    end;
  end;
  Result := TString.StringReplace(Result, [SQUOTE+SQUOTE+SQUOTE], [SQUOTE], [rfReplaceAll]);
end;

{ TArrayField }

constructor TArrayField.Create(Collection: TList<TPair<Variant, TField>>);
begin
  inherited Create(Collection);
end;

destructor TArrayField.Destroy;
begin
  inherited;

  inherited Values.Free;
  inherited Keys.Free;
end;

function TArrayField.ToKeys(Prettify: Boolean = False): string;
var
  I: Integer;
  S: String;
begin
  Result := EmptyStr;
  S := System.StrUtils.IfThen(Prettify, Comma + EOL, EOL);
  for I := 0 to Count - 1 do
    Result := Result + Key[I] + S;
  Result := TString.RemoveLastCommaEOL(Result);
end;

function TArrayField.ToValues(Prettify: Boolean = False): string;
var
  I: Integer;
  S: String;
begin
  Result := EmptyStr;
  S := System.StrUtils.IfThen(Prettify, Comma + EOL, EOL);
  for I := 0 to Count - 1 do
    Result := Result + TArrayVariantHelper.VarToStr(ValuesAtIndex[I].AsVariant) + S;
  Result := TString.RemoveLastCommaEOL(Result);
end;

function TArrayField.ToList(Prettify: Boolean = False): string;
var
  I: Integer;
  S1, S2: String;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, SSpace + LTag + Equal + RTag + SSpace, SSpace);
  S2 := System.StrUtils.IfThen(Prettify, Comma + EOL, EOL);
  for I := 0 to Count - 1 do
  begin
    Result := Result + Key[I] + S1 + TArrayVariantHelper.VarToStr(ValuesAtIndex[I].AsVariant, SQUOTE, TBinaryMode.Write) + S2;
    Result := TString.RemoveLastComma(Result);
  end;
end;

function TArrayField.ToTags(Prettify: Boolean = False): string;
var
  I: Integer;
  S: String;
begin
  Result := EmptyStr;
  S := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  for I := 0 to Count - 1 do
    Result := Result + LTag + Key[I] + RTag + TArrayVariantHelper.VarToStr(ValuesAtIndex[I].AsVariant, EmptyStr, TBinaryMode.Write) + CTag + Key[I] + RTag + S;
  Result := TString.RemoveLastEOL(Result);
end;

function TArrayField.ToXML(Prettify: Boolean = False): string;
var
  S1, S2: String;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  S2 := System.StrUtils.IfThen(Prettify, DSpace, EmptyStr);
  Result := Result + XML + S1;
  Result := Result + LTag + 'root' + RTag + S1;
  Result := Result + TString.IndentTag(Self.ToTags(Prettify), S2);
  Result := Result + CTag + 'root' + RTag;
end;

function TArrayField.ToJSON(Prettify: Boolean = False): string;
var
  I : Integer;
  S1, S2: String;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  S2 := System.StrUtils.IfThen(Prettify, DSpace, EmptyStr);
  Result := Result + LCURLYBRACKET + S1;
  for I := 0 to Count - 1 do
    Result := Result + S2 + DQuote + Key[I] + DQuote + Colon + TArrayVariantHelper.VarToStr(ValuesAtIndex[I].AsVariant, DQUOTE, TBinaryMode.Write) + Comma + S1;
  Result := TString.RemoveLastComma(Result);
  Result := Result + RCURLYBRACKET;
end;

procedure TArrayField.Add(Key: String; Value: TField);
begin
  inherited Add(Key, Value);
end;

procedure TArrayField.AddKeyValue(Key: String; Value: TField);
begin
  inherited AddOrSetValue(Key, Value);
end;

function TArrayField.GetKey(Index: Integer): String;
begin
  Result := ToArray[Index].Key;
end;

function TArrayField.GetValues(Name: string): TField;
var
  OutValue: TField;
begin
  TryGetValue(Name, OutValue);
  Result := OutValue;
end;

function TArrayField.GetValuesAtIndex(Index: Integer): TField;
var
  OutValue: TField;
begin
  TryGetValue(Self.ToArray[Index].Key, OutValue);
  Result := OutValue;
end;

procedure TArrayField.SetValues(Name: String; const Value: TField);
begin
  Values[Name] := Value;
end;

function TArrayField.GetItem(Index: String): TField;
begin
  Result := Self.GetValues(Index);
end;

procedure TArrayField.SetItem(Index: String; const Value: TField);
begin
  AddOrSetValue(Index, Value);
end;

{ TArrayFieldHelper }

class function TArrayFieldHelper.FieldToStr(Field: TField): String;
var
  FmtSet: TFormatSettings;
  I: Integer;
  I64: Int64;
  D: Double;
  Cur: Currency;
  DT: TDateTime;
begin
  if Field.isNull then
    if (Field.DataType = ftDate) then
      Result := '0000-00-00'
    else
      Result := NUL
  else
  begin
    case Field.DataType of
      ftSmallint, ftWord, ftInteger:
      begin
        i := Field.AsInteger;
        Result := IntToStr(i);
        Result := StringReplace(Result, #0, EmptyStr, [rfReplaceAll]);
      end;
      ftLargeint:
      begin
        I64 := TLargeintField(Field).AsLargeInt;
        Result := IntToStr(I64);
      end;
      ftFloat:
      begin
        D := Field.AsFloat;
        FmtSet.DecimalSeparator := '.';
        Result := FloatToStr(D, FmtSet);
      end;
      ftBCD:
      begin
        Cur := Field.AsCurrency;
        FmtSet.DecimalSeparator := '.';
        Result := System.SysUtils.CurrToStr(Cur, FmtSet);
      end;
      ftFMTBcd:
      begin
        Result := Field.AsString;
        if FormatSettings.DecimalSeparator <> '.' then
          Result := StringReplace(Result, FormatSettings.DecimalSeparator, '.', []);
      end;
      ftBoolean:
      begin
        Result := BoolToStr(Field.AsBoolean, False);
      end;
      ftDate:
      begin
        DT := Field.AsDateTime;
        FmtSet.DateSeparator := '-';
        Result := QuotedStr(FormatDateTime('yyyy-mm-dd', DT, FmtSet));
      end;
      ftTime:
      begin
        DT := Field.AsDateTime;
        FmtSet.TimeSeparator := ':';
        Result := QuotedStr(FormatDateTime('hh:nn:ss', DT, FmtSet));
      end;
      ftDateTime:
      begin
        DT := Field.AsDateTime;
        FmtSet.DateSeparator := '-';
        FmtSet.TimeSeparator := ':';
        Result := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', DT, FmtSet));
      end;
    else
      Result := QuotedStr(TString.RealEscapeStrings(Field.Value));
    end;
  end;
end;

{ TArrayAssoc }

constructor TArrayAssoc.Create(StrictRules: Boolean = False);
begin
  fStrict := StrictRules;
  fDict := nil;
  TVarData(fVal).VType := varEmpty;
end;

destructor TArrayAssoc.Destroy;
var
  Enum: TPair<Variant, TArrayAssoc>;
begin
  if(fDict <> nil) then
  begin
    for Enum in fDict do
      Enum.Value.Free;
  end;
end;

function TArrayAssoc.Add(Index: Variant): TArrayAssoc;
begin
  Result := nil;
  if(fDict <> nil) then
  begin
    if(fDict.ContainsKey(Index)) then
    begin
      if(fStrict = true) then
        raise Exception.Create('A Matriz est� em estrito, a chave "'+ Index +'" j� estava definida.')
    end
    else
    begin
      Result := TArrayAssoc.Create(fStrict);
      fDict.Add(Index,Result);
    end;
  end
  else
  begin
    fDict := TDictionary<Variant,TArrayAssoc>.Create(1);
    Result := TArrayAssoc.Create(fStrict);
    fDict.Add(Index,Result);
  end;
end;

function TArrayAssoc.Add(Index, Value: Variant): TArrayAssoc;
begin
  Result := Add(Index);
  Result.Val := Value;
end;

procedure TArrayAssoc.Clear;
var
  Enum: TPair<Variant, TArrayAssoc>;
begin
  if(fDict <> nil) then
  begin
    for Enum in fDict do
      Enum.Value.Free;
    fDict.Clear;
  end;
end;

function TArrayAssoc.GetItem(Index: Variant): TArrayAssoc;
begin
  if(fdict <> nil) then
  begin
    if(fDict.ContainsKey(Index)) then
      Result := fDict.Items[Index]
    else
    begin
      if (fStrict) then
        raise Exception.Create('A Matriz est� em estrito, a chave "'+ Index +'" n�o foi definida.')
      else
      begin
        Result := TArrayAssoc.Create(fStrict);
        fDict.Add(Index,Result);
      end;
    end;
  end
  else
  begin
    if(fStrict) then
      raise Exception.Create('A Matriz est� em estrito, a chave "'+ Index +'" n�o foi definida.')
    else
    begin
      fDict := TDictionary<Variant,TArrayAssoc>.Create(1);
      Result := TArrayAssoc.Create(fStrict);
      fDict.Add(Index,Result);
    end;
  end;
end;

function TArrayAssoc.GetVal: Variant;
begin
  Result := fVal;
end;

procedure TArrayAssoc.SetVal(Value: Variant);
begin
  fVal := Value;
end;

function TArrayAssoc.ToList(Prettify : Boolean = False): String;
var
  S1, S2: String;
  Parent, Children: TPair<Variant, TArrayAssoc>;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, SSpace + LTag + Equal + RTag + SSpace, SSpace);
  S2 := System.StrUtils.IfThen(Prettify, Comma + EOL, EOL);
  for Parent in Self.ToArray do
  begin
    for Children in Parent.Value.ToArray do
    begin
      Result := Result + Children.Key + LSQUAREBRACKET + String(Parent.Key) + RSQUAREBRACKET + S1 + TArrayVariantHelper.VarToStr(Parent.Value[Children.Key].Val, SQUOTE, TBinaryMode.Write) + S2;
      Result := TString.RemoveLastComma(Result);
    end;
  end;
end;

function TArrayAssoc.ToTags(Prettify : Boolean = False): string;
var
  S1, S2: String;
  Parent, Children: TPair<Variant, TArrayAssoc>;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  S2 := System.StrUtils.IfThen(Prettify, DSPACE, EmptyStr);
  for Parent in Self.ToArray do
  begin
    Result := Result + LTag + 'resultset' + SSPACE + 'rowid' + EQUAL + DQUOTE + String(Parent.Key) + DQUOTE + RTag + S1;
    for Children in Parent.Value.ToArray do
    begin
      Result := Result + TString.IndentTag(LTag + Children.Key + RTag + TArrayVariantHelper.VarToStr(Parent.Value[Children.Key].Val, EmptyStr, TBinaryMode.Write) + CTag + Children.Key + RTag, S2) + S1;
    end;
    Result := Result + CTag + 'resultset' + RTag + S1;
  end;
  Result := TString.RemoveLastEOL(Result);
end;

function TArrayAssoc.ToXML(Prettify : Boolean = False): string;
var
  S1, S2: String;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  S2 := System.StrUtils.IfThen(Prettify, DSPACE, EmptyStr);
  Result := Result + XML + S1;
  Result := Result + LTag + 'root' + RTag + S1;
  Result := Result + TString.IndentTag(Self.ToTags(Prettify), S2);
  Result := Result + CTag + 'root' + RTag;
end;

function TArrayAssoc.ToJSON(Prettify : Boolean = False): string;
var
  S1, S2: String;
  Parent, Children: TPair<Variant, TArrayAssoc>;
begin
  Result := EmptyStr;
  S1 := System.StrUtils.IfThen(Prettify, EOL, EmptyStr);
  S2 := System.StrUtils.IfThen(Prettify, DSpace, EmptyStr);
  Result := Result + LCURLYBRACKET + S1;
  for Parent in Self.ToArray do
  begin
    for Children in Parent.Value.ToArray do
    begin
      Result := Result + S2 + DQuote + Children.Key + DQuote + Colon + TArrayVariantHelper.VarToStr(Parent.Value[Children.Key].Val, DQUOTE, TBinaryMode.Write) + Comma + S1;
    end;
  end;
  Result := TString.RemoveLastComma(Result);
  Result := Result + RCURLYBRACKET;
end;

end.

