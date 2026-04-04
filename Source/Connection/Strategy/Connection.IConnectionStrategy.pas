unit Connection.IConnectionStrategy;

{
  IConnectionStrategy
  ------------------------------------------------------------------------------
  Contrato de Strategy para gerenciamento de conexão.
  Cada engine (FireDAC, dbExpress, ZeOS, UniDAC) possui uma implementação
  concreta. TConnection delega toda a lógica de engine para esta interface.
  ------------------------------------------------------------------------------
  Zero $IFDEF de engine — apenas tipos base e Data.DB.
}

interface

uses
  Connection.Types;

type
  IConnectionStrategy = interface
    ['{A1B2C3D4-0001-0000-0000-000000000001}']
    { Configura os parâmetros de conexão sem conectar.
      Deve ser chamado antes de Connect. }
    procedure Configure(const AParams: TConnectionParams);
    { Abre a conexão }
    procedure Connect;
    { Fecha a conexão }
    procedure Disconnect;
    { Retorna True se a conexão está ativa }
    function IsConnected: Boolean;
    { Gerenciamento de transações }
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    { Retorna True se há uma transação ativa }
    function InTransaction: Boolean;
    { Retorna o objeto de conexão nativo (TFDConnection, TSQLConnection, etc.)
      como TObject — o adapter de Query faz o cast interno }
    function NativeConnection: TObject;
    { Engine identificador desta estratégia }
    function Engine: TEngine;
  end;

implementation

end.
