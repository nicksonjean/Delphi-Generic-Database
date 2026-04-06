{
  Connection.Config.YAML.Mapper
  ------------------------------------------------------------------------------
  Objetivo : Mapeamento YAML (raiz mapping) → TConnection, sem JSON.
  Requer   : Neslib.Yaml — mesmas chaves lógicas que JSON (engine, driver, host, …, args).
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.YAML.Mapper;

interface

uses
  Neslib.Yaml,
  System.Classes,
  Connection;

type
  TConnectionConfigYamlMapper = class sealed
  public
    class function LoadFromYamlDocument(const ADoc: IYamlDocument): TConnection;
  end;

implementation

uses
  System.SysUtils,
  Connection.Types;

const
  MAX_ALIAS_DEPTH = 128;

function YamlResolveAlias(Node: TYamlNode; var Depth: Integer): TYamlNode;
begin
  Result := Node;
  while Result.IsAlias do
  begin
    Inc(Depth);
    if Depth > MAX_ALIAS_DEPTH then
      raise EArgumentException.Create('YAML: alias depth too deep or cycle.');
    Result := Result.Target;
  end;
end;

function YamlScalarText(const Node: TYamlNode; const AFieldName: string): string;
var
  D: Integer;
  N: TYamlNode;
begin
  D := 0;
  N := YamlResolveAlias(Node, D);
  if not N.IsScalar then
    raise EArgumentException.CreateFmt(
      'Connection config YAML: expected scalar for "%s".', [AFieldName]);
  Result := N.ToString;
end;

class function TConnectionConfigYamlMapper.LoadFromYamlDocument(const ADoc: IYamlDocument): TConnection;
var
  Root:      TYamlNode;
  Engine:    TEngine;
  Driver:    TDriver;
  EngineStr: string;
  V:         TYamlNode;
  PortVal:   Integer;
  ArgsNode:  TYamlNode;
  I:         Integer;
  El:        PYamlElement;
begin
  if ADoc = nil then
    raise EArgumentException.Create('Connection config YAML: document is nil.');
  Root := ADoc.Root;
  if not Root.IsMapping then
    raise EArgumentException.Create('Connection config YAML: root must be a mapping (object).');

  if not Root.TryGetValue('engine', V) then
    raise EArgumentException.Create('Connection config YAML: key "engine" is required.');
  EngineStr := YamlScalarText(V, 'engine');
  if not StringToEngine(EngineStr, Engine) then
    raise EArgumentException.CreateFmt('Unknown engine: %s', [EngineStr]);

  Result := TConnection.Create(Engine);

  if Root.TryGetValue('driver', V) then
  begin
    if StringToDriver(YamlScalarText(V, 'driver'), Driver) then
      Result.Driver := Driver;
  end;

  if Root.TryGetValue('host', V) then
    Result.Host := YamlScalarText(V, 'host');
  if Root.TryGetValue('port', V) then
  begin
    if not TryStrToInt(Trim(YamlScalarText(V, 'port')), PortVal) then
      raise EArgumentException.Create('Connection config YAML: "port" must be an integer.');
    if PortVal > 0 then
      Result.Port := PortVal;
  end;
  if Root.TryGetValue('schema', V) then
    Result.Schema := YamlScalarText(V, 'schema');
  if Root.TryGetValue('database', V) then
    Result.Database := YamlScalarText(V, 'database');
  if Root.TryGetValue('username', V) then
    Result.Username := YamlScalarText(V, 'username');
  if Root.TryGetValue('password', V) then
    Result.Password := YamlScalarText(V, 'password');

  if Root.TryGetValue('args', ArgsNode) then
  begin
    if not ArgsNode.IsMapping then
      raise EArgumentException.Create('Connection config YAML: "args" must be a mapping.');
    for I := 0 to ArgsNode.Count - 1 do
    begin
      El := ArgsNode.Elements[I];
      if El <> nil then
        Result.AddArgument(El^.Key.ToString, YamlScalarText(El^.Value, 'args.' + El^.Key.ToString));
    end;
  end;
end;

end.
