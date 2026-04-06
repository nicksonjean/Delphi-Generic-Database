unit EventDriven.ItemBox;

interface

uses
  System.Classes,
  FMX.ListBox;

type
  TItemBoxEvent = procedure(const Sender: TCustomListBox; const Item: TListBoxItem) of object;
  TNotifyItemBoxEventReference = reference to procedure(const Sender: TCustomListBox; const Item: TListBoxItem);

function DelegateItemBoxEvent(Owner: TComponent; Proc: TNotifyItemBoxEventReference): TItemBoxEvent;

type
  TNotifyItemBoxEventWrapper = class(TComponent)
  private
    FProc: TNotifyItemBoxEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyItemBoxEventReference); reintroduce;
  published
    procedure ItemBoxEvent(const Sender: TCustomListBox; const AItem: TListBoxItem);
  end;

implementation

{ TNotifyItemBoxEventWrapper }

constructor TNotifyItemBoxEventWrapper.Create(Owner: TComponent; Proc: TNotifyItemBoxEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyItemBoxEventWrapper.ItemBoxEvent(const Sender: TCustomListBox; const AItem: TListBoxItem);
begin
  FProc(Sender, AItem);
end;

function DelegateItemBoxEvent(Owner: TComponent; Proc: TNotifyItemBoxEventReference): TItemBoxEvent;
begin
  Result := TNotifyItemBoxEventWrapper.Create(Owner, Proc).ItemBoxEvent;
end;

end.
