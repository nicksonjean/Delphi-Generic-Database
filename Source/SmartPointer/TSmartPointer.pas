unit TSmartPointer;

interface

uses
  Generics.Defaults;

type
  TSmartPointer<T: class, constructor> = record
  strict private
    FGuard: IInterface;
    FGuardedObject: T;
    procedure SetValues(GuardedObject: T);
    function GetValues: T;
  private
    type
      TGuard = class (TInterfacedObject)
      private
        FObject: TObject;
      public
        constructor Create(AObject: TObject);
        destructor Destroy; override;
      end;
  public
    procedure Create; overload;
    constructor Create(GuardedObject: T); overload;
    class operator Implicit(GuardedObject: T): TSmartPointer<T>;
    class operator Implicit(Smart: TSmartPointer <T>): T;
    property Ref: T read GetValues write SetValues;
  end;

implementation

{ TSmartPointer<T>.TGuard }

constructor TSmartPointer<T>.TGuard.Create(AObject: TObject);
begin
  FObject := AObject;
end;

destructor TSmartPointer<T>.TGuard.Destroy;
begin
  FObject.Free;
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
