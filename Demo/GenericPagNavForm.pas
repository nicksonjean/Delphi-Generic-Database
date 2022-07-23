unit GenericPagNavForm;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.Layouts,
  Data.Bind.Controls,
  Fmx.Bind.Navigator,
  System.Rtti,
  FMX.Grid.Style,
  FMX.ScrollBox,
  FMX.Grid,
  FMX.Edit,
  FMX.TabControl,
  Generics.Defaults
  ;

type
  TGenericPagNavForm = class(TForm)
    TabControlSQLConnectors: TTabControl;
    TabDBConnectorsNavigators: TTabItem;
    GridPanelLayout1: TGridPanelLayout;
    GroupBox1: TGroupBox;
    GridPanelLayout2: TGridPanelLayout;
    BindNavigator1: TBindNavigator;
    Edit1: TEdit;
    SearchEditButton1: TSearchEditButton;
    Grid1: TGrid;
    GridPanelLayout3: TGridPanelLayout;
    GroupBox2: TGroupBox;
    GridPanelLayout5: TGridPanelLayout;
    Edit2: TEdit;
    SearchEditButton2: TSearchEditButton;
    Grid2: TGrid;
    PagPanelLayout: TGridPanelLayout;
    PagButtonFirst: TCornerButton;
    PagButtonPrior: TCornerButton;
    PagButtonNext: TCornerButton;
    PagButtonLast: TCornerButton;
    GroupBox3: TGroupBox;
    GridPanelLayout4: TGridPanelLayout;
    Edit3: TEdit;
    SearchEditButton3: TSearchEditButton;
    Grid3: TGrid;
    NavPanelLayout: TGridPanelLayout;
    NavButtonFirst: TCornerButton;
    NavButtonPrior: TCornerButton;
    NavButtonNext: TCornerButton;
    NavButtonLast: TCornerButton;
    NavButtonInsert: TCornerButton;
    NavButtonDelete: TCornerButton;
    NavButtonEdit: TCornerButton;
    NavButtonPost: TCornerButton;
    NavButtonCancel: TCornerButton;
    NavButtonRefresh: TCornerButton;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FGenericPagNavForm: TGenericPagNavForm;

implementation

uses
  DictionaryHelper,
  TimeDate,
  Float,
  IArray,
  ArrayString,
  ArrayStringHelper,
  ArrayVariant,
  ArrayVariantHelper,
  ArrayField,
  ArrayFieldHelper,
  ArrayAssoc,
  MimeType,
  ISmartPointer,
  TSmartPointer;

{$R *.fmx}

{
dbNavigator1.VisibleButtons := [nbFirst,nbPrior,nbNext,nbLast,nbInsert,nbEdit,nbPost,nbCancel,nbRefresh]
}

procedure TGenericPagNavForm.Button1Click(Sender: TObject);
var
  SLT : TSmartPointer<TArrayString>;
  SLI, SLIS: TArrayString;
  SLIV: TArrayVariant;
  SLIZ: TArrayVariant;
begin
  SLT.Ref.Add('abc', '123');
  SLT.Ref['teste'] := '123';
  ShowMessage(SLT.Ref.ToList(True));

  SLI := IArray<TArrayString>(TArrayString.Create());
  SLI.Add('abc', '123');
  SLI['teste'] := '123';
  ShowMessage(SLI.ToList(True));

  SLIZ := IArray<TArrayVariant>(TArrayVariant.Create());
  SLIZ.Add('abc', '123');
  SLIZ['teste'] := '123';
  ShowMessage(SLIZ.ToList(True));

  SLIS := TArrayString.Create();
  SLIS.Add('abc', '123');
  SLIS['teste'] := '123';
  ShowMessage(SLIS.ToList(True));
  SLIS.Destroy;

  SLIV := TArrayVariant.Create;
  SLIV.Add('abc', 123);
  SLIV['teste'] := '123';
  ShowMessage(SLIV.ToList(True));
  SLIV.Destroy;
end;

procedure TGenericPagNavForm.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
end;

end.
