unit Connection.Strategy.Intf;

{
  Contratos de Strategy para conexão, query, factory e configuração de driver.
  Agrupa as interfaces anteriormente em Connection.IConnectionStrategy,
  Connection.IDriverConfigurator, Connection.IQueryStrategy e Connection.IEngineFactory.
}

interface

uses
  System.Classes,
  Data.DB,
  Connection.Types;

type
  IConnectionStrategy = interface
    ['{A1B2C3D4-0001-0000-0000-000000000001}']
    procedure Configure(const AParams: TConnectionParams);
    procedure Connect;
    procedure Disconnect;
    function IsConnected: Boolean;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    function InTransaction: Boolean;
    function NativeConnection: TObject;
    function Engine: TEngine;
  end;

  IDriverConfigurator = interface
    ['{A1B2C3D4-0001-0000-0000-000000000004}']
    function DriverName: TDriver;
    procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  end;

  IQueryStrategy = interface
    ['{A1B2C3D4-0001-0000-0000-000000000002}']
    procedure SetConnection(const AStrategy: IConnectionStrategy);
    procedure Open(const ASQL: String);
    procedure ExecSQL(const ASQL: String);
    procedure Close;
    function IsEmpty: Boolean;
    function EOF: Boolean;
    procedure First;
    procedure Next;
    function FieldCount: Integer;
    function Fields: TFields;
    function FieldDefs: TFieldDefs;
    function AsDataSet: TDataSet;
    function AsInMemoryDataSet: TDataSet;
    function RecordCount: Integer;
  end;

  IEngineFactory = interface
    ['{A1B2C3D4-0001-0000-0000-000000000003}']
    function Engine: TEngine;
    function CreateConnectionStrategy: IConnectionStrategy;
    function CreateQueryStrategy: IQueryStrategy;
  end;

implementation

end.
