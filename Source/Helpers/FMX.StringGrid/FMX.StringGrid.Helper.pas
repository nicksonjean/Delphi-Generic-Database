unit FMX.StringGrid.Helper;

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
  Data.DB;

type
  TStringGridHelper = class helper for TStringGrid
  private
    class var FData : TDataSet;
    function GetData : TDataSet;
    procedure SetData(Data : TDataSet);
    procedure DoFillData(Data: TDataSet);
    class var FAutoSizeColumns: Boolean;
    function GetAutoSizeColumns : Boolean;
    procedure SetAutoSizeColumns(Value : Boolean);
    procedure DoAutoSizeColumns;
  public
    procedure RemoveRows(RowIndex, RCount: Integer);
    procedure Clear;
    property FillData: TDataSet read GetData write SetData;
    property AutoSizeColumns: Boolean read GetAutoSizeColumns write SetAutoSizeColumns default false;
  end;

implementation

{ TStringGridHelper }

procedure TStringGridHelper.DoAutoSizeColumns;
var
  W: Integer;
  WMax: Single;
  SizeMax: Single;
  Column : Integer;
begin
  if (FData = nil) or not FData.Active then
    Exit;
  SizeMax := Self.Width;
  for Column := 0 to Self.ColumnCount-1 do
  begin
    if Self.ColumnByIndex(Column).Width > 0 then
    begin
      WMax := Round(Canvas.TextWidth(Self.ColumnByIndex(Column).Header));
      FData.First;
      while not FData.Eof do
      begin
        W := Round(Canvas.TextWidth(FData.Fields[Column].AsString));
        if W > WMax then
          WMax := W;
        if WMax > SizeMax then
        begin
          Self.ColumnByIndex(Column).Width := SizeMax + 10;
          Break;
        end;
        Self.ColumnByIndex(Column).Width := WMax + 10;
        FData.Next;
      end;
      FData.Last;
    end;
  end;
end;

procedure TStringGridHelper.DoFillData(Data: TDataSet);
var
  I : Integer;
  Column : TColumn;
begin
  if (Data = nil) then
    Exit;
  if not Data.Active then
    Data.Open;
  Self.RowCount := Data.RecordCount;

  for I := 0 to Data.FieldCount - 1 do
  begin
    Column := TColumn.Create(nil);
    Column.Header := Data.Fields[I].FieldName;
    Column.Tag := I;
    Column.Parent := Self;
  end;

  Data.First;
  while not Data.Eof do
  begin
    for I := 0 to Data.FieldCount - 1 do
      Self.Cells[I, Data.RecNo - 1] := Data.Fields[I].AsString;
    Data.Next;
  end;
  Data.Last;
end;

procedure TStringGridHelper.SetData(Data: TDataSet);
begin
  TGrid(Self).OnGetValue := nil;
  FData := Data;
  Self.DoFillData(Data);
end;

function TStringGridHelper.GetData: TDataSet;
begin
  Result := FData;
end;

function TStringGridHelper.GetAutoSizeColumns: Boolean;
begin
  Result := FAutoSizeColumns;
end;

procedure TStringGridHelper.SetAutoSizeColumns(Value: Boolean);
begin
  FAutoSizeColumns := Value;
  if FAutoSizeColumns = True then
    Self.DoAutoSizeColumns;
end;

procedure TStringGridHelper.Clear;
var
  I: Integer;
begin
  for I := 0 to RowCount - 1 do
    RemoveRows(0, RowCount);
  ClearColumns;
end;

procedure TStringGridHelper.RemoveRows(RowIndex, RCount: Integer);
var
  I, J: Integer;
begin
  for I := RCount to RowCount - 1 do
    for J := 0 to ColumnCount - 1 do
      Cells[J, I] := Cells[J, I + 1];
  RowCount := RowCount - RCount;
end;

end.
