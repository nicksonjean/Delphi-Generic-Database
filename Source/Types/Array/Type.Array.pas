{
  Type.Array — IArray<T> com TArrayGuard (RAII).
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a criaусo de matrizes php-like em Delphi de forma otimi
  zada e sem a necessidade de se preocupar com o gerenciamento de memзria.
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  ------------------------------------------------------------------------------
  Esta biblioteca ж software livre; vocЖ pode redistribuь-la e/ou modificр-la
  sob os termos da Licenуa PЩblica Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a versсo 3.29 da Licenуa, ou (a seu critжrio)
  qualquer versсo posterior.
  Esta biblioteca ж distribuьda na expectativa de que seja Щtil, porжm, SEM
  NENHUMA GARANTIA; nem mesmo a garantia implьcita de COMERCIABILIDADE OU
  ADEQUAК├O A UMA FINALIDADE ESPEC═FICA. Consulte a Licenуa PЩblica Geral Menor
  do GNU para mais detalhes. (Arquivo LICENКA.TXT ou LICENSE.TXT)
  VocЖ deve ter recebido uma cзpia da Licenуa PЩblica Geral Menor do GNU junto
  com esta biblioteca; se nсo, escreva para a Free Software Foundation, Inc.,
  no endereуo 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  VocЖ tambжm pode obter uma copia da licenуa em:
  http://www.opensource.org/licenses/lgpl-license.php
}

unit &Type.&Array;

interface

uses
  Generics.Defaults,
  &Type.&Array.Guard.Intf;

type
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

{ TArrayGuard }

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
