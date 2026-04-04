{
  OptionsJSON.
  ------------------------------------------------------------------------------
  Objetivo : Conectar o Objeto TQuery aos Componentes TGrid, TStringGrid,
  TListBox, TListView, TComboBox, TComboEdit e TEdit.
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  ------------------------------------------------------------------------------
  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la
  sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela
  Free Software Foundation; tanto a vers�o 3.29 da Licen�a, ou (a seu crit�rio)
  qualquer vers�o posterior.
  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM
  NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU
  ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor
  do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)
  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto
  com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,
  no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.
  Voc� tamb�m pode obter uma copia da licen�a em:
  http://www.opensource.org/licenses/lgpl-license.php
}

unit OptionsJSON;

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
  DictionaryHelper,
  ArrayHelper,
  EventDriven,
  Connection,
  Connector
  ;

  { Classe TConnector Herdade de TQuery }
type
  TOptionsJSON = class(TConnector)
  private
    class procedure AddItem<T>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []);
  public
    class procedure AddToEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
    class procedure AddToComboEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
    class procedure AddToComboBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
    class procedure AddToListBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
    class procedure AddToGrid<T: Class>(AOwner: TComponent; DataSet: TDataSet; Options: String = '');
    class procedure AddToStringGrid<T: Class>(AOwner: TComponent; DataSet: TDataSet; Options: String = '');
    class procedure AddToListView<T: Class>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []; Options: String = '');
  end;

implementation

{ TOptionsJSON }

class procedure TOptionsJSON.AddItem<T>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []);
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

class procedure TOptionsJSON.AddToEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
var
  JSONPairs, JSONField : Integer;
  JSONObject, JSONFields, JSONPagination, JSONNavigation : TJSONObject;
begin
  TEdit(AOwner).Items.BeginUpdate;
  try
    TEdit(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(TEdit(AOwner), IndexValue[1]));

    if Options <> EmptyStr then
    begin
      JSONObject := nil;
      try
        JSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Options), 0) as TJSONObject;
        if JSONObject <> nil then
        begin
          for JSONPairs := 0 to JSONObject.Count - 1 do
          begin
            if JSONObject.Pairs[JSONPairs].JsonString.Value = 'Index' then
            begin
              if TEdit(AOwner).Items.IndexOf(IndexValue[0]) = StrToInt(JSONObject.GetValue('Index').Value) then
                TEdit(AOwner).ItemIndex := StrToInt(JSONObject.GetValue('Index').Value);
            end
            else if JSONObject.Pairs[JSONPairs].JsonString.Value = 'Field' then
            begin
              JSONFields := JSONObject.Get('Field').JsonValue as TJSONObject;
              for JSONField := 0 to JSONFields.Count - 1 do
              begin
                if JSONFields.Pairs[JSONField].JsonString.Value = FieldIndexValue[0] then
                begin
                  if IndexValue[1] = JSONFields.Pairs[JSONField].JsonValue.Value then
                    TEdit(AOwner).ItemIndex := TEdit(AOwner).Items.IndexOf(IndexValue[0]);
                end
                else if JSONFields.Pairs[JSONField].JsonString.Value = FieldIndexValue[1] then
                begin
                  if IndexValue[0] = JSONFields.Pairs[JSONField].JsonValue.Value then
                    TEdit(AOwner).ItemIndex := TEdit(AOwner).Items.IndexOf(IndexValue[0]);
                end;
              end;
            end;
          end;
        end;
      finally
        JSONObject.Free;
      end;
    end;

  finally
    TEdit(AOwner).Items.EndUpdate;
  end;
end;

class procedure TOptionsJSON.AddToComboEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
var
  I, J : Integer;
  JSONObject, JSONFields, JSONPagination, JSONNavigation : TJSONObject;
  LB: TCustomListBox;
  Item: TListBoxItem;
begin
  TComboEdit(AOwner).Items.BeginUpdate;
  try
    TComboEdit(AOwner).Items.Add(IndexValue[0]);

    if Options <> EmptyStr then
    begin
      JSONObject := nil;
      try
        JSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Options), 0) as TJSONObject;
        if JSONObject <> nil then
        begin
          for I := 0 to JSONObject.Count - 1 do
          begin
            if JSONObject.Pairs[I].JsonString.Value = 'Index' then
            begin
              if TComboEdit(AOwner).Items.IndexOf(IndexValue[0]) = StrToInt(JSONObject.GetValue('Index').Value) then
                TComboEdit(AOwner).ItemIndex := StrToInt(JSONObject.GetValue('Index').Value);
            end
            else if JSONObject.Pairs[I].JsonString.Value = 'Field' then
            begin
              JSONFields := JSONObject.Get('Field').JsonValue as TJSONObject;
              for J := 0 to JSONFields.Count - 1 do
              begin
                if JSONFields.Pairs[J].JsonString.Value = FieldIndexValue[0] then
                begin
                  if IndexValue[1] = JSONFields.Pairs[J].JsonValue.Value then
                    TComboEdit(AOwner).ItemIndex := TComboEdit(AOwner).Items.IndexOf(IndexValue[0]);
                end
                else if JSONFields.Pairs[J].JsonString.Value = FieldIndexValue[1] then
                begin
                  if IndexValue[0] = JSONFields.Pairs[J].JsonValue.Value then
                    TComboEdit(AOwner).ItemIndex := TComboEdit(AOwner).Items.IndexOf(IndexValue[0]);
                end;
              end;
            end;
          end;
        end;
      finally
        JSONObject.Free;
      end;
    end;

  finally
    TComboEdit(AOwner).Items.EndUpdate;
  end;
  { TValueObject criado com o TListBoxItem como Owner: liberado automaticamente pelo FMX ao destruir o item. }
  LB := TComboEdit(AOwner).ListBox;
  if (LB <> nil) and (TComboEdit(AOwner).Count > 0) then
  begin
    Item := LB.ListItems[TComboEdit(AOwner).Count - 1];
    Item.Data := TValueObject.Create(Item, IndexValue[1]);
  end;
end;

class procedure TOptionsJSON.AddToComboBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
var
  JSONPairs, JSONField : Integer;
  JSONObject, JSONFields, JSONPagination, JSONNavigation : TJSONObject;
  LB: TCustomListBox;
  Item: TListBoxItem;
begin
  TComboBox(AOwner).Items.BeginUpdate;
  try
    TComboBox(AOwner).Items.Add(IndexValue[0]);

    if Options <> EmptyStr then
    begin
      JSONObject := nil;
      try
        JSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Options), 0) as TJSONObject;
        if JSONObject <> nil then
        begin
          for JSONPairs := 0 to JSONObject.Count - 1 do
          begin
            if JSONObject.Pairs[JSONPairs].JsonString.Value = 'Index' then
            begin
              if TComboBox(AOwner).Items.IndexOf(IndexValue[0]) = StrToInt(JSONObject.GetValue('Index').Value) then
                TComboBox(AOwner).ItemIndex := StrToInt(JSONObject.GetValue('Index').Value);
            end
            else if JSONObject.Pairs[JSONPairs].JsonString.Value = 'Field' then
            begin
              JSONFields := JSONObject.Get('Field').JsonValue as TJSONObject;
              for JSONField := 0 to JSONFields.Count - 1 do
              begin
                if JSONFields.Pairs[JSONField].JsonString.Value = FieldIndexValue[0] then
                begin
                  if IndexValue[1] = JSONFields.Pairs[JSONField].JsonValue.Value then
                    TComboBox(AOwner).ItemIndex := TComboBox(AOwner).Items.IndexOf(IndexValue[0]);
                end
                else if JSONFields.Pairs[JSONField].JsonString.Value = FieldIndexValue[1] then
                begin
                  if IndexValue[0] = JSONFields.Pairs[JSONField].JsonValue.Value then
                    TComboBox(AOwner).ItemIndex := TComboBox(AOwner).Items.IndexOf(IndexValue[0]);
                end;
              end;
            end;
          end;
        end;
      finally
        JSONObject.Free;
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

class procedure TOptionsJSON.AddToListBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
var
  JSONPairs, JSONField : Integer;
  JSONObject, JSONFields, JSONPagination, JSONNavigation : TJSONObject;
  Item: TListBoxItem;
begin
  TListBox(AOwner).Items.BeginUpdate;
  try
    TListBox(AOwner).Items.Add(IndexValue[0]);

    if Options <> EmptyStr then
    begin
      JSONObject := nil;
      try
        JSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Options), 0) as TJSONObject;
        if JSONObject <> nil then
        begin
          for JSONPairs := 0 to JSONObject.Count - 1 do
          begin
            if JSONObject.Pairs[JSONPairs].JsonString.Value = 'Index' then
            begin
              if TListBox(AOwner).Items.IndexOf(IndexValue[0]) = StrToInt(JSONObject.GetValue('Index').Value) then
                TListBox(AOwner).ItemIndex := StrToInt(JSONObject.GetValue('Index').Value);
            end
            else if JSONObject.Pairs[JSONPairs].JsonString.Value = 'Field' then
            begin
              JSONFields := JSONObject.Get('Field').JsonValue as TJSONObject;
              for JSONField := 0 to JSONFields.Count - 1 do
              begin
                if JSONFields.Pairs[JSONField].JsonString.Value = FieldIndexValue[0] then
                begin
                  if IndexValue[1] = JSONFields.Pairs[JSONField].JsonValue.Value then
                    TListBox(AOwner).ItemIndex := TListBox(AOwner).Items.IndexOf(IndexValue[0]);
                end
                else if JSONFields.Pairs[JSONField].JsonString.Value = FieldIndexValue[1] then
                begin
                  if IndexValue[0] = JSONFields.Pairs[JSONField].JsonValue.Value then
                    TListBox(AOwner).ItemIndex := TListBox(AOwner).Items.IndexOf(IndexValue[0]);
                end;
              end;
            end;
          end;
        end;
      finally
        JSONObject.Free;
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

class procedure TOptionsJSON.AddToGrid<T>(AOwner: TComponent; DataSet: TDataSet; Options: String = '');
var
  Row, Column: Integer;
  JSONPairs, JSONField : Integer;
  JSONObject, JSONFields, JSONPagination, JSONNavigation : TJSONObject;
begin
  TGrid(AOwner).Options := [TGridOption.AlternatingRowBackground, TGridOption.RowSelect, TGridOption.ColumnResize, TGridOption.ColumnMove, TGridOption.ColLines, TGridOption.RowLines, TGridOption.Tabs, TGridOption.Header, TGridOption.HeaderClick, TGridOption.AutoDisplacement];
  TGrid(AOwner).FillData := DataSet;
  TGrid(AOwner).AutoSizeColumns := True;

  if Options <> EmptyStr then
  begin
    JSONObject := nil;
    try
      JSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Options), 0) as TJSONObject;
      if JSONObject <> nil then
      begin
        for JSONPairs := 0 to JSONObject.Count - 1 do
        begin
          if JSONObject.Pairs[JSONPairs].JsonString.Value = 'Index' then
          begin
            for Row := 0 to TGrid(AOwner).RowCount - 1 do
            begin
              if (Row = StrToInt(JSONObject.GetValue('Index').Value)) then
              begin
                TGrid(AOwner).Row := StrToInt(JSONObject.GetValue('Index').Value);
                TGrid(AOwner).Col := 0;
                Break;
              end;
            end;
          end
          else if JSONObject.Pairs[JSONPairs].JsonString.Value = 'Field' then
          begin
            JSONFields := JSONObject.Get('Field').JsonValue as TJSONObject;
            for JSONField := 0 to JSONFields.Count - 1 do
            begin
              for Column := 0 to TGrid(AOwner).ColumnCount - 1 do
              begin
                if TGrid(AOwner).ColumnByIndex(Column).Header = JSONFields.Pairs[JSONField].JsonString.Value then
                begin
                  Row := 0;
                  if not DataSet.Active then
                    DataSet.Open;
                  DataSet.First;
                  while not DataSet.Eof do
                  begin
                    if DataSet.Fields[Column].AsString = JSONFields.Pairs[JSONField].JsonValue.Value then
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
      end;
    finally
      JSONObject.Free;
    end;
  end;

  if TGrid(AOwner).Model <> nil then
    TGrid(AOwner).Model.ClearCache;

end;

class procedure TOptionsJSON.AddToStringGrid<T>(AOwner: TComponent; DataSet: TDataSet; Options: String = '');
var
  Row, Column: Integer;
  JSONPairs, JSONField : Integer;
  JSONObject, JSONFields, JSONPagination, JSONNavigation : TJSONObject;
begin
  TStringGrid(AOwner).Options := [TGridOption.AlternatingRowBackground, TGridOption.RowSelect, TGridOption.ColumnResize, TGridOption.ColumnMove, TGridOption.ColLines, TGridOption.RowLines, TGridOption.Tabs, TGridOption.Header, TGridOption.HeaderClick, TGridOption.AutoDisplacement];
  TStringGrid(AOwner).FillData := DataSet;
  TStringGrid(AOwner).AutoSizeColumns := True;

  if Options <> EmptyStr then
  begin
    JSONObject := nil;
    try
      JSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Options), 0) as TJSONObject;
      if JSONObject <> nil then
      begin
        for JSONPairs := 0 to JSONObject.Count - 1 do
        begin
          if JSONObject.Pairs[JSONPairs].JsonString.Value = 'Index' then
          begin
            for Row := 0 to TStringGrid(AOwner).RowCount - 1 do
            begin
              if (Row = StrToInt(JSONObject.GetValue('Index').Value)) then
              begin
                TStringGrid(AOwner).Row := StrToInt(JSONObject.GetValue('Index').Value);
                TStringGrid(AOwner).Col := 0;
                Break;
              end;
            end;
          end
          else if JSONObject.Pairs[JSONPairs].JsonString.Value = 'Field' then
          begin
            JSONFields := JSONObject.Get('Field').JsonValue as TJSONObject;
            for JSONField := 0 to JSONFields.Count - 1 do
            begin
              for Column := 0 to TStringGrid(AOwner).ColumnCount - 1 do
              begin
                if TStringGrid(AOwner).ColumnByIndex(Column).Header = JSONFields.Pairs[JSONField].JsonString.Value then
                begin
                  Row := 0;
                  if not DataSet.Active then
                    DataSet.Open;
                  DataSet.First;
                  while not DataSet.Eof do
                  begin
                    if DataSet.Fields[Column].AsString = JSONFields.Pairs[JSONField].JsonValue.Value then
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
    finally
      JSONObject.Free;
    end;
  end;

end;

class procedure TOptionsJSON.AddToListView<T>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []; Options: String = '');
var
  Row, Column: Integer;
  JSONString: String;
  JSONDataObject, JSONDataBase: TJSONObject;
  JSONPairs, JSONField : Integer;
  JSONObject, JSONFields, JSONPagination, JSONNavigation : TJSONObject;
begin
  TListView(AOwner).BeginUpdate;
  try
    TOptionsJSON.AddItem<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields);

    if Options <> EmptyStr then
    begin
      JSONObject := nil;
      try
        JSONObject := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(Options), 0) as TJSONObject;
        if JSONObject <> nil then
        begin
          for JSONPairs := 0 to JSONObject.Count - 1 do
          begin
            if JSONObject.Pairs[JSONPairs].JsonString.Value = 'Index' then
            begin
              for Row := 0 to TListView(AOwner).Items.Count - 1 do
              begin
                if (Row = StrToInt(JSONObject.GetValue('Index').Value)) then
                begin
                  TListView(AOwner).ItemIndex := StrToInt(JSONObject.GetValue('Index').Value);
                  Break;
                end;
              end;
            end
            else if JSONObject.Pairs[JSONPairs].JsonString.Value = 'Field' then
            begin
              JSONFields := JSONObject.Get('Field').JsonValue as TJSONObject;
              for JSONField := 0 to JSONFields.Count - 1 do
              begin
                for Row := 0 to TListView(AOwner).Items.Count - 1 do
                begin
                  JSONString := TListView(AOwner).Items.AppearanceItem[Row].Objects.FindObjectT<TListItemText>(TMultiDetailAppearanceNames.Detail4).Text;
                  JSONDataObject := nil;
                  try
                    JSONDataObject := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JSONString), 0) as TJSONObject;
                    if (JSONDataObject <> nil) and (JSONDataObject.Get('ValueField') <> nil) and
                      (JSONDataObject.Get('ValueField').JsonValue.Value = JSONFields.Pairs[JSONField].JsonString.Value) then
                    begin
                      TListView(AOwner).ItemIndex := TListView(AOwner).FindItemByValue(JSONFields.Pairs[JSONField].JsonValue.Value);
                      Break;
                    end
                    else if JSONDataObject <> nil then
                    begin
                      JSONDataBase := JSONDataObject.Get('DataFields').JsonValue as TJSONObject;
                      if JSONDataBase <> nil then
                      begin
                        for Column := 0 to JSONDataBase.Count - 1 do
                        begin
                          if JSONDataBase.Pairs[Column].JsonValue.Value = JSONFields.Pairs[JSONField].JsonValue.Value then
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
        end;
      finally
        JSONObject.Free;
      end;
    end;

  finally
    TListView(AOwner).EndUpdate;
  end;
end;

end.
