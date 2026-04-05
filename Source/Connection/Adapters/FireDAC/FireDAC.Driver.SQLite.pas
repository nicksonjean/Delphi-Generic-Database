unit FireDAC.Driver.SQLite;

{
  FireDAC.Driver.SQLite
  ------------------------------------------------------------------------------
  IDriverConfigurator para SQLite via FireDAC.
  Configura TFDConnection com os parâmetros de conexão SQLite.
}

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TFireDAC_SQLiteConfigurator = class(TInterfacedObject, IDriverConfigurator)
  public
    function DriverName: TDriver;
    procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Comp.Client,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  SmartPointer.ISmartPointer;

function TFireDAC_SQLiteConfigurator.DriverName: TDriver;
begin
  Result := TDriver.SQLite;
end;

procedure TFireDAC_SQLiteConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TFDConnection;
{$IFDEF MSWINDOWS}
  DriverLink: TFDPhysSQLiteDriverLink;
{$ENDIF}
begin
  Conn := AConn as TFDConnection;
{$IFDEF MSWINDOWS}
  DriverLink := ISmartPointer<TFDPhysSQLiteDriverLink>(TFDPhysSQLiteDriverLink.Create(nil));
  DriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'sqlite3.dll';
{$ENDIF}
  Conn.ConnectionName := 'FD_SQLite';
  Conn.DriverName     := 'SQLite';
  Conn.Connected      := False;

  with Conn.ResourceOptions as TFDTopResourceOptions do
  begin
    KeepConnection := True;
    Persistent     := True;
    SilentMode     := True;
  end;
  with Conn.FetchOptions as TFDFetchOptions do
    RecordCountMode := cmVisible;

  Conn.LoginPrompt := False;

  with Conn.Params as TFDPhysSQLiteConnectionDefParams do
  begin
    BeginUpdate;
    Clear;
    DriverID := 'SQLite';
    Database := AParams.Database;
    { ExtraArgs }
    EndUpdate;
  end;

  { ExtraArgs genéricos via Params.Values }
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('ForceCreateDatabase') then
      Conn.Params.Values['ForceCreateDatabase'] := AParams.ExtraArgs['ForceCreateDatabase'];
    if AParams.ExtraArgs.ContainsKey('JournalMode') then
      Conn.Params.Values['JournalMode'] := AParams.ExtraArgs['JournalMode'];
  end;
end;

end.
