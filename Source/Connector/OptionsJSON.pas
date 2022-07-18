{
  OptionsJSON.
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

unit OptionsJSON;

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

  { Classe TConnector Herdade de TQuery }
type
  TOptionsJSON = class(TConnector)
  private
    { Public declarations }
    procedure AddItem<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []);
  public
    { Public declarations }
    procedure AddToEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
    procedure AddToComboEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
    procedure AddToComboBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
    procedure AddToListBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
    procedure AddToGrid<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: String = '');
    procedure AddToStringGrid<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: String = '');
    procedure AddToListView<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []; Options: String = '');
  end;

var
  InstanceOptionsJSON : TOptionsJSON;

implementation

{ TOptionsJSON }

procedure TOptionsJSON.AddItem<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []);
var
  JSONItem : TJSONItem;
begin
  JSONItem := TJSONItem.Create;
  JSONItem.AddItem<T>(AOwner, DataSet, IndexField, ValueField, DetailFields);
  JSONItem.Destroy;
end;

procedure TOptionsJSON.AddToEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
var
  JSONPairs, JSONField : Integer;
  JSONObject, JSONFields, JSONPagination, JSONNavigation : TJSONObject;
begin
  TEdit(AOwner).Items.BeginUpdate;
  try
    TEdit(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));

    if Options <> EmptyStr then
    begin
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
    end;

  finally
    TEdit(AOwner).Items.EndUpdate;
  end;
end;

procedure TOptionsJSON.AddToComboEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
var
  I, J : Integer;
  JSONObject, JSONFields, JSONPagination, JSONNavigation : TJSONObject;
begin
  TComboEdit(AOwner).Items.BeginUpdate;
  try
    TComboEdit(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));

    if Options <> EmptyStr then
    begin
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
    end;

  finally
    TComboEdit(AOwner).Items.EndUpdate;
  end;
end;

procedure TOptionsJSON.AddToComboBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
var
  JSONPairs, JSONField : Integer;
  JSONObject, JSONFields, JSONPagination, JSONNavigation : TJSONObject;
begin
  TComboBox(AOwner).Items.BeginUpdate;
  try
    TComboBox(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));

    if Options <> EmptyStr then
    begin
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
    end;

  finally
    TComboBox(AOwner).Items.EndUpdate;
  end;
end;

procedure TOptionsJSON.AddToListBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: String = '');
var
  JSONPairs, JSONField : Integer;
  JSONObject, JSONFields, JSONPagination, JSONNavigation : TJSONObject;
begin
  TListBox(AOwner).Items.BeginUpdate;
  try
    TListBox(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));

    if Options <> EmptyStr then
    begin
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
    end;

  finally
    TListBox(AOwner).Items.EndUpdate;
  end;
end;

procedure TOptionsJSON.AddToGrid<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: String = '');
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
  end;

end;

procedure TOptionsJSON.AddToStringGrid<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: String = '');
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
  end;

end;

procedure TOptionsJSON.AddToListView<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []; Options: String = '');
var
  Row, Column: Integer;
  JSONString: String;
  JSONDataObject, JSONDataBase: TJSONObject;
  JSONPairs, JSONField : Integer;
  JSONObject, JSONFields, JSONPagination, JSONNavigation : TJSONObject;
begin
  TListView(AOwner).BeginUpdate;
  try
    Self.AddItem<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields);

    if Options <> EmptyStr then
    begin
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
                JSONDataObject := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(JSONString), 0) as TJSONObject;
                if JSONDataObject.Get('ValueField').JsonValue.Value = JSONFields.Pairs[JSONField].JsonString.Value then
                begin
                  TListView(AOwner).ItemIndex := TListView(AOwner).FindItemByValue(JSONFields.Pairs[JSONField].JsonValue.Value);
                  Break;
                end
                else
                begin
                  JSONDataBase := JSONDataObject.Get('DataFields').JsonValue as TJSONObject;
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
