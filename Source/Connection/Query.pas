unit Query;

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

  Float,
  Strings,
  MimeType,
  ArrayString,
  ArrayStringHelper,
  ArrayVariant,
  ArrayVariantHelper,
  ArrayField,
  ArrayFieldHelper,
  ArrayAssoc,
  Connection,

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

  { Classe TQuery Herdada de TConnection }
type
  TQuery = class(TConnection)
  private
    { Private declarations }
    FInstance: TConnection;
    FQuery: {$I CNX.Query.Type.inc};
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    property Query: {$I CNX.Query.Type.inc} read FQuery write FQuery;
  end;

implementation

{ TQuery }

constructor TQuery.Create;
begin
  FInstance := TConnection.Create;
  Self.FQuery := {$I CNX.Query.Type.inc}.Create(nil);
{$IFDEF dbExpressLib}
  Self.FQuery.SQLConnection := FInstance.GetInstance.Connection;
{$ENDIF}
{$IFDEF FireDACLib}
  Self.FQuery.Connection := FInstance.GetInstance.Connection;
{$ENDIF}
{$IFDEF ZeOSLib}
  Self.FQuery.Connection := FInstance.GetInstance.Connection;
{$ENDIF}
end;

destructor TQuery.Destroy;
begin
  inherited;
end;

end.
