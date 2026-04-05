unit ZeOS.QueryStrategy;

interface

uses
  System.Classes,
  Data.DB,
  Connection.IConnectionStrategy,
  Connection.IQueryStrategy;

type
  TZeOSQueryStrategy = class(TInterfacedObject, IQueryStrategy)
  strict private
    FQuery: TObject; { TZQuery }
  public
    constructor Create;
    destructor  Destroy; override;
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
  ZConnection,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  Datasnap.Provider,
  Datasnap.DBClient;

constructor TZeOSQueryStrategy.Create;
begin
  inherited Create;
  FQuery := TZQuery.Create(nil);
end;

destructor TZeOSQueryStrategy.Destroy;
begin
  FreeAndNil(FQuery);
  inherited Destroy;
end;

procedure TZeOSQueryStrategy.SetConnection(const AStrategy: IConnectionStrategy);
begin
  (FQuery as TZQuery).Connection := AStrategy.NativeConnection as TZConnection;
end;

procedure TZeOSQueryStrategy.Open(const ASQL: String);
var
  Q: TZQuery;
begin
  Q := FQuery as TZQuery;
  Q.Close;
  Q.SQL.Clear;
  Q.SQL.Text := ASQL;
  Q.Open;
end;

procedure TZeOSQueryStrategy.ExecSQL(const ASQL: String);
var
  Q: TZQuery;
begin
  Q := FQuery as TZQuery;
  Q.Close;
  Q.SQL.Clear;
  Q.SQL.Text := ASQL;
  Q.ExecSQL;
end;

procedure TZeOSQueryStrategy.Close;
begin
  (FQuery as TZQuery).Close;
end;

function TZeOSQueryStrategy.IsEmpty: Boolean;
begin
  Result := (FQuery as TZQuery).IsEmpty;
end;

function TZeOSQueryStrategy.EOF: Boolean;
begin
  Result := (FQuery as TZQuery).Eof;
end;

procedure TZeOSQueryStrategy.First;
begin
  (FQuery as TZQuery).First;
end;

procedure TZeOSQueryStrategy.Next;
begin
  (FQuery as TZQuery).Next;
end;

function TZeOSQueryStrategy.FieldCount: Integer;
begin
  Result := (FQuery as TZQuery).FieldCount;
end;

function TZeOSQueryStrategy.Fields: TFields;
begin
  Result := (FQuery as TZQuery).Fields;
end;

function TZeOSQueryStrategy.FieldDefs: TFieldDefs;
begin
  Result := (FQuery as TZQuery).FieldDefs;
end;

function TZeOSQueryStrategy.AsDataSet: TDataSet;
begin
  Result := FQuery as TZQuery;
end;

function TZeOSQueryStrategy.AsInMemoryDataSet: TDataSet;
var
  Q:        TZQuery;
  Provider: TDataSetProvider;
  CDS:      TClientDataSet;
begin
  Q        := FQuery as TZQuery;
  Provider := TDataSetProvider.Create(nil);
  CDS      := TClientDataSet.Create(nil);
  try
    Provider.DataSet := Q;
    CDS.SetProvider(Provider);
    CDS.Open;
  except
    FreeAndNil(CDS);
    FreeAndNil(Provider);
    raise;
  end;
  FreeAndNil(Provider);
  Result := CDS;
end;

function TZeOSQueryStrategy.RecordCount: Integer;
begin
  Result := (FQuery as TZQuery).RecordCount;
end;

end.
