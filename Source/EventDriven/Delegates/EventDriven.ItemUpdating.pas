unit EventDriven.ItemUpdating;

interface

uses
  System.Classes,
  FMX.ListView.Types,
  FMX.ListView.Appearances;

type
  TUpdatingObjectsEvent = procedure(const Sender: TObject; const AItem: TListViewItem; var AHandled: Boolean) of object;
  TNotifyItemUpdatingEventReference = reference to procedure(const Sender: TObject; const AItem: TListViewItem; var AHandled: Boolean);

function DelegateItemUpdatingEvent(Owner: TComponent; Proc: TNotifyItemUpdatingEventReference): TUpdatingObjectsEvent;

type
  TNotifyItemUpdatingEventReferenceWrapper = class(TComponent)
  private
    FProc: TNotifyItemUpdatingEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyItemUpdatingEventReference); reintroduce;
  published
    procedure ItemUpdatingEvent(const Sender: TObject; const AItem: TListViewItem; var AHandled: Boolean);
  end;

implementation

{ TNotifyItemUpdatingEventReferenceWrapper }

constructor TNotifyItemUpdatingEventReferenceWrapper.Create(Owner: TComponent; Proc: TNotifyItemUpdatingEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyItemUpdatingEventReferenceWrapper.ItemUpdatingEvent(const Sender: TObject; const AItem: TListViewItem; var AHandled: Boolean);
begin
  FProc(Sender, AItem, AHandled);
end;

function DelegateItemUpdatingEvent(Owner: TComponent; Proc: TNotifyItemUpdatingEventReference): TUpdatingObjectsEvent;
begin
  Result := TNotifyItemUpdatingEventReferenceWrapper.Create(Owner, Proc).ItemUpdatingEvent;
end;

end.
