unit Masks;

interface

uses
  FMX.Types,
  FMX.Edit;

type
  TMasks = class
  public
    class procedure SetMaskSerial(AEdit: TEdit);
    class procedure SetMaskCPF(AEdit: TEdit);
    class procedure SetMaskCNPJ(AEdit: TEdit);
    class procedure SetMaskCEP(AEdit: TEdit);
    class procedure SetMaskFone(AEdit: TEdit);
    class procedure SetMaskMonthYear2D(AEdit: TEdit; var Key: Word);
    class procedure SetMaskMonthYear4D(AEdit: TEdit; var Key: Word);
    class procedure SetMaskDate2D(AEdit: TEdit; var Key: Word);
    class procedure SetMaskDate4D(AEdit: TEdit; var Key: Word);
    class procedure SetMaskTime(AEdit: TEdit; var Key: Word);
    class procedure SetMaskMoneyKeyUp(AEdit: TEdit; var KeyChar: Char);
    class procedure SetMaskFloatKeyDown(AEdit: TEdit; var KeyChar: Char; var Key: Word; DecimalLength: Integer = 4; const Symbol: String = '');
    class procedure SetMaskMoneyKeyDown(AEdit: TEdit; var KeyChar: Char; var Key: Word; DecimalLength: Integer = 2; const Symbol: String = 'R$');
  private
    class function SetMaskKeyDown(const Value: String; var KeyChar: Char; var Key: Word; SelStart: Integer; MaxLength: Integer; DecimalLength: Integer = 4; const Symbol: String = ''): String;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  System.RegularExpressions,
  System.MaskUtils,
  System.Character,
  &Type.&Float,
  &Type.&String;

{ TMasks }

class procedure TMasks.SetMaskSerial(AEdit: TEdit);
var
  _Value, _Result: string;
begin
  _Value := TString.OnlyAlphaNumeric(AEdit.Text);
  AEdit.GoToTextEnd;
  AEdit.MaxLength := 28;
  AEdit.KeyboardType := TVirtualKeyBoardType.Alphabet;

  if (_Value <> '') then
  begin

    case Length(_Value) of
      0:
        _Result := FormatMaskText('0;0', _Value);
      1:
        _Result := FormatMaskText('00;0', _Value);
      2:
        _Result := FormatMaskText('000;0', _Value);
      3:
        _Result := FormatMaskText('0000;0', _Value);
      4:
        _Result := FormatMaskText('00000;0', _Value);
      5:
        _Result := FormatMaskText('000000;0', _Value);
      6:
        _Result := FormatMaskText('000000;0', _Value);
      7:
        _Result := FormatMaskText('000000\-00;0', _Value);
      8:
        _Result := FormatMaskText('000000\-000;0', _Value);
      9:
        _Result := FormatMaskText('000000\-0000;0', _Value);
      10:
        _Result := FormatMaskText('000000\-00000;0', _Value);
      11:
        _Result := FormatMaskText('000000\-00000;0', _Value);
      12:
        _Result := FormatMaskText('000000\-00000\-00;0', _Value);
      13:
        _Result := FormatMaskText('000000\-00000\-000;0', _Value);
      14:
        _Result := FormatMaskText('000000\-00000\-0000;0', _Value);
      15:
        _Result := FormatMaskText('000000\-00000\-0000;0', _Value);
      16:
        _Result := FormatMaskText('000000\-00000\-0000\-00;0', _Value);
      17:
        _Result := FormatMaskText('000000\-00000\-0000\-000;0', _Value);
      18:
        _Result := FormatMaskText('000000\-00000\-0000\-0000;0', _Value);
      19:
        _Result := FormatMaskText('000000\-00000\-0000\-00000;0', _Value);
      20:
        _Result := FormatMaskText('000000\-00000\-0000\-00000;0', _Value);
      21:
        _Result := FormatMaskText('000000\-00000\-0000\-00000\-00;0', _Value);
      22:
        _Result := FormatMaskText('000000\-00000\-0000\-00000\-000;0', _Value);
      23:
        _Result := FormatMaskText('000000\-00000\-0000\-00000\-0000;0', _Value);
      24:
        _Result := FormatMaskText('000000\-00000\-0000\-00000\-0000\0;0', _Value);
    else
      _Result := _Value;
    end;

    if Length(_Value) > 28 then
      _Result := FormatMaskText('000000\-00000\-0000\-00000\-0000\0;0', Copy(_Value, 1, 28));

    AEdit.Text := Trim(StringReplace(_Result, ' ', '', [rfReplaceAll]));
    AEdit.SelStart := Length(AEdit.Text);
  end;
end;

class procedure TMasks.SetMaskCNPJ(AEdit: TEdit);
var
  _Value, _Result: string;
const
  Mask = '__.___.___/____-__';
begin
  _Value := TString.OnlyNumeric(AEdit.Text);
  AEdit.GoToTextEnd;
  AEdit.MaxLength := Length(Mask);
  AEdit.TextPrompt := AEdit.Hint;
  AEdit.KeyboardType := TVirtualKeyBoardType.NumberPad;

  if (_Value <> '') then
  begin
    case Length(_Value) of
      1:
        _Result := FormatMaskText('0', _Value);
      2:
        _Result := FormatMaskText('00;0', _Value);
      3:
        _Result := FormatMaskText('00\.;0', _Value);
      4:
        _Result := FormatMaskText('00\.0;0', _Value);
      5:
        _Result := FormatMaskText('00\.00;0', _Value);
      6:
        _Result := FormatMaskText('00\.000\.;0', _Value);
      7:
        _Result := FormatMaskText('00\.000\.0;0', _Value);
      8:
        _Result := FormatMaskText('00\.000\.000;0', _Value);
      9:
        _Result := FormatMaskText('00\.000\.000\/;0', _Value);
      10:
        _Result := FormatMaskText('00\.000\.000\/0;0', _Value);
      11:
        _Result := FormatMaskText('00\.000\.000\/00;0', _Value);
      12:
        _Result := FormatMaskText('00\.000\.000\/000;0', _Value);
      13:
        _Result := FormatMaskText('00\.000\.000\/0000\-0;0', _Value);
      14:
        _Result := FormatMaskText('00\.000\.000\/0000\-0;0', _Value);
      15:
        _Result := FormatMaskText('00\.000\.000\/0000\-00;0', _Value);
    end;

    if Length(_Value) > 14 then
      _Result := FormatMaskText('00\.000\.000\/0000\-00;0', Copy(_Value, 1, 14));

    AEdit.Text := _Result;
    AEdit.SelStart := Length(AEdit.Text);
  end;
end;

class procedure TMasks.SetMaskCPF(AEdit: TEdit);
var
  _Value, _Result: string;
const
  Mask = '___.___.___-__';
begin
  _Value := TString.OnlyNumeric(AEdit.Text);
  AEdit.GoToTextEnd;
  AEdit.MaxLength := Length(Mask);
  AEdit.TextPrompt := Mask;
  AEdit.KeyboardType := TVirtualKeyBoardType.NumberPad;

  if (_Value <> '') then
  begin
    case Length(_Value) of
      1:
        _Result := FormatMaskText('0', _Value);
      2:
        _Result := FormatMaskText('00;0', _Value);
      3:
        _Result := FormatMaskText('000;0', _Value);
      4:
        _Result := FormatMaskText('000\.;0', _Value);
      5:
        _Result := FormatMaskText('000\.0;0', _Value);
      6:
        _Result := FormatMaskText('000\.00;0', _Value);
      7:
        _Result := FormatMaskText('000\.000\.;0', _Value);
      8:
        _Result := FormatMaskText('000\.000\.;0', _Value);
      9:
        _Result := FormatMaskText('000\.000\.0;0', _Value);
      10:
        _Result := FormatMaskText('000\.000\.000\-;0', _Value);
      11:
        _Result := FormatMaskText('000\.000\.000\-00;0', _Value);
    else
      _Result := _Value;
    end;

    if Length(_Value) > 11 then
      _Result := FormatMaskText('000\.000\.000\-00;0', Copy(_Value, 1, 11));

    AEdit.Text := _Result;
    AEdit.SelStart := Length(AEdit.Text);
  end;
end;

class procedure TMasks.SetMaskFone(AEdit: TEdit);
var
  _Value, _Result: string;
const
  Mask = '(__) _____-____';
begin
  _Value := TString.OnlyNumeric(AEdit.Text);
  AEdit.GoToTextEnd;
  AEdit.MaxLength := Length(Mask);
  AEdit.TextPrompt := Mask;
  AEdit.KeyboardType := TVirtualKeyBoardType.NumberPad;

  if (_Value <> '') then
  begin
    case Length(_Value) of
      1:
        _Result := FormatMaskText('\(0;0', _Value);
      2:
        _Result := FormatMaskText('\(00;0', _Value);
      3:
        _Result := FormatMaskText('\(00\) ;0', _Value);
      4:
        _Result := FormatMaskText('\(00\) 0;0', _Value);
      5:
        _Result := FormatMaskText('\(00\) 00;0', _Value);
      6:
        _Result := FormatMaskText('\(00\) 000;0', _Value);
      7:
        _Result := FormatMaskText('\(00\) 0000;0', _Value);
      8:
        _Result := FormatMaskText('\(00\) 0000\-;0', _Value);
      9:
        _Result := FormatMaskText('\(00\) 0000\-00;0', _Value);
      10:
        _Result := FormatMaskText('\(00\) 0000\-000;0', _Value);
      11:
        _Result := FormatMaskText('\(00\) 00000\-0000;0', _Value);
    else
      _Result := _Value;
    end;

    if Length(_Value) > 11 then
      _Result := FormatMaskText('\(00\) 00000\-0000;0', Copy(_Value, 1, 11));

    AEdit.Text := _Result;
    AEdit.SelStart := Length(AEdit.Text);
  end;
end;

class procedure TMasks.SetMaskCEP(AEdit: TEdit);
var
  _Value, _Result: string;
const
  Mask = '__.___-___';
begin
  _Value := TString.OnlyNumeric(AEdit.Text);
  AEdit.GoToTextEnd;
  AEdit.MaxLength := Length(Mask);
  AEdit.TextPrompt := Mask;
  AEdit.KeyboardType := TVirtualKeyBoardType.NumberPad;

  if (_Value <> '') then
  begin
    case Length(_Value) of
      1:
        _Result := FormatMaskText('0', _Value);
      2:
        _Result := FormatMaskText('00;0', _Value);
      3:
        _Result := FormatMaskText('00\.0;0', _Value);
      4:
        _Result := FormatMaskText('00\.00;0', _Value);
      5:
        _Result := FormatMaskText('00\.000;0', _Value);
      6:
        _Result := FormatMaskText('00\.000\-0;0', _Value);
      7:
        _Result := FormatMaskText('00\.000\-00;0', _Value);
      8:
        _Result := FormatMaskText('00\.000\-000;0', _Value);
    end;

    if Length(_Value) > 8 then
      _Result := FormatMaskText('00\.000\-000;0', Copy(_Value, 1, 8));

    AEdit.Text := _Result;
    AEdit.SelStart := Length(AEdit.Text);
  end;
end;

class procedure TMasks.SetMaskMoneyKeyUp(AEdit: TEdit; var KeyChar: Char);
var
  str_valor: String;
begin
  if (KeyChar.IsNumber) then
  begin
    if (KeyChar.IsNumber) and (Length(Trim(AEdit.Text)) > 23) then
      KeyChar := #0;
    if AEdit.Text = '' then
      AEdit.Text := '0,00';
    str_valor :=
      Trim(CurrToStrF(StrToCurrDef(Trim(FloatToStr(StrToFloat(TString.OnlyNumeric(AEdit.Text)) / 100)), 0), ffCurrency, 2));
    if KeyChar = #0 then
      Delete(str_valor, Length(str_valor), 1);
    str_valor := FormatFloat('0.00', StrToCurr(StringReplace(TString.OnlyNumeric(AEdit.Text), '.', ',', [rfReplaceAll])) / 100);
    AEdit.Text := str_valor;
  end;
  AEdit.GoToTextEnd;
  KeyChar := #0;
end;

class procedure TMasks.SetMaskMonthYear2D(AEdit: TEdit; var Key: Word);
var
  _Value, _Result: string;
begin
  _Value := TString.OnlyNumeric(AEdit.Text);
  AEdit.GoToTextEnd;
  AEdit.MaxLength := 5;

  if ((Key <> 8) and (Key <> 46)) then
  begin
    if (_Value <> '') then
    begin
      case Length(_Value) of
        2:
          _Result := FormatMaskText('00\/;0', _Value);
        3:
          _Result := FormatMaskText('00\/0;0', _Value);
        4:
          _Result := FormatMaskText('00\/00;0', _Value);
      else
        _Result := _Value;
      end;

      if Length(_Value) > 4 then
        _Result := FormatMaskText('00\/00;0', Copy(_Value, 1, 4));

      AEdit.Text := _Result;
      AEdit.GoToTextEnd;
    end;
  end;
end;

class procedure TMasks.SetMaskMonthYear4D(AEdit: TEdit; var Key: Word);
var
  _Value, _Result: string;
begin
  _Value := TString.OnlyNumeric(AEdit.Text);
  AEdit.GoToTextEnd;
  AEdit.MaxLength := 7;

  if ((Key <> 8) and (Key <> 46)) then
  begin
    if (_Value <> '') then
    begin
      case Length(_Value) of
        2:
          _Result := FormatMaskText('00\/;0', _Value);
        3:
          _Result := FormatMaskText('00\/0;0', _Value);
        4:
          _Result := FormatMaskText('00\/00;0', _Value);
        5:
          _Result := FormatMaskText('00\/000;0', _Value);
        6:
          _Result := FormatMaskText('00\/0000;0', _Value);
      else
        _Result := _Value;
      end;

      if Length(_Value) > 6 then
        _Result := FormatMaskText('00\/0000;0', Copy(_Value, 1, 6));

      AEdit.Text := _Result;
      AEdit.GoToTextEnd;
    end;
  end;
end;

class procedure TMasks.SetMaskDate2D(AEdit: TEdit; var Key: Word);
var
  _Value, _Result: string;
begin
  _Value := TString.OnlyNumeric(AEdit.Text);
  AEdit.GoToTextEnd;
  AEdit.MaxLength := 8;

  if ((Key <> 8) and (Key <> 46)) then
  begin
    if (_Value <> '') then
    begin

      with FormatSettings do
      begin
        DateSeparator := '/';
      end;

      case Length(_Value) of
        2:
          _Result := FormatMaskText('00\/;0', _Value);
        3:
          _Result := FormatMaskText('00\/0;0', _Value);
        4:
          _Result := FormatMaskText('00\/00;0', _Value);
        5:
          _Result := FormatMaskText('00\/00\/;0', _Value);
        6:
          _Result := FormatMaskText('00\/00\/0;0', _Value);
        7:
          _Result := FormatMaskText('00\/00\/00;0', _Value);
      else
        _Result := _Value;
      end;

      if Length(_Value) > 6 then
        _Result := FormatMaskText('00\/00\/00;0', Copy(_Value, 1, 6));

      AEdit.Text := _Result;
      AEdit.GoToTextEnd;

      with FormatSettings do
      begin
        DateSeparator := '-';
      end;
    end;
  end;
end;

class procedure TMasks.SetMaskDate4D(AEdit: TEdit; var Key: Word);
var
  _Value, _Result: string;
begin
  _Value := TString.OnlyNumeric(AEdit.Text);
  AEdit.GoToTextEnd;
  AEdit.MaxLength := 10;

  if ((Key <> 8) and (Key <> 46)) then
  begin
    if (_Value <> '') then
    begin

      with FormatSettings do
      begin
        DateSeparator := '/';
      end;

      case Length(_Value) of
        0:
          _Result := FormatMaskText('0;0', _Value);
        1:
          _Result := FormatMaskText('00;0', _Value);
        2:
          _Result := FormatMaskText('00\/;0', _Value);
        3:
          _Result := FormatMaskText('00\/0;0', _Value);
        4:
          _Result := FormatMaskText('00\/00;0', _Value);
        5:
          _Result := FormatMaskText('00\/00\/;0', _Value);
        6:
          _Result := FormatMaskText('00\/00\/0;0', _Value);
        7:
          _Result := FormatMaskText('00\/00\/00;0', _Value);
        8:
          _Result := FormatMaskText('00\/00\/000;0', _Value);
        9:
          _Result := FormatMaskText('00\/00\/0000;0', _Value);
      else
        _Result := _Value;
      end;

      if Length(_Value) > 8 then
        _Result := FormatMaskText('00\/00\/0000;0', Copy(_Value, 1, 8));

      AEdit.Text := _Result;
      AEdit.GoToTextEnd;

      with FormatSettings do
      begin
        DateSeparator := '-';
      end;
    end;
  end;
end;

class procedure TMasks.SetMaskTime(AEdit: TEdit; var Key: Word);
var
  _Value, _Result: string;
begin
  _Value := TString.OnlyNumeric(AEdit.Text);
  AEdit.GoToTextEnd;
  AEdit.MaxLength := 8;

  if ((Key <> 8) and (Key <> 46)) then
  begin
    if (_Value <> '') then
    begin
      case Length(_Value) of
        0:
          _Result := FormatMaskText('0;0', _Value);
        1:
          _Result := FormatMaskText('00;0', _Value);
        2:
          _Result := FormatMaskText('00\:;0', _Value);
        3:
          _Result := FormatMaskText('00\:0;0', _Value);
        4:
          _Result := FormatMaskText('00\:00;0', _Value);
        5:
          _Result := FormatMaskText('00\:00\:;0', _Value);
        6:
          _Result := FormatMaskText('00\:00\:0;0', _Value);
        7:
          _Result := FormatMaskText('00\:00\:00;0', _Value);
      else
        _Result := _Value;
      end;

      if Length(_Value) > 6 then
        _Result := FormatMaskText('00\:00\:00;0', Copy(_Value, 1, 6));

      AEdit.Text := _Result;
      AEdit.GoToTextEnd;
    end;
  end;
end;

class function TMasks.SetMaskKeyDown(const Value: String; var KeyChar: Char; var Key: Word; SelStart: Integer; MaxLength: Integer; DecimalLength: Integer = 4; const Symbol: String = ''): String;
var
  StrSymbol, IntValue, StrValue: String;
  DblValue: Extended;
  FormatBr: TFormatSettings;
begin
  FormatBr                     := TFormatSettings.Create;
  FormatBr.DecimalSeparator    := ',';
  FormatBr.ThousandSeparator   := '.';

  System.SysUtils.FormatSettings := FormatBr;

  if DecimalLength > 4 then
    raise EIntError.CreateFmt('O Parâmetro DecimalLength[%d] não pode ser maior que DecimalLength[4]', [DecimalLength]);

  if ( ( not(CharInSet(KeyChar, ['0'..'9']) ) ) and ( not(Key in[8]) ) ) then
  begin
    Result := Value;
    KeyChar := #0;
    Key := 0;
    Exit;
  end;

  StrSymbol := System.StrUtils.IfThen(Symbol <> EmptyStr, Symbol + ' ', Symbol);
  MaxLength := System.Math.IfThen(DecimalLength > 2, 19, 20);

  StrValue := Value;
  StrValue := System.StrUtils.IfThen(KeyChar.IsNumber, Concat(StrValue, KeyChar), StrValue);

  IntValue := TRegEx.Replace(StrValue, '\D', '');
  DblValue := StrToFloat(IntValue) / StrToInt(String('1').PadRight(DecimalLength+1, '0'));

  if (KeyChar.IsNumber) then
  begin
    if MaxLength > Length(Value)+(System.Math.IfThen(DecimalLength = 0, 1, 0)) then
      Result := StrSymbol + TFloat.ToString(FloatToStr(DblValue), DecimalLength, TResultMode.Truncate, TResultFormat.BR)
    else
      Result := Value;
  end;

  if (Key = 8) then
  begin
    if Value <> EmptyStr then
    begin
      Key := 0;
      Result := StrSymbol + TFloat.ToString(LeftStr(FloatToStr(DblValue), Length(FloatToStr(DblValue))-1), DecimalLength, TResultMode.Truncate, TResultFormat.BR);
    end;
  end;

  KeyChar := #0;
  Key := 0;
  Exit;
end;

class procedure TMasks.SetMaskFloatKeyDown(AEdit: TEdit; var KeyChar: Char; var Key: Word; DecimalLength: Integer = 4; const Symbol: String = '');
begin
  if ( not(Key in[9, 13, 27]) ) then
  begin
    AEdit.Text := TMasks.SetMaskKeyDown(AEdit.Text, KeyChar, Key, AEdit.SelStart, AEdit.MaxLength, DecimalLength, Symbol);
    AEdit.GoToTextEnd;
  end;
end;

class procedure TMasks.SetMaskMoneyKeyDown(AEdit: TEdit; var KeyChar: Char; var Key: Word; DecimalLength: Integer = 2; const Symbol: String = 'R$');
begin
  if ( not(Key in[9, 13, 27]) ) then
  begin
    AEdit.Text := TMasks.SetMaskKeyDown(AEdit.Text, KeyChar, Key, AEdit.SelStart, AEdit.MaxLength, DecimalLength, Symbol);
    AEdit.GoToTextEnd;
  end;
end;

end.
