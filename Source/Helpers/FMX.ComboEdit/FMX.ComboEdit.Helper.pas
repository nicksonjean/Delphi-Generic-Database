﻿unit FMX.ComboEdit.Helper;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.DateUtils,
  FMX.Types,
  FMX.ComboEdit,
  FMX.ComboEdit.Style,
  FMX.Controls.Presentation,
  FMX.Controls.Model,
  FMX.Presentation.Messages,
  FMX.Forms,
  EventDriven;

type
  TComboEditHelper = class helper for TComboEdit
  private
    class var FLastKeyChar: System.WideChar;
    class var FLastKey : Word;
    class var FAutoComplete: Boolean;
    function GetEdit: TStyledComboEdit;
    function RemoveFontSettings(const Settings: TStyledSettings) : TStyledSettings;
    function GetListBoxFromComboEdit: TComboEditListBox;
    procedure ListBoxApplyStyleLookup(Sender: TObject);
    procedure DoAutoComplete;
    procedure SetAutoComplete(Value : Boolean);
    function GetAutoComplete : Boolean;
  public
    procedure SetFont(const FontFamily: TFontName; const FontStyles: TFontStyles; const FontSize: Integer; const FontColor: TAlphaColor);
    property ListBox: TComboEditListBox read GetListBoxFromComboEdit;
    property AutoComplete: Boolean read GetAutoComplete write SetAutoComplete default false;
  end;

implementation

uses
  System.Rtti,
  System.Generics.Collections,
  FMX.Graphics,
  FMX.Pickers,
  FMX.ListBox;

var
  GFonts: TDictionary<TComboEdit, TTextSettings>;
  GListBoxes: TDictionary<TComboEdit, TCustomListBox>;

type
  TComboTextSettings = class(TTextSettings)
  private
  var
    [Weak]
    FComboEdit: TComboEdit;
  public
    constructor Create(const ComboEdit: TComboEdit); reintroduce;
    destructor Destroy; override;
  end;

{ TComboTextSettings }

constructor TComboTextSettings.Create(const ComboEdit: TComboEdit);
begin
  inherited Create(ComboEdit);
  FComboEdit := ComboEdit;
end;

destructor TComboTextSettings.Destroy;
begin
  if GFonts.ContainsKey(FComboEdit) then
    GFonts.Remove(FComboEdit);

  if GListBoxes.ContainsKey(FComboEdit) then
    GListBoxes.Remove(FComboEdit);

  inherited;
end;

{ TComboEditHelper }

procedure TComboEditHelper.DoAutoComplete;
begin
  if FAutoComplete = True then
  begin
    Self.OnKeyDown := DelegateKeyEvent(
      Self,
      procedure(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState)
      begin
        FLastKey := Key;
        FLastKeyChar := KeyChar;
      end
    );
    Self.OnTyping := DelegateEvent(Self,
    procedure(Sender: TObject)
    var
      Search, Text: String;
      I: Integer;
    begin
      Search := Self.Text;
      if FLastKey = vkBack then
      begin
        FLastKey := 0;
        Exit;
      end;
      if (CharInSet(FLastKeyChar,[Chr(48)..Chr(57)])) or (CharInSet(FLastKeyChar,[Chr(65)..Chr(90)])) or (CharInSet(FLastKeyChar,[Chr(97)..Chr(122)])) then
      begin
        if Length(Search)<=0 then
          Exit;
        for I := 0 to Self.Items.Count do
        begin
          Text := Self.Text.ToLower;
          if Self.Items[I].ToLower.StartsWith(Text) then
            Break;
        end;
        Self.ItemIndex := I;
        Self.SelStart := Length(Search);
        Self.SelLength := (Length(Self.Text) - Length(Search));
      end;
    end);
  end;
end;

function TComboEditHelper.GetAutoComplete: Boolean;
begin
  Result := FAutoComplete;
end;

procedure TComboEditHelper.SetAutoComplete(Value: Boolean);
begin
  FAutoComplete := Value;
  Self.DoAutoComplete;
end;

function TComboEditHelper.GetListBoxFromComboEdit: TComboEditListBox;
begin
  if Self.HasPresentationProxy and (Self.PresentationProxy.Receiver is TStyledComboEdit) then
    Result := TStyledComboEdit(Self.PresentationProxy.Receiver).ListBox
  else
    Result := nil;
end;

function TComboEditHelper.GetEdit: TStyledComboEdit;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ChildrenCount - 1 do
    if Children[I] is TStyledComboEdit then
    begin
      Result := TStyledComboEdit(Children[I]);
      Break;
    end;
end;

procedure TComboEditHelper.ListBoxApplyStyleLookup(Sender: TObject);
var
  ListBox: TCustomListBox;
  Edit: TStyledComboEdit;
  Picker: TCustomListPicker;
  Settings: TTextSettings;
  Item: TListBoxItem;
  i: Integer;
begin
  if not GListBoxes.TryGetValue(Self, ListBox) then
    Exit;

  if not GFonts.TryGetValue(Self, Settings) then
    Exit;

  Edit := GetEdit;
  if Edit = nil then
    Exit;

  Picker := Edit.ListPicker;
  if Picker = nil then
    Exit;

  for i := 0 to ListBox.Items.Count - 1 do
  begin
    Item := ListBox.ListItems[i];

    Item.StyledSettings := RemoveFontSettings(Item.StyledSettings);

    if Settings.Font.Family <> '' then
      Item.TextSettings.Font.Family := Settings.Font.Family;

    Item.TextSettings.Font.Style := Settings.Font.Style;
    Item.TextSettings.Font.Size := Settings.Font.Size;
    Item.TextSettings.FontColor := Settings.FontColor;
  end;

  Picker.ItemHeight := Settings.Font.Size + 2;
end;

procedure TComboEditHelper.SetFont(const FontFamily: TFontName; const FontStyles: TFontStyles; const FontSize: Integer; const FontColor: TAlphaColor);
var
  Edit: TStyledComboEdit;
  ListBox: TCustomListBox;
  ListBoxPicker: TObject;
  Settings: TTextSettings;
  RttiType: TRttiType;
  RttiField: TRttiField;
begin
  ListBox := nil;

  Edit := GetEdit;
  if Edit = nil then
    Exit;

  RttiType := SharedContext.GetType(Edit.ListPicker.ClassType);
  if (RttiType <> nil) then
  begin
    RttiField := RttiType.GetField('FPopupListPicker');
    if (RttiField <> nil) then
    begin
      ListBoxPicker := RttiField.GetValue(Edit.ListPicker).AsObject;

      if (ListBoxPicker <> nil) then
      begin
        RttiType := SharedContext.GetType(ListBoxPicker.ClassType);
        if (RttiType <> nil) then
        begin
          RttiField := RttiType.GetField('FListBox');
          ListBox := RttiField.GetValue(ListBoxPicker).AsType<TCustomListBox>;
        end;
      end;
    end;
  end;

  if ListBox = nil then
    Exit;

  GListBoxes.Add(Self, ListBox);
  ListBox.OnApplyStyleLookup := ListBoxApplyStyleLookup;

  Settings := TComboTextSettings.Create(Self);
  GFonts.Add(Self, Settings);
  Settings.Font.Family := FontFamily;
  Settings.Font.Style := FontStyles;
  Settings.Font.Size := FontSize;
  Settings.FontColor := FontColor;

  Self.StyledSettings := RemoveFontSettings(Self.StyledSettings);
  Self.TextSettings.Assign(Settings);
end;

function TComboEditHelper.RemoveFontSettings(const Settings: TStyledSettings): TStyledSettings;
begin
  Result := Settings - [TStyledSetting.Family, TStyledSetting.Size, TStyledSetting.Style, TStyledSetting.FontColor];
end;

initialization

GListBoxes := TDictionary<TComboEdit, TCustomListBox>.Create;
GFonts := TDictionary<TComboEdit, TTextSettings>.Create;

finalization

GListBoxes.DisposeOf;
GFonts.DisposeOf;

end.
