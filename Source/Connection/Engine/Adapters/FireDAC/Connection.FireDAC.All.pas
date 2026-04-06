{
  Connection.FireDAC.All
  ------------------------------------------------------------------------------
  Objetivo : Agrega (re-exporta via uses) todas as units públicas do adapter
             FireDAC — Core (factory + strategies) e Drivers — para um único
             `uses Connection.FireDAC.All` no projeto.
  Nota     : Não declara tipos próprios — apenas força o linkage das dependências.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.FireDAC.All;

interface

uses
  FireDAC.Factory,
  FireDAC.Connection.Strategy,
  FireDAC.Query.Strategy,
  FireDAC.Driver.SQLite,
  FireDAC.Driver.MySQL,
  FireDAC.Driver.Firebird,
  FireDAC.Driver.Interbase,
  FireDAC.Driver.MSSQL,
  FireDAC.Driver.PostgreSQL,
  FireDAC.Driver.Oracle;

implementation

end.
