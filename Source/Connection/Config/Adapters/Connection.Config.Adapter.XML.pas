{
  Connection.Config.Adapter.XML
  ------------------------------------------------------------------------------
  Objetivo : Adaptador IConnectionConfig para XML (delega a TConnectionConfigXML /
             Connection.Config.XML.Mapper).
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.Adapter.XML;

interface

uses
  Connection,
  Connection.Config.Intf;

type
  TConnectionConfigXMLAdapter = class(TInterfacedObject, IConnectionConfig)
  public
    function LoadFromFile(const AFileName: String): TConnection;
    function Load(const ASource: String): TConnection;
    function LoadFromObject(const AObject: TObject): TConnection;
  end;

implementation

uses
  Connection.Config.XML;

{ TConnectionConfigXMLAdapter }

function TConnectionConfigXMLAdapter.LoadFromFile(const AFileName: String): TConnection;
begin
  Result := TConnectionConfigXML.LoadFromFile(AFileName);
end;

function TConnectionConfigXMLAdapter.Load(const ASource: String): TConnection;
begin
  Result := TConnectionConfigXML.Load(ASource);
end;

function TConnectionConfigXMLAdapter.LoadFromObject(const AObject: TObject): TConnection;
begin
  Result := TConnectionConfigXML.LoadFromObject(AObject);
end;

end.
