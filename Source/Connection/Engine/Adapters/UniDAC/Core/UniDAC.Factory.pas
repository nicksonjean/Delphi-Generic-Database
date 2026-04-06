unit UniDAC.Factory;

{
  UniDAC.Factory
  ------------------------------------------------------------------------------
  IEngineFactory para UniDAC.
  Auto-registra no TEngineRegistry via initialization.
  IMPORTANTE: Requer licença comercial UniDAC (Devart).
  Esta unit só compila se os units da UniDAC estiverem no search path do projeto.
}

interface

uses
  Connection.Types,
  Connection.Strategy.Intf;

type
  TUniDACFactory = class(TInterfacedObject, IEngineFactory)
  public
    function Engine: TEngine;
    function CreateConnectionStrategy: IConnectionStrategy;
    function CreateQueryStrategy: IQueryStrategy;
  end;

implementation

uses
  Engine.Registry,
  UniDAC.Connection.Strategy,
  UniDAC.Query.Strategy;

function TUniDACFactory.Engine: TEngine;
begin
  Result := TEngine.UniDAC;
end;

function TUniDACFactory.CreateConnectionStrategy: IConnectionStrategy;
begin
  Result := TUniDACConnectionStrategy.Create;
end;

function TUniDACFactory.CreateQueryStrategy: IQueryStrategy;
begin
  Result := TUniDACQueryStrategy.Create;
end;

initialization
  TEngineRegistry.Register(TEngine.UniDAC, TUniDACFactory.Create);

end.
