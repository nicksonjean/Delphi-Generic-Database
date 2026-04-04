{
  Connection.Config.XML
  ------------------------------------------------------------------------------
  Objetivo : Criar e configurar um TConnection a partir de um documento XML.
  Formato esperado:

    <Connection>
      <Engine>FireDAC</Engine>
      <Driver>MySQL</Driver>
      <Host>localhost</Host>
      <Port>3306</Port>
      <Schema>public</Schema>
      <Database>app</Database>
      <Username>root</Username>
      <Password>senha</Password>
      <Args>
        <CharacterSet>UTF8</CharacterSet>
        <Compress>True</Compress>
      </Args>
    </Connection>

  O elemento Engine é obrigatório.
  Retorna TConnection configurada sem conectar.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.XML;

interface

uses
  Connection;

type
  TConnectionConfigXML = class
  public
    { Lê AFileName como arquivo XML e retorna um TConnection configurado (sem conectar).
      Lança EArgumentException se o arquivo não existir ou contiver engine desconhecida. }
    class function LoadFromFile(const AFileName: String): TConnection;
    { Lê ASource como conteúdo XML em memória e retorna um TConnection configurado. }
    class function Load(const ASource: String): TConnection;
  end;

implementation

uses
  System.SysUtils,
  System.Variants,
  Xml.XMLDoc,
  Xml.XMLIntf,
  Connection.Types;

{ Retorna o texto do primeiro filho com o nome indicado, ou EmptyStr se ausente }
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

{ Lógica compartilhada — recebe o documento XML já carregado }
function InternalLoadFromXML(const ADoc: IXMLDocument): TConnection;
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
  Root := ADoc.DocumentElement;
  if not Assigned(Root) then
    raise EArgumentException.Create('XML document has no root element');

  EngineStr := NodeText(Root, 'Engine');
  if EngineStr = EmptyStr then
    raise EArgumentException.Create('Connection config XML: <Engine> is required.');
  if not StringToEngine(EngineStr, Engine) then
    raise EArgumentException.CreateFmt('Unknown engine: %s', [EngineStr]);

  Result := TConnection.Create(Engine);

  { Driver — opcional }
  DriverStr := NodeText(Root, 'Driver');
  if (DriverStr <> EmptyStr) and StringToDriver(DriverStr, Driver) then
    Result.Driver := Driver;

  { Parâmetros de conexão }
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

  { Senha pode ser vazia intencionalmente }
  PasswordVal := NodeText(Root, 'Password');
  Result.Password := PasswordVal;

  { Nó <Args> — opcional }
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

{ TConnectionConfigXML }

class function TConnectionConfigXML.LoadFromFile(const AFileName: String): TConnection;
var
  Doc: IXMLDocument;
begin
  if not FileExists(AFileName) then
    raise EArgumentException.CreateFmt('XML file not found: %s', [AFileName]);
  Doc := TXMLDocument.Create(nil);
  Doc.LoadFromFile(AFileName);
  Doc.Active := True;
  Result := InternalLoadFromXML(Doc);
end;

class function TConnectionConfigXML.Load(const ASource: String): TConnection;
var
  Doc: IXMLDocument;
begin
  if ASource = EmptyStr then
    raise EArgumentException.Create('XML source is empty');
  Doc := TXMLDocument.Create(nil);
  Doc.LoadFromXML(ASource);
  Doc.Active := True;
  Result := InternalLoadFromXML(Doc);
end;

end.
