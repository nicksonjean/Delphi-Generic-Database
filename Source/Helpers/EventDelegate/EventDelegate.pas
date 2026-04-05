unit EventDelegate;

interface

uses
  System.Classes,
  System.SysUtils,
  System.UITypes,
  FMX.Types,
  FMX.Controls,
  FMX.ListView.Types,
  FMX.ListView.Appearances;

type
  TNotifyEventReference = reference to procedure(Sender: TObject);

  TNofifyKeyEventReference = reference to procedure(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);

  TItemViewEvent = procedure(const Sender: TObject; const AItem: TListViewItem) of object;
  TNotifyItemViewEventReference = reference to procedure(const Sender: TObject; const AItem: TListViewItem);

  TNotifyEventWrapper = class(TComponent)
  private
    FProc: TNotifyEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyEventReference); reintroduce;
  published
    procedure Event(Sender: TObject);
  end;

  TNotifyKeyEventWrapper = class(TComponent)
  private
    FProc: TNofifyKeyEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNofifyKeyEventReference); reintroduce;
  published
    procedure KeyEvent(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
  end;

  TNotifyItemViewEventWrapper = class(TComponent)
  private
    FProc: TNotifyItemViewEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyItemViewEventReference); reintroduce;
  published
    procedure ItemViewEvent(const Sender: TObject; const AItem: TListViewItem);
  end;

function DelegateEvent(Owner: TComponent; Proc: TNotifyEventReference): TNotifyEvent;
function DelegateKeyEvent(Owner: TComponent; Proc: TNofifyKeyEventReference): TKeyEvent;
function DelegateItemViewEvent(Owner: TComponent; Proc: TNotifyItemViewEventReference): TItemViewEvent;

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

{ TNotifyKeyEventWrapper }

constructor TNotifyKeyEventWrapper.Create(Owner: TComponent; Proc: TNofifyKeyEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyKeyEventWrapper.KeyEvent(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  FProc(Sender, Key, KeyChar, Shift);
end;

function DelegateKeyEvent(Owner: TComponent; Proc: TNofifyKeyEventReference): TKeyEvent;
begin
  Result := TNotifyKeyEventWrapper.Create(Owner, Proc).KeyEvent;
end;

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
