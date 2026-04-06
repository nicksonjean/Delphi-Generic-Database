{
  Options.Integer.
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

unit Options.Integer;

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
  Connection,
  Connector.Types,
  Connector
  ;

type
  TOptionsInteger = class(TConnector)
  private
    class procedure AddItem<T>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []);
  public
    class procedure AddToEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
    class procedure AddToComboEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
    class procedure AddToComboBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
    class procedure AddToListBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
    class procedure AddToGrid<T: Class>(AOwner: TComponent; DataSet: TDataSet; Options: Integer = -1);
    class procedure AddToStringGrid<T: Class>(AOwner: TComponent; DataSet: TDataSet; Options: Integer = -1);
    class procedure AddToListView<T: Class>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []; Options: Integer = -1);
  end;

implementation

{ TOptionsInteger }

class procedure TOptionsInteger.AddItem<T>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []);
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

class procedure TOptionsInteger.AddToEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
begin
  TEdit(AOwner).Items.BeginUpdate;
  try
    TEdit(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(TEdit(AOwner), IndexValue[1]));

    if Options <> -1 then
    begin
      if TEdit(AOwner).Items.IndexOf(IndexValue[0]) = Options then
        TEdit(AOwner).ItemIndex := Options;
    end;

  finally
    TEdit(AOwner).Items.EndUpdate;
  end;
end;

class procedure TOptionsInteger.AddToComboEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
var
  LB: TCustomListBox;
  Item: TListBoxItem;
begin
  TComboEdit(AOwner).Items.BeginUpdate;
  try
    TComboEdit(AOwner).Items.Add(IndexValue[0]);

    if Options <> -1 then
    begin
      if TComboEdit(AOwner).Items.IndexOf(IndexValue[0]) = Options then
        TComboEdit(AOwner).ItemIndex := Options;
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

class procedure TOptionsInteger.AddToComboBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
var
  LB: TCustomListBox;
  Item: TListBoxItem;
begin
  TComboBox(AOwner).Items.BeginUpdate;
  try
    TComboBox(AOwner).Items.Add(IndexValue[0]);

    if Options <> -1 then
    begin
      if TComboBox(AOwner).Items.IndexOf(IndexValue[0]) = Options then
        TComboBox(AOwner).ItemIndex := Options;
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

class procedure TOptionsInteger.AddToListBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
var
  Item: TListBoxItem;
begin
  TListBox(AOwner).Items.BeginUpdate;
  try
    TListBox(AOwner).Items.Add(IndexValue[0]);

    if Options <> -1 then
    begin
      if TListBox(AOwner).Items.IndexOf(IndexValue[0]) = Options then
        TListBox(AOwner).ItemIndex := Options;
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

class procedure TOptionsInteger.AddToGrid<T>(AOwner: TComponent; DataSet: TDataSet; Options: Integer = -1);
begin
  if (TypeInfo(T) = TypeInfo(TGrid)) then
  begin
    TGrid(AOwner).Options := [TGridOption.AlternatingRowBackground, TGridOption.RowSelect, TGridOption.ColumnResize, TGridOption.ColumnMove, TGridOption.ColLines, TGridOption.RowLines, TGridOption.Tabs, TGridOption.Header, TGridOption.HeaderClick, TGridOption.AutoDisplacement];
    TGrid(AOwner).FillData := DataSet;
    TGrid(AOwner).AutoSizeColumns := True;

    if Options <> -1 then
    begin
      TGrid(AOwner).Row := Options;
      TGrid(AOwner).Col := 0;
    end;
    if TGrid(AOwner).Model <> nil then
      TGrid(AOwner).Model.ClearCache;
  end;
end;

class procedure TOptionsInteger.AddToStringGrid<T>(AOwner: TComponent; DataSet: TDataSet; Options: Integer = -1);
begin
  if (TypeInfo(T) = TypeInfo(TStringGrid)) then
  begin
    TStringGrid(AOwner).Options := [TGridOption.AlternatingRowBackground, TGridOption.RowSelect, TGridOption.ColumnResize, TGridOption.ColumnMove, TGridOption.ColLines, TGridOption.RowLines, TGridOption.Tabs, TGridOption.Header, TGridOption.HeaderClick, TGridOption.AutoDisplacement];
    TStringGrid(AOwner).FillData := DataSet;
    TStringGrid(AOwner).AutoSizeColumns := True;

    if Options <> -1 then
    begin
      TStringGrid(AOwner).Row := Options;
      TStringGrid(AOwner).Col := 0;
    end;
  end;
end;

class procedure TOptionsInteger.AddToListView<T>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []; Options: Integer = -1);
begin
  if (TypeInfo(T) = TypeInfo(TListView)) then
  begin
    TListView(AOwner).BeginUpdate;
    try

      TOptionsInteger.AddItem<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields);

      if Options <> -1 then
        TListView(AOwner).ItemIndex := Options;

    finally
      TListView(AOwner).EndUpdate;
    end;
  end;
end;

end.