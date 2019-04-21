﻿{
  SQLConnection.
  ------------------------------------------------------------------------------
  Objetivo : Simplificar a conexão à Bancos de Dados via codigos livre de
  componentes de terceiros.
  Suporta 3 tipos de componentes do dbExpres, ZeOSLIB e FireDAC.
  ------------------------------------------------------------------------------
  Autor : Nickson Jeanmerson
  Colaborador : Ramon Ruan
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

unit SQLConnection;

interface

{ Carrega a Interface Padrão }
{$I CNX.Default.inc}

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

  Data.DB,
  Data.FMTBcd,
  Data.SqlExpr, // Expressões SQL dbExpress

  FMX.Consts,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Types,
  FMX.Edit,

  FMX.Grid, // Necessário para o método toGrid
  FMX.ListBox, // Necessário para os métodos toFillList, toListBox e toComboBox
  FMX.ListView, // Necessário para o método toListView
  FMX.SearchBox,
  FMX.TextLayout,
  MultiDetailAppearanceU, // Necessário para o método toMultiList
  FMX.Bind.Editors,
  FMX.Bind.DBEngExt,

  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,

  {Runtime Live Bindings}
  Data.Bind.Components,
  Data.Bind.Grid,
  Data.Bind.DBScope,
  Data.Bind.EngExt,
  Datasnap.DBClient,
  Datasnap.Provider,

  {dbExpress}
{$IFDEF dbExpressLib}
  Data.DBXSqlite,
{$IFDEF MSWINDOWS}
  Data.DBXMySql,
  Data.DBXMSSQL,
  Data.DBXOracle,
  Data.DBXFirebird,
  Data.DBXInterBase,
{$IFDEF DBXDevartLib}
  DBXDevartPostgreSQL,
{$ENDIF}
{$ENDIF}
{$ENDIF}
  {ZeOSLib}
{$IFDEF MSWINDOWS}
{$IFDEF ZeOSLib}
  ZAbstractConnection,
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  ZConnection,
  ZAbstractTable,
  ZDbcConnection,
  ZClasses,
  ZDbcIntfs,
  ZTokenizer,
  ZCompatibility,
  ZGenericSqlToken,
  ZGenericSqlAnalyser,
  ZPlainDriver,
  ZURL,
  ZCollections,
  ZVariant,
{$ENDIF}
{$ENDIF}
  {FireDAC}
{$IFDEF FireDACLib}
  FireDAC.DatS, // FireDAC Local Data Storage Class
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Stan.Param,
  FireDAC.Stan.ExprFuncs,
  FireDAC.UI.Intf,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.IBWrapper,
{$IFDEF MSWINDOWS}
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
{$ENDIF}
{$ENDIF}
  {Ping de Conexão}
  IdBaseComponent,
  IdComponent,
  IdRawBase,
  IdRawClient,
  IdIcmpClient,

  {Classe para Criação de Matrizes Associativas}
  ArrayAssoc,
  {Record para Conversão de Tipos}
  Conversion,

  FMX.StdCtrls,
  System.Types,
{$IFDEF MSWINDOWS}
  Winapi.Windows,
  Winapi.Messages,
  FMX.Platform.Win,
{$ELSE}
  System.ByteStrings,
  FMX.Platform.Android,
  FMX.Helpers.Android,
{$ENDIF}
  System.Rtti,
  System.UITypes;

type        // OK     OK       OK                                     OK
  TDriver = (SQLite, MySQL, FIREBIRD, INTERBASE, SQLSERVER, MSSQL, POSTGRES, ORACLE);

  { Design Pattern Singleton }
type
  TSingleton<T: class, constructor> = class
  strict private
    class var SInstance: T;
  public
    class function GetInstance(): T;
    class procedure ReleaseInstance();
  end;

  { Classe Helper para o Objeto TFMXObject }
type
  TObjectHelper = class helper for TFMXObject
  public
    procedure Placeholder(Desc: String);
  end;

  { Classe Helper para o Componente TGrid }
type
  TArrayColumn= Array of String;
  TGridHelper = class(TGrid)
  private
    FRows: Array of TArrayColumn;
    FRecNo: Integer;
    function iif(B: Boolean; T,F: Variant): Variant;
    function GetCell(const Row, Col: Integer): String;
    procedure SetCell(const Row, Col: Integer; const Value: String);
    procedure SelfGetValue(Sender: TObject; const Col, Row: Integer; var Value: TValue);
    procedure SelfSetValue(Sender: TObject; const Col, Row: Integer; const Value: TValue);
    function GetAdd(const Col: Integer): String;
    procedure SetAdd(const Col: Integer; const Value: String);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function RecNo: Integer;
    procedure IncRow(Value: Integer = 1);
    property Cell[const Row, Col: Integer]: String read GetCell write SetCell; default;
    property AddValue[const Col:Integer]: String read GetAdd write SetAdd;
    procedure ClearItems;
  end;

  { Classe Helper para o Componente TStringGrid }
type
  TStringGridRowDeletion = class helper for TStringGrid
  public
    procedure RemoveRows(RowIndex, RCount: Integer);
    procedure Clear;
  end;

  { Classe Helper para o Componente TGrid }
type
  TGridRowDeletion = class helper for TGrid
  public
    procedure RemoveRows(RowIndex, RCount: Integer);
    procedure Clear;
  end;

  { Classe Helper para o Componente TListViewSearchEdit }
type
  TListViewClearSearchBox = class helper for TListView
  public
    procedure ClearSearchBoxListView();
  end;

  { Classe TConnection Herdada de TObject }
type
  TConnection = class(TObject)
  private
    { Private declarations }
    class var FInstance: TConnection;
    class var FSQLInstance: {$I CNX.Type.inc};
    class var FDriver: TDriver;
    class var FHost: String;
    class var FSchema: String;
    class var FDatabase: String;
    class var FUsername: String;
    class var FPassword: String;
    class var FPort: Integer;
    class procedure SetDriver(const Value: TDriver); static;
    class function GetConnection: {$I CNX.Type.inc}; static;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    class property Driver: TDriver read FDriver write SetDriver default Sqlite;
    class property Host: String read FHost write FHost;
    class property Schema: String read FSchema write FSchema;
    class property Database: String read FDatabase write FDatabase;
    class property Username: String read FUsername write FUsername;
    class property Password: String read FPassword write FPassword;
    class property Port: Integer read FPort write FPort;
    class property Connection: {$I CNX.Type.inc} read GetConnection;
    class function GetInstance: TConnection;
  end;

  { Cria Instancia Singleton da Classe TConnection }
type
  TConnectionClass = TSingleton<TConnection>;

  { Classe TQuery Herdada de TConnection }
type
  TQuery = class(TConnection)
  private
    { Private declarations }
    Instance: TConnection;
    FQuery: {$I CNX.Query.Type.inc};
    procedure toFillList(AOwner: TComponent; IndexField, ValueField: String);
    procedure toMultiList(AOwner: TComponent; IndexField, ValueField: String; Detail1Field: String = ''; Detail2Field: String = ''; Detail3Field: String = '');
  public
    { Public declarations }
    constructor Create(Indestructible: Boolean = False);
    destructor Destroy; override;
    procedure toGrid(AOwner: TComponent);
    procedure toComboBox(AOwner: TComponent; IndexField, ValueField: String);
    procedure toListBox(AOwner: TComponent; IndexField, ValueField: String);
    procedure toListView(AOwner: TComponent; IndexField, ValueField: String; Detail1Field: String = ''; Detail2Field: String = ''; Detail3Field: String = '');
    property Query: {$I CNX.Query.Type.inc} read FQuery write FQuery;
  end;

  { Record TQueryBuilder para Criação de Consultas para a Classe TQuery }
type
  TQueryBuilder = record
  private
    { Private declarations }
    function GenericQuery(Input: String; Mode: Boolean = False) : TQuery; overload;
  public
    { Public declarations }
    function View(Input: String; const Mode: Boolean = False): TQuery;
    function Exec(Input: String; const Mode: Boolean = True): TQuery;
    procedure Fetch(Input: String; out ReturnArray: TArray); overload;  // OK
    procedure Fetch(Input: String; out ReturnArray: TArrayVariant); overload; // OK
    function Insert(ATable: String; Data: TArray; Run: Boolean = False; Ignore : Boolean = False) : String; overload; // OK
    function Insert(ATable: String; Data: TArrayVariant; Run: Boolean = False; Ignore : Boolean = False) : String; overload; // OK
    function Update(ATable: String; Data: TArray; Run: Boolean = False) : String; overload; // OK
    function Update(ATable: String; Data: TArray; Condition: TArray; Run: Boolean = False): String; overload; // OK
    function Update(ATable: String; Data: TArrayVariant; Run: Boolean = False) : String; overload; // OK
    function Update(ATable: String; Data: TArrayVariant; Condition: TArrayVariant; Run: Boolean = False) : String; overload; // OK
    function Delete(ATable: String; Run: Boolean = False): String; overload; // OK //Genérica
    function Delete(ATable: String; Condition: TArray; Run: Boolean = False) : String; overload; // OK
    function Delete(ATable: String; Condition: TArrayVariant; Run: Boolean = False): String; overload; // OK
    function Replace(ATable: String; Data: TArray; Run: Boolean = False) : String; overload; // OK
    function Replace(ATable: String; Data: TArrayVariant; Run: Boolean = False) : String; overload; // OK
    function Replace(ATable: String; Data: TArray; Condition: TArray; Run: Boolean = False) : String; overload; // OK
    function Replace(ATable: String; Data: TArrayVariant; Condition: TArrayVariant; Run: Boolean = False) : String; overload; // OK
    function Upsert(ATable: String; Data: TArray; Run: Boolean = False; Ignore : Boolean = False; Duplicate : Boolean = False) : String; overload; // OK
    function Upsert(ATable: String; Data: TArrayVariant; Run: Boolean = False; Ignore : Boolean = False; Duplicate : Boolean = False) : String; overload; // OK
  end;

  { Classe TEventComponent Herdada de TComponent }
type
  TEventComponent = class(TComponent)
  protected
    { Protected declarations }
    FAnon: TProc;
    procedure Notify(Sender: TObject);
    class function MakeComponent(const AOwner: TComponent; const AProc: TProc): TEventComponent;
  public
    { Public declarations }
    class function NotifyEvent(const AOwner: TComponent; const AProc: TProc): TNotifyEvent;
  end;

  { Record TLocale para Localidade }
type
  TLocale = record
  private
    { Private declarations }
{$HINTS OFF}
{$WARNINGS OFF}
    function GetWindowsLanguage(LCTYPE: LCTYPE): String;
{$HINTS ON}
{$WARNINGS ON}
    procedure StoreWindowsLanguage();
    procedure RestoreWindowsLanguage();
    procedure SetWindowsLanguage();
  public
    { Public declarations }
  end;

var
  Locale: TLocale;
{$IFDEF SQLDateTime}
  _LOCALE_STHOUSAND, _LOCALE_SDECIMAL, _LOCALE_SSHORTDATE, _LOCALE_SLONGDATE, _LOCALE_SDATE, _LOCALE_STIME : String;
{$ENDIF}

implementation

{ TLocale }

function TLocale.GetWindowsLanguage(LCTYPE: LCTYPE): String;
var
  Buffer : PChar;
  Size : Integer;
begin
  Size := GetLocaleInfo(LOCALE_USER_DEFAULT, LCType, nil, 0);
  GetMem(Buffer, Size);
  try
    GetLocaleInfo(LOCALE_USER_DEFAULT, LCTYPE, Buffer, Size);
    Result := String(Buffer);
  finally
    FreeMem(Buffer);
  end;
end;

procedure TLocale.RestoreWindowsLanguage();
{$IFDEF SQLDateTime}
var
  Locale : LongInt;
{$ENDIF}
begin
{$IFDEF SQLDateTime}
  Locale := GetUserDefaultLCID();
  SetLocaleInfo(Locale, LOCALE_STHOUSAND, PWideChar(_LOCALE_STHOUSAND));
  SetLocaleInfo(Locale, LOCALE_SDECIMAL, PWideChar(_LOCALE_SDECIMAL));
  SetLocaleInfo(Locale, LOCALE_SSHORTDATE, PWideChar(_LOCALE_SSHORTDATE));
  SetLocaleInfo(Locale, LOCALE_SLONGDATE, PWideChar(_LOCALE_SLONGDATE));
  SetLocaleInfo(Locale, LOCALE_SDATE, PWideChar(_LOCALE_SDATE));
  SetLocaleInfo(Locale, LOCALE_STIME, PWideChar(_LOCALE_STIME));
{$ENDIF}
end;

procedure TLocale.StoreWindowsLanguage();
begin
{$IFDEF SQLDateTime}
  _LOCALE_STHOUSAND := Locale.GetWindowsLanguage(LOCALE_STHOUSAND);
  _LOCALE_SDECIMAL := Locale.GetWindowsLanguage(LOCALE_SDECIMAL);
  _LOCALE_SSHORTDATE := Locale.GetWindowsLanguage(LOCALE_SSHORTDATE);
  _LOCALE_SLONGDATE := Locale.GetWindowsLanguage(LOCALE_SLONGDATE);
  _LOCALE_SDATE := Locale.GetWindowsLanguage(LOCALE_SDATE);
  _LOCALE_STIME := Locale.GetWindowsLanguage(LOCALE_STIME);
{$ENDIF}
end;

procedure TLocale.SetWindowsLanguage();
{$IFDEF SQLDateTime}
var
  Locale : LongInt;
{$ENDIF}
begin
{$IFDEF SQLDateTime}
  Locale := GetUserDefaultLCID();
  SetLocaleInfo(Locale, LOCALE_STHOUSAND, #0);
  SetLocaleInfo(Locale, LOCALE_SDECIMAL, '.');
  SetLocaleInfo(Locale, LOCALE_SSHORTDATE, 'yyyy-MM-dd');
  SetLocaleInfo(Locale, LOCALE_SLONGDATE, 'yyyy-MM-dd hh:nn:ss');
  SetLocaleInfo(Locale, LOCALE_SDATE, '-');
  SetLocaleInfo(Locale, LOCALE_STIME, ':');
{$ENDIF}
  with FormatSettings do
  begin
    ThousandSeparator := #0;
    DecimalSeparator := '.';
    ShortDateFormat := 'yyyy-MM-dd';
    LongDateFormat := 'yyyy-MM-dd hh:nn:ss';
    DateSeparator := '-';
    TimeSeparator := ':';
  end;
end;

{ TEventComponent }

class function TEventComponent.MakeComponent(const AOwner: TComponent; const AProc: TProc): TEventComponent;
begin
  Result:= TEventComponent.Create(AOwner);
  Result.FAnon:= AProc;
end;

procedure TEventComponent.Notify(Sender: TObject);
begin
  FAnon();
end;

class function TEventComponent.NotifyEvent(const AOwner: TComponent; const AProc: TProc): TNotifyEvent;
begin
  Result:= MakeComponent(AOwner, AProc).Notify;
end;

{ Singleton }

class function TSingleton<T>.GetInstance: T;
begin
  if not Assigned(Self.SInstance) then
    Self.SInstance := T.Create();
  Result := Self.SInstance;
end;

class procedure TSingleton<T>.ReleaseInstance;
begin
  if Assigned(Self.SInstance) then
    Self.SInstance.Free;
end;

{ TObjectHelper }

procedure TObjectHelper.Placeholder(Desc: String);
var
  lbl : TLabel;
  Win: TForm;
begin
  lbl := TLabel.Create(Self);
  lbl.Text := Desc;
  lbl.Name := 'Label'+Self.Name;
  lbl.StyledSettings := [TStyledSetting.Family];
  lbl.Position.X := 3;
  lbl.Position.Y := 0;
  lbl.TextSettings.Font.Size := 13;
  lbl.TextSettings.FontColor := TAlphaColors.Darkgray;
  lbl.Parent := Self;

  TEdit(Self).OnEnter := TEventComponent.NotifyEvent(Win,
              procedure
              var
                runlbl :TLabel;
              begin
                if (Self as TEdit).Text = '' then
                begin
                  runlbl := TLabel((Self as TEdit).FindComponent('Label'+(Self as TEdit).Name));
                  runlbl.AnimateFloat('Font.Size',9,0.1, TAnimationType.InOut,TInterpolationType.Elastic);
                  runlbl.AnimateFloat('Position.Y',-16,0.1, TAnimationType.InOut,TInterpolationType.Elastic);
                  runlbl.FontColor := TAlphaColors.Royalblue;
                end;
                Win.Free;
              end);

  TEdit(Self).OnExit := TEventComponent.NotifyEvent(Win,
              procedure
              var
                runlbl :TLabel;
              begin
                if (Self as TEdit).Text = '' then
                begin
                  runlbl := TLabel((Self as TEdit).FindComponent('Label'+(Self as TEdit).Name));
                  runlbl.AnimateFloat('Font.Size',14,0.1, TAnimationType.InOut,TInterpolationType.Elastic);
                  runlbl.AnimateFloat('Position.Y',3,0.1, TAnimationType.InOut,TInterpolationType.Elastic);
                  runlbl.FontColor := TAlphaColors.Darkgray;
                end;
                Win.Free;
              end);
end;

{ TGridHelper }

procedure TGridHelper.ClearItems;
begin
  if RowCount = 0 then Exit;

  RowCount := 0;
  FRecNo := RowCount;
  SetLength(FRows, 0);
end;

constructor TGridHelper.Create(AOwner: TComponent);
begin
  inherited;
  RowCount := 0;
  FRecNo := RowCount;
  inherited OnGetValue := SelfGetValue;
  inherited OnSetValue := SelfSetValue;
end;

destructor TGridHelper.Destroy;
begin
  inherited;
end;

function TGridHelper.GetAdd(const Col: Integer): String;
begin

end;

function TGridHelper.GetCell(const Row, Col: Integer): String;
begin
  Result := FRows[Row][Col];
end;

function TGridHelper.iif(B: Boolean; T, F: Variant): Variant;
begin
  if B then
    Result := T
  else
    Result := F;
end;

procedure TGridHelper.IncRow(Value: Integer);
begin
  RowCount := RowCount + Value;
  SetLength(FRows, RowCount);
  SetLength(FRows[RowCount - 1], ColumnCount);
  FRecNo := RowCount;
end;

function TGridHelper.RecNo: Integer;
begin
  Result := FRecNo;
end;

procedure TGridHelper.SelfGetValue(Sender: TObject; const Col, Row: Integer;
  var Value: TValue);
begin
  if (Row <= RowCount) and (Col < ColumnCount) then
  begin
    Value := TValue.FromVariant(
                                 iif((Cell[Row, Col] = 'N'),
                                     False,
                                     iif(Cell[Row, Col] = 'Y', True, Cell[Row, Col])
                                    )
                               );
  end;
end;

procedure TGridHelper.SelfSetValue(Sender: TObject; const Col, Row: Integer;
  const Value: TValue);
begin
  if (Row <= RowCount) and (Col < ColumnCount) then
  begin
    Cell[Row, Col] := iif(UpperCase(Value.ToString) = 'TRUE', 'Y', iif(UpperCase(Value.ToString) = 'FALSE', 'N', Value.ToString));
  end;
end;

procedure TGridHelper.SetAdd(const Col: Integer; const Value: String);
begin
  SetCell(FRecNo - 1, Col, Value);
end;

procedure TGridHelper.SetCell(const Row, Col: Integer; const Value: String);
begin
  try
    if Length(FRows[Row]) = 0 then
      SetLength(FRows[Row], ColumnCount);

    FRows[Row][Col]:= Value;
  except
    ShowMessage('This cell not found!');
  end;
end;

{ TStringGridRowDeletion }

procedure TStringGridRowDeletion.Clear;
var
  I: Integer;
begin
  for I := 0 to RowCount - 1 do
    RemoveRows(0, RowCount);
  ClearColumns;
end;

procedure TStringGridRowDeletion.RemoveRows(RowIndex, RCount: Integer);
var
  I, J: Integer;
begin
  for I := RCount to RowCount - 1 do
    for J := 0 to ColumnCount - 1 do
      Cells[J, I] := Cells[J, I + 1];
  RowCount := RowCount - RCount;
end;

{ TGridRowDeletion }

procedure TGridRowDeletion.Clear;
begin
  TStringGrid(Self).Clear;
  TStringGrid(Self).ClearColumns;
end;

procedure TGridRowDeletion.RemoveRows(RowIndex, RCount: Integer);
begin
  TStringGrid(Self).RemoveRows(RowIndex, RCount);
end;

{ TListViewClearSearchBox }

procedure TListViewClearSearchBox.ClearSearchBoxListView;
var
  SearchListView: TSearchBox;
  I: Integer;
begin
  SearchListView := nil;
  for I := 0 to Self.ComponentCount - 1 do
  begin
    if (Self.Components[I] is TSearchBox) then
    begin
      SearchListView := Self.Components[I] as TSearchBox;
      break;
    end;
  end;
  if (SearchListView <> nil) then
    SearchListView.Text := '';
end;

{ TConnection }

constructor TConnection.Create;
begin
  inherited Create;
end;

destructor TConnection.Destroy;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
  if Assigned(FSQLInstance) then
    FreeAndNil(FSQLInstance);
  inherited;
end;

class procedure TConnection.SetDriver(const Value: TDriver);
begin
  FDriver := Value;
end;

class function TConnection.GetConnection: {$I CNX.Type.inc};
begin
  Result := FSQLInstance;
end;

class function TConnection.GetInstance: TConnection;
begin
  try
    if not Assigned(FInstance) then
    begin
      FInstance := TConnection.Create;
      TConnection.FInstance.FSQLInstance := {$I CNX.Type.inc}.Create(nil);
      {$I CNX.Params.inc}
    end;
  except
    on E: Exception do
      raise Exception.Create(E.Message);
  end;
  Result := FInstance;
end;

{ TQuery }

constructor TQuery.Create(Indestructible: Boolean = False);
begin
  Instance := TConnection.Create;
  FQuery := {$I CNX.Query.Type.inc}.Create(nil);
{$IFDEF dbExpressLib}
  FQuery.SQLConnection := Instance.GetInstance.Connection;
{$ENDIF}
{$IFDEF FireDACLib}
  FQuery.Connection := Instance.GetInstance.Connection;
{$ENDIF}
{$IFDEF ZeOSLib}
  FQuery.Connection := Instance.GetInstance.Connection;
{$ENDIF}
  if Indestructible then
    Instance.FreeInstance;
end;

{
procedure TQuery.toGrid(AOwner: TComponent);
var
  Column : TColumn;
  I : Integer;
begin
  FQuery.Open(FQuery.Text);
  FQuery.FetchOptions.Mode := fmAll;

  if (AOwner is TStringGrid) and (TStringGrid(AOwner) <> nil) then
  begin
    TStringGrid(AOwner).ClearColumns;
    TStringGrid(AOwner).RowCount := FQuery.RecordCount;

    for I := 0 to FQuery.FieldCount - 1 do
    begin
      Column := TColumn.Create(FQuery);
      Column.Header := FQuery.Fields[I].FieldName;
      Column.Parent := TStringGrid(AOwner);
    end;

    FQuery.First;
    while not FQuery.Eof do
    begin
      for I := 0 to FQuery.FieldCount - 1 do
        TStringGrid(AOwner).Cells[I, FQuery.RecNo - 1] := FQuery.Fields[I].AsString;
      FQuery.Next;
    end;
  end;

  if (AOwner is TGrid) and (TGrid(AOwner) <> nil) then
  begin
    TGrid(AOwner).ClearColumns;
    TGrid(AOwner).RowCount := FQuery.RecordCount;

    for I := 0 to FQuery.FieldCount - 1 do
    begin
      Column := TColumn.Create(FQuery);
      Column.Header := FQuery.FieldDefs[I].Name;
      Column.Tag := I;
      Column.Data := FQuery.Fields[I].AsString;
      TGrid(AOwner).AddObject(Column);
    end;

  end;

end;
}

procedure TQuery.toGrid(AOwner: TComponent);
var
  DataSetProvider: TDataSetProvider;
  ClientDataSet: TClientDataSet;
  BindSourceDB: TBindSourceDB;
  BindingsList: TBindingsList;
  LinkGridToDataSource: TLinkGridToDataSource;
begin

  try

    Application.ProcessMessages;
    if (AOwner is TGrid) and (TGrid(AOwner) <> nil) and (TGrid(AOwner).VisibleColumnCount > 0) then
      TGrid(AOwner).Clear
    else if (AOwner is TStringGrid) and (TStringGrid(AOwner) <> nil) and (TStringGrid(AOwner).VisibleColumnCount > 0) then
      TStringGrid(AOwner).Clear;

{$WARNINGS OFF}
{$HINTS OFF}

    DataSetProvider := TDataSetProvider.Create(FQuery);
    ClientDataSet := TClientDataSet.Create(DataSetProvider);
    BindSourceDB := TBindSourceDB.Create(ClientDataSet);
    BindingsList := TBindingsList.Create(BindSourceDB);
    LinkGridToDataSource := TLinkGridToDataSource.Create(BindSourceDB);

    DataSetProvider.DataSet := FQuery;
    ClientDataSet.SetProvider(DataSetProvider);

    BindSourceDB.DataSet := ClientDataSet;
    BindSourceDB.DataSet.Active := False;
    BindSourceDB.DataSet.Active := True;

    BindingsList.PromptDeleteUnused := True;

    LinkGridToDataSource.GridControl := AOwner;
    LinkGridToDataSource.DataSource := BindSourceDB;
    LinkGridToDataSource.AutoBufferCount := False;
    LinkGridToDataSource.Active := False;
    LinkGridToDataSource.Active := True;

{$HINTS ON}
{$WARNINGS ON}    
        
  except

  end;

end;

procedure TQuery.toFillList(AOwner: TComponent; IndexField, ValueField: String);
var
  DataSetProvider: TDataSetProvider;
  ClientDataSet: TClientDataSet;
  BindSourceDB: TBindSourceDB;
  BindingsList: TBindingsList;
  LinkListControlToField: TLinkListControlToField;
  LinkPropertyToFieldIndex: TLinkPropertyToField;
begin

  try

    Application.ProcessMessages;
    if (AOwner is TComboBox) and (TComboBox(AOwner) <> nil) and (TComboBox(AOwner).Items.Count > 0) then
      TComboBox(AOwner).Items.Clear
    else if (AOwner is TListBox) and (TListBox(AOwner) <> nil) and (TListBox(AOwner).Items.Count > 0) then
      TListBox(AOwner).Clear;

{$WARNINGS OFF}
{$HINTS OFF}
    DataSetProvider := TDataSetProvider.Create(FQuery);
    ClientDataSet := TClientDataSet.Create(DataSetProvider);
    BindSourceDB := TBindSourceDB.Create(ClientDataSet);
    BindingsList := TBindingsList.Create(BindSourceDB);
    LinkListControlToField := TLinkListControlToField.Create(BindSourceDB);
    LinkPropertyToFieldIndex := TLinkPropertyToField.Create(BindSourceDB);

    DataSetProvider.DataSet := FQuery;
    ClientDataSet.SetProvider(DataSetProvider);

    BindSourceDB.DataSet := ClientDataSet;
    BindSourceDB.DataSet.Active := True;

    BindingsList.PromptDeleteUnused := True;

    LinkListControlToField.Control := AOwner;
    LinkListControlToField.DataSource := BindSourceDB;
    LinkListControlToField.FieldName := ValueField;
    LinkListControlToField.AutoBufferCount := False;
    LinkListControlToField.Active := True;

    LinkPropertyToFieldIndex.Component := AOwner;
    LinkPropertyToFieldIndex.DataSource := BindSourceDB;
    LinkPropertyToFieldIndex.ComponentProperty := 'Index';
    LinkPropertyToFieldIndex.FieldName := IndexField;
    LinkPropertyToFieldIndex.Active := True;

{$HINTS ON}
{$WARNINGS ON}
  except

  end;

end;

procedure TQuery.toMultiList(AOwner: TComponent; IndexField, ValueField: String; Detail1Field: String = ''; Detail2Field: String = ''; Detail3Field: String = '');
var
  DataSetProvider: TDataSetProvider;
  ClientDataSet: TClientDataSet;
  BindSourceDB: TBindSourceDB;
  BindingsList: TBindingsList;
  LinkListControlToField: TLinkListControlToField;
  LinkPropertyToFieldIndex: TLinkPropertyToField;
begin

  try

    Application.ProcessMessages;
    if (AOwner is TListView) and (TListView(AOwner) <> nil) and (TListView(AOwner).Items.Count > 0) then
    begin
      TListView(AOwner).Items.Clear;
      TListView(AOwner).ClearSearchBoxListView;
    end;

{$WARNINGS OFF}
{$HINTS OFF}

    DataSetProvider := TDataSetProvider.Create(FQuery);
    ClientDataSet := TClientDataSet.Create(DataSetProvider);
    BindSourceDB := TBindSourceDB.Create(ClientDataSet);
    BindingsList := TBindingsList.Create(BindSourceDB);
    LinkListControlToField := TLinkListControlToField.Create(BindSourceDB);
    LinkPropertyToFieldIndex := TLinkPropertyToField.Create(BindSourceDB);

    DataSetProvider.DataSet := FQuery;
    ClientDataSet.SetProvider(DataSetProvider);

    BindSourceDB.DataSet := ClientDataSet;
    BindSourceDB.DataSet.Active := True;

    BindingsList.PromptDeleteUnused := True;

    LinkPropertyToFieldIndex.Component := AOwner;
    LinkPropertyToFieldIndex.DataSource := BindSourceDB;
    LinkPropertyToFieldIndex.ComponentProperty := 'Index';
    LinkPropertyToFieldIndex.FieldName := IndexField;
    LinkPropertyToFieldIndex.Active := True;

    LinkListControlToField.Control := AOwner;
    LinkListControlToField.DataSource := BindSourceDB;
    LinkListControlToField.FieldName := ValueField;
    LinkListControlToField.AutoBufferCount := False;
    LinkListControlToField.Active := True;

    if ((Detail1Field <> '') or (Detail2Field <> '') or (Detail3Field <> '')) then
    begin

      TListView(AOwner).ItemAppearance.ItemAppearance := 'MultiDetailItem';
      TListView(AOwner).BeginUpdate;

      if Detail1Field <> '' then
      begin
        with LinkListControlToField.FillExpressions.AddExpression do
        begin
          SourceMemberName := Detail1Field;
          ControlMemberName := 'Detail1';
        end;
      end;

      if Detail2Field <> '' then
      begin
        with LinkListControlToField.FillExpressions.AddExpression do
        begin
          SourceMemberName := Detail2Field;
          ControlMemberName := 'Detail2';
        end;
      end;

      if Detail3Field <> '' then
      begin
        with LinkListControlToField.FillExpressions.AddExpression do
        begin
          SourceMemberName := Detail3Field;
          ControlMemberName := 'Detail3';
        end;
      end;

      TListView(AOwner).EndUpdate;

    end;

{$HINTS ON}
{$WARNINGS ON}
  except

  end;

end;

procedure TQuery.toComboBox(AOwner: TComponent; IndexField, ValueField: String);
begin
  toFillList(AOwner, IndexField, ValueField);
end;

procedure TQuery.toListBox(AOwner: TComponent; IndexField, ValueField: String);
begin
  toFillList(AOwner, IndexField, ValueField);
end;

procedure TQuery.toListView(AOwner: TComponent; IndexField, ValueField: String; Detail1Field: String = ''; Detail2Field: String = ''; Detail3Field: String = '');
begin
  toMultiList(AOwner, IndexField, ValueField, Detail1Field, Detail2Field, Detail3Field);
end;

destructor TQuery.Destroy;
begin
  inherited;
end;

{ TQueryBuilder }

function TQueryBuilder.GenericQuery(Input: String; Mode: Boolean = False): TQuery;
var
  SQL: TQuery;
begin
  SQL := TQuery.Create;
  SQL.Query.Close;
  SQL.Query.SQL.Clear;
  SQL.Query.SQL.Text := Input;
  if not Mode then
    SQL.Query.Open
  else
    SQL.Query.ExecSQL;
  Result := SQL;
end;

function TQueryBuilder.View(Input: String; const Mode: Boolean = False): TQuery;
begin
  Result := GenericQuery(Input, Mode);
end;

function TQueryBuilder.Exec(Input: String; const Mode: Boolean = True): TQuery;
begin
  Result := GenericQuery(Input, Mode);
end;

procedure TQueryBuilder.Fetch(Input: String; out ReturnArray: TArray);
var
  Query: TQueryBuilder;
  SQL: TQuery;
  Return: TArray;
  I: Integer;
begin
  SQL := Query.View(Input);
  if not (SQL.Query.IsEmpty) then
  begin
    Return := TArray.Create;
    Return.Clear;
    while not SQL.Query.Eof do
    begin // Linhas
      for I := 0 to SQL.Query.FieldCount - 1 do
        Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsString);
      SQL.Query.Next;
    end;
    ReturnArray := Return;
  end
  else
  begin
    Return := TArray.Create;
    Return.Clear;
    Return.Add('0');
    ReturnArray := Return;
  end;
end;

procedure TQueryBuilder.Fetch(Input: String; out ReturnArray: TArrayVariant);
var
  Query: TQueryBuilder;
  SQL: TQuery;
  Return: TArrayVariant;
  I: Integer;
begin
  SQL := Query.View(Input);
  if not (SQL.Query.IsEmpty) then
  begin
    Return := TArrayVariant.Create;
    Return.Clear;
    while not SQL.Query.Eof do
    begin // Linhas
        for I := 0 to SQL.Query.FieldCount - 1 do
      begin // Colunas
        {$REGION 'DataTypes'}
        //http://docwiki.embarcadero.com/RADStudio/Rio/en/DbExpress_Data_Type_Mapping_for_Supported_Databases
        {$ENDREGION}
        case SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).DataType of
          ftFixedChar,
          ftString :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsString);
          ftBoolean :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsBoolean);
          ftBytes,
          ftVarBytes,
          ftGuid :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsBytes);
          ftShortInt,
          ftSmallInt,
          ftInteger,
          ftAutoInc,
          ftWord :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsInteger);
          ftLargeInt :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsLargeInt);
          ftLongWord :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsLongWord);
          ftSingle:
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsSingle);
          ftFloat :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsFloat);
          ftExtended :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsExtended);
          ftCurrency,
          ftBCD :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsCurrency);
          ftWideString :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsWideString);
          ftDate,
          ftTime,
          ftDateTime,
          ftTimeStamp,
          ftTimeStampOffset :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsDateTime);
          ftMemo,
          ftWideMemo,
          ftBlob,
          ftGraphic :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsWideString);
          ftUnknown :
            Return.AddKeyValue(SQL.Query.Fields[I].DisplayName, SQL.Query.FieldByName(SQL.Query.Fields[I].DisplayName).AsString);
        end;
      end;
      SQL.Query.Next;
    end;
    ReturnArray := Return;
  end
  else
  begin
    Return := TArrayVariant.Create;
    Return.Clear;
    Return.AddKeyValue('0', '');
    ReturnArray := Return;
  end;
end;

function TQueryBuilder.Insert(ATable: String; Data: TArray; Run: Boolean = False; Ignore : Boolean = False): String;
var
  DBFields, DBValues, DBValue, IgnoreStr, InsertStr: String;
  I: Integer;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBFields := '';
  DBValues := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Percorre a Matriz
  for I := 0 to Data.Count - 1 do
  begin
    DBFields := DBFields + ',' + Data.Names[I] + '';
    DBValue := Data.ValuesAtIndex[I];

    // Trata Palavras Reservadas
    case AnsiIndexStr(UpperCase(String(DBValue)), ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP']) of
     0..5 : DBValues := DBValues + ',' + DBValue
    else
     DBValues := DBValues + ',''' + DBValue + '''';
    end;
  end;

  // Remove os Último Caractere
  System.Delete(DBFields, 1, 1);
  System.Delete(DBValues, 1, 1);

  // Trata se Contém algum Caractere de Controle e o Remove
  if DBValues.Contains(#0) then
    DBValues := StringReplace(DBValues, #0, '',[rfReplaceAll]);

  // Possui Cláusula Ignore ?
  if Ignore = True then
    IgnoreStr := ' IGNORE';

  // Constrói o Comando INSERT
  InsertStr := 'INSERT' + IgnoreStr + ' INTO ' + Trim(ATable) + ' (' + Trim(DBFields) + ') VALUES (' + Trim(DBValues) + ');';

  // Deve ser Executada ?
  if Run then
    Query.Exec(InsertStr);

  // Retorna o Comando INSERT
  Result := InsertStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Insert(ATable: String; Data: TArrayVariant; Run: Boolean = False; Ignore : Boolean = False): String;
var
  DBFields, DBValues, DBValue, IgnoreStr, InsertStr: String;
  I: Integer;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBFields := '';
  DBValues := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Percorre a Matriz
  for I := 0 to Data.Count - 1 do
  begin
    DBFields := DBFields + ',' + Data.Key[I] + '';
    DBValue := Data.ValuesAtIndex[I];

    // Trata Palavras Reservadas
    case AnsiIndexStr(UpperCase(String(DBValue)), ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP']) of
     0..5 : DBValues := DBValues + ',' + DBValue
    else
     DBValues := DBValues + ',' + Convert.VarToStr(DBValue);
    end;
  end;

  // Remove os Último Caractere
  System.Delete(DBFields, 1, 1);
  System.Delete(DBValues, 1, 1);

  // Trata se Contém algum Caractere de Controle e o Remove
  if DBValues.Contains(#0) then
    DBValues := StringReplace(DBValues, #0, '',[rfReplaceAll]);

  // Possui Cláusula Ignore ?
  if Ignore = True then
    IgnoreStr := ' IGNORE';

  // Constrói o Comando INSERT
  InsertStr := 'INSERT' + IgnoreStr + ' INTO ' + Trim(ATable) + ' (' + Trim(DBFields) + ') VALUES (' + Trim(DBValues) + ');';

  // Deve ser Executada ?
  if Run then
    Query.Exec(InsertStr);

  // Retorna o Comando INSERT
  Result := InsertStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Update(ATable: String; Data: TArray; Run: Boolean = False): String;
var
  DBValues, DBValue, UpdateStr: String;
  I: Integer;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBValues := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Percorre a Matriz
  for I := 0 to Data.Count - 1 do
  begin
    DBValue := Data.ValuesAtIndex[I];

    // Trata Palavras Reservadas
    case AnsiIndexStr(UpperCase(String(DBValue)), ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP']) of
     0..5 : DBValues := DBValues + ',' + DBValue
    else
      DBValues := DBValues + ',' + Data.Names[I] + ' = ' + '''' + DBValue + '''';
    end;
  end;

  // Remove os Último Caractere
  System.Delete(DBValues, 1, 1);

  // Trata se Contém algum Caractere de Controle e o Remove
  if DBValues.Contains(#0) then
    DBValues := StringReplace(DBValues, #0, '',[rfReplaceAll]);

  // Constrói o Comando UPDATE
  UpdateStr := 'UPDATE ' + ATable + ' SET ' + DBValues;

  // Deve ser Executada ?
  if Run then
    Query.Exec(UpdateStr);

  // Retorna o Comando UPDATE
  Result := UpdateStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Update(ATable: String; Data: TArray; Condition: TArray; Run: Boolean = False): String;
var
  DBValues, DBValue, DBFilters, UpdateStr: String;
  I: Integer;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBValues := '';
  DBFilters := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Percorre a Matriz
  for I := 0 to Data.Count - 1 do
  begin
    DBValue := Data.ValuesAtIndex[I];

    // Trata Palavras Reservadas
    case AnsiIndexStr(UpperCase(String(DBValue)), ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP']) of
     0..5 : DBValues := DBValues + ',' + DBValue
    else
      DBValues := DBValues + ',' + Data.Names[I] + ' = ' + '''' + DBValue + '''';
    end;
  end;

  // Obtém os Filtros
  DBFilters := Condition.ToFilter;

  // Remove os Último Caractere
  System.Delete(DBValues, 1, 1);

  // Trata se Contém algum Caractere de Controle e o Remove
  if DBValues.Contains(#0) then
    DBValues := StringReplace(DBValues, #0, '',[rfReplaceAll]);
  if DBFilters.Contains(#0) then
    DBFilters := StringReplace(DBFilters, #0, '',[rfReplaceAll]);

  // Constrói o Comando UPDATE
  UpdateStr := 'UPDATE ' + ATable + ' SET ' + DBValues + ' WHERE ' + DBFilters;

  // Deve ser Executada ?
  if Run then
    Query.Exec(UpdateStr);

  // Retorna o Comando UPDATE
  Result := UpdateStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Update(ATable: String; Data: TArrayVariant; Run: Boolean = False): String;
var
  DBValues, DBValue, UpdateStr: String;
  I: Integer;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBValues := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Percorre a Matriz
  for I := 0 to Data.Count - 1 do
  begin
    DBValue := Data.ValuesAtIndex[I];

    // Trata Palavras Reservadas
    case AnsiIndexStr(UpperCase(String(DBValue)), ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP']) of
     0..5 : DBValues := DBValues + ',' + Data.Key[I] + ' = ' + DBValue
    else
     DBValues := DBValues + ',' + Data.Key[I] + ' = ' + Convert.VarToStr(DBValue);
    end;
  end;

  // Remove os Último Caractere
  System.Delete(DBValues, 1, 1);

  // Trata se Contém algum Caractere de Controle e o Remove
  if DBValues.Contains(#0) then
    DBValues := StringReplace(DBValues, #0, '',[rfReplaceAll]);

  // Constrói o Comando UPDATE
  UpdateStr := 'UPDATE ' + ATable + ' SET ' + DBValues;

  // Deve ser Executada ?
  if Run then
    Query.Exec(UpdateStr);

  // Retorna o Comando UPDATE
  Result := UpdateStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Update(ATable: String; Data: TArrayVariant; Condition: TArrayVariant; Run: Boolean = False): String;
var
  DBValues, DBValue, DBFilters, UpdateStr: String;
  I: Integer;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBValues := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Percorre a Matriz
  for I := 0 to Data.Count - 1 do
  begin
    DBValue := Data.ValuesAtIndex[I];

    // Trata Palavras Reservadas
    case AnsiIndexStr(UpperCase(String(DBValue)), ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP']) of
     0..5 : DBValues := DBValues + ',' + Data.Key[I] + ' = ' + DBValue
    else
     DBValues := DBValues + ',' + Data.Key[I] + ' = ' + Convert.VarToStr(DBValue);
    end;
  end;

  // Obtém os Filtros
  DBFilters := Condition.ToFilter;

  // Remove os Último Caractere
  System.Delete(DBValues, 1, 1);

  // Trata se Contém algum Caractere de Controle e o Remove
  if DBValues.Contains(#0) then
    DBValues := StringReplace(DBValues, #0, '',[rfReplaceAll]);
  if DBFilters.Contains(#0) then
    DBFilters := StringReplace(DBFilters, #0, '',[rfReplaceAll]);

  // Constrói o Comando UPDATE
  UpdateStr := 'UPDATE ' + ATable + ' SET ' + DBValues + ' WHERE ' + DBFilters;

  // Deve ser Executada ?
  if Run then
    Query.Exec(UpdateStr);

  // Retorna o Comando UPDATE
  Result := UpdateStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Delete(ATable: String; Run: Boolean = False): String;
var
  DeleteStr: String;
  Query: TQueryBuilder;
begin
  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Constrói o Comando DELETE
  DeleteStr := 'DELETE FROM ' + ATable;

  // Deve ser Executada ?
  if Run then
    Query.Exec(DeleteStr);

  // Retorna o Comando DELETE
  Result := DeleteStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Delete(ATable: String; Condition: TArray; Run: Boolean = False): String;
var
  DBFilters, DeleteStr: String;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBFilters := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Obtém os Filtros
  DBFilters := Condition.ToFilter;

  // Trata se Contém algum Caractere de Controle e o Remove
  if DBFilters.Contains(#0) then
    DBFilters := StringReplace(DBFilters, #0, '',[rfReplaceAll]);

  // Constrói o Comando DELETE
  DeleteStr := 'DELETE FROM ' + ATable + ' WHERE ' + DBFilters;

  // Deve ser Executada ?
  if Run then
    Query.Exec(DeleteStr);

  // Retorna o Comando DELETE
  Result := DeleteStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Delete(ATable: String; Condition: TArrayVariant; Run: Boolean = False): String;
var
  DBFilters, DeleteStr: String;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBFilters := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Obtém os Filtros
  DBFilters := Condition.ToFilter;

  // Trata se Contém algum Caractere de Controle e o Remove
  if DBFilters.Contains(#0) then
    DBFilters := StringReplace(DBFilters, #0, '',[rfReplaceAll]);

  // Constrói o Comando DELETE
  DeleteStr := 'DELETE FROM ' + ATable + ' WHERE ' + DBFilters;

  // Deve ser Executada ?
  if Run then
    Query.Exec(DeleteStr);

  // Retorna o Comando DELETE
  Result := DeleteStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Replace(ATable: String; Data: TArray; Run: Boolean = False): String;
var
  DBFields, DBValues, DBValue, ReplaceStr: String;
  I: Integer;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBFields := '';
  DBValues := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Percorre a Matriz
  for I := 0 to Data.Count - 1 do
  begin
    DBFields := DBFields + ',' + Data.Names[I] + '';
    DBValue := Data.ValuesAtIndex[I];

    // Trata Palavras Reservadas
    case AnsiIndexStr(UpperCase(String(DBValue)), ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP']) of
     0..5 : DBValues := DBValues + ',' + DBValue
    else
      DBValues := DBValues + ',''' + DBValue + '''';
    end;
  end;

  // Remove os Último Caractere
  System.Delete(DBFields, 1, 1);
  System.Delete(DBValues, 1, 1);

  // Trata se Contém algum Caractere de Controle e o Remove
  if DBValues.Contains(#0) then
    DBValues := StringReplace(DBValues, #0, '',[rfReplaceAll]);

  // Constrói o Comando REPLACE
  ReplaceStr := 'REPLACE INTO ' + ATable + ' (' + DBFields + ') VALUES (' + DBValues + ')';

  // Deve ser Executada ?
  if Run then
    Query.Exec(ReplaceStr);

  // Retorna o Comando UPDATE
  Result := ReplaceStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Replace(ATable: String; Data: TArrayVariant; Run: Boolean = False): String;
var
  DBFields, DBValues, DBValue, ReplaceStr: String;
  I: Integer;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBFields := '';
  DBValues := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Percorre a Matriz
  for I := 0 to Data.Count - 1 do
  begin
    DBFields := DBFields + ',' + Data.Key[I] + '';
    DBValue := Data.ValuesAtIndex[I];

    // Trata Palavras Reservadas
    case AnsiIndexStr(UpperCase(String(DBValue)), ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP']) of
     0..5 : DBValues := DBValues + ',' + DBValue
    else
      DBValues := DBValues + ',' + Convert.VarToStr(DBValue);
    end;
  end;

  // Remove os Último Caractere
  System.Delete(DBFields, 1, 1);
  System.Delete(DBValues, 1, 1);

  // Trata se Contém algum Caractere de Controle e o Remove
  if DBValues.Contains(#0) then
    DBValues := StringReplace(DBValues, #0, '',[rfReplaceAll]);

  // Constrói o Comando REPLACE
  ReplaceStr := 'REPLACE INTO ' + ATable + ' (' + DBFields + ') VALUES (' + DBValues + ')';

  // Deve ser Executada ?
  if Run then
    Query.Exec(ReplaceStr);

  // Retorna o Comando UPDATE
  Result := ReplaceStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Replace(ATable: String; Data: TArray; Condition: TArray; Run: Boolean = False): String;
var
  DBFields, DBValues, DBValue, DBFilters, ReplaceStr: String;
  I: Integer;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBFields := '';
  DBValues := '';
  DBFilters := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Percorre a Matriz
  for I := 0 to Data.Count - 1 do
  begin
    DBFields := DBFields + ',' + Data.Names[I] + '';
    DBValue := Data.ValuesAtIndex[I];

    // Trata Palavras Reservadas
    case AnsiIndexStr(UpperCase(String(DBValue)), ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP']) of
     0..5 : DBValues := DBValues + ',' + DBValue
    else
      DBValues := DBValues + ',''' + DBValue + '''';
    end;
  end;

  // Remove os Último Caractere
  System.Delete(DBFields, 1, 1);
  System.Delete(DBValues, 1, 1);
  System.Delete(DBFilters, 1, 1);

  // Obtém os Filtros
  DBFilters := Condition.ToFilter;

  // Constrói o Comando REPLACE
  ReplaceStr := 'REPLACE INTO ' + ATable + ' (' + DBFields + ') VALUES (' + DBValues + ')' + ' WHERE ' + DBFilters;

  // Deve ser Executada ?
  if Run then
    Query.Exec(ReplaceStr);

  // Retorna o Comando UPDATE
  Result := ReplaceStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Replace(ATable: String; Data: TArrayVariant; Condition: TArrayVariant; Run: Boolean = False): String;
var
  DBFields, DBValues, DBValue, DBFilters, ReplaceStr: String;
  I: Integer;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBFields := '';
  DBValues := '';
  DBFilters := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Percorre a Matriz
  for I := 0 to Data.Count - 1 do
  begin
    DBFields := DBFields + ',' + Data.Key[I] + '';
    DBValue := Data.ValuesAtIndex[I];

    // Trata Palavras Reservadas
    case AnsiIndexStr(UpperCase(String(DBValue)), ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP']) of
     0..5 : DBValues := DBValues + ',' + DBValue
    else
      DBValues := DBValues + ',' + Convert.VarToStr(DBValue);
    end;
  end;

  // Remove os Último Caractere
  System.Delete(DBFields, 1, 1);
  System.Delete(DBValues, 1, 1);
  System.Delete(DBFilters, 1, 1);

  // Obtém os Filtros
  DBFilters := Condition.ToFilter;

  // Constrói o Comando REPLACE
  ReplaceStr := 'REPLACE INTO ' + ATable + ' (' + DBFields + ') VALUES (' + DBValues + ')' + ' WHERE ' + DBFilters;

  // Deve ser Executada ?
  if Run then
    Query.Exec(ReplaceStr);

  // Retorna o Comando UPDATE
  Result := ReplaceStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Upsert(ATable: String; Data: TArray; Run: Boolean = False; Ignore : Boolean = False; Duplicate : Boolean = False): String;
var
  DBFields, DBValues, DBValue, DBReplaces, IgnoreStr, UpsertStr: String;
  I: Integer;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBFields := '';
  DBValues := '';
  DBReplaces := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Percorre a Matriz
  for I := 0 to Data.Count - 1 do
  begin
    DBFields := DBFields + ',' + Data.Names[I] + '';
    DBValue := Data.ValuesAtIndex[I];

    // Trata Palavras Reservadas
    case AnsiIndexStr(UpperCase(String(DBValue)), ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP']) of
     0..5 : DBValues := DBValues + ',' + DBValue
    else
      DBValues := DBValues + ',''' + DBValue + '''';
    end;
  end;

  // Remove os Último Caractere
  System.Delete(DBFields, 1, 1);
  System.Delete(DBValues, 1, 1);

  // Possui Cláusula Ignore ?
  if Ignore = True then
    IgnoreStr := ' IGNORE';

  // Possui Cláusula Duplicate ?
  if Duplicate = True then
  begin
    DBReplaces := ' ON DUPLICATE KEY UPDATE';
    // Percorre a Matriz
    for I := 0 to Data.Count - 1 do
      DBReplaces := DBReplaces + ' ' + Data.Names[I] + ' = ' + 'VALUES(' + Data.Names[I] + '),';

    // Remove os Último Caractere
    System.Delete(DBReplaces,Length(DBReplaces), 1);
  end;

  // Trata se Contém algum Caractere de Controle e o Remove
  if DBValues.Contains(#0) then
    DBValues := StringReplace(DBValues, #0, '',[rfReplaceAll]);

  // Constrói o Comando UPSERT
  UpsertStr := 'INSERT' + IgnoreStr + ' INTO ' + ATable + ' (' + DBFields + ') VALUES (' + DBValues + ')' + DBReplaces;

  // Deve ser Executada ?
  if Run then
    Query.Exec(UpsertStr);

  // Retorna o Comando UPSERT
  Result := UpsertStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

function TQueryBuilder.Upsert(ATable: String; Data: TArrayVariant; Run: Boolean = False; Ignore : Boolean = False; Duplicate : Boolean = False): String;
var
  DBFields, DBValues, DBValue, DBReplaces, IgnoreStr, UpsertStr: String;
  I: Integer;
  Query: TQueryBuilder;
begin
  // Inicializa Variáveis
  DBFields := '';
  DBValues := '';
  DBReplaces := '';

  // Armazena e Redefine a Configuração do Windows
  Locale.StoreWindowsLanguage();
  Locale.SetWindowsLanguage();

  // Percorre a Matriz
  for I := 0 to Data.Count - 1 do
  begin
    DBFields := DBFields + ',' + Data.Key[I] + '';
    DBValue := Data.ValuesAtIndex[I];

    // Trata Palavras Reservadas
    case AnsiIndexStr(UpperCase(String(DBValue)), ['NOW()', 'CURTIME()', 'CURDATE()', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP']) of
     0..5 : DBValues := DBValues + ',' + DBValue
    else
      DBValues := DBValues + ',' + Convert.VarToStr(DBValue);
    end;
  end;

  // Remove os Último Caractere
  System.Delete(DBFields, 1, 1);
  System.Delete(DBValues, 1, 1);

  // Possui Cláusula Ignore ?
  if Ignore = True then
    IgnoreStr := ' IGNORE';

  // Possui Cláusula Duplicate ?
  if Duplicate = True then
  begin
    DBReplaces := ' ON DUPLICATE KEY UPDATE';
    // Percorre a Matriz
    for I := 0 to Data.Count - 1 do
      DBReplaces := DBReplaces + ' ' + Data.Key[I] + ' = ' + 'VALUES(' + Data.Key[I] + '),';

    // Remove os Último Caractere
    System.Delete(DBReplaces,Length(DBReplaces), 1);
  end;

  // Trata se Contém algum Caractere de Controle e o Remove
  if DBValues.Contains(#0) then
    DBValues := StringReplace(DBValues, #0, '',[rfReplaceAll]);

  // Constrói o Comando UPSERT
  UpsertStr := 'INSERT' + IgnoreStr + ' INTO ' + ATable + ' (' + DBFields + ') VALUES (' + DBValues + ')' + DBReplaces;

  // Deve ser Executada ?
  if Run then
    Query.Exec(UpsertStr);

  // Retorna o Comando UPSERT
  Result := UpsertStr;

  // Restaura a Configuração do Windows
  Locale.RestoreWindowsLanguage();
end;

initialization

finalization

TConnectionClass.ReleaseInstance();

end.


