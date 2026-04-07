unit FMX.Edit.Helper;

interface

uses
  System.Types,
  System.UITypes,
  System.Classes,
  FMX.Edit,
  FMX.Edit.Suggest.Messages;

type
  TEditHelper = class helper for TEdit
  private
    function GetIndex: Integer;
    procedure SetIndex(const Value: Integer);
    procedure SetOnItemChange(const Value: TNotifyEvent);
    function GetItems: TStrings;
  public
    procedure SetEditControlColor(AColor: TAlphaColor);
    procedure AssignItems(const S: TStrings);
    procedure ForceDropDown;
    procedure PressEnter;
    procedure RefreshSuggestionList;
    procedure ClearSuggestionListBox;
    function SelectedItem: TSelectedItem;
    property OnItemChange: TNotifyEvent write SetOnItemChange;
    property ItemIndex: Integer read GetIndex write SetIndex;
    property Items: TStrings read GetItems;
  end;

implementation

uses
  System.RTTI,
  FMX.Objects,
  FMX.Types;

{ TEditHelper }

procedure TEditHelper.PressEnter;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessage(PM_PRESSENTER);
end;

procedure TEditHelper.RefreshSuggestionList;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessage(PM_REBUILD_SUGGESTIONS);
end;

procedure TEditHelper.ClearSuggestionListBox;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessage(PM_CLEAR_SUGGESTION_LISTBOX);
end;

function TEditHelper.SelectedItem: TSelectedItem;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessageWithResult<TSelectedItem>(PM_GET_SELECTEDITEM, Result);
end;

procedure TEditHelper.SetIndex(const Value: Integer);
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessage<Integer>(PM_SET_ITEMINDEX, Value);
end;

procedure TEditHelper.SetOnItemChange(const Value: TNotifyEvent);
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessage<TNotifyEvent>(PM_SET_ITEMCHANGE_EVENT, Value);
end;

procedure TEditHelper.ForceDropDown;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessage(PM_DROP_DOWN);
end;

function TEditHelper.GetIndex: Integer;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessageWithResult<Integer>(PM_GET_ITEMINDEX, Result);
end;

function TEditHelper.GetItems: TStrings;
begin
  if HasPresentationProxy then
    PresentationProxy.SendMessageWithResult<TStrings>(PM_GET_ITEMS, Result);
end;

procedure TEditHelper.AssignItems(const S: TStrings);
begin
  Self.Model.Data['suggestions'] := TValue.From<TStrings>(S);
end;

procedure TEditHelper.SetEditControlColor(AColor: TAlphaColor);
var
  T: TFmxObject;
begin
  if TEdit(Self) = nil then
    Exit;
  T := TEdit(Self).FindStyleResource('background');
  if (T <> nil) and (T is TRectangle) then
    if TRectangle(T).Fill <> nil then
      TRectangle(T).Fill.Color := AColor;
  TEdit(Self).Repaint;
end;

end.
