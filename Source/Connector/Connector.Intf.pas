unit Connector.Intf;

{
  IConnector — marcador para documentação / assinaturas externas.
  TConnector herda de TQuery (TObject): não implementa IConnector no Delphi sem IUnknown.
  Use TConnector diretamente onde precisar da implementação.
}

interface

type
  IConnector = interface
    ['{E4C8F3A1-2B9D-4E1F-8C0A-9D7E6F5B4A31}']
  end;

implementation

end.
