{
  Connection.All
  ------------------------------------------------------------------------------
  Objetivo : Agrega (via uses) todas as units públicas de Source\Connection para
             um único `uses Connection.All` no projeto ou pacote.
  Nota     : Não declara tipos próprios — apenas força o linkage das dependências.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.All;

interface

uses
  Connection.Types,
  Connection.Intf,
  Connection.Strategy.Intf,
  Engine.Registry,
  Connection.Engine.All,
  Connection.Config.All,
  Query.Intf,
  Query,
  QueryBuilder
  ;

implementation

end.