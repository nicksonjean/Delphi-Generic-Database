{
  Connection.Config.Adapter.TOML
  ------------------------------------------------------------------------------
  Objetivo : Adaptador IConnectionConfig para TOML (delega a TConnectionConfigTOML /
             Connection.Config.TOML.Mapper).
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.Adapter.TOML;

interface

uses
  Connection,
  Connection.Config.Intf;

type
  TConnectionConfigTOMLAdapter = class(TInterfacedObject, IConnectionConfig)
  public
    function LoadFromFile(const AFileName: String): TConnection;
    function Load(const ASource: String): TConnection;
    function LoadFromObject(const AObject: TObject): TConnection;
  end;

implementation

uses
  Connection.Config.TOML;

{ TConnectionConfigTOMLAdapter }

function TConnectionConfigTOMLAdapter.LoadFromFile(const AFileName: String): TConnection;
begin
  Result := TConnectionConfigTOML.LoadFromFile(AFileName);
end;

function TConnectionConfigTOMLAdapter.Load(const ASource: String): TConnection;
begin
  Result := TConnectionConfigTOML.Load(ASource);
end;

function TConnectionConfigTOMLAdapter.LoadFromObject(const AObject: TObject): TConnection;
begin
  Result := TConnectionConfigTOML.LoadFromObject(AObject);
end;

end.
