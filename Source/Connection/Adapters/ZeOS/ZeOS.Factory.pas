unit ZeOS.Factory;

interface

uses
  Connection.Types,
  Connection.IConnectionStrategy,
  Connection.IQueryStrategy,
  Connection.IEngineFactory;

type
  TZeOSFactory = class(TInterfacedObject, IEngineFactory)
  public
    function Engine: TEngine;
    function CreateConnectionStrategy: IConnectionStrategy;
    function CreateQueryStrategy: IQueryStrategy;
  end;

implementation

uses
  EngineRegistry,
  ZeOS.ConnectionStrategy,
  ZeOS.QueryStrategy;

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
