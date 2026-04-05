(*
  Connection.Config.NEON
  ------------------------------------------------------------------------------
  Objetivo : Criar TConnection a partir de texto JSON usando delphi-neon para
  materializar um DTO tipado antes de aplicar o mesmo mapeamento do JSON.
  Requer : paolo-rossi/delphi-neon — unit Neon.Core.Persistence.JSON.
  Nota : O formato on-disk é o mesmo JSON de Connection.Config.JSON (não é o
  formato .neon da linguagem Nette).
  ------------------------------------------------------------------------------
*)

unit Connection.Config.NEON;

interface

uses
  Connection;

type
  TConnectionConfigNEON = class
  public
    class function Load(const ASource: String): TConnection;
  end;

implementation

uses
  System.SysUtils,
  System.JSON,
  Neon.Core.Persistence.JSON,
  Connection.Config.JSON;

type
  TConnectionNeonDto = class
  public
    engine: string;
    driver: string;
    host: string;
    port: Integer;
    schema: string;
    database: string;
    username: string;
    password: string;
    constructor Create;
  end;

constructor TConnectionNeonDto.Create;
begin
  inherited Create;
end;

class function TConnectionConfigNEON.Load(const ASource: String): TConnection;
var
  JSON: TJSONObject;
  Dto: TConnectionNeonDto;
begin
  JSON := TJSONObject.ParseJSONValue(ASource) as TJSONObject;
  if not Assigned(JSON) then
    raise EArgumentException.Create('Invalid JSON for connection config (NEON path)');
  Dto := TConnectionNeonDto.Create;
  try
    TNeon.JSONToObject(Dto, JSON);
    if Dto.engine = '' then
      raise EArgumentException.Create('Connection config (NEON): property "engine" is required.');
    Result := TConnectionConfigJSON.LoadFromJSONObject(JSON);
  finally
    Dto.Free;
    JSON.Free;
  end;
end;

end.
