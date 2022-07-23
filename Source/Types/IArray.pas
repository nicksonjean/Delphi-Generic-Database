{
  IArray.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a cria��o de matrizes php-like em Delphi de forma otimi
  zada e sem a necessidade de se preocupar com o gerenciamento de mem�ria.
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  ------------------------------------------------------------------------------
  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la
  sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a vers�o 3.29 da Licen�a, ou (a seu crit�rio)
  qualquer vers�o posterior.
  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM
  NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU
  ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor
  do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)
  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto
  com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,
  no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Voc� tamb�m pode obter uma copia da licen�a em:
  http://www.opensource.org/licenses/lgpl-license.php
}

unit IArray;

interface

uses
  Generics.Defaults;

type
  IArrayGuard = interface
    ['{CE522D5D-41DE-4C6F-BC84-912C2AEF66B3}']
  end;
  TArrayGuard = class(TInterfacedObject, IArrayGuard)
  private
    FObject: TObject;
  public
    constructor Create(); overload;
    constructor Create(AObject: TObject); overload;
    destructor Destroy; override;
  end;
  IArray<T: class> = record
  private
    FArrayGuard: IArrayGuard;
    FArrayGuardedObject: T;
  public
    class operator Implicit(ArrayGuardedObject: T): IArray<T>;
    class operator Implicit(ArrayGuard: IArray<T>): T;
  end;

implementation

{ IArrayGuard }

constructor TArrayGuard.Create;
begin
  inherited;
end;

constructor TArrayGuard.Create(AObject: TObject);
begin
  FObject := AObject;
end;

destructor TArrayGuard.Destroy;
begin
  FObject.Free;
  inherited;
end;

{ IArray }

class operator IArray<T>.Implicit(ArrayGuardedObject: T): IArray<T>;
begin
  Result.FArrayGuard := TArrayGuard.Create(ArrayGuardedObject);
  Result.FArrayGuardedObject := ArrayGuardedObject;
end;

class operator IArray<T>.Implicit(ArrayGuard: IArray<T>): T;
begin
  Result := ArrayGuard.FArrayGuardedObject;
end;

end.
