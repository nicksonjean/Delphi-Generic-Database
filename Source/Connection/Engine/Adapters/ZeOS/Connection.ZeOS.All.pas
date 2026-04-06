{
  Connection.ZeOS.All
  ------------------------------------------------------------------------------
  Objetivo : Agrega (re-exporta via uses) todas as units públicas do adapter
             ZeOS — Core (factory + strategies) e Drivers — para um único
             `uses Connection.ZeOS.All` no projeto.
  Nota     : Não declara tipos próprios — apenas força o linkage das dependências.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.ZeOS.All;

interface

uses
  ZeOS.Factory,
  ZeOS.Connection.Strategy,
  ZeOS.Query.Strategy,
  ZeOS.Driver.SQLite,
  ZeOS.Driver.MySQL,
  ZeOS.Driver.Firebird,
  ZeOS.Driver.Interbase,
  ZeOS.Driver.MSSQL,
  ZeOS.Driver.PostgreSQL,
  ZeOS.Driver.Oracle;

implementation

end.
