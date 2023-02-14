﻿{
  ArrayVariantHelper.
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

unit ArrayStringHelper;

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
  
  ArrayString
  ;

type
  TArrayStringHelper = class(TArrayString)
  private
    { Private declarations }
  public
    { Public declarations }
    class function StrToStr(Value: String; Quote : String = #39): String;
  end;

implementation

uses
  Strings,
  Float,
  TimeDate,
  ArrayVariantHelper;

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

end.