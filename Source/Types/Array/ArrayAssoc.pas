{
  ArrayAssoc.
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

unit ArrayAssoc;

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
  TimeDate,
  ArrayString,
  ArrayVariantHelper;

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
        raise Exception.Create('A Matriz est� em estrito, a chave "'+ Index +'" já estava definida.')
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
        raise Exception.Create('A Matriz está em estrito, a chave "'+ Index +'" não foi definida.')
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
      raise Exception.Create('A Matriz está em estrito, a chave "'+ Index +'" não foi definida.')
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

