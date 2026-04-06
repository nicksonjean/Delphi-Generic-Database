unit Engine.Registry;

{
  Engine.Registry
  ------------------------------------------------------------------------------
  Registry global de engines disponíveis em runtime.
  Cada adapter se auto-registra na seção initialization de seu Factory.pas.
  Inclusão da unit no projeto = engine disponível — sem alteração neste arquivo.
  ------------------------------------------------------------------------------
  Thread-safe para registro e lookup.
  Não há engine “padrão”: TConnection e TQuery exigem engine / conexão explícitas.
}

interface

uses
  System.SysUtils,
  System.SyncObjs,
  System.Generics.Collections,
  Connection.Types,
  Connection.Strategy.Intf;

type
  TEngineRegistry = class
  strict private
    class var FLock:        TCriticalSection;
    class var FEngines:     TDictionary<TEngine, IEngineFactory>;
    class var FInitialized: Boolean;
    class procedure EnsureInit;
  public
    { Registra um factory para a engine indicada.
      Chamado automaticamente via initialization de cada Factory.pas }
    class procedure Register(const AEngine: TEngine; const AFactory: IEngineFactory);
    { Retorna o factory para a engine indicada.
      Lança ENotSupportedException se a engine não foi registrada. }
    class function Get(const AEngine: TEngine): IEngineFactory;
    { Retorna True se a engine foi registrada }
    class function IsRegistered(const AEngine: TEngine): Boolean;
    { Lista de engines registradas }
    class function Available: TArray<TEngine>;
    { Cria uma ConnectionStrategy para a engine indicada }
    class function CreateConnectionStrategy(const AEngine: TEngine): IConnectionStrategy;
    { Cria uma QueryStrategy para a engine indicada }
    class function CreateQueryStrategy(const AEngine: TEngine): IQueryStrategy;
    { Libera recursos — chamado em finalization }
    class procedure Finalize;
  end;

implementation

class procedure TEngineRegistry.EnsureInit;
begin
  if not FInitialized then
  begin
    FLock    := TCriticalSection.Create;
    FEngines := TDictionary<TEngine, IEngineFactory>.Create;
    FInitialized := True;
  end;
end;

class procedure TEngineRegistry.Register(const AEngine: TEngine; const AFactory: IEngineFactory);
begin
  EnsureInit;
  FLock.Acquire;
  try
    FEngines.AddOrSetValue(AEngine, AFactory);
  finally
    FLock.Release;
  end;
end;

class function TEngineRegistry.Get(const AEngine: TEngine): IEngineFactory;
begin
  EnsureInit;
  FLock.Acquire;
  try
    if not FEngines.TryGetValue(AEngine, Result) then
      raise ENotSupportedException.CreateFmt(
        'Engine "%s" not registered. Include the corresponding Factory unit in your project.',
        [EngineToString(AEngine)]);
  finally
    FLock.Release;
  end;
end;

class function TEngineRegistry.IsRegistered(const AEngine: TEngine): Boolean;
begin
  EnsureInit;
  FLock.Acquire;
  try
    Result := FEngines.ContainsKey(AEngine);
  finally
    FLock.Release;
  end;
end;

class function TEngineRegistry.Available: TArray<TEngine>;
begin
  EnsureInit;
  FLock.Acquire;
  try
    Result := FEngines.Keys.ToArray;
  finally
    FLock.Release;
  end;
end;

class function TEngineRegistry.CreateConnectionStrategy(const AEngine: TEngine): IConnectionStrategy;
begin
  Result := Get(AEngine).CreateConnectionStrategy;
end;

class function TEngineRegistry.CreateQueryStrategy(const AEngine: TEngine): IQueryStrategy;
begin
  Result := Get(AEngine).CreateQueryStrategy;
end;

class procedure TEngineRegistry.Finalize;
begin
  if FInitialized then
  begin
    FreeAndNil(FEngines);
    FreeAndNil(FLock);
    FInitialized := False;
  end;
end;

initialization

finalization
  TEngineRegistry.Finalize;

end.
