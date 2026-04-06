unit UniDAC.Connection.Strategy;

interface

uses
  System.Generics.Collections,
  Connection.Types,
  Connection.Strategy.Intf;

type
  TUniDACConnectionStrategy = class(TInterfacedObject, IConnectionStrategy)
  strict private
    FConnection:    TObject; { TUniConnection }
    FConfigurators: TDictionary<TDriver, IDriverConfigurator>;
    FInTransaction: Boolean;
    procedure RegisterDrivers;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Configure(const AParams: TConnectionParams);
    procedure Connect;
    procedure Disconnect;
    function  IsConnected: Boolean;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    function  InTransaction: Boolean;
    function  NativeConnection: TObject;
    function  Engine: TEngine;
  end;

implementation

uses
  System.SysUtils,
  Uni,
  UniDAC.Driver.SQLite,
  UniDAC.Driver.MySQL,
  UniDAC.Driver.Firebird,
  UniDAC.Driver.Interbase,
  UniDAC.Driver.MSSQL,
  UniDAC.Driver.PostgreSQL,
  UniDAC.Driver.Oracle;

constructor TUniDACConnectionStrategy.Create;
begin
  inherited Create;
  FConnection    := TUniConnection.Create(nil);
  FConfigurators := TDictionary<TDriver, IDriverConfigurator>.Create;
  FInTransaction := False;
  RegisterDrivers;
end;

destructor TUniDACConnectionStrategy.Destroy;
begin
  var Conn := FConnection as TUniConnection;
  if Assigned(Conn) then
  begin
    try
      if Conn.Connected then Conn.Connected := False;
    except
    end;
    FreeAndNil(FConnection);
  end;
  FreeAndNil(FConfigurators);
  inherited Destroy;
end;

procedure TUniDACConnectionStrategy.RegisterDrivers;
begin
  FConfigurators.Add(TDriver.SQLite,     TUniDAC_SQLiteConfigurator.Create);
  FConfigurators.Add(TDriver.MySQL,      TUniDAC_MySQLConfigurator.Create);
  FConfigurators.Add(TDriver.Firebird,   TUniDAC_FirebirdConfigurator.Create);
  FConfigurators.Add(TDriver.Interbase,  TUniDAC_InterbaseConfigurator.Create);
  FConfigurators.Add(TDriver.MSSQL,      TUniDAC_MSSQLConfigurator.Create);
  FConfigurators.Add(TDriver.PostgreSQL, TUniDAC_PostgreSQLConfigurator.Create);
  FConfigurators.Add(TDriver.Oracle,     TUniDAC_OracleConfigurator.Create);
end;

procedure TUniDACConnectionStrategy.Configure(const AParams: TConnectionParams);
var
  Configurator: IDriverConfigurator;
  Conn: TUniConnection;
begin
  Conn := FConnection as TUniConnection;
  if Conn.Connected then Conn.Connected := False;
  if not FConfigurators.TryGetValue(AParams.Driver, Configurator) then
    raise ENotSupportedException.CreateFmt(
      'UniDAC: driver "%s" not supported.', [DriverToString(AParams.Driver)]);
  Configurator.Configure(FConnection, AParams);
end;

procedure TUniDACConnectionStrategy.Connect;
begin
  (FConnection as TUniConnection).Connected := True;
end;

procedure TUniDACConnectionStrategy.Disconnect;
var
  Conn: TUniConnection;
begin
  Conn := FConnection as TUniConnection;
  if Conn.Connected then Conn.Connected := False;
end;

function TUniDACConnectionStrategy.IsConnected: Boolean;
var
  Conn: TUniConnection;
begin
  Conn := FConnection as TUniConnection;
  Result := Assigned(Conn) and Conn.Connected;
end;

procedure TUniDACConnectionStrategy.StartTransaction;
begin
  (FConnection as TUniConnection).StartTransaction;
  FInTransaction := True;
end;

procedure TUniDACConnectionStrategy.Commit;
begin
  (FConnection as TUniConnection).Commit;
  FInTransaction := False;
end;

procedure TUniDACConnectionStrategy.Rollback;
begin
  (FConnection as TUniConnection).Rollback;
  FInTransaction := False;
end;

function TUniDACConnectionStrategy.InTransaction: Boolean;
begin
  Result := FInTransaction;
end;

function TUniDACConnectionStrategy.NativeConnection: TObject;
begin
  Result := FConnection;
end;

function TUniDACConnectionStrategy.Engine: TEngine;
begin
  Result := TEngine.UniDAC;
end;

end.
