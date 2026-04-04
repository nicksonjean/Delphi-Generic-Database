unit UniDAC.Driver.SQLite;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TUniDAC_SQLiteConfigurator = class(TInterfacedObject, IDriverConfigurator)
  public
    function DriverName: TDriver;
    procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  end;

implementation

uses
  System.SysUtils,
  Uni,             { TUniConnection }
  SQLiteUniProvider;

function TUniDAC_SQLiteConfigurator.DriverName: TDriver;
begin
  Result := TDriver.SQLite;
end;

procedure TUniDAC_SQLiteConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TUniConnection;
begin
  Conn := AConn as TUniConnection;
  Conn.ProviderName := 'SQLite';
  Conn.Database     := AParams.Database;
  Conn.LoginPrompt  := False;
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('ForceCreateDatabase') then
      Conn.SpecificOptions.Values['SQLite.ForceCreateDatabase'] := AParams.ExtraArgs['ForceCreateDatabase'];
  end;
end;

end.
