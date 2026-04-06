unit SmartPointer.Intf;

{
  ISmartPointer<T> — record com conversão implícita para T; ciclo de vida via TGuard + IGuard.
}

interface

uses
  SmartPointer.Guard.Intf;

type
  ISmartPointer<T: class> = record
  private
    FGuard: IGuard;
    FGuardedObject: T;
  public
    class operator Implicit(GuardedObject: T): ISmartPointer<T>;
    class operator Implicit(Guard: ISmartPointer<T>): T;
  end;

implementation

uses
  SmartPointer.Guard;

{ ISmartPointer }

class operator ISmartPointer<T>.Implicit(GuardedObject: T): ISmartPointer<T>;
begin
  Result.FGuard := TGuard.Create(GuardedObject);
  Result.FGuardedObject := GuardedObject;
end;

class operator ISmartPointer<T>.Implicit(Guard: ISmartPointer<T>): T;
begin
  Result := Guard.FGuardedObject;
end;

end.
