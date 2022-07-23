unit QueryHelper;

interface

{ Carrega a Interface Padrão }
{$I CNX.Default.inc}

uses
  System.SysUtils,
  System.IOUtils,
  System.StrUtils,
  System.DateUtils,
  System.Classes,
  System.Threading,

  Data.DBConsts,
  Data.DB,
  Data.FMTBcd,
  Data.SqlExpr,
  Data.SqlTimSt,
  Data.DBCommonTypes,

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

  { Classe Helper para o Objeto TSQLQuery ou TZQuery ou TFDQuery }
type
  TQueryHelper = class helper for {$I ..\CNX.Query.Type.inc}
  public
    procedure Open(SQL: String); overload;
  end;

implementation

{ TQueryHelper }

procedure TQueryHelper.Open(SQL: String);
{$IFDEF FireDACLib}
var
  Task: ITask;
{$ENDIF}
begin
{$IFDEF FireDACLib}
  if Self.Command.State <> csExecuting then
  begin
    Task := TTask.Create(
      procedure()
      begin
        Self.Open(SQL);
      end);
    Task.Start;
  end;
{$ENDIF}
{$IFDEF dbExpressLib}
  Self.Open(SQL);
{$ENDIF}
{$IFDEF ZeOSLib}
  Self.Open(SQL);
{$ENDIF}
end;

end.