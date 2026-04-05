(*
  Connection.Config.JSON
  ------------------------------------------------------------------------------
  Objetivo : Criar e configurar um TConnection a partir de um JSON.
  Formato esperado:
    {
      "engine":   "FireDAC",   (obrigatório)
      "driver":   "MySQL",
      "host":     "localhost",
      "port":     3306,
      "schema":   "public",
      "database": "app",
      "username": "root",
      "password": "senha",
      "args": {
        "CharacterSet": "UTF8",
        "Compress":     "True"
      }
    }
  Retorna TConnection configurada sem abrir a conexão.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
*)

unit Connection.Config.JSON;

interface

uses
  Connection,
  System.JSON;

type
  TConnectionConfigJSON = class
  public
    { Lê ASource como JSON e retorna um TConnection configurado (sem conectar).
      Lança EArgumentException se o JSON for inválido ou contiver engine desconhecida. }
    class function Load(const ASource: String): TConnection;
    { Aplica um objeto JSON já parseado (mesmo esquema de Load). Não libera AJSON. }
    class function LoadFromJSONObject(const AJSON: TJSONObject): TConnection;
  end;

implementation

uses
  System.SysUtils,
  Connection.Types;

class function TConnectionConfigJSON.LoadFromJSONObject(const AJSON: TJSONObject): TConnection;
var
  Engine:   TEngine;
  ArgsObj:  TJSONObject;
  Pair:     TJSONPair;
  Driver:   TDriver;
begin
  if not Assigned(AJSON) then
    raise EArgumentException.Create('Connection config: JSON object is nil.');
  if AJSON.GetValue('engine') = nil then
    raise EArgumentException.Create('Connection config JSON: property "engine" is required.');
  if not StringToEngine(AJSON.GetValue<String>('engine'), Engine) then
    raise EArgumentException.CreateFmt('Unknown engine: %s',
      [AJSON.GetValue<String>('engine')]);

  Result := TConnection.Create(Engine);

  if AJSON.GetValue('driver') <> nil then
  begin
    if StringToDriver(AJSON.GetValue<String>('driver'), Driver) then
      Result.Driver := Driver;
  end;

  if AJSON.GetValue('host')     <> nil then Result.Host     := AJSON.GetValue<String>('host');
  if AJSON.GetValue('port')     <> nil then Result.Port     := AJSON.GetValue<Integer>('port');
  if AJSON.GetValue('schema')   <> nil then Result.Schema   := AJSON.GetValue<String>('schema');
  if AJSON.GetValue('database') <> nil then Result.Database := AJSON.GetValue<String>('database');
  if AJSON.GetValue('username') <> nil then Result.Username := AJSON.GetValue<String>('username');
  if AJSON.GetValue('password') <> nil then Result.Password := AJSON.GetValue<String>('password');

  ArgsObj := AJSON.GetValue<TJSONObject>('args');
  if Assigned(ArgsObj) then
    for Pair in ArgsObj do
      Result.AddArgument(Pair.JsonString.Value, Pair.JsonValue.Value);
end;

class function TConnectionConfigJSON.Load(const ASource: String): TConnection;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.ParseJSONValue(ASource) as TJSONObject;
  if not Assigned(JSON) then
    raise EArgumentException.Create('Invalid JSON for connection config');
  try
    Result := LoadFromJSONObject(JSON);
  finally
    JSON.Free;
  end;
end;

end.
