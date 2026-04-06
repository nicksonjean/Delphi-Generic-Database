unit dbExpress.Query.Strategy;

{
  dbExpress.Query.Strategy
  ------------------------------------------------------------------------------
  Implementação de IQueryStrategy para dbExpress.
  Gerencia TSQLQuery e produz TClientDataSet via TDataSetProvider.
}

interface

uses
  System.Classes,
  Data.DB,
  Connection.Strategy.Intf;

type
  TdbExpressQueryStrategy = class(TInterfacedObject, IQueryStrategy)
  strict private
    FQuery: TObject; { TSQLQuery }
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
  Data.SqlExpr,
  Datasnap.Provider,
  Datasnap.DBClient;

{ TdbExpressQueryStrategy }

constructor TdbExpressQueryStrategy.Create;
begin
  inherited Create;
  FQuery := TSQLQuery.Create(nil);
end;

destructor TdbExpressQueryStrategy.Destroy;
begin
  FreeAndNil(FQuery);
  inherited Destroy;
end;

procedure TdbExpressQueryStrategy.SetConnection(const AStrategy: IConnectionStrategy);
begin
  (FQuery as TSQLQuery).SQLConnection := AStrategy.NativeConnection as TSQLConnection;
end;

procedure TdbExpressQueryStrategy.Open(const ASQL: String);
var
  Q: TSQLQuery;
begin
  Q := FQuery as TSQLQuery;
  Q.Close;
  Q.SQL.Clear;
  Q.SQL.Text := ASQL;
  Q.Open;
end;

procedure TdbExpressQueryStrategy.ExecSQL(const ASQL: String);
var
  Q: TSQLQuery;
begin
  Q := FQuery as TSQLQuery;
  Q.Close;
  Q.SQL.Clear;
  Q.SQL.Text := ASQL;
  Q.ExecSQL;
end;

procedure TdbExpressQueryStrategy.Close;
begin
  (FQuery as TSQLQuery).Close;
end;

function TdbExpressQueryStrategy.IsEmpty: Boolean;
begin
  Result := (FQuery as TSQLQuery).IsEmpty;
end;

function TdbExpressQueryStrategy.EOF: Boolean;
begin
  Result := (FQuery as TSQLQuery).Eof;
end;

procedure TdbExpressQueryStrategy.First;
begin
  (FQuery as TSQLQuery).First;
end;

procedure TdbExpressQueryStrategy.Next;
begin
  (FQuery as TSQLQuery).Next;
end;

function TdbExpressQueryStrategy.FieldCount: Integer;
begin
  Result := (FQuery as TSQLQuery).FieldCount;
end;

function TdbExpressQueryStrategy.Fields: TFields;
begin
  Result := (FQuery as TSQLQuery).Fields;
end;

function TdbExpressQueryStrategy.FieldDefs: TFieldDefs;
begin
  Result := (FQuery as TSQLQuery).FieldDefs;
end;

function TdbExpressQueryStrategy.AsDataSet: TDataSet;
begin
  Result := FQuery as TSQLQuery;
end;

function TdbExpressQueryStrategy.AsInMemoryDataSet: TDataSet;
var
  Q:        TSQLQuery;
  Provider: TDataSetProvider;
  CDS:      TClientDataSet;
  Packet:   OleVariant;
begin
  Q        := FQuery as TSQLQuery;
  Provider := TDataSetProvider.Create(nil);
  CDS      := TClientDataSet.Create(nil);
  try
    Provider.DataSet := Q;
    CDS.SetProvider(Provider);
    CDS.Open;
    { Captura o packet enquanto Provider está vivo e CDS está aberto }
    Packet := CDS.Data;
    { Fecha CDS com Provider vivo: sem risco de AV (FProvider válido) }
    CDS.Close;
    { Desconecta CDS do Provider enquanto CDS está inativo:
      SetProvider(nil) com CDS inativo apenas zera FProvider/FProviderComp
      sem tentar reabrir — evita que FProvider fique dangling ao liberar Provider }
    CDS.SetProvider(nil);
  except
    FreeAndNil(CDS);
    FreeAndNil(Provider);
    raise;
  end;
  { Provider pode ser liberado com segurança: CDS.FProvider já é nil }
  FreeAndNil(Provider);
  { Recarrega dados no CDS agora desvinculado de qualquer provider }
  CDS.Data := Packet;
  CDS.Open;
  Result := CDS;
end;

function TdbExpressQueryStrategy.RecordCount: Integer;
begin
  Result := (FQuery as TSQLQuery).RecordCount;
end;

end.
