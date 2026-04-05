unit FireDAC.Driver.Oracle;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TFireDAC_OracleConfigurator = class(TInterfacedObject, IDriverConfigurator)
  public
    function DriverName: TDriver;
    procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Math,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Comp.Client,
  FireDAC.Phys.Oracle,
  FireDAC.Phys.OracleDef,
  SmartPointer.ISmartPointer;

function TFireDAC_OracleConfigurator.DriverName: TDriver;
begin
  Result := TDriver.Oracle;
end;

procedure TFireDAC_OracleConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TFDConnection;
{$IFDEF MSWINDOWS}
  DriverLink: TFDPhysOracleDriverLink;
{$ENDIF}
  Port: Integer;
begin
  Conn := AConn as TFDConnection;
  Port := IfThen(AParams.Port > 0, AParams.Port, 1521);

{$IFDEF MSWINDOWS}
  DriverLink := ISmartPointer<TFDPhysOracleDriverLink>(TFDPhysOracleDriverLink.Create(nil));
  DriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'oci.dll';
{$ENDIF}

  Conn.ConnectionName := 'FD_Oracle';
  Conn.DriverName     := 'Ora';
  Conn.Connected      := False;

  with Conn.ResourceOptions as TFDTopResourceOptions do
  begin
    KeepConnection := True;
    Persistent     := True;
    SilentMode     := True;
    DirectExecute  := True;
  end;
  with Conn.FetchOptions as TFDFetchOptions do
    RecordCountMode := cmVisible;

  Conn.LoginPrompt := False;

  with Conn.Params as TFDPhysOracleConnectionDefParams do
  begin
    BeginUpdate;
    Clear;
    DriverID       := 'Ora';
    { Formato TNS EZConnect: host:port/service_name }
    Database       := Format('(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=%s)(PORT=%u))(CONNECT_DATA=(SERVICE_NAME=%s)))',
                             [AParams.Host, Port, AParams.Schema]);
    UserName       := AParams.Username;
    Password       := IfThen(AParams.Password = '', #0, AParams.Password);
    MetaDefSchema  := AParams.Username;
    MetaCurSchema  := AParams.Username;
    CharacterSet   := TFDOracleCharacterSet.csUTF8;
    { ExtraArgs }
    if Assigned(AParams.ExtraArgs) then
    begin
      if AParams.ExtraArgs.ContainsKey('NLS_LANGUAGE') then
        Conn.Params.Values['NLS_LANGUAGE'] := AParams.ExtraArgs['NLS_LANGUAGE'];
      if AParams.ExtraArgs.ContainsKey('NLS_TERRITORY') then
        Conn.Params.Values['NLS_TERRITORY'] := AParams.ExtraArgs['NLS_TERRITORY'];
    end;
    EndUpdate;
  end;
end;

end.
