{
  Connection.Config.XML.Mapper
  ------------------------------------------------------------------------------
  Objetivo : Mapeamento XML (raiz Connection) → TConnection.
  Formato  : Elementos Engine (obrigatório), Driver, Host, Port, Schema, Database,
             Username, Password e Args com filhos como argumentos extras.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.XML.Mapper;

interface

uses
  Xml.XMLIntf,
  Connection;

type
  TConnectionConfigXmlMapper = class sealed
  public
    class function LoadFromDocument(const ADoc: IXMLDocument): TConnection;
  end;

implementation

uses
  System.SysUtils,
  System.Variants,
  Connection.Types;

function NodeText(const AParent: IXMLNode; const AName: String): String;
var
  Node: IXMLNode;
begin
  Node := AParent.ChildNodes.FindNode(AName);
  if Assigned(Node) then
    Result := VarToStrDef(Node.NodeValue, EmptyStr)
  else
    Result := EmptyStr;
end;

class function TConnectionConfigXmlMapper.LoadFromDocument(const ADoc: IXMLDocument): TConnection;
var
  Root:        IXMLNode;
  ArgsNode:    IXMLNode;
  Engine:      TEngine;
  Driver:      TDriver;
  EngineStr:   String;
  DriverStr:   String;
  HostVal:     String;
  SchemaVal:   String;
  DatabaseVal: String;
  UsernameVal: String;
  PasswordVal: String;
  PortStr:     String;
  PortVal:     Integer;
  I:           Integer;
  ArgNode:     IXMLNode;
begin
  if not Assigned(ADoc) then
    raise EArgumentException.Create('Connection config XML: document is nil.');

  Root := ADoc.DocumentElement;
  if not Assigned(Root) then
    raise EArgumentException.Create('XML document has no root element');

  EngineStr := NodeText(Root, 'Engine');
  if EngineStr = EmptyStr then
    raise EArgumentException.Create('Connection config XML: <Engine> is required.');
  if not StringToEngine(EngineStr, Engine) then
    raise EArgumentException.CreateFmt('Unknown engine: %s', [EngineStr]);

  Result := TConnection.Create(Engine);

  DriverStr := NodeText(Root, 'Driver');
  if (DriverStr <> EmptyStr) and StringToDriver(DriverStr, Driver) then
    Result.Driver := Driver;

  HostVal := NodeText(Root, 'Host');
  if HostVal <> EmptyStr then Result.Host := HostVal;

  PortStr := NodeText(Root, 'Port');
  if (PortStr <> EmptyStr) and TryStrToInt(PortStr, PortVal) and (PortVal > 0) then
    Result.Port := PortVal;

  SchemaVal := NodeText(Root, 'Schema');
  if SchemaVal <> EmptyStr then Result.Schema := SchemaVal;

  DatabaseVal := NodeText(Root, 'Database');
  if DatabaseVal <> EmptyStr then Result.Database := DatabaseVal;

  UsernameVal := NodeText(Root, 'Username');
  if UsernameVal <> EmptyStr then Result.Username := UsernameVal;

  PasswordVal := NodeText(Root, 'Password');
  Result.Password := PasswordVal;

  ArgsNode := Root.ChildNodes.FindNode('Args');
  if Assigned(ArgsNode) then
    for I := 0 to ArgsNode.ChildNodes.Count - 1 do
    begin
      ArgNode := ArgsNode.ChildNodes[I];
      if ArgNode.NodeType = ntElement then
        Result.AddArgument(ArgNode.NodeName,
          VarToStrDef(ArgNode.NodeValue, EmptyStr));
    end;
end;

end.
