unit FireDAC.Connection.Strategy;

{
  FireDAC.Connection.Strategy
  ------------------------------------------------------------------------------
  Implementação de IConnectionStrategy para FireDAC.
  Gerencia TFDConnection e delega configuração de driver a IDriverConfigurator.
  Cada instância possui seu próprio TFDConnection com nome único para evitar
  conflitos no pool interno do FireDAC.
  ------------------------------------------------------------------------------
  Toda lógica FireDAC reside nesta unit e em seus Driver.*.pas — zero
  $IFDEF de engine em Connection.pas.
}

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Connection.Types,
  Connection.Strategy.Intf;

type
  TFireDACConnectionStrategy = class(TInterfacedObject, IConnectionStrategy)
  strict private
    class var FInstanceCount: Integer;
    FConnection:   TObject; { TFDConnection — declarado como TObject para não vazar FireDAC fora }
    FConnectionName: String;
    FConfigurators: TDictionary<TDriver, IDriverConfigurator>;
    FLastDriver:   TDriver;
    FLastSchema:   String;
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
  System.Threading,
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Comp.Client,
  FireDAC.UI.Intf,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.FB,
  FireDAC.Phys.IBWrapper,
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.PG,
  FireDAC.Phys.Oracle,

  FireDAC.Driver.SQLite,
  FireDAC.Driver.MySQL,
  FireDAC.Driver.Firebird,
  FireDAC.Driver.Interbase,
  FireDAC.Driver.MSSQL,
  FireDAC.Driver.PostgreSQL,
  FireDAC.Driver.Oracle;

{ TFireDACConnectionStrategy }

constructor TFireDACConnectionStrategy.Create;
begin
  inherited Create;
  Inc(FInstanceCount);
  FConnectionName := 'CNX_FD_' + IntToStr(FInstanceCount) + '_'
{$IFDEF MSWINDOWS}
                   + IntToStr(GetCurrentThreadId)
{$ELSE}
                   + IntToStr(TThread.CurrentThread.ThreadID)
{$ENDIF}
                   ;
  FConfigurators  := TDictionary<TDriver, IDriverConfigurator>.Create;
  FInTransaction  := False;
  FConnection     := TFDConnection.Create(nil);
  RegisterDrivers;
end;

destructor TFireDACConnectionStrategy.Destroy;
var
  Conn: TFDConnection;
begin
  Conn := FConnection as TFDConnection;
  if Assigned(Conn) then
  begin
    try
      if Conn.Connected then Conn.Connected := False;
      Conn.Close;
    except
    end;
    { TFDConnection.Destroy pode lançar durante limpeza do pool interno do FireDAC.
      Capturamos silenciosamente para não impedir a liberação de FConfigurators e
      do próprio TFireDACConnectionStrategy (evita o vazamento em cascata). }
    try
      FreeAndNil(FConnection);
    except
    end;
  end;
  FreeAndNil(FConfigurators);
  inherited Destroy;
end;

procedure TFireDACConnectionStrategy.RegisterDrivers;
begin
  FConfigurators.Add(TDriver.SQLite,     TFireDAC_SQLiteConfigurator.Create);
  FConfigurators.Add(TDriver.MySQL,      TFireDAC_MySQLConfigurator.Create);
  FConfigurators.Add(TDriver.Firebird,   TFireDAC_FirebirdConfigurator.Create);
  FConfigurators.Add(TDriver.Interbase,  TFireDAC_InterbaseConfigurator.Create);
  FConfigurators.Add(TDriver.MSSQL,      TFireDAC_MSSQLConfigurator.Create);
  FConfigurators.Add(TDriver.PostgreSQL, TFireDAC_PostgreSQLConfigurator.Create);
  FConfigurators.Add(TDriver.Oracle,     TFireDAC_OracleConfigurator.Create);
end;


procedure TFireDACConnectionStrategy.Configure(const AParams: TConnectionParams);
var
  Configurator: IDriverConfigurator;
  Conn: TFDConnection;
begin
  Conn := FConnection as TFDConnection;
  if Conn.Connected then Conn.Connected := False;

  if not FConfigurators.TryGetValue(AParams.Driver, Configurator) then
    raise ENotSupportedException.CreateFmt(
      'FireDAC: driver "%s" not supported.', [DriverToString(AParams.Driver)]);

  Configurator.Configure(FConnection, AParams);

  { FireDAC: sobrescreve o ConnectionName fixo com nome único por instância
    para evitar conflito no pool interno (-503) }
  Conn.ConnectionName := FConnectionName;

  FLastDriver := AParams.Driver;
  FLastSchema := AParams.Schema;
end;

procedure TFireDACConnectionStrategy.Connect;
var
  Conn: TFDConnection;
begin
  Conn := FConnection as TFDConnection;
  Conn.Connected := True;

  { PostgreSQL: definir search_path após conexão }
  if FLastDriver = TDriver.PostgreSQL then
  begin
    if FLastSchema <> '' then
    try
      Conn.ExecSQL(Format('SET search_path TO E''%s'', E''public'';', [FLastSchema]));
    except
      { Não interromper por falha no search_path }
    end;
  end;
end;

procedure TFireDACConnectionStrategy.Disconnect;
var
  Conn: TFDConnection;
begin
  Conn := FConnection as TFDConnection;
  if Conn.Connected then Conn.Connected := False;
end;

function TFireDACConnectionStrategy.IsConnected: Boolean;
var
  Conn: TFDConnection;
begin
  Conn := FConnection as TFDConnection;
  Result := Assigned(Conn) and Conn.Connected;
end;

procedure TFireDACConnectionStrategy.StartTransaction;
var
  Conn: TFDConnection;
begin
  Conn := FConnection as TFDConnection;
  Conn.StartTransaction;
  FInTransaction := True;
end;

procedure TFireDACConnectionStrategy.Commit;
var
  Conn: TFDConnection;
begin
  Conn := FConnection as TFDConnection;
  Conn.Commit;
  FInTransaction := False;
end;

procedure TFireDACConnectionStrategy.Rollback;
var
  Conn: TFDConnection;
begin
  Conn := FConnection as TFDConnection;
  Conn.Rollback;
  FInTransaction := False;
end;

function TFireDACConnectionStrategy.InTransaction: Boolean;
begin
  Result := FInTransaction;
end;

function TFireDACConnectionStrategy.NativeConnection: TObject;
begin
  Result := FConnection;
end;

function TFireDACConnectionStrategy.Engine: TEngine;
begin
  Result := TEngine.FireDAC;
end;

end.
