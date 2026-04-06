{
  Connection.Config.Adapter.JSON
  ------------------------------------------------------------------------------
  Objetivo : Adaptador IConnectionConfig para JSON (delega a TConnectionConfigJSON /
             Connection.Config.JSON.Mapper).
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.Adapter.JSON;

interface

uses
  Connection,
  Connection.Config.Intf;

type
  TConnectionConfigJSONAdapter = class(TInterfacedObject, IConnectionConfig)
  public
    function LoadFromFile(const AFileName: String): TConnection;
    function Load(const ASource: String): TConnection;
    function LoadFromObject(const AObject: TObject): TConnection;
  end;

implementation

uses
  Connection.Config.JSON;

{ TConnectionConfigJSONAdapter }

function TConnectionConfigJSONAdapter.LoadFromFile(const AFileName: String): TConnection;
begin
  Result := TConnectionConfigJSON.LoadFromFile(AFileName);
end;

function TConnectionConfigJSONAdapter.Load(const ASource: String): TConnection;
begin
  Result := TConnectionConfigJSON.Load(ASource);
end;

function TConnectionConfigJSONAdapter.LoadFromObject(const AObject: TObject): TConnection;
begin
  Result := TConnectionConfigJSON.LoadFromObject(AObject);
end;

end.
