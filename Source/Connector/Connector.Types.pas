unit Connector.Types;

{
  Tipos e helpers partilhados pelo Connector e pelas units Options* (TValueObject,
  TJSONItem, helpers de Options, TCustomListBoxAccess).
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  System.Variants,
  System.Generics.Collections,
  System.Types,
  System.UITypes,
  FMX.Types,
  FMX.Controls,
  FMX.ListBox,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.StdCtrls,
  FMX.Edit,
  Data.DB;

type
  TValueObject = class(TComponent)
  strict private
    FValue: TValue;
  public
    constructor Create(AOwner: TComponent; const aValue: TValue); reintroduce;
    property Value: TValue read FValue;
  end;

  TNavigationType = (Pages, Full);
  TPairArray = Array[0..1] of Variant;
  TDetailArray = Array[0..2] of Variant;

  TJSONItem = class
  private
    FJSONData: String;
  public
    const Height = 76;
    function GetJSONData: String;
    procedure SetJSONData(IndexField, ValueField, DataFields: String);
    procedure AddItem<T>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []);
  end;

  TJSONOptionsHelper = class
  public
    class function &Set(Index : Integer): String; overload;
    class function &Set(Index : Integer; Pagination: Integer = -1): String; overload;
    class function &Set(Index : Integer; Pagination: Integer = -1; Navigation: TNavigationType = TNavigationType.Pages): String; overload;
    class function &Set(Field : TArray<Variant>): String; overload;
    class function &Set(Field : TArray<Variant>; Pagination: Integer = -1): String; overload;
    class function &Set(Field : TArray<Variant>; Pagination: Integer = -1; Navigation: TNavigationType = TNavigationType.Pages): String; overload;
  end;

  TArrayOptionsHelper = class
  public
    class function &Set(Index : Integer): TDictionary<String, TArray<Variant>>; overload;
    class function &Set(Index : Integer; Pagination: Integer = -1): TDictionary<String, TArray<Variant>>; overload;
    class function &Set(Index : Integer; Pagination: Integer = -1; Navigation: TNavigationType = TNavigationType.Pages): TDictionary<String, TArray<Variant>>; overload;
    class function &Set(Field : TArray<Variant>): TDictionary<String, TArray<Variant>>; overload;
    class function &Set(Field : TArray<Variant>; Pagination: Integer = -1): TDictionary<String, TArray<Variant>>; overload;
    class function &Set(Field : TArray<Variant>; Pagination: Integer = -1; Navigation: TNavigationType = TNavigationType.Pages): TDictionary<String, TArray<Variant>>; overload;
  end;

  TCustomListBoxAccess = class(TCustomListBox)
  public
    property AlternatingRowBackground;
  end;

implementation

uses
  System.StrUtils,
  &Type.Dictionary.Helper,
  &Type.&Array.Variant,
  RTTI,
  FMX.ListView.Extension,
  EventDelegate;

{ TValueObject }

constructor TValueObject.Create(AOwner: TComponent; const aValue: TValue);
begin
  inherited Create(AOwner);
  FValue := aValue;
end;

{ TJSONItem }

function TJSONItem.GetJSONData: String;
begin
  Result := FJSONData;
end;

procedure TJSONItem.SetJSONData(IndexField, ValueField, DataFields: String);
var
  DataColumns : String;
begin
  DataColumns := '{"IndexField":"' + IndexField + '","ValueField":"' + ValueField + '","DataFields":' + DataFields + '}';
  FJSONData := DataColumns;
end;

procedure TJSONItem.AddItem<T>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []);
var
  Item: TListViewItem;
  I, ItemHeight: Integer;
  JSONData: TArrayVariant;
begin
  ItemHeight := Self.Height;
  if Length(DetailFields) > 0 then
    ItemHeight := 19 * (Length(DetailFields) + 1)
  else
    ItemHeight := 19;
  if (TypeInfo(T) = TypeInfo(TListView)) then
  begin
    JSONData := TArrayVariant.Create;
    TListView(AOwner).BeginUpdate;
    try
      if not DataSet.Active then
        DataSet.Open;
      DataSet.First;
      while not(DataSet.Eof) do
      begin
        Item := TListView(AOwner).Items.Add;
        Item.Index := DataSet.FieldByName(IndexField).AsInteger;
        Item.Text := DataSet.FieldByName(ValueField).AsString;
        Item.Height := ItemHeight;
        if Length(DetailFields) > 0 then
        begin
          if Length(DetailFields) = 1 then
          begin
            if DetailFields[0] <> EmptyStr then
              Item.Data[TMultiDetailAppearanceNames.Detail1] := DataSet.FieldByName(DetailFields[0]).AsString;
          end;
          if Length(DetailFields) = 2 then
          begin
            if DetailFields[0] <> EmptyStr then
              Item.Data[TMultiDetailAppearanceNames.Detail1] := DataSet.FieldByName(DetailFields[0]).AsString;
            if DetailFields[1] <> EmptyStr then
              Item.Data[TMultiDetailAppearanceNames.Detail2] := DataSet.FieldByName(DetailFields[1]).AsString;
          end;
          if Length(DetailFields) = 3 then
          begin
            if DetailFields[0] <> EmptyStr then
              Item.Data[TMultiDetailAppearanceNames.Detail1] := DataSet.FieldByName(DetailFields[0]).AsString;
            if DetailFields[1] <> EmptyStr then
              Item.Data[TMultiDetailAppearanceNames.Detail2] := DataSet.FieldByName(DetailFields[1]).AsString;
            if DetailFields[2] <> EmptyStr then
              Item.Data[TMultiDetailAppearanceNames.Detail3] := DataSet.FieldByName(DetailFields[2]).AsString;
          end;
        end;
        JSONData.Clear;
        for I := 0 to DataSet.FieldDefs.Count - 1 do
          JSONData[DataSet.FieldDefs[I].Name] := DataSet.FieldByName(DataSet.FieldDefs[I].Name).Value;
        Self.SetJSONData(IndexField, ValueField, JSONData.ToJSON);
        Item.Data[TMultiDetailAppearanceNames.Detail4] := Self.GetJSONData;
        DataSet.Next;
      end;
    finally
      JSONData.Free;
      TListView(AOwner).EndUpdate;
    end;
    TListView(AOwner).OnUpdateObjects := DelegateItemViewEvent(
      TListView(AOwner),
      procedure(const Sender: TObject; const AItem: TListViewItem)
      begin
        if Length(DetailFields) = 3 then
        begin
          AItem.Objects.FindObjectT<TListItemText>(TMultiDetailAppearanceNames.Detail1).PlaceOffset.Y := 0;
          AItem.Objects.FindObjectT<TListItemText>(TMultiDetailAppearanceNames.Detail2).PlaceOffset.Y := 0;
          AItem.Objects.FindObjectT<TListItemText>(TMultiDetailAppearanceNames.Detail3).PlaceOffset.Y := 0;
        end
        else if Length(DetailFields) = 2 then
        begin
          AItem.Objects.FindObjectT<TListItemText>(TMultiDetailAppearanceNames.Detail1).PlaceOffset.Y := 19;
          AItem.Objects.FindObjectT<TListItemText>(TMultiDetailAppearanceNames.Detail2).PlaceOffset.Y := 19;
          AItem.Objects.FindObjectT<TListItemText>(TMultiDetailAppearanceNames.Detail3).PlaceOffset.Y := 0;
        end
        else if Length(DetailFields) = 1 then
        begin
          AItem.Objects.FindObjectT<TListItemText>(TMultiDetailAppearanceNames.Detail1).PlaceOffset.Y := 19;
          AItem.Objects.FindObjectT<TListItemText>(TMultiDetailAppearanceNames.Detail2).PlaceOffset.Y := 0;
          AItem.Objects.FindObjectT<TListItemText>(TMultiDetailAppearanceNames.Detail3).PlaceOffset.Y := 0;
        end;
      end
    );
  end;
end;

{ TJSONOptionsHelper }

class function TJSONOptionsHelper.&Set(Index : Integer): String;
begin
  Result := '{"Index":' + IntToStr(Index) + '}';
end;

class function TJSONOptionsHelper.&Set(Index : Integer; Pagination: Integer = -1): String;
begin
  Result := '{"Index":' + IntToStr(Index) + ',"Pagination":{"ItemsPerPage":' + IntToStr(Pagination) + '}}';
end;

class function TJSONOptionsHelper.&Set(Index : Integer; Pagination: Integer = -1; Navigation: TNavigationType = TNavigationType.Pages): String;
begin
  Result := '{"Index":' + IntToStr(Index) + ',"Pagination":{"ItemsPerPage":' + IntToStr(Pagination) + '},"Navigation":{"Type":"' + TEnumConverter.EnumToString(Navigation) + '"}}';
end;

class function TJSONOptionsHelper.&Set(Field : TArray<Variant>): String;
begin
  Result := '{"Field":{"' + VarToStr(Field[0]) + '":' +  VarToStr(Field[1]) + '}}';
end;

class function TJSONOptionsHelper.&Set(Field : TArray<Variant>; Pagination: Integer = -1): String;
begin
  Result := '{"Field":{"' + VarToStr(Field[0]) + '":' +  VarToStr(Field[1]) + '},"Pagination":{"ItemsPerPage":' + IntToStr(Pagination) + '}}';
end;

class function TJSONOptionsHelper.&Set(Field : TArray<Variant>; Pagination: Integer = -1; Navigation: TNavigationType = TNavigationType.Pages): String;
begin
  Result := '{"Field":{"' + VarToStr(Field[0]) + '":' +  VarToStr(Field[1]) + '},"Pagination":{"ItemsPerPage":' + IntToStr(Pagination) + '},"Navigation":{"Type":"' + TEnumConverter.EnumToString(Navigation) + '"}}';
end;

{ TArrayOptionsHelper }

class function TArrayOptionsHelper.&Set(Index : Integer): TDictionary<String, TArray<Variant>>;
begin
  Result := TDictionaryHelper<String, TArray<Variant>>.Make(['Index'], [[Index]]);
end;

class function TArrayOptionsHelper.&Set(Index : Integer; Pagination: Integer = -1): TDictionary<String, TArray<Variant>>;
begin
  Result := TDictionaryHelper<String, TArray<Variant>>.Make(['Index', 'Pagination'], [[Index], ['ItemsPerPage',IntToStr(Pagination)]]);
end;

class function TArrayOptionsHelper.&Set(Index : Integer; Pagination: Integer = -1; Navigation: TNavigationType = TNavigationType.Pages): TDictionary<String, TArray<Variant>>;
begin
  Result := TDictionaryHelper<String, TArray<Variant>>.Make(['Index', 'Pagination', 'Navigation'], [[Index], ['ItemsPerPage', Pagination], ['Type', Navigation]]);
end;

class function TArrayOptionsHelper.&Set(Field : TArray<Variant>): TDictionary<String, TArray<Variant>>;
begin
  Result := TDictionaryHelper<String, TArray<Variant>>.Make(['Field'], [[Field[0], Field[1]]]);
end;

class function TArrayOptionsHelper.&Set(Field : TArray<Variant>; Pagination: Integer = -1): TDictionary<String, TArray<Variant>>;
begin
  Result := TDictionaryHelper<String, TArray<Variant>>.Make(['Field', 'Pagination'], [[Field[0], Field[1]], ['ItemsPerPage', Pagination]]);
end;

class function TArrayOptionsHelper.&Set(Field : TArray<Variant>; Pagination: Integer = -1; Navigation: TNavigationType = TNavigationType.Pages): TDictionary<String, TArray<Variant>>;
begin
  Result := TDictionaryHelper<String, TArray<Variant>>.Make(['Field', 'Pagination', 'Navigation'], [[Field[0], Field[1]], ['ItemsPerPage', Pagination], ['Type', Navigation]]);
end;

end.
