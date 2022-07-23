{
  ArrayField.
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

unit ArrayField;

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
  TArrayField = class(TDictionary<Variant, TField>)
  private
    { Private declarations }
    function GetKey(Index: Integer): String;
    function GetValues(Name: String): TField;
    function GetValuesAtIndex(Index: Integer): TField;
    procedure SetValues(Name: String; Const Value: TField);
    function GetItem(Index: String): TField;
    procedure SetItem(Index: String; Const Value: TField);
    procedure DoCopy(Collection : TDictionary<Variant, TField>);
  public
    { Public declarations }
    constructor Create(Collection: TList<TPair<Variant,TField>>); overload;
    destructor Destroy; override;
    procedure Assign(Collection : TDictionary<Variant, TField>);
    function ToKeys(Prettify : Boolean = False): String;
    function ToValues(Prettify : Boolean = False): String;
    function ToList(Prettify : Boolean = False): String;
    function ToTags(Prettify : Boolean = False): String;
    function ToXML(Prettify : Boolean = False): String;
    function ToJSON(Prettify : Boolean = False): String;
    procedure Add(Key: String; Value: TField);
    procedure AddKeyValue(Key: String; Value: TField);
    property Key[Index: Integer]: String read GetKey;
    property ValuesAtIndex[Index: Integer]: TField read GetValuesAtIndex;
    property Values[Name: String]: TField read GetValues write SetValues;
    property Item[Index: String]: TField read GetItem write SetItem; default;
  end;

implementation

uses
  Strings,
  Float,
  TimeDate,
  ArrayVariantHelper;

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

procedure TArrayField.DoCopy(Collection : TDictionary<Variant, TField>);
var
  I: Integer;
begin
  if Collection <> nil then
  begin
    for I := 0 to Collection.Count - 1 do
      Self.Add(TArrayField(Collection).Key[I], TArrayField(Collection).ValuesAtIndex[I]);
  end;
end;

function TArrayField.ToKeys(Prettify: Boolean = False): String;
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

function TArrayField.ToValues(Prettify: Boolean = False): String;
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

function TArrayField.ToList(Prettify: Boolean = False): String;
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

function TArrayField.ToTags(Prettify: Boolean = False): String;
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

function TArrayField.ToXML(Prettify: Boolean = False): String;
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

function TArrayField.ToJSON(Prettify: Boolean = False): String;
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

procedure TArrayField.Assign(Collection: TDictionary<Variant, TField>);
begin
  Self.DoCopy(Collection);
end;

function TArrayField.GetKey(Index: Integer): String;
begin
  Result := ToArray[Index].Key;
end;

function TArrayField.GetValues(Name: String): TField;
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

end.

