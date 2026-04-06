{
  Connection.Config.Loader.Abstract
  ------------------------------------------------------------------------------
  Objetivo : Contrato genérico para carregadores estáticos de configuração de
             TConnection (arquivo, texto em memória, objeto tipado).
  Detalhes : TConnectionConfigLoader é a raiz abstrata; cada formato herda e
             delega o mapeamento a Connection.Config.*.Mapper.
  Retorna : TConnection configurada sem conectar.
  ------------------------------------------------------------------------------
  Autor: Nickson Jeanmerson
}

unit Connection.Config.Loader.Abstract;

interface

uses
  Connection,
  Connection.Config.Types;

type
  { Carregador estático base — um descendente por formato (INI, JSON, XML, …). }
  TConnectionConfigLoader = class abstract
  protected
    class procedure RequireFileExists(const AFileName, ANotFoundMessage: string);
  public
    class function ConfigFormat: TConnectionConfigFormat; virtual; abstract;
    class function LoadFromFile(const AFileName: String): TConnection; virtual; abstract;
    class function Load(const ASource: String): TConnection; virtual; abstract;
    { Padrão: não suportado — descendentes aceitam TObject apenas via *DocumentRef
      (unit Connection.Config.DocumentRefs). }
    class function LoadFromObject(const AObject: TObject): TConnection; virtual;
  end;

implementation

uses
  System.SysUtils;

{ TConnectionConfigLoader }

class procedure TConnectionConfigLoader.RequireFileExists(const AFileName,
  ANotFoundMessage: string);
begin
  if not FileExists(AFileName) then
    raise EArgumentException.Create(ANotFoundMessage);
end;

class function TConnectionConfigLoader.LoadFromObject(const AObject: TObject): TConnection;
begin
  raise EArgumentException.CreateFmt(
    '%s does not support LoadFromObject for this object type.', [ClassName]);
end;

end.
