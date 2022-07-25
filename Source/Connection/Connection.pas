{
  Connection.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a conexão à Bancos de Dados via codigos livre de
  componentes de terceiros.
  Suporta 3 Framework de Banco de Dados: dbExpres, ZeosLib e FireDAC.
  Suporta 5 Tipos de Banco de Dados: SQLite, MySQL/MariaDB, Firebird, Interbase,
  SQLServer, Firebird, PostgreSQL, Oracle
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  Colaborador : Ramon Ruan
  ------------------------------------------------------------------------------
  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la
  sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a versão 3.29 da Licença, ou (a seu critério)
  qualquer versão posterior.
  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM
  NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU
  ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor
  do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)
  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto
  com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,
  no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Você também pode obter uma copia da licença em:
  http://www.opensource.org/licenses/lgpl-license.php
}

{
  TODO -oNickson Jeanmerson -cProgrammer :
  1)   Criar Gerador de Classes com Base em Tabela
}

unit Connection;

interface

{ Carrega a Interface Padrão }
{$I CNX.Default.inc}

uses
  System.SysUtils,
  System.IOUtils,
  System.StrUtils,
  System.DateUtils,
  System.Classes,
  System.Math,

  System.SyncObjs,
  System.Threading,
  System.Generics.Collections,
  System.RTLConsts,
  System.Variants,
  System.JSON,
  System.RTTI,
  System.TypInfo,
  System.NetEncoding,

  Data.DBConsts,
  Data.DB,
  Data.FMTBcd,
  Data.SqlExpr,
  Data.SqlTimSt,
  Data.DBCommonTypes,

  FMX.Types,
  FMX.Forms,
  FMX.Grid,
  FMX.ComboEdit,
  FMX.ListBox,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.SearchBox,
  FMX.StdCtrls,

  FMX.Dialogs,

  Datasnap.DBClient,
  Datasnap.Provider,

  {dbExpress}
{$IFDEF dbExpressLib}
  Data.DBXSqlite,
{$IFDEF MSWINDOWS}
  Data.DBXMySql,
  Data.DBXMSSQL,
  Data.DBXFirebird,
  Data.DBXInterBase,
{$IFDEF DBXDevartLib}
  DBXDevartPostgreSQL,
  DBXDevartOracle,
{$ENDIF}
{$ENDIF}
{$ENDIF}
  {ZeOSLib}
{$IFDEF MSWINDOWS}
{$IFDEF ZeOSLib}
  ZAbstractConnection,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  ZConnection,
  ZAbstractTable,
  ZDbcConnection,
  ZClasses,
  ZDbcIntfs,
  ZTokenizer,
  ZCompatibility,
  ZGenericSqlToken,
  ZGenericSqlAnalyser,
  ZPlainDriver,
  ZURL,
  ZCollections,
  ZVariant,
{$ENDIF}
{$ENDIF}
  {FireDAC}
{$IFDEF FireDACLib}
  FireDAC.DatS,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.UI,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Stan.Param,
  FireDAC.Stan.ExprFuncs,
  FireDAC.UI.Intf,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  FireDAC.Phys.FB,
  FireDAC.Phys.IBWrapper,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef,
  FireDAC.Phys.Oracle,
  FireDAC.Phys.OracleDef,
{$ENDIF}
  System.Types,
{$IFDEF MSWINDOWS}
  Winapi.Windows,
  Winapi.Messages,
  FMX.Platform.Win,
{$ELSE}
  System.ByteStrings,
  FMX.Platform.Android,
  FMX.Helpers.Android,
{$ENDIF}
  System.UITypes;

type
  TDriver = (SQLite, MySQL, FIREBIRD, INTERBASE, MSSQL, POSTGRESQL, ORACLE);
  TEngine = (FireDAC, dbExpress, ZeOS);
  TEnvironment = (Local, Developer, Stage, Production);

  { Design Pattern Singleton }
type
  TSingleton<T: class, constructor> = class
  strict private
    class var SInstance: T;
  public
    class function GetInstance(): T;
    class procedure ReleaseInstance();
  end;

type
  IConnection = interface['{B9F7FE0A-EAFC-48F3-85A0-E1219AD17076}']
    function GetConnection: {$I CNX.Type.inc};
    function GetInstance: IConnection;
    procedure SetInstance;
    function GetDriver: TDriver;
    procedure SetDriver(const Value: TDriver);
    function GetHost: String;
    procedure SetHost(const Value: String);
    function GetPort: Integer;
    procedure SetPort(const Value: Integer);
    function GetSchema: String;
    procedure SetSchema(const Value: String);
    function GetDatabase: String;
    procedure SetDatabase(const Value: String);
    function GetUsername: String;
    procedure SetUsername(const Value: String);
    function GetPassword: String;
    procedure SetPassword(const Value: String);
    function GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
    procedure SetConnect(const Value: Boolean);
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    function CheckDatabase: Boolean;
    property Driver: TDriver read GetDriver write SetDriver;
    property Host: String read GetHost write SetHost;
    property Schema: String read GetSchema write SetSchema;
    property Database: String read GetDatabase write SetDatabase;
    property Username: String read GetUsername write SetUsername;
    property Password: String read GetPassword write SetPassword;
    property Port: Integer read GetPort write SetPort;
    property Instance: IConnection read GetInstance;
    property Connection: {$I CNX.Type.inc} read GetConnection;
    property Connected: Boolean read GetConnected write SetConnected;
    property Connect: Boolean write SetConnect;
  end;

{ Classe TConnexion Herdada de IConnexion }
type
  TConnection = class(TInterfacedObject, IConnection)
//  TConnection = class
  private
    { Private declarations }
    class var FInstance: IConnection;
    FConnection: {$I CNX.Type.inc};
    FConnected: Boolean;
    FDriver: TDriver;
    FHost: String;
    FPort: Integer;
    FSchema: String;
    FDatabase: String;
    FUsername: String;
    FPassword: String;
    function GetDriver: TDriver;
    procedure SetDriver(const Value: TDriver);
    function GetHost: String;
    procedure SetHost(const Value: String);
    function GetPort: Integer;
    procedure SetPort(const Value: Integer);
    function GetSchema: String;
    procedure SetSchema(const Value: String);
    function GetDatabase: String;
    procedure SetDatabase(const Value: String);
    function GetUsername: String;
    procedure SetUsername(const Value: String);
    function GetPassword: String;
    procedure SetPassword(const Value: String);
    function GetConnected: Boolean;
    procedure SetConnected(const Value: Boolean);
    procedure SetConnect(const Value: Boolean);
    function GetInstance: IConnection;
    procedure SetInstance;
    function GetConnection: {$I CNX.Type.inc};
{$IFDEF dbExpressLib}
    FTransaction: TTransactionDesc;
{$ENDIF}
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    function CheckDatabase: Boolean;
    property Driver: TDriver read GetDriver write SetDriver default SQLite;
    property Host: String read GetHost write SetHost;
    property Schema: String read GetSchema write SetSchema;
    property Database: String read GetDatabase write SetDatabase;
    property Username: String read GetUsername write SetUsername;
    property Password: String read GetPassword write SetPassword;
    property Port: Integer read GetPort write SetPort;
    property Instance: IConnection read GetInstance;
    property Connection: {$I CNX.Type.inc} read GetConnection;
    property Connected: Boolean read GetConnected write SetConnected;
    property Connect: Boolean write SetConnect;
  end;

  { Cria Instancia Singleton da Classe TConnection }
type
  TConnectionClass = TSingleton<TConnection>;

implementation

uses
  ISmartPointer,
  TSmartPointer,
  Query,
  QueryHelper,
  QueryBuilder;

{ Singleton }

class function TSingleton<T>.GetInstance: T;
begin
  if not Assigned(Self.SInstance) then
    Self.SInstance := T.Create();
  Result := Self.SInstance;
end;

class procedure TSingleton<T>.ReleaseInstance;
begin
  if Assigned(Self.SInstance) then
    Self.SInstance.Free;
end;

{ TConnection }

constructor TConnection.Create;
begin
  inherited Create;
  Self.SetInstance;
end;

destructor TConnection.Destroy;
begin
//  if Assigned(Self.FConnection) then
//    FreeAndNil(Self.FConnection);
  inherited Destroy;
end;

procedure TConnection.SetInstance;
begin
  FInstance := Self;
end;

function TConnection.GetInstance: IConnection;
begin
  Result := FInstance;
end;

function TConnection.GetDriver: TDriver;
begin
  Result := Self.FDriver;
end;

procedure TConnection.SetDriver(const Value: TDriver);
begin
  Self.FDriver := Value;
end;

function TConnection.GetPort: Integer;
begin
  Result := Self.FPort;
end;

procedure TConnection.SetPort(const Value: Integer);
begin
  Self.FPort := Value;
end;

function TConnection.GetHost: String;
begin
  Result := Self.FHost;
end;

procedure TConnection.SetHost(const Value: String);
begin
  Self.FHost := Value;
end;

function TConnection.GetSchema: String;
begin
  Result := Self.FSchema;
end;

procedure TConnection.SetSchema(const Value: String);
begin
  Self.FSchema := Value;
end;

function TConnection.GetDatabase: String;
begin
  Result := Self.FDatabase;
end;

procedure TConnection.SetDatabase(const Value: String);
begin
  Self.FDatabase := Value;
end;

function TConnection.GetUsername: String;
begin
  Result := Self.FUsername;
end;

procedure TConnection.SetUsername(const Value: String);
begin
  Self.FUsername := Value;
end;

function TConnection.GetPassword: String;
begin
  Result := Self.FPassword;
end;

procedure TConnection.SetPassword(const Value: String);
begin
  Self.FPassword := Value;
end;

procedure TConnection.SetConnected(const Value: Boolean);
begin
  Self.FConnected := Value;
  Self.FConnection.Connected := Self.FConnected;
end;

function TConnection.GetConnected: Boolean;
begin
  Result := Self.FConnected;
end;

procedure TConnection.SetConnect(const Value: Boolean);
begin
  if Value then
  begin
    try
      if not Assigned(Self.FConnection) then
      begin
        Self.FConnection := {$I CNX.Type.inc}.Create(nil);
{$I CNX.Params.inc}
        Self.SetConnected(Value);
      end;
    except
      on E: Exception do
      begin
        Self.SetConnected(False);
        raise Exception.Create(E.Message);
      end;
    end;
  end;
  Self.SetConnected(Value);
end;

function TConnection.GetConnection: {$I CNX.Type.inc};
begin
  Result := Self.FConnection;
end;

procedure TConnection.StartTransaction;
begin
  if Assigned(FInstance) then
  begin
{$IFDEF dbExpressLib}
    Self.FTransaction.IsolationLevel := xilREADCOMMITTED;
    Self.Connection.StartTransaction(FTransaction);
{$ENDIF}
{$IFDEF FireDACLib}
    Self.Connection.StartTransaction;
{$ENDIF}
{$IFDEF ZeOSLib}
    Self.Connection.StartTransaction;
{$ENDIF}
  end;
end;

procedure TConnection.Commit;
begin
{$IFDEF dbExpressLib}
  Self.Connection.Commit(FTransaction);
{$ENDIF}
{$IFDEF FireDACLib}
  Self.Connection.Commit;
{$ENDIF}
{$IFDEF ZeOSLib}
  Self.Connection.Commit;
{$ENDIF}
end;

procedure TConnection.Rollback;
begin
{$IFDEF dbExpressLib}
  Self.Connection.Rollback(FTransaction);
{$ENDIF}
{$IFDEF FireDACLib}
  Self.Connection.Rollback;
{$ENDIF}
{$IFDEF ZeOSLib}
  Self.Connection.Rollback;
{$ENDIF}
end;

function TConnection.CheckDatabase: Boolean;
var
  Query: TQueryBuilder;
  SQL: TQuery;
begin
  Result := false;
  case Self.Driver of
    MySQL :
    begin
      SQL := Query.View('SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = ' + QuotedStr(Self.Database));
      if not SQL.Query.IsEmpty then
        Result := True;
    end;
    POSTGRESQL:
    begin
      SQL := Query.View('SELECT 1 AS result FROM pg_database WHERE datname = ' + QuotedStr(Self.Database));
      if not SQL.Query.IsEmpty then
        Result := True;
    end;
    ORACLE:
    begin

    end;
    SQLite, FIREBIRD, INTERBASE:
    begin

    end;
    MSSQL:
    begin

    end;
  end;
end;

initialization

finalization

TConnectionClass.ReleaseInstance();

end.
