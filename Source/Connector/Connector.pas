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
  EventDriven,
  Connection,
  Query,
  QueryHelper,
  QueryBuilder,
  RTTI,
  ArrayHelper,
  ArrayString,
  ArrayVariant,
  Vcl.Forms
  ;

  { Classe Utilizada para Armazenamento de Dados }
type
  { TComponent como base: o TListBoxItem que for Owner libera automaticamente via FComponents ao ser destruído pelo FMX. }
  TValueObject = class(TComponent)
  strict private
    FValue: TValue;
  public
    constructor Create(AOwner: TComponent; const aValue: TValue); reintroduce;
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
    procedure AddItem<T>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String> = []);
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

  { AlternatingRowBackground é protected em TCustomListBox; republicar para uso em ToFillList<F>. }
  TCustomListBoxAccess = class(TCustomListBox)
  public
    property AlternatingRowBackground;
  end;

  { Classe TConnector Herdade de TQuery }
type
  TConnector = class(TQuery)
  protected
    { protected declarations }
    procedure AddObject<T: Class; F>(AOwner: TComponent; DataSet: TDataSet; Options: F); overload;
    procedure AddObject<T: Class; F>(AOwner: TComponent; IndexField, ValueField: TArray<String>; Options: F); overload;
    procedure AddObject<T: Class; F>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String>; Options: F); overload;
  private
    { Private declarations }
    FQuery: TQuery;
    { Um clone por tipo: TStringGrid herda de TGrid — se usar um só campo, ToGrid(Grid) liberava o clone
      ainda referenciado pelo TStringGrid.FillData (class var FData no helper). }
    FMemDataSetStringGrid: TDataSet;
    FMemDataSetGrid: TDataSet;
    { Último TGrid/TStringGrid que recebeu FillData — OnGetValue deve ser nil antes de Close/Free do clone. }
    FBoundFMXGrid: TGrid;
    { Libera o TDataSet retornado por TQuery.AsInMemoryDataSet (qualquer engine: dbExpress, ZeOS, FireDAC, UniDAC). }
    procedure ReleaseInMemoryDataSet(var ADS: TDataSet);
    procedure FreeControlObjects(AControl: TComponent);
    procedure SyncItemValueOwnershipAfterFill(AOwner: TComponent);
    function ToDataSet(Query: TQuery): TDataSet;
    procedure ToFillList<F>(AOwner: TComponent; IndexField, ValueField: String; Options: F); overload;
    procedure ToMultiList<F>(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String>; Options: F); overload;
    procedure ToGridTable<F>(AOwner: TComponent; Options: F); overload;
  public
    { Public declarations }
    constructor Create(Query: TQuery);
    destructor Destroy; override;
    { Libera TValueObject: TStringList.Items com OwnsObjects + Clear; TEdit suggest usa ClearSuggestionListBox antes de Clear. }
    class procedure ReleaseItemValueObjects(AControl: TComponent);
    class procedure ReleaseItemValueObjectsInSubtree(Root: TFmxObject);
    /// <summary>
    ///   Método para exibir os dados de uma consulta SQL diretamente nos componentes <c>TGrid</c> ou <c>TStringGrid</c>
    ///   <para>Exemplo:</para>
    ///   <code>
    ///     <para>Query := TQueryBuilder.ForConnection(conn.GetConnectionStrategy);</para>
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
    ///     <para>Query := TQueryBuilder.ForConnection(conn.GetConnectionStrategy);</para>
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
    ///     <para>Query := TQueryBuilder.ForConnection(conn.GetConnectionStrategy);</para>
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
    ///     <para>Query := TQueryBuilder.ForConnection(conn.GetConnectionStrategy);</para>
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
    ///     <para>Query := TQueryBuilder.ForConnection(conn.GetConnectionStrategy);</para>
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

function ConnectorGetItemsStrings(AControl: TComponent): TStrings;
begin
  Result := nil;
  if AControl = nil then
    Exit;
  if AControl is TEdit then
    Result := TEdit(AControl).Items
  else if AControl is TComboEdit then
    Result := TComboEdit(AControl).Items
  else if AControl is TComboBox then
    Result := TComboBox(AControl).Items
  else if AControl is TListBox then
    Result := TListBox(AControl).Items;
end;

function ConnectorGetHostedListBox(AControl: TComponent): TCustomListBox;
begin
  Result := nil;
  if AControl is TListBox then
    Result := TCustomListBox(TListBox(AControl))
  else if AControl is TComboBox then
  begin
    if TComboBox(AControl).ListBox <> nil then
      Result := TCustomListBox(TComboBox(AControl).ListBox);
  end
  else if AControl is TComboEdit then
  begin
    if TComboEdit(AControl).ListBox <> nil then
      Result := TCustomListBox(TComboEdit(AControl).ListBox);
  end;
end;

procedure ConnectorReleaseFMXListLikeItemObjects(AControl: TComponent; SL: TStrings);
var
  LB: TCustomListBox;
  K: Integer;
  O: TObject;
  V: TValue;
begin
  if SL = nil then
    Exit;
  LB := ConnectorGetHostedListBox(AControl);
  if LB <> nil then
  begin
    SL.BeginUpdate;
    try
      { 1) Todas as linhas visuais: FMX guarda TObject em ListItems[K].Data (nem sempre espelhado em Objects[K]). }
      for K := LB.Count - 1 downto 0 do
      begin
        V := LB.ListItems[K].Data;
        if (not V.IsEmpty) and (V.Kind = tkClass) then
        begin
          O := V.AsObject;
          LB.ListItems[K].Data := nil;
          if (O <> nil) and (K < SL.Count) and (SL.Objects[K] = O) then
            SL.Objects[K] := nil;
          if O <> nil then
            O.Free;
        end;
      end;
      { 2) Todas as entradas de Items: combo pode ter Objects sem Data materializado no ListBox. }
      for K := 0 to SL.Count - 1 do
      begin
        O := SL.Objects[K];
        if O <> nil then
        begin
          SL.Objects[K] := nil;
          O.Free;
        end;
      end;
    finally
      SL.EndUpdate;
    end;
  end
  else
  begin
    for K := 0 to SL.Count - 1 do
      if SL.Objects[K] <> nil then
      begin
        SL.Objects[K].Free;
        SL.Objects[K] := nil;
      end;
  end;
  if SL is TStringList then
    TStringList(SL).OwnsObjects := False;
  SL.Clear;
end;

procedure ConnectorReleaseItemValueObjects(AControl: TComponent);
var
  K: Integer;
  SL: TStrings;
begin
  if AControl = nil then
    Exit;
  if AControl is TEdit then
    TEdit(AControl).ClearSuggestionListBox;
  SL := ConnectorGetItemsStrings(AControl);
  if SL = nil then
    Exit;

  { FMX: TValueObject fica em TListBoxItem.Data; Items muitas vezes não é TStringList nem preenche Objects[i]. }
  if (AControl is TListBox) or (AControl is TComboBox) or (AControl is TComboEdit) then
  begin
    ConnectorReleaseFMXListLikeItemObjects(AControl, SL);
    Exit;
  end;

  if SL is TStringList then
  begin
    TStringList(SL).OwnsObjects := True;
    SL.Clear;
  end
  else
  begin
    for K := 0 to SL.Count - 1 do
      if SL.Objects[K] <> nil then
      begin
        SL.Objects[K].Free;
        SL.Objects[K] := nil;
      end;
  end;
end;

procedure ConnectorEnsureItemsStringListOwnsObjects(AControl: TComponent);
var
  SL: TStrings;
begin
  SL := ConnectorGetItemsStrings(AControl);
  if (SL <> nil) and (SL is TStringList) then
    TStringList(SL).OwnsObjects := True;
end;

function ConnectorIsListBoxUnderComboDropDown(const LB: TListBox): Boolean;
var
  P: TFmxObject;
  O: TComponent;
begin
  Result := False;
  if LB = nil then
    Exit;
  P := LB.Parent;
  while P <> nil do
  begin
    if (P is TComboBox) or (P is TComboEdit) then
    begin
      Result := True;
      Exit;
    end;
    P := P.Parent;
  end;
  O := LB.Owner;
  while O <> nil do
  begin
    if (O is TComboBox) or (O is TComboEdit) then
    begin
      Result := True;
      Exit;
    end;
    O := O.Owner;
  end;
end;

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
  { TODO -oNickson Jeanmerson -cProgrammer :
  1) Adicionar Suporte à Imagens via Blog com TImage/TBitmap e ImageString em Base64;
  2) Adicionar Suporte à Accessory; }
        //Item.BitmapRef := ImageRAD.Bitmap;
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
  inherited Create(Query.ConnectionStrategy);
  Self.FQuery := Query;
end;

procedure TConnector.ReleaseInMemoryDataSet(var ADS: TDataSet);
begin
  if ADS = nil then
    Exit;

  try
    if ADS.Active then
      ADS.Close;
  except
    // dbExpress/ZeOS/FireDAC podem lançar aqui em casos de estado transitório;
    // não queremos falha catastrófica no fechamento final dos datasets em Connector.
  end;

  try
    ADS.Free;
  except
    // Se o dataset estiver preso a um bridge UI ou já foi liberado, evita AV.
  end;

  ADS := nil;
end;

procedure TConnector.AddObject<T, F>(AOwner: TComponent; DataSet: TDataSet; Options: F);
begin
  if (TypeInfo(T) = TypeInfo(TGrid)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: TOptionsJSON.AddToGrid<TGrid>(AOwner, DataSet, TValue.From<F>(Options).AsString);
      tkInteger: TOptionsInteger.AddToGrid<TGrid>(AOwner, DataSet, TValue.From<F>(Options).AsInteger);
      tkClass: TOptionsArray.AddToGrid<TGrid>(AOwner, DataSet, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TStringGrid)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: TOptionsJSON.AddToStringGrid<TStringGrid>(AOwner, DataSet, TValue.From<F>(Options).AsString);
      tkInteger: TOptionsInteger.AddToStringGrid<TStringGrid>(AOwner, DataSet, TValue.From<F>(Options).AsInteger);
      tkClass: TOptionsArray.AddToStringGrid<TStringGrid>(AOwner, DataSet, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end;
end;

procedure TConnector.AddObject<T, F>(AOwner: TComponent; IndexField, ValueField: TArray<String>; Options: F);
begin
  if (TypeInfo(T) = TypeInfo(TEdit)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: TOptionsJSON.AddToEdit<TEdit>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsString);
      tkInteger: TOptionsInteger.AddToEdit<TEdit>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsInteger);
      tkClass: TOptionsArray.AddToEdit<TEdit>(AOwner, IndexField, ValueField, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TComboEdit)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: TOptionsJSON.AddToComboEdit<TComboEdit>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsString);
      tkInteger: TOptionsInteger.AddToComboEdit<TComboEdit>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsInteger);
      tkClass: TOptionsArray.AddToComboEdit<TComboEdit>(AOwner, IndexField, ValueField, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TComboBox)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: TOptionsJSON.AddToComboBox<TComboBox>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsString);
      tkInteger: TOptionsInteger.AddToComboBox<TComboBox>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsInteger);
      tkClass: TOptionsArray.AddToComboBox<TComboBox>(AOwner, IndexField, ValueField, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end
  else if (TypeInfo(T) = TypeInfo(TListBox)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: TOptionsJSON.AddToListBox<TListBox>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsString);
      tkInteger: TOptionsInteger.AddToListBox<TListBox>(AOwner, IndexField, ValueField, TValue.From<F>(Options).AsInteger);
      tkClass: TOptionsArray.AddToListBox<TListBox>(AOwner, IndexField, ValueField, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end;
end;

procedure TConnector.AddObject<T, F>(AOwner: TComponent; DataSet: TDataSet; IndexField, ValueField: String; DetailFields: TArray<String>; Options: F);
begin
  if (TypeInfo(T) = TypeInfo(TListView)) then
  begin
    case PTypeInfo(TypeInfo(F)).Kind of
      tkUString: TOptionsJSON.AddToListView<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields, TValue.From<F>(Options).AsString);
      tkInteger: TOptionsInteger.AddToListView<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields, TValue.From<F>(Options).AsInteger);
      tkClass: TOptionsArray.AddToListView<TListView>(AOwner, DataSet, IndexField, ValueField, DetailFields, TypeResolver.ReCast<TDictionary<String, TArray<Variant>>>(Options));
    end;
  end
end;

procedure TConnector.FreeControlObjects(AControl: TComponent);
begin
  { Libera TObject em Items.Objects antes de Clear/repovoar; Objects[K] := nil evita double free. }
  ConnectorReleaseItemValueObjects(AControl);
end;

procedure TConnector.SyncItemValueOwnershipAfterFill(AOwner: TComponent);
begin
  ConnectorEnsureItemsStringListOwnsObjects(AOwner);
end;

function TConnector.ToDataSet(Query: TQuery): TDataSet;
begin
  Result := Query.AsInMemoryDataSet;
end;

procedure TConnector.ToFillList<F>(AOwner: TComponent; IndexField, ValueField: String; Options : F);
var
  I: Integer;
  Items : TArrayString;
  DataSet : TDataSet;
begin
  Items := nil;
  DataSet := nil;
  Self.FreeControlObjects(AOwner);
  if AOwner Is TComboBox then
  begin
    TComboBox(AOwner).DropDownKind := TDropDownKind.Custom;
    TComboBox(AOwner).AutoComplete := True;
    TComboBox(AOwner).Items.Clear;
  end
  else if AOwner Is TComboEdit then
  begin
    TComboEdit(AOwner).DropDownKind := TDropDownKind.Custom;
    TComboEdit(AOwner).AutoComplete := True;
    TComboEdit(AOwner).Items.Clear;
  end
  else if AOwner Is TEdit then
  begin
    TEdit(AOwner).Items.Clear;
    TEdit(AOwner).RefreshSuggestionList;
  end
  else if AOwner Is TListBox then
  begin
    TListBox(AOwner).Items.Clear;
  end;
  try
    DataSet := Self.ToDataSet(Self.FQuery);
    if DataSet <> nil then
    begin
      if not DataSet.Active then
        DataSet.Open;
      if DataSet.RecordCount > 0 then
      begin
      Items := TArrayString.Create;
      DataSet.First;
      while not DataSet.Eof do
      begin
        Items.AddPair(DataSet.FieldByName(ValueField).AsString, DataSet.FieldByName(IndexField).AsString);
        DataSet.Next;
      end;
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
      if AOwner Is TComboBox then
      begin
        if (TComboBox(AOwner).ListBox <> nil) and (TComboBox(AOwner).ListBox is TCustomListBox) then
          TCustomListBoxAccess(TComboBox(AOwner).ListBox).AlternatingRowBackground := True;
      end
      else if AOwner Is TComboEdit then
      begin
        if (TComboEdit(AOwner).ListBox <> nil) and (TComboEdit(AOwner).ListBox is TCustomListBox) then
          TCustomListBoxAccess(TComboEdit(AOwner).ListBox).AlternatingRowBackground := True;
      end
      else if AOwner Is TListBox then
        TListBox(AOwner).AlternatingRowBackground := True;
      end;
    end;
    Self.SyncItemValueOwnershipAfterFill(AOwner);
    if AOwner is TEdit then
      TEdit(AOwner).RefreshSuggestionList;
  finally
    Items.Free;
    Items := nil;
    Self.ReleaseInMemoryDataSet(DataSet);
    if PTypeInfo(TypeInfo(F)).Kind = tkClass then
      TValue.From<F>(Options).AsObject.Free;
  end;
end;

procedure TConnector.ToMultiList<F>(AOwner: TComponent; IndexField, ValueField: String; DetailFields: TArray<String>; Options: F);
var
  DataSet : TDataSet;
begin
  DataSet := nil;
  TListView(AOwner).ItemAppearanceClassName := 'TMultiDetailItemAppearance';
  TListView(AOwner).ItemEditAppearanceClassName := 'TMultiDetailDeleteAppearance';
  if (AOwner is TListView) and (TListView(AOwner) <> nil) and (TListView(AOwner).Items.Count > 0) then
  begin
    TListView(AOwner).Items.Clear;
    TListView(AOwner).EmptyFilter;
  end;
  try
    DataSet := Self.ToDataSet(Self.FQuery);
    if DataSet <> nil then
    begin
      if not DataSet.Active then
        DataSet.Open;
      if DataSet.RecordCount > 0 then
      begin
        if (AOwner is TListView) then
          Self.AddObject<TListView, F>(AOwner, DataSet, IndexField, ValueField, DetailFields, Options);
      end;
    end;
    if AOwner Is TListView then
      TListView(AOwner).AlternatingColors := True;
  finally
    Self.ReleaseInMemoryDataSet(DataSet);
    if PTypeInfo(TypeInfo(F)).Kind = tkClass then
      TValue.From<F>(Options).AsObject.Free;
  end;
end;

procedure TConnector.ToGridTable<F>(AOwner: TComponent; Options: F);
var
  DataSet: TDataSet;
  Previous: TDataSet;
begin
  { TDataSet aqui cobre qualquer engine em runtime: TFDMemTable, TClientDataSet, etc.
    AsInMemoryDataSet já devolve a instância concreta; tipar via .inc só fazia escolha em compile-time. }
  DataSet := nil;
  Previous := nil;

  if (AOwner is TGrid) and (TGrid(AOwner) <> nil) then
  begin
    if (FBoundFMXGrid <> nil) and (FBoundFMXGrid <> TGrid(AOwner)) then
      ReleaseFMXGridVirtualDataBinding(FBoundFMXGrid);
    ReleaseFMXGridVirtualDataBinding(TGrid(AOwner));
  end;

  if (AOwner is TStringGrid) and (TStringGrid(AOwner) <> nil) then
    TStringGrid(AOwner).ClearColumns
  else if (AOwner is TGrid) and (TGrid(AOwner) <> nil) then
    TGrid(AOwner).ClearColumns;

  try
    DataSet := Self.ToDataSet(Self.FQuery);
    if DataSet = nil then
      Exit;
    if not DataSet.Active then
      DataSet.Open;

    if DataSet.RecordCount > 0 then
    begin
      if AOwner is TStringGrid then
      begin
        Previous := FMemDataSetStringGrid;
        FMemDataSetStringGrid := DataSet;
        DataSet := nil;
        try
          Self.AddObject<TStringGrid, F>(AOwner, FMemDataSetStringGrid, Options);
          FBoundFMXGrid := TGrid(AOwner);
        finally
          Self.ReleaseInMemoryDataSet(Previous);
        end;
      end
      else if AOwner is TGrid then
      begin
        Previous := FMemDataSetGrid;
        FMemDataSetGrid := DataSet;

        DataSet := nil;
        try
          Self.AddObject<TGrid, F>(AOwner, FMemDataSetGrid, Options);
          FBoundFMXGrid := TGrid(AOwner);
        finally
          Self.ReleaseInMemoryDataSet(Previous);
        end;
      end
      else
      begin
        Self.ReleaseInMemoryDataSet(DataSet);
        DataSet := nil;
      end;
    end
    else
    begin
      Self.ReleaseInMemoryDataSet(DataSet);
      DataSet := nil;
    end;
  finally
    Self.ReleaseInMemoryDataSet(DataSet);
    if PTypeInfo(TypeInfo(F)).Kind = tkClass then
      TValue.From<F>(Options).AsObject.Free;
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
  // Deixar o binding de TGrid vivo (correto até o grid ser destruído pelo FMX):
  // O dataset em uso pelo OnGetValue fica preso ao próprio bridge do grid.
  FBoundFMXGrid := nil;

  // TStringGrid já copia os valores e não depende de OnGetValue.
  Self.ReleaseInMemoryDataSet(FMemDataSetStringGrid);

  // Não liberar FMemDataSetGrid aqui, pois sua vida útil é gerenciada pelo bridge incorporado ao grid.
  FMemDataSetGrid := nil;

  inherited;
end;

class procedure TConnector.ReleaseItemValueObjects(AControl: TComponent);
begin
  ConnectorReleaseItemValueObjects(AControl);
end;

class procedure TConnector.ReleaseItemValueObjectsInSubtree(Root: TFmxObject);
var
  I: Integer;
  Child: TFmxObject;
begin
  if Root = nil then
    Exit;
  if Root is TComboBox then
    ConnectorReleaseItemValueObjects(TComponent(Root))
  else if Root is TComboEdit then
    ConnectorReleaseItemValueObjects(TComponent(Root))
  else if Root is TEdit then
    ConnectorReleaseItemValueObjects(TComponent(Root))
  else if Root is TListBox then
  begin
    { ListBox interno do drop-down compartilha / espelha Items do Combo: liberar de novo corrompe o heap. }
    if not ConnectorIsListBoxUnderComboDropDown(TListBox(Root)) then
      ConnectorReleaseItemValueObjects(TComponent(Root));
  end;
  for I := 0 to Root.ChildrenCount - 1 do
  begin
    Child := Root.Children[I];
    if Child <> nil then
      TConnector.ReleaseItemValueObjectsInSubtree(Child);
  end;
end;

end.