unit FireDAC.Driver.MSSQL;

interface

uses
  Connection.Types,
  Connection.IDriverConfigurator;

type
  TFireDAC_MSSQLConfigurator = class(TInterfacedObject, IDriverConfigurator)
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
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef,
  SmartPointer.ISmartPointer;

function TFireDAC_MSSQLConfigurator.DriverName: TDriver;
begin
  Result := TDriver.MSSQL;
end;

procedure TFireDAC_MSSQLConfigurator.Configure(const AConn: TObject; const AParams: TConnectionParams);
var
  Conn: TFDConnection;
{$IFDEF MSWINDOWS}
  DriverLink: TFDPhysMSSQLDriverLink;
{$ENDIF}
  Port: Integer;
begin
  Conn := AConn as TFDConnection;
  Port := IfThen(AParams.Port > 0, AParams.Port, 1433);

{$IFDEF MSWINDOWS}
  DriverLink := ISmartPointer<TFDPhysMSSQLDriverLink>(TFDPhysMSSQLDriverLink.Create(nil));
  DriverLink.VendorLib := ExtractFilePath(ParamStr(0)) + 'sqlncli11.dll';
{$ENDIF}

  Conn.ConnectionName := 'FD_MSSQL';
  Conn.DriverName     := 'MSSQL';
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

  with Conn.Params as TFDPhysMSSQLConnectionDefParams do
  begin
    BeginUpdate;
    Clear;
    DriverID := 'MSSQL';
    Server   := AParams.Host;
    Database := AParams.Database;
    UserName := AParams.Username;
    Password := IfThen(AParams.Password = '', #0, AParams.Password);
    if Assigned(AParams.ExtraArgs) then
    begin
      if AParams.ExtraArgs.ContainsKey('Windows Auth') or
         AParams.ExtraArgs.ContainsKey('WindowsAuth') then
        Conn.Params.Values['OSAuthent'] := 'Yes';
    end;
    EndUpdate;
  end;
  Conn.Params.Values['Port'] := IntToStr(Port);
end;

end.
