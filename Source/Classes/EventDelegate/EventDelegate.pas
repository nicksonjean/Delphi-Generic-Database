unit EventDelegate;

interface

uses
  System.Classes,
  System.UITypes,
  FMX.Types,
  FMX.Controls,
  FMX.ListView.Types,
  FMX.ListView.Appearances;

type
  TNotifyEventReference = reference to procedure(Sender: TObject);

  TNofifyKeyEventReference = reference to procedure(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);

  { OnKeyPress do VCL recriado para FMX: recebe apenas KeyChar (WideChar).
    Backspace é sintetizado como #8; teclas de controle puras são ignoradas. }
  TKeyPressEvent = procedure(Sender: TObject; var KeyChar: WideChar) of object;
  TNotifyKeyPressEventReference = reference to procedure(Sender: TObject; var KeyChar: WideChar);

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

  { Wrapper para procedure anônima }
  TNotifyKeyPressEventWrapper = class(TComponent)
  private
    FProc: TNotifyKeyPressEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyKeyPressEventReference); reintroduce;
  published
    procedure KeyDownBridge(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
  end;

  { Wrapper para handler of object — usado pelo class helper (property OnKeyPress) }
  TKeyPressEventBridge = class(TComponent)
  private
    FHandler: TKeyPressEvent;
  public
    constructor Create(Owner: TComponent; const Handler: TKeyPressEvent); reintroduce;
  published
    procedure KeyDownBridge(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
  end;

  TNotifyItemViewEventWrapper = class(TComponent)
  private
    FProc: TNotifyItemViewEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyItemViewEventReference); reintroduce;
  published
    procedure ItemViewEvent(const Sender: TObject; const AItem: TListViewItem);
  end;

function DelegateEvent        (Owner: TComponent; Proc: TNotifyEventReference):          TNotifyEvent;
function DelegateKeyEvent     (Owner: TComponent; Proc: TNofifyKeyEventReference):        TKeyEvent;
function DelegateKeyPressEvent(Owner: TComponent; Proc: TNotifyKeyPressEventReference):   TKeyEvent;
function DelegateItemViewEvent(Owner: TComponent; Proc: TNotifyItemViewEventReference):   TItemViewEvent;

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

type
  { TProc<T> não suporta var — tipo local necessário para o parâmetro var Ch }
  TKeyPressRunner = reference to procedure(var Ch: WideChar);

{ Bridge compartilhado: sintetiza #8 para Backspace, filtra teclas de controle }
procedure KeyPressBridgeRun(Sender: TObject; var Key: Word; var KeyChar: WideChar;
  const Runner: TKeyPressRunner);
var
  Ch: WideChar;
begin
  if KeyChar <> #0 then
    Ch := KeyChar
  else if Key = vkBack then
    Ch := #8
  else
    Exit;

  Runner(Ch);

  KeyChar := Ch;
  if KeyChar = #0 then Key := 0;
end;

{ TNotifyKeyPressEventWrapper }

constructor TNotifyKeyPressEventWrapper.Create(Owner: TComponent; Proc: TNotifyKeyPressEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyKeyPressEventWrapper.KeyDownBridge(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  KeyPressBridgeRun(Sender, Key, KeyChar,
    procedure(var Ch: WideChar) begin FProc(Sender, Ch); end);
end;

function DelegateKeyPressEvent(Owner: TComponent; Proc: TNotifyKeyPressEventReference): TKeyEvent;
begin
  Result := TNotifyKeyPressEventWrapper.Create(Owner, Proc).KeyDownBridge;
end;

{ TKeyPressEventBridge }

constructor TKeyPressEventBridge.Create(Owner: TComponent; const Handler: TKeyPressEvent);
begin
  inherited Create(Owner);
  FHandler := Handler;
end;

procedure TKeyPressEventBridge.KeyDownBridge(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  KeyPressBridgeRun(Sender, Key, KeyChar,
    procedure(var Ch: WideChar) begin FHandler(Sender, Ch); end);
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
