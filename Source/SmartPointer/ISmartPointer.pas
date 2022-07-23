unit ISmartPointer;

interface

uses
  Generics.Defaults;

type
  IGuard = interface
    ['{CE522D5D-41DE-4C6F-BC84-912C2AEF66B3}']
  end;
  TGuard = class(TInterfacedObject, IGuard)
  private
    FObject: TObject;
  public
    constructor Create(); overload;
    constructor Create(AObject: TObject); overload;
    destructor Destroy; override;
  end;
  ISmartPointer<T: class> = record
  private
    FGuard: IGuard;
    FGuardedObject: T;
  public
    class operator Implicit(GuardedObject: T): ISmartPointer<T>;
    class operator Implicit(Guard: ISmartPointer<T>): T;
  end;

implementation

{ TGuard }

constructor TGuard.Create;
begin
  inherited;
end;

constructor TGuard.Create(AObject: TObject);
begin
  FObject := AObject;
end;

destructor TGuard.Destroy;
begin
  FObject.Free;
  inherited;
end;

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
