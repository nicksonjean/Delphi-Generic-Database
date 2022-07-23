{
  Strings.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a formata��o de Textos.
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
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

unit Strings;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Generics.Collections,
  System.RegularExpressions,
  System.RTLConsts,
  System.Variants,
  System.Rtti,
  System.WideStrUtils,
  Data.DB,
  REST.JSON;

const
  EMPTYCHAR : Char = #0; //EmptyStr para Char
  LF : Char = #10; //<LINE FEED>
  CR : Char = #13; //<CARRIAGE RETURN>
  SUB : Char = #26; //<SUBSTITUTE>
  DQUOTE : Char = #34; //"
  SQUOTE : Char = #39; //'
  COMMA : Char = #44; //,
  COLON : Char = #58; //:
  SEMICOLON : Char = #59; //;
  LTAG : Char = #60; //<
  EQUAL : Char = #61; //=
  RTAG : Char = #62; //>
  LROUNDBRACKET : Char = #40; //(
  RROUNDBRACKET : Char = #41; //)
  LCURLYBRACKET : Char = #123; //{
  RCURLYBRACKET : Char = #125; //}
  LSQUAREBRACKET : Char = #91; //[
  RSQUAREBRACKET : Char = #93; //]
  CTAG : String = '</';
  PIPE : Char = #124; //|
  CBAR : Char = #92; //\
  SSPACE : Char = #32; //\s
  DSPACE : String = '  '; //\s\s
  EOL : String = #13#10; //\r\n
  XML : String = '<?xml version="1.0" encoding="UTF-8"?>';
  NUL : String = 'null';
  NULER : String = '\b(\w*null|NULL\w*)\b';
  SYMBOLS = '[-()\"#\/@;:<>{}`+=~|?!@#$%^&*a-zA-Z\s]';
  ZEROFILLED : String = '^\-?(?:[0+])\d+$';
  NUMERIC : String = '^\-?(?![0+])\d+$';
  DECIMAL : String = '^\-?\d+[\,\.]\d+$';

type
  {$IFDEF Unicode}
  TBinary = RawByteString;
  {$ELSE}
  TBinary = AnsiString;
  {$ENDIF}

type
  TString = class
  private
    { Private declarations }
  public
    { Public declarations }
    class function OnlyAlpha(Text: String): String; static;
    class function OnlyValues(Text: String): String; static;
    class function OnlyNumeric(Text: String): String; static;
    class function OnlyAlphaNumeric(Text: String): String; static;
    class function IsNull(Text: String): Boolean;
    class function IsZeroFilled(Text: String): Boolean;
    class function IsNumeric(Text: String): Boolean;
    class function IsDecimal(Text: String): Boolean;
    class function RealEscapeStrings(const Text: String): String;
    class function FromTags(Input, Column: String): String;
    class function IsUTF8(const Text: TBinary): boolean; static;
    class function IsAnsi(const Text: String): Boolean; static;
    class function IndentTag(Input, Replace : String): String;
    class function RemoveLastComma(Input : String): String;
    class function RemoveLastCommaEOL(Input : String): String;
    class function RemoveLastEOL(Input : String): String;
    class function RemoveSpecialChars(Text : String): String;
    class function ExtractStringBetweenDelimiters(Input: String; Delim1, Delim2: String): String;
    class function StringReplace(Text: String; OldPattern, NewPattern: TArray<String>; Flags: TReplaceFlags): String;
    class function StrArrayJoin(const StringArray: Array of String; const Separator: string) : string;
    class function JoinStrings(const S: Array of String; Delimiter: Char): string;
    class function Quote(Text : String; Quote: String = #39): String;
  end;

implementation

{ TString }

class function TString.OnlyAlpha(Text: String): String;
begin
  Result := Trim(TRegEx.Replace(Text, '[^\w]', EmptyStr));
end;

class function TString.OnlyValues(Text: String): String;
begin
  Result := Trim(TRegEx.Replace(Text, Symbols, EmptyStr));
end;

class function TString.Quote(Text : String; Quote: String = #39): String;
begin
  Result := Quote + Text + Quote;
end;

class function TString.OnlyNumeric(Text: String): String;
begin
  Result := Trim(TRegEx.Replace(Text, '[^\d]', EmptyStr));
end;

class function TString.OnlyAlphaNumeric(Text: String): String;
begin
  Result := Trim(TRegEx.Replace(Text, '[^\d\w]', EmptyStr));
end;

class function TString.IsNull(Text: String): Boolean;
begin
  Result := TRegEx.IsMatch(Text, NULER);
end;

class function TString.IsZeroFilled(Text: String): Boolean;
begin
  Result := TRegEx.IsMatch(Text, ZEROFILLED);
end;

class function TString.IsNumeric(Text: String): Boolean;
begin
  Result := TRegEx.IsMatch(Text, NUMERIC);
end;

class function TString.IsDecimal(Text: String): Boolean;
begin
  Result := TRegEx.IsMatch(Text, DECIMAL);
end;

class function TString.StringReplace(Text: String; OldPattern, NewPattern: TArray<String>; Flags: TReplaceFlags): String;
var
  I: Integer;
begin
  Assert(Length(OldPattern) = (Length(NewPattern)));
  Result := Text;
  for I := Low(OldPattern) to High(OldPattern) do
    Result := System.SysUtils.StringReplace(Result, OldPattern[I], NewPattern[I], Flags);
end;

class function TString.RemoveSpecialChars(Text : String): String;
begin
  Result := Self.StringReplace(Text, [LF, CR, EOL], [EmptyStr, EmptyStr, EmptyStr], [rfReplaceAll]);
end;

class function TString.RealEscapeStrings(const Text : String): String;
begin
  Result := Self.StringReplace(Text,
    [CBAR,      DQUOTE,      SQUOTE,      EMPTYCHAR, LF,    CR,   SUB],
    [CBAR+CBAR, CBAR+DQUOTE, CBAR+SQUOTE, '\0',     '\n', '\r',  '\Z'],
    [rfReplaceAll]
  );
  {
  Result := Self.StringReplace(Text,
    ['\' , #39  , #34  , #0 , #10, #13, #26],
    ['\\','\'#39,'\'#34,'\0','\n','\r','\Z'],
    [rfReplaceAll]
  );
  }
end;

class function TString.ExtractStringBetweenDelimiters(Input: String; Delim1, Delim2: String): String;
var
  aPos, bPos: Integer;
begin
  result := '';
  aPos := Pos(Delim1, Input);
  if aPos > 0 then 
  begin
    bPos := PosEx(Delim2, Input, aPos + Length(Delim1));
    if bPos > 0 then 
      result := Copy(Input, aPos + Length(Delim1), bPos - (aPos + Length(Delim1)));
  end;
end;

class function TString.IsUTF8(const Text : TBinary): Boolean;
begin
  Result := IsUTF8String(Text);
end;

class function TString.IsAnsi(const Text: String): Boolean;
var
  tempansi : AnsiString;
  temp : String;
begin
  tempansi := AnsiString(Text);
  temp := String(tempansi);
  Result := temp = Text;
end;

class function TString.IndentTag(Input, Replace: String): String;
var
  Regex: TRegEx;
begin
  Regex := TRegEx.Create('^([^<]*)<(.*)', [roMultiLine]);
  Result := Regex.Replace(Input, '$1' + Replace + '<$2');
end;

class function TString.FromTags(Input, Column: String): String;
begin
  Result := Self.ExtractStringBetweenDelimiters(Input, LTAG + Column + RTAG, CTAG + Column + LTAG);
end;

class function TString.RemoveLastComma(Input: String): String;
begin
  if Input[Length(Input)-2] = Comma then
    System.Delete(Input, Length(Input)-2, 1)
  else
    System.Delete(Input, Length(Input), 1);
  Result := Input;
end;

class function TString.RemoveLastCommaEOL(Input: String): String;
begin
  if Input[Length(Input)-2] = Comma then
    System.Delete(Input, Length(Input)-2, 3)
  else
    System.Delete(Input, Length(Input)-1, 2);
  Result := Input;
end;

class function TString.RemoveLastEOL(Input: String): String;
begin
  if Input[Length(Input)-1] = EOL then
    System.Delete(Input, Length(Input)-1, 2);
  Result := Input;
end;

class function TString.StrArrayJoin(const StringArray: Array of String; const Separator: string) : string;
var
  I : Integer;
begin
  Result := EmptyStr;
  for I := low(StringArray) to high(StringArray) do
    Result := Result + StringArray[I] + Separator;
  Delete(Result, Length(Result), 1);
end;

class function TString.JoinStrings(const S: Array of String; Delimiter: Char): string;
var
  I, C: Integer;
  P: PChar;
begin
  C := 0;
  for I := 0 to High(S) do
    Inc(C, Length(S[I]));
  SetLength(Result, C + High(S));
  P := PChar(Result);
  for I := 0 to High(S) do 
  begin
    if I > 0 then 
    begin
      P^ := Delimiter;
      Inc(P);
    end;
    Move(PChar(S[I])^, P^, SizeOf(Char)*Length(S[I]));
    Inc(P, Length(S[I]));
  end;
end;

end.
