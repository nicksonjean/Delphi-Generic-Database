unit FMX.Edit.Helper;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  FMX.Edit;

  {$I Consts.inc}
  {$I Record.inc}

type
  TEditHelper = class helper for TEdit
  private
    { Private declarations }
    function GetIndex: Integer;
    procedure SetIndex(const Value: Integer);
    procedure SetOnItemChange(const Value: TNotifyEvent);
    function GetItems: TStrings;
    function SetMaskKeyDown(const Value: String; var KeyChar: Char; var Key: Word; SelStart : Integer; MaxLength : Integer; DecimalLength: Integer = 4; const Symbol: String = ''): String;
  public
    { Public declarations }
    procedure SetEditControlColor(AColor: TAlphaColor);
    procedure SetMaskSerial;
    procedure SetMaskCPF;
    procedure SetMaskCNPJ;
    procedure SetMaskCEP;
    procedure SetMaskFone;
    procedure SetMaskMonthYear2D(var Key: Word);
    procedure SetMaskMonthYear4D(var Key: Word);
    procedure SetMaskDate2D(var Key: Word);
    procedure SetMaskDate4D(var Key: Word);
    procedure SetMaskTime(var Key: Word);
    procedure SetMaskMoneyKeyUp(var KeyChar: Char);
    procedure SetMaskFloatKeyDown(var KeyChar: Char; var Key: Word; DecimalLength: Integer = 4; const Symbol: String = '');
    procedure SetMaskMoneyKeyDown(var KeyChar: Char; var Key: Word; DecimalLength: Integer = 2; const Symbol: String = 'R$');
    procedure AssignItems(const S: TStrings);
    procedure ForceDropDown;
    procedure PressEnter;
    function SelectedItem: TSelectedItem;
    property OnItemChange: TNotifyEvent write SetOnItemChange;
    property ItemIndex: Integer read GetIndex write SetIndex;
    property Items: TStrings read GetItems;
  end;

implementation

uses
  System.Math,
  System.RegularExpressions,
  System.MaskUtils,
  System.Character,
  System.RTTI,
  FMX.Objects,
  FMX.Types,
  Float,
  &String;

{ TEditHelper }

procedure TEditHelper.PressEnter;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessage(PM_PRESSENTER);
end;

function TEditHelper.SelectedItem: TSelectedItem;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessageWithResult<TSelectedItem>(PM_GET_SELECTEDITEM, Result);
end;

procedure TEditHelper.SetIndex(const Value: Integer);
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessage<Integer>(PM_SET_ITEMINDEX, Value);
end;

procedure TEditHelper.SetOnItemChange(const Value: TNotifyEvent);
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessage<TNotifyEvent>(PM_SET_ITEMCHANGE_EVENT, Value);
end;

procedure TEditHelper.ForceDropDown;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessage(PM_DROP_DOWN);
end;

function TEditHelper.GetIndex: Integer;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessageWithResult<Integer>(PM_GET_ITEMINDEX, Result);
end;

function TEditHelper.GetItems: TStrings;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessageWithResult<TStrings>(PM_GET_ITEMS, Result);
end;

procedure TEditHelper.AssignItems(const S: TStrings);
begin
  Self.Model.Data['suggestions'] := TValue.From<TStrings>(S);
end;

procedure TEditHelper.SetEditControlColor(AColor: TAlphaColor);
var
  T: TFmxObject;
begin
  if TEdit(Self) = nil then
    Exit;
  T := TEdit(Self).FindStyleResource('background');
  if (T <> nil) and (T is TRectangle) then
    if TRectangle(T).Fill <> nil then
      TRectangle(T).Fill.Color := AColor;
  TEdit(Self).Repaint;
end;

procedure TEditHelper.SetMaskSerial;
var
  _Value, _Result: string;
begin
  _Value := TString.OnlyAlphaNumeric(Text);
  GoToTextEnd;
  MaxLength := 28;
  KeyboardType := TVirtualKeyBoardType.Alphabet;

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

    Text := Trim(StringReplace(_Result, ' ', '', [rfReplaceAll]));
    SelStart := Length(Text);
  end;
end;

procedure TEditHelper.SetMaskCNPJ;
var
  _Value, _Result: string;
const
  Mask = '__.___.___/____-__';
begin
  _Value := TString.OnlyNumeric(Text);
  GoToTextEnd;
  MaxLength := Length(Mask);
  //TextPrompt := Mask;
  TextPrompt := Self.Hint;
  KeyboardType := TVirtualKeyBoardType.NumberPad;

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

    Text := _Result;
    SelStart := Length(Text);
  end;
end;

procedure TEditHelper.SetMaskCPF;
var
  _Value, _Result: string;
const
  Mask = '___.___.___-__';
begin
  _Value := TString.OnlyNumeric(Text);
  GoToTextEnd;
  MaxLength := Length(Mask);
  TextPrompt := Mask;
  KeyboardType := TVirtualKeyBoardType.NumberPad;

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

    Text := _Result;
    SelStart := Length(Text);
  end;
end;

procedure TEditHelper.SetMaskFone;
var
  _Value, _Result: string;
const
  Mask = '(__) _____-____';
begin
  _Value := TString.OnlyNumeric(Text);
  GoToTextEnd;
  MaxLength := Length(Mask);
  TextPrompt := Mask;
  KeyboardType := TVirtualKeyBoardType.NumberPad;

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

    Text := _Result;
    SelStart := Length(Text);
  end;
end;

procedure TEditHelper.SetMaskCEP;
var
  _Value, _Result: string;
const
  Mask = '__.___-___';
begin
  _Value := TString.OnlyNumeric(Text);
  GoToTextEnd;
  MaxLength := Length(Mask);
  TextPrompt := Mask;
  KeyboardType := TVirtualKeyBoardType.NumberPad;

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

    Text := _Result;
    SelStart := Length(Text);
  end;
end;

procedure TEditHelper.SetMaskMoneyKeyUp(var KeyChar: Char);
var
  str_valor: String;
begin
  if (KeyChar.IsNumber) then
  begin
    if (KeyChar.IsNumber) and (Length(Trim(Text)) > 23) then
      KeyChar := #0;
    if Text = '' then
      Text := '0,00';
    str_valor :=
      Trim(CurrToStrF(StrToCurrDef(Trim(FloatToStr(StrToFloat(TString.OnlyNumeric(Text)) / 100)), 0), ffCurrency, 2));
    if KeyChar = #0 then
      Delete(str_valor, Length(str_valor), 1);
    str_valor := FormatFloat('0.00', StrToCurr(StringReplace(TString.OnlyNumeric(Text), '.', ',', [rfReplaceAll])) / 100);
    Text := str_valor;
  end;
  GoToTextEnd;
  KeyChar := #0;
end;

procedure TEditHelper.SetMaskMonthYear2D(var Key: Word);
var
  _Value, _Result: string;
begin
  _Value := TString.OnlyNumeric(Text);
  GoToTextEnd;
  MaxLength := 5;

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

      Text := _Result;
      GoToTextEnd;
    end;
  end;
end;

procedure TEditHelper.SetMaskMonthYear4D(var Key: Word);
var
  _Value, _Result: string;
begin
  _Value := TString.OnlyNumeric(Text);
  GoToTextEnd;
  MaxLength := 7;

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

      Text := _Result;
      GoToTextEnd;
    end;
  end;
end;

procedure TEditHelper.SetMaskDate2D(var Key: Word);
var
  _Value, _Result: string;
begin
  _Value := TString.OnlyNumeric(Text);
  GoToTextEnd;
  MaxLength := 8;

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

      Text := _Result;
      GoToTextEnd;

      with FormatSettings do
      begin
        DateSeparator := '-';
      end;
    end;
  end;
end;

procedure TEditHelper.SetMaskDate4D(var Key: Word);
var
  _Value, _Result: string;
begin
  _Value := TString.OnlyNumeric(Text);
  GoToTextEnd;
  MaxLength := 10;

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

      Text := _Result;
      GoToTextEnd;

      with FormatSettings do
      begin
        DateSeparator := '-';
      end;
    end;
  end;
end;

procedure TEditHelper.SetMaskTime(var Key: Word);
var
  _Value, _Result: string;
begin
  _Value := TString.OnlyNumeric(Text);
  GoToTextEnd;
  MaxLength := 8;

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

      Text := _Result;
      GoToTextEnd;
    end;
  end;
end;

function TEditHelper.SetMaskKeyDown(const Value: String; var KeyChar: Char; var Key: Word; SelStart : Integer; MaxLength : Integer; DecimalLength: Integer = 4; const Symbol: String = ''): String;
var
  StrSymbol, IntValue, StrValue: String;
  DblValue: Extended;
  FormatBr: TFormatSettings;
begin
  FormatBr                     := TFormatSettings.Create;
  FormatBr.DecimalSeparator    := ',';
  FormatBr.ThousandSeparator   := '.';

  // Assign the App region settings to the newly created format
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

  // Se a Tecla é Numérica
  if (KeyChar.IsNumber) then
  begin
    if MaxLength > Length(Value)+(System.Math.IfThen(DecimalLength = 0, 1, 0)) then
      Result := StrSymbol + TFloat.ToString(FloatToStr(DblValue), DecimalLength, TResultMode.Truncate, TResultFormat.BR)
    else
      Result := Value;
  end;

  // Se a Tecla é o BackSpace
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

procedure TEditHelper.SetMaskFloatKeyDown(var KeyChar: Char; var Key: Word; DecimalLength: Integer = 4; const Symbol: String = '');
begin
  if ( not(Key in[9, 13, 27]) ) then
  begin
    Text := SetMaskKeyDown(Text, KeyChar, Key, SelStart, MaxLength, DecimalLength, Symbol);
    GoToTextEnd;
  end;
end;

procedure TEditHelper.SetMaskMoneyKeyDown(var KeyChar: Char; var Key: Word; DecimalLength: Integer = 2; const Symbol: String = 'R$');
begin
  if ( not(Key in[9, 13, 27]) ) then
  begin
    Text := SetMaskKeyDown(Text, KeyChar, Key, SelStart, MaxLength, DecimalLength, Symbol);
    GoToTextEnd;
  end;
end;

end.
