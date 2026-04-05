unit UniDAC.QueryStrategy;

interface

uses
  System.Classes,
  Data.DB,
  Connection.IConnectionStrategy,
  Connection.IQueryStrategy;

type
  TUniDACQueryStrategy = class(TInterfacedObject, IQueryStrategy)
  strict private
    FQuery: TObject; { TUniQuery }
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
  Uni,
  Datasnap.Provider,
  Datasnap.DBClient;

constructor TUniDACQueryStrategy.Create;
begin
  inherited Create;
  FQuery := TUniQuery.Create(nil);
end;

destructor TUniDACQueryStrategy.Destroy;
begin
  FreeAndNil(FQuery);
  inherited Destroy;
end;

procedure TUniDACQueryStrategy.SetConnection(const AStrategy: IConnectionStrategy);
begin
  (FQuery as TUniQuery).Connection := AStrategy.NativeConnection as TUniConnection;
end;

procedure TUniDACQueryStrategy.Open(const ASQL: String);
var
  Q: TUniQuery;
begin
  Q := FQuery as TUniQuery;
  Q.Close;
  Q.SQL.Clear;
  Q.SQL.Text := ASQL;
  Q.Open;
end;

procedure TUniDACQueryStrategy.ExecSQL(const ASQL: String);
var
  Q: TUniQuery;
begin
  Q := FQuery as TUniQuery;
  Q.Close;
  Q.SQL.Clear;
  Q.SQL.Text := ASQL;
  Q.Execute;
end;

procedure TUniDACQueryStrategy.Close;
begin
  (FQuery as TUniQuery).Close;
end;

function TUniDACQueryStrategy.IsEmpty: Boolean;
begin
  Result := (FQuery as TUniQuery).IsEmpty;
end;

function TUniDACQueryStrategy.EOF: Boolean;
begin
  Result := (FQuery as TUniQuery).Eof;
end;

procedure TUniDACQueryStrategy.First;
begin
  (FQuery as TUniQuery).First;
end;

procedure TUniDACQueryStrategy.Next;
begin
  (FQuery as TUniQuery).Next;
end;

function TUniDACQueryStrategy.FieldCount: Integer;
begin
  Result := (FQuery as TUniQuery).FieldCount;
end;

function TUniDACQueryStrategy.Fields: TFields;
begin
  Result := (FQuery as TUniQuery).Fields;
end;

function TUniDACQueryStrategy.FieldDefs: TFieldDefs;
begin
  Result := (FQuery as TUniQuery).FieldDefs;
end;

function TUniDACQueryStrategy.AsDataSet: TDataSet;
begin
  Result := FQuery as TUniQuery;
end;

function TUniDACQueryStrategy.AsInMemoryDataSet: TDataSet;
var
  Q:        TUniQuery;
  Provider: TDataSetProvider;
  CDS:      TClientDataSet;
begin
  Q        := FQuery as TUniQuery;
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

function TUniDACQueryStrategy.RecordCount: Integer;
begin
  Result := (FQuery as TUniQuery).RecordCount;
end;

end.
