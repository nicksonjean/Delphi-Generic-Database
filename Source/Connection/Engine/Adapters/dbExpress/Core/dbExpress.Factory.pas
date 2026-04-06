unit dbExpress.Factory;

{
  dbExpress.Factory
  ------------------------------------------------------------------------------
  IEngineFactory para dbExpress.
  Auto-registra no TEngineRegistry via initialization.
}

interface

uses
  Connection.Types,
  Connection.Strategy.Intf;

type
  TdbExpressFactory = class(TInterfacedObject, IEngineFactory)
  public
    function Engine: TEngine;
    function CreateConnectionStrategy: IConnectionStrategy;
    function CreateQueryStrategy: IQueryStrategy;
  end;

implementation

uses
  Engine.Registry,
  dbExpress.Connection.Strategy,
  dbExpress.Query.Strategy;

function TdbExpressFactory.Engine: TEngine;
begin
  Result := TEngine.dbExpress;
end;

function TdbExpressFactory.CreateConnectionStrategy: IConnectionStrategy;
begin
  Result := TdbExpressConnectionStrategy.Create;
end;

function TdbExpressFactory.CreateQueryStrategy: IQueryStrategy;
begin
  Result := TdbExpressQueryStrategy.Create;
end;

initialization
  TEngineRegistry.Register(TEngine.dbExpress, TdbExpressFactory.Create);

end.
