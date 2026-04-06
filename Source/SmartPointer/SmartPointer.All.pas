{
  SmartPointer.All
  ------------------------------------------------------------------------------
  Objetivo : Agrega (via uses) todas as units públicas de Source\SmartPointer para
             um único `uses SmartPointer.All` no projeto ou pacote.
  Nota     : Não declara tipos próprios — apenas força o linkage das dependências.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit SmartPointer.All;

interface

uses
  SmartPointer.Guard.Intf,
  SmartPointer.Guard,
  SmartPointer.Intf,
  SmartPointer.RefGuard,
  SmartPointer;

implementation

end.
