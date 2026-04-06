{
  Connection.Config.XML
  ------------------------------------------------------------------------------
  Local    : Source\Connection\Config\Static
  Objetivo : Loader XML — LoadFromDocument(IXMLDocument); LoadFromObject via
             TConnectionXmlDocumentRef. Mapeamento em Connection.Config.XML.Mapper.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.XML;

interface

uses
  Connection,
  Xml.XMLIntf,
  Connection.Config.Loader.Abstract,
  Connection.Config.Types;

type
  TConnectionConfigXML = class(TConnectionConfigLoader)
  public
    class function ConfigFormat: TConnectionConfigFormat; override;
    class function LoadFromFile(const AFileName: String): TConnection; override;
    class function Load(const ASource: String): TConnection; override;
    class function LoadFromObject(const AObject: TObject): TConnection; override;
    class function LoadFromDocument(const ADoc: IXMLDocument): TConnection;
  end;

implementation

uses
  System.SysUtils,
  Xml.XMLDoc,
  Connection.Config.DocumentRefs,
  Connection.Config.XML.Mapper;

{ TConnectionConfigXML }

class function TConnectionConfigXML.ConfigFormat: TConnectionConfigFormat;
begin
  Result := ccfXML;
end;

class function TConnectionConfigXML.LoadFromDocument(const ADoc: IXMLDocument): TConnection;
begin
  Result := TConnectionConfigXmlMapper.LoadFromDocument(ADoc);
end;

class function TConnectionConfigXML.LoadFromFile(const AFileName: String): TConnection;
var
  Doc: IXMLDocument;
begin
  RequireFileExists(AFileName, Format('XML file not found: %s', [AFileName]));
  Doc := TXMLDocument.Create(nil);
  Doc.LoadFromFile(AFileName);
  Doc.Active := True;
  Result := TConnectionConfigXmlMapper.LoadFromDocument(Doc);
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
  Result := TConnectionConfigXmlMapper.LoadFromDocument(Doc);
end;

class function TConnectionConfigXML.LoadFromObject(const AObject: TObject): TConnection;
var
  Doc: IXMLDocument;
begin
  if AObject is TConnectionXmlDocumentRef then
  begin
    Doc := TConnectionXmlDocumentRef(AObject).Document as IXMLDocument;
    Result := TConnectionConfigXmlMapper.LoadFromDocument(Doc);
  end
  else
    Result := inherited LoadFromObject(AObject);
end;

end.
