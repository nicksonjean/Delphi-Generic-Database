unit FireDAC.Driver.MySQL;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TFireDAC_MySQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
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
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  SmartPointer.ISmartPointer;

function TFireDAC_MySQLConfigurator.DriverName: TDriver;
begin
  Result := TDriver.MySQL;
end;

procedure TFireDAC_MySQLConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TFDConnection;
{$IFDEF MSWINDOWS}
  DriverLink: TFDPhysMySQLDriverLink;
{$ENDIF}
  Port: Integer;
begin
  Conn := AConn as TFDConnection;
  Port := IfThen(AParams.Port > 0, AParams.Port, 3306);

{$IFDEF MSWINDOWS}
  DriverLink := ISmartPointer<TFDPhysMySQLDriverLink>(TFDPhysMySQLDriverLink.Create(nil));
  DriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'libmysql.dll';
{$ENDIF}

  Conn.ConnectionName := 'FD_MySQL';
  Conn.DriverName     := 'MySQL';
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

  with Conn.Params as TFDPhysMySQLConnectionDefParams do
  begin
    BeginUpdate;
    Clear;
    DriverID := 'MySQL';
    Server   := AParams.Host;
    Database := AParams.Database;
    UserName := AParams.Username;
    Password := IfThen(AParams.Password = '', #0, AParams.Password);
    Compress := True;
    { ExtraArgs }
    if Assigned(AParams.ExtraArgs) then
    begin
      if AParams.ExtraArgs.ContainsKey('Compress') then
        Compress := UpperCase(AParams.ExtraArgs['Compress']) = 'TRUE';
      if AParams.ExtraArgs.ContainsKey('Encrypted') then
        Conn.Params.Values['Encrypted'] := AParams.ExtraArgs['Encrypted'];
      if AParams.ExtraArgs.ContainsKey('CharacterSet') then
        Conn.Params.Values['CharacterSet'] := AParams.ExtraArgs['CharacterSet'];
    end;
    EndUpdate;
  end;
  Conn.Params.Values['Port'] := IntToStr(Port);

  { ExtraArgs genéricos adicionais }
  if Assigned(AParams.ExtraArgs) then
  begin
    if AParams.ExtraArgs.ContainsKey('Pooled') then
      Conn.Params.Values['Pooled'] := AParams.ExtraArgs['Pooled'];
    if AParams.ExtraArgs.ContainsKey('Pool_MaxItems') then
      Conn.Params.Values['Pool_MaxItems'] := AParams.ExtraArgs['Pool_MaxItems'];
  end;
end;

end.
