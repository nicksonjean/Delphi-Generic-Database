{
  EventDriven.
  ------------------------------------------------------------------------------
  Objetivo : Biblioteca para Trabalhar com Delegação de Eventos Utilizando
  o Programação Orientada à Eventos POE no Padrão de Projetos MVE.
  ------------------------------------------------------------------------------
}

unit EventDriven;

interface

uses
  System.Classes,
  System.Types,
  System.UITypes,
  System.Math.Vectors,
  System.RTTI,
  FMX.Types,
  FMX.Controls,
  FMX.ListView.Types,
  FMX.ListBox,
  FMX.Grid,
  EventDriven.Types,
  EventDriven.Core,
  EventDriven.Notify,
  EventDriven.Key,
  EventDriven.KeyPress,
  EventDriven.ItemBox,
  EventDriven.ItemView,
  EventDriven.Paint,
  EventDriven.ItemButton,
  EventDriven.ItemUpdating,
  EventDriven.GridBindings;

type
  TNotifyEvent = procedure(Sender: TObject) of object;
  TItemBoxEvent = EventDriven.ItemBox.TItemBoxEvent;
  TItemViewEvent = EventDriven.ItemView.TItemViewEvent;
  TPaintEvent = EventDriven.Paint.TPaintEvent;
  TMouseEvent = EventDriven.Types.TMouseEvent;
  TMouseMoveEvent = EventDriven.Types.TMouseMoveEvent;
  TMouseWheelEvent = EventDriven.Types.TMouseWheelEvent;
  TKeyEvent = EventDriven.Types.TKeyEvent;
  TProcessTickEvent = EventDriven.Types.TProcessTickEvent;
  TVirtualKeyboardEvent = EventDriven.Types.TVirtualKeyboardEvent;
  TTapEvent = EventDriven.Types.TTapEvent;
  TTouchEvent = EventDriven.Types.TTouchEvent;
  TItemControlEvent = EventDriven.ItemButton.TItemControlEvent;
  TUpdatingObjectsEvent = EventDriven.ItemUpdating.TUpdatingObjectsEvent;
  TOnGetValue = EventDriven.GridBindings.TOnGetValue;
  TOnSetValue = EventDriven.GridBindings.TOnSetValue;
  TPresenterNameChoosingEvent = EventDriven.GridBindings.TPresenterNameChoosingEvent;

  TNotifyEventReference = EventDriven.Core.TNotifyEventReference;
  TNofifyKeyEventReference = EventDriven.Key.TNofifyKeyEventReference;
  TKeyPressEvent = EventDriven.KeyPress.TKeyPressEvent;
  TNotifyKeyPressEventReference = EventDriven.KeyPress.TNotifyKeyPressEventReference;
  TNotifyItemBoxEventReference = EventDriven.ItemBox.TNotifyItemBoxEventReference;
  TNotifyItemViewEventReference = EventDriven.ItemView.TNotifyItemViewEventReference;
  TNotifyPaintEventReference = EventDriven.Paint.TNotifyPaintEventReference;
  TNotifyItemButtonEventReference = EventDriven.ItemButton.TNotifyItemButtonEventReference;
  TNotifyItemUpdatingEventReference = EventDriven.ItemUpdating.TNotifyItemUpdatingEventReference;
  TNotifyOnGetValueEventReference = EventDriven.GridBindings.TNotifyOnGetValueEventReference;
  TNotifyOnSetValueEventReference = EventDriven.GridBindings.TNotifyOnSetValueEventReference;
  TNotityOnPresentationNameChoosing = EventDriven.GridBindings.TNotityOnPresentationNameChoosing;

  TEventComponent = EventDriven.Core.TEventComponent;

function DelegateEvent        (Owner: TComponent; Proc: TNotifyEventReference):           TNotifyEvent;
function DelegateKeyEvent     (Owner: TComponent; Proc: TNofifyKeyEventReference):         TKeyEvent;
function DelegateKeyPressEvent(Owner: TComponent; Proc: TNotifyKeyPressEventReference):    TKeyEvent;
function DelegatePaintEvent(Owner: TComponent; Proc: TNotifyPaintEventReference): TPaintEvent;
function DelegateItemBoxEvent(Owner: TComponent; Proc: TNotifyItemBoxEventReference): TItemBoxEvent;
function DelegateItemViewEvent(Owner: TComponent; Proc: TNotifyItemViewEventReference): TItemViewEvent;
function DelegateItemButtonEvent(Owner: TComponent; Proc: TNotifyItemButtonEventReference): TItemControlEvent;
function DelegateItemUpdatingEvent(Owner: TComponent; Proc: TNotifyItemUpdatingEventReference): TUpdatingObjectsEvent;
function DelegateOnGetValueEvent(Owner: TComponent; Proc: TNotifyOnGetValueEventReference): TOnGetValue;
function DelegateOnSetValueEvent(Owner: TComponent; Proc: TNotifyOnSetValueEventReference): TOnSetValue;
function DelegateOnPresentationNameChoosing(Owner: TComponent; Proc: TNotityOnPresentationNameChoosing): TPresenterNameChoosingEvent;

implementation

function DelegateEvent(Owner: TComponent; Proc: TNotifyEventReference): TNotifyEvent;
begin
  Result := EventDriven.Notify.DelegateEvent(Owner, Proc);
end;

function DelegateKeyEvent(Owner: TComponent; Proc: TNofifyKeyEventReference): TKeyEvent;
begin
  Result := EventDriven.Key.DelegateKeyEvent(Owner, Proc);
end;

function DelegateKeyPressEvent(Owner: TComponent; Proc: TNotifyKeyPressEventReference): TKeyEvent;
begin
  Result := EventDriven.KeyPress.DelegateKeyPressEvent(Owner, Proc);
end;

function DelegatePaintEvent(Owner: TComponent; Proc: TNotifyPaintEventReference): TPaintEvent;
begin
  Result := EventDriven.Paint.DelegatePaintEvent(Owner, Proc);
end;

function DelegateItemBoxEvent(Owner: TComponent; Proc: TNotifyItemBoxEventReference): TItemBoxEvent;
begin
  Result := EventDriven.ItemBox.DelegateItemBoxEvent(Owner, Proc);
end;

function DelegateItemViewEvent(Owner: TComponent; Proc: TNotifyItemViewEventReference): TItemViewEvent;
begin
  Result := EventDriven.ItemView.DelegateItemViewEvent(Owner, Proc);
end;

function DelegateItemButtonEvent(Owner: TComponent; Proc: TNotifyItemButtonEventReference): TItemControlEvent;
begin
  Result := EventDriven.ItemButton.DelegateItemButtonEvent(Owner, Proc);
end;

function DelegateItemUpdatingEvent(Owner: TComponent; Proc: TNotifyItemUpdatingEventReference): TUpdatingObjectsEvent;
begin
  Result := EventDriven.ItemUpdating.DelegateItemUpdatingEvent(Owner, Proc);
end;

function DelegateOnGetValueEvent(Owner: TComponent; Proc: TNotifyOnGetValueEventReference): TOnGetValue;
begin
  Result := EventDriven.GridBindings.DelegateOnGetValueEvent(Owner, Proc);
end;

function DelegateOnSetValueEvent(Owner: TComponent; Proc: TNotifyOnSetValueEventReference): TOnSetValue;
begin
  Result := EventDriven.GridBindings.DelegateOnSetValueEvent(Owner, Proc);
end;

function DelegateOnPresentationNameChoosing(Owner: TComponent; Proc: TNotityOnPresentationNameChoosing): TPresenterNameChoosingEvent;
begin
  Result := EventDriven.GridBindings.DelegateOnPresentationNameChoosing(Owner, Proc);
end;

end.
