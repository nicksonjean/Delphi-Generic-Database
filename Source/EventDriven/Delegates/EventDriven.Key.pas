unit EventDriven.Key;

interface

uses
  System.Classes,
  System.UITypes,
  FMX.Types,
  FMX.Controls;

type
  TNofifyKeyEventReference = reference to procedure(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);

function DelegateKeyEvent(Owner: TComponent; Proc: TNofifyKeyEventReference): TKeyEvent;

type
  TNotifyKeyEventWrapper = class(TComponent)
  private
    FProc: TNofifyKeyEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNofifyKeyEventReference); reintroduce;
  published
    procedure KeyEvent(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
  end;

implementation

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

end.
