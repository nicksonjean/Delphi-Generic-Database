unit dbExpress.Driver.PostgreSQL;

{
  dbExpress.Driver.PostgreSQL
  ------------------------------------------------------------------------------
  Driver PostgreSQL via Devart dbexppgsql40.dll.
  O driver ODBC foi descontinuado — Devart é a única opção viável para
  dbExpress + PostgreSQL com suporte completo a metadados e tipos.
  Requer: DBXDevartPostgreSQL unit + dbexppgsql40.dll no diretório do executável.
}

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TdbExpress_PostgreSQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
  public
    function DriverName: TDriver;
    procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  Data.SqlExpr,
  DBXDevartPostgreSQL; { Devart driver — requer licença e dll }

function TdbExpress_PostgreSQLConfigurator.DriverName: TDriver;
begin
  Result := TDriver.PostgreSQL;
end;

procedure TdbExpress_PostgreSQLConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TSQLConnection;
  Port: Integer;
begin
  Conn := AConn as TSQLConnection;
  Port := IfThen(AParams.Port > 0, AParams.Port, 5432);
  Conn.ConnectionName := 'DBDevartPostgreSQL';
  Conn.DriverName     := 'DevartPostgreSQL';
  Conn.KeepConnection := False;
  Conn.LoginPrompt    := False;
  Conn.GetDriverFunc  := 'getSQLDriverPostgreSQL';
  Conn.LibraryName    := 'dbexppgsql40.dll';
  Conn.VendorLib      := 'dbexppgsql40.dll';
  Conn.Params.BeginUpdate;
  Conn.Params.Clear;
  Conn.Params.Values['LoginPrompt'] := 'False';
  Conn.Params.Values['HostName']    := AParams.Host;
  Conn.Params.Values['Port']        := IntToStr(Port);
  Conn.Params.Values['Database']    := AParams.Database;
  Conn.Params.Values['SchemaName']  := IfThen(AParams.Schema = '', 'public', AParams.Schema);
  Conn.Params.Values['User_Name']   := AParams.Username;
  Conn.Params.Values['Password']    := IfThen(AParams.Password = '', #0, AParams.Password);
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('CharacterSet') then
      Conn.Params.Values['CharacterSet'] := AParams.ExtraArgs['CharacterSet'];
    if AParams.ExtraArgs.ContainsKey('lc_ctype') then
      Conn.Params.Values['lc_ctype'] := AParams.ExtraArgs['lc_ctype'];
    if AParams.ExtraArgs.ContainsKey('search_path') then
      Conn.Params.Values['search_path'] := AParams.ExtraArgs['search_path'];
  end;
  Conn.Params.EndUpdate;
  Conn.ParamsLoaded := True;
end;

end.
