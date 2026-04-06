unit EventDriven.ItemView;

interface

uses
  System.Classes,
  FMX.ListView.Types,
  FMX.ListView.Appearances;

type
  TItemViewEvent = procedure(const Sender: TObject; const AItem: TListViewItem) of object;
  TNotifyItemViewEventReference = reference to procedure(const Sender: TObject; const AItem: TListViewItem);

function DelegateItemViewEvent(Owner: TComponent; Proc: TNotifyItemViewEventReference): TItemViewEvent;

type
  TNotifyItemViewEventWrapper = class(TComponent)
  private
    FProc: TNotifyItemViewEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyItemViewEventReference); reintroduce;
  published
    procedure ItemViewEvent(const Sender: TObject; const AItem: TListViewItem);
  end;

implementation

{ TNotifyItemViewEventWrapper }

constructor TNotifyItemViewEventWrapper.Create(Owner: TComponent; Proc: TNotifyItemViewEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyItemViewEventWrapper.ItemViewEvent(const Sender: TObject; const AItem: TListViewItem);
begin
  FProc(Sender, AItem);
end;

function DelegateItemViewEvent(Owner: TComponent; Proc: TNotifyItemViewEventReference): TItemViewEvent;
begin
  Result := TNotifyItemViewEventWrapper.Create(Owner, Proc).ItemViewEvent;
end;

end.
