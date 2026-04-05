unit dbExpress.Driver.MySQL;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TdbExpress_MySQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
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

function TdbExpress_MySQLConfigurator.DriverName: TDriver;
begin
  Result := TDriver.MySQL;
end;

procedure TdbExpress_MySQLConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TSQLConnection;
  Port: Integer;
begin
  Conn := AConn as TSQLConnection;
  Port := IfThen(AParams.Port > 0, AParams.Port, 3306);
  Conn.ConnectionName  := 'DBMySQL';
  Conn.DriverName      := 'MySQL';
  Conn.KeepConnection  := True;
  Conn.LoginPrompt     := False;
  Conn.GetDriverFunc   := 'getSQLDriverMYSQL';
  Conn.LibraryName     := 'dbxmys.dll';
  Conn.VendorLib       := 'LIBMYSQL.dll';
  Conn.Params.BeginUpdate;
  Conn.Params.Clear;
  Conn.Params.Values['ColumnMetadataSupported'] := 'False';
  Conn.Params.Values['LoginPrompt']             := 'False';
  Conn.Params.Values['HostName']                := AParams.Host;
  Conn.Params.Values['Port']                    := IntToStr(Port);
  Conn.Params.Values['Database']                := AParams.Database;
  Conn.Params.Values['User_Name']               := AParams.Username;
  Conn.Params.Values['Password']                := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.Params.Values['ForceCreateDatabase']     := 'False';
  Conn.Params.Values['FailIfMissing']           := 'False';
  Conn.Params.Values['MaxBlobSize']             := '-1';
  Conn.Params.Values['BlobSize']                := '-1';
  Conn.Params.Values['LocaleCode']              := '0000';
  Conn.Params.Values['Compressed']              := 'True';
  Conn.Params.Values['Encrypted']               := 'False';
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('Compressed') then
      Conn.Params.Values['Compressed'] := AParams.ExtraArgs['Compressed'];
    if AParams.ExtraArgs.ContainsKey('Encrypted') then
      Conn.Params.Values['Encrypted']  := AParams.ExtraArgs['Encrypted'];
    if AParams.ExtraArgs.ContainsKey('CharacterSet') then
      Conn.Params.Values['CharacterSet'] := AParams.ExtraArgs['CharacterSet'];
  end;
  Conn.Params.EndUpdate;
  Conn.ParamsLoaded := True;
end;

end.
