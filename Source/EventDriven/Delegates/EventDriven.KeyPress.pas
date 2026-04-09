unit EventDriven.KeyPress;

{ Recria o OnKeyPress do VCL para controles FMX.
  ------------------------------------------------------------------------------
  O FMX não possui OnKeyPress — apenas OnKeyDown/OnKeyUp, que carregam Key:Word
  e KeyChar:WideChar. O bridge mapeia OnKeyDown → OnKeyPress da seguinte forma:

    KeyChar <> #0          → caractere imprimível → dispara normalmente
    Key = vkBack + KeyChar = #0 → sintetiza KeyChar = #8 (compatível VCL)
    demais teclas de controle  → ignoradas (não disparam OnKeyPress)

  Se o handler zerar KeyChar (consumindo o caractere), o bridge também zera Key,
  cancelando a tecla para o componente.

  Dois wrappers são fornecidos:
    TNotifyKeyPressEventWrapper — para procedures anônimas (DelegateKeyPressEvent)
    TKeyPressEventBridge        — para handlers of object (helper de propriedade)
  ------------------------------------------------------------------------------ }

interface

uses
  System.Classes,
  System.UITypes,
  FMX.Types,
  FMX.Controls;

type
  { Tipo equivalente ao TKeyPressEvent do VCL, adaptado para WideChar do FMX }
  TKeyPressEvent = procedure(Sender: TObject; var KeyChar: WideChar) of object;

  { Tipo reference (anônimo) para uso com DelegateKeyPressEvent }
  TNotifyKeyPressEventReference = reference to procedure(Sender: TObject; var KeyChar: WideChar);

{ Converte uma procedure anônima em TKeyEvent, pronto para atribuir a OnKeyDown }
function DelegateKeyPressEvent(Owner: TComponent; Proc: TNotifyKeyPressEventReference): TKeyEvent;

type
  { Wrapper para procedure anônima — usado por DelegateKeyPressEvent }
  TNotifyKeyPressEventWrapper = class(TComponent)
  private
    FProc: TNotifyKeyPressEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyKeyPressEventReference); reintroduce;
  published
    procedure KeyDownBridge(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
  end;

  { Wrapper para TKeyPressEvent of object — usado pelo class helper de propriedade }
  TKeyPressEventBridge = class(TComponent)
  private
    FHandler: TKeyPressEvent;
  public
    constructor Create(Owner: TComponent; const Handler: TKeyPressEvent); reintroduce;
  published
    procedure KeyDownBridge(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
  end;

implementation

type
  { TProc<T> não suporta var — tipo local necessário para o parâmetro var Ch }
  TKeyPressRunner = reference to procedure(var Ch: WideChar);

{ Bridge compartilhado: sintetiza #8 para backspace, filtra demais controles }
procedure RunKeyPressBridge(Sender: TObject; var Key: Word; var KeyChar: WideChar;
  const Runner: TKeyPressRunner);
var
  Ch: WideChar;
begin
  if KeyChar <> #0 then
    Ch := KeyChar
  else if Key = vkBack then
    Ch := #8          // sintetiza backspace como VCL fazia
  else
    Exit;             // tecla de controle sem equivalente — ignora

  Runner(Ch);

  KeyChar := Ch;
  if KeyChar = #0 then Key := 0;  // consumiu o caractere → cancela a tecla
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
  RunKeyPressBridge(Sender, Key, KeyChar,
    procedure(var Ch: WideChar) begin FProc(Sender, Ch); end);
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
  RunKeyPressBridge(Sender, Key, KeyChar,
    procedure(var Ch: WideChar) begin FHandler(Sender, Ch); end);
end;

{ Função pública }

function DelegateKeyPressEvent(Owner: TComponent; Proc: TNotifyKeyPressEventReference): TKeyEvent;
begin
  Result := TNotifyKeyPressEventWrapper.Create(Owner, Proc).KeyDownBridge;
end;

end.
