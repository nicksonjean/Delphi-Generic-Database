unit dbExpress.Driver.Interbase;

interface

uses
  Connection.Types,
  Connection.Strategy.Intf;

type
  TdbExpress_InterbaseConfigurator = class(TInterfacedObject, IDriverConfigurator)
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

function TdbExpress_InterbaseConfigurator.DriverName: TDriver;
begin
  Result := TDriver.Interbase;
end;

procedure TdbExpress_InterbaseConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TSQLConnection;
  Port: Integer;
begin
  Conn := AConn as TSQLConnection;
  Port := IfThen(AParams.Port > 0, AParams.Port, 3050);
  Conn.ConnectionName := 'DBInterbase';
  Conn.DriverName     := 'InterBase';
  Conn.KeepConnection := True;
  Conn.LoginPrompt    := False;
  Conn.GetDriverFunc  := 'getSQLDriverINTERBASE';
  Conn.LibraryName    := 'dbxint.dll';
  Conn.VendorLib      := 'GDS32.DLL';
  Conn.Params.BeginUpdate;
  Conn.Params.Clear;
  Conn.Params.Values['ColumnMetadataSupported'] := 'False';
  Conn.Params.Values['LoginPrompt']    := 'False';
  if AParams.Host = EmptyStr then
    Conn.Params.Values['Database'] := AParams.Database
  else
    Conn.Params.Values['Database'] := AParams.Host + ':' + AParams.Database;
  Conn.Params.Values['Port']           := IntToStr(Port);
  Conn.Params.Values['User_Name']      := AParams.Username;
  Conn.Params.Values['Password']       := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.Params.Values['Role']           := 'RoleName';
  Conn.Params.Values['LocaleCode']     := '0000';
  Conn.Params.Values['IsolationLevel'] := 'ReadCommitted';
  Conn.Params.Values['ServerCharSet']  := 'UTF8';
  Conn.Params.Values['SQLDialect']     := '3';
  Conn.Params.Values['BlobSize']       := '-1';
  Conn.Params.Values['CommitRetain']   := 'False';
  Conn.Params.Values['WaitOnLocks']    := 'True';
  Conn.Params.Values['TrimChar']       := 'False';
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('ServerCharSet') then
      Conn.Params.Values['ServerCharSet'] := AParams.ExtraArgs['ServerCharSet'];
    if AParams.ExtraArgs.ContainsKey('CharacterSet') then
      Conn.Params.Values['ServerCharSet'] := AParams.ExtraArgs['CharacterSet'];
  end;
  Conn.Params.EndUpdate;
  Conn.ParamsLoaded := True;
end;

end.
