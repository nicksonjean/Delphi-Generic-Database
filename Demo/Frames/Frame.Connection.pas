unit Frame.Connection;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.IOUtils,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.Layouts,
  FMX.ScrollBox,
  FMX.ListBox,
  FMX.Edit,
  FMX.Memo,
  FMX.Memo.Types;

type
  TFrameConnection = class(TFrame)
    RectConnectionBg: TRectangle;
    GridPanelMain: TGridPanelLayout;
    RectConnectionParams: TRectangle;
    RectParamsHeader: TRectangle;
    RectParamsHeaderFill: TRectangle;
    LblParamsTitle: TLabel;
    ScrollParams: TVertScrollBox;
    LblEngine: TLabel;
    ComboEngine: TComboBox;
    LblDriver: TLabel;
    ComboDriver: TComboBox;
    LblHost: TLabel;
    EditHost: TEdit;
    LblPort: TLabel;
    EditPort: TEdit;
    LblDatabase: TLabel;
    EditDatabase: TEdit;
    LblUsername: TLabel;
    EditUsername: TEdit;
    LblPassword: TLabel;
    EditPassword: TEdit;
    LblSchema: TLabel;
    EditSchema: TEdit;
    LayButtons: TLayout;
    BtnTestConnection: TButton;
    BtnBrowseFile: TButton;
    LayConfigActions: TLayout;
    BtnLoadConfig: TButton;
    BtnSaveConfig: TButton;
    RectConfigRight: TRectangle;
    RectRightHeader: TRectangle;
    RectRightHeaderFill: TRectangle;
    LblRightTitle: TLabel;
    ComboConfigFormat: TComboBox;
    GridPanelRight: TGridPanelLayout;
    RectConfigPreview: TRectangle;
    MemoConfigPreview: TMemo;
    RectStatusAndLog: TRectangle;
    RectLogHeader: TRectangle;
    LblLogTitle: TLabel;
    RectStatusIndicator: TRectangle;
    LblConnectionStatus: TLabel;
    BtnClearLog: TButton;
    MemoConnectionLog: TMemo;
    procedure ComboEngineChange(Sender: TObject);
    procedure ComboDriverChange(Sender: TObject);
    procedure ComboConfigFormatChange(Sender: TObject);
    procedure BtnTestConnectionClick(Sender: TObject);
    procedure BtnBrowseFileClick(Sender: TObject);
    procedure BtnLoadConfigClick(Sender: TObject);
    procedure BtnSaveConfigClick(Sender: TObject);
    procedure BtnClearLogClick(Sender: TObject);
  private
    procedure UpdateDefaultPort;
    procedure UpdateDatabaseLabel;
    procedure UpdateConfigPreview;
    procedure SetConnectionStatus(AConnected: Boolean; const AMsg: String);
    procedure AddLog(const AMsg: String);
    function GetConfigAsJSON: String;
    function GetConfigAsYAML: String;
    function GetConfigAsXML: String;
    function GetConfigAsINI: String;
    function GetConfigAsTOML: String;
    function GetDriverName: String;
    function GetEngineName: String;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  Connection,
  Connection.Types,
  SmartPointer.Intf,
  SmartPointer;

{$R *.fmx}

const
  COLOR_CONNECTED    = $FF4CAF50;
  COLOR_DISCONNECTED = $FF9E9E9E;
  COLOR_ERROR        = $FFF44336;

{ TFrameConnection }

constructor TFrameConnection.Create(AOwner: TComponent);
begin
  inherited;
  ComboEngine.ItemIndex := 0;
  ComboDriver.ItemIndex := 0;
  UpdateDefaultPort;
  UpdateDatabaseLabel;
  UpdateConfigPreview;
  AddLog('Ready. Configure connection parameters and click Test Connection.');
end;

function TFrameConnection.GetEngineName: String;
begin
  case ComboEngine.ItemIndex of
    0: Result := 'FireDAC';
    1: Result := 'dbExpress';
    2: Result := 'ZeOS';
    3: Result := 'UniDAC';
  else
    Result := 'FireDAC';
  end;
end;

function TFrameConnection.GetDriverName: String;
begin
  case ComboDriver.ItemIndex of
    0: Result := 'SQLite';
    1: Result := 'MySQL';
    2: Result := 'MariaDB';
    3: Result := 'Firebird';
    4: Result := 'Interbase';
    5: Result := 'PostgreSQL';
    6: Result := 'SQLServer';
    7: Result := 'Oracle';
  else
    Result := 'SQLite';
  end;
end;

procedure TFrameConnection.UpdateDefaultPort;
begin
  case ComboDriver.ItemIndex of
    0: // SQLite
    begin
      EditPort.Text := '';
      EditHost.Text := 'localhost';
      EditHost.Enabled := False;
      EditPort.Enabled := False;
    end;
    1, 2: // MySQL / MariaDB
    begin
      EditPort.Text := '3306';
      EditHost.Enabled := True;
      EditPort.Enabled := True;
    end;
    3: // Firebird
    begin
      EditPort.Text := '3050';
      EditHost.Enabled := True;
      EditPort.Enabled := True;
    end;
    4: // Interbase
    begin
      EditPort.Text := '3050';
      EditHost.Enabled := True;
      EditPort.Enabled := True;
    end;
    5: // PostgreSQL
    begin
      EditPort.Text := '5432';
      EditHost.Enabled := True;
      EditPort.Enabled := True;
    end;
    6: // SQL Server
    begin
      EditPort.Text := '1433';
      EditHost.Enabled := True;
      EditPort.Enabled := True;
    end;
    7: // Oracle
    begin
      EditPort.Text := '1521';
      EditHost.Enabled := True;
      EditPort.Enabled := True;
    end;
  end;
end;

procedure TFrameConnection.UpdateDatabaseLabel;
begin
  if ComboDriver.ItemIndex = 0 then // SQLite
    LblDatabase.Text := 'Database File (.sqlite, .db)'
  else
    LblDatabase.Text := 'Database / Schema Name';
end;

procedure TFrameConnection.ComboEngineChange(Sender: TObject);
begin
  UpdateConfigPreview;
end;

procedure TFrameConnection.ComboDriverChange(Sender: TObject);
begin
  UpdateDefaultPort;
  UpdateDatabaseLabel;
  UpdateConfigPreview;
end;

procedure TFrameConnection.ComboConfigFormatChange(Sender: TObject);
begin
  UpdateConfigPreview;
end;

procedure TFrameConnection.UpdateConfigPreview;
var
  LContent: String;
begin
  case ComboConfigFormat.ItemIndex of
    0: LContent := GetConfigAsJSON;
    1: LContent := GetConfigAsYAML;
    2: LContent := GetConfigAsXML;
    3: LContent := GetConfigAsINI;
    4: LContent := GetConfigAsTOML;
  else
    LContent := GetConfigAsJSON;
  end;
  MemoConfigPreview.Text := LContent;
end;

function TFrameConnection.GetConfigAsJSON: String;
begin
  Result :=
    '{' + sLineBreak +
    '  "engine":   "' + GetEngineName + '",' + sLineBreak +
    '  "driver":   "' + GetDriverName + '",' + sLineBreak +
    '  "host":     "' + EditHost.Text + '",' + sLineBreak +
    '  "port":     ' + EditPort.Text + ',' + sLineBreak +
    '  "database": "' + EditDatabase.Text + '",' + sLineBreak +
    '  "username": "' + EditUsername.Text + '",' + sLineBreak +
    '  "password": "' + EditPassword.Text + '",' + sLineBreak +
    '  "schema":   "' + EditSchema.Text + '"' + sLineBreak +
    '}';
end;

function TFrameConnection.GetConfigAsYAML: String;
begin
  Result :=
    'connection:' + sLineBreak +
    '  engine:   ' + GetEngineName + sLineBreak +
    '  driver:   ' + GetDriverName + sLineBreak +
    '  host:     ' + EditHost.Text + sLineBreak +
    '  port:     ' + EditPort.Text + sLineBreak +
    '  database: ' + EditDatabase.Text + sLineBreak +
    '  username: ' + EditUsername.Text + sLineBreak +
    '  password: ' + EditPassword.Text + sLineBreak +
    '  schema:   ' + EditSchema.Text;
end;

function TFrameConnection.GetConfigAsXML: String;
begin
  Result :=
    '<?xml version="1.0" encoding="UTF-8"?>' + sLineBreak +
    '<connection>' + sLineBreak +
    '  <engine>'   + GetEngineName + '</engine>' + sLineBreak +
    '  <driver>'   + GetDriverName + '</driver>' + sLineBreak +
    '  <host>'     + EditHost.Text + '</host>' + sLineBreak +
    '  <port>'     + EditPort.Text + '</port>' + sLineBreak +
    '  <database>' + EditDatabase.Text + '</database>' + sLineBreak +
    '  <username>' + EditUsername.Text + '</username>' + sLineBreak +
    '  <password>' + EditPassword.Text + '</password>' + sLineBreak +
    '  <schema>'   + EditSchema.Text + '</schema>' + sLineBreak +
    '</connection>';
end;

function TFrameConnection.GetConfigAsINI: String;
begin
  Result :=
    '[connection]' + sLineBreak +
    'engine='   + GetEngineName + sLineBreak +
    'driver='   + GetDriverName + sLineBreak +
    'host='     + EditHost.Text + sLineBreak +
    'port='     + EditPort.Text + sLineBreak +
    'database=' + EditDatabase.Text + sLineBreak +
    'username=' + EditUsername.Text + sLineBreak +
    'password=' + EditPassword.Text + sLineBreak +
    'schema='   + EditSchema.Text;
end;

function TFrameConnection.GetConfigAsTOML: String;
begin
  Result :=
    '[connection]' + sLineBreak +
    'engine   = "' + GetEngineName + '"' + sLineBreak +
    'driver   = "' + GetDriverName + '"' + sLineBreak +
    'host     = "' + EditHost.Text + '"' + sLineBreak +
    'port     = ' + EditPort.Text + sLineBreak +
    'database = "' + EditDatabase.Text + '"' + sLineBreak +
    'username = "' + EditUsername.Text + '"' + sLineBreak +
    'password = "' + EditPassword.Text + '"' + sLineBreak +
    'schema   = "' + EditSchema.Text + '"';
end;

procedure TFrameConnection.SetConnectionStatus(AConnected: Boolean; const AMsg: String);
begin
  if AConnected then
  begin
    RectStatusIndicator.Fill.Color := COLOR_CONNECTED;
    LblConnectionStatus.Text := 'Connected';
    LblConnectionStatus.TextSettings.FontColor := COLOR_CONNECTED;
  end
  else
  begin
    RectStatusIndicator.Fill.Color := COLOR_ERROR;
    LblConnectionStatus.Text := 'Failed';
    LblConnectionStatus.TextSettings.FontColor := COLOR_ERROR;
  end;
  AddLog(AMsg);
end;

procedure TFrameConnection.AddLog(const AMsg: String);
var
  LTimestamp: String;
begin
  LTimestamp := FormatDateTime('[hh:nn:ss] ', Now);
  MemoConnectionLog.Lines.Add(LTimestamp + AMsg);
  // Scroll to bottom
  MemoConnectionLog.GoToTextEnd;
end;

procedure TFrameConnection.BtnTestConnectionClick(Sender: TObject);
var
  DB: TSmartPointer<TConnection>;
  LEngine: TEngine;
  LDriver: TDriver;
begin
  UpdateConfigPreview;
  AddLog('Testing connection...');
  AddLog(Format('Engine: %s | Driver: %s', [GetEngineName, GetDriverName]));

  // Map engine
  case ComboEngine.ItemIndex of
    0: LEngine := TEngine.FireDAC;
    1: LEngine := TEngine.dbExpress;
    2: LEngine := TEngine.ZeOS;
    3: LEngine := TEngine.UniDAC;
  else
    LEngine := TEngine.FireDAC;
  end;

  // Map driver
  case ComboDriver.ItemIndex of
    0: LDriver := TDriver.SQLite;
    1: LDriver := TDriver.MySQL;
    2: LDriver := TDriver.MySQL;      // MariaDB usa o mesmo driver MySQL
    3: LDriver := TDriver.Firebird;
    4: LDriver := TDriver.Interbase;
    5: LDriver := TDriver.PostgreSQL;
    6: LDriver := TDriver.MSSQL;
    7: LDriver := TDriver.Oracle;
  else
    LDriver := TDriver.SQLite;
  end;

  try
    DB := TSmartPointer<TConnection>.Create(TConnection.Create(LEngine));
    DB.Ref.Driver    := LDriver;
    DB.Ref.Host      := EditHost.Text;
    DB.Ref.Port      := StrToIntDef(EditPort.Text, 0);
    DB.Ref.Database  := EditDatabase.Text;
    DB.Ref.Username  := EditUsername.Text;
    DB.Ref.Password  := EditPassword.Text;
    DB.Ref.Schema    := EditSchema.Text;
    DB.Ref.Connected := True;

    if DB.Ref.Connected then
      SetConnectionStatus(True, Format('Connection successful! Engine: %s, Driver: %s', [GetEngineName, GetDriverName]))
    else
      SetConnectionStatus(False, 'Connection failed: could not establish connection.');
  except
    on E: Exception do
      SetConnectionStatus(False, 'Error: ' + E.Message);
  end;
end;

procedure TFrameConnection.BtnBrowseFileClick(Sender: TObject);
var
  LOpenDlg: TOpenDialog;
begin
  LOpenDlg := TOpenDialog.Create(Self);
  try
    LOpenDlg.Filter := 'SQLite Files (*.sqlite;*.db)|*.sqlite;*.db|Firebird Files (*.fdb;*.gdb)|*.fdb;*.gdb|All Files (*.*)|*.*';
    LOpenDlg.Title := 'Select Database File';
    if LOpenDlg.Execute then
    begin
      EditDatabase.Text := LOpenDlg.FileName;
      UpdateConfigPreview;
      AddLog('File selected: ' + LOpenDlg.FileName);
    end;
  finally
    LOpenDlg.Free;
  end;
end;

procedure TFrameConnection.BtnLoadConfigClick(Sender: TObject);
var
  LOpenDlg: TOpenDialog;
begin
  LOpenDlg := TOpenDialog.Create(Self);
  try
    LOpenDlg.Filter := 'Config Files (*.json;*.yaml;*.yml;*.xml;*.ini;*.toml)|*.json;*.yaml;*.yml;*.xml;*.ini;*.toml|All Files (*.*)|*.*';
    LOpenDlg.Title := 'Load Connection Configuration';
    if LOpenDlg.Execute then
    begin
      AddLog('Loading config from: ' + LOpenDlg.FileName);
      // TODO: Use Connection.Config.Factory to load and populate fields
      // var Config := TConnectionConfigFactory.Load(LOpenDlg.FileName);
      // EditHost.Text     := Config.Host;
      // EditPort.Text     := IntToStr(Config.Port);
      // EditDatabase.Text := Config.Database;
      // ...
      AddLog('Config loaded. (Use Connection.Config.Factory for full implementation)');
      UpdateConfigPreview;
    end;
  finally
    LOpenDlg.Free;
  end;
end;

procedure TFrameConnection.BtnSaveConfigClick(Sender: TObject);
var
  LSaveDlg: TSaveDialog;
  LContent: String;
begin
  LSaveDlg := TSaveDialog.Create(Self);
  try
    case ComboConfigFormat.ItemIndex of
      0: LSaveDlg.Filter := 'JSON Files (*.json)|*.json';
      1: LSaveDlg.Filter := 'YAML Files (*.yaml)|*.yaml';
      2: LSaveDlg.Filter := 'XML Files (*.xml)|*.xml';
      3: LSaveDlg.Filter := 'INI Files (*.ini)|*.ini';
      4: LSaveDlg.Filter := 'TOML Files (*.toml)|*.toml';
    end;
    LSaveDlg.Title := 'Save Connection Configuration';
    LSaveDlg.FileName := 'connection';
    if LSaveDlg.Execute then
    begin
      UpdateConfigPreview;
      LContent := MemoConfigPreview.Text;
      TFile.WriteAllText(LSaveDlg.FileName, LContent, TEncoding.UTF8);
      AddLog('Config saved to: ' + LSaveDlg.FileName);
    end;
  finally
    LSaveDlg.Free;
  end;
end;

procedure TFrameConnection.BtnClearLogClick(Sender: TObject);
begin
  MemoConnectionLog.Lines.Clear;
  RectStatusIndicator.Fill.Color := COLOR_DISCONNECTED;
  LblConnectionStatus.Text := 'Disconnected';
  LblConnectionStatus.TextSettings.FontColor := COLOR_DISCONNECTED;
end;

end.
