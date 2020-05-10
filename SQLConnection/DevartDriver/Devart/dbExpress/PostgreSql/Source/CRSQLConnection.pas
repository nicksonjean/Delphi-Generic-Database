{$IFNDEF CLR}
unit CRSQLConnection;
{$ENDIF}

{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}
{$WARN UNIT_PLATFORM OFF}
{$WARN UNIT_DEPRECATED OFF}

{$I dbx.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows, Messages,
{$ENDIF}
  SysUtils, Classes, DB,
{$IFNDEF VER11P}
  DriverOptions,
  DBXpress,
{$ENDIF}
  Variants, SqlExpr;

type
{$IFDEF VER16P}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64 or pidOSX32)]
{$ENDIF}
  TCRSQLConnection = class(TSQLConnection)
  private
  protected
  {$IFNDEF VER11P}
    procedure ConnectionOptions; override;
  {$ENDIF}
  public
  published
  end;

implementation

{ TCRSQLConnection }

{$IFNDEF VER11P}
procedure TCRSQLConnection.ConnectionOptions;
var
  i: integer;
  SQLOption: integer;
  SQLOptionValue: Variant;
  ParamName: string;
  ParamValue: string;
  ConvertStrings: boolean;
begin
  if Params.Values[SUseQuoteChar] <> '' then
  {$IFDEF CLR}
    ISQLConnection_SetOption(SQLConnection, TSQLConnectionOption(coUseQuoteChar), LongInt(UpperCase(trim(Params.Values[SUseQuoteChar])) = 'TRUE'));
  {$ELSE}
    SQLConnection.SetOption(TSQLConnectionOption(coUseQuoteChar), LongInt(UpperCase(trim(Params.Values[SUseQuoteChar])) = 'TRUE'));
  {$ENDIF}

  inherited;

  ConvertStrings := False;
{$IFDEF VER180}
{$IFNDEF VER180}
  ConvertStrings := True;
{$ENDIF}
{$ENDIF}

  for i := 0 to Params.Count - 1 do begin
    ParamName := Params.Names[i];
    ParamValue := Copy(Params.Strings[i], Length(ParamName) + 2, MaxInt);
    ConvertOption(ParamName, ParamValue, SQLOption, SQLOptionValue, ConvertStrings);
    if SQLOption <> 0 then
      if SQLOption <> coUseQuoteChar then
        case VarType(SQLOptionValue) of
          varInteger:
          {$IFDEF CLR}
            ISQLConnection_SetOption(SQLConnection, TSQLConnectionOption(SQLOption), Integer(SQLOptionValue));
          {$ELSE}
            SQLConnection.SetOption(TSQLConnectionOption(SQLOption), Integer(SQLOptionValue));
          {$ENDIF}
          varString{$IFDEF WIN32},varOleStr{$ENDIF}{$IFDEF CLR}, varChar{$ENDIF}: 
          {$IFDEF CLR}
            ISQLConnection_SetOption(SQLConnection, TSQLConnectionOption(SQLOption), VarToStr(SQLOptionValue));
          {$ELSE}
          {$IFDEF VER180} // d10 only
            SQLConnection.SetStringOption(TSQLConnectionOption(SQLOption), WideString(SQLOptionValue));
          {$ELSE} // d6, d7, d9w32
            SQLConnection.SetOption(TSQLConnectionOption(SQLOption), Integer(PChar(VarToStr(SQLOptionValue))));
          {$ENDIF}
          {$ENDIF}
        end;
  end;
end;
{$ENDIF}

end.
