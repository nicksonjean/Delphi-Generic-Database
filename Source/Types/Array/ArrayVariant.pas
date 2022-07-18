{
  ArrayString.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a criação de matrizes php-like em Delphi.
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
  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la
  sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a versão 3.29 da Licença, ou (a seu critério)
  qualquer versão posterior.
  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM
  NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU
  ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor
  do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)
  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto
  com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,
  no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Você também pode obter uma copia da licença em:
  http://www.opensource.org/licenses/lgpl-license.php
}

unit ArrayVariant;

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
  MimeType,
  Data.DB,
  REST.JSON
  ;

type
  TArrayVariant = class(TDictionary<Variant, Variant>)
  private
    { Private declarations }
  public
    { Public declarations }
    function GetKey(Index: Integer): String;
    function GetValues(Name: String): Variant;
    function GetValuesAtIndex(Index: Integer): Variant;
    procedure SetValues(Name: String; const Value: Variant);
    function GetItem(Index: String): Variant;
    procedure SetItem(Index: String; const Value: Variant);
    procedure DoCopy<T: Class>(Collection : T);

    constructor Create(Collection: TList<TPair<Variant,Variant>>); overload;
    destructor Destroy; override;
    procedure Assign<T: Class>(Collection : T);
    function ToKeys(Prettify : Boolean = False): String;
    function ToValues(Prettify : Boolean = False): String;
    function ToList(Prettify : Boolean = False): String;
    function ToTags(Prettify : Boolean = False): String;
    function ToXML(Prettify : Boolean = False): String;
    function ToJSON(Prettify : Boolean = False): String;
    procedure Add(Key: String; Value: Variant);
    procedure AddKeyValue(Key: String; Value: Variant);
    property Key[Index: Integer]: String read GetKey;
    property ValuesAtIndex[Index: Integer]: Variant read GetValuesAtIndex;
    property Values[Name: String]: Variant read GetValues write SetValues;
    property Item[Index: String]: Variant read GetItem write SetItem; default;
  end;

implementation

uses
  &String,
  Float,
  TimeDate,
  ArrayString,
  ArrayField,
  ArrayVariantHelper;

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

function TArrayVariant.ToTags(Prettify : Boolean = False): String;
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

function TArrayVariant.ToXML(Prettify : Boolean = False): String;
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

function TArrayVariant.ToJSON(Prettify : Boolean = False): String;
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

function TArrayVariant.GetValues(Name: String): Variant;
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

end.

