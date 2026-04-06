{
  Connection.Config.DocumentRefs
  ------------------------------------------------------------------------------
  Objetivo : Wrappers TObject uniformes para LoadFromObject / IConnectionConfig —
             cada formato expõe a mesma ideia: uma classe Ref com campo Document
             apontando para o tipo nativo do parser (ou IYamlDocument no YAML).
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.DocumentRefs;

interface

uses
  System.IniFiles,
  System.JSON,
  Xml.XMLDoc,
  TOML,
  Neslib.Yaml;

type
  TConnectionIniDocumentRef = class
  public
    Document: TCustomIniFile;
    constructor Create(const ADocument: TCustomIniFile);
  end;

  TConnectionJsonDocumentRef = class
  public
    Document: TJSONObject;
    constructor Create(const ADocument: TJSONObject);
  end;

  TConnectionXmlDocumentRef = class
  public
    Document: TXMLDocument;
    constructor Create(const ADocument: TXMLDocument);
  end;

  TConnectionTomlDocumentRef = class
  public
    Document: TTOMLTable;
    constructor Create(const ADocument: TTOMLTable);
  end;

  TConnectionYamlDocumentRef = class
  public
    Document: IYamlDocument;
    constructor Create(const ADocument: IYamlDocument);
  end;

implementation

{ TConnectionIniDocumentRef }

constructor TConnectionIniDocumentRef.Create(const ADocument: TCustomIniFile);
begin
  inherited Create;
  Document := ADocument;
end;

{ TConnectionJsonDocumentRef }

constructor TConnectionJsonDocumentRef.Create(const ADocument: TJSONObject);
begin
  inherited Create;
  Document := ADocument;
end;

{ TConnectionXmlDocumentRef }

constructor TConnectionXmlDocumentRef.Create(const ADocument: TXMLDocument);
begin
  inherited Create;
  Document := ADocument;
end;

{ TConnectionTomlDocumentRef }

constructor TConnectionTomlDocumentRef.Create(const ADocument: TTOMLTable);
begin
  inherited Create;
  Document := ADocument;
end;

{ TConnectionYamlDocumentRef }

constructor TConnectionYamlDocumentRef.Create(const ADocument: IYamlDocument);
begin
  inherited Create;
  Document := ADocument;
end;

end.
