unit SmartPointer.RefGuard;

{
  TSmartPointerRefGuard — guarda usado por TSmartPointer<T>: TInterfacedObject via IInterface
  ou Free direto para TObject sem suporte a interface.
}

interface

uses
  System.SysUtils;

type
  TSmartPointerRefGuard = class(TInterfacedObject)
  private
    FObject: TObject;
    FIntf: IInterface;
  public
    constructor Create(AObject: TObject);
    destructor Destroy; override;
  end;

implementation

{ TSmartPointerRefGuard }

constructor TSmartPointerRefGuard.Create(AObject: TObject);
begin
  inherited Create;
  FObject := AObject;
  if not Supports(AObject, IInterface, FIntf) then
    FIntf := nil;
end;

destructor TSmartPointerRefGuard.Destroy;
begin
  if Assigned(FIntf) then
    FIntf := nil
  else
    FObject.Free;
  inherited;
end;

end.
