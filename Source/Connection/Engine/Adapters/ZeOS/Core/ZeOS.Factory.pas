unit ZeOS.Factory;

interface

uses
  Connection.Types,
  Connection.Strategy.Intf;

type
  TZeOSFactory = class(TInterfacedObject, IEngineFactory)
  public
    function Engine: TEngine;
    function CreateConnectionStrategy: IConnectionStrategy;
    function CreateQueryStrategy: IQueryStrategy;
  end;

implementation

uses
  Engine.Registry,
  ZeOS.Connection.Strategy,
  ZeOS.Query.Strategy;

function TZeOSFactory.Engine: TEngine;
begin
  Result := TEngine.ZeOS;
end;

function TZeOSFactory.CreateConnectionStrategy: IConnectionStrategy;
begin
  Result := TZeOSConnectionStrategy.Create;
end;

function TZeOSFactory.CreateQueryStrategy: IQueryStrategy;
begin
  Result := TZeOSQueryStrategy.Create;
end;

initialization
  TEngineRegistry.Register(TEngine.ZeOS, TZeOSFactory.Create);

end.
