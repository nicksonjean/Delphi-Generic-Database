{
  Float.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a conves�o, formata��o e compara��o de valores
  monet�rios e quantitativos em Delphi.
  Suporta 2 Modos de Resultado: ResultMode = (Truncate, Round);
  Suporta 2 Formatos de Resultado: ResultFormat = (BR, DB);
  OBS.:
  1 - O Formato DB � o Mesmo Utilizado em Campos Decimais, Double ou Float,
  de Bancos de Dados como MySQL/MariaDB, PostgreSQL, SQLite e etc...
  2 - Como Recomenda��o ao Definir seus Campos Monet�rios no Banco de Dados,
  Utilize um comprimento de grandeza igual ou superior � 18, ex: Decimal(18,x).
  3 - N�o Ser�o Adicionados S�mbolos Monet�rios como: R$, US$, etc...
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  Co-Autor : Wellington Fonseca
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

unit &Float;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  System.RegularExpressions,

  System.MaskUtils,
  System.Character,

  FMX.Objects,
  FMX.Dialogs,
  FMX.Edit,

  Winapi.Windows,
  Winapi.Messages,
  Locale,
  Strings
  ;

{$I Money.Types.json.inc}

type
  TLocaleFloat = class(TLocale)
  private
    { Private declarations }
    class var _LOCALE_STHOUSAND, _LOCALE_SDECIMAL: String;
    class procedure StoreWindowsLocale();
    class procedure RestoreWindowsLocale();
    class procedure SetWindowsLocale(const &ThousandSeparator: String = '.'; const &DecimalSeparator: String = ',');
  public
    { Public declarations }
  end;

type
  TRoundToRange = -37..37;
  TResultFormat = (BR, DB);
  TResultMode = (Truncate, Round);
  TFloat = class
  protected
    { Private declarations }
    class function RoundTo(const AValue: Double; const ADigit: TRoundToRange): Double;
    class function SimpleRoundTo(const AValue: Double; const ADigit: TRoundToRange = -2): Double;
    class function SimpleRoundToEX(const AValue: Extended; const ADigit: TRoundToRange = -2): Extended;
    class function TruncFix(X: Extended): Int64;
    class function TruncTo(const AValue: Double; const Digits: TRoundToRange): Double;
    class function RoundABNT(const AValue: Double; const Digits: TRoundToRange; const Delta: Double = 0.00001 ): Double;
  private
    { Private declarations }
    class function StrToCurr(const Value: String): Currency; overload;
    class function StrToCurr(Value: String; const FormatSettings : TFormatSettings): Currency; overload;
    class function StrToFloat(const Value: String): Extended; overload;
    class function StrToFloat(Value: String; const FormatSettings : TFormatSettings): Extended; overload;
    class procedure GetFormat(Value: String; out QtdDecimal: Integer; out PosDecimal: Integer; out PosType : String); overload;
    class function GetFormat(Value: String): Integer; overload;
    class function FromFormat(Value: string; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','): Variant;
    class procedure ToFormat(out Return : String; Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.BR; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','); overload;
    class procedure ToFormat(out Return : Currency; Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','); overload;
    class procedure ToFormat(out Return : Double; Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','); overload;
    class procedure ToFormat(out Return : Extended; Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','); overload;
  public
    { Public declarations }
    class function ToString(Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.BR; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','): String; reintroduce;
    class function ToCurrency(Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','): Currency;
    class function ToDouble(Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','): Double;
    class function ToExtended(Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','): Extended;
    class function ToMoney(Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','): String;
    class function ToSQL(Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; const &ThousandSeparator: Char = #0; const &DecimalSeparator: Char = '.'): String;
  end;

{
  TODO -oNickson Jeanmerson -cProgrammer :
  1)   Estudar Diferen�a Entre CurrToStr e FloatToStr
}

function CurrToStr(const Value: Extended): string;

implementation

function CurrToStr(const Value: Extended): string;
var
  FormatSettings : TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create;
  FormatSettings.DecimalSeparator := '.';
  Result := FloatToStrF(Value, ffFixed, 18, 9, FormatSettings);
end;

{ TLocaleFloat }

class procedure TLocaleFloat.RestoreWindowsLocale();
begin
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDECIMAL, PWideChar(PWideString(WideString(_LOCALE_SDECIMAL))));
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_STHOUSAND, PWideChar(PWideString(WideString(_LOCALE_STHOUSAND))));
end;

class procedure TLocaleFloat.StoreWindowsLocale();
begin
  _LOCALE_SDECIMAL := TLocale.GetWindowsLocale(LOCALE_SDECIMAL);
  _LOCALE_STHOUSAND := TLocale.GetWindowsLocale(LOCALE_STHOUSAND);
end;

class procedure TLocaleFloat.SetWindowsLocale(const &ThousandSeparator: String = '.'; const &DecimalSeparator: String = ',');
begin
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDECIMAL, PWideChar(PWideString(WideString(&DecimalSeparator))));
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_STHOUSAND, PWideChar(PWideString(WideString(&ThousandSeparator))));
  with FormatSettings do
  begin
    ThousandSeparator := &ThousandSeparator;
    DecimalSeparator := &DecimalSeparator;
  end;
end;

{ TFloat }

class function TFloat.RoundTo(const AValue: Double; const ADigit: TRoundToRange): Double;
var
  LFactor: Double;
begin
  LFactor := IntPower(10, ADigit);
  Result := System.Round(AValue / LFactor) * LFactor;
end;

class function TFloat.SimpleRoundTo(const AValue: Double; const ADigit: TRoundToRange = -2): Double;
var
  LFactor: Double;
begin
  LFactor := IntPower(10, ADigit);
  Result := Trunc((AValue / LFactor) + 0.5) * LFactor;
end;

class function TFloat.SimpleRoundToEX(const AValue: Extended; const ADigit: TRoundToRange = -2): Extended;
var
  LFactor: Extended;
begin
  LFactor := IntPower(10.0, ADigit);
  if AValue < 0 then
    Result := Int((AValue / LFactor) - 0.5) * LFactor
  else
    Result := Int((AValue / LFactor) + 0.5) * LFactor;
end;

class function TFloat.TruncFix( X : Extended ) : Int64 ;
begin
  Result := Trunc( SimpleRoundToEX( X, -9) ) ;
end;

class function TFloat.RoundABNT(const AValue: Double; const Digits: TRoundToRange; const Delta: Double = 0.00001 ): Double;
var
  Pow, FracValue, PowValue : Extended;
  RestPart: Double;
  IntCalc, FracCalc, LastNumber, IntValue : Int64;
  Negativo: Boolean;
Begin
  Negativo  := (AValue < 0);
  Pow       := IntPower(10, Abs(Digits) );
  PowValue  := Abs(AValue) / 10 ;
  IntValue  := Trunc(PowValue);
  FracValue := Frac(PowValue);
  PowValue := Self.SimpleRoundToEX( FracValue * 10 * Pow, -9);
  IntCalc  := Trunc( PowValue );
  FracCalc := Trunc( frac( PowValue ) * 100 );
  if (FracCalc > 50) then
    Inc( IntCalc )
  else if (FracCalc = 50) then
  begin
    LastNumber := System.Round( Frac( IntCalc / 10) * 10);
    if Odd(LastNumber) then
      Inc( IntCalc )
    else
    begin
      RestPart := Frac( PowValue * 10 ) ;
      if RestPart > Delta then
        Inc( IntCalc );
    end;
  end;
  Result := ((IntValue*10) + (IntCalc / Pow));
  if Negativo then
    Result := -Result;
end;

class function TFloat.TruncTo(const AValue: Double; const Digits: TRoundToRange): Double;
var
 VFrac : Double;
 Pow: Extended;
begin
  Result := AValue;
  VFrac  := Frac(Result);
  if VFrac <> 0 then
  begin
    Pow    := IntPower(10, Abs(Digits) );
    VFrac  := Self.TruncFix(VFrac * Pow);
    VFrac  := VFrac / Pow;
    Result := Int(Result) + VFrac  ;
  end;
end;

class function TFloat.StrToCurr(const Value: String): Currency;
var
  PosDecimal, QtdDecimal : Integer;
  PosType : String;
begin
  QtdDecimal := 0;
  PosDecimal := 0;
  PosType := EmptyStr;
  Self.GetFormat(Value, QtdDecimal, PosDecimal, PosType);
  if Length(SplitString(Value, PosType)) > 1 then
    Result := System.SysUtils.StrToCurr(TString.OnlyNumeric(SplitString(Value, PosType)[0]) + FormatSettings.DecimalSeparator + SplitString(Value, PosType)[1])
  else
    Result := System.SysUtils.StrToCurr(Value);
end;

class function TFloat.StrToCurr(Value: String; const FormatSettings: TFormatSettings): Currency;
begin
  Result:= Self.StrToCurr(Value, FormatSettings);
end;

class function TFloat.StrToFloat(const Value: String): Extended;
var
  PosDecimal, QtdDecimal : Integer;
  PosType : String;
begin
  QtdDecimal := 0;
  PosDecimal := 0;
  PosType := EmptyStr;
  Self.GetFormat(Value, QtdDecimal, PosDecimal, PosType);
  if Length(SplitString(Value, PosType)) > 1 then
    Result := System.SysUtils.StrToFloat(TString.OnlyNumeric(SplitString(Value, PosType)[0]) + FormatSettings.DecimalSeparator + SplitString(Value, PosType)[1])
  else
    Result := System.SysUtils.StrToFloat(Value);
end;

class function TFloat.StrToFloat(Value: String; const FormatSettings: TFormatSettings): Extended;
begin
  Result:= Self.StrToFloat(Value, FormatSettings);
end;

class procedure TFloat.GetFormat(Value: String; out QtdDecimal: Integer; out PosDecimal: Integer; out PosType : String);
var
  RevString : String;
  PosComma, PosDot : Integer;
begin
  RevString := ReverseString(Value);
  PosComma := Pos(',', RevString);
  PosDot := Pos('.', RevString);

  if ( (PosComma <> 0) and (PosDot <> 0) ) then
  begin
    if (PosComma < PosDot) then
    begin
      QtdDecimal := PosComma-1;
      if QtdDecimal < 0 then
        QtdDecimal := 0;
      PosDecimal := PosComma;
    end
    else
    begin
      QtdDecimal := PosDot-1;
      if QtdDecimal < 0 then
        QtdDecimal := 0;
      PosDecimal := PosDot;
    end
  end
  else
  begin
    if PosComma > 0 then
    begin
      QtdDecimal := PosComma-1;
      if QtdDecimal < 0 then
        QtdDecimal := 0;
      PosDecimal := PosComma;
    end
    else
    begin
      QtdDecimal := PosDot-1;
      if QtdDecimal < 0 then
        QtdDecimal := 0;
      PosDecimal := PosDot;
    end
  end;
  if PosDecimal = PosDot then
    PosType := '.'
  else if PosDecimal = PosComma then
    PosType := ','
  else
    PosType := '';
end;

class function TFloat.FromFormat(Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','): Variant;
var
  ExtValue: Extended;
  Position, PosDecimal, QtdDecimal : Integer;
  ResDecimal, NumDecimal, PosType : String;
begin
  TLocaleFloat.StoreWindowsLocale();
  TLocaleFloat.SetWindowsLocale(&ThousandSeparator, &DecimalSeparator);
  try
    Value := TString.OnlyValues(Value);
    Self.GetFormat(Value, QtdDecimal, PosDecimal, PosType);
    Value := TString.OnlyNumeric(Value);
    Position := (Length(Value) - (PosDecimal)) + 2;

    if DecimalLength = -1 then
      DecimalLength := Self.GetFormat(Value);

    ResDecimal := String('1').PadRight(QtdDecimal +1, '0');
    NumDecimal := StringOfChar('0', DecimalLength);

    if Mode = TResultMode.Round then
      ExtValue := Self.SimpleRoundToEX(System.SysUtils.StrToFloat(Value) / StrToInt(ResDecimal), -DecimalLength)
    else
      ExtValue := Self.StrToFloat(Copy(Value, 1, Position-1) + &DecimalSeparator + Copy(Value, Position, DecimalLength));

    if Format = TResultFormat.BR then
      Result := ReverseString(StringReplace(ReverseString(ExtValue.ToString), &ThousandSeparator, &DecimalSeparator, [rfReplaceAll]))
    else
      Result := ExtValue;
  finally
    TLocaleFloat.RestoreWindowsLocale();
  end;
end;

class function TFloat.GetFormat(Value: String): Integer;
var
  PosDecimal, QtdDecimal : Integer;
  PosType : String;
begin
  Value := TString.OnlyValues(Value);
  Self.GetFormat(Value, QtdDecimal, PosDecimal, PosType);
  Result := QtdDecimal;
end;

class procedure TFloat.ToFormat(out Return: String; Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.BR; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ',');
var
  ExtValue: Extended;
begin
  if DecimalLength = -1 then
    DecimalLength := Self.GetFormat(Value);
  ExtValue := Self.FromFormat(Value, DecimalLength, Mode, Format, &ThousandSeparator, &DecimalSeparator);
  if Format = TResultFormat.BR then
    Return := FormatFloat(',0.' + StringOfChar('0', DecimalLength), ExtValue)
  else
    Return := TString.StringReplace(FloatToStr(ExtValue), ['.', ','], ['', '.'], [rfReplaceAll]);
end;

class procedure TFloat.ToFormat(out Return: Currency; Value: string; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ',');
var
  CurrValue: Currency;
begin
  if DecimalLength = -1 then
    DecimalLength := Self.GetFormat(Value);
  CurrValue := Self.FromFormat(Value, DecimalLength, Mode, Format, &ThousandSeparator, &DecimalSeparator);
  Return := CurrValue;
end;

class procedure TFloat.ToFormat(out Return: Double; Value: string; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ',');
var
  DoubValue: Double;
begin
  if DecimalLength = -1 then
    DecimalLength := Self.GetFormat(Value);
  DoubValue := Self.FromFormat(Value, DecimalLength, Mode, Format, &ThousandSeparator, &DecimalSeparator);
  Return := DoubValue;
end;

class procedure TFloat.ToFormat(out Return: Extended; Value: string; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ',');
var
  ExtValue: Extended;
begin
  if DecimalLength = -1 then
    DecimalLength := Self.GetFormat(Value);
  ExtValue := Self.FromFormat(Value, DecimalLength, &Mode, Format, ThousandSeparator, &DecimalSeparator);
  Return := ExtValue;
end;

class function TFloat.ToString(Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.BR; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','): String;
var
  Return : String;
begin
  Return := Value;
  Self.ToFormat(Return, Value, DecimalLength, Mode, Format, &ThousandSeparator, &DecimalSeparator);
  Result := Return;
end;

class function TFloat.ToCurrency(Value: string; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','): Currency;
var
  Return : Currency;
begin
  Return := Self.StrToCurr(TString.OnlyValues(Value));
  Self.ToFormat(Return, Value, DecimalLength, Mode, Format, &ThousandSeparator, &DecimalSeparator);
  Result := Return;
end;

class function TFloat.ToDouble(Value: string; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','): Double;
var
  Return : Double;
begin
  Return := Self.StrToFloat(TString.OnlyValues(Value));
  Self.ToFormat(Return, Value, DecimalLength, Mode, Format, &ThousandSeparator, &DecimalSeparator);
  Result := Return;
end;

class function TFloat.ToExtended(Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; Format: TResultFormat = TResultFormat.DB; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','): Extended;
var
  Return : Extended;
begin
  Return := Self.StrToFloat(TString.OnlyValues(Value));
  Self.ToFormat(Return, Value, DecimalLength, Mode, Format, &ThousandSeparator, &DecimalSeparator);
  Result := Return;
end;

class function TFloat.ToMoney(Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; const &ThousandSeparator: Char = '.'; const &DecimalSeparator: Char = ','): String;
begin
  Result := 'R$ ' + Self.ToString(Value, DecimalLength, Mode, TResultFormat.BR, &ThousandSeparator, &DecimalSeparator);
end;

class function TFloat.ToSQL(Value: String; DecimalLength: Integer = -1; Mode: TResultMode = TResultMode.Truncate; const &ThousandSeparator: Char = #0; const &DecimalSeparator: Char = '.'): String;
begin
  Result := Self.ToString(Value, DecimalLength, Mode, TResultFormat.DB, &ThousandSeparator, &DecimalSeparator);
end;

end.

