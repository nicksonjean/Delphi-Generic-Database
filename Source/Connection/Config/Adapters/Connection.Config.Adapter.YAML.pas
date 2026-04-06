{
  Connection.Config.Adapter.YAML
  ------------------------------------------------------------------------------
  Objetivo : Adaptador IConnectionConfig para YAML (delega a TConnectionConfigYAML /
             Connection.Config.YAML.Mapper).
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.Adapter.YAML;

interface

uses
  Connection,
  Connection.Config.Intf;

type
  TConnectionConfigYAMLAdapter = class(TInterfacedObject, IConnectionConfig)
  public
    function LoadFromFile(const AFileName: String): TConnection;
    function Load(const ASource: String): TConnection;
    function LoadFromObject(const AObject: TObject): TConnection;
  end;

implementation

uses
  Connection.Config.YAML;

{ TConnectionConfigYAMLAdapter }

function TConnectionConfigYAMLAdapter.LoadFromFile(const AFileName: String): TConnection;
begin
  Result := TConnectionConfigYAML.LoadFromFile(AFileName);
end;

function TConnectionConfigYAMLAdapter.Load(const ASource: String): TConnection;
begin
  Result := TConnectionConfigYAML.Load(ASource);
end;

function TConnectionConfigYAMLAdapter.LoadFromObject(const AObject: TObject): TConnection;
begin
  Result := TConnectionConfigYAML.LoadFromObject(AObject);
end;

end.
