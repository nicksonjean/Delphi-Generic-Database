{
  Connection.Config.TOML
  ------------------------------------------------------------------------------
  Local    : Source\Connection\Config\Static
  Objetivo : Loader TOML — arquivo/texto; LoadFromTable; LoadFromObject via
             TConnectionTomlDocumentRef. Mapeamento em Connection.Config.TOML.Mapper.
  Requer   : DelphiTOML (TOML, TOML.Types).
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.TOML;

interface

uses
  Connection,
  TOML,
  Connection.Config.Loader.Abstract,
  Connection.Config.Types;

type
  TConnectionConfigTOML = class(TConnectionConfigLoader)
  public
    class function ConfigFormat: TConnectionConfigFormat; override;
    class function LoadFromFile(const AFileName: String): TConnection; override;
    class function Load(const ASource: String): TConnection; override;
    class function LoadFromObject(const AObject: TObject): TConnection; override;
    class function LoadFromTable(const ATable: TTOMLTable): TConnection;
  end;

implementation

uses
  System.SysUtils,
  Connection.Config.DocumentRefs,
  Connection.Config.TOML.Mapper;

class function TConnectionConfigTOML.ConfigFormat: TConnectionConfigFormat;
begin
  Result := ccfTOML;
end;

class function TConnectionConfigTOML.LoadFromTable(const ATable: TTOMLTable): TConnection;
begin
  Result := TConnectionConfigTomlMapper.LoadFromTable(ATable);
end;

class function TConnectionConfigTOML.LoadFromFile(const AFileName: String): TConnection;
var
  Table: TTOMLTable;
begin
  Table := ParseTOMLFromFile(AFileName, False);
  try
    Result := LoadFromTable(Table);
  finally
    Table.Free;
  end;
end;

class function TConnectionConfigTOML.Load(const ASource: String): TConnection;
var
  Table: TTOMLTable;
begin
  Table := ParseTOML(ASource, False);
  try
    Result := LoadFromTable(Table);
  finally
    Table.Free;
  end;
end;

class function TConnectionConfigTOML.LoadFromObject(const AObject: TObject): TConnection;
begin
  if AObject is TConnectionTomlDocumentRef then
    Result := LoadFromTable(TConnectionTomlDocumentRef(AObject).Document)
  else
    Result := inherited LoadFromObject(AObject);
end;

end.
