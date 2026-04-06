unit FireDAC.Factory;

{
  FireDAC.Factory
  ------------------------------------------------------------------------------
  IEngineFactory para FireDAC.
  Registra automaticamente o adapter no TEngineRegistry via initialization.
  Incluir esta unit no projeto = FireDAC disponível em runtime.
}

interface

uses
  Connection.Types,
  Connection.Strategy.Intf;

type
  TFireDACFactory = class(TInterfacedObject, IEngineFactory)
  public
    function Engine: TEngine;
    function CreateConnectionStrategy: IConnectionStrategy;
    function CreateQueryStrategy: IQueryStrategy;
  end;

implementation

uses
  Engine.Registry,
  FireDAC.Connection.Strategy,
  FireDAC.Query.Strategy;

function TFireDACFactory.Engine: TEngine;
begin
  Result := TEngine.FireDAC;
end;

function TFireDACFactory.CreateConnectionStrategy: IConnectionStrategy;
begin
  Result := TFireDACConnectionStrategy.Create;
end;

function TFireDACFactory.CreateQueryStrategy: IQueryStrategy;
begin
  Result := TFireDACQueryStrategy.Create;
end;

initialization
  TEngineRegistry.Register(TEngine.FireDAC, TFireDACFactory.Create);

end.
