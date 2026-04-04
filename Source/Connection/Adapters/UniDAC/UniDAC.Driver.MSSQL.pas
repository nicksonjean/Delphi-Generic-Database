unit UniDAC.Driver.MSSQL;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TUniDAC_MSSQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
  public
    function DriverName: TDriver;
    procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  Uni,
  SQLServerUniProvider;

function TUniDAC_MSSQLConfigurator.DriverName: TDriver;
begin
  Result := TDriver.MSSQL;
end;

procedure TUniDAC_MSSQLConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TUniConnection;
begin
  Conn := AConn as TUniConnection;
  Conn.ProviderName := 'SQL Server';
  Conn.Server       := AParams.Host;
  Conn.Port         := IfThen(AParams.Port > 0, AParams.Port, 1433);
  Conn.Database     := AParams.Database;
  Conn.Username     := AParams.Username;
  Conn.Password     := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.LoginPrompt  := False;
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('WindowsAuth') then
      Conn.SpecificOptions.Values['SQLServer.Authentication'] := 'Windows';
  end;
end;

end.
