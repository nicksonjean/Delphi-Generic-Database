(*
  Connection.Config.JSON.Mapper
  ------------------------------------------------------------------------------
  Objetivo : Mapeamento JSON (objeto raiz) → TConnection.
  Formato  : Propriedades engine (obrigatório), driver, host, port, schema,
             database, username, password, args { chave/valor }.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
*)

unit Connection.Config.JSON.Mapper;

interface

uses
  System.JSON,
  Connection;

type
  TConnectionConfigJsonMapper = class sealed
  public
    class function LoadFromJSONObject(const AJSON: TJSONObject): TConnection;
  end;

implementation

uses
  System.SysUtils,
  Connection.Types;

class function TConnectionConfigJsonMapper.LoadFromJSONObject(const AJSON: TJSONObject): TConnection;
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

end.
