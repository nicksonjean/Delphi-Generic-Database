{
  Connection.UniDAC.All
  ------------------------------------------------------------------------------
  Objetivo : Agrega (re-exporta via uses) todas as units públicas do adapter
             UniDAC — Core (factory + strategies) e Drivers — para um único
             `uses Connection.UniDAC.All` no projeto.
  Nota     : Não declara tipos próprios — apenas força o linkage das dependências.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.UniDAC.All;

interface

uses
  UniDAC.Factory,
  UniDAC.Connection.Strategy,
  UniDAC.Query.Strategy,
  UniDAC.Driver.SQLite,
  UniDAC.Driver.MySQL,
  UniDAC.Driver.Firebird,
  UniDAC.Driver.Interbase,
  UniDAC.Driver.MSSQL,
  UniDAC.Driver.PostgreSQL,
  UniDAC.Driver.Oracle;

implementation

end.
