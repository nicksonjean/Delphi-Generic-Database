unit dbExpress.Driver.MSSQL;

interface

uses
  Connection.Types,
  Connection.Strategy.Intf;

type
  TdbExpress_MSSQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
  public
    function DriverName: TDriver;
    procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  Data.SqlExpr;

function TdbExpress_MSSQLConfigurator.DriverName: TDriver;
begin
  Result := TDriver.MSSQL;
end;

procedure TdbExpress_MSSQLConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TSQLConnection;
  Port: Integer;
begin
  Conn := AConn as TSQLConnection;
  Port := IfThen(AParams.Port > 0, AParams.Port, 1433);
  Conn.ConnectionName := 'DBMSSQL';
  Conn.DriverName     := 'MSSQL';
  Conn.KeepConnection := False;
  Conn.LoginPrompt    := False;
  Conn.GetDriverFunc  := 'getSQLDriverMSSQL';
  Conn.VendorLib      := 'sqlncli11.dll';
  Conn.LibraryName    := 'dbxmss.dll';
  Conn.Params.BeginUpdate;
  Conn.Params.Clear;
  Conn.Params.Values['ColumnMetadataSupported'] := 'False';
  Conn.Params.Values['LoginPrompt']     := 'False';
  Conn.Params.Values['HostName']        := AParams.Host;
  Conn.Params.Values['Port']            := IntToStr(Port);
  Conn.Params.Values['Database']        := AParams.Database;
  Conn.Params.Values['User_Name']       := AParams.Username;
  Conn.Params.Values['Password']        := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.Params.Values['MaxBlobSize']     := '-1';
  Conn.Params.Values['BlobSize']        := '-1';
  Conn.Params.Values['LocaleCode']      := '0000';
  Conn.Params.Values['SchemaOverride']  := '%.dbo';
  Conn.Params.Values['Max_DBProcesses'] := '50';
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('SchemaOverride') then
      Conn.Params.Values['SchemaOverride'] := AParams.ExtraArgs['SchemaOverride'];
  end;
  Conn.Params.EndUpdate;
  Conn.ParamsLoaded := True;
end;

end.
