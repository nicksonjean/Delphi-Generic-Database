unit Connection.IQueryStrategy;

{
  IQueryStrategy
  ------------------------------------------------------------------------------
  Contrato de Strategy para execução de queries.
  Cada engine possui uma implementação concreta.
  TQuery delega toda operação de banco para esta interface.
  ------------------------------------------------------------------------------
  Não importa nenhuma unit de engine — apenas tipos base e Data.DB.
}

interface

uses
  System.Classes,
  Data.DB,
  Connection.IConnectionStrategy;

type
  IQueryStrategy = interface
    ['{A1B2C3D4-0001-0000-0000-000000000002}']
    { Vincula esta query à connection strategy de uma TConnection }
    procedure SetConnection(const AStrategy: IConnectionStrategy);
    { Executa SQL de leitura (SELECT) }
    procedure Open(const ASQL: String);
    { Executa SQL de escrita (INSERT/UPDATE/DELETE) }
    procedure ExecSQL(const ASQL: String);
    { Fecha o cursor atual }
    procedure Close;
    { Retorna True se o resultado está vazio }
    function IsEmpty: Boolean;
    { Cursor no fim do result set }
    function EOF: Boolean;
    { Move para o primeiro registro }
    procedure First;
    { Avança para o próximo registro }
    procedure Next;
    { Total de campos no result set }
    function FieldCount: Integer;
    { Coleção de campos — todos os métodos de TDataSet são acessíveis }
    function Fields: TFields;
    { FieldDefs para iteração de metadados }
    function FieldDefs: TFieldDefs;
    { Acesso ao TDataSet subjacente — para uso direto de FieldByName, FieldValues, etc. }
    function AsDataSet: TDataSet;
    { Dataset em memória desconectado da query original.
      FireDAC:          TFDMemTable populado via CopyDataSet
      dbExpress/ZeOS/UniDAC: TClientDataSet populado via TDataSetProvider
      O caller é responsável por liberar o objeto retornado. }
    function AsInMemoryDataSet: TDataSet;
    { Número de registros (pode ser -1 se não disponível antes de fetch completo) }
    function RecordCount: Integer;
  end;

implementation

end.
