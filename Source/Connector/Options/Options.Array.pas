{
  Options.Array.
  ------------------------------------------------------------------------------
  Objetivo : Conectar o Objeto TQuery aos Componentes TGrid, TStringGrid,
  TListBox, TListView, TComboBox, TComboEdit e TEdit.
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

unit Options.&Array;

interface

uses
  System.SysUtils,
  System.IOUtils,
  System.StrUtils,
  System.DateUtils,
  System.Classes,
  System.Math,
  System.SyncObjs,
  System.Threading,
  System.Generics.Collections,
  System.RTLConsts,
  System.Variants,
  System.JSON,
  System.RTTI,
  System.TypInfo,
  System.Types,
  System.UITypes,

  FMX.Styles.Objects,
  FMX.Consts,
  FMX.Types,
  FMX.Grid,
  FMX.ComboEdit,
  FMX.ListBox,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.SearchBox,
  FMX.StdCtrls,
  FMX.Controls,
  FMX.Graphics,
  FMX.Layouts,
  FMX.Objects,
  FMX.Pickers,
  FMX.Edit,
  FMX.Edit.Style,
  FMX.Controls.Presentation,
  Data.DB,
  FMX.Dialogs,

  FMX.ListView.Extension,
  FMX.Edit.Extension,
  FMX.Edit.Helper,
  FMX.ListView.Helper,
  FMX.ListBox.Helper,
  FMX.StringGrid.Helper,
  FMX.Grid.Helper,
  FMX.ComboEdit.Helper,
  FMX.ComboBox.Helper,
  &Type.Dictionary.Helper,
  &Type.&Array.Helper,
  Connection,
  Connector.Types,
  Connector
  ;

type
  TOptionsArray = class(TConnector)
  private
    class procedure AddItem<T>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []);
  public
    class procedure AddToEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
    class procedure AddToComboEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
    class procedure AddToComboBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
    class procedure AddToListBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
    class procedure AddToGrid<T: Class>(AOwner: TComponent; DataSet: TDataSet; Options: TDictionary<String, TArray<Variant>> = nil);
    class procedure AddToStringGrid<T: Class>(AOwner: TComponent; DataSet: TDataSet; Options: TDictionary<String, TArray<Variant>> = nil);
    class procedure AddToListView<T: Class>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []; Options: TDictionary<String, TArray<Variant>> = nil);
  end;

implementation

{ TOptionsArray }

class procedure TOptionsArray.AddItem<T>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []);
var
  JSONItem : TJSONItem;
begin
  JSONItem := TJSONItem.Create;
  try
    JSONItem.AddItem<T>(AOwner, DataSet, IndexField, ValueField, DetailFields);
  finally
    JSONItem.Free;
  end;
end;

class procedure TOptionsArray.AddToEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
var
  Pair: TPair<String, TArray<Variant>>;
begin
  TEdit(AOwner).Items.BeginUpdate;
  try
    TEdit(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(TEdit(AOwner), IndexValue[1]));

    if Options <> nil then
    begin
      for Pair in Options do
      begin
        if Pair.Key = 'Index' then
        begin
          if TEdit(AOwner).Items.IndexOf(IndexValue[0]) = Pair.Value[0] then
            TEdit(AOwner).ItemIndex := Pair.Value[0];
        end
        else if Pair.Key = 'Field' then
        begin
          if Pair.Value[0] = FieldIndexValue[0] then
          begin
            if IndexValue[1] = Pair.Value[1] then
              TEdit(AOwner).ItemIndex := TEdit(AOwner).Items.IndexOf(IndexValue[0]);
          end
          else if Pair.Value[0] = FieldIndexValue[1] then
          begin
            if IndexValue[0] = Pair.Value[1] then
              TEdit(AOwner).ItemIndex := TEdit(AOwner).Items.IndexOf(IndexValue[0]);
          end;
        end;
      end;
    end;

  finally
    TEdit(AOwner).Items.EndUpdate;
  end;
end;

class procedure TOptionsArray.AddToComboEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
var
  Pair: TPair<String, TArray<Variant>>;
  LB: TCustomListBox;
  Item: TListBoxItem;
begin
  TComboEdit(AOwner).Items.BeginUpdate;
  try
    TComboEdit(AOwner).Items.Add(IndexValue[0]);

    if Options <> nil then
    begin
      for Pair in Options do
      begin
        if Pair.Key = 'Index' then
        begin
          if TComboEdit(AOwner).Items.IndexOf(IndexValue[0]) = Pair.Value[0] then
            TComboEdit(AOwner).ItemIndex := Pair.Value[0];
        end
        else if Pair.Key = 'Field' then
        begin
          if Pair.Value[0] = FieldIndexValue[0] then
          begin
            if IndexValue[1] = Pair.Value[1] then
              TComboEdit(AOwner).ItemIndex := TComboEdit(AOwner).Items.IndexOf(IndexValue[0]);
          end
          else if Pair.Value[0] = FieldIndexValue[1] then
          begin
            if IndexValue[0] = Pair.Value[1] then
              TComboEdit(AOwner).ItemIndex := TComboEdit(AOwner).Items.IndexOf(IndexValue[0]);
          end;
        end;
      end;
    end;

  finally
    TComboEdit(AOwner).Items.EndUpdate;
  end;
  LB := TComboEdit(AOwner).ListBox;
  if (LB <> nil) and (TComboEdit(AOwner).Count > 0) then
  begin
    Item := LB.ListItems[TComboEdit(AOwner).Count - 1];
    Item.Data := TValueObject.Create(Item, IndexValue[1]);
  end;
end;

class procedure TOptionsArray.AddToComboBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
var
  Pair: TPair<String, TArray<Variant>>;
  LB: TCustomListBox;
  Item: TListBoxItem;
begin
  TComboBox(AOwner).Items.BeginUpdate;
  try
    TComboBox(AOwner).Items.Add(IndexValue[0]);

    if Options <> nil then
    begin
      for Pair in Options do
      begin
        if Pair.Key = 'Index' then
        begin
          if TComboBox(AOwner).Items.IndexOf(IndexValue[0]) = Pair.Value[0] then
            TComboBox(AOwner).ItemIndex := Pair.Value[0];
        end
        else if Pair.Key = 'Field' then
        begin
          if Pair.Value[0] = FieldIndexValue[0] then
          begin
            if IndexValue[1] = Pair.Value[1] then
              TComboBox(AOwner).ItemIndex := TComboBox(AOwner).Items.IndexOf(IndexValue[0]);
          end
          else if Pair.Value[0] = FieldIndexValue[1] then
          begin
            if IndexValue[0] = Pair.Value[1] then
              TComboBox(AOwner).ItemIndex := TComboBox(AOwner).Items.IndexOf(IndexValue[0]);
          end;
        end;
      end;
    end;

  finally
    TComboBox(AOwner).Items.EndUpdate;
  end;
  LB := TComboBox(AOwner).ListBox;
  if (LB <> nil) and (TComboBox(AOwner).Count > 0) then
  begin
    Item := LB.ListItems[TComboBox(AOwner).Count - 1];
    Item.Data := TValueObject.Create(Item, IndexValue[1]);
  end;
end;

class procedure TOptionsArray.AddToListBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
var
  Pair: TPair<String, TArray<Variant>>;
  Item: TListBoxItem;
begin
  TListBox(AOwner).Items.BeginUpdate;
  try
    TListBox(AOwner).Items.Add(IndexValue[0]);

    if Options <> nil then
    begin
      for Pair in Options do
      begin
        if Pair.Key = 'Index' then
        begin
          if TListBox(AOwner).Items.IndexOf(IndexValue[0]) = Pair.Value[0] then
            TListBox(AOwner).ItemIndex := Pair.Value[0];
        end
        else if Pair.Key = 'Field' then
        begin
          if Pair.Value[0] = FieldIndexValue[0] then
          begin
            if IndexValue[1] = Pair.Value[1] then
              TListBox(AOwner).ItemIndex := TListBox(AOwner).Items.IndexOf(IndexValue[0]);
          end
          else if Pair.Value[0] = FieldIndexValue[1] then
          begin
            if IndexValue[0] = Pair.Value[1] then
              TListBox(AOwner).ItemIndex := TListBox(AOwner).Items.IndexOf(IndexValue[0]);
          end;
        end;
      end;
    end;

  finally
    TListBox(AOwner).Items.EndUpdate;
  end;
  if TListBox(AOwner).Count > 0 then
  begin
    Item := TListBox(AOwner).ListItems[TListBox(AOwner).Count - 1];
    Item.Data := TValueObject.Create(Item, IndexValue[1]);
  end;
end;

class procedure TOptionsArray.AddToGrid<T>(AOwner: TComponent; DataSet: TDataSet; Options: TDictionary<String, TArray<Variant>> = nil);
var
  Row, Column: Integer;
  Pair: TPair<String, TArray<Variant>>;
begin
  TGrid(AOwner).Options := [TGridOption.AlternatingRowBackground, TGridOption.RowSelect, TGridOption.ColumnResize, TGridOption.ColumnMove, TGridOption.ColLines, TGridOption.RowLines, TGridOption.Tabs, TGridOption.Header, TGridOption.HeaderClick, TGridOption.AutoDisplacement];
  TGrid(AOwner).FillData := DataSet;
  TGrid(AOwner).AutoSizeColumns := True;

  if Options <> nil then
  begin
    for Pair in Options do
    begin
      if Pair.Key = 'Index' then
      begin
        for Row := 0 to TGrid(AOwner).RowCount - 1 do
        begin
          if (Row = Pair.Value[0]) then
          begin
            TGrid(AOwner).Row := Pair.Value[0];
            TGrid(AOwner).Col := 0;
            Break;
          end;
        end;
      end
      else if Pair.Key = 'Field' then
      begin
        for Column := 0 to TGrid(AOwner).ColumnCount - 1 do
        begin
          if TGrid(AOwner).ColumnByIndex(Column).Header = Pair.Value[0] then
          begin
            Row := 0;
            if not DataSet.Active then
              DataSet.Open;
            DataSet.First;
            while not DataSet.Eof do
            begin
              if DataSet.Fields[Column].AsString = Pair.Value[1] then
              begin
                TGrid(AOwner).Row := Row;
                TGrid(AOwner).Col := 0;
                Break;
              end;
              Inc(Row);
              DataSet.Next;
            end;
            DataSet.Last;
          end;
        end;
      end;
    end;
  end;

  if TGrid(AOwner).Model <> nil then
    TGrid(AOwner).Model.ClearCache;

end;

class procedure TOptionsArray.AddToStringGrid<T>(AOwner: TComponent; DataSet: TDataSet; Options: TDictionary<String, TArray<Variant>> = nil);
var
  Row, Column: Integer;
  Pair: TPair<String, TArray<Variant>>;
begin
  TStringGrid(AOwner).Options := [TGridOption.AlternatingRowBackground, TGridOption.RowSelect, TGridOption.ColumnResize, TGridOption.ColumnMove, TGridOption.ColLines, TGridOption.RowLines, TGridOption.Tabs, TGridOption.Header, TGridOption.HeaderClick, TGridOption.AutoDisplacement];
  TStringGrid(AOwner).FillData := DataSet;
  TStringGrid(AOwner).AutoSizeColumns := True;

  if Options <> nil then
  begin
    for Pair in Options do
    begin
      if Pair.Key = 'Index' then
      begin
        for Row := 0 to TStringGrid(AOwner).RowCount - 1 do
        begin
          if (Row = Pair.Value[0]) then
          begin
            TStringGrid(AOwner).Row := Pair.Value[0];
            TStringGrid(AOwner).Col := 0;
            Break;
          end;
        end;
      end
      else if Pair.Key = 'Field' then
      begin
        for Column := 0 to TStringGrid(AOwner).ColumnCount - 1 do
        begin
          if TStringGrid(AOwner).ColumnByIndex(Column).Header = Pair.Value[0] then
          begin
            Row := 0;
            if not DataSet.Active then
              DataSet.Open;
            DataSet.First;
            while not DataSet.Eof do
            begin
              if DataSet.Fields[Column].AsString = Pair.Value[1] then
              begin
                TStringGrid(AOwner).Row := Row;
                TStringGrid(AOwner).Col := 0;
                Break;
              end;
              Inc(Row);
              DataSet.Next;
            end;
            DataSet.Last;
          end;
        end;
      end;
    end;
  end;

end;

class procedure TOptionsArray.AddToListView<T>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []; Options: TDictionary<String, TArray<Variant>> = nil);
var
  Row, Column: Integer;
  Pair: TPair<String, TArray<Variant>>;
  JSONString: String;
  JSONDataObject, JSONDataBase: TJSONObject;
begin
  TListView(AOwner).BeginUpdate;
  try
    TOptionsArray.AddItem<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields);

    if Options <> nil then
    begin
      for Pair in Options do
      begin
        if Pair.Key = 'Index' then
        begin
          for Row := 0 to TListView(AOwner).Items.Count - 1 do
          begin
            if (Row = Pair.Value[0]) then
            begin
              TListView(AOwner).ItemIndex := Pair.Value[0];
              Break;
            end;
          end;
        end
        else if Pair.Key = 'Field' then
        begin
          for Row := 0 to TListView(AOwner).Items.Count - 1 do
          begin
            JSONString := TListView(AOwner).Items.AppearanceItem[Row].Objects.FindObjectT<TListItemText>(TMultiDetailAppearanceNames.Detail4).Text;
            JSONDataObject := nil;
            try
              JSONDataObject := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JSONString), 0) as TJSONObject;
              if (JSONDataObject <> nil) and (JSONDataObject.Get('ValueField') <> nil) and
                 (JSONDataObject.Get('ValueField').JsonValue.Value = Pair.Value[0]) then
              begin
                TListView(AOwner).ItemIndex := TListView(AOwner).FindItemByValue(Pair.Value[1]);
                Break;
              end
              else if JSONDataObject <> nil then
              begin
                JSONDataBase := JSONDataObject.Get('DataFields').JsonValue as TJSONObject;
                if JSONDataBase <> nil then
                begin
                  for Column := 0 to JSONDataBase.Count - 1 do
                  begin
                    if JSONDataBase.Pairs[Column].JsonValue.Value = Pair.Value[1] then
                    begin
                      TListView(AOwner).ItemIndex := Row;
                      Break;
                    end;
                  end;
                end;
              end;
            finally
              JSONDataObject.Free;
            end;
          end;
        end;
      end;
    end;

  finally
    TListView(AOwner).EndUpdate;
  end;
end;

end.
