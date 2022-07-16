﻿{
  TimeDate
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a convesão, formatação e comparação de datas e horas
  em Delphi.
  Suporta 2 Formatos de Resultado: ResultFormat = (BR, DB);
  OBS.:
  1 - O Formato DB é o Mesmo Utilizado em Campos Date, Time ou DateTime,
  de Bancos de Dados como MySQL/MariaDB, PostgreSQL, SQLite e etc...
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  Co-Autor : Wellington Fonseca
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

unit TimeDate;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  System.RegularExpressions,
  System.DateUtils,
  System.Variants,
  Winapi.Windows,

  FMX.Dialogs,

  Locale,
  &Array
  ;

type
  TLocaleTimeDate = class(TLocale)
  private
    { Private declarations }
    class var _LOCALE_SSHORTDATE, _LOCALE_SLONGDATE, _LOCALE_SDATE, _LOCALE_STIME: String;
    class procedure StoreWindowsLocale();
    class procedure RestoreWindowsLocale();
    class procedure SetWindowsLocale(const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':');
  public
    { Public declarations }
  end;

type
  TRegexDateTime = class
  private
    { Private declarations }
    const TIME_SEPARATOR = '[\s\/\|\:.-]';
    const DATE_SEPARATOR = TIME_SEPARATOR + '?';
    const HOURS = '[0-1][0-9]|2[0-3]';
    const MINUTES = '[0-5][0-9]';
    const SECONDS = MINUTES;
    const HOURS_12 = '(?<hours_12>0[1-9]|1[0-2])';
    const HOURS_24 = '(?<hours_24>' + HOURS + ')';
    const MINUTES_12 = '(?<minutes_12>' + MINUTES + ')';
    const MINUTES_24 = '(?<minutes_24>' + MINUTES + ')';
    const SECONDS_12 = '(?<seconds_12>' + SECONDS + ')';
    const SECONDS_24 = '(?<seconds_24>' + SECONDS + ')';
    const MERIDIAN = '(?<meridian>[AaPp][Mm])';
    const TIMEZONE = '(?<timezone>Z|[+-]' + '(?:' + HOURS + ')' + TIME_SEPARATOR + '(?:' + MINUTES + ')' + ')';
    const DAYS_28 = '(?<day_28>0[1-9]|1[0-9]|2[0-8])';
    const DAYS_30 = '(?<day_30>0[1-9]|[1-2][0-9]|30)';
    const DAYS_31 = '(?<day_31>0[1-9]|[1-2][0-9]|3[01])';
    const MONTHS_28 = '(?<month_28>02)';
    const MONTHS_30 = '(?<month_30>0[13456789]|1[012])';
    const MONTHS_31 = '(?<month_31>0[13578]|1[02])';
    const LEAP_DAY = '(?<leap_day>29)';
    const LEAP_MONTH = '(?<leap_month>02)';
    const LEAP_YEAR = '(?<leap_year>(?:\d{0,2}(?:0[48]|[2468][048]|[13579][26]))|(?:(?:[02468][048])|[13579][26])00)';
    const YEAR = '(?<year>\d{2,4})';
    class function Get(Regex: String; Init: Integer = 1; Term: Integer = 0): String;
    class function HNSM: String;   //10:10:59 AM/PM
    class function HNSZ: String;   //10:10:59 +02:00
    class function HNSF: String;   //10:10:59 *
    class function YMD: String;    //2020-02-29
    class function MDY: String;    //02.29.2020
    class function DMY: String;    //29/02/2020
    class function YMDHNS: String; //2020-02-29 10:10:59 *
    class function MDYHNS: String; //02.29.2020 10:10:59 *
    class function DMYHNS: String; //29/02/2020 10:10:59 *
  public
    { Public declarations }
  end;

type
  TTimeDate = class(TRegexDateTime)
  private
    { Private declarations }
    function GetNOW: TDateTime;
    function GetTIME: TDateTime;
    function GetDATE: TDateTime;
    function GetTODAY: TDateTime;
    function GetTOMORROW: TDateTime;
    function GetYESTERDAY: TDateTime;
  public
    { Public declarations }
    class function IsValidTime(Value: String): Boolean;
    class function IsValidDate(Value: String): Boolean;
    class function IsValidDateTime(Value: String): Boolean;
    class function IsValid(Value: String): Boolean;
    class function ToArrayTime(Value: String; IsValid : Boolean = False): TArrayVariant;
    class function ToArrayDate(Value: String; IsValid : Boolean = False): TArrayVariant;
    class function ToArrayDateTime(Value: String; IsValid : Boolean = False): TArrayVariant;
    class function ToArray(Value: String; IsValid : Boolean = False): TArrayVariant;
    class function ToTime(Value: String; const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':'): TTime;
    class function ToDate(Value: String; const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':'): TDate;
    class function ToDateTime(Value: String; const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':'): TDateTime;
    class function ToTimeString(Value: String; const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':'): String;
    class function ToDateString(Value: String; const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':'): String;
    class function ToDateTimeString(Value: String; const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':'): String;
    class function ToFormat(Value: String; const Format: String): String;
    class function ToSQL(Value: String): String;
    property NOW: TDateTime read GetNOW;
    property TIME: TDateTime read GetTIME;
    property DATE: TDateTime read GetDATE;
    property TODAY: TDateTime read GetTODAY;
    property TOMORROW: TDateTime read GetTOMORROW;
    property YESTERDAY: TDateTime read GetYESTERDAY;
  end;

implementation

{ TLocaleTimeDate }

class procedure TLocaleTimeDate.RestoreWindowsLocale();
begin
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SSHORTDATE, PWideChar(PWideString(WideString(_LOCALE_SSHORTDATE))));
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SLONGDATE, PWideChar(PWideString(WideString(_LOCALE_SLONGDATE))));
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDATE, PWideChar(PWideString(WideString(_LOCALE_SDATE))));
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_STIME, PWideChar(PWideString(WideString(_LOCALE_STIME))));
end;

class procedure TLocaleTimeDate.StoreWindowsLocale();
begin
  _LOCALE_SSHORTDATE := TLocale.GetWindowsLocale(LOCALE_SSHORTDATE);
  _LOCALE_SLONGDATE := TLocale.GetWindowsLocale(LOCALE_SLONGDATE);
  _LOCALE_SDATE := TLocale.GetWindowsLocale(LOCALE_SDATE);
  _LOCALE_STIME := TLocale.GetWindowsLocale(LOCALE_STIME);
end;

class procedure TLocaleTimeDate.SetWindowsLocale(const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':');
begin
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SSHORTDATE, PWideChar(PWideString(WideString(&ShortDateFormat))));
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SLONGDATE, PWideChar(PWideString(WideString(&LongDateFormat))));
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDATE, PWideChar(PWideString(WideString(&DateSeparator))));
  SetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_STIME, PWideChar(PWideString(WideString(&TimeSeparator))));
  with FormatSettings do
  begin
    ShortDateFormat := LowerCase(&ShortDateFormat);
    LongDateFormat := LowerCase(&LongDateFormat);
    DateSeparator := &DateSeparator;
    TimeSeparator := &TimeSeparator;
  end;
end;

{ TRegexDateTime }

class function TRegexDateTime.Get(Regex: String; Init: Integer = 1; Term: Integer = 0): String;
begin
  Result := Copy(Regex, Init, Length(Regex) - Term);
end;

class function TRegexDateTime.HNSM: String;
begin
  Result := '^(?:' + HOURS_12 + TIME_SEPARATOR + MINUTES_12 + TIME_SEPARATOR + '?' + SECONDS_12 + '?' + TIME_SEPARATOR + '?' + MERIDIAN + '?)?$';
end;

class function TRegexDateTime.HNSZ: String;
begin
  Result := '^(?:(?:' + HOURS_24 + TIME_SEPARATOR + MINUTES_24 + ')' + TIME_SEPARATOR + '?' + SECONDS_24 + '?' + TIME_SEPARATOR + '?' + TIMEZONE + '?)?$';
end;

class function TRegexDateTime.HNSF: String;
begin
  Result := '^(?:' + Self.Get(Self.HNSM, 2, 2) + '|' + Self.Get(Self.HNSZ, 2, 2) + ')$';
end;

class function TRegexDateTime.YMD: String;
begin
  Result := '^(?:' + YEAR + DATE_SEPARATOR + '(?:(?:' + MONTHS_31 + DATE_SEPARATOR + DAYS_31 + ')|(?:' + MONTHS_30 + DATE_SEPARATOR + DAYS_30 + ')|(?:' + MONTHS_28 + DATE_SEPARATOR + DAYS_28 + '))|(?:' + LEAP_YEAR + DATE_SEPARATOR + LEAP_MONTH + DATE_SEPARATOR + LEAP_DAY + '))$';
end;

class function TRegexDateTime.MDY: String;
begin
  Result := '^(?:(?:(?:' + MONTHS_31 + DATE_SEPARATOR + DAYS_31 + ')|(?:' + MONTHS_30 + DATE_SEPARATOR + DAYS_30 + ')|(?:' + MONTHS_28 + DATE_SEPARATOR + DAYS_28 + '))' + DATE_SEPARATOR + YEAR + '|(?:' + LEAP_MONTH + DATE_SEPARATOR + LEAP_DAY + DATE_SEPARATOR + LEAP_YEAR + '))$';
end;

class function TRegexDateTime.DMY: String;
begin
  Result := '^(?:(?:(?:' + DAYS_31 + DATE_SEPARATOR + MONTHS_31 + ')|(?:' + DAYS_30 + DATE_SEPARATOR + MONTHS_30 + ')|(?:' + DAYS_28 + DATE_SEPARATOR + MONTHS_28 + '))' + DATE_SEPARATOR + YEAR + '|(?:' + LEAP_DAY + DATE_SEPARATOR + LEAP_MONTH + DATE_SEPARATOR + LEAP_YEAR + '))$';
end;

class function TRegexDateTime.YMDHNS: String;
begin
  Result := '^(?:' + Self.Get(Self.YMD, 2, 2) + DATE_SEPARATOR + Self.Get(Self.HNSF, 2, 2) + ')$';
end;

class function TRegexDateTime.MDYHNS: String;
begin
  Result := '^(?:' + Self.Get(Self.MDY, 2, 2) + DATE_SEPARATOR + Self.Get(Self.HNSF, 2, 2) + ')$';
end;

class function TRegexDateTime.DMYHNS: String;
begin
  Result := '^(?:' + Self.Get(Self.DMY, 2, 2) + DATE_SEPARATOR + Self.Get(Self.HNSF, 2, 2) + ')$';
end;

{ TTimeDate }

function TTimeDate.GetNOW: TDateTime;
begin
  Result := System.SysUtils.Now;
end;

function TTimeDate.GetDATE: TDateTime;
begin
  Result := System.SysUtils.Date;
end;

function TTimeDate.GetTIME: TDateTime;
begin
  Result := System.SysUtils.Time;
end;

function TTimeDate.GetTODAY: TDateTime;
begin
  Result := System.DateUtils.Today;
end;

function TTimeDate.GetTOMORROW: TDateTime;
begin
  Result := System.DateUtils.Tomorrow;
end;

function TTimeDate.GetYESTERDAY: TDateTime;
begin
  Result := System.DateUtils.Yesterday;
end;

class function TTimeDate.IsValidTime(Value: String): Boolean;
begin
  if TRegEx.IsMatch(Value, TRegexDateTime.HNSM) then
    Result := True
  else if TRegEx.IsMatch(Value, TRegexDateTime.HNSZ) then
    Result := True
  else
    Result := False;
end;

class function TTimeDate.IsValidDate(Value: String): Boolean;
begin
  if TRegEx.IsMatch(Value, TRegexDateTime.YMD) then
    Result := True
  else if TRegEx.IsMatch(Value, TRegexDateTime.MDY) then
    Result := True
  else if TRegEx.IsMatch(Value, TRegexDateTime.DMY) then
    Result := True
  else
    Result := False;
end;

class function TTimeDate.IsValidDateTime(Value: String): Boolean;
begin
  if TRegEx.IsMatch(Value, TRegexDateTime.YMDHNS) then
    Result := True
  else if TRegEx.IsMatch(Value, TRegexDateTime.MDYHNS) then
    Result := True
  else if TRegEx.IsMatch(Value, TRegexDateTime.DMYHNS) then
    Result := True
  else
    Result := False;
end;

class function TTimeDate.IsValid(Value: String): Boolean;
begin
  if Self.isValidTime(Value) then
    Result := True
  else if Self.isValidDate(Value) then
    Result := True
  else if Self.isValidDateTime(Value) then
    Result := True
  else
    Result := False;
end;

class function TTimeDate.ToArrayTime(Value: String; IsValid : Boolean = False): TArrayVariant;
var
  Match: TMatch;
  Return : TArrayVariant;
begin
  Return := TArrayVariant.Create;
  Return.Clear;
  IsValid := Self.IsValidTime(Value);
  if IsValid then
  begin
    Match := TRegEx.Create(TRegexDateTime.HNSM, [roIgnoreCase, roMultiline, roExplicitCapture]).Match(Value);
    if Match.Success then
    begin
      Return['hours'] := Match.Groups['hours_12'].Value;
      Return['minutes'] := Match.Groups['minutes_12'].Value;
      Return['seconds'] := Match.Groups['seconds_12'].Value;
      if Match.Groups.Count > 4 then
        Return['meridian'] := Match.Groups['meridian'].Value;
    end;
    Match := TRegEx.Create(TRegexDateTime.HNSZ, [roIgnoreCase, roMultiline, roExplicitCapture]).Match(Value);
    if Match.Success then
    begin
      Return['hours'] := Match.Groups['hours_24'].Value;
      Return['minutes'] := Match.Groups['minutes_24'].Value;
      Return['seconds'] := Match.Groups['seconds_24'].Value;
      if Match.Groups.Count > 4 then
        Return['timezone'] := Match.Groups['timezone'].Value;
    end;
  end;
  Result := Return;
end;

class function TTimeDate.ToArrayDate(Value: String; IsValid: Boolean = False): TArrayVariant;
var
  Match: TMatch;
  Return: TArrayVariant;
  I, J: Integer;
begin
  Return := TArrayVariant.Create;
  Return.Clear;
  IsValid := Self.IsValidDate(Value);
  J := 0;  
  if IsValid then
  begin
    Match := TRegEx.Create(TRegexDateTime.YMD, [roIgnoreCase, roMultiline]).Match(Value);
    if Match.Success then
    begin
      while Match.Success do
      begin
        if Match.Groups.Count > 1 then
        begin
          for I := 1 to Match.Groups.Count -1 do
          begin
            if Match.Groups.Item[I].Value <> EmptyStr then
            begin
              if J = 0 then             
                Return['year'] := Match.Groups.Item[I].Value;
              if J = 1 then              
                Return['month'] := Match.Groups.Item[I].Value;
              if J = 2 then              
                Return['day'] := Match.Groups.Item[I].Value;
              Inc(J);
            end;
          end;
        end;
        Match := Match.NextMatch;
      end;
    end;
    Match := TRegEx.Create(TRegexDateTime.MDY, [roIgnoreCase, roMultiline]).Match(Value);
    if Match.Success then
    begin
      while Match.Success do
      begin
        if Match.Groups.Count > 1 then
        begin
          for I := 1 to Match.Groups.Count -1 do
          begin
            if Match.Groups.Item[I].Value <> EmptyStr then
            begin
              if J = 0 then             
                Return['month'] := Match.Groups.Item[I].Value;                
              if J = 1 then              
                Return['day'] := Match.Groups.Item[I].Value;                
              if J = 2 then              
                Return['year'] := Match.Groups.Item[I].Value;
              Inc(J);
            end;
          end;
        end;
        Match := Match.NextMatch;
      end;
    end;
    Match := TRegEx.Create(TRegexDateTime.DMY, [roIgnoreCase, roMultiline]).Match(Value);
    if Match.Success then
    begin
      while Match.Success do
      begin
        if Match.Groups.Count > 1 then
        begin
          for I := 1 to Match.Groups.Count -1 do
          begin
            if Match.Groups.Item[I].Value <> EmptyStr then
            begin
              if J = 0 then
                Return['day'] := Match.Groups.Item[I].Value;                               
              if J = 1 then              
                Return['month'] := Match.Groups.Item[I].Value;                
              if J = 2 then              
                Return['year'] := Match.Groups.Item[I].Value;
              Inc(J);
            end;
          end;
        end;
        Match := Match.NextMatch;
      end;
    end;
  end;
  Result := Return;
end;

class function TTimeDate.ToArrayDateTime(Value: String; IsValid: Boolean = False): TArrayVariant;
var
  Match: TMatch;
  Return: TArrayVariant;
  I, J: Integer;
begin
  Return := TArrayVariant.Create;
  Return.Clear;
  IsValid := Self.IsValidDateTime(Value);
  J := 0;
  if IsValid then
  begin
    Match := TRegEx.Create(TRegexDateTime.YMDHNS, [roIgnoreCase, roMultiline]).Match(Value);
    if Match.Success then
    begin
      while Match.Success do
      begin
        if Match.Groups.Count > 1 then
        begin
          for I := 1 to Match.Groups.Count -1 do
          begin
            if Match.Groups.Item[I].Value <> EmptyStr then
            begin
              if J = 0 then
                Return['year'] := Match.Groups.Item[I].Value;
              if J = 1 then
                Return['month'] := Match.Groups.Item[I].Value;
              if J = 2 then
                Return['day'] := Match.Groups.Item[I].Value;
              if J = 3 then
                Return['hours'] := Match.Groups.Item[I].Value;
              if J = 4 then
                Return['minutes'] := Match.Groups.Item[I].Value;
              if J = 5 then
                Return['seconds'] := Match.Groups.Item[I].Value;
              if J = 6 then
              begin
                if TRegEx.IsMatch(Match.Groups.Item[I].Value, '^' + TRegexDateTime.MERIDIAN + '$') then
                  Return['meridian'] := Match.Groups.Item[I].Value
                else
                  Return['timezone'] := Match.Groups.Item[I].Value;
              end;
              Inc(J);
            end;
          end;
        end;
        Match := Match.NextMatch;
      end;
    end;
    Match := TRegEx.Create(TRegexDateTime.MDYHNS, [roIgnoreCase, roMultiline]).Match(Value);
    if Match.Success then
    begin
      while Match.Success do
      begin
        if Match.Groups.Count > 1 then
        begin
          for I := 1 to Match.Groups.Count -1 do
          begin
            if Match.Groups.Item[I].Value <> EmptyStr then
            begin
              if J = 0 then
                Return['month'] := Match.Groups.Item[I].Value;
              if J = 1 then
                Return['day'] := Match.Groups.Item[I].Value;
              if J = 2 then
                Return['year'] := Match.Groups.Item[I].Value;
              if J = 3 then
                Return['hours'] := Match.Groups.Item[I].Value;
              if J = 4 then
                Return['minutes'] := Match.Groups.Item[I].Value;
              if J = 5 then
                Return['seconds'] := Match.Groups.Item[I].Value;
              if J = 6 then
              begin
                if TRegEx.IsMatch(Match.Groups.Item[I].Value, '^' + TRegexDateTime.MERIDIAN + '$') then
                  Return['meridian'] := Match.Groups.Item[I].Value
                else
                  Return['timezone'] := Match.Groups.Item[I].Value;
              end;
              Inc(J);
            end;
          end;
        end;
        Match := Match.NextMatch;
      end;
    end;
    Match := TRegEx.Create(TRegexDateTime.DMYHNS, [roIgnoreCase, roMultiline]).Match(Value);
    if Match.Success then
    begin
      while Match.Success do
      begin
        if Match.Groups.Count > 1 then
        begin
          for I := 1 to Match.Groups.Count -1 do
          begin
            if Match.Groups.Item[I].Value <> EmptyStr then
            begin
              if J = 0 then
                Return['day'] := Match.Groups.Item[I].Value;
              if J = 1 then
                Return['month'] := Match.Groups.Item[I].Value;
              if J = 2 then
                Return['year'] := Match.Groups.Item[I].Value;
              if J = 3 then
                Return['hours'] := Match.Groups.Item[I].Value;
              if J = 4 then
                Return['minutes'] := Match.Groups.Item[I].Value;
              if J = 5 then
                Return['seconds'] := Match.Groups.Item[I].Value;
              if J = 6 then
              begin
                if TRegEx.IsMatch(Match.Groups.Item[I].Value, '^' + TRegexDateTime.MERIDIAN + '$') then
                  Return['meridian'] := Match.Groups.Item[I].Value
                else
                  Return['timezone'] := Match.Groups.Item[I].Value;
              end;
              Inc(J);
            end;
          end;
        end;
        Match := Match.NextMatch;
      end;
    end;
  end;
  Result := Return;
end;

class function TTimeDate.ToArray(Value: String; IsValid : Boolean = False): TArrayVariant;
var
  Return : TArrayVariant;
begin
  Return := TArrayVariant.Create;
  Return.Clear;

  IsValid := Self.IsValidTime(Value);
  if IsValid then
    Return := Self.ToArrayTime(Value, IsValid);

  IsValid := Self.IsValidDate(Value);
  if IsValid then
    Return := Self.ToArrayDate(Value, IsValid);

  IsValid := Self.IsValidDateTime(Value);
  if IsValid then
    Return := Self.ToArrayDateTime(Value, IsValid);

  Result := Return;
end;

class function TTimeDate.ToTime(Value: String; const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':'): TTime;
begin
  TLocaleTimeDate.StoreWindowsLocale();
  TLocaleTimeDate.SetWindowsLocale(&ShortDateFormat, &LongDateFormat, &DateSeparator, &TimeSeparator);
  try
    Result := TTimeDate(Self).GetTIME;//#
  finally
    TLocaleTimeDate.RestoreWindowsLocale();
  end;
end;

class function TTimeDate.ToDate(Value: String; const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':'): TDate;
begin
  TLocaleTimeDate.StoreWindowsLocale();
  TLocaleTimeDate.SetWindowsLocale(&ShortDateFormat, &LongDateFormat, &DateSeparator, &TimeSeparator);
  try
    Result := TTimeDate(Self).GetDATE;//#
  finally
    TLocaleTimeDate.RestoreWindowsLocale();
  end;
end;

class function TTimeDate.ToDateTime(Value: String; const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':'): TDateTime;
begin
  TLocaleTimeDate.StoreWindowsLocale();
  TLocaleTimeDate.SetWindowsLocale(&ShortDateFormat, &LongDateFormat, &DateSeparator, &TimeSeparator);
  try
    Result := TTimeDate(Self).GetNOW;//#
  finally
    TLocaleTimeDate.RestoreWindowsLocale();
  end;
end;

class function TTimeDate.ToTimeString(Value: String; const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':'): String;
begin

  TLocaleTimeDate.StoreWindowsLocale();
  TLocaleTimeDate.SetWindowsLocale(&ShortDateFormat, &LongDateFormat, &DateSeparator, &TimeSeparator);
  try

  finally
    TLocaleTimeDate.RestoreWindowsLocale();
  end;
end;

class function TTimeDate.ToDateString(Value: String; const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':'): String;
begin

  TLocaleTimeDate.StoreWindowsLocale();
  TLocaleTimeDate.SetWindowsLocale(&ShortDateFormat, &LongDateFormat, &DateSeparator, &TimeSeparator);
  try

  finally
    TLocaleTimeDate.RestoreWindowsLocale();
  end;
end;

class function TTimeDate.ToDateTimeString(Value: String; const &ShortDateFormat : String = 'yyyy-MM-dd'; const &LongDateFormat : String = 'yyyy-MM-dd hh:nn:ss'; const &DateSeparator : Char = '-'; const &TimeSeparator : Char = ':'): String;
begin

  TLocaleTimeDate.StoreWindowsLocale();
  TLocaleTimeDate.SetWindowsLocale(&ShortDateFormat, &LongDateFormat, &DateSeparator, &TimeSeparator);
  try

  finally
    TLocaleTimeDate.RestoreWindowsLocale();
  end;
end;

class function TTimeDate.ToFormat(Value: String; const Format: String): String;
begin
  Result := '';
end;

class function TTimeDate.ToSQL(Value: String): String;
var
  Return : TArrayVariant;
begin
  Return := TArrayVariant.Create;
  Return.Clear;

  if Self.IsValidTime(Value) then
  begin
    Return := Self.ToArrayTime(Value);
    Result := Return['hours'] + ':' + Return['minutes'] + ':' + Return['seconds'];
  end
  else if Self.IsValidDate(Value) then
  begin
    Return := Self.ToArrayDate(Value);
    Result := Return['year'] + '-' + Return['month'] + '-' + Return['day'];
  end
  else if Self.IsValidDateTime(Value) then
  begin
    Return := Self.ToArrayDateTime(Value);
    Result := Return['year'] + '-' + Return['month'] + '-' + Return['day'] + ' ' + Return['hours'] + ':' + Return['minutes'] + ':' + Return['seconds'];
  end
  else
    Result := Value;
end;

end.