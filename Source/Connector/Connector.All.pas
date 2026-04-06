{
  Connector.All
  ------------------------------------------------------------------------------
  Objetivo : Agrega (via uses) todas as units públicas de Source\Connector para
             um único `uses Connector.All` no projeto ou pacote.
  Nota     : Não declara tipos próprios — apenas força o linkage das dependências.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connector.All;

interface

uses
  Connector.Types,
  Connector.Intf,
  Connector,
  Options.Intf,
  Options.Integer,
  Options.&Array,
  Options.JSON
  ;

implementation

end.
