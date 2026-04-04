unit ZeOS.Driver.PostgreSQL;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TZeOS_PostgreSQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
  public
    function DriverName: TDriver;
    procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  ZConnection;

function TZeOS_PostgreSQLConfigurator.DriverName: TDriver;
begin
  Result := TDriver.PostgreSQL;
end;

procedure TZeOS_PostgreSQLConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TZConnection;
begin
  Conn := AConn as TZConnection;
{$IFDEF MSWINDOWS}
  Conn.LibraryLocation := ExtractFilePath(ParamStr(0)) + 'libpq.dll';
{$ENDIF}
  Conn.HostName  := AParams.Host;
  Conn.Protocol  := 'postgresql';
  Conn.Port      := IfThen(AParams.Port > 0, AParams.Port, 5432);
  Conn.Database  := AParams.Database;
  Conn.Catalog   := IfThen(AParams.Schema = '', 'public', AParams.Schema);
  Conn.User      := AParams.Username;
  Conn.Password  := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.AutoCommit := False;
  Conn.Properties.Clear;
  Conn.Properties.Add('CLIENT_MULTI_STATEMENTS=1');
  Conn.Properties.Add('controls_cp=GET_ACP');
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('lc_ctype') then
      Conn.Properties.Add('lc_ctype=' + AParams.ExtraArgs['lc_ctype']);
    if AParams.ExtraArgs.ContainsKey('search_path') then
      Conn.Properties.Add('options=-c search_path=' + AParams.ExtraArgs['search_path']);
  end;
end;

end.
