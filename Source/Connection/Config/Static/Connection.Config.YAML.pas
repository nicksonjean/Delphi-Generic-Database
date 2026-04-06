{
  Connection.Config.YAML
  ------------------------------------------------------------------------------
  Local    : Source\Connection\Config\Static
  Objetivo : Loader YAML — arquivo/texto; LoadFromObject via TConnectionYamlDocumentRef
             (Connection.Config.DocumentRefs). Mapeamento em Connection.Config.YAML.Mapper.
  Requer   : Neslib.Yaml.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.YAML;

interface

uses
  Connection,
  Neslib.Yaml,
  Neslib.Utf8,
  Connection.Config.Loader.Abstract,
  Connection.Config.Types;

type
  TConnectionConfigYAML = class(TConnectionConfigLoader)
  public
    class function ConfigFormat: TConnectionConfigFormat; override;
    class function LoadFromFile(const AFileName: String): TConnection; override;
    class function Load(const ASource: String): TConnection; override;
    class function LoadFromObject(const AObject: TObject): TConnection; override;
    class function LoadFromYamlDocument(const ADoc: IYamlDocument): TConnection;
  end;

implementation

uses
  System.SysUtils,
  Connection.Config.DocumentRefs,
  Connection.Config.YAML.Mapper;

class function TConnectionConfigYAML.ConfigFormat: TConnectionConfigFormat;
begin
  Result := ccfYAML;
end;

class function TConnectionConfigYAML.LoadFromYamlDocument(const ADoc: IYamlDocument): TConnection;
begin
  Result := TConnectionConfigYamlMapper.LoadFromYamlDocument(ADoc);
end;

class function TConnectionConfigYAML.LoadFromFile(const AFileName: String): TConnection;
var
  Doc: IYamlDocument;
begin
  Doc := TYamlDocument.Load(AFileName);
  if Doc = nil then
    raise EArgumentException.CreateFmt('YAML file could not be loaded: %s', [AFileName]);
  Result := LoadFromYamlDocument(Doc);
end;

class function TConnectionConfigYAML.Load(const ASource: String): TConnection;
var
  Doc: IYamlDocument;
begin
  Doc := TYamlDocument.Parse(ASource);
  if Doc = nil then
    raise EArgumentException.Create('Invalid YAML for connection config');
  Result := LoadFromYamlDocument(Doc);
end;

class function TConnectionConfigYAML.LoadFromObject(const AObject: TObject): TConnection;
begin
  if AObject is TConnectionYamlDocumentRef then
    Result := LoadFromYamlDocument(TConnectionYamlDocumentRef(AObject).Document)
  else
    Result := inherited LoadFromObject(AObject);
end;

end.
