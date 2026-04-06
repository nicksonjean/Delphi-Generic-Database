unit EventDriven.Core;

interface

uses
  System.Classes,
  System.SysUtils;

type
  TNotifyEventReference = reference to procedure(Sender: TObject);

  TEventComponent = class(TComponent)
  protected
    FAnon: TProc;
    procedure Notify(Sender: TObject);
    class function MakeComponent(const AOwner: TComponent; const AProc: TProc): TEventComponent;
  public
    class procedure MethodReferenceToMethodPointer(const MethodReference; var MethodPointer);
    class function NotifyEvent(const AOwner: TComponent; const AProc: TProc): TNotifyEvent; overload;
    class function NotifyEvent(const ANotifyReference: TNotifyEventReference): TNotifyEvent; overload;
  end;

implementation

class function TEventComponent.MakeComponent(const AOwner: TComponent; const AProc: TProc): TEventComponent;
begin
  Result := TEventComponent.Create(AOwner);
  Result.FAnon := AProc;
end;

class function TEventComponent.NotifyEvent(const AOwner: TComponent; const AProc: TProc): TNotifyEvent;
begin
  Result := MakeComponent(AOwner, AProc).Notify;
end;

class procedure TEventComponent.MethodReferenceToMethodPointer(const MethodReference; var MethodPointer);
type
  TVtable = array [0 .. 3] of Pointer;
  PVtable = ^TVtable;
  PPVtable = ^PVtable;
begin
  System.TMethod(MethodPointer).Code := PPVtable(MethodReference)^^[3];
  System.TMethod(MethodPointer).Data := Pointer(MethodReference);
end;

class function TEventComponent.NotifyEvent(const ANotifyReference: TNotifyEventReference): TNotifyEvent;
begin
  TEventComponent.MethodReferenceToMethodPointer(ANotifyReference, Result);
end;

procedure TEventComponent.Notify(Sender: TObject);
begin
  FAnon();
end;

end.
