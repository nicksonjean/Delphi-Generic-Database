{
  Connection.Config.INI
  ------------------------------------------------------------------------------
  Local    : Source\Connection\Config\Static
  Objetivo : Loader INI — arquivo/texto; LoadFromObject via TConnectionIniDocumentRef.
             Mapeamento em Connection.Config.INI.Mapper.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.INI;

interface

uses
  System.IniFiles,
  Connection,
  Connection.Config.Loader.Abstract,
  Connection.Config.Types;

type
  TConnectionConfigINI = class(TConnectionConfigLoader)
  public
    class function ConfigFormat: TConnectionConfigFormat; override;
    class function LoadFromFile(const AFileName: String): TConnection; override;
    class function Load(const ASource: String): TConnection; override;
    class function LoadFromObject(const AObject: TObject): TConnection; override;
    class function LoadFromIni(const AINI: TCustomIniFile): TConnection;
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  Connection.Config.DocumentRefs,
  Connection.Config.INI.Mapper;

{ TConnectionConfigINI }

class function TConnectionConfigINI.ConfigFormat: TConnectionConfigFormat;
begin
  Result := ccfINI;
end;

class function TConnectionConfigINI.LoadFromIni(const AINI: TCustomIniFile): TConnection;
begin
  Result := TConnectionConfigIniMapper.LoadFromCustomIni(AINI);
end;

class function TConnectionConfigINI.LoadFromFile(const AFileName: String): TConnection;
var
  INI: TIniFile;
begin
  RequireFileExists(AFileName, Format('INI file not found: %s', [AFileName]));
  INI := TIniFile.Create(AFileName);
  try
    Result := TConnectionConfigIniMapper.LoadFromCustomIni(INI);
  finally
    INI.Free;
  end;
end;

class function TConnectionConfigINI.Load(const ASource: String): TConnection;
var
  Lines: TStringList;
  Mem:   TMemIniFile;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := ASource;
    Mem := TMemIniFile.Create(EmptyStr);
    try
      Mem.SetStrings(Lines);
      Result := TConnectionConfigIniMapper.LoadFromCustomIni(Mem);
    finally
      Mem.Free;
    end;
  finally
    Lines.Free;
  end;
end;

class function TConnectionConfigINI.LoadFromObject(const AObject: TObject): TConnection;
begin
  if AObject is TConnectionIniDocumentRef then
    Result := LoadFromIni(TConnectionIniDocumentRef(AObject).Document)
  else
    Result := inherited LoadFromObject(AObject);
end;

end.
