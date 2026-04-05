unit EventDriven.Notify;

interface

uses
  System.Classes,
  EventDriven.Core;

function DelegateEvent(Owner: TComponent; Proc: TNotifyEventReference): TNotifyEvent;

type
  TNotifyEventWrapper = class(TComponent)
  private
    FProc: TNotifyEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyEventReference); reintroduce;
  published
    procedure Event(Sender: TObject);
  end;

implementation

{ TNotifyEventWrapper }

constructor TNotifyEventWrapper.Create(Owner: TComponent; Proc: TNotifyEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyEventWrapper.Event(Sender: TObject);
begin
  FProc(Sender);
end;

function DelegateEvent(Owner: TComponent; Proc: TNotifyEventReference): TNotifyEvent;
begin
  Result := TNotifyEventWrapper.Create(Owner, Proc).Event;
end;

end.
