unit MultiDetailHorzAppearanceU;
 
interface
 
uses FMX.ListView, FMX.ListView.Types, System.Classes, System.SysUtils,
FMX.Types, System.UITypes, FMX.MobilePreview;
 
type
 
  TMultiDetailHorzAppearanceNames = class
  public const
    ListItem = 'MultiDetailHorzItem';
    ListItemCheck = ListItem + 'ShowCheck';
    ListItemDelete = ListItem + 'Delete';
    Detail1 = 'det1';  
// Name of MultiDetail object/data
    Detail2 = 'det2';
    Detail3 = 'det3';
  end;
 
implementation
 
uses System.Math, System.Rtti;
 
type
 
  TMultiDetailHorzItemAppearance = class(TPresetItemObjects)
  public const
    cTextMarginAccessory = 8;
    cDefaultHeight = 40;
  private
    FMultiDetail1: TTextObjectAppearance;
    FMultiDetail2: TTextObjectAppearance;
    FMultiDetail3: TTextObjectAppearance;
    procedure SetMultiDetail1(const Value: TTextObjectAppearance);
    procedure SetMultiDetail2(const Value: TTextObjectAppearance);
    procedure SetMultiDetail3(const Value: TTextObjectAppearance);
  protected
    function DefaultHeight: Integer; override;
    procedure UpdateSizes; override;
    function GetGroupClass: TPresetItemObjects.TGroupClass; override;
    procedure SetObjectData(const AListViewItem: TListViewItem; const AIndex: string; const AValue: TValue; var AHandled: Boolean); override;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property MultiDetail1: TTextObjectAppearance read FMultiDetail1 write SetMultiDetail1;
    property MultiDetail2: TTextObjectAppearance read FMultiDetail2 write SetMultiDetail2;
    property MultiDetail3: TTextObjectAppearance read FMultiDetail3 write SetMultiDetail3;
    property Accessory;
  end;
 
  TMultiDetailHorzDeleteAppearance = class(TMultiDetailHorzItemAppearance)
  private const
    cDefaultGlyph = TGlyphButtonType.Delete;
  public
    constructor Create; override;
  published
    property GlyphButton;
  end;
 
  TMultiDetailShowCheckAppearance = class(TMultiDetailHorzItemAppearance)
  private const
    cDefaultGlyph = TGlyphButtonType.Checkbox;
  public
    constructor Create; override;
  published
    property GlyphButton;
  end;
 
const
  cMultiDetail1Member = 'Detail1';
  cMultiDetail2Member = 'Detail2';
  cMultiDetail3Member = 'Detail3';
 
constructor TMultiDetailHorzItemAppearance.Create;
begin
  inherited;
  Accessory.DefaultValues.AccessoryType := TAccessoryType.More;
  Accessory.DefaultValues.Visible := True;
  Accessory.RestoreDefaults;
  Text.DefaultValues.VertAlign := TListItemAlign.Trailing;
  Text.DefaultValues.TextVertAlign := TTextAlign.Center;
  Text.DefaultValues.Visible := True;
  Text.RestoreDefaults;
 
  FMultiDetail1 := TTextObjectAppearance.Create;
  FMultiDetail1.Name := TMultiDetailHorzAppearanceNames.Detail1;
  FMultiDetail1.DefaultValues.Assign(Text.DefaultValues);  
// Start with same defaults as Text object
  FMultiDetail1.DefaultValues.IsDetailText := True; 
// Use detail font
  FMultiDetail1.VertAlign := TListItemAlign.Leading;
  FMultiDetail1.Align := TListItemAlign.Trailing;
  FMultiDetail1.TextVertAlign := TTextAlign.Center;
  FMultiDetail1.RestoreDefaults;
  FMultiDetail1.OnChange := Self.ItemPropertyChange;
  FMultiDetail1.Owner := Self;
 
  FMultiDetail2 := TTextObjectAppearance.Create;
  FMultiDetail2.Name := TMultiDetailHorzAppearanceNames.Detail2;
  FMultiDetail2.DefaultValues.Assign(FMultiDetail1.DefaultValues);  
// Start with same defaults as Text object
  FMultiDetail2.VertAlign := TListItemAlign.Leading;
  FMultiDetail2.Align := TListItemAlign.Trailing;
  FMultiDetail2.TextVertAlign := TTextAlign.Center;
  FMultiDetail2.RestoreDefaults;
  FMultiDetail2.OnChange := Self.ItemPropertyChange;
  FMultiDetail2.Owner := Self;
 
  FMultiDetail3 := TTextObjectAppearance.Create;
  FMultiDetail3.Name := TMultiDetailHorzAppearanceNames.Detail3;
  FMultiDetail3.DefaultValues.Assign(FMultiDetail2.DefaultValues);  
// Start with same defaults as Text object
//  FMultiDetail3.DefaultValues.Height := 20; // Move text down
  FMultiDetail3.VertAlign := TListItemAlign.Leading;
  FMultiDetail3.Align := TListItemAlign.Trailing;
  FMultiDetail3.TextVertAlign := TTextAlign.Center;
  FMultiDetail3.RestoreDefaults;
  FMultiDetail3.OnChange := Self.ItemPropertyChange;
  FMultiDetail3.Owner := Self;
 
  
// Define livebindings members that make up MultiDetail
  FMultiDetail1.DataMembers :=
    TObjectAppearance.TDataMembers.Create(
      TObjectAppearance.TDataMember.Create(
        cMultiDetail1Member, 
// Displayed by LiveBindings
        Format('Data["%s"]', [TMultiDetailHorzAppearanceNames.Detail1])));   
// Expression to access value from TListViewItem
  FMultiDetail2.DataMembers :=
    TObjectAppearance.TDataMembers.Create(
      TObjectAppearance.TDataMember.Create(
        cMultiDetail2Member, 
// Displayed by LiveBindings
        Format('Data["%s"]', [TMultiDetailHorzAppearanceNames.Detail2])));   
// Expression to access value from TListViewItem
  FMultiDetail3.DataMembers :=
    TObjectAppearance.TDataMembers.Create(
      TObjectAppearance.TDataMember.Create(
        cMultiDetail3Member, 
// Displayed by LiveBindings
        Format('Data["%s"]', [TMultiDetailHorzAppearanceNames.Detail3])));   
// Expression to access value from TListViewItem
 
  GlyphButton.DefaultValues.VertAlign := TListItemAlign.Center;
  GlyphButton.RestoreDefaults;
 
  
// Define the appearance objects
  AddObject(Text, True);
  AddObject(MultiDetail1, True);
  AddObject(MultiDetail2, True);
  AddObject(MultiDetail3, True);
  AddObject(Image, True);
  AddObject(Accessory, True);
  AddObject(GlyphButton, IsItemEdit);  
// GlyphButton is only visible when in edit mode
end;
 
constructor TMultiDetailHorzDeleteAppearance.Create;
begin
  inherited;
  GlyphButton.DefaultValues.ButtonType := cDefaultGlyph;
  GlyphButton.DefaultValues.Visible := True;
  GlyphButton.RestoreDefaults;
end;
 
constructor TMultiDetailShowCheckAppearance.Create;
begin
  inherited;
  GlyphButton.DefaultValues.ButtonType := cDefaultGlyph;
  GlyphButton.DefaultValues.Visible := True;
  GlyphButton.RestoreDefaults;
end;
 
function TMultiDetailHorzItemAppearance.DefaultHeight: Integer;
begin
  Result := cDefaultHeight;
end;
 
destructor TMultiDetailHorzItemAppearance.Destroy;
begin
  FMultiDetail1.Free;
  FMultiDetail2.Free;
  FMultiDetail3.Free;
  inherited;
end;
 
procedure TMultiDetailHorzItemAppearance.SetMultiDetail1(
  const Value: TTextObjectAppearance);
begin
  FMultiDetail1.Assign(Value);
end;
 
procedure TMultiDetailHorzItemAppearance.SetMultiDetail2(
  const Value: TTextObjectAppearance);
begin
  FMultiDetail2.Assign(Value);
end;
 
procedure TMultiDetailHorzItemAppearance.SetMultiDetail3(
  const Value: TTextObjectAppearance);
begin
  FMultiDetail3.Assign(Value);
end;
 
procedure TMultiDetailHorzItemAppearance.SetObjectData(
  const AListViewItem: TListViewItem; const AIndex: string;
  const AValue: TValue; var AHandled: Boolean);
begin
  inherited;
 
end;
 
function TMultiDetailHorzItemAppearance.GetGroupClass: TPresetItemObjects.TGroupClass;
begin
  Result := TMultiDetailHorzItemAppearance;
end;
 
procedure TMultiDetailHorzItemAppearance.UpdateSizes;
const
    
// Total Rate = 1.0
    TextWidthRate = 0.4;
    Det1WidthRate = 0.2;
    Det2WidthRate = 0.2;
    Det3WidthRate = 0.2;
 
var
  LOuterHeight: Single;
  LOuterWidth: Single;
  LInternalWidth: Single;
  LImagePlaceOffset: Single;
  LImageTextPlaceOffset: Single;
begin
  BeginUpdate;
  try
    inherited;
 
    
// Update the widths and positions of renderening objects within a TListViewItem
    LOuterHeight := Height - Owner.ItemSpaces.Top - Owner.ItemSpaces.Bottom;
    LOuterWidth := Owner.Width - Owner.ItemSpaces.Left - Owner.ItemSpaces.Right;
    Text.InternalPlaceOffset.X :=
      Image.ActualPlaceOffset.X +  Image.ActualWidth + LImageTextPlaceOffset;
 
    LInternalWidth := (LOuterWidth - Text.ActualPlaceOffset.X - Accessory.ActualWidth);
    if Accessory.ActualWidth > 0 then
      LInternalWidth := LInternalWidth - cTextMarginAccessory;
    Text.InternalWidth := Max(1, LInternalWidth * TextWidthRate);
 
    MultiDetail1.InternalWidth := LInternalWidth * Det1WidthRate;
    MultiDetail1.InternalPlaceOffset.X := Text.InternalPlaceOffset.X + Text.InternalWidth;
    MultiDetail2.InternalWidth := LInternalWidth * Det2WidthRate;
    MultiDetail2.InternalPlaceOffset.X := MultiDetail1.InternalPlaceOffset.X + MultiDetail1.InternalWidth;
    MultiDetail3.InternalWidth := LInternalWidth * Det3WidthRate;
    MultiDetail3.InternalPlaceOffset.X := MultiDetail2.InternalPlaceOffset.X + MultiDetail2.InternalWidth;
  finally
    EndUpdate;
  end;
end;
 
type
  TOption = TCustomListView.TRegisterAppearanceOption;
const
  sThisUnit = 'MultiDetailHorzAppearanceU';     
// Will be added to the uses list when appearance is used
initialization
  
// MultiDetailItem group
  TCustomListView.RegisterAppearance(
    TMultiDetailHorzItemAppearance, TMultiDetailHorzAppearanceNames.ListItem,
    [TOption.Item], sThisUnit);
  TCustomListView.RegisterAppearance(
    TMultiDetailHorzDeleteAppearance, TMultiDetailHorzAppearanceNames.ListItemDelete,
    [TOption.ItemEdit], sThisUnit);
  TCustomListView.RegisterAppearance(
    TMultiDetailShowCheckAppearance, TMultiDetailHorzAppearanceNames.ListItemCheck,
    [TOption.ItemEdit], sThisUnit);
finalization
  TCustomListView.UnregisterAppearances(
    TArray<tcustomlistview.titemappearanceobjectsclass>.Create(
      TMultiDetailHorzItemAppearance, TMultiDetailHorzDeleteAppearance,
      TMultiDetailShowCheckAppearance));
end.