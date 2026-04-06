unit dbExpress.Driver.Oracle;

{
  dbExpress.Driver.Oracle
  ------------------------------------------------------------------------------
  Driver Oracle nativo Embarcadero via dbxora.dll + oci.dll.
  O driver Devart (dbexpoda41.dll) foi descontinuado.
  Requer: Oracle Client instalado; EZConnect ou tnsnames.ora configurado.
  FSchema = Service Name / TNS alias (ex: 'orcl', 'freepdb1').
}

interface

uses
  Connection.Types,
  Connection.Strategy.Intf;

type
  TdbExpress_OracleConfigurator = class(TInterfacedObject, IDriverConfigurator)
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

function TdbExpress_OracleConfigurator.DriverName: TDriver;
begin
  Result := TDriver.Oracle;
end;

procedure TdbExpress_OracleConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TSQLConnection;
  Port: Integer;
begin
  Conn := AConn as TSQLConnection;
  Port := IfThen(AParams.Port > 0, AParams.Port, 1521);
  Conn.ConnectionName := 'DBOracle';
  Conn.DriverName     := 'Oracle';
  Conn.KeepConnection := False;
  Conn.LoginPrompt    := False;
  Conn.GetDriverFunc  := 'getSQLDriverORACLE';
  Conn.LibraryName    := 'dbxora.dll';
  Conn.VendorLib      := 'oci.dll';
  Conn.Params.BeginUpdate;
  Conn.Params.Clear;
  Conn.Params.Values['DriverName']    := 'Oracle';
  Conn.Params.Values['LoginPrompt']   := 'False';
  { Formato EZConnect: host:port/service_name — requer Oracle Client 10g+ }
  Conn.Params.Values['DataBase']      := Format('%s:%u/%s', [AParams.Host, Port, AParams.Schema]);
  Conn.Params.Values['User_Name']     := AParams.Username;
  Conn.Params.Values['Password']      := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.Params.Values['ServerCharSet'] := 'UTF8';
  Conn.Params.Values['BlobSize']      := '-1';
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('ServerCharSet') then
      Conn.Params.Values['ServerCharSet'] := AParams.ExtraArgs['ServerCharSet'];
    if AParams.ExtraArgs.ContainsKey('CharacterSet') then
      Conn.Params.Values['ServerCharSet'] := AParams.ExtraArgs['CharacterSet'];
    if AParams.ExtraArgs.ContainsKey('NLS_LANGUAGE') then
      Conn.Params.Values['NLS_LANGUAGE'] := AParams.ExtraArgs['NLS_LANGUAGE'];
  end;
  Conn.Params.EndUpdate;
  Conn.ParamsLoaded := True;
end;

end.
