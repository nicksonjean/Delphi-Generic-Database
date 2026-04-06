unit ZeOS.Driver.Interbase;

interface

uses
  Connection.Types,
  Connection.Strategy.Intf;

type
  TZeOS_InterbaseConfigurator = class(TInterfacedObject, IDriverConfigurator)
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

function TZeOS_InterbaseConfigurator.DriverName: TDriver;
begin
  Result := TDriver.Interbase;
end;

procedure TZeOS_InterbaseConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TZConnection;
begin
  Conn := AConn as TZConnection;
{$IFDEF MSWINDOWS}
  Conn.LibraryLocation := ExtractFilePath(ParamStr(0)) + 'gds32.dll';
{$ENDIF}
  Conn.HostName  := AParams.Host;
  Conn.Protocol  := 'interbase';
  Conn.Port      := IfThen(AParams.Port > 0, AParams.Port, 3050);
  Conn.Database  := AParams.Database;
  Conn.User      := AParams.Username;
  Conn.Password  := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.AutoCommit := False;
  Conn.Properties.Clear;
  Conn.Properties.Add('CLIENT_MULTI_STATEMENTS=1');
  Conn.Properties.Add('controls_cp=GET_ACP');
end;

end.
