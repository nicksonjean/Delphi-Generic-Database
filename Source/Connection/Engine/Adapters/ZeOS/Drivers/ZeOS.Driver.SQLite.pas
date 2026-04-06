unit ZeOS.Driver.SQLite;

interface

uses
  Connection.Types,
  Connection.Strategy.Intf;

type
  TZeOS_SQLiteConfigurator = class(TInterfacedObject, IDriverConfigurator)
  public
    function DriverName: TDriver;
    procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  end;

implementation

uses
  System.SysUtils,
  ZConnection;

function TZeOS_SQLiteConfigurator.DriverName: TDriver;
begin
  Result := TDriver.SQLite;
end;

procedure TZeOS_SQLiteConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TZConnection;
begin
  Conn := AConn as TZConnection;
{$IFDEF MSWINDOWS}
  Conn.LibraryLocation := ExtractFilePath(ParamStr(0)) + 'sqlite3.dll';
{$ENDIF}
  Conn.Protocol := 'sqlite';
  Conn.Database := AParams.Database;
  Conn.AutoCommit := False;
end;

end.
