{
  OptionsArray.
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

unit OptionsArray;

interface

{ Carrega as Variáveis Padrão }
{$I CNC.Default.inc}

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

{$IFDEF FireDACLib}
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
{$ENDIF}
{$IF DEFINED(dbExpressLib) OR DEFINED(ZeOSLib)}
  Datasnap.Provider,
  Datasnap.DBClient,
  Data.FMTBcd,
  Data.SqlExpr,
{$ENDIF}
{$IFDEF ZeOSLib}
  ZAbstractConnection,
  ZConnection,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
{$ENDIF}

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

  { Classe TOptionsArray Herdade de TConnector }
type
  TOptionsArray = class(TConnector)
  private
    { Public declarations }
    procedure AddItem<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []);
  public
    { Public declarations }
    procedure AddToEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
    procedure AddToComboEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
    procedure AddToComboBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
    procedure AddToListBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
    procedure AddToGrid<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: TDictionary<String, TArray<Variant>> = nil);
    procedure AddToStringGrid<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: TDictionary<String, TArray<Variant>> = nil);
    procedure AddToListView<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []; Options: TDictionary<String, TArray<Variant>> = nil);
  end;

var
  InstanceOptionsArray : TOptionsArray;

implementation

{ TOptionsArray }

procedure TOptionsArray.AddItem<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []);
var
  JSONItem : TJSONItem;
begin
  JSONItem := TJSONItem.Create;
  JSONItem.AddItem<T>(AOwner, DataSet, IndexField, ValueField, DetailFields);
  JSONItem.Destroy;
end;

procedure TOptionsArray.AddToEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
var
  Pair: TPair<String, TArray<Variant>>;
begin
  TEdit(AOwner).Items.BeginUpdate;
  try
    TEdit(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));

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

procedure TOptionsArray.AddToComboEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
var
  Pair: TPair<String, TArray<Variant>>;
begin
  TComboEdit(AOwner).Items.BeginUpdate;
  try
    TComboEdit(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));

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
end;

procedure TOptionsArray.AddToComboBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
var
  Pair: TPair<String, TArray<Variant>>;
begin
  TComboBox(AOwner).Items.BeginUpdate;
  try
    TComboBox(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));

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
end;

procedure TOptionsArray.AddToListBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: TDictionary<String, TArray<Variant>> = nil);
var
  Pair: TPair<String, TArray<Variant>>;
begin
  TListBox(AOwner).Items.BeginUpdate;
  try
    TListBox(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));

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
end;

procedure TOptionsArray.AddToGrid<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: TDictionary<String, TArray<Variant>> = nil);
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

end;

procedure TOptionsArray.AddToStringGrid<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: TDictionary<String, TArray<Variant>> = nil);
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

procedure TOptionsArray.AddToListView<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []; Options: TDictionary<String, TArray<Variant>> = nil);
var
  Row, Column: Integer;
  Pair: TPair<String, TArray<Variant>>;
  JSONString: String;
  JSONDataObject, JSONDataBase: TJSONObject;
begin
  TListView(AOwner).BeginUpdate;
  try
    Self.AddItem<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields);

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
            JSONDataObject := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JSONString), 0) as TJSONObject;
            if JSONDataObject.Get('ValueField').JsonValue.Value = Pair.Value[0] then
            begin
              TListView(AOwner).ItemIndex := TListView(AOwner).FindItemByValue(Pair.Value[1]);
              Break;
            end
            else
            begin
              JSONDataBase := JSONDataObject.Get('DataFields').JsonValue as TJSONObject;
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
        end;
      end;
    end;

  finally
    TListView(AOwner).EndUpdate;
  end;
end;

end.
