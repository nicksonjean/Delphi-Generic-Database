{
  Connection.Config.INI.Mapper
  ------------------------------------------------------------------------------
  Objetivo : Mapeamento INI → TConnection.
  Formato  : Seções [Connection] e opcional [Args] (ver Connection.Config.INI).
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.INI.Mapper;

interface

uses
  System.IniFiles,
  Connection;

type
  { Lógica de mapeamento INI — sem herança de loader; usada só pelo loader público. }
  TConnectionConfigIniMapper = class sealed
  public
    class function LoadFromCustomIni(const AINI: TCustomIniFile): TConnection;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  Connection.Types;

const
  SEC_CONNECTION = 'Connection';
  SEC_ARGS       = 'Args';

class function TConnectionConfigIniMapper.LoadFromCustomIni(const AINI: TCustomIniFile): TConnection;
var
  Engine:      TEngine;
  Driver:      TDriver;
  EngineStr:   String;
  DriverStr:   String;
  HostVal:     String;
  SchemaVal:   String;
  DatabaseVal: String;
  UsernameVal: String;
  PasswordVal: String;
  PortVal:     Integer;
  ArgsKeys:    TStringList;
  Key:         String;
begin
  if not Assigned(AINI) then
    raise EArgumentException.Create('Connection config INI: INI object is nil.');
  EngineStr := AINI.ReadString(SEC_CONNECTION, 'Engine', EmptyStr);
  if EngineStr = EmptyStr then
    raise EArgumentException.Create('Connection config INI: [Connection] Engine= is required.');
  if not StringToEngine(EngineStr, Engine) then
    raise EArgumentException.CreateFmt('Unknown engine: %s', [EngineStr]);

  Result := TConnection.Create(Engine);

  DriverStr := AINI.ReadString(SEC_CONNECTION, 'Driver', EmptyStr);
  if (DriverStr <> EmptyStr) and StringToDriver(DriverStr, Driver) then
    Result.Driver := Driver;

  HostVal := AINI.ReadString(SEC_CONNECTION, 'Host', EmptyStr);
  if HostVal <> EmptyStr then Result.Host := HostVal;

  PortVal := AINI.ReadInteger(SEC_CONNECTION, 'Port', 0);
  if PortVal > 0 then Result.Port := PortVal;

  SchemaVal := AINI.ReadString(SEC_CONNECTION, 'Schema', EmptyStr);
  if SchemaVal <> EmptyStr then Result.Schema := SchemaVal;

  DatabaseVal := AINI.ReadString(SEC_CONNECTION, 'Database', EmptyStr);
  if DatabaseVal <> EmptyStr then Result.Database := DatabaseVal;

  UsernameVal := AINI.ReadString(SEC_CONNECTION, 'Username', EmptyStr);
  if UsernameVal <> EmptyStr then Result.Username := UsernameVal;

  PasswordVal := AINI.ReadString(SEC_CONNECTION, 'Password', EmptyStr);
  Result.Password := PasswordVal;

  ArgsKeys := TStringList.Create;
  try
    AINI.ReadSection(SEC_ARGS, ArgsKeys);
    for Key in ArgsKeys do
      Result.AddArgument(Key, AINI.ReadString(SEC_ARGS, Key, EmptyStr));
  finally
    ArgsKeys.Free;
  end;
end;

end.
