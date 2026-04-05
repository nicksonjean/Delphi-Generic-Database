{
  Connection.Config.INI
  ------------------------------------------------------------------------------
  Objetivo : Criar e configurar um TConnection a partir de um arquivo INI.
  Formato esperado:

    [Connection]
    Engine=FireDAC
    Driver=MySQL
    Host=localhost
    Port=3306
    Schema=public
    Database=app
    Username=root
    Password=senha

    [Args]
    CharacterSet=UTF8
    Compress=True

  O campo Engine na seção [Connection] é obrigatório.
  Retorna TConnection configurada sem conectar.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.INI;

interface

uses
  Connection;

type
  TConnectionConfigINI = class
  public
    { Lê AFileName como arquivo INI e retorna um TConnection configurado (sem conectar).
      Lança EArgumentException se o arquivo não existir ou contiver engine desconhecida. }
    class function LoadFromFile(const AFileName: String): TConnection;
    { Lê ASource como conteúdo INI em memória e retorna um TConnection configurado. }
    class function Load(const ASource: String): TConnection;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,
  Connection.Types;

const
  SEC_CONNECTION = 'Connection';
  SEC_ARGS       = 'Args';

{ Lógica compartilhada — recebe qualquer TCustomIniFile }
function InternalLoadFromINI(const AINI: TCustomIniFile): TConnection;
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
  EngineStr := AINI.ReadString(SEC_CONNECTION, 'Engine', EmptyStr);
  if EngineStr = EmptyStr then
    raise EArgumentException.Create('Connection config INI: [Connection] Engine= is required.');
  if not StringToEngine(EngineStr, Engine) then
    raise EArgumentException.CreateFmt('Unknown engine: %s', [EngineStr]);

  Result := TConnection.Create(Engine);

  { Driver — opcional }
  DriverStr := AINI.ReadString(SEC_CONNECTION, 'Driver', EmptyStr);
  if (DriverStr <> EmptyStr) and StringToDriver(DriverStr, Driver) then
    Result.Driver := Driver;

  { Parâmetros de conexão }
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

  { Senha pode ser vazia intencionalmente }
  PasswordVal := AINI.ReadString(SEC_CONNECTION, 'Password', EmptyStr);
  Result.Password := PasswordVal;

  { Seção [Args] — opcional }
  ArgsKeys := TStringList.Create;
  try
    AINI.ReadSection(SEC_ARGS, ArgsKeys);
    for Key in ArgsKeys do
      Result.AddArgument(Key, AINI.ReadString(SEC_ARGS, Key, EmptyStr));
  finally
    ArgsKeys.Free;
  end;
end;

{ TConnectionConfigINI }

class function TConnectionConfigINI.LoadFromFile(const AFileName: String): TConnection;
var
  INI: TIniFile;
begin
  if not FileExists(AFileName) then
    raise EArgumentException.CreateFmt('INI file not found: %s', [AFileName]);
  INI := TIniFile.Create(AFileName);
  try
    Result := InternalLoadFromINI(INI);
  finally
    INI.Free;
  end;
end;

class function TConnectionConfigINI.Load(const ASource: String): TConnection;
var
  Lines: TStringList;
  INI:   TMemIniFile;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := ASource;
    INI := TMemIniFile.Create(EmptyStr);
    try
      INI.SetStrings(Lines);
      Result := InternalLoadFromINI(INI);
    finally
      INI.Free;
    end;
  finally
    Lines.Free;
  end;
end;

end.
