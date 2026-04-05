unit SmartPointer.TSmartPointer;

{
  TSmartPointer<T> — RAII com propriedade Ref; compatível com TInterfacedObject quando aplicável.
}

interface

uses
  Generics.Defaults,
  System.SysUtils,
  SmartPointer.RefGuard;

type
  TSmartPointer<T: class, constructor> = record
  strict private
    FGuard: IInterface;
    FGuardedObject: T;
    procedure SetValues(GuardedObject: T);
    function GetValues: T;
  public
    procedure Create; overload;
    constructor Create(GuardedObject: T); overload;
    class operator Implicit(GuardedObject: T): TSmartPointer<T>;
    class operator Implicit(Smart: TSmartPointer<T>): T;
    property Ref: T read GetValues write SetValues;
  end;

implementation

{ TSmartPointer<T> }

constructor TSmartPointer<T>.Create(GuardedObject: T);
begin
  FGuardedObject := GuardedObject;
  FGuard := TSmartPointerRefGuard.Create(FGuardedObject);
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
