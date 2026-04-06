{
  Connection.Config.All
  ------------------------------------------------------------------------------
  Objetivo : Agrega (re-exporta via uses) todas as units públicas de Connection.Config
             para um único `uses Connection.Config.All` no projeto ou pacote.
  Nota     : Não declara tipos próprios — apenas força o linkage das dependências.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.All;

interface

uses
  Connection.Config.Types,
  Connection.Config.DocumentRefs,
  Connection.Config.Loader.Abstract,
  Connection.Config.Intf,
  Connection.Config.INI.Mapper,
  Connection.Config.JSON.Mapper,
  Connection.Config.XML.Mapper,
  Connection.Config.YAML.Mapper,
  Connection.Config.TOML.Mapper,
  Connection.Config.INI,
  Connection.Config.JSON,
  Connection.Config.XML,
  Connection.Config.YAML,
  Connection.Config.TOML,
  Connection.Config.Adapter.INI,
  Connection.Config.Adapter.JSON,
  Connection.Config.Adapter.XML,
  Connection.Config.Adapter.YAML,
  Connection.Config.Adapter.TOML,
  Connection.Config.Factory;

implementation

end.
