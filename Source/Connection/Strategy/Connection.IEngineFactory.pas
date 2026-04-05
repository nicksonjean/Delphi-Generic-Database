unit Connection.IEngineFactory;

{
  IEngineFactory
  ------------------------------------------------------------------------------
  Abstract Factory para criação dos objetos de strategy de cada engine.
  Cada adapter registra sua fábrica concreta no TEngineRegistry.
  Inclusão da unit do adapter no projeto = engine disponível em runtime.
  ------------------------------------------------------------------------------
  Não importa nenhuma unit de engine — apenas tipos base e Data.DB.
}

interface

uses
  Connection.Types,
  Connection.IConnectionStrategy,
  Connection.IQueryStrategy;

type
  IEngineFactory = interface
    ['{A1B2C3D4-0001-0000-0000-000000000003}']
    { Identificador da engine que esta fábrica produz }
    function Engine: TEngine;
    { Cria uma nova estratégia de conexão para esta engine }
    function CreateConnectionStrategy: IConnectionStrategy;
    { Cria uma nova estratégia de query para esta engine }
    function CreateQueryStrategy: IQueryStrategy;
  end;

implementation

end.
