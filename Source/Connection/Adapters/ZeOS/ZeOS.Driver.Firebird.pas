unit ZeOS.Driver.Firebird;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TZeOS_FirebirdConfigurator = class(TInterfacedObject, IDriverConfigurator)
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

function TZeOS_FirebirdConfigurator.DriverName: TDriver;
begin
  Result := TDriver.Firebird;
end;

procedure TZeOS_FirebirdConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TZConnection;
begin
  Conn := AConn as TZConnection;
{$IFDEF MSWINDOWS}
  Conn.LibraryLocation := ExtractFilePath(ParamStr(0)) + 'fbclient.dll';
{$ENDIF}
  Conn.HostName  := AParams.Host;
  Conn.Protocol  := 'firebird-3.0';
  Conn.Port      := IfThen(AParams.Port > 0, AParams.Port, 3050);
  Conn.Database  := AParams.Database;
  Conn.User      := AParams.Username;
  Conn.Password  := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.AutoCommit := False;
  Conn.Properties.Clear;
  Conn.Properties.Add('CLIENT_MULTI_STATEMENTS=1');
  Conn.Properties.Add('controls_cp=GET_ACP');
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('SQLDialect') then
      Conn.Properties.Add('dialect=' + AParams.ExtraArgs['SQLDialect']);
    if AParams.ExtraArgs.ContainsKey('CharacterSet') then
      Conn.Properties.Add('lc_ctype=' + AParams.ExtraArgs['CharacterSet']);
  end;
end;

end.
