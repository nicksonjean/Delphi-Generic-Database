{
  IArray.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a criação de matrizes php-like em Delphi de forma otimi
  zada e sem a necessidade de se preocupar com o gerenciamento de memória.
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  ------------------------------------------------------------------------------
  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la
  sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a versão 3.29 da Licença, ou (a seu critério)
  qualquer versão posterior.
  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM
  NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU
  ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor
  do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)
  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto
  com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,
  no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Você também pode obter uma copia da licença em:
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
