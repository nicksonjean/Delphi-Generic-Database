unit Options.Intf;

{
  IOptions — marcador comum aos helpers Options.Integer, Options.Array e Options.JSON.
  Classes baseadas em TConnector/TQuery (TObject) não implementam esta interface no Delphi
  sem suporte a IUnknown; use o tipo concreto ou parâmetros genéricos onde precisar.
}

interface

type
  IOptions = interface
    ['{A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D}']
  end;

implementation

end.
