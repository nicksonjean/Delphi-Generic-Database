{
  Connection
  ------------------------------------------------------------------------------
  Objetivo : Gerenciar conexão com banco de dados de forma agnóstica à engine.
  Suporta: FireDAC, dbExpress, ZeOS, UniDAC via Strategy Pattern.
  TConnection.Create exige TEngine explícita — não há engine padrão no registry.
  Sem IFDEF de engine.
  Inclua a unit Factory desejada no projeto para registrar a engine:
    FireDAC.Factory, dbExpress.Factory, ZeOS.Factory, UniDAC.Factory.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Connection.Types,
  Connection.IConnectionStrategy,
  EngineRegistry;

type
  IConnection = interface
    ['{B9F7FE0A-EAFC-48F3-85A0-E1219AD17076}']
    function  GetInstance: IConnection;
    procedure SetInstance;
    function  GetDriver: TDriver;
    procedure SetDriver(const Value: TDriver);
    function  GetHost: String;
    procedure SetHost(const Value: String);
    function  GetPort: Integer;
    procedure SetPort(const Value: Integer);
    function  GetSchema: String;
    procedure SetSchema(const Value: String);
    function  GetDatabase: String;
    procedure SetDatabase(const Value: String);
    function  GetUsername: String;
    procedure SetUsername(const Value: String);
    function  GetPassword: String;
    procedure SetPassword(const Value: String);
    function  GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
    procedure SetConnect(const Value: Boolean);
    function  GetEngine: TEngine;
    procedure SetEngine(const AEngine: TEngine);
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    function  InTransaction: Boolean;
    { Retorna o objeto de conexão nativo (TFDConnection, TSQLConnection, etc.) }
    function  NativeConnection: TObject;
    function  CheckDatabase: Boolean;
    { Strategy interna — para TQuery / TQueryBuilder usarem a mesma conexão configurada }
    function  GetConnectionStrategy: IConnectionStrategy;
    property Driver:    TDriver     read GetDriver    write SetDriver;
    property Host:      String      read GetHost       write SetHost;
    property Schema:    String      read GetSchema     write SetSchema;
    property Database:  String      read GetDatabase   write SetDatabase;
    property Username:  String      read GetUsername   write SetUsername;
    property Password:  String      read GetPassword   write SetPassword;
    property Port:      Integer     read GetPort       write SetPort;
    property Instance:  IConnection read GetInstance;
    property Connected: Boolean     read GetConnected  write SetConnected;
    property Connect:   Boolean     write SetConnect;
    property Engine:    TEngine     read GetEngine     write SetEngine;
  end;

  TConnection = class(TInterfacedObject, IConnection)
  private
    FStrategy:  IConnectionStrategy;
    FEngine:    TEngine;
    FParams:    TConnectionParams;
    FExtraArgs: TDictionary<String, String>;
    function  GetDriver: TDriver;
    procedure SetDriver(const Value: TDriver);
    function  GetHost: String;
    procedure SetHost(const Value: String);
    function  GetPort: Integer;
    procedure SetPort(const Value: Integer);
    function  GetSchema: String;
    procedure SetSchema(const Value: String);
    function  GetDatabase: String;
    procedure SetDatabase(const Value: String);
    function  GetUsername: String;
    procedure SetUsername(const Value: String);
    function  GetPassword: String;
    procedure SetPassword(const Value: String);
    function  GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
    procedure SetConnect(const Value: Boolean);
    function  GetEngine: TEngine;
    procedure SetEngine(const AEngine: TEngine);
    procedure SetInstance;
    procedure ApplyParams;
  public
    { Engine obrigatória — não há conexão implícita. }
    constructor Create(const AEngine: TEngine);
    destructor  Destroy; override;
    function  GetInstance: IConnection;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    function  InTransaction: Boolean;
    function  NativeConnection: TObject;
    function  CheckDatabase: Boolean;
    { Troca a engine em runtime. Lança EInvalidOpException se há transação ativa. }
    function  SwitchEngine(const AEngine: TEngine): TConnection;
    { Métodos chainable }
    function  WithEngine(const AEngine: TEngine): TConnection;
    function  WithDriver(const ADriver: TDriver): TConnection;
    function  WithHost(const AHost: String): TConnection;
    function  WithPort(const APort: Integer): TConnection;
    function  WithSchema(const ASchema: String): TConnection;
    function  WithDatabase(const ADatabase: String): TConnection;
    function  WithUsername(const AUsername: String): TConnection;
    function  WithPassword(const APassword: String): TConnection;
    function  AddArgument(const AKey, AValue: String): TConnection;
    function  AddParameter(const AKey, AValue: String): TConnection;
    { Expõe a ConnectionStrategy interna — usada por TQuery para injeção }
    function  GetConnectionStrategy: IConnectionStrategy;
    property Driver:    TDriver     read GetDriver    write SetDriver;
    property Host:      String      read GetHost       write SetHost;
    property Schema:    String      read GetSchema     write SetSchema;
    property Database:  String      read GetDatabase   write SetDatabase;
    property Username:  String      read GetUsername   write SetUsername;
    property Password:  String      read GetPassword   write SetPassword;
    property Port:      Integer     read GetPort       write SetPort;
    property Instance:  IConnection read GetInstance;
    property Connected: Boolean     read GetConnected  write SetConnected;
    property Connect:   Boolean     write SetConnect;
    property Engine:    TEngine     read GetEngine     write SetEngine;
  end;

implementation

{ TConnection }

constructor TConnection.Create(const AEngine: TEngine);
begin
  inherited Create;
  FExtraArgs        := TDictionary<String, String>.Create;
  FParams           := TConnectionParams.Default;
  FParams.ExtraArgs := FExtraArgs;
  FEngine           := AEngine;
  FStrategy         := TEngineRegistry.CreateConnectionStrategy(AEngine);
end;

destructor TConnection.Destroy;
begin
  if Assigned(FStrategy) and FStrategy.IsConnected then
  begin
    try
      FStrategy.Disconnect;
    except
    end;
  end;
  FStrategy := nil;
  FreeAndNil(FExtraArgs);
  inherited Destroy;
end;

procedure TConnection.SetInstance;
begin
  { Mantido para compatibilidade com IConnection — sem uso interno }
end;

function TConnection.GetInstance: IConnection;
begin
  Result := Self as IConnection;
end;

procedure TConnection.ApplyParams;
begin
  FParams.ExtraArgs := FExtraArgs;
  FStrategy.Configure(FParams);
end;

{ Engine }

function TConnection.GetEngine: TEngine;
begin
  Result := FEngine;
end;

procedure TConnection.SetEngine(const AEngine: TEngine);
begin
  if Assigned(FStrategy) and FStrategy.IsConnected then
  begin
    try
      FStrategy.Disconnect;
    except
    end;
  end;
  FStrategy := TEngineRegistry.CreateConnectionStrategy(AEngine);
  FEngine   := AEngine;
end;

function TConnection.SwitchEngine(const AEngine: TEngine): TConnection;
begin
  if Assigned(FStrategy) and FStrategy.InTransaction then
    raise EInvalidOpException.Create('Cannot switch engine while in transaction');
  SetEngine(AEngine);
  Result := Self;
end;

{ Métodos chainable }

function TConnection.WithEngine(const AEngine: TEngine): TConnection;
begin
  SetEngine(AEngine);
  Result := Self;
end;

function TConnection.WithDriver(const ADriver: TDriver): TConnection;
begin
  FParams.Driver := ADriver;
  Result := Self;
end;

function TConnection.WithHost(const AHost: String): TConnection;
begin
  FParams.Host := AHost;
  Result := Self;
end;

function TConnection.WithPort(const APort: Integer): TConnection;
begin
  FParams.Port := APort;
  Result := Self;
end;

function TConnection.WithSchema(const ASchema: String): TConnection;
begin
  FParams.Schema := ASchema;
  Result := Self;
end;

function TConnection.WithDatabase(const ADatabase: String): TConnection;
begin
  FParams.Database := ADatabase;
  Result := Self;
end;

function TConnection.WithUsername(const AUsername: String): TConnection;
begin
  FParams.Username := AUsername;
  Result := Self;
end;

function TConnection.WithPassword(const APassword: String): TConnection;
begin
  FParams.Password := APassword;
  Result := Self;
end;

function TConnection.AddArgument(const AKey, AValue: String): TConnection;
begin
  FExtraArgs.AddOrSetValue(AKey, AValue);
  Result := Self;
end;

function TConnection.AddParameter(const AKey, AValue: String): TConnection;
begin
  Result := AddArgument(AKey, AValue);
end;

function TConnection.GetConnectionStrategy: IConnectionStrategy;
begin
  Result := FStrategy;
end;

{ Getters / Setters de parâmetros }

function TConnection.GetDriver: TDriver;
begin
  Result := FParams.Driver;
end;

procedure TConnection.SetDriver(const Value: TDriver);
begin
  FParams.Driver := Value;
end;

function TConnection.GetHost: String;
begin
  Result := FParams.Host;
end;

procedure TConnection.SetHost(const Value: String);
begin
  FParams.Host := Value;
end;

function TConnection.GetPort: Integer;
begin
  Result := FParams.Port;
end;

procedure TConnection.SetPort(const Value: Integer);
begin
  FParams.Port := Value;
end;

function TConnection.GetSchema: String;
begin
  Result := FParams.Schema;
end;

procedure TConnection.SetSchema(const Value: String);
begin
  FParams.Schema := Value;
end;

function TConnection.GetDatabase: String;
begin
  Result := FParams.Database;
end;

procedure TConnection.SetDatabase(const Value: String);
begin
  FParams.Database := Value;
end;

function TConnection.GetUsername: String;
begin
  Result := FParams.Username;
end;

procedure TConnection.SetUsername(const Value: String);
begin
  FParams.Username := Value;
end;

function TConnection.GetPassword: String;
begin
  Result := FParams.Password;
end;

procedure TConnection.SetPassword(const Value: String);
begin
  FParams.Password := Value;
end;

{ Conexão }

function TConnection.GetConnected: Boolean;
begin
  Result := Assigned(FStrategy) and FStrategy.IsConnected;
end;

procedure TConnection.SetConnected(const Value: Boolean);
begin
  if Value then
  begin
    ApplyParams;
    FStrategy.Connect;
  end
  else
    FStrategy.Disconnect;
end;

procedure TConnection.SetConnect(const Value: Boolean);
begin
  if Value then
  begin
    try
      ApplyParams;
      FStrategy.Connect;
    except
      on E: Exception do
        raise;
    end;
  end
  else
    FStrategy.Disconnect;
end;

{ Transações }

procedure TConnection.StartTransaction;
begin
  FStrategy.StartTransaction;
end;

procedure TConnection.Commit;
begin
  FStrategy.Commit;
end;

procedure TConnection.Rollback;
begin
  FStrategy.Rollback;
end;

function TConnection.InTransaction: Boolean;
begin
  Result := FStrategy.InTransaction;
end;

{ Acesso nativo }

function TConnection.NativeConnection: TObject;
begin
  Result := FStrategy.NativeConnection;
end;

function TConnection.CheckDatabase: Boolean;
begin
  Result := False;
  { TODO: implementar via IQueryStrategy }
end;

initialization

end.
