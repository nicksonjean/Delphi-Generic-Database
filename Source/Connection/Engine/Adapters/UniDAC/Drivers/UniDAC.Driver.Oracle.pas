unit UniDAC.Driver.Oracle;

interface

uses
  Connection.Types,
  Connection.Strategy.Intf;

type
  TUniDAC_OracleConfigurator = class(TInterfacedObject, IDriverConfigurator)
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
  OracleUniProvider;

function TUniDAC_OracleConfigurator.DriverName: TDriver;
begin
  Result := TDriver.Oracle;
end;

procedure TUniDAC_OracleConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TUniConnection;
  Port: Integer;
begin
  Conn := AConn as TUniConnection;
  Port := IfThen(AParams.Port > 0, AParams.Port, 1521);
  Conn.ProviderName := 'Oracle';
  { Formato EZConnect via SpecificOptions }
  Conn.Server       := Format('%s:%d/%s', [AParams.Host, Port, AParams.Schema]);
  Conn.Database     := AParams.Database;
  Conn.Username     := AParams.Username;
  Conn.Password     := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.LoginPrompt  := False;
  Conn.SpecificOptions.Values['Oracle.Direct'] := 'False';
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('CharacterSet') then
      Conn.SpecificOptions.Values['Oracle.CharSet'] := AParams.ExtraArgs['CharacterSet'];
    if AParams.ExtraArgs.ContainsKey('NLS_LANGUAGE') then
      Conn.SpecificOptions.Values['Oracle.NLS_LANGUAGE'] := AParams.ExtraArgs['NLS_LANGUAGE'];
  end;
end;

end.
