unit Connection.IDriverConfigurator;

{
  IDriverConfigurator
  ------------------------------------------------------------------------------
  Contrato para configurar um objeto de conexão nativo com os parâmetros
  de um driver específico. Cada combinação engine+driver possui sua própria
  implementação concreta dentro do adapter correspondente.
  ------------------------------------------------------------------------------
  Não importa nenhuma unit de engine.
}

interface

uses
  Connection.Types;

type
  IDriverConfigurator = interface
    ['{A1B2C3D4-0001-0000-0000-000000000004}']
    { Retorna o TDriver que este configurador atende }
    function DriverName: TDriver;
    { Configura AConn (TObject — cast interno para o tipo da engine)
      com os parâmetros em AParams, incluindo ExtraArgs }
    procedure Configure(const AConn: TObject; const AParams: TConnectionParams);
  end;

implementation

end.
