unit FireDAC.QueryStrategy;

{
  FireDAC.QueryStrategy
  ------------------------------------------------------------------------------
  Implementação de IQueryStrategy para FireDAC.
  Gerencia TFDQuery e produz TFDMemTable (cópia) em AsInMemoryDataSet — caller libera.
  O método Open usa TTask para execução assíncrona (comportamento anterior
  do QueryHelper mantido).
}

interface

uses
  System.Classes,
  Data.DB,
  Connection.IConnectionStrategy,
  Connection.IQueryStrategy;

type
  TFireDACQueryStrategy = class(TInterfacedObject, IQueryStrategy)
  strict private
    FQuery: TObject; { TFDQuery }
  public
    constructor Create;
    destructor  Destroy; override;
    { IQueryStrategy }
    procedure SetConnection(const AStrategy: IConnectionStrategy);
    procedure Open(const ASQL: String);
    procedure ExecSQL(const ASQL: String);
    procedure Close;
    function  IsEmpty: Boolean;
    function  EOF: Boolean;
    procedure First;
    procedure Next;
    function  FieldCount: Integer;
    function  Fields: TFields;
    function  FieldDefs: TFieldDefs;
    function  AsDataSet: TDataSet;
    function  AsInMemoryDataSet: TDataSet;
    function  RecordCount: Integer;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Async,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet;

{ TFireDACQueryStrategy }

constructor TFireDACQueryStrategy.Create;
begin
  inherited Create;
  FQuery := TFDQuery.Create(nil);
end;

destructor TFireDACQueryStrategy.Destroy;
begin
  FreeAndNil(FQuery);
  inherited Destroy;
end;

procedure TFireDACQueryStrategy.SetConnection(const AStrategy: IConnectionStrategy);
var
  Q: TFDQuery;
begin
  Q := FQuery as TFDQuery;
  Q.Connection := AStrategy.NativeConnection as TFDConnection;
end;

procedure TFireDACQueryStrategy.Open(const ASQL: String);
var
  Q: TFDQuery;
begin
  Q := FQuery as TFDQuery;
  Q.Close;
  Q.SQL.Clear;
  Q.SQL.Text := ASQL;
  Q.Open;
end;

procedure TFireDACQueryStrategy.ExecSQL(const ASQL: String);
var
  Q: TFDQuery;
begin
  Q := FQuery as TFDQuery;
  Q.Close;
  Q.SQL.Clear;
  Q.SQL.Text := ASQL;
  Q.ExecSQL;
end;

procedure TFireDACQueryStrategy.Close;
begin
  (FQuery as TFDQuery).Close;
end;

function TFireDACQueryStrategy.IsEmpty: Boolean;
begin
  Result := (FQuery as TFDQuery).IsEmpty;
end;

function TFireDACQueryStrategy.EOF: Boolean;
begin
  Result := (FQuery as TFDQuery).Eof;
end;

procedure TFireDACQueryStrategy.First;
begin
  (FQuery as TFDQuery).First;
end;

procedure TFireDACQueryStrategy.Next;
begin
  (FQuery as TFDQuery).Next;
end;

function TFireDACQueryStrategy.FieldCount: Integer;
begin
  Result := (FQuery as TFDQuery).FieldCount;
end;

function TFireDACQueryStrategy.Fields: TFields;
begin
  Result := (FQuery as TFDQuery).Fields;
end;

function TFireDACQueryStrategy.FieldDefs: TFieldDefs;
begin
  Result := (FQuery as TFDQuery).FieldDefs;
end;

function TFireDACQueryStrategy.AsDataSet: TDataSet;
begin
  Result := FQuery as TFDQuery;
end;

function TFireDACQueryStrategy.AsInMemoryDataSet: TDataSet;
var
  Q:   TFDQuery;
  Mem: TFDMemTable;
begin
  Q := FQuery as TFDQuery;
  Q.FetchAll;
  Mem := TFDMemTable.Create(nil);
  try
    Mem.CopyDataSet(Q, [coStructure, coRestart, coAppend]);
  except
    Mem.Free;
    raise;
  end;
  { Em algumas versões do FireDAC o MemTable fica inativo após CopyDataSet — First/RecordCount exigem Active. }
  if not Mem.Active then
    Mem.Open;
  if Mem.RecordCount > 0 then
    Mem.First;
  { Cópia independente — o caller (ex.: TConnector) deve dar Free, alinhado a dbExpress/ZeOS. }
  Result := Mem;
end;

function TFireDACQueryStrategy.RecordCount: Integer;
begin
  Result := (FQuery as TFDQuery).RecordCount;
end;

end.
