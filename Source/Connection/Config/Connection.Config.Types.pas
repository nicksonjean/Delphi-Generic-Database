{
  Connection.Config.Types
  ------------------------------------------------------------------------------
  Objetivo : Tipos compartilhados para configuração de conexão (formato de
             serialização e origem lógica).
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.Types;

interface

uses
  System.SysUtils;

type
  { Formato do arquivo ou do adaptador de configuração. }
  TConnectionConfigFormat = (
    ccfINI,
    ccfJSON,
    ccfXML,
    ccfYAML,
    ccfTOML);

  { Origem lógica da configuração (útil para logging e extensões). }
  TConnectionConfigSourceKind = (
    ccsFile,
    ccsString,
    ccsObject);

{ Retorna True se Ext (com ou sem ponto) for reconhecido. }
function ConnectionConfigTryFormatFromExtension(const Ext: string; out AFormat: TConnectionConfigFormat): Boolean;

{ Igual ao anterior, mas lança EArgumentException se não reconhecer. }
function ConnectionConfigFormatFromExtension(const Ext: string): TConnectionConfigFormat;

implementation

function NormalizeExt(const Ext: string): string;
begin
  Result := LowerCase(Trim(Ext));
  if (Result <> '') and (Result[1] <> '.') then
    Result := '.' + Result;
end;

function ConnectionConfigTryFormatFromExtension(const Ext: string; out AFormat: TConnectionConfigFormat): Boolean;
var
  E: string;
begin
  E := NormalizeExt(Ext);
  if (E = '.ini') then
  begin
    AFormat := ccfINI;
    Exit(True);
  end;
  if (E = '.json') then
  begin
    AFormat := ccfJSON;
    Exit(True);
  end;
  if (E = '.xml') then
  begin
    AFormat := ccfXML;
    Exit(True);
  end;
  if (E = '.yaml') or (E = '.yml') then
  begin
    AFormat := ccfYAML;
    Exit(True);
  end;
  if (E = '.toml') then
  begin
    AFormat := ccfTOML;
    Exit(True);
  end;
  Result := False;
end;

function ConnectionConfigFormatFromExtension(const Ext: string): TConnectionConfigFormat;
begin
  if not ConnectionConfigTryFormatFromExtension(Ext, Result) then
    raise EArgumentException.CreateFmt('Unsupported config extension: %s', [Ext]);
end;

end.
