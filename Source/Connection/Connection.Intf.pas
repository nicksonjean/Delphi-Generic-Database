unit Connection.Intf;

{
  Interface IConnection — desacoplada da implementação TConnection (Connection.pas).
}

interface

uses
  Connection.Types,
  Connection.IConnectionStrategy;

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

implementation

end.
