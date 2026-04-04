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
  Connection;

type
  TConnectionConfigJSON = class
  public
    { Lê ASource como JSON e retorna um TConnection configurado (sem conectar).
      Lança EArgumentException se o JSON for inválido ou contiver engine desconhecida. }
    class function Load(const ASource: String): TConnection;
  end;

implementation

uses
  System.SysUtils,
  System.JSON,
  Connection.Types;

class function TConnectionConfigJSON.Load(const ASource: String): TConnection;
var
  JSON:     TJSONObject;
  Engine:   TEngine;
  ArgsObj:  TJSONObject;
  Pair:     TJSONPair;
  Driver:   TDriver;
begin
  JSON := TJSONObject.ParseJSONValue(ASource) as TJSONObject;
  if not Assigned(JSON) then
    raise EArgumentException.Create('Invalid JSON for connection config');
  try
    if JSON.GetValue('engine') = nil then
      raise EArgumentException.Create('Connection config JSON: property "engine" is required.');
    if not StringToEngine(JSON.GetValue<String>('engine'), Engine) then
      raise EArgumentException.CreateFmt('Unknown engine: %s',
        [JSON.GetValue<String>('engine')]);

    Result := TConnection.Create(Engine);

    { Driver — opcional }
    if JSON.GetValue('driver') <> nil then
    begin
      if StringToDriver(JSON.GetValue<String>('driver'), Driver) then
        Result.Driver := Driver;
    end;

    if JSON.GetValue('host')     <> nil then Result.Host     := JSON.GetValue<String>('host');
    if JSON.GetValue('port')     <> nil then Result.Port     := JSON.GetValue<Integer>('port');
    if JSON.GetValue('schema')   <> nil then Result.Schema   := JSON.GetValue<String>('schema');
    if JSON.GetValue('database') <> nil then Result.Database := JSON.GetValue<String>('database');
    if JSON.GetValue('username') <> nil then Result.Username := JSON.GetValue<String>('username');
    if JSON.GetValue('password') <> nil then Result.Password := JSON.GetValue<String>('password');

    { Args extras — opcional }
    ArgsObj := JSON.GetValue<TJSONObject>('args');
    if Assigned(ArgsObj) then
      for Pair in ArgsObj do
        Result.AddArgument(Pair.JsonString.Value, Pair.JsonValue.Value);
  finally
    JSON.Free;
  end;
end;

end.
