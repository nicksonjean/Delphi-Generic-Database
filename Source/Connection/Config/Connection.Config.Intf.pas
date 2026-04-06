{
  Connection.Config.Intf
  ------------------------------------------------------------------------------
  Objetivo : Contrato IConnectionConfig dos adaptadores (Adapter + Factory).
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.Intf;

interface

uses
  Connection;

type
  IConnectionConfig = interface
    ['{B9F7FE0A-EAFC-48F3-85A0-E1219AD17076}']
    function LoadFromFile(const AFileName: String): TConnection;
    function Load(const ASource: String): TConnection;
    { Sempre via wrappers em Connection.Config.DocumentRefs (TConnectionIniDocumentRef, …). }
    function LoadFromObject(const AObject: TObject): TConnection;
  end;

implementation

end.
