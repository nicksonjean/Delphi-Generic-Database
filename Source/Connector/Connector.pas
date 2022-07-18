{
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
  RTTI,
  ArrayVariant
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

  { Tipos Específicos Pré-Validados }
type
  TNavigationType = (Pages, Full);
  TPairArray = Array[0..1] of Variant;
  TDetailArray = Array[0..2] of Variant;

  { Classe para Criação dos Itens em Formato JSON, Utilizada em ToListView }
type
  TJSONItem = class
  private
    { Private declarations }
    FJSONData: String;
  public
    { Public declarations }
    const Height = 76;
    function GetJSONData: String;
    procedure SetJSONData(IndexField, ValueField, DataFields: String);
    procedure AddItem<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []);
  end;

  { Classe Estática para Facilitar a Alimentação do Parâmetro Options no Formato JSON }
type
  TJSONOptionsHelper = class
  public
    class function &Set(Index : Integer): String; overload;
    class function &Set(Index : Integer; Pagination: Integer = -1): String; overload;
    class function &Set(Index : Integer; Pagination: Integer = -1; Navigation: TNavigationType = TNavigationType.Pages): String; overload;
    class function &Set(Field : TArray<Variant>): String; overload;
    class function &Set(Field : TArray<Variant>; Pagination: Integer = -1): String; overload;
    class function &Set(Field : TArray<Variant>; Pagination: Integer = -1; Navigation: TNavigationType = TNavigationType.Pages): String; overload;
  end;

  { Classe Estática para Facilitar a Alimentação do Parâmetro Options no Formato Array }
type
  TArrayOptionsHelper = class
  public
    class function &Set(Index : Integer): TDictionary<String, TArray<Variant>>; overload;
    class function &Set(Index : Integer; Pagination: Integer = -1): TDictionary<String, TArray<Variant>>; overload;
    class function &Set(Index : Integer; Pagination: Integer = -1; Navigation: TNavigationType = TNavigationType.Pages): TDictionary<String, TArray<Variant>>; overload;
    class function &Set(Field : TArray<Variant>): TDictionary<String, TArray<Variant>>; overload;
    class function &Set(Field : TArray<Variant>; Pagination: Integer = -1): TDictionary<String, TArray<Variant>>; overload;
    class function &Set(Field : TArray<Variant>; Pagination: Integer = -1; Navigation: TNavigationType = TNavigationType.Pages): TDictionary<String, TArray<Variant>>; overload;
  end;

  { Classe TConnector Herdade de TQuery }
type
  TConnector = class(TQuery)
  protected
    { protected declarations }
    procedure AddObject<T: Class; F>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: F); overload;
    procedure AddObject<T: Class; F>(AOwner: TComponent; IndexField, ValueField: TArray<String>; Options: F); overload;
    procedure AddObject<T: Class; F>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String>; Options: F); overload;
  private
    { Private declarations }
    FQuery: TQuery;
    function ToDataSet(Query: TQuery): {$I CNC.Type.inc};
    procedure ToFillList<F>(AOwner: TComponent; IndexField, ValueField: String; Options: F); overload;
    procedure ToMultiList<F>(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String>; Options: F); overload;
    procedure ToGridTable<F>(AOwner: TComponent; Options: F); overload;
  public
    { Public declarations }
    constructor Create(Query: TQuery);
    destructor Destroy; override;

    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente nos componentes <c>TGrid</c> ou <c>TStringGrid</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToGrid(GridComponent0, 0);</para>
    ///     <para>    Connector.ToGrid(GridComponent1, '{"Index":0}');</para>
    ///     <para>    Connector.ToGrid(GridComponent2, '{"Field":{"DBField":"DBValue"}}');</para>
    ///     <para>    Connector.ToGrid(GridComponent3, TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</para>
    ///     <para>    Connector.ToGrid(GridComponent4, TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</para>
    ///     <para>  finally</para>
    ///     <para>    Connector.Destroy;</para>
    ///     <para>  end;</para>
    ///     <para>finally</para>
    ///     <para>  SQL.Destroy;</para>
    ///     <para>end;</para>
    ///   </code>
    /// </summary>
    /// <param name="AOwner:Requerido">
    ///   O componente do tipo <c>TGrid</c> ou <c>TStringGrid</c> que se quer popular
    /// </param>
    /// <param name="Options:Opcional[¹]">
    ///   <para>O índice numérico da linha do <c>TGrid</c> ou <c>TStringGrid</c> que se quer selecionar, da seguinte forma:</para>
    ///   <para>1) Seleção por índice: <c>0;</c></para>
    ///   <para>Dicionário utilizada para selecionar uma linha do componente, possuindo duas formas:</para>
    ///   <para>1) Seleção por índice: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</c></para>
    ///   <para>Matriz JSON utilizada para selecionar uma linha do componente, possuindo duas formas:</para>
    ///   <para>1) Seleção por índice: <c>'{"Index":0}';</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>'{"Field":{"DBField":"DBValue"}}';</c></para>
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>Options</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>nil</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToGrid'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToGrid<F>(AOwner: TComponent; Options : F); overload;

    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente no componente <c>TEdit</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToEdit(EditComponent0, 'IndexField', 'ValueField', 0);</para>
    ///     <para>    Connector.ToEdit(EditComponent1, 'IndexField', 'ValueField', '{"Index":0}');</para>
    ///     <para>    Connector.ToEdit(EditComponent2, 'IndexField', 'ValueField', '{"Field":{"DBField":"DBValue"}}');</para>
    ///     <para>    Connector.ToEdit(EditComponent3, 'IndexField', 'ValueField', TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</para>
    ///     <para>    Connector.ToEdit(EditComponent4, 'IndexField', 'ValueField', TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</para>
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
    /// <param name="Options:Opcional[¹]">
    ///   <para>O índice numérico da linha do <c>TEdit</c> que se quer selecionar, da seguinte forma:</para>
    ///   <para>1) Seleção por índice: <c>0;</c></para>
    ///   <para>Dicionário utilizada para selecionar uma linha do componente, possuindo duas formas:</para>
    ///   <para>1) Seleção por índice: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</c></para>
    ///   <para>Matriz JSON utilizada para selecionar uma linha do componente, possuindo duas formas:</para>
    ///   <para>1) Seleção por índice: <c>'{"Index":0}';</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>'{"Field":{"DBField":"DBValue"}}';</c></para>
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>Options</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>nil</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToEdit'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToEdit<F>(AOwner: TComponent; IndexField, ValueField: String; Options: F); overload;

    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente nos componentes <c>TComboBox</c>, <c>TComboEdit</c> ou <c>TEdit</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToCombo(ComboComponent0, 'IndexField', 'ValueField', 0);</para>
    ///     <para>    Connector.ToCombo(ComboComponent1, 'IndexField', 'ValueField', '{"Index":0}');</para>
    ///     <para>    Connector.ToCombo(ComboComponent2, 'IndexField', 'ValueField', '{"Field":{"DBField":"DBValue"}}');</para>
    ///     <para>    Connector.ToCombo(ComboComponent3, 'IndexField', 'ValueField', TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</para>
    ///     <para>    Connector.ToCombo(ComboComponent4, 'IndexField', 'ValueField', TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</para>
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
    /// <param name="Options:Opcional[¹]">
    ///   <para>O índice numérico da linha do <c>TComboBox</c>, <c>TComboEdit</c> ou <c>TEdit</c> que se quer selecionar, da seguinte forma:</para>
    ///   <para>1) Seleção por índice: <c>0;</c></para>
    ///   <para>Dicionário utilizada para selecionar uma linha do componente, possuindo duas formas:</para>
    ///   <para>1) Seleção por índice: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</c></para>
    ///   <para>Matriz JSON utilizada para selecionar uma linha do componente, possuindo duas formas:</para>
    ///   <para>1) Seleção por índice: <c>'{"Index":0}';</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>'{"Field":{"DBField":"DBValue"}}';</c></para>
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>Options</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>nil</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToCombo'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToCombo<F>(AOwner: TComponent; IndexField, ValueField: String; Options: F); overload;

    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente nos componentes <c>TListBox</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToListBox(ComboComponent0, 'IndexField', 'ValueField', 0);</para>
    ///     <para>    Connector.ToListBox(ComboComponent1, 'IndexField', 'ValueField', '{"Index":0}');</para>
    ///     <para>    Connector.ToListBox(ComboComponent2, 'IndexField', 'ValueField', '{"Field":{"DBField":"DBValue"}}');</para>
    ///     <para>    Connector.ToListBox(ComboComponent3, 'IndexField', 'ValueField', TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</para>
    ///     <para>    Connector.ToListBox(ComboComponent4, 'IndexField', 'ValueField', TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</para>
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
    /// <param name="Options:Opcional[¹]">
    ///   <para>O índice numérico da linha do <c>TListBox</c> que se quer selecionar, da seguinte forma:</para>
    ///   <para>1) Seleção por índice: <c>0;</c></para>
    ///   <para>Dicionário utilizada para selecionar uma linha do componente, possuindo duas formas:</para>
    ///   <para>1) Seleção por índice: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</c></para>
    ///   <para>Matriz JSON utilizada para selecionar uma linha do componente, possuindo duas formas:</para>
    ///   <para>1) Seleção por índice: <c>'{"Index":0}';</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>'{"Field":{"DBField":"DBValue"}}';</c></para>
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>Options</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>nil</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToCombo'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToListBox<F>(AOwner: TComponent; IndexField, ValueField: String; Options: F); overload;

    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente no componente <c>TListView</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>SQL := TQuery.Create;</para>
    ///     <para>try</para>
    ///     <para>  SQL := Query.View('SELECT DBField FROM DBTable');</para>
    ///     <para>  Connector := TConnector.Create(SQL);</para>
    ///     <para>  try</para>
    ///     <para>    Connector.ToListView(ListViewComponent0, 'IndexField', 'ValueField', [DetailFields], 0);</para>
    ///     <para>    Connector.ToListView(ListViewComponent1, 'IndexField', 'ValueField', [DetailFields], '{"Index":0}');</para>
    ///     <para>    Connector.ToListView(ListViewComponent2, 'IndexField', 'ValueField', [DetailFields], '{"Field":{"DBField":"DBValue"}}');</para>
    ///     <para>    Connector.ToListView(ListViewComponent3, 'IndexField', 'ValueField', [DetailFields], TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</para>
    ///     <para>    Connector.ToListView(ListViewComponent4, 'IndexField', 'ValueField', [DetailFields], TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</para>
    ///     <para>  finally</para>
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
    /// <param name="Options:Opcional[¹]">
    ///   <para>O índice numérico da linha do <c>TListView</c> que se quer selecionar, da seguinte forma:</para>
    ///   <para>1) Seleção por índice: <c>0;</c></para>
    ///   <para>Dicionário utilizada para selecionar uma linha do componente, possuindo duas formas:</para>
    ///   <para>1) Seleção por índice: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Index'], [[0]]));</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>TDictionaryHelper&lt;String, TArray&lt;Variant&gt;&gt;.Make(['Field'], [['DBField', 'DBValue']]));</c></para>
    ///   <para>Matriz JSON utilizada para selecionar uma linha do componente, possuindo duas formas:</para>
    ///   <para>1) Seleção por índice: <c>'{"Index":0}';</c></para>
    ///   <para>2) Seleção por pares[DBField, DBValue]: <c>'{"Field":{"DBField":"DBValue"}}';</c></para>
    /// </param>
    /// <remarks>
    ///   <para>[¹]: O parâmetro <c>Options</c> no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>nil</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToListView'</c>, informando que há uma ambiguidade de métodos</para>
    ///   <para>[²]: O parâmetro <c>DetailFields</c> é uma matriz de strings que pode conter de 0 à 3 índices, no contexto do método é opcional, porém, no contexto da classe ele é obrigatório e deve ser informado <c>[]</c> como seu valor, caso contrário haverá o erro de compilação <c>E2251 Ambiguous overloaded call to 'ToListView'</c>, informando que há uma ambiguidade de métodos</para>
    /// </remarks>

    procedure ToListView<F>(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String>; Options: F); overload;
  end;

implementation

uses
  OptionsInteger,
  OptionsArray,
  OptionsJSON;

{ TValueObject }

constructor TValueObject.Create(const aValue: TValue);
begin
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

procedure TJSONItem.AddItem<T>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String> = []);
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
    TListView(AOwner).BeginUpdate;
    try
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

        // Armazena Todo o ResultRow da Query SQL
        JSONData := TArrayVariant.Create;
        JSONData.Clear;
        for I := 0 to DataSet.FieldDefs.Count - 1 do
          JSONData[DataSet.FieldDefs[I].Name] := DataSet.FieldByName(DataSet.FieldDefs[I].Name).Value;
        Self.SetJSONData(IndexField, ValueField, JSONData.ToJSON);
        Item.Data[TMultiDetailAppearanceNames.Detail4] := Self.GetJSONData;
        JSONData.Destroy;

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

{ TOptionsHelper }

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

{ TOptionsHelper }

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

{ TConnector }

constructor TConnector.Create(Query : TQuery);
begin
  inherited Create;

  Self.FQuery := Query;
end;

procedure TConnector.AddObject<T, F>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; Options: F);
begin
  if (TypeInfo(T) = TypeInfo(TGrid)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: InstanceOptionsJSON.AddToGrid<TGrid>(AOwner, DataSet, TValue.From<F>(Options).AsString);
      tkInteger: InstanceOptionsInteger.AddToGrid<TGrid>(AOwner, DataSet, TValue.From<F>(Options).AsInteger);
      tkClass: InstanceOptionsArray.AddToGrid<TGrid>(AOwner, DataSet, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TStringGrid)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: InstanceOptionsJSON.AddToStringGrid<TStringGrid>(AOwner, DataSet, TValue.From<F>(Options).AsString);
      tkInteger: InstanceOptionsInteger.AddToStringGrid<TStringGrid>(AOwner, DataSet, TValue.From<F>(Options).AsInteger);
      tkClass: InstanceOptionsArray.AddToStringGrid<TStringGrid>(AOwner, DataSet, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end;
end;

procedure TConnector.AddObject<T, F>(AOwner: TComponent; IndexField, ValueField: TArray<String>; Options: F);
begin
  if (TypeInfo(T) = TypeInfo(TEdit)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: InstanceOptionsJSON.AddToEdit<TEdit>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsString);
      tkInteger: InstanceOptionsInteger.AddToEdit<TEdit>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsInteger);
      tkClass: InstanceOptionsArray.AddToEdit<TEdit>(AOwner, IndexField, ValueField, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TComboEdit)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: InstanceOptionsJSON.AddToComboEdit<TComboEdit>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsString);
      tkInteger: InstanceOptionsInteger.AddToComboEdit<TComboEdit>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsInteger);
      tkClass: InstanceOptionsArray.AddToComboEdit<TComboEdit>(AOwner, IndexField, ValueField, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TComboBox)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: InstanceOptionsJSON.AddToComboBox<TComboBox>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsString);
      tkInteger: InstanceOptionsInteger.AddToComboBox<TComboBox>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsInteger);
      tkClass: InstanceOptionsArray.AddToComboBox<TComboBox>(AOwner, IndexField, ValueField, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TListBox)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: InstanceOptionsJSON.AddToListBox<TListBox>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsString);
      tkInteger: InstanceOptionsInteger.AddToListBox<TListBox>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsInteger);
      tkClass: InstanceOptionsArray.AddToListBox<TListBox>(AOwner, IndexField, ValueField, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end;
end;

procedure TConnector.AddObject<T, F>(AOwner: TComponent; DataSet: {$I CNC.Type.inc}; IndexField, ValueField: String; DetailFields: TArray<String>; Options: F);
begin
  if (TypeInfo(T) = TypeInfo(TListView)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: InstanceOptionsJSON.AddToListView<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields, TValue.From<F>(Options).AsString);
      tkInteger: InstanceOptionsInteger.AddToListView<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields, TValue.From<F>(Options).AsInteger);
      tkClass: InstanceOptionsArray.AddToListView<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end
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
  while not DataSet.Eof do
  begin
    DataSet.Edit;
    DataSet.Post;
    DataSet.Next;
  end;
  DataSet.Last;
  Result := DataSet;
end;

procedure TConnector.ToFillList<F>(AOwner: TComponent; IndexField, ValueField: String; Options : F);
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
        Self.AddObject<TEdit, F>(AOwner, [IndexField, ValueField], [Items.Names[I], Items.ValueFromIndex[I]], Options)
      else if AOwner Is TComboEdit then
        Self.AddObject<TComboEdit, F>(AOwner, [IndexField, ValueField], [Items.Names[I], Items.ValueFromIndex[I]], Options)
      else if AOwner Is TComboBox then
        Self.AddObject<TComboBox, F>(AOwner, [IndexField, ValueField], [Items.Names[I], Items.ValueFromIndex[I]], Options)
      else if AOwner Is TListBox then
        Self.AddObject<TListBox, F>(AOwner, [IndexField, ValueField], [Items.Names[I], Items.ValueFromIndex[I]], Options)
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

procedure TConnector.ToMultiList<F>(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String>; Options: F);
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
      Self.AddObject<TListView, F>(AOwner, DataSet, IndexField, ValueField, DetailFields, Options);
  end;

  if AOwner Is TListView then
    TListView(AOwner).AlternatingColors := True;
end;

procedure TConnector.ToGridTable<F>(AOwner: TComponent; Options: F);
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
      Self.AddObject<TStringGrid, F>(AOwner, DataSet, Options)
    else if AOwner Is TGrid then
      Self.AddObject<TGrid, F>(AOwner, DataSet, Options);
  end;
end;

procedure TConnector.ToGrid<F>(AOwner: TComponent; Options : F);
begin
  Self.ToGridTable<F>(AOwner, Options);
end;

procedure TConnector.ToEdit<F>(AOwner: TComponent; IndexField, ValueField: String; Options: F);
begin
  Self.ToFillList<F>(AOwner, IndexField, ValueField, Options);
end;

procedure TConnector.ToCombo<F>(AOwner: TComponent; IndexField, ValueField: String; Options: F);
begin
  Self.ToFillList<F>(AOwner, IndexField, ValueField, Options);
end;

procedure TConnector.ToListBox<F>(AOwner: TComponent; IndexField, ValueField: String; Options: F);
begin
  Self.ToFillList<F>(AOwner, IndexField, ValueField, Options);
end;

procedure TConnector.ToListView<F>(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String>; Options: F);
begin
  Self.ToMultiList<F>(AOwner, IndexField, ValueField, DetailFields, Options);
end;

destructor TConnector.Destroy;
begin

  inherited;
end;

end.