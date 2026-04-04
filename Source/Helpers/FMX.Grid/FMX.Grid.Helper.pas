unit FMX.Grid.Helper;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  System.Generics.Collections,
  System.Variants,
  System.RTTI,
  System.Types,
  System.UITypes,
  FMX.Grid,
  FMX.Controls,
  FMX.Graphics,
  FMX.Consts,
  Data.DB;

procedure ReleaseFMXGridVirtualDataBinding(AGrid: TGrid);

type
  TGridHelper = class helper for TGrid
  private
    class var FData: TDataSet;
    function GetData: TDataSet;
    procedure SetData(Data: TDataSet);
    procedure DoFillData(Data: TDataSet);
    class var FAutoSizeColumns: Boolean;
    function GetAutoSizeColumns: Boolean;
    procedure SetAutoSizeColumns(Value: Boolean);
    procedure DoAutoSizeColumns;
  public
    procedure RemoveRows(RowIndex, RCount: Integer);
    procedure Clear;
    property FillData: TDataSet read GetData write SetData;
    property AutoSizeColumns: Boolean read GetAutoSizeColumns write SetAutoSizeColumns default false;
  end;

implementation

type
  TGridOnGetBridge = class(TComponent)
  strict private
    FData: TDataSet;
  public
    destructor Destroy; override;
    procedure GridOnGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: System.Rtti.TValue);
    procedure GridOnSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: System.Rtti.TValue);
    property SourceData: TDataSet read FData write FData;
  end;

procedure DisposeGridGetBridge(AGrid: TGrid);
var
  I: Integer;
begin
  AGrid.OnGetValue := nil;
  AGrid.OnSetValue := nil;
  for I := AGrid.ComponentCount - 1 downto 0 do
    if AGrid.Components[I] is TGridOnGetBridge then
      AGrid.Components[I].Free;
end;

procedure ReleaseFMXGridVirtualDataBinding(AGrid: TGrid);
begin
  if AGrid <> nil then
    DisposeGridGetBridge(AGrid);
end;

destructor TGridOnGetBridge.Destroy;
begin
  if Assigned(FData) then
    FreeAndNil(FData);
  inherited;
end;

procedure TGridOnGetBridge.GridOnSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: System.Rtti.TValue);
begin
 //
end;

procedure TGridOnGetBridge.GridOnGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: System.Rtti.TValue);
var
  G: TGrid;
  FieldIx: Integer;
begin
  Value := System.Rtti.TValue.Empty;
  if (FData = nil) or not FData.Active then
    Exit;
  if not (Owner is TGrid) then
    Exit;
  G := TGrid(Owner);
  if (ACol < 0) or (ACol >= G.ColumnCount) then
    Exit;
  FieldIx := G.ColumnByIndex(ACol).Tag;
  if (FieldIx < 0) or (FieldIx >= FData.FieldCount) or (ARow < 0) then
    Exit;

  FData.First;
  if ARow > 0 then
    FData.MoveBy(ARow);
  if FData.Eof and (ARow > 0) then
    Exit;
  Value := System.Rtti.TValue.From<String>(FData.Fields[FieldIx].Text);
end;

{ TGridHelper }

procedure TGridHelper.DoAutoSizeColumns;
var
  W: Integer;
  WMax: Single;
  SizeMax: Single;
  ColIdx: Integer;
  FieldIx: Integer;
begin
  if (FData = nil) or not FData.Active then
    Exit;
  SizeMax := Max(80, Self.Width * 0.95);
  for ColIdx := 0 to Self.ColumnCount - 1 do
  begin
    FieldIx := Self.ColumnByIndex(ColIdx).Tag;
    if (FieldIx < 0) or (FieldIx >= FData.FieldCount) then
      Continue;
    WMax := Max(8, Round(Canvas.TextWidth(Self.ColumnByIndex(ColIdx).Header)));
    FData.First;
    while not FData.Eof do
    begin
      W := Round(Canvas.TextWidth(FData.Fields[FieldIx].AsString));
      if W > WMax then
        WMax := W;
      FData.Next;
    end;
    FData.Last;
    WMax := Max(WMax + 12, 56);
    if WMax > SizeMax then
      Self.ColumnByIndex(ColIdx).Width := SizeMax
    else
      Self.ColumnByIndex(ColIdx).Width := WMax;
  end;
end;

procedure TGridHelper.DoFillData(Data: TDataSet);
var
  I: Integer;
  Column: TColumn;
  GridInst: TGrid;
  Bridge: TGridOnGetBridge;
begin
  if Data = nil then
    Exit;
  if not Data.Active then
    Data.Open;
  if Data.RecordCount > 0 then
    Data.First;

  GridInst := TGrid(Self);
  DisposeGridGetBridge(GridInst);

  if GridInst.Model <> nil then
  begin
    GridInst.Model.DefaultDrawing := True;
    GridInst.Model.DataStored := False;
    if GridInst.Model.RowHeight < 8 then
      GridInst.Model.RowHeight := 22;
    GridInst.Model.DefaultTextSettings.FontColor := $FF000000;
  end;

  if GridInst.Model <> nil then
    GridInst.Model.BeginUpdate;
  try
    Self.RowCount := Data.RecordCount;
    for I := 0 to Data.FieldCount - 1 do
    begin
      Column := TStringColumn.Create(nil);
      Column.Header := Data.FieldDefs[I].Name;
      Column.Tag := I;
      Column.Data := Data.Fields[I].FieldName;
      Column.Width := 72;
      Self.AddObject(Column);
    end;
  finally
    if GridInst.Model <> nil then
      GridInst.Model.EndUpdate;
  end;

  Bridge := TGridOnGetBridge.Create(GridInst);
  Bridge.SourceData := Data;
  GridInst.OnGetValue := Bridge.GridOnGetValue;
  GridInst.OnSetValue := Bridge.GridOnSetValue;

  if GridInst.Model <> nil then
    GridInst.Model.ClearCache;

  GridInst.Repaint;
end;

procedure TGridHelper.SetData(Data: TDataSet);
begin
  DisposeGridGetBridge(TGrid(Self));
  FData := Data;
  Self.DoFillData(Data);
end;

function TGridHelper.GetData: TDataSet;
begin
  Result := FData;
end;

procedure TGridHelper.SetAutoSizeColumns(Value: Boolean);
begin
  FAutoSizeColumns := Value;
  if FAutoSizeColumns then
    Self.DoAutoSizeColumns;
end;

function TGridHelper.GetAutoSizeColumns: Boolean;
begin
  Result := FAutoSizeColumns;
end;

procedure TGridHelper.Clear;
begin
  TGrid(Self).Clear;
end;

procedure TGridHelper.RemoveRows(RowIndex, RCount: Integer);
begin
  TGrid(Self).RemoveRows(RowIndex, RCount);
end;

end.
