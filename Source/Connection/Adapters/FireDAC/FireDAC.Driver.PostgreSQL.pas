unit FireDAC.Driver.PostgreSQL;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TFireDAC_PostgreSQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
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
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  ISmartPointer,
  TSmartPointer;

function TFireDAC_PostgreSQLConfigurator.DriverName: TDriver;
begin
  Result := TDriver.PostgreSQL;
end;

procedure TFireDAC_PostgreSQLConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TFDConnection;
{$IFDEF MSWINDOWS}
  DriverLink: TFDPhysPgDriverLink;
{$ENDIF}
  Port: Integer;
  Schema: String;
begin
  Conn := AConn as TFDConnection;
  Port   := IfThen(AParams.Port > 0, AParams.Port, 5432);
  Schema := IfThen(AParams.Schema = '', 'public', AParams.Schema);

{$IFDEF MSWINDOWS}
  DriverLink := ISmartPointer<TFDPhysPgDriverLink>(TFDPhysPgDriverLink.Create(nil));
  DriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'libpq.dll';
{$ENDIF}

  Conn.ConnectionName := 'FD_PostgreSQL';
  Conn.DriverName     := 'PG';
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

  with Conn.Params as TFDPhysPGConnectionDefParams do
  begin
    BeginUpdate;
    Clear;
    DriverID      := 'PG';
    Server        := AParams.Host;
    Database      := AParams.Database;
    UserName      := AParams.Username;
    Password      := IfThen(AParams.Password = '', #0, AParams.Password);
    MetaDefSchema := Schema;
    { ExtraArgs }
    if Assigned(AParams.ExtraArgs) then
    begin
      if AParams.ExtraArgs.ContainsKey('CharacterSet') then
        Conn.Params.Values['CharacterSet'] := AParams.ExtraArgs['CharacterSet'];
    end;
    EndUpdate;
  end;
  Conn.Params.Values['Port'] := IntToStr(Port);

  { Definir search_path após configurar (será executado após Connect) }
  { O TFireDACConnectionStrategy chama ExecSQL pós-connect quando Schema != '' }
end;

end.
