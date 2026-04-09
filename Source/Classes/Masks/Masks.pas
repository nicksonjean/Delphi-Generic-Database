unit Masks;

{ TMasks — record utilitário de máscaras de digitação para TEdit (FMX).
  ------------------------------------------------------------------------------
  Motor central: ApplyPattern(ADigits, APattern)
    • APattern define o formato final: '0' = slot de entrada, qualquer outro
      caractere = separador literal (ex.: '.', '-', '/', '(', ')', ' ', ':').
    • Percorre o template inserindo os dígitos nas posições certas, parando
      quando os dígitos acabam — sem case/FormatMaskText por tipo de máscara.

  SetupNumericMask / SetupAlphaMask / SetupMoney / SetupFloat
    • Usam AEdit.OnKeyPress (bridge FMX→VCL via TEditHelper) em vez de
      OnKeyDown + OnKeyUp. O handler recebe apenas KeyChar: WideChar —
      #8 = backspace, #0 = cancela a tecla. A lógica é linear e sem Shift.

  SetMaskXxx públicos
    • Mantidos para chamada avulsa (sem Setup). Agora delegam ao ApplyPattern.
  ------------------------------------------------------------------------------ }

interface

uses
  System.UITypes,
  FMX.Types,
  FMX.Edit,
  FMX.Edit.Helper;

type
  TMasks = record
  public
    { Setup completo: configura TextPrompt, KeyboardType e OnKeyPress }
    class procedure SetupCPF        (AEdit: TEdit); static;
    class procedure SetupCNPJ       (AEdit: TEdit); static;
    class procedure SetupCEP        (AEdit: TEdit); static;
    class procedure SetupFone       (AEdit: TEdit); static;
    class procedure SetupSerial     (AEdit: TEdit); static;
    class procedure SetupMonthYear2D(AEdit: TEdit); static;
    class procedure SetupMonthYear4D(AEdit: TEdit); static;
    class procedure SetupDate2D     (AEdit: TEdit); static;
    class procedure SetupDate4D     (AEdit: TEdit); static;
    class procedure SetupTime       (AEdit: TEdit); static;
    class procedure SetupMoney      (AEdit: TEdit; DecimalLength: Integer = 2; const Symbol: string = 'R$'); static;
    class procedure SetupFloat      (AEdit: TEdit; DecimalLength: Integer = 4; const Symbol: string = '');  static;

    { Filtros avulsos — bloqueiam teclas inválidas em OnKeyDown externo }
    class procedure FilterNumericOnly     (var KeyChar: Char; var Key: Word); static;
    class procedure FilterAlphaNumericOnly(var KeyChar: Char; var Key: Word); static;

    { Formatadores públicos — aplicam máscara diretamente no conteúdo atual de AEdit }
    class procedure SetMaskCPF        (AEdit: TEdit); static;
    class procedure SetMaskCNPJ       (AEdit: TEdit); static;
    class procedure SetMaskCEP        (AEdit: TEdit); static;
    class procedure SetMaskFone       (AEdit: TEdit); static;
    class procedure SetMaskSerial     (AEdit: TEdit); static;
    class procedure SetMaskMonthYear2D(AEdit: TEdit; var Key: Word); static;
    class procedure SetMaskMonthYear4D(AEdit: TEdit; var Key: Word); static;
    class procedure SetMaskDate2D     (AEdit: TEdit; var Key: Word); static;
    class procedure SetMaskDate4D     (AEdit: TEdit; var Key: Word); static;
    class procedure SetMaskTime       (AEdit: TEdit; var Key: Word); static;
    class procedure SetMaskMoney(AEdit: TEdit; var KeyChar: WideChar; DecimalLength: Integer = 2; const Symbol: string = 'R$'); static;
    class procedure SetMaskFloat(AEdit: TEdit; var KeyChar: WideChar; DecimalLength: Integer = 4; const Symbol: string = ''); static;

  private
    { Motor de padrão: insere ADigits nos slots '0' de APattern }
    class function  ApplyPattern(const ADigits, APattern: string): string; static;
    { Handlers genéricos de Setup }
    class procedure SetupNumericMask(AEdit: TEdit; const APrompt, APattern: string; AMaxDigits: Integer; AKeyboard: TVirtualKeyBoardType); static;
    class procedure SetupAlphaMask  (AEdit: TEdit; const APrompt, APattern: string; AMaxDigits: Integer); static;
    { Motor de valor monetário / float }
    class function  ApplyMoneyMask(const AValue: string; var KeyChar: WideChar; ADecimalLength: Integer; const ASymbol: string): string; static;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  System.RegularExpressions,
  System.Character,
  System.Classes,
  &Type.&Float,
  &Type.&String;

const
  { Padrões de formato: '0' = slot de dígito/char, outros = separador literal }
  PAT_CPF        = '000.000.000-00';     // 11 dígitos
  PAT_CNPJ       = '00.000.000/0000-00'; // 14 dígitos
  PAT_CEP        = '00.000-000';         //  8 dígitos
  PAT_FONE       = '(00) 00000-0000';    // 11 dígitos
  PAT_SERIAL     = '000000-00000-0000-00000-0000'; // 24 alfanum.
  PAT_MONTHYR_2D = '00/00';              //  4 dígitos
  PAT_MONTHYR_4D = '00/0000';            //  6 dígitos
  PAT_DATE_2D    = '00/00/00';           //  6 dígitos
  PAT_DATE_4D    = '00/00/0000';         //  8 dígitos
  PAT_TIME       = '00:00:00';           //  6 dígitos

// =============================================================================
// Motor central
// =============================================================================

{ Percorre APattern caractere a caractere:
    '0'          → consome o próximo elemento de ADigits
    qualquer outro → insere como separador literal, MAS somente se ainda houver
                    dígitos a consumir depois dele no padrão (evita separador
                    pendente no final).
  Resultado: string formatada com exatamente os dígitos disponíveis. }
class function TMasks.ApplyPattern(const ADigits, APattern: string): string;
var
  I, D: Integer;
begin
  Result := '';
  D      := 1;
  for I := 1 to Length(APattern) do
  begin
    if D > Length(ADigits) then Break;
    if APattern[I] = '0' then
    begin
      Result := Result + ADigits[D];
      Inc(D);
    end
    else
      Result := Result + APattern[I]; // separador: só chega aqui se D ≤ Length
  end;
end;

// =============================================================================
// Handlers genéricos de Setup
// =============================================================================

class procedure TMasks.SetupNumericMask(AEdit: TEdit; const APrompt, APattern: string;
  AMaxDigits: Integer; AKeyboard: TVirtualKeyBoardType);
begin
  AEdit.TextPrompt   := APrompt;
  AEdit.KeyboardType := AKeyboard;
  AEdit.OnKeyPress   := procedure(Sender: TObject; var KeyChar: WideChar)
    var
      Edit  : TEdit;
      Digits: string;
    begin
      Edit   := TEdit(Sender);
      Digits := TString.OnlyNumeric(Edit.Text);

      if KeyChar = #8 then              // Backspace sintetizado pelo bridge
      begin
        if Digits <> '' then SetLength(Digits, Length(Digits) - 1);
        Edit.Text := ApplyPattern(Digits, APattern);
        Edit.GoToTextEnd; KeyChar := #0; Exit;
      end;

      if not CharInSet(KeyChar, ['0'..'9']) then begin KeyChar := #0; Exit; end;
      if Length(Digits) >= AMaxDigits       then begin KeyChar := #0; Exit; end;

      Edit.Text := ApplyPattern(Digits + KeyChar, APattern);
      Edit.GoToTextEnd; KeyChar := #0;
    end;
end;

class procedure TMasks.SetupAlphaMask(AEdit: TEdit; const APrompt, APattern: string;
  AMaxDigits: Integer);
begin
  AEdit.TextPrompt   := APrompt;
  AEdit.KeyboardType := TVirtualKeyBoardType.Alphabet;
  AEdit.OnKeyPress   := procedure(Sender: TObject; var KeyChar: WideChar)
    var
      Edit : TEdit;
      Chars: string;
    begin
      Edit  := TEdit(Sender);
      Chars := TString.OnlyAlphaNumeric(Edit.Text);

      if KeyChar = #8 then              // Backspace sintetizado pelo bridge
      begin
        if Chars <> '' then SetLength(Chars, Length(Chars) - 1);
        Edit.Text := ApplyPattern(Chars, APattern);
        Edit.GoToTextEnd; KeyChar := #0; Exit;
      end;

      if not CharInSet(KeyChar, ['0'..'9', 'a'..'z', 'A'..'Z']) then begin KeyChar := #0; Exit; end;
      if Length(Chars) >= AMaxDigits                              then begin KeyChar := #0; Exit; end;

      Edit.Text := ApplyPattern(Chars + KeyChar, APattern);
      Edit.GoToTextEnd; KeyChar := #0;
    end;
end;

// =============================================================================
// Setup público — cada um é uma única linha
// =============================================================================

class procedure TMasks.SetupCPF(AEdit: TEdit);
begin SetupNumericMask(AEdit, '___.___.___-__',    PAT_CPF,        11, TVirtualKeyBoardType.NumberPad); end;

class procedure TMasks.SetupCNPJ(AEdit: TEdit);
begin SetupNumericMask(AEdit, '__.___.___/____-__', PAT_CNPJ,      14, TVirtualKeyBoardType.NumberPad); end;

class procedure TMasks.SetupCEP(AEdit: TEdit);
begin SetupNumericMask(AEdit, '__.___-___',         PAT_CEP,        8, TVirtualKeyBoardType.NumberPad); end;

class procedure TMasks.SetupFone(AEdit: TEdit);
begin SetupNumericMask(AEdit, '(__) _____-____',    PAT_FONE,      11, TVirtualKeyBoardType.NumberPad); end;

class procedure TMasks.SetupSerial(AEdit: TEdit);
begin SetupAlphaMask  (AEdit, 'XXXXXX-XXXXX-XXXX-XXXXX-XXXX', PAT_SERIAL, 24); end;

class procedure TMasks.SetupMonthYear2D(AEdit: TEdit);
begin SetupNumericMask(AEdit, 'MM/AA',      PAT_MONTHYR_2D, 4, TVirtualKeyBoardType.NumberPad); end;

class procedure TMasks.SetupMonthYear4D(AEdit: TEdit);
begin SetupNumericMask(AEdit, 'MM/AAAA',    PAT_MONTHYR_4D, 6, TVirtualKeyBoardType.NumberPad); end;

class procedure TMasks.SetupDate2D(AEdit: TEdit);
begin SetupNumericMask(AEdit, 'DD/MM/AA',   PAT_DATE_2D,    6, TVirtualKeyBoardType.NumberPad); end;

class procedure TMasks.SetupDate4D(AEdit: TEdit);
begin SetupNumericMask(AEdit, 'DD/MM/AAAA', PAT_DATE_4D,    8, TVirtualKeyBoardType.NumberPad); end;

class procedure TMasks.SetupTime(AEdit: TEdit);
begin SetupNumericMask(AEdit, 'HH:MM:SS',   PAT_TIME,       6, TVirtualKeyBoardType.NumberPad); end;

class procedure TMasks.SetupMoney(AEdit: TEdit; DecimalLength: Integer; const Symbol: string);
begin
  AEdit.KeyboardType := TVirtualKeyBoardType.NumberPad;
  AEdit.OnKeyPress   := procedure(Sender: TObject; var KeyChar: WideChar)
    var Edit: TEdit;
    begin
      Edit := TEdit(Sender);
      if not (CharInSet(KeyChar, ['0'..'9']) or (KeyChar = #8)) then Exit;
      Edit.Text := ApplyMoneyMask(Edit.Text, KeyChar, DecimalLength, Symbol);
      Edit.GoToTextEnd;
    end;
end;

class procedure TMasks.SetupFloat(AEdit: TEdit; DecimalLength: Integer; const Symbol: string);
begin
  AEdit.KeyboardType := TVirtualKeyBoardType.NumberPad;
  AEdit.OnKeyPress   := procedure(Sender: TObject; var KeyChar: WideChar)
    var Edit: TEdit;
    begin
      Edit := TEdit(Sender);
      if not (CharInSet(KeyChar, ['0'..'9']) or (KeyChar = #8)) then Exit;
      Edit.Text := ApplyMoneyMask(Edit.Text, KeyChar, DecimalLength, Symbol);
      Edit.GoToTextEnd;
    end;
end;

// =============================================================================
// Filtros avulsos
// =============================================================================

class procedure TMasks.FilterNumericOnly(var KeyChar: Char; var Key: Word);
begin
  if not (CharInSet(KeyChar, ['0'..'9']) or (Key in [vkBack, vkDelete, vkLeft, vkRight, vkHome, vkEnd])) then
  begin KeyChar := #0; Key := 0; end;
end;

class procedure TMasks.FilterAlphaNumericOnly(var KeyChar: Char; var Key: Word);
begin
  if not (CharInSet(KeyChar, ['0'..'9', 'a'..'z', 'A'..'Z']) or (Key in [vkBack, vkDelete, vkLeft, vkRight, vkHome, vkEnd])) then
  begin KeyChar := #0; Key := 0; end;
end;

// =============================================================================
// Formatadores públicos — chamada avulsa sem Setup
// =============================================================================

class procedure TMasks.SetMaskCPF(AEdit: TEdit);
begin AEdit.Text := ApplyPattern(TString.OnlyNumeric(AEdit.Text), PAT_CPF); AEdit.GoToTextEnd; end;

class procedure TMasks.SetMaskCNPJ(AEdit: TEdit);
begin AEdit.Text := ApplyPattern(TString.OnlyNumeric(AEdit.Text), PAT_CNPJ); AEdit.GoToTextEnd; end;

class procedure TMasks.SetMaskCEP(AEdit: TEdit);
begin AEdit.Text := ApplyPattern(TString.OnlyNumeric(AEdit.Text), PAT_CEP); AEdit.GoToTextEnd; end;

class procedure TMasks.SetMaskFone(AEdit: TEdit);
begin AEdit.Text := ApplyPattern(TString.OnlyNumeric(AEdit.Text), PAT_FONE); AEdit.GoToTextEnd; end;

class procedure TMasks.SetMaskSerial(AEdit: TEdit);
begin AEdit.Text := ApplyPattern(TString.OnlyAlphaNumeric(AEdit.Text), PAT_SERIAL); AEdit.GoToTextEnd; end;

class procedure TMasks.SetMaskMonthYear2D(AEdit: TEdit; var Key: Word);
begin
  if (Key = vkBack) or (Key = vkDelete) then Exit;
  AEdit.Text := ApplyPattern(TString.OnlyNumeric(AEdit.Text), PAT_MONTHYR_2D);
  AEdit.GoToTextEnd;
end;

class procedure TMasks.SetMaskMonthYear4D(AEdit: TEdit; var Key: Word);
begin
  if (Key = vkBack) or (Key = vkDelete) then Exit;
  AEdit.Text := ApplyPattern(TString.OnlyNumeric(AEdit.Text), PAT_MONTHYR_4D);
  AEdit.GoToTextEnd;
end;

class procedure TMasks.SetMaskDate2D(AEdit: TEdit; var Key: Word);
begin
  if (Key = vkBack) or (Key = vkDelete) then Exit;
  AEdit.Text := ApplyPattern(TString.OnlyNumeric(AEdit.Text), PAT_DATE_2D);
  AEdit.GoToTextEnd;
end;

class procedure TMasks.SetMaskDate4D(AEdit: TEdit; var Key: Word);
begin
  if (Key = vkBack) or (Key = vkDelete) then Exit;
  AEdit.Text := ApplyPattern(TString.OnlyNumeric(AEdit.Text), PAT_DATE_4D);
  AEdit.GoToTextEnd;
end;

class procedure TMasks.SetMaskTime(AEdit: TEdit; var Key: Word);
begin
  if (Key = vkBack) or (Key = vkDelete) then Exit;
  AEdit.Text := ApplyPattern(TString.OnlyNumeric(AEdit.Text), PAT_TIME);
  AEdit.GoToTextEnd;
end;

// =============================================================================
// Motor monetário / float
// =============================================================================

class function TMasks.ApplyMoneyMask(const AValue: string; var KeyChar: WideChar;
  ADecimalLength: Integer; const ASymbol: string): string;
var
  StrSymbol, IntPart, StrValue: string;
  DblValue: Extended;
  Fmt: TFormatSettings;
begin
  if ADecimalLength > 4 then
    raise EIntError.CreateFmt('DecimalLength[%d] não pode exceder 4', [ADecimalLength]);

  if not (CharInSet(KeyChar, ['0'..'9']) or (KeyChar = #8)) then
  begin
    Result := AValue; KeyChar := #0; Exit;
  end;

  Fmt                   := TFormatSettings.Create;
  Fmt.DecimalSeparator  := ',';
  Fmt.ThousandSeparator := '.';
  System.SysUtils.FormatSettings := Fmt;

  StrSymbol := IfThen(ASymbol <> '', ASymbol + ' ', '');
  StrValue  := IfThen(KeyChar.IsNumber, AValue + KeyChar, AValue);
  IntPart   := TRegEx.Replace(StrValue, '\D', '');
  DblValue  := StrToFloatDef(IntPart, 0) / StrToIntDef('1' + StringOfChar('0', ADecimalLength), 1);

  if KeyChar.IsNumber then
  begin
    if IfThen(ADecimalLength > 2, 19, 20) > Length(AValue) + IfThen(ADecimalLength = 0, 1, 0) then
      Result := StrSymbol + TFloat.ToString(FloatToStr(DblValue), ADecimalLength, TResultMode.Truncate, TResultFormat.BR)
    else
      Result := AValue;
  end
  else if KeyChar = #8 then
  begin
    if AValue <> '' then
      Result := StrSymbol + TFloat.ToString(
        LeftStr(FloatToStr(DblValue), Length(FloatToStr(DblValue)) - 1),
        ADecimalLength, TResultMode.Truncate, TResultFormat.BR);
  end;

  KeyChar := #0;
end;

class procedure TMasks.SetMaskMoney(AEdit: TEdit; var KeyChar: WideChar;
  DecimalLength: Integer; const Symbol: string);
begin
  if not (CharInSet(KeyChar, ['0'..'9']) or (KeyChar = #8)) then Exit;
  AEdit.Text := ApplyMoneyMask(AEdit.Text, KeyChar, DecimalLength, Symbol);
  AEdit.GoToTextEnd;
end;

class procedure TMasks.SetMaskFloat(AEdit: TEdit; var KeyChar: WideChar;
  DecimalLength: Integer; const Symbol: string);
begin
  if not (CharInSet(KeyChar, ['0'..'9']) or (KeyChar = #8)) then Exit;
  AEdit.Text := ApplyMoneyMask(AEdit.Text, KeyChar, DecimalLength, Symbol);
  AEdit.GoToTextEnd;
end;

end.
