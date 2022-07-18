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

unit ArrayString;

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
  System.NetEncoding
  ;

type
  TArrayString = class(TStringList)
  private
    { Private declarations }
  public
    { Public declarations }
    function GetKey(Index: Integer): String;
    function GetValues(Index: String): String;
    function GetValuesAtIndex(Index: Integer): String;
    procedure SetValues(Index: String; Const Value: String);
    function GetItem(Index: String): String;
    procedure SetItem(Index: String; Const Value: String);
    procedure DoCopy(Collection: TArrayString = nil);

    constructor Create(Collection: TArrayString = nil);
    destructor Destroy; override;
    procedure Assign(Collection: TArrayString); reintroduce;
    function ToKeys(Prettify : Boolean = False): String;
    function ToValues(Prettify : Boolean = False): String;
    function ToList(Prettify : Boolean = False): String;
    function ToTags(Prettify : Boolean = False): String;
    function ToXML(Prettify : Boolean = False): String;
    function ToJSON(Prettify : Boolean = False): String;
    procedure Add(Key, Value: String); reintroduce; overload;
    procedure AddKeyValue(Key, Value: String);
    property Key[Index: Integer]: String read GetKey;
    property ValuesAtIndex[Index: Integer]: String read GetValuesAtIndex;
    property Values[Index: String]: String read GetValues write SetValues;
    property Item[Index: String]: String read GetItem write SetItem; default;
  end;

implementation

uses
  &String,
  Float,
  TimeDate,
  ArrayStringHelper;

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

function TArrayString.ToKeys(Prettify : Boolean = False): String;
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

function TArrayString.ToValues(Prettify : Boolean = False): String;
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

function TArrayString.ToList(Prettify : Boolean = False): String;
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

function TArrayString.ToTags(Prettify : Boolean = False): String;
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

function TArrayString.ToXML(Prettify: Boolean = False): String;
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

function TArrayString.ToJSON(Prettify: Boolean = False): String;
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

procedure TArrayString.Add(Key, Value: String);
begin
  if Self.IndexOfName(Key) = -1 then
    Add(Key + NameValueSeparator + Value);
end;

procedure TArrayString.AddKeyValue(Key, Value: String);
begin
  if Self.IndexOfName(Key) = -1 then
    Self.Add(Key, Value);
end;

function TArrayString.GetKey(Index: Integer): String;
begin
  inherited;
end;

function TArrayString.GetValues(Index: String): String;
begin
  Result := inherited Values[Index];
end;

function TArrayString.GetValuesAtIndex(Index: Integer): String;
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

end.

