unit EventDriven.ItemButton;

interface

uses
  System.Classes,
  FMX.ListView.Types;

type
  TItemControlEvent = procedure(const Sender: TObject; const AItem: TListItem; const AObject: TListItemSimpleControl) of object;
  TNotifyItemButtonEventReference = reference to procedure(const Sender: TObject; const AItem: TListItem; const AObject: TListItemSimpleControl);

function DelegateItemButtonEvent(Owner: TComponent; Proc: TNotifyItemButtonEventReference): TItemControlEvent;

type
  TNotifyItemButtonEventWrapper = class(TComponent)
  private
    FProc: TNotifyItemButtonEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyItemButtonEventReference); reintroduce;
  published
    procedure ItemControlEvent(const Sender: TObject; const AItem: TListItem; const AObject: TListItemSimpleControl);
  end;

implementation

{ TNotifyItemButtonEventWrapper }

constructor TNotifyItemButtonEventWrapper.Create(Owner: TComponent; Proc: TNotifyItemButtonEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyItemButtonEventWrapper.ItemControlEvent(const Sender: TObject; const AItem: TListItem; const AObject: TListItemSimpleControl);
begin
  FProc(Sender, AItem, AObject);
end;

function DelegateItemButtonEvent(Owner: TComponent; Proc: TNotifyItemButtonEventReference): TItemControlEvent;
begin
  Result := TNotifyItemButtonEventWrapper.Create(Owner, Proc).ItemControlEvent;
end;

end.
