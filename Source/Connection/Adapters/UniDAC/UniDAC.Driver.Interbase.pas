unit UniDAC.Driver.Interbase;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TUniDAC_InterbaseConfigurator = class(TInterfacedObject, IDriverConfigurator)
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
  InterBaseUniProvider;

function TUniDAC_InterbaseConfigurator.DriverName: TDriver;
begin
  Result := TDriver.Interbase;
end;

procedure TUniDAC_InterbaseConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TUniConnection;
begin
  Conn := AConn as TUniConnection;
  Conn.ProviderName := 'InterBase';
  Conn.Server       := AParams.Host;
  Conn.Port         := IfThen(AParams.Port > 0, AParams.Port, 3050);
  Conn.Database     := AParams.Database;
  Conn.Username     := AParams.Username;
  Conn.Password     := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.LoginPrompt  := False;
  Conn.SpecificOptions.Values['InterBase.ServerType'] := 'InterBase';
  Conn.SpecificOptions.Values['InterBase.CharSet']    := 'UTF8';
  Conn.SpecificOptions.Values['InterBase.SQLDialect'] := '3';
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('CharacterSet') then
      Conn.SpecificOptions.Values['InterBase.CharSet'] := AParams.ExtraArgs['CharacterSet'];
  end;
end;

end.
