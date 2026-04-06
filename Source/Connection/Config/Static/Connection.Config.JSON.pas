{
  Connection.Config.JSON
  ------------------------------------------------------------------------------
  Local    : Source\Connection\Config\Static
  Objetivo : Loader JSON — LoadFromJSONObject (TJSONObject); LoadFromObject via
             TConnectionJsonDocumentRef. Mapeamento em Connection.Config.JSON.Mapper.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.JSON;

interface

uses
  Connection,
  System.JSON,
  Connection.Config.Loader.Abstract,
  Connection.Config.Types;

type
  TConnectionConfigJSON = class(TConnectionConfigLoader)
  public
    class function ConfigFormat: TConnectionConfigFormat; override;
    class function LoadFromFile(const AFileName: String): TConnection; override;
    class function Load(const ASource: String): TConnection; override;
    class function LoadFromObject(const AObject: TObject): TConnection; override;
    class function LoadFromJSONObject(const AJSON: TJSONObject): TConnection;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  Connection.Config.DocumentRefs,
  Connection.Config.JSON.Mapper;

{ TConnectionConfigJSON }

class function TConnectionConfigJSON.ConfigFormat: TConnectionConfigFormat;
begin
  Result := ccfJSON;
end;

class function TConnectionConfigJSON.LoadFromFile(const AFileName: String): TConnection;
var
  Lines: TStringList;
begin
  RequireFileExists(AFileName, Format('JSON file not found: %s', [AFileName]));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFileName);
    Result := Load(Lines.Text);
  finally
    Lines.Free;
  end;
end;

class function TConnectionConfigJSON.LoadFromJSONObject(const AJSON: TJSONObject): TConnection;
begin
  Result := TConnectionConfigJsonMapper.LoadFromJSONObject(AJSON);
end;

class function TConnectionConfigJSON.Load(const ASource: String): TConnection;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.ParseJSONValue(ASource) as TJSONObject;
  if not Assigned(JSON) then
    raise EArgumentException.Create('Invalid JSON for connection config');
  try
    Result := LoadFromJSONObject(JSON);
  finally
    JSON.Free;
  end;
end;

class function TConnectionConfigJSON.LoadFromObject(const AObject: TObject): TConnection;
begin
  if AObject is TConnectionJsonDocumentRef then
    Result := LoadFromJSONObject(TConnectionJsonDocumentRef(AObject).Document)
  else
    Result := inherited LoadFromObject(AObject);
end;

end.
