unit SmartPointer.Guard;

{
  TGuard — libera TObject no destructor (uso com ISmartPointer<T>).
}

interface

uses
  SmartPointer.Guard.Intf;

type
  TGuard = class(TInterfacedObject, IGuard)
  private
    FObject: TObject;
  public
    constructor Create(); overload;
    constructor Create(AObject: TObject); overload;
    destructor Destroy; override;
  end;

implementation

{ TGuard }

constructor TGuard.Create;
begin
  inherited;
end;

constructor TGuard.Create(AObject: TObject);
begin
  inherited Create;
  FObject := AObject;
end;

destructor TGuard.Destroy;
begin
  FObject.Free;
  inherited;
end;

end.
