unit ZeOS.Driver.Oracle;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TZeOS_OracleConfigurator = class(TInterfacedObject, IDriverConfigurator)
  public
    function DriverName: TDriver;
    procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  ZConnection;

function TZeOS_OracleConfigurator.DriverName: TDriver;
begin
  Result := TDriver.Oracle;
end;

procedure TZeOS_OracleConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TZConnection;
begin
  Conn := AConn as TZConnection;
{$IFDEF MSWINDOWS}
  Conn.LibraryLocation := ExtractFilePath(ParamStr(0)) + 'oci.dll';
{$ENDIF}
  { ZeOS Oracle: Database = "host/schema", HostName = schema alias }
  Conn.Database  := Format('%s/%s', [AParams.Host, AParams.Schema]);
  Conn.HostName  := AParams.Schema;
  Conn.Catalog   := '';
  Conn.Port      := IfThen(AParams.Port > 0, AParams.Port, 1521);
  Conn.User      := AParams.Username;
  Conn.Password  := IfThen(AParams.Password = '', #0, AParams.Password);
  Conn.Protocol  := 'oracle';
  Conn.AutoCommit := False;
  Conn.Properties.Clear;
  Conn.Properties.Add('codepage=utf8');
  Conn.Properties.Add('charset=utf8');
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('CharacterSet') then
    begin
      Conn.Properties.Values['codepage'] := LowerCase(AParams.ExtraArgs['CharacterSet']);
      Conn.Properties.Values['charset']  := LowerCase(AParams.ExtraArgs['CharacterSet']);
    end;
  end;
end;

end.
