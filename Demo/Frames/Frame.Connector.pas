unit Frame.Connector;

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
  FMX.ListView,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.Edit,
  FMX.ComboEdit,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.SearchBox,
  System.Rtti,
  FMX.Grid.Style,
  FMX.Grid,
  Connection.Types;

type
  TFrameConnector = class(TFrame)
    RectConnectorBg: TRectangle;
    GridPanelConnector: TGridPanelLayout;
    RectConnectorConfig: TRectangle;
    RectConnConfigHeader: TRectangle;
    LblConnConfigTitle: TLabel;
    ScrollConnConfig: TVertScrollBox;
    LblConnEngine: TLabel;
    ComboConnEngine: TComboBox;
    LblConnDriver: TLabel;
    ComboConnDriver: TComboBox;
    LblConnDatabase: TLabel;
    EditConnDatabase: TEdit;
    LblConnSQL: TLabel;
    MemoConnSQL: TMemo;
    LblConnIndexField: TLabel;
    EditConnIndexField: TEdit;
    LblConnValueField: TLabel;
    EditConnValueField: TEdit;
    LblConnFilter: TLabel;
    EditConnFilter: TEdit;
    LblConnOptions: TLabel;
    ComboConnOptions: TComboBox;
    BtnRunConnector: TButton;
    RectConnectorResults: TRectangle;
    RectResultsHeader: TRectangle;
    LblResultsTitle: TLabel;
    GridPanelResults: TGridPanelLayout;
    GroupBoxCombo: TGroupBox;
    ComboConnResult: TComboBox;
    RectEditComboContainer: TRectangle;
    GridPanelEditCombo: TGridPanelLayout;
    GroupBoxEdit: TGroupBox;
    EditConnResult: TEdit;
    GroupBoxComboEdit: TGroupBox;
    ComboEditConnResult: TComboEdit;
    GroupBoxListBox: TGroupBox;
    SearchBoxListBox: TSearchBox;
    ListBoxConnResult: TListBox;
    GroupBoxListView: TGroupBox;
    ListViewConnResult: TListView;
    GroupBoxStringGrid: TGroupBox;
    StringGridConnResult: TStringGrid;
    GroupBoxGrid: TGroupBox;
    GridConnResult: TGrid;
    procedure ComboConnDriverChange(Sender: TObject);
    procedure BtnRunConnectorClick(Sender: TObject);
  private
    procedure SetupDefaultSQL;
    function GetEngine: TEngine;
    function GetDriver: TDriver;
    function BuildFilter: String;
    procedure ApplyBootstrapChrome;
  protected
    procedure SetParent(const Value: TFmxObject); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  BootstrapStyle,
  BootstrapStyle.Core,
  FMX.Edit.Helper,
  FMX.ComboEdit.Helper,
  FMX.Objects.Helper,
  FMX.Edit.Extension,
  FMX.ComboEdit.Extension,
  &Type.&Array,
  &Type.&Array.Field,
  &Type.&Array.&String,
  &Type.&Array.Variant,
  &Type.Dictionary.Helper,
  Connection,
  Connector,
  Query,
  QueryBuilder,
  SmartPointer.Intf,
  SmartPointer;

{$R *.fmx}

{ TFrameConnector }

constructor TFrameConnector.Create(AOwner: TComponent);
begin
  inherited;
  ComboConnEngine.ItemIndex := 0;
  ComboConnDriver.ItemIndex := 0;
  { Opt-in explícito: apenas os result-components do Connector recebem a extensão }
  EditConnResult.Extension       := True;
  ComboEditConnResult.Extension  := True;
  SetupDefaultSQL;
  // Default database path for SQLite
  EditConnDatabase.Text :=
    {$IFDEF MSWINDOWS}
    ExtractFilePath(ParamStr(0)) + 'DB.SQLITE';
    {$ELSE}
    TPath.Combine(TPath.GetDocumentsPath, 'DB.SQLITE');
    {$ENDIF}
end;

procedure TFrameConnector.ApplyBootstrapChrome;
begin
  { Buttons }
  TBootstrapStyle.ApplyButton(BtnRunConnector, bsPrimary, 'Run Connector', 15, 'play-fill');
  { Config panel controls }
  TBootstrapStyle.ApplyComboBox(ComboConnEngine,  14);
  TBootstrapStyle.ApplyComboBox(ComboConnDriver,  14);
  TBootstrapStyle.ApplyEdit(EditConnDatabase,     14);
  TBootstrapStyle.ApplyMemo(MemoConnSQL,          13);
  TBootstrapStyle.ApplyEdit(EditConnIndexField,   14);
  TBootstrapStyle.ApplyEdit(EditConnValueField,   14);
  TBootstrapStyle.ApplyEdit(EditConnFilter,       14);
  TBootstrapStyle.ApplyComboBox(ComboConnOptions, 14);
  { Result components }
  TBootstrapStyle.ApplyComboBox(ComboConnResult,        14);
  TBootstrapStyle.ApplyEdit(EditConnResult,             14);
  TBootstrapStyle.ApplyComboEdit(ComboEditConnResult,   14);
  TBootstrapStyle.ApplySearchBox(SearchBoxListBox,      14);
  TBootstrapStyle.ApplyListBox(ListBoxConnResult,       14);
  TBootstrapStyle.ApplyListView(ListViewConnResult,     13);
  TBootstrapStyle.ApplyStringGrid(StringGridConnResult, 13);
  TBootstrapStyle.ApplyGrid(GridConnResult,             13);
end;

procedure TFrameConnector.SetParent(const Value: TFmxObject);
begin
  inherited SetParent(Value);
  if Value <> nil then
    ApplyBootstrapChrome;
end;

procedure TFrameConnector.SetupDefaultSQL;
begin
  MemoConnSQL.Text := 'SELECT id AS Codigo, nome AS Estado, sigla AS Sigla FROM estado ORDER BY id';
  EditConnIndexField.Text := 'Codigo';
  EditConnValueField.Text := 'Estado';
end;

function TFrameConnector.GetEngine: TEngine;
begin
  case ComboConnEngine.ItemIndex of
    0: Result := TEngine.FireDAC;
    1: Result := TEngine.dbExpress;
    2: Result := TEngine.ZeOS;
    3: Result := TEngine.UniDAC;
  else
    Result := TEngine.FireDAC;
  end;
end;

function TFrameConnector.GetDriver: TDriver;
begin
  case ComboConnDriver.ItemIndex of
    0: Result := TDriver.SQLite;
    1: Result := TDriver.MySQL;
    2: Result := TDriver.Firebird;
    3: Result := TDriver.PostgreSQL;
    4: Result := TDriver.MSSQL;
    5: Result := TDriver.Oracle;
  else
    Result := TDriver.SQLite;
  end;
end;

function TFrameConnector.BuildFilter: String;
var
  LDummy: Integer;
begin
  Result := Trim(EditConnFilter.Text);
  // If using index mode and filter is a number, wrap as JSON
  if (ComboConnOptions.ItemIndex = 1) and (Result <> '') then
  begin
    if TryStrToInt(Result, LDummy) then
      Result := '{"Index":' + Result + '}';
  end;
end;

procedure TFrameConnector.ComboConnDriverChange(Sender: TObject);
begin
  // Update database hint based on driver
  if ComboConnDriver.ItemIndex = 0 then // SQLite
    EditConnDatabase.Text :=
      {$IFDEF MSWINDOWS}
      ExtractFilePath(ParamStr(0)) + 'DB.SQLITE'
      {$ELSE}
      TPath.Combine(TPath.GetDocumentsPath, 'DB.SQLITE')
      {$ENDIF}
  else
    EditConnDatabase.Text := 'mydb';
end;

procedure TFrameConnector.BtnRunConnectorClick(Sender: TObject);
var
  DB: TSmartPointer<TConnection>;
  SQL: TSmartPointer<TQuery>;
  QBuilder: TQueryBuilder;
  LConnector: TConnector;
  LFilter: String;
  LIndexField, LValueField: String;
begin
  LFilter     := BuildFilter;
  LIndexField := Trim(EditConnIndexField.Text);
  LValueField := Trim(EditConnValueField.Text);

  try
    DB := TSmartPointer<TConnection>.Create(TConnection.Create(GetEngine));
    DB.Ref.Driver   := GetDriver;
    DB.Ref.Database := Trim(EditConnDatabase.Text);

    if not DB.Ref.Connected then
      DB.Ref.Connected := True;

    QBuilder := TQueryBuilder.ForConnection(DB.Ref.GetConnectionStrategy);
    SQL := TSmartPointer<TQuery>.Create(QBuilder.View(Trim(MemoConnSQL.Text)));

    LConnector := TConnector.Create(SQL.Ref);
    try
      if LFilter <> '' then
      begin
        LConnector.ToCombo(ComboConnResult, LIndexField, LValueField, LFilter);
        LConnector.ToCombo(EditConnResult, LIndexField, LValueField, LFilter);
        LConnector.ToCombo(ComboEditConnResult, LIndexField, LValueField, LFilter);
        LConnector.ToListBox(ListBoxConnResult, LIndexField, LValueField, LFilter);
        LConnector.ToGrid(StringGridConnResult, LFilter);
        LConnector.ToGrid(GridConnResult, LFilter);
        LConnector.ToListView(ListViewConnResult, LIndexField, LValueField, ['Codigo', 'Estado', 'Sigla'], LFilter);
      end
      else
      begin
        LConnector.ToCombo(ComboConnResult, LIndexField, LValueField, '');
        LConnector.ToCombo(EditConnResult, LIndexField, LValueField, '');
        LConnector.ToCombo(ComboEditConnResult, LIndexField, LValueField, '');
        LConnector.ToListBox(ListBoxConnResult, LIndexField, LValueField, '');
        LConnector.ToGrid(StringGridConnResult, '');
        LConnector.ToGrid(GridConnResult, '');
        LConnector.ToListView(ListViewConnResult, LIndexField, LValueField, ['Codigo', 'Estado', 'Sigla'], '');
      end;
    finally
      LConnector.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Connector error: ' + E.Message);
  end;
end;

end.
