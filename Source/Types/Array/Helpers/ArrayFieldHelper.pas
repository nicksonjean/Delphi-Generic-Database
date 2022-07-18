{
  ArrayFieldHelper.
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

unit ArrayFieldHelper;

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
  TArrayFieldHelper = class(TArrayField)
  private
    { Private declarations }
  public
    { Public declarations }
    class function FieldToStr(Field: TField): String;
  end;

implementation

uses
  &String,
  Float,
  TimeDate,
  ArrayField;

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

end.
