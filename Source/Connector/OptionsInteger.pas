{
  OptionsInteger.
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

unit OptionsInteger;

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
  TOptionsInteger = class(TConnector)
  private
    { Public declarations }
    procedure AddItem<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []);
  public
    { Public declarations }
    procedure AddToEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
    procedure AddToComboEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
    procedure AddToComboBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
    procedure AddToListBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
    procedure AddToGrid<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: Integer = -1);
    procedure AddToStringGrid<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: Integer = -1);
    procedure AddToListView<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []; Options: Integer = -1);
  end;

var
  InstanceOptionsInteger : TOptionsInteger;

implementation

{ TOptionsInteger }

procedure TOptionsInteger.AddItem<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []);
var
  JSONItem : TJSONItem;
begin
  JSONItem := TJSONItem.Create;
  JSONItem.AddItem<T>(AOwner, DataSet, IndexField, ValueField, DetailFields);
  JSONItem.Destroy;
end;

procedure TOptionsInteger.AddToEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
begin
  TEdit(AOwner).Items.BeginUpdate;
  try
    TEdit(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));

    if Options <> -1 then
    begin
      if TEdit(AOwner).Items.IndexOf(IndexValue[0]) = Options then
        TEdit(AOwner).ItemIndex := Options;
    end;

  finally
    TEdit(AOwner).Items.EndUpdate;
  end;
end;

procedure TOptionsInteger.AddToComboEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
begin
  TComboEdit(AOwner).Items.BeginUpdate;
  try
    TComboEdit(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));

    if Options <> -1 then
    begin
      if TComboEdit(AOwner).Items.IndexOf(IndexValue[0]) = Options then
        TComboEdit(AOwner).ItemIndex := Options;
    end;

  finally
    TComboEdit(AOwner).Items.EndUpdate;
  end;
end;

procedure TOptionsInteger.AddToComboBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
begin
  TComboBox(AOwner).Items.BeginUpdate;
  try
    TComboBox(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));

    if Options <> -1 then
    begin
      if TComboBox(AOwner).Items.IndexOf(IndexValue[0]) = Options then
        TComboBox(AOwner).ItemIndex := Options;
    end;

  finally
    TComboBox(AOwner).Items.EndUpdate;
  end;
end;

procedure TOptionsInteger.AddToListBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; Options: Integer = -1);
begin
  TListBox(AOwner).Items.BeginUpdate;
  try
    TListBox(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));

    if Options <> -1 then
    begin
      if TListBox(AOwner).Items.IndexOf(IndexValue[0]) = Options then
        TListBox(AOwner).ItemIndex := Options;
    end;

  finally
    TListBox(AOwner).Items.EndUpdate;
  end;
end;

procedure TOptionsInteger.AddToGrid<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: Integer = -1);
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
  end;
end;

procedure TOptionsInteger.AddToStringGrid<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: Integer = -1);
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

procedure TOptionsInteger.AddToListView<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []; Options: Integer = -1);
begin
  if (TypeInfo(T) = TypeInfo(TListView)) then
  begin
    TListView(AOwner).BeginUpdate;
    try

      Self.AddItem<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields);

      if Options <> -1 then
        TListView(AOwner).ItemIndex := Options;

    finally
      TListView(AOwner).EndUpdate;
    end;
  end;
end;

end.