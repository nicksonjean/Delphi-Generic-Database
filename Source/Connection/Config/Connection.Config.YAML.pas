(*
  Connection.Config.YAML
  ------------------------------------------------------------------------------
  Objetivo : Criar TConnection a partir de YAML (mesmo esquema lógico do JSON).
  Requer : neslib/Neslib.Yaml (boss.json) no search path do projeto.
  O documento raiz deve ser um mapping (objeto) com chaves engine, driver, etc.
  ------------------------------------------------------------------------------
*)

unit Connection.Config.YAML;

interface

uses
  Connection;

type
  TConnectionConfigYAML = class
  public
    class function Load(const ASource: String): TConnection;
  end;

implementation

uses
  System.SysUtils,
  System.JSON,
  Neslib.Yaml,
  Connection.Config.JSON;

function YamlNodeToJsonValue(const Node: TYamlNode; Depth: Integer): TJSONValue;
var
  I: Integer;
  El: PYamlElement;
  Obj: TJSONObject;
  Arr: TJSONArray;
begin
  if Depth > 128 then
    raise EArgumentException.Create('YAML nesting too deep or alias cycle.');
  if Node.IsNil then
    Exit(TJSONNull.Create);
  if Node.IsAlias then
    Exit(YamlNodeToJsonValue(Node.Target, Depth + 1));
  if Node.IsScalar then
    Exit(TJSONString.Create(Node.ToString));
  if Node.IsSequence then
  begin
    Arr := TJSONArray.Create;
    for I := 0 to Node.Count - 1 do
      Arr.AddElement(YamlNodeToJsonValue(Node.Nodes[I], Depth + 1));
    Exit(Arr);
  end;
  if Node.IsMapping then
  begin
    Obj := TJSONObject.Create;
    for I := 0 to Node.Count - 1 do
    begin
      El := Node.Elements[I];
      if El <> nil then
        Obj.AddPair(El^.Key.ToString, YamlNodeToJsonValue(El^.Value, Depth + 1));
    end;
    Exit(Obj);
  end;
  Result := TJSONNull.Create;
end;

class function TConnectionConfigYAML.Load(const ASource: String): TConnection;
var
  Doc: IYamlDocument;
  Root: TYamlNode;
  JSON: TJSONObject;
begin
  Doc := TYamlDocument.Parse(ASource);
  if Doc = nil then
    raise EArgumentException.Create('Invalid YAML for connection config');
  Root := Doc.Root;
  if not Root.IsMapping then
    raise EArgumentException.Create('Connection config YAML: root must be a mapping (object).');
  JSON := YamlNodeToJsonValue(Root, 0) as TJSONObject;
  try
    Result := TConnectionConfigJSON.LoadFromJSONObject(JSON);
  finally
    JSON.Free;
  end;
end;

end.
