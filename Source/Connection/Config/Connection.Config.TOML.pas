(*
  Connection.Config.TOML
  ------------------------------------------------------------------------------
  Objetivo : Criar TConnection a partir de TOML (mesmo esquema lógico do JSON).
  Requer : SilenceCCF/DelphiTOML (boss.json) — units TOML, TOML.JSON.
  ------------------------------------------------------------------------------
*)

unit Connection.Config.TOML;

interface

uses
  Connection;

type
  TConnectionConfigTOML = class
  public
    class function Load(const ASource: String): TConnection;
  end;

implementation

uses
  System.SysUtils,
  System.JSON,
  TOML,
  TOML.JSON,
  Connection.Config.JSON;

class function TConnectionConfigTOML.Load(const ASource: String): TConnection;
var
  Table: TTOMLTable;
  JsonText: string;
  JSON: TJSONObject;
begin
  Table := ParseTOML(ASource, False);
  try
    JsonText := TOMLToJSON(Table, False, 2);
  finally
    Table.Free;
  end;
  JSON := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
  if not Assigned(JSON) then
    raise EArgumentException.Create('TOML to JSON conversion failed for connection config');
  try
    Result := TConnectionConfigJSON.LoadFromJSONObject(JSON);
  finally
    JSON.Free;
  end;
end;

end.
