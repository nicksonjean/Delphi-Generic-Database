{
  EventDriven.All
  ------------------------------------------------------------------------------
  Objetivo : Agrega (via uses) todas as units públicas de Source\EventDriven para
             um único `uses EventDriven.All` no projeto ou pacote.
  Nota     : Não declara tipos próprios — apenas força o linkage das dependências.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit EventDriven.All;

interface

uses
  EventDriven.Types,
  EventDriven.Core,
  EventDriven.Notify,
  EventDriven.Key,
  EventDriven.KeyPress,
  EventDriven.ItemBox,
  EventDriven.ItemView,
  EventDriven.Paint,
  EventDriven.ItemButton,
  EventDriven.ItemUpdating,
  EventDriven.GridBindings,
  EventDriven;

implementation

end.
