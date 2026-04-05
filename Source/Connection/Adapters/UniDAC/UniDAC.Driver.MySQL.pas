unit UniDAC.Driver.MySQL;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TUniDAC_MySQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
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
  MySQLUniProvider;

function TUniDAC_MySQLConfigurator.DriverName: TDriver;
begin
  Result := TDriver.MySQL;
end;

procedure TUniDAC_MySQLConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TUniConnection;
begin
  Conn := AConn as TUniConnection;
  Conn.ProviderName := 'MySQL';
  Conn.Server       := AParams.Host;
  Conn.Port         := IfThen(AParams.Port > 0, AParams.Port, 3306);
  Conn.Database     := AParams.Database;
  Conn.Username     := AParams.Username;
  Conn.Password     := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.LoginPrompt  := False;
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('CharacterSet') then
      Conn.SpecificOptions.Values['MySQL.CharSet'] := AParams.ExtraArgs['CharacterSet'];
    if AParams.ExtraArgs.ContainsKey('Compress') then
      Conn.SpecificOptions.Values['MySQL.UseCompression'] := AParams.ExtraArgs['Compress'];
  end;
end;

end.
