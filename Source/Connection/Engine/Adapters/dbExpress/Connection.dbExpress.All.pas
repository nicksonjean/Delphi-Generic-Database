{
  Connection.dbExpress.All
  ------------------------------------------------------------------------------
  Objetivo : Agrega (re-exporta via uses) todas as units públicas do adapter
             dbExpress — Core (factory + strategies) e Drivers — para um único
             `uses Connection.dbExpress.All` no projeto.
  Nota     : Não declara tipos próprios — apenas força o linkage das dependências.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.dbExpress.All;

interface

uses
  dbExpress.Factory,
  dbExpress.Connection.Strategy,
  dbExpress.Query.Strategy,
  dbExpress.Driver.SQLite,
  dbExpress.Driver.MySQL,
  dbExpress.Driver.Firebird,
  dbExpress.Driver.Interbase,
  dbExpress.Driver.MSSQL,
  dbExpress.Driver.PostgreSQL,
  dbExpress.Driver.Oracle;

implementation

end.
