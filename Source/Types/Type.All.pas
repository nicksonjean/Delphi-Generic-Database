{
  Type.All
  ------------------------------------------------------------------------------
  Objetivo : Agrega (via uses) as units publicas de Source\Types para um unico
             `uses Type.All` no projeto ou pacote.
  Nota     : Nao declara tipos proprios — apenas forca o linkage das dependencias.
             Inclui MimeType (Reflection) porque varias units de matriz o usam.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit &Type.All;

interface

uses
  &Type.&Array.Guard.Intf,
  &Type.&Array.Intf,
  &Type.Locale,
  &Type.&String,
  &Type.Float,
  &Type.&Array,
  &Type.&Array.&String,
  &Type.&Array.&String.Helper,
  &Type.&Array.Variant,
  &Type.&Array.Variant.Helper,
  &Type.&Array.Field,
  &Type.&Array.Field.Helper,
  &Type.&Array.Assoc,
  &Type.DateTime
  ;

implementation

end.
