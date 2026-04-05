unit ZeOS.Driver.MySQL;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TZeOS_MySQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
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

function TZeOS_MySQLConfigurator.DriverName: TDriver;
begin
  Result := TDriver.MySQL;
end;

procedure TZeOS_MySQLConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TZConnection;
begin
  Conn := AConn as TZConnection;
{$IFDEF MSWINDOWS}
  Conn.LibraryLocation := ExtractFilePath(ParamStr(0)) + 'libmysql.dll';
{$ENDIF}
  Conn.HostName  := AParams.Host;
  Conn.Protocol  := 'mysql';
  Conn.Port      := IfThen(AParams.Port > 0, AParams.Port, 3306);
  Conn.Database  := AParams.Database;
  Conn.User      := AParams.Username;
  Conn.Password  := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.AutoCommit := False;
  Conn.Properties.Clear;
  Conn.Properties.Add('CLIENT_MULTI_STATEMENTS=1');
  Conn.Properties.Add('controls_cp=GET_ACP');
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('CharacterSet') then
      Conn.Properties.Add('characterEncoding=' + AParams.ExtraArgs['CharacterSet']);
  end;
end;

end.
