{
  EventDriven.
  ------------------------------------------------------------------------------
  Objetivo : Biblioteca para Trabalhar com Delegação de Eventos Utilizando
  o Programação Orientada à Eventos POE no Padrão de Projetos MVE.
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  ------------------------------------------------------------------------------
  Esta biblioteca é software livre; você pode redistribuí-la e/ou modificá-la
  sob os termos da Licença Pública Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a versão 3.29 da Licença, ou (a seu critério)
  qualquer versão posterior.
  Esta biblioteca é distribuída na expectativa de que seja útil, porém, SEM
  NENHUMA GARANTIA; nem mesmo a garantia implícita de COMERCIABILIDADE OU
  ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA. Consulte a Licença Pública Geral Menor
  do GNU para mais detalhes. (Arquivo LICENÇA.TXT ou LICENSE.TXT)
  Você deve ter recebido uma cópia da Licença Pública Geral Menor do GNU junto
  com esta biblioteca; se não, escreva para a Free Software Foundation, Inc.,
  no endereço 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Você também pode obter uma copia da licença em:
  http://www.opensource.org/licenses/lgpl-license.php
}

unit EventDriven;

interface

uses
  System.Classes,
  System.Types,
  System.SysUtils,
  System.DateUtils,
  System.UITypes,
  System.Math.Vectors,
  System.RTTI,
  FMX.Graphics,
  FMX.Forms,
  FMX.ExtCtrls,
  FMX.Controls,
  FMX.Types,
  FMX.StdCtrls,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.ListBox,
  FMX.Edit,
  FMX.Controls.Presentation,
  FMX.Grid;

type
  TNotifyEvent = procedure(Sender: TObject) of object; { OK }
  TItemBoxEvent = procedure(const Sender: TCustomListBox; const Item: TListBoxItem) of object; { OK }
  TItemViewEvent = procedure(const Sender: TObject; const AItem: TListViewItem) of object; { OK }
  TPaintEvent = procedure(Sender: TObject; Canvas: TCanvas; const ARect: TRectF) of object; { OK }
  TMouseEvent = procedure(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single) of object;
  TMouseMoveEvent = procedure(Sender: TObject; Shift: TShiftState; X, Y: Single) of object;
  TMouseWheelEvent = procedure(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean) of object;
  TKeyEvent = procedure(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState) of object; { OK }
  TProcessTickEvent = procedure(Sender: TObject; time, deltaTime: Single) of object;
  TVirtualKeyboardEvent = procedure(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect) of object;
  TTapEvent = procedure(Sender: TObject; const Point: TPointF) of object;
  TTouchEvent = procedure(Sender: TObject; const Touches: TTouches; const Action: TTouchAction) of object;
  TItemControlEvent = procedure(const Sender: TObject; const AItem: TListItem; const AObject: TListItemSimpleControl) of object;
  TUpdatingObjectsEvent = procedure(const Sender: TObject; const AItem: TListViewItem; var AHandled: Boolean) of object;
  TOnGetValue = procedure(Sender: TObject; const ACol, ARow: Integer; var Value: System.Rtti.TValue) of object;
  TOnSetValue = procedure(Sender: TObject; const ACol, ARow: Integer; const Value: System.Rtti.TValue) of object;
  TPresenterNameChoosingEvent = procedure (Sender: TObject; var PresenterName: string) of object;

type
  TNotifyEventReference = reference to procedure(Sender: TObject);
  TNofifyKeyEventReference = reference to procedure(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  TNotifyItemBoxEventReference = reference to procedure(const Sender: TCustomListBox; const Item: TListBoxItem);
  TNotifyItemViewEventReference = reference to procedure(const Sender: TObject; const AItem: TListViewItem);
  TNotifyPaintEventReference = reference to procedure(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
  TNotifyMouseEventReference = reference to procedure(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  TNotifyItemButtonEventReference = reference to procedure(const Sender: TObject; const AItem: TListItem; const AObject: TListItemSimpleControl);
  TNotifyItemUpdatingEventReference = reference to procedure(const Sender: TObject; const AItem: TListViewItem; var AHandled: Boolean);
  TNotifyOnGetValueEventReference = reference to procedure(Sender: TObject; const ACol, ARow: Integer; var Value: System.Rtti.TValue);
  TNotifyOnSetValueEventReference = reference to procedure(Sender: TObject; const ACol, ARow: Integer; const Value: System.Rtti.TValue);
  TNotityOnPresentationNameChoosing = reference to procedure(Sender: TObject; var PresenterName: string);

type
  TNotifyEventWrapper = class(TComponent)
  private
    FProc: TNotifyEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyEventReference); reintroduce;
  published
    procedure Event(Sender: TObject);
  end;

type
  TNotifyKeyEventWrapper = class(TComponent)
  private
    FProc: TNofifyKeyEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNofifyKeyEventReference); reintroduce;
  published
    procedure KeyEvent(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
  end;

type
  TNotifyItemBoxEventWrapper = class(TComponent)
  private
    FProc: TNotifyItemBoxEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyItemBoxEventReference); reintroduce;
  published
    procedure ItemBoxEvent(const Sender: TCustomListBox; const AItem: TListBoxItem);
  end;

type
  TNotifyItemViewEventWrapper = class(TComponent)
  private
    FProc: TNotifyItemViewEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyItemViewEventReference); reintroduce;
  published
    procedure ItemViewEvent(const Sender: TObject; const AItem: TListViewItem);
  end;

type
  TNotifyPaintEventWrapper = class(TComponent)
  private
    FProc: TNotifyPaintEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyPaintEventReference); reintroduce;
  published
    procedure PaintEvent(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
  end;

type
  TNotifyItemButtonEventWrapper = class(TComponent)
  private
    FProc: TNotifyItemButtonEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyItemButtonEventReference); reintroduce;
  published
    procedure ItemControlEvent(const Sender: TObject; const AItem: TListItem; const AObject: TListItemSimpleControl);
  end;

type
  TNotifyItemUpdatingEventReferenceWrapper = class(TComponent)
  private
    FProc: TNotifyItemUpdatingEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyItemUpdatingEventReference); reintroduce;
  published
    procedure ItemUpdatingEvent(const Sender: TObject; const AItem: TListViewItem; var AHandled: Boolean);
  end;

type
  TNotifyOnGetValueEventReferenceWrapper = class(TComponent)
  private
    FProc: TNotifyOnGetValueEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyOnGetValueEventReference); reintroduce;
  published
    procedure OnGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: System.Rtti.TValue);
  end;

type
  TNotifyOnSetValueEventReferenceWrapper = class(TComponent)
  private
    FProc: TNotifyOnSetValueEventReference;
  public
    constructor Create(Owner: TComponent; Proc: TNotifyOnSetValueEventReference); reintroduce;
  published
    procedure OnSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: System.Rtti.TValue);
  end;

type
  TNotityOnPresentationNameChoosingReferenceWrapper = class(TComponent)
  private
    FProc: TNotityOnPresentationNameChoosing;
  public
    constructor Create(Owner: TComponent; Proc: TNotityOnPresentationNameChoosing); reintroduce;
  published
    procedure OnPresentationNameChoosing(Sender: TObject; var PresenterName: string);
  end;

type
  TEventComponent = class(TComponent)
  protected
    FAnon: TProc;
    procedure Notify(Sender: TObject);
    class function MakeComponent(const AOwner: TComponent; const AProc: TProc) : TEventComponent;
  public
    class procedure MethodReferenceToMethodPointer(const MethodReference; var MethodPointer);
    class function NotifyEvent(const AOwner: TComponent; const AProc: TProc) : TNotifyEvent; overload;
    class function NotifyEvent(const ANotifyReference: TNotifyEventReference) : TNotifyEvent; overload;
  end;

  { Shortcut Functions }
function DelegateEvent(Owner: TComponent; Proc: TNotifyEventReference) : TNotifyEvent;
function DelegateKeyEvent(Owner: TComponent; Proc: TNofifyKeyEventReference) : TKeyEvent;
function DelegatePaintEvent(Owner: TComponent; Proc: TNotifyPaintEventReference) : TPaintEvent;
function DelegateItemBoxEvent(Owner: TComponent; Proc: TNotifyItemBoxEventReference) : TItemBoxEvent;
function DelegateItemViewEvent(Owner: TComponent; Proc: TNotifyItemViewEventReference) : TItemViewEvent;
function DelegateItemButtonEvent(Owner: TComponent; Proc: TNotifyItemButtonEventReference): TItemControlEvent;
function DelegateItemUpdatingEvent(Owner: TComponent; Proc: TNotifyItemUpdatingEventReference): TUpdatingObjectsEvent;
function DelegateOnGetValueEvent(Owner: TComponent; Proc: TNotifyOnGetValueEventReference): TOnGetValue;
function DelegateOnSetValueEvent(Owner: TComponent; Proc: TNotifyOnSetValueEventReference): TOnSetValue;
function DelegateOnPresentationNameChoosing(Owner: TComponent; Proc: TNotityOnPresentationNameChoosing): TPresenterNameChoosingEvent;

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

function DelegateEvent(Owner: TComponent; Proc: TNotifyEventReference) : TNotifyEvent;
begin
  Result := TNotifyEventWrapper.Create(Owner, Proc).Event;
end;

{ TNotifyKeyEventWrapper }

constructor TNotifyKeyEventWrapper.Create(Owner: TComponent; Proc: TNofifyKeyEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyKeyEventWrapper.KeyEvent(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  FProc(Sender, Key, KeyChar, Shift);
end;

function DelegateKeyEvent(Owner: TComponent; Proc: TNofifyKeyEventReference) : TKeyEvent;
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

function DelegateItemViewEvent(Owner: TComponent; Proc: TNotifyItemViewEventReference) : TItemViewEvent;
begin
  Result := TNotifyItemViewEventWrapper.Create(Owner, Proc).ItemViewEvent;
end;

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

function DelegateItemBoxEvent(Owner: TComponent; Proc: TNotifyItemBoxEventReference) : TItemBoxEvent;
begin
  Result := TNotifyItemBoxEventWrapper.Create(Owner, Proc).ItemBoxEvent;
end;

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

{ TNotifyPaintEventWrapper }

constructor TNotifyPaintEventWrapper.Create(Owner: TComponent; Proc: TNotifyPaintEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyPaintEventWrapper.PaintEvent(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
begin
  FProc(Sender, Canvas, ARect);
end;

function DelegatePaintEvent(Owner: TComponent; Proc: TNotifyPaintEventReference) : TPaintEvent;
begin
  Result := TNotifyPaintEventWrapper.Create(Owner, Proc).PaintEvent;
end;

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

{ TNotifyOnGetValueEventReferenceWrapper }

constructor TNotifyOnGetValueEventReferenceWrapper.Create(Owner: TComponent; Proc: TNotifyOnGetValueEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyOnGetValueEventReferenceWrapper.OnGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: System.Rtti.TValue);
begin
  FProc(Sender, ACol, ARow, Value);
end;

function DelegateOnGetValueEvent(Owner: TComponent; Proc: TNotifyOnGetValueEventReference): TOnGetValue;
begin
  Result := TNotifyOnGetValueEventReferenceWrapper.Create(Owner, Proc).OnGetValue;
end;

{ TNotifyOnSetValueEventReferenceWrapper }

constructor TNotifyOnSetValueEventReferenceWrapper.Create(Owner: TComponent; Proc: TNotifyOnSetValueEventReference);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotifyOnSetValueEventReferenceWrapper.OnSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: System.Rtti.TValue);
begin
  FProc(Sender, ACol, ARow, Value);
end;

function DelegateOnSetValueEvent(Owner: TComponent; Proc: TNotifyOnSetValueEventReference): TOnSetValue;
begin
  Result := TNotifyOnSetValueEventReferenceWrapper.Create(Owner, Proc).OnSetValue;
end;

{ TNotityOnPresentationNameChoosingReferenceWrapper }

constructor TNotityOnPresentationNameChoosingReferenceWrapper.Create(Owner: TComponent; Proc: TNotityOnPresentationNameChoosing);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNotityOnPresentationNameChoosingReferenceWrapper.OnPresentationNameChoosing(Sender: TObject; var PresenterName: string);
begin
  FProc(Sender, PresenterName);
end;

function DelegateOnPresentationNameChoosing(Owner: TComponent; Proc: TNotityOnPresentationNameChoosing): TPresenterNameChoosingEvent;
begin
  Result := TNotityOnPresentationNameChoosingReferenceWrapper.Create(Owner, Proc).OnPresentationNameChoosing;
end;

{ TEventComponent }

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

class function TEventComponent.NotifyEvent(const ANotifyReference : TNotifyEventReference): TNotifyEvent;
begin
  TEventComponent.MethodReferenceToMethodPointer(ANotifyReference, Result);
end;

procedure TEventComponent.Notify(Sender: TObject);
begin
  FAnon();
end;

end.
