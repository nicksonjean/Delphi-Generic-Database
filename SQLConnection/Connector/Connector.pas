﻿{
  Connector.
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

unit Connector;

interface

{ Carrega a Interface Padrão }
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

  FMX.Dialogs,

  Data.DB,

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
  SQLConnection,
  &Array
  ;

  { Classe Utilizada para Armazenamento de Dados }
type
  TValueObject = class(TObject)
  strict private
    FValue: TValue;
  public
    constructor Create(const aValue: TValue);
    property Value: TValue read FValue;
  end;

  { Classe TConnector Herdade de TQuery }
type
  TConnector = class(TQuery)
  strict protected
    { Strict Protected declarations }
    procedure AddToEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
    procedure AddToComboEdit<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
    procedure AddToComboBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
    procedure AddToListBox<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
    procedure AddToGrid<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
    procedure AddToStringGrid<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
    procedure AddToListView<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
  strict private
    { Strict Private declarations }
    procedure AddObject<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; SelectedBy: Integer); overload;
    procedure AddObject<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; SelectedBy: TDictionary<String, TArray<Variant>>); overload;
    procedure AddObject<T: Class>(AOwner: TComponent; Index : String; Value : TObject; SelectedBy: Integer); overload;
    procedure AddObject<T: Class>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; SelectedBy: TDictionary<String, TArray<Variant>>); overload;
    procedure AddObject<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []; SelectedBy: Integer = -1); overload;
    procedure AddObject<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []; SelectedBy: TDictionary<String, TArray<Variant>> = nil); overload;
  protected
    { Strict Private declarations }
    const FItemHeight = 76;
    procedure AddItem<T: Class>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []);
  private
    { Private declarations }
    {TODO -oNickson Jeanmerson -cProgrammer : Refazer a Filtragem do ListView por Colunas Utilizando a Hidden JSON DataSet Presente no Componente}
    FItem:String;
    FText:String;
    FDetail1: String;
    FDetail2: String;
    FDetail3: String;
    FQuery: TQuery;
    function ToDataSet(Query: TQuery): {$I CNC.Type.inc};
    procedure ToFillList(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: Integer = -1); overload;
    procedure ToFillList(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: TDictionary<String, TArray<Variant>> = nil); overload;
    procedure ToMultiList(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String> = []; SelectedBy: Integer = -1); overload;
    procedure ToMultiList(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String> = []; SelectedBy: TDictionary<String, TArray<Variant>> = nil); overload;
    procedure ToGridTable(AOwner: TComponent; SelectedBy: Integer = -1); overload;
    procedure ToGridTable(AOwner: TComponent; SelectedBy: TDictionary<String, TArray<Variant>> = nil); overload;
  public
    { Public declarations }
    constructor Create(Query: TQuery);
    destructor Destroy; override;
    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente nos componentes <c>TGrid</c> e/ou <c>TStringGrid</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToGrid(GridComponent, 0);</para>
    ///     <para>  finally</para>
    ///     <para>    Connector.Destroy;</para>
    ///     <para>  end;</para>
    ///     <para>finally</para>
    ///     <para>  SQL.Destroy;</para>
    ///     <para>end;</para>
    ///   </code>
    /// </summary>
    /// <param name="AOwner:Requerido">
    ///   O componente do tipo <c>TGrid</c> e/ou <c>TStringGrid</c> que se quer popular
    /// </param>
    /// <param name="SelectedBy:Opcional[¹]">
    ///   O índice numérico da linha do <c>TListBox</c> que se quer selecionar
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>SelectedBy</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>-1</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToGrid'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToGrid(AOwner: TComponent; SelectedBy : Integer = -1); overload;
    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente nos componentes <c>TGrid</c> e/ou <c>TStringGrid</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToGrid(GridComponent1, TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</para>
    ///     <para>    Connector.ToGrid(GridComponent2, TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</para>
    ///     <para>  finally</para>
    ///     <para>    Connector.Destroy;</para>
    ///     <para>  end;</para>
    ///     <para>finally</para>
    ///     <para>  SQL.Destroy;</para>
    ///     <para>end;</para>
    ///   </code>
    /// </summary>
    /// <param name="AOwner:Requerido">
    ///   O componente do tipo <c>TGrid</c> e/ou <c>TStringGrid</c> que se quer popular
    /// </param>
    /// <param name="SelectedBy:Opcional[¹]">
    ///   Matriz utilizada para selecionar uma linha do componente, possuindo duas formas:
    ///   <para>1) Seleção por índice: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</c></para>
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>SelectedBy</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>nil</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToGrid'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToGrid(AOwner: TComponent; SelectedBy : TDictionary<String, TArray<Variant>> = nil); overload;
    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente no componente <c>TEdit</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToEdit(EditComponent0, 'DBField1', 'DBField2', 0);</para>
    ///     <para>  finally</para>
    ///     <para>    Connector.Destroy;</para>
    ///     <para>  end;</para>
    ///     <para>finally</para>
    ///     <para>  SQL.Destroy;</para>
    ///     <para>end;</para>
    ///   </code>
    /// </summary>
    /// <param name="AOwner:Requerido">
    ///   O componente do tipo <c>TEdit</c> que se quer popular
    /// </param>
    /// <param name="IndexField:Requerido">
    ///   Uma coluna para indexação de preferência o Auto-Incremento da consulta
    /// </param>
    /// <param name="ValueField:Requerido">
    ///   A coluna que se quer exibir na listagem
    /// </param>
    /// <param name="SelectedBy:Opcional[¹]">
    ///   O índice numérico da linha do <c>TEdit</c> que se quer selecionar
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>SelectedBy</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>-1</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToEdit'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToEdit(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: Integer = -1); overload;
    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente no componente <c>TEdit</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToEdit(EditComponent1, 'DBField1', 'DBField2', TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</para>
    ///     <para>    Connector.ToEdit(EditComponent2, 'DBField1', 'DBField2', TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</para>
    ///     <para>  finally</para>
    ///     <para>    Connector.Destroy;</para>
    ///     <para>  end;</para>
    ///     <para>finally</para>
    ///     <para>  SQL.Destroy;</para>
    ///     <para>end;</para>
    ///   </code>
    /// </summary>
    /// <param name="AOwner:Requerido">
    ///   O componente do tipo <c>TEdit</c> que se quer popular
    /// </param>
    /// <param name="IndexField:Requerido">
    ///   Uma coluna para indexação de preferência o Auto-Incremento da consulta
    /// </param>
    /// <param name="ValueField:Requerido">
    ///   A coluna que se quer exibir na listagem
    /// </param>
    /// <param name="SelectedBy:Opcional[¹]">
    ///   Matriz utilizada para selecionar uma linha do componente, possuindo duas formas:
    ///   <para>1) Seleção por índice: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</c></para>
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>SelectedBy</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>nil</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToEdit'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToEdit(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: TDictionary<String, TArray<Variant>> = nil); overload;
    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente nos componentes <c>TComboBox</c>, <c>TComboEdit</c> e/ou <c>TEdit</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToCombo(ComboComponent0, 'DBField1', 'DBField2', 0);</para>
    ///     <para>  finally</para>
    ///     <para>    Connector.Destroy;</para>
    ///     <para>  end;</para>
    ///     <para>finally</para>
    ///     <para>  SQL.Destroy;</para>
    ///     <para>end;</para>
    ///   </code>
    /// </summary>
    /// <param name="AOwner:Requerido">
    ///   O componente do tipo <c>TComboBox</c>, <c>TComboEdit</c> e/ou <c>TEdit</c> que se quer popular
    /// </param>
    /// <param name="IndexField:Requerido">
    ///   Uma coluna para indexação de preferência o Auto-Incremento da consulta
    /// </param>
    /// <param name="ValueField:Requerido">
    ///   A coluna que se quer exibir na listagem
    /// </param>
    /// <param name="SelectedBy:Opcional[¹]">
    ///   O índice numérico da linha do <c>TComboBox</c>, <c>TComboEdit</c> e/ou <c>TEdit</c> que se quer selecionar
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>SelectedBy</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>-1</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'TComboBox|TComboEdit|TEdit'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToCombo(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: Integer = -1); overload;
    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente nos componentes <c>TComboBox</c>, <c>TComboEdit</c> e/ou <c>TEdit</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToCombo(ComboComponent1, TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</para>
    ///     <para>    Connector.ToCombo(ComboComponent2, TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</para>
    ///     <para>  finally</para>
    ///     <para>    Connector.Destroy;</para>
    ///     <para>  end;</para>
    ///     <para>finally</para>
    ///     <para>  SQL.Destroy;</para>
    ///     <para>end;</para>
    ///   </code>
    /// </summary>
    /// <param name="AOwner:Requerido">
    ///   O componente do tipo <c>TComboBox</c>, <c>TComboEdit</c> e/ou <c>TEdit</c> que se quer popular
    /// </param>
    /// <param name="IndexField:Requerido">
    ///   Uma coluna para indexação de preferência o Auto-Incremento da consulta
    /// </param>
    /// <param name="ValueField:Requerido">
    ///   A coluna que se quer exibir na listagem
    /// </param>
    /// <param name="SelectedBy:Opcional[¹]">
    ///   Matriz utilizada para selecionar uma linha do componente, possuindo duas formas:
    ///   <para>1) Seleção por indice: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</c></para>
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>SelectedBy</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>nil</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'TComboBox|TComboEdit|TEdit'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToCombo(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: TDictionary<String, TArray<Variant>> = nil); overload;
    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente no componente <c>TListBox</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToListBox(ListBoxComponent0, 'DBField1', 'DBField2', 0);</para>
    ///     <para>  finally</para>
    ///     <para>    Connector.Destroy;</para>
    ///     <para>  end;</para>
    ///     <para>finally</para>
    ///     <para>  SQL.Destroy;</para>
    ///     <para>end;</para>
    ///   </code>
    /// </summary>
    /// <param name="AOwner:Requerido">
    ///   O componente do tipo <c>TListBox</c> que se quer popular
    /// </param>
    /// <param name="IndexField:Requerido">
    ///   Uma coluna para indexação de preferência o Auto-Incremento da consulta
    /// </param>
    /// <param name="ValueField:Requerido">
    ///   A coluna que se quer exibir na listagem
    /// </param>
    /// <param name="SelectedBy:Opcional[¹]">
    ///   O índice numérico da linha do <c>TListBox</c> que se quer selecionar
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>SelectedBy</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>-1</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToListBox'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToListBox(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: Integer = -1); overload;
    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente no componente <c>TListBox</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToListBox(ListBoxComponent1, 'DBField1', 'DBField2', TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</para>
    ///     <para>    Connector.ToListBox(ListBoxComponent2, 'DBField1', 'DBField2', TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</para>
    ///     <para>  finally</para>
    ///     <para>    Connector.Destroy;</para>
    ///     <para>  end;</para>
    ///     <para>finally</para>
    ///     <para>  SQL.Destroy;</para>
    ///     <para>end;</para>
    ///   </code>
    /// </summary>
    /// <param name="AOwner:Requerido">
    ///   O componente do tipo <c>TListBox</c> que se quer popular
    /// </param>
    /// <param name="IndexField:Requerido">
    ///   Uma coluna para indexação de preferência o Auto-Incremento da consulta
    /// </param>
    /// <param name="ValueField:Requerido">
    ///   A coluna que se quer exibir na listagem
    /// </param>
    /// <param name="SelectedBy:Opcional[¹]">
    ///   Matriz utilizada para selecionar uma linha do componente, possuindo duas formas:
    ///   <para>1) Seleção por índice: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</c></para>
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>SelectedBy</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>nil</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToListBox'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToListBox(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: TDictionary<String, TArray<Variant>> = nil); overload;
    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente no componente <c>TListView</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToListView(ListViewComponent0, 'DBField1', 'DBField2', [DetailFields], 0);</para>
    ///     <para>  finally</para>
    ///     <para>    Connector.Destroy;</para>
    ///     <para>  end;</para>
    ///     <para>finally</para>
    ///     <para>  SQL.Destroy;</para>
    ///     <para>end;</para>
    ///   </code>
    /// </summary>
    /// <param name="AOwner:Requerido">
    ///   O componente do tipo <c>TListView</c> que se quer popular
    /// </param>
    /// <param name="IndexField:Requerido">
    ///   Uma coluna para indexação de preferência o Auto-Incremento da consulta
    /// </param>
    /// <param name="ValueField:Requerido">
    ///   A coluna que se quer exibir na listagem
    /// </param>
    /// <param name="DetailFields:Opcional[²]">
    ///   As colunas adicionais que se quer exibir na listagem, até o máximo de 3 colunas
    /// </param>
    /// <param name="SelectedBy:Opcional[¹]">
    ///   O índice numérico da linha do <c>TListView</c> que se quer selecionar
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>SelectedBy</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>-1</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToListView'</c>, informando que há uma ambiguidade de métodos</para>
    ///   <para>[²]: O parâmetro <c>DetailFields</c> é uma matriz de strings que pode conter de 0 à 3 índices, no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>[]</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToListView'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToListView(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String> = []; SelectedBy: Integer = -1); overload;
    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente no componente <c>TListView</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToListView(ListViewComponent1, 'DBField1', 'DBField2', [DetailFields], TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</para>
    ///     <para>    Connector.ToListView(ListViewComponent2, 'DBField1', 'DBField2', [DetailFields], TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</para>
    ///     <para>  finally</para>
    ///     <para>    Connector.Destroy;</para>
    ///     <para>  end;</para>
    ///     <para>finally</para>
    ///     <para>  SQL.Destroy;</para>
    ///     <para>end;</para>
    ///   </code>
    /// </summary>
    /// <param name="AOwner:Requerido">
    ///   O componente do tipo <c>TListView</c> que se quer popular
    /// </param>
    /// <param name="IndexField:Requerido">
    ///   Uma coluna para indexação de preferência o Auto-Incremento da consulta
    /// </param>
    /// <param name="ValueField:Requerido">
    ///   A coluna que se quer exibir na listagem
    /// </param>
    /// <param name="DetailFields:Opcional[²]">
    ///   As colunas adicionais que se quer exibir na listagem, até o máximo de 3 colunas
    /// </param>
    /// <param name="SelectedBy:Opcional[¹]">
    ///   Matriz utilizada para selecionar uma linha do componente, possuindo duas formas:
    ///   <para>1) Seleção por índice: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</c></para>
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>SelectedBy</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>nil</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToListView'</c>, informando que há uma ambiguidade de métodos</para>
    ///   <para>[²]: O parâmetro <c>DetailFields</c> é uma matriz de strings que pode conter de 0 à 3 índices, no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>[]</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToListView'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToListView(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String> = []; SelectedBy: TDictionary<String, TArray<Variant>> = nil); overload;
  end;

implementation

{ TValueObject }

constructor TValueObject.Create(const aValue: TValue);
begin
  FValue := aValue;
end;

{ TConnector }

constructor TConnector.Create(Query : TQuery);
begin
  inherited Create;

  Self.FQuery := Query;
end;

procedure TConnector.AddObject<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; SelectedBy : Integer);
begin
  if (TypeInfo(T) = TypeInfo(TGrid)) then
  begin
    TGrid(AOwner).Options := [TGridOption.AlternatingRowBackground, TGridOption.RowSelect, TGridOption.ColumnResize, TGridOption.ColumnMove, TGridOption.ColLines, TGridOption.RowLines, TGridOption.Tabs, TGridOption.Header, TGridOption.HeaderClick, TGridOption.AutoDisplacement];
    TGrid(AOwner).FillData := DataSet;
    TGrid(AOwner).AutoSizeColumns := True;

    if SelectedBy <> -1 then
    begin
      TGrid(AOwner).Row := SelectedBy;
      TGrid(AOwner).Col := 0;
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TStringGrid)) then
  begin
    TStringGrid(AOwner).Options := [TGridOption.AlternatingRowBackground, TGridOption.RowSelect, TGridOption.ColumnResize, TGridOption.ColumnMove, TGridOption.ColLines, TGridOption.RowLines, TGridOption.Tabs, TGridOption.Header, TGridOption.HeaderClick, TGridOption.AutoDisplacement];
    TStringGrid(AOwner).FillData := DataSet;
    TStringGrid(AOwner).AutoSizeColumns := True;

    if SelectedBy <> -1 then
    begin
      TStringGrid(AOwner).Row := SelectedBy;
      TStringGrid(AOwner).Col := 0;
    end;
  end;
end;

procedure TConnector.AddObject<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; SelectedBy : TDictionary<String, TArray<Variant>>);
begin
  if (TypeInfo(T) = TypeInfo(TGrid)) then
    Self.AddToGrid<TGrid>(AOwner, DataSet, SelectedBy)
  else if (TypeInfo(T) = TypeInfo(TStringGrid)) then
    Self.AddToStringGrid<TStringGrid>(AOwner, DataSet, SelectedBy);
end;

procedure TConnector.AddObject<T>(AOwner: TComponent; Index: String; Value: TObject; SelectedBy: Integer);
begin
  if (TypeInfo(T) = TypeInfo(TEdit)) then
  begin
    TEdit(AOwner).Items.BeginUpdate;
    try
      TEdit(AOwner).Items.AddObject(Index, TValueObject.Create(Value));
      if TEdit(AOwner).Items.IndexOf(Index) = SelectedBy then
        TEdit(AOwner).ItemIndex := SelectedBy;
    finally
      TEdit(AOwner).Items.EndUpdate;
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TComboEdit)) then
  begin
    TComboEdit(AOwner).Items.BeginUpdate;
    try
      TComboEdit(AOwner).Items.AddObject(Index, TValueObject.Create(Value));
      if TComboEdit(AOwner).Items.IndexOf(Index) = SelectedBy then
        TComboEdit(AOwner).ItemIndex := SelectedBy;
    finally
      TComboEdit(AOwner).Items.EndUpdate;
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TComboBox)) then
  begin
    TComboBox(AOwner).Items.BeginUpdate;
    try
      TComboBox(AOwner).Items.AddObject(Index, TValueObject.Create(Value));
      if TComboBox(AOwner).Items.IndexOf(Index) = SelectedBy then
        TComboBox(AOwner).ItemIndex := SelectedBy;
    finally
      TComboBox(AOwner).Items.EndUpdate;
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TListBox)) then
  begin
    TListBox(AOwner).Items.BeginUpdate;
    try
      TListBox(AOwner).Items.AddObject(Index, TValueObject.Create(Value));
      if TListBox(AOwner).Items.IndexOf(Index) = SelectedBy then
        TListBox(AOwner).ItemIndex := SelectedBy;
    finally
      TListBox(AOwner).Items.EndUpdate;
    end;
  end;
end;

procedure TConnector.AddToEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
var
  Pair: TPair<String, TArray<Variant>>;
begin
  TEdit(AOwner).Items.BeginUpdate;
  try
    TEdit(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));
    if SelectedBy <> nil then
    begin
      for Pair in SelectedBy do
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

procedure TConnector.AddToComboEdit<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
var
  Pair: TPair<String, TArray<Variant>>;
begin
  TComboEdit(AOwner).Items.BeginUpdate;
  try
    TComboEdit(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));
    if SelectedBy <> nil then
    begin
      for Pair in SelectedBy do
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

procedure TConnector.AddToComboBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
var
  Pair: TPair<String, TArray<Variant>>;
begin
  TComboBox(AOwner).Items.BeginUpdate;
  try
    TComboBox(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));
    if SelectedBy <> nil then
    begin
      for Pair in SelectedBy do
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

procedure TConnector.AddToListBox<T>(AOwner: TComponent; FieldIndexValue, IndexValue: TArray<String>; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
var
  Pair: TPair<String, TArray<Variant>>;
begin
  TListBox(AOwner).Items.BeginUpdate;
  try
    TListBox(AOwner).Items.AddObject(IndexValue[0], TValueObject.Create(IndexValue[1]));
    if SelectedBy <> nil then
    begin
      for Pair in SelectedBy do
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

procedure TConnector.AddToGrid<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
var
  Row, Column: Integer;
  Pair: TPair<String, TArray<Variant>>;
begin
  TGrid(AOwner).Options := [TGridOption.AlternatingRowBackground, TGridOption.RowSelect, TGridOption.ColumnResize, TGridOption.ColumnMove, TGridOption.ColLines, TGridOption.RowLines, TGridOption.Tabs, TGridOption.Header, TGridOption.HeaderClick, TGridOption.AutoDisplacement];
  TGrid(AOwner).FillData := DataSet;
  TGrid(AOwner).AutoSizeColumns := True;

  if SelectedBy <> nil then
  begin
    for Pair in SelectedBy do
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

procedure TConnector.AddToStringGrid<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
var
  I, J: Integer;
  Pair: TPair<String, TArray<Variant>>;
begin
  TStringGrid(AOwner).Options := [TGridOption.AlternatingRowBackground, TGridOption.RowSelect, TGridOption.ColumnResize, TGridOption.ColumnMove, TGridOption.ColLines, TGridOption.RowLines, TGridOption.Tabs, TGridOption.Header, TGridOption.HeaderClick, TGridOption.AutoDisplacement];
  TStringGrid(AOwner).FillData := DataSet;
  TStringGrid(AOwner).AutoSizeColumns := True;

  if SelectedBy <> nil then
  begin
    for Pair in SelectedBy do
    begin
      if Pair.Key = 'Index' then
      begin
        for I := 0 to TStringGrid(AOwner).RowCount - 1 do
        begin
          if (I = Pair.Value[0]) then
          begin
            TStringGrid(AOwner).Row := Pair.Value[0];
            TStringGrid(AOwner).Col := 0;
            Break;
          end;
        end;
      end
      else if Pair.Key = 'Field' then
      begin
        for I := 0 to TStringGrid(AOwner).ColumnCount - 1 do
        begin
          if TStringGrid(AOwner).ColumnByIndex(I).Header = Pair.Value[0] then
          begin
            J := 0;
            DataSet.First;
            while not DataSet.Eof do
            begin
              if DataSet.Fields[I].AsString = Pair.Value[1] then
              begin
                TStringGrid(AOwner).Row := J;
                TStringGrid(AOwner).Col := 0;
                Break;
              end;
              Inc(J);
              DataSet.Next;
            end;
            DataSet.Last;
          end;
        end;
      end;
    end;
  end;
end;

procedure TConnector.AddToListView<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
var
  I, J: Integer;
  Pair: TPair<String, TArray<Variant>>;
begin
  TListView(AOwner).BeginUpdate;
  try
    Self.AddItem<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields);
    if SelectedBy <> nil then
    begin
      for Pair in SelectedBy do
      begin
        if Pair.Key = 'Index' then
        begin
          for I := 0 to TListView(AOwner).Items.Count - 1 do
          begin
            if (I = Pair.Value[0]) then
            begin
              TListView(AOwner).ItemIndex := Pair.Value[0];
              Break;
            end;
          end;
        end
        else if Pair.Key = 'Field' then
        begin
          if FText = Pair.Value[0] then
            TListView(AOwner).ItemIndex := TListView(AOwner).FindItemByValue(Pair.Value[1])
          else if FDetail1 = Pair.Value[0] then
            TListView(AOwner).ItemIndex := TListView(AOwner).FindItemByName(Pair.Value[1], TMultiDetailAppearanceNames.Detail1)
          else if FDetail2 = Pair.Value[0] then
            TListView(AOwner).ItemIndex := TListView(AOwner).FindItemByName(Pair.Value[1], TMultiDetailAppearanceNames.Detail2)
          else if FDetail3 = Pair.Value[0] then
            TListView(AOwner).ItemIndex := TListView(AOwner).FindItemByName(Pair.Value[1], TMultiDetailAppearanceNames.Detail3)
          else
            TListView(AOwner).ItemIndex := Pair.Value[1];
        end;
      end;
    end;

  finally
    TListView(AOwner).EndUpdate;
  end;
end;

procedure TConnector.AddObject<T>(AOwner: TComponent; FieldIndexValue, IndexValue : TArray<String>; SelectedBy : TDictionary<String, TArray<Variant>>);
begin
  if (TypeInfo(T) = TypeInfo(TEdit)) then
    Self.AddToEdit<TEdit>(AOwner, FieldIndexValue, IndexValue, SelectedBy)
  else if (TypeInfo(T) = TypeInfo(TComboEdit)) then
    Self.AddToComboEdit<TComboEdit>(AOwner, FieldIndexValue, IndexValue, SelectedBy)
  else if (TypeInfo(T) = TypeInfo(TComboBox)) then
    Self.AddToComboBox<TComboBox>(AOwner, FieldIndexValue, IndexValue, SelectedBy)
  else if (TypeInfo(T) = TypeInfo(TListBox)) then
    Self.AddToListBox<TListBox>(AOwner, FieldIndexValue, IndexValue, SelectedBy);
end;

procedure TConnector.AddItem<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []);
var
  Item: TListViewItem;
  I, ItemHeight: Integer;
  Dados: TArrayVariant;
begin
  ItemHeight := FItemHeight;
  if Length(DetailFields) > 0 then
    ItemHeight := 19 * (Length(DetailFields) + 1)
  else
    ItemHeight := 19;

  if (TypeInfo(T) = TypeInfo(TListView)) then
  begin
    TListView(AOwner).BeginUpdate;
    try
      DataSet.First;
      while not(DataSet.Eof) do
      begin
        Item := TListView(AOwner).Items.Add;
        Item.Index := DataSet.FieldByName(IndexField).AsInteger;
        Item.Text := DataSet.FieldByName(ValueField).AsString;
        Item.Height := ItemHeight;

        FItem := IndexField;
        FText := ValueField;
        if Length(DetailFields) > 0 then
        begin
          if Length(DetailFields) = 1 then
          begin
            if DetailFields[0] <> EmptyStr then
            begin
              FDetail1 := DetailFields[0];
              Item.Data[TMultiDetailAppearanceNames.Detail1] := DataSet.FieldByName(DetailFields[0]).AsString;
            end;
          end;
          if Length(DetailFields) = 2 then
          begin
            if DetailFields[0] <> EmptyStr then
            begin
              FDetail1 := DetailFields[0];
              Item.Data[TMultiDetailAppearanceNames.Detail1] := DataSet.FieldByName(DetailFields[0]).AsString;
            end;
            if DetailFields[1] <> EmptyStr then
            begin
              FDetail2 := DetailFields[1];
              Item.Data[TMultiDetailAppearanceNames.Detail2] := DataSet.FieldByName(DetailFields[1]).AsString;
            end;
          end;
          if Length(DetailFields) = 3 then
          begin
            if DetailFields[0] <> EmptyStr then
            begin
              FDetail1 := DetailFields[0];
              Item.Data[TMultiDetailAppearanceNames.Detail1] := DataSet.FieldByName(DetailFields[0]).AsString;
            end;
            if DetailFields[1] <> EmptyStr then
            begin
              FDetail2 := DetailFields[1];
              Item.Data[TMultiDetailAppearanceNames.Detail2] := DataSet.FieldByName(DetailFields[1]).AsString;
            end;
            if DetailFields[2] <> EmptyStr then
            begin
              FDetail3 := DetailFields[2];
              Item.Data[TMultiDetailAppearanceNames.Detail3] := DataSet.FieldByName(DetailFields[2]).AsString;
            end;
          end;
        end;

        // Armazena Todo o ResultRow da Query SQL
        Dados := TArrayVariant.Create;
        Dados.Clear;
        for I := 0 to DataSet.FieldDefs.Count - 1 do
          Dados[DataSet.FieldDefs[I].Name] := DataSet.FieldByName(DataSet.FieldDefs[I].Name).Value;
        Item.Data[TMultiDetailAppearanceNames.Detail4] := Dados.ToJSON;
        Dados.Destroy;

  { TODO -oNickson Jeanmerson -cProgrammer :
  1) Adicionar Suporte à Imagens via Blog com TImage/TBitmap e ImageString em Base64;
  2) Adicionar Suporte à Accessory; }

        //Item.BitmapRef := ImageRAD.Bitmap;
        DataSet.Next;
      end;
      DataSet.Last;
      DataSet.Destroy;

    finally
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
        end
      end
    );
  end;
end;

procedure TConnector.AddObject<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []; SelectedBy : Integer = -1);
begin
  if (TypeInfo(T) = TypeInfo(TListView)) then
  begin
    Self.AddItem<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields);
    if SelectedBy <> 0 then
      TListView(AOwner).ItemIndex := SelectedBy;
  end;
end;

procedure TConnector.AddObject<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []; SelectedBy : TDictionary<String, TArray<Variant>> = nil);
begin
  if (TypeInfo(T) = TypeInfo(TListView)) then
    Self.AddToListView<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields, SelectedBy);
end;

function TConnector.ToDataSet(Query: TQuery): {$I CNC.Type.inc};
var
  DataSet : {$I CNC.Type.inc};
{$IF DEFINED(dbExpressLib) OR DEFINED(ZeOSLib)}
  DataSetProvider : TDataSetProvider;
{$ENDIF}
begin
{$IF DEFINED(FireDACLib)}
  DataSet := {$I CNC.Type.inc}.Create(Query.Query);
  Query.Query.FetchOptions.Unidirectional := False;
  Query.Query.Open;
  Query.Query.FetchAll;
  DataSet.Data := Query.Query.Data;
{$ENDIF}
{$IF DEFINED(dbExpressLib) OR DEFINED(ZeOSLib)}
  DataSetProvider := TDataSetProvider.Create(Query.Query);
  DataSetProvider.DataSet := Query.Query;
  DataSet := {$I CNC.Type.inc}.Create(DataSetProvider);
  DataSet.Data := DataSetProvider.Data;
  DataSet.Active := True;
{$ENDIF}
  DataSet.First;
  while not DataSet.Eof do begin
    DataSet.Edit;
    DataSet.Post;
    DataSet.Next;
  end;
  DataSet.Last;
  Result := DataSet;
end;

procedure TConnector.ToFillList(AOwner: TComponent; IndexField, ValueField: String; SelectedBy : Integer = -1);
var
  I: Integer;
  Items : TStringList;
  DataSet : {$I CNC.Type.inc};
begin
  if (AOwner is TEdit) and (TEdit(AOwner) <> nil) and (TEdit(AOwner).Items.Count > 0) then
    TEdit(AOwner).Items.Clear
  else if (AOwner is TComboEdit) and (TComboEdit(AOwner) <> nil) and (TComboEdit(AOwner).Items.Count > 0) then
    TComboEdit(AOwner).Items.Clear
  else if (AOwner is TComboBox) and (TComboBox(AOwner) <> nil) and (TComboBox(AOwner).Items.Count > 0) then
    TComboBox(AOwner).Items.Clear
  else if (AOwner is TListBox) and (TListBox(AOwner) <> nil) and (TListBox(AOwner).Items.Count > 0) then
  begin
    TListBox(AOwner).Items.Clear;
    TListBox(AOwner).EmptyFilter;
  end;

  if AOwner Is TComboBox then
  begin
    TComboBox(AOwner).DropDownKind := TDropDownKind.Custom;
    TComboBox(AOwner).AutoComplete := True;
  end
  else if AOwner Is TComboEdit then
  begin
    TComboEdit(AOwner).DropDownKind := TDropDownKind.Custom;
    TComboEdit(AOwner).AutoComplete := True;
  end;

  DataSet := Self.ToDataSet(Self.FQuery);

  if DataSet.RecordCount > 0 then
  begin
    Items := TStringList.Create(True);

    DataSet.First;
    while not(DataSet.Eof) do
    begin
      Items.AddPair(DataSet.FieldByName(ValueField).AsString, DataSet.FieldByName(IndexField).AsString);
      DataSet.Next;
    end;
    DataSet.Last;

    for I := 0 to Items.Count - 1 do
    begin
      if (AOwner is TEdit) then
        Self.AddObject<TEdit>(AOwner, Items.Names[I], TValueObject.Create(Items.ValueFromIndex[I]), SelectedBy)
      else if AOwner Is TComboEdit then
        Self.AddObject<TComboEdit>(AOwner, Items.Names[I], TValueObject.Create(Items.ValueFromIndex[I]), SelectedBy)
      else if AOwner Is TComboBox then
        Self.AddObject<TComboBox>(AOwner, Items.Names[I], TValueObject.Create(Items.ValueFromIndex[I]), SelectedBy)
      else if AOwner Is TListBox then
        Self.AddObject<TListBox>(AOwner, Items.Names[I], TValueObject.Create(Items.ValueFromIndex[I]), SelectedBy);
    end;
    Items.Destroy;

    if AOwner Is TComboBox then
      TListBox(TComboBox(AOwner).ListBox).AlternatingRowBackground := True
    else if AOwner Is TComboEdit then
      TListBox(TComboEdit(AOwner).ListBox).AlternatingRowBackground := True
    else if AOwner Is TListBox then
      TListBox(AOwner).AlternatingRowBackground := True;
  end;
  DataSet.Destroy;
end;

procedure TConnector.ToFillList(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: TDictionary<String, TArray<Variant>>);
var
  I: Integer;
  Items : TStringList;
  DataSet : {$I CNC.Type.inc};
begin
  if (AOwner is TEdit) and (TEdit(AOwner) <> nil) and (TEdit(AOwner).Items.Count > 0) then
    TEdit(AOwner).Items.Clear
  else if (AOwner is TComboEdit) and (TComboEdit(AOwner) <> nil) and (TComboEdit(AOwner).Items.Count > 0) then
    TComboEdit(AOwner).Items.Clear
  else if (AOwner is TComboBox) and (TComboBox(AOwner) <> nil) and (TComboBox(AOwner).Items.Count > 0) then
    TComboBox(AOwner).Items.Clear
  else if (AOwner is TListBox) and (TListBox(AOwner) <> nil) and (TListBox(AOwner).Items.Count > 0) then
  begin
    TListBox(AOwner).Items.Clear;
    TListBox(AOwner).EmptyFilter;
  end;

  if AOwner Is TComboBox then
  begin
    TComboBox(AOwner).DropDownKind := TDropDownKind.Custom;
    TComboBox(AOwner).AutoComplete := True;
  end
  else if AOwner Is TComboEdit then
  begin
    TComboEdit(AOwner).DropDownKind := TDropDownKind.Custom;
    TComboEdit(AOwner).AutoComplete := True;
  end;

  DataSet := Self.ToDataSet(Self.FQuery);

  if DataSet.RecordCount > 0 then
  begin
    Items := TStringList.Create(True);

    DataSet.First;
    while not(DataSet.Eof) do
    begin
      Items.AddPair(DataSet.FieldByName(ValueField).AsString, DataSet.FieldByName(IndexField).AsString);
      DataSet.Next;
    end;
    DataSet.Last;

    for I := 0 to Items.Count - 1 do
    begin
      if AOwner Is TEdit then
        Self.AddObject<TEdit>(AOwner, [IndexField, ValueField], [Items.Names[I], Items.ValueFromIndex[I]], SelectedBy)
      else if AOwner Is TComboEdit then
        Self.AddObject<TComboEdit>(AOwner, [IndexField, ValueField], [Items.Names[I], Items.ValueFromIndex[I]], SelectedBy)
      else if AOwner Is TComboBox then
        Self.AddObject<TComboBox>(AOwner, [IndexField, ValueField], [Items.Names[I], Items.ValueFromIndex[I]], SelectedBy)
      else if AOwner Is TListBox then
        Self.AddObject<TListBox>(AOwner, [IndexField, ValueField], [Items.Names[I], Items.ValueFromIndex[I]], SelectedBy);
    end;
    Items.Destroy;

    if AOwner Is TComboBox then
      TListBox(TComboBox(AOwner).ListBox).AlternatingRowBackground := True
    else if AOwner Is TComboEdit then
      TListBox(TComboEdit(AOwner).ListBox).AlternatingRowBackground := True
    else if AOwner Is TListBox then
      TListBox(AOwner).AlternatingRowBackground := True;
  end;
  DataSet.Destroy;
end;

procedure TConnector.ToMultiList(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String> = []; SelectedBy : Integer = -1);
var
  DataSet : {$I CNC.Type.inc};
begin
  TListView(AOwner).ItemAppearanceClassName := 'TMultiDetailItemAppearance';
  TListView(AOwner).ItemEditAppearanceClassName := 'TMultiDetailDeleteAppearance';

  if (AOwner is TListView) and (TListView(AOwner) <> nil) and (TListView(AOwner).Items.Count > 0) then
  begin
    TListView(AOwner).Items.Clear;
    TListView(AOwner).EmptyFilter;
  end;

  DataSet := Self.ToDataSet(Self.FQuery);

  if DataSet.RecordCount > 0 then
  begin
    if (AOwner is TListView) then
      Self.AddObject<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields, SelectedBy);
  end;

  if AOwner Is TListView then
    TListView(AOwner).AlternatingColors := True;
end;

procedure TConnector.ToMultiList(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String>; SelectedBy: TDictionary<String, TArray<Variant>>);
var
  DataSet : {$I CNC.Type.inc};
begin
  TListView(AOwner).ItemAppearanceClassName := 'TMultiDetailItemAppearance';
  TListView(AOwner).ItemEditAppearanceClassName := 'TMultiDetailDeleteAppearance';

  if (AOwner is TListView) and (TListView(AOwner) <> nil) and (TListView(AOwner).Items.Count > 0) then
  begin
    TListView(AOwner).Items.Clear;
    TListView(AOwner).EmptyFilter;
  end;

  DataSet := Self.ToDataSet(Self.FQuery);

  if DataSet.RecordCount > 0 then
  begin
    if (AOwner is TListView) then
      Self.AddObject<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields, SelectedBy);
  end;

  if AOwner Is TListView then
    TListView(AOwner).AlternatingColors := True;
end;

procedure TConnector.ToGridTable(AOwner: TComponent; SelectedBy : Integer = -1);
var
  DataSet : {$I CNC.Type.inc};
begin
  if (AOwner is TStringGrid) and (TStringGrid(AOwner) <> nil) then
    TStringGrid(AOwner).ClearColumns
  else if (AOwner is TGrid) and (TGrid(AOwner) <> nil) then
    TGrid(AOwner).ClearColumns;

  DataSet := Self.ToDataSet(Self.FQuery);

  if DataSet.RecordCount > 0 then
  begin
    if AOwner Is TStringGrid then
      Self.AddObject<TStringGrid>(AOwner, DataSet, SelectedBy)
    else if AOwner Is TGrid then
      Self.AddObject<TGrid>(AOwner, DataSet, SelectedBy);
  end;
end;

procedure TConnector.ToGridTable(AOwner: TComponent; SelectedBy : TDictionary<String, TArray<Variant>> = nil);
var
  DataSet : {$I CNC.Type.inc};
begin
  if (AOwner is TStringGrid) and (TStringGrid(AOwner) <> nil) then
    TStringGrid(AOwner).ClearColumns
  else if (AOwner is TGrid) and (TGrid(AOwner) <> nil) then
    TGrid(AOwner).ClearColumns;

  DataSet := Self.ToDataSet(Self.FQuery);

  if DataSet.RecordCount > 0 then
  begin
    if AOwner Is TStringGrid then
      Self.AddObject<TStringGrid>(AOwner, DataSet, SelectedBy)
    else if AOwner Is TGrid then
      Self.AddObject<TGrid>(AOwner, DataSet, SelectedBy);
  end;
end;

procedure TConnector.ToGrid(AOwner: TComponent; SelectedBy : Integer = -1);
begin
  Self.ToGridTable(AOwner, SelectedBy);
end;

procedure TConnector.ToGrid(AOwner: TComponent; SelectedBy: TDictionary<String, TArray<Variant>>);
begin
  Self.ToGridTable(AOwner, SelectedBy);
end;

procedure TConnector.ToEdit(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: Integer);
begin
  Self.ToFillList(AOwner, IndexField, ValueField, SelectedBy);
end;

procedure TConnector.ToEdit(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: TDictionary<String, TArray<Variant>>);
begin
  Self.ToFillList(AOwner, IndexField, ValueField, SelectedBy);
end;

procedure TConnector.ToCombo(AOwner: TComponent; IndexField, ValueField: String; SelectedBy : Integer = -1);
begin
  Self.ToFillList(AOwner, IndexField, ValueField, SelectedBy);
end;

procedure TConnector.ToCombo(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: TDictionary<String, TArray<Variant>> = nil);
begin
  Self.ToFillList(AOwner, IndexField, ValueField, SelectedBy);
end;

procedure TConnector.ToListBox(AOwner: TComponent; IndexField, ValueField: String; SelectedBy : Integer = -1);
begin
  Self.ToFillList(AOwner, IndexField, ValueField, SelectedBy);
end;

procedure TConnector.ToListBox(AOwner: TComponent; IndexField, ValueField: String; SelectedBy: TDictionary<String, TArray<Variant>>);
begin
  Self.ToFillList(AOwner, IndexField, ValueField, SelectedBy);
end;

procedure TConnector.ToListView(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String> = []; SelectedBy : Integer = -1);
begin
  Self.ToMultiList(AOwner, IndexField, ValueField, DetailFields, SelectedBy);
end;

procedure TConnector.ToListView(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String>; SelectedBy: TDictionary<String, TArray<Variant>>);
begin
  Self.ToMultiList(AOwner, IndexField, ValueField, DetailFields, SelectedBy);
end;

destructor TConnector.Destroy;
begin

  inherited;
end;

end.
