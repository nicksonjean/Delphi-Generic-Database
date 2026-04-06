unit Query;

{
  Query
  ------------------------------------------------------------------------------
  Objetivo: Encapsular a execução de queries de forma agnóstica à engine.
  Construção apenas com IConnectionStrategy explícito — sem conexão implícita.
  Sem IFDEF de engine — zero acoplamento a FireDAC, dbExpress, ZeOS ou UniDAC.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

interface

uses
  System.SysUtils,
  Data.DB,
  Connection.Strategy.Intf,
  Engine.Registry,
  Query.Intf;

type
  TQuery = class
  private
    FStrategy:           IQueryStrategy;
    FConnectionStrategy: IConnectionStrategy;
    function  GetDataSet: TDataSet;
  public
    constructor Create(const AConnStrategy: IConnectionStrategy);
    destructor  Destroy; override;
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
    { Compatibilidade retroativa: Query retorna o TDataSet ativo }
    property  Query: TDataSet read GetDataSet;
    property  Strategy: IQueryStrategy read FStrategy;
    property  ConnectionStrategy: IConnectionStrategy read FConnectionStrategy;
  end;

implementation

uses
  Connection.Types;

{ TQuery }

constructor TQuery.Create(const AConnStrategy: IConnectionStrategy);
var
  Engine: TEngine;
begin
  inherited Create;
  FConnectionStrategy := AConnStrategy;
  Engine    := AConnStrategy.Engine;
  FStrategy := TEngineRegistry.CreateQueryStrategy(Engine);
  FStrategy.SetConnection(AConnStrategy);
end;

destructor TQuery.Destroy;
begin
  FStrategy := nil;
  FConnectionStrategy := nil;
  inherited Destroy;
end;

function TQuery.GetDataSet: TDataSet;
begin
  Result := FStrategy.AsDataSet;
end;

procedure TQuery.Open(const ASQL: String);
begin
  FStrategy.Open(ASQL);
end;

procedure TQuery.ExecSQL(const ASQL: String);
begin
  FStrategy.ExecSQL(ASQL);
end;

procedure TQuery.Close;
begin
  FStrategy.Close;
end;

function TQuery.IsEmpty: Boolean;
begin
  Result := FStrategy.IsEmpty;
end;

function TQuery.EOF: Boolean;
begin
  Result := FStrategy.EOF;
end;

procedure TQuery.First;
begin
  FStrategy.First;
end;

procedure TQuery.Next;
begin
  FStrategy.Next;
end;

function TQuery.FieldCount: Integer;
begin
  Result := FStrategy.FieldCount;
end;

function TQuery.Fields: TFields;
begin
  Result := FStrategy.Fields;
end;

function TQuery.FieldDefs: TFieldDefs;
begin
  Result := FStrategy.FieldDefs;
end;

function TQuery.AsDataSet: TDataSet;
begin
  Result := FStrategy.AsDataSet;
end;

function TQuery.AsInMemoryDataSet: TDataSet;
begin
  Result := FStrategy.AsInMemoryDataSet;
end;

function TQuery.RecordCount: Integer;
begin
  Result := FStrategy.RecordCount;
end;

end.
