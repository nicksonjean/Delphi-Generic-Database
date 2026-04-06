unit dbExpress.Connection.Strategy;

{
  dbExpress.Connection.Strategy
  ------------------------------------------------------------------------------
  Implementação de IConnectionStrategy para dbExpress.
  Gerencia TSQLConnection e transações via TDBXTransaction / BeginTransaction (dbExpress).
}

interface

uses
  System.Generics.Collections,
  Connection.Types,
  Connection.Strategy.Intf,
  Data.DBXCommon;

type
  TdbExpressConnectionStrategy = class(TInterfacedObject, IConnectionStrategy)
  strict private
    FConnection:    TObject; { TSQLConnection }
    FConfigurators: TDictionary<TDriver, IDriverConfigurator>;
    { Transação ativa retornada por TSQLConnection.BeginTransaction (substitui StartTransaction/Commit/Rollback depreciados). }
    FDBXTransaction: TDBXTransaction;
    FInTransaction: Boolean;
    procedure RegisterDrivers;
  public
    constructor Create;
    destructor  Destroy; override;
    { IConnectionStrategy }
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
  Data.SqlExpr,
  dbExpress.Driver.SQLite,
  dbExpress.Driver.MySQL,
  dbExpress.Driver.Firebird,
  dbExpress.Driver.Interbase,
  dbExpress.Driver.MSSQL,
  dbExpress.Driver.PostgreSQL,
  dbExpress.Driver.Oracle;

{ TdbExpressConnectionStrategy }

constructor TdbExpressConnectionStrategy.Create;
begin
  inherited Create;
  FConnection    := TSQLConnection.Create(nil);
  FConfigurators := TDictionary<TDriver, IDriverConfigurator>.Create;
  FInTransaction := False;
  RegisterDrivers;
end;

destructor TdbExpressConnectionStrategy.Destroy;
begin
  var Conn := FConnection as TSQLConnection;
  if Assigned(Conn) then
  begin
    try
      if FInTransaction then
        Conn.RollbackFreeAndNil(FDBXTransaction);
    except
    end;
    FInTransaction := False;
    try
      if Conn.Connected then Conn.Connected := False;
    except
    end;
    FreeAndNil(FConnection);
  end;
  FreeAndNil(FConfigurators);
  inherited Destroy;
end;

procedure TdbExpressConnectionStrategy.RegisterDrivers;
begin
  FConfigurators.Add(TDriver.SQLite,     TdbExpress_SQLiteConfigurator.Create);
  FConfigurators.Add(TDriver.MySQL,      TdbExpress_MySQLConfigurator.Create);
  FConfigurators.Add(TDriver.Firebird,   TdbExpress_FirebirdConfigurator.Create);
  FConfigurators.Add(TDriver.Interbase,  TdbExpress_InterbaseConfigurator.Create);
  FConfigurators.Add(TDriver.MSSQL,      TdbExpress_MSSQLConfigurator.Create);
  FConfigurators.Add(TDriver.PostgreSQL, TdbExpress_PostgreSQLConfigurator.Create);
  FConfigurators.Add(TDriver.Oracle,     TdbExpress_OracleConfigurator.Create);
end;

procedure TdbExpressConnectionStrategy.Configure(const AParams: TConnectionParams);
var
  Configurator: IDriverConfigurator;
  Conn: TSQLConnection;
begin
  Conn := FConnection as TSQLConnection;
  if Conn.Connected then Conn.Connected := False;
  if not FConfigurators.TryGetValue(AParams.Driver, Configurator) then
    raise ENotSupportedException.CreateFmt(
      'dbExpress: driver "%s" not supported.', [DriverToString(AParams.Driver)]);
  Configurator.Configure(FConnection, AParams);
end;

procedure TdbExpressConnectionStrategy.Connect;
begin
  (FConnection as TSQLConnection).Connected := True;
end;

procedure TdbExpressConnectionStrategy.Disconnect;
var
  Conn: TSQLConnection;
begin
  Conn := FConnection as TSQLConnection;
  if Conn.Connected then Conn.Connected := False;
end;

function TdbExpressConnectionStrategy.IsConnected: Boolean;
var
  Conn: TSQLConnection;
begin
  Conn := FConnection as TSQLConnection;
  Result := Assigned(Conn) and Conn.Connected;
end;

procedure TdbExpressConnectionStrategy.StartTransaction;
var
  Conn: TSQLConnection;
begin
  Conn := FConnection as TSQLConnection;
  { Sobrecarga sem parâmetro usa o nível padrão da conexão (equivalente prático ao antigo READ COMMITTED na maioria dos drivers). }
  FDBXTransaction := Conn.BeginTransaction;
  FInTransaction := True;
end;

procedure TdbExpressConnectionStrategy.Commit;
var
  Conn: TSQLConnection;
begin
  if not FInTransaction then
    Exit;
  Conn := FConnection as TSQLConnection;
  Conn.CommitFreeAndNil(FDBXTransaction);
  FInTransaction := False;
end;

procedure TdbExpressConnectionStrategy.Rollback;
var
  Conn: TSQLConnection;
begin
  if not FInTransaction then
    Exit;
  Conn := FConnection as TSQLConnection;
  Conn.RollbackFreeAndNil(FDBXTransaction);
  FInTransaction := False;
end;

function TdbExpressConnectionStrategy.InTransaction: Boolean;
begin
  Result := FInTransaction;
end;

function TdbExpressConnectionStrategy.NativeConnection: TObject;
begin
  Result := FConnection;
end;

function TdbExpressConnectionStrategy.Engine: TEngine;
begin
  Result := TEngine.dbExpress;
end;

end.
