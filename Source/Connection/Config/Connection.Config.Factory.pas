{
  Connection.Config.Factory
  ------------------------------------------------------------------------------
  Objetivo : Fábrica de IConnectionConfig (escolha por extensão, formato explícito,
             string ou TObject). Complementa os loaders estáticos TConnectionConfig*.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.Factory;

interface

uses
  Connection.Config.Intf,
  Connection.Config.Types;

type
  TConnectionConfigFactory = class
  public
    class function CreateForFormat(const AFormat: TConnectionConfigFormat): IConnectionConfig;

    class function FromFile(const AFileName: String): IConnectionConfig; overload;
    class function FromFile(const AFileName: String; const AFormat: TConnectionConfigFormat): IConnectionConfig; overload;

    class function FromString(const ASource: String; const AFormat: TConnectionConfigFormat): IConnectionConfig; overload;
    class function FromString(const ASource: String): IConnectionConfig; overload;

    class function FromObject(const AObject: TObject): IConnectionConfig; overload;
    class function FromObject(const AObject: TObject; const AFormat: TConnectionConfigFormat): IConnectionConfig; overload;

    class function FromObject<T: class>(const AObject: T): IConnectionConfig; overload;

    class function ObjectFormat(const AObject: TObject): TConnectionConfigFormat;
  end;

implementation

uses
  System.SysUtils,
  Connection.Config.DocumentRefs,
  Connection.Config.Adapter.INI,
  Connection.Config.Adapter.JSON,
  Connection.Config.Adapter.XML,
  Connection.Config.Adapter.YAML,
  Connection.Config.Adapter.TOML;

{ TConnectionConfigFactory }

class function TConnectionConfigFactory.CreateForFormat(const AFormat: TConnectionConfigFormat): IConnectionConfig;
begin
  case AFormat of
    ccfINI:
      Result := TConnectionConfigINIAdapter.Create;
    ccfJSON:
      Result := TConnectionConfigJSONAdapter.Create;
    ccfXML:
      Result := TConnectionConfigXMLAdapter.Create;
    ccfYAML:
      Result := TConnectionConfigYAMLAdapter.Create;
    ccfTOML:
      Result := TConnectionConfigTOMLAdapter.Create;
  end;
end;

class function TConnectionConfigFactory.FromFile(const AFileName: String): IConnectionConfig;
var
  Fmt: TConnectionConfigFormat;
begin
  Fmt := ConnectionConfigFormatFromExtension(ExtractFileExt(AFileName));
  Result := CreateForFormat(Fmt);
end;

class function TConnectionConfigFactory.FromFile(const AFileName: String;
  const AFormat: TConnectionConfigFormat): IConnectionConfig;
begin
  Result := CreateForFormat(AFormat);
end;

class function TConnectionConfigFactory.FromString(const ASource: String;
  const AFormat: TConnectionConfigFormat): IConnectionConfig;
begin
  Result := CreateForFormat(AFormat);
end;

class function TConnectionConfigFactory.FromString(const ASource: String): IConnectionConfig;
var
  S: string;
  L: Integer;
begin
  S := Trim(ASource);
  L := Length(S);
  if (L > 0) and (S[1] = '{') then
    Result := CreateForFormat(ccfJSON)
  else if (L > 0) and (S[1] = '<') then
    Result := CreateForFormat(ccfXML)
  else
    Result := CreateForFormat(ccfINI);
end;

class function TConnectionConfigFactory.ObjectFormat(const AObject: TObject): TConnectionConfigFormat;
begin
  if not Assigned(AObject) then
    raise EArgumentException.Create('Connection config: object is nil.');

  if AObject is TConnectionIniDocumentRef then
    Exit(ccfINI);
  if AObject is TConnectionJsonDocumentRef then
    Exit(ccfJSON);
  if AObject is TConnectionXmlDocumentRef then
    Exit(ccfXML);
  if AObject is TConnectionYamlDocumentRef then
    Exit(ccfYAML);
  if AObject is TConnectionTomlDocumentRef then
    Exit(ccfTOML);

  raise EArgumentException.CreateFmt(
    'Connection config: cannot infer format from class %s. Use FromObject(Obj, Format) or a *DocumentRef (Connection.Config.DocumentRefs).',
    [AObject.ClassName]);
end;

class function TConnectionConfigFactory.FromObject(const AObject: TObject): IConnectionConfig;
begin
  Result := CreateForFormat(ObjectFormat(AObject));
end;

class function TConnectionConfigFactory.FromObject(const AObject: TObject;
  const AFormat: TConnectionConfigFormat): IConnectionConfig;
begin
  Result := CreateForFormat(AFormat);
end;

class function TConnectionConfigFactory.FromObject<T>(const AObject: T): IConnectionConfig;
begin
  Result := FromObject(TObject(AObject));
end;

end.
