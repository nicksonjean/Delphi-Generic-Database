unit UniDAC.Driver.PostgreSQL;

interface

uses
  Connection.Types,
  Connection.Strategy.Intf;

type
  TUniDAC_PostgreSQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
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
  PostgreSQLUniProvider;

function TUniDAC_PostgreSQLConfigurator.DriverName: TDriver;
begin
  Result := TDriver.PostgreSQL;
end;

procedure TUniDAC_PostgreSQLConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TUniConnection;
begin
  Conn := AConn as TUniConnection;
  Conn.ProviderName := 'PostgreSQL';
  Conn.Server       := AParams.Host;
  Conn.Port         := IfThen(AParams.Port > 0, AParams.Port, 5432);
  Conn.Database     := AParams.Database;
  Conn.Username     := AParams.Username;
  Conn.Password     := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.LoginPrompt  := False;
  if AParams.Schema <> '' then
    Conn.SpecificOptions.Values['PostgreSQL.SearchPath'] := AParams.Schema;
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('CharacterSet') then
      Conn.SpecificOptions.Values['PostgreSQL.Charset'] := AParams.ExtraArgs['CharacterSet'];
    if AParams.ExtraArgs.ContainsKey('lc_ctype') then
      Conn.SpecificOptions.Values['PostgreSQL.lc_ctype'] := AParams.ExtraArgs['lc_ctype'];
    if AParams.ExtraArgs.ContainsKey('search_path') then
      Conn.SpecificOptions.Values['PostgreSQL.SearchPath'] := AParams.ExtraArgs['search_path'];
  end;
end;

end.
