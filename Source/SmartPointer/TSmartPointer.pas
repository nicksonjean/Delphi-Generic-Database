unit TSmartPointer;

interface

uses
  Generics.Defaults, System.SysUtils;

type
  TSmartPointer<T: class, constructor> = record
  strict private
    FGuard: IInterface;
    FGuardedObject: T;
    procedure SetValues(GuardedObject: T);
    function GetValues: T;
  private
    type
      { TGuard gerencia o ciclo de vida do objeto.
        Se o objeto suporta IInterface (ex: TInterfacedObject), usa _Release
        da interface para decrementar o refcount corretamente, evitando
        double-free quando FInstance ou outra variavel de interface ainda
        segura uma referencia.
        Se nao suporta IInterface, chama Free diretamente como antes. }
      TGuard = class(TInterfacedObject)
      private
        FObject: TObject;
        FIntf: IInterface;
      public
        constructor Create(AObject: TObject);
        destructor Destroy; override;
      end;
  public
    procedure Create; overload;
    constructor Create(GuardedObject: T); overload;
    class operator Implicit(GuardedObject: T): TSmartPointer<T>;
    class operator Implicit(Smart: TSmartPointer<T>): T;
    property Ref: T read GetValues write SetValues;
  end;

implementation

{ TSmartPointer<T>.TGuard }

constructor TSmartPointer<T>.TGuard.Create(AObject: TObject);
begin
  FObject := AObject;
  { Tenta obter IInterface do objeto.
    Se obtiver, o refcount sera gerenciado via interface (TInterfacedObject).
    O FIntf segura a referencia durante a vida do TGuard. }
  if not Supports(AObject, IInterface, FIntf) then
    FIntf := nil;
end;

destructor TSmartPointer<T>.TGuard.Destroy;
begin
  if Assigned(FIntf) then
  begin
    { Objeto e TInterfacedObject: libera via interface.
      Ao zerar FIntf o refcount decrementa — se chegar a 0, o objeto
      e destruido automaticamente pelo TInterfacedObject._Release.
      Nao chamamos Free diretamente para evitar double-free. }
    FIntf := nil;
  end
  else
  begin
    { Objeto nao suporta IInterface: Free direto como antes. }
    FObject.Free;
  end;
  inherited;
end;

{ TSmartPointer<T> }

constructor TSmartPointer<T>.Create(GuardedObject: T);
begin
  FGuardedObject := GuardedObject;
  FGuard := TGuard.Create(FGuardedObject);
end;

procedure TSmartPointer<T>.Create;
begin
  TSmartPointer<T>.Create(T.Create);
end;

function TSmartPointer<T>.GetValues: T;
begin
  if not Assigned(FGuard) then
    Self := TSmartPointer<T>.Create(T.Create);
  Result := FGuardedObject;
end;

procedure TSmartPointer<T>.SetValues(GuardedObject: T);
begin
  if not Assigned(FGuard) then
    Self := TSmartPointer<T>.Create(T.Create);
  FGuardedObject := GuardedObject;
end;

class operator TSmartPointer<T>.Implicit(Smart: TSmartPointer<T>): T;
begin
  Result := Smart.Ref;
end;

class operator TSmartPointer<T>.Implicit(GuardedObject: T): TSmartPointer<T>;
begin
  Result := TSmartPointer<T>.Create(GuardedObject);
end;

end.
