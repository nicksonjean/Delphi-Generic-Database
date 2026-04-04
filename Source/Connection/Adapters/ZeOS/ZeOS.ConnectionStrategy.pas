unit ZeOS.ConnectionStrategy;

interface

uses
  System.Generics.Collections,
  Connection.Types,
  Connection.IConnectionStrategy,
  Connection.IDriverConfigurator;

type
  TZeOSConnectionStrategy = class(TInterfacedObject, IConnectionStrategy)
  strict private
    FConnection:    TObject; { TZConnection }
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
  ZConnection,
  ZeOS.Driver.SQLite,
  ZeOS.Driver.MySQL,
  ZeOS.Driver.Firebird,
  ZeOS.Driver.Interbase,
  ZeOS.Driver.MSSQL,
  ZeOS.Driver.PostgreSQL,
  ZeOS.Driver.Oracle;

constructor TZeOSConnectionStrategy.Create;
begin
  inherited Create;
  FConnection    := TZConnection.Create(nil);
  FConfigurators := TDictionary<TDriver, IDriverConfigurator>.Create;
  FInTransaction := False;
  RegisterDrivers;
end;

destructor TZeOSConnectionStrategy.Destroy;
begin
  var Conn := FConnection as TZConnection;
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

procedure TZeOSConnectionStrategy.RegisterDrivers;
begin
  FConfigurators.Add(TDriver.SQLite,     TZeOS_SQLiteConfigurator.Create);
  FConfigurators.Add(TDriver.MySQL,      TZeOS_MySQLConfigurator.Create);
  FConfigurators.Add(TDriver.Firebird,   TZeOS_FirebirdConfigurator.Create);
  FConfigurators.Add(TDriver.Interbase,  TZeOS_InterbaseConfigurator.Create);
  FConfigurators.Add(TDriver.MSSQL,      TZeOS_MSSQLConfigurator.Create);
  FConfigurators.Add(TDriver.PostgreSQL, TZeOS_PostgreSQLConfigurator.Create);
  FConfigurators.Add(TDriver.Oracle,     TZeOS_OracleConfigurator.Create);
end;

procedure TZeOSConnectionStrategy.Configure(const AParams: TConnectionParams);
var
  Configurator: IDriverConfigurator;
  Conn: TZConnection;
begin
  Conn := FConnection as TZConnection;
  if Conn.Connected then Conn.Connected := False;
  if not FConfigurators.TryGetValue(AParams.Driver, Configurator) then
    raise ENotSupportedException.CreateFmt(
      'ZeOS: driver "%s" not supported.', [DriverToString(AParams.Driver)]);
  Configurator.Configure(FConnection, AParams);
end;

procedure TZeOSConnectionStrategy.Connect;
begin
  (FConnection as TZConnection).Connected := True;
end;

procedure TZeOSConnectionStrategy.Disconnect;
var
  Conn: TZConnection;
begin
  Conn := FConnection as TZConnection;
  if Conn.Connected then Conn.Connected := False;
end;

function TZeOSConnectionStrategy.IsConnected: Boolean;
var
  Conn: TZConnection;
begin
  Conn := FConnection as TZConnection;
  Result := Assigned(Conn) and Conn.Connected;
end;

procedure TZeOSConnectionStrategy.StartTransaction;
begin
  (FConnection as TZConnection).StartTransaction;
  FInTransaction := True;
end;

procedure TZeOSConnectionStrategy.Commit;
begin
  (FConnection as TZConnection).Commit;
  FInTransaction := False;
end;

procedure TZeOSConnectionStrategy.Rollback;
begin
  (FConnection as TZConnection).Rollback;
  FInTransaction := False;
end;

function TZeOSConnectionStrategy.InTransaction: Boolean;
begin
  Result := FInTransaction;
end;

function TZeOSConnectionStrategy.NativeConnection: TObject;
begin
  Result := FConnection;
end;

function TZeOSConnectionStrategy.Engine: TEngine;
begin
  Result := TEngine.ZeOS;
end;

end.
