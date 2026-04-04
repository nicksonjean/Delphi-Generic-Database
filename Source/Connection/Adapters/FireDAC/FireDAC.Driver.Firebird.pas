unit FireDAC.Driver.Firebird;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TFireDAC_FirebirdConfigurator = class(TInterfacedObject, IDriverConfigurator)
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
  FireDAC.Phys.FB,
  FireDAC.Phys.IBWrapper,
  FireDAC.Phys.FBDef,
  ISmartPointer,
  TSmartPointer;

function TFireDAC_FirebirdConfigurator.DriverName: TDriver;
begin
  Result := TDriver.Firebird;
end;

procedure TFireDAC_FirebirdConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TFDConnection;
{$IFDEF MSWINDOWS}
  DriverLink: TFDPhysFBDriverLink;
{$ENDIF}
  Port: Integer;
begin
  Conn := AConn as TFDConnection;
  Port := IfThen(AParams.Port > 0, AParams.Port, 3050);

{$IFDEF MSWINDOWS}
  DriverLink := ISmartPointer<TFDPhysFBDriverLink>(TFDPhysFBDriverLink.Create(nil));
  DriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'fbclient.dll';
{$ENDIF}

  Conn.ConnectionName := 'FD_Firebird';
  Conn.DriverName     := 'FB';
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

  with Conn.Params as TFDPhysFBConnectionDefParams do
  begin
    BeginUpdate;
    Clear;
    DriverID     := 'FB';
    Server       := AParams.Host;
    Database     := AParams.Database;
    UserName     := AParams.Username;
    Password     := IfThen(AParams.Password = '', #0, AParams.Password);
    Protocol     := ipTCPIP;
    SQLDialect   := 3;
    CharacterSet := TIBCharacterSet.csUTF8;
    { ExtraArgs }
    if Assigned(AParams.ExtraArgs) then
    begin
      if AParams.ExtraArgs.ContainsKey('SQLDialect') then
        SQLDialect := StrToIntDef(AParams.ExtraArgs['SQLDialect'], 3);
      if AParams.ExtraArgs.ContainsKey('Role') then
        RoleName := AParams.ExtraArgs['Role'];
    end;
    EndUpdate;
  end;
  Conn.Params.Values['Port'] := IntToStr(Port);
end;

end.
