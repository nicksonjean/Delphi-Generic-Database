unit ZeOS.Driver.MSSQL;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TZeOS_MSSQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
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

function TZeOS_MSSQLConfigurator.DriverName: TDriver;
begin
  Result := TDriver.MSSQL;
end;

procedure TZeOS_MSSQLConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TZConnection;
begin
  Conn := AConn as TZConnection;
{$IFDEF MSWINDOWS}
  Conn.LibraryLocation := ExtractFilePath(ParamStr(0)) + 'sybdb.dll';
{$ENDIF}
  Conn.HostName  := AParams.Host;
  Conn.Protocol  := 'FreeTDS_MsSQL>=2005';
  Conn.Port      := IfThen(AParams.Port > 0, AParams.Port, 1433);
  Conn.Database  := AParams.Database;
  Conn.User      := AParams.Username;
  Conn.Password  := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.AutoCommit := False;
  Conn.Properties.Clear;
  Conn.Properties.Add('CLIENT_MULTI_STATEMENTS=1');
  Conn.Properties.Add('trusted=yes');
  Conn.Properties.Add('ntauth=true');
  Conn.Properties.Add('secure=true');
  Conn.Properties.Add('AutoEncodeStrings=ON');
  Conn.Properties.Add('controls_cp=GET_ACP');
end;

end.
