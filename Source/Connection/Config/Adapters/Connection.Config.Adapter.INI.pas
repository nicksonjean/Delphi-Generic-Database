{
  Connection.Config.Adapter.INI
  ------------------------------------------------------------------------------
  Objetivo : Adaptador IConnectionConfig para o formato INI (delega a
             TConnectionConfigINI / Connection.Config.INI.Mapper).
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.Adapter.INI;

interface

uses
  Connection,
  Connection.Config.Intf;

type
  TConnectionConfigINIAdapter = class(TInterfacedObject, IConnectionConfig)
  public
    function LoadFromFile(const AFileName: String): TConnection;
    function Load(const ASource: String): TConnection;
    function LoadFromObject(const AObject: TObject): TConnection;
  end;

implementation

uses
  Connection.Config.INI;

{ TConnectionConfigINIAdapter }

function TConnectionConfigINIAdapter.LoadFromFile(const AFileName: String): TConnection;
begin
  Result := TConnectionConfigINI.LoadFromFile(AFileName);
end;

function TConnectionConfigINIAdapter.Load(const ASource: String): TConnection;
begin
  Result := TConnectionConfigINI.Load(ASource);
end;

function TConnectionConfigINIAdapter.LoadFromObject(const AObject: TObject): TConnection;
begin
  Result := TConnectionConfigINI.LoadFromObject(AObject);
end;

end.
