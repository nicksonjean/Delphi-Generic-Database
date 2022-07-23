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

type        // OK     OK       OK        OK       OK        OK        OK
  TDriver = (SQLite, MySQL, FIREBIRD, INTERBASE, MSSQL, POSTGRESQL, ORACLE);

  { Design Pattern Singleton }
type
  TSingleton<T: class, constructor> = class
  strict private
    class var SInstance: T;
  public
    class function GetInstance(): T;
    class procedure ReleaseInstance();
  end;

  { Classe TConnection Herdada de TObject }
type
  TConnection = class(TObject)
  private
    { Private declarations }
    class var FInstance: TConnection;
    class var FSQLInstance: {$I CNX.Type.inc};
    class var FDriver: TDriver;
    class var FHost: String;
    class var FSchema: String;
    class var FDatabase: String;
    class var FUsername: String;
    class var FPassword: String;
    class var FPort: Integer;
    class procedure SetDriver(const Value: TDriver); static;
    class function GetConnection: {$I CNX.Type.inc}; static;
{$IFDEF dbExpressLib}
    class var FTransaction: TTransactionDesc;
{$ENDIF}
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    class property Driver: TDriver read FDriver write SetDriver default SQLite;
    class property Host: String read FHost write FHost;
    class property Schema: String read FSchema write FSchema;
    class property Database: String read FDatabase write FDatabase;
    class property Username: String read FUsername write FUsername;
    class property Password: String read FPassword write FPassword;
    class property Port: Integer read FPort write FPort;
    class property Connection: {$I CNX.Type.inc} read GetConnection;
    class function GetInstance: TConnection;
    class procedure StartTransaction;
    class procedure Commit;
    class procedure Rollback;
    class function CheckDatabase : Boolean;
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
end;

destructor TConnection.Destroy;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
  if Assigned(FSQLInstance) then
    FreeAndNil(FSQLInstance);

  inherited;
end;

class procedure TConnection.SetDriver(const Value: TDriver);
begin
  FDriver := Value;
end;

class function TConnection.GetConnection: {$I CNX.Type.inc};
begin
  Result := FSQLInstance;
end;

class function TConnection.GetInstance: TConnection;
begin
  try
    if not Assigned(FInstance) then
    begin
      FInstance := TConnection.Create;
      TConnection.FInstance.FSQLInstance := {$I CNX.Type.inc}.Create(nil);
{$I CNX.Params.inc}
    end;
  except
    on E: Exception do
      raise Exception.Create(E.Message);
  end;
  Result := FInstance;
end;

class procedure TConnection.StartTransaction;
begin
  if Assigned(FInstance) then
  begin
{$IFDEF dbExpressLib}
    FTransaction.IsolationLevel := xilREADCOMMITTED;
    FInstance.Connection.StartTransaction(FTransaction);
{$ENDIF}
{$IFDEF FireDACLib}
    FInstance.Connection.StartTransaction;
{$ENDIF}
{$IFDEF ZeOSLib}
    FInstance.Connection.StartTransaction;
{$ENDIF}
  end;
end;

class procedure TConnection.Commit;
begin
{$IFDEF dbExpressLib}
    FInstance.Connection.Commit(FTransaction);
{$ENDIF}
{$IFDEF FireDACLib}
    FInstance.Connection.Commit;
{$ENDIF}
{$IFDEF ZeOSLib}
    FInstance.Connection.Commit;
{$ENDIF}
end;

class procedure TConnection.Rollback;
begin
{$IFDEF dbExpressLib}
    FInstance.Connection.Rollback(FTransaction);
{$ENDIF}
{$IFDEF FireDACLib}
    FInstance.Connection.Rollback;
{$ENDIF}
{$IFDEF ZeOSLib}
    FInstance.Connection.Rollback;
{$ENDIF}
end;

class function TConnection.CheckDatabase: Boolean;
var
  Query: TQueryBuilder;
  SQL: TQuery;
begin
  Result := false;
  case FInstance.Driver of
    MySQL :
    begin
      SQL := Query.View('SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = ' + QuotedStr(FInstance.Database));
      if not SQL.Query.IsEmpty then
        Result := True;
    end;
    POSTGRESQL:
    begin
      SQL := Query.View('SELECT 1 AS result FROM pg_database WHERE datname = ' + QuotedStr(FInstance.Database));
      if not SQL.Query.IsEmpty then
        Result := True;
    end;
    ORACLE :
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

end.
