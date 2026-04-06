unit dbExpress.Driver.SQLite;

interface

uses
  Connection.Types,
  Connection.Strategy.Intf;

type
  TdbExpress_SQLiteConfigurator = class(TInterfacedObject, IDriverConfigurator)
  public
    function DriverName: TDriver;
    procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  end;

implementation

uses
  System.SysUtils,
  Data.DbxSqlite,
  Data.SqlExpr;

function TdbExpress_SQLiteConfigurator.DriverName: TDriver;
begin
  Result := TDriver.SQLite;
end;

procedure TdbExpress_SQLiteConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TSQLConnection;
begin
  Conn := AConn as TSQLConnection;
  Conn.ConnectionName := 'DBSQLite';
  Conn.DriverName     := 'SQLite';
  Conn.GetDriverFunc  := 'getSQLDriverSQLITE';
  Conn.LibraryName    := 'dbxsqlite.dll';
  Conn.VendorLib      := 'sqlite3.dll';
  Conn.KeepConnection := True;
  Conn.LoginPrompt    := False;
  Conn.Params.BeginUpdate;
  Conn.Params.Clear;
  Conn.Params.Values['ColumnMetadataSupported'] := 'False';
  Conn.Params.Values['LoginPrompt']             := 'False';
  Conn.Params.Values['ForceCreateDatabase']     := 'False';
  Conn.Params.Values['FailIfMissing']           := 'False';
  Conn.Params.Values['Database']                := AParams.Database;
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('ForceCreateDatabase') then
      Conn.Params.Values['ForceCreateDatabase'] := AParams.ExtraArgs['ForceCreateDatabase'];
  end;
  Conn.Params.EndUpdate;
  Conn.ParamsLoaded := True;
end;

end.
