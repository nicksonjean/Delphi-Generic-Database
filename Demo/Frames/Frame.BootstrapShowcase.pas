unit Frame.BootstrapShowcase;

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
  FMX.ScrollBox,
  FMX.Edit,
  FMX.ComboEdit,
  FMX.ListBox,
  FMX.Grid,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.SearchBox,
  FMX.ListView,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  System.Rtti,
  FMX.Grid.Style;

type
  TFrameBootstrapShowcase = class(TFrame)
    RectShowcaseBg: TRectangle;
    ScrollMain: TVertScrollBox;
    { Section 1: Buttons }
    RectSectionBtns: TRectangle;
    RectBtnsHeader: TRectangle;
    LblBtnsTitle: TLabel;
    RectBtnsDivider: TRectangle;
    LayBtnsBody: TLayout;
    LblRowText: TLabel;
    LayBtnsText: TLayout;
    BtnPrimary: TButton;
    BtnSecondary: TButton;
    BtnSuccess: TButton;
    BtnDanger: TButton;
    BtnWarning: TButton;
    BtnInfo: TButton;
    BtnLight: TButton;
    BtnDark: TButton;
    BtnLink: TButton;
    LblRowIconText: TLabel;
    LayBtnsIconText: TLayout;
    BtnIPrimary: TButton;
    BtnISecondary: TButton;
    BtnISuccess: TButton;
    BtnIDanger: TButton;
    BtnIWarning: TButton;
    BtnIInfo: TButton;
    LblRowIconOnly: TLabel;
    LayBtnsIconOnly: TLayout;
    BtnOPrimary: TButton;
    BtnOSecondary: TButton;
    BtnOSuccess: TButton;
    BtnODanger: TButton;
    BtnOWarning: TButton;
    BtnODark: TButton;
    LblRowCorner: TLabel;
    LayCorner: TLayout;
    CbtnPrimary: TCornerButton;
    CbtnSecondary: TCornerButton;
    CbtnSuccess: TCornerButton;
    CbtnDanger: TCornerButton;
    CbtnWarning: TCornerButton;
    CbtnInfo: TCornerButton;
    { Section 2: Form Controls }
    RectSectionForms: TRectangle;
    RectFormsHeader: TRectangle;
    LblFormsTitle: TLabel;
    RectFormsDivider: TRectangle;
    LayFormsBody: TLayout;
    LayFormsLeft: TLayout;
    LblEditNormal: TLabel;
    EditNormal: TEdit;
    LblEditPassword: TLabel;
    EditPassword: TEdit;
    LblEditDisabled: TLabel;
    EditDisabled: TEdit;
    LayFormsRight: TLayout;
    LblComboBox: TLabel;
    ComboBoxMain: TComboBox;
    LblComboEdit: TLabel;
    ComboEditMain: TComboEdit;
    LblSearchBox: TLabel;
    SearchBoxMain: TSearchBox;
    { Section 3: Memo & ListBox }
    RectSectionLists: TRectangle;
    RectListsHeader: TRectangle;
    LblListsTitle: TLabel;
    RectListsDivider: TRectangle;
    LayListsBody: TLayout;
    LayListsLeft: TLayout;
    LblMemo: TLabel;
    MemoMain: TMemo;
    LayListsRight: TLayout;
    LblListBox: TLabel;
    ListBoxMain: TListBox;
    { Section 4: Grids }
    RectSectionGrid: TRectangle;
    RectGridHeader: TRectangle;
    LblGridTitle: TLabel;
    RectGridDivider: TRectangle;
    LayGridBody: TLayout;
    LayGridLeft: TLayout;
    LblStringGrid: TLabel;
    StringGridMain: TStringGrid;
    LayGridRight: TLayout;
    LblListView: TLabel;
    ListViewMain: TListView;
    { Section 5: Toggle }
    RectSectionToggle: TRectangle;
    RectToggleHeader: TRectangle;
    LblToggleTitle: TLabel;
    RectToggleDivider: TRectangle;
    LayToggleBody: TLayout;
    BtnToggleBootstrap: TButton;
    procedure BtnToggleBootstrapClick(Sender: TObject);
  private
    procedure PopulateData;
    procedure ApplyBootstrapChrome;
  protected
    procedure SetParent(const Value: TFmxObject); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  BootstrapStyle,
  BootstrapStyle.Core;

{$R *.fmx}

{ TFrameBootstrapShowcase }

constructor TFrameBootstrapShowcase.Create(AOwner: TComponent);
begin
  inherited;
  PopulateData;
end;

procedure TFrameBootstrapShowcase.PopulateData;
begin
  { ListBox items }
  ListBoxMain.Items.Add('Active item');
  ListBoxMain.Items.Add('Normal item');
  ListBoxMain.Items.Add('Another item');
  ListBoxMain.Items.Add('Fourth item');
  ListBoxMain.Items.Add('Disabled item');
  ListBoxMain.ItemIndex := 0;

  { StringGrid data }
  if StringGridMain.ColumnCount >= 3 then
  begin
    StringGridMain.Cells[0, 0] := 'host';
    StringGridMain.Cells[1, 0] := 'string';
    StringGridMain.Cells[2, 0] := 'localhost';
    StringGridMain.Cells[0, 1] := 'port';
    StringGridMain.Cells[1, 1] := 'integer';
    StringGridMain.Cells[2, 1] := '5432';
    StringGridMain.Cells[0, 2] := 'database';
    StringGridMain.Cells[1, 2] := 'string';
    StringGridMain.Cells[2, 2] := 'myapp_db';
    StringGridMain.Cells[0, 3] := 'username';
    StringGridMain.Cells[1, 3] := 'string';
    StringGridMain.Cells[2, 3] := 'admin';
  end;

  { ListView items }
  ListViewMain.Items.Add.Text := 'Bootstrap Icons (v1.11)';
  ListViewMain.Items.Add.Text := 'Bootstrap Colors 5.3';
  ListViewMain.Items.Add.Text := 'Bootstrap Buttons engine';
  ListViewMain.Items.Add.Text := 'Bootstrap Forms engine';
  ListViewMain.Items.Add.Text := 'Runtime toggle support';
end;

procedure TFrameBootstrapShowcase.ApplyBootstrapChrome;
begin
  { ── Section 1: Buttons — Row 1 (Solid, all 9 variants) ── }
  TBootstrapStyle.ApplyButton(BtnPrimary,   bsPrimary,   'Primary');
  TBootstrapStyle.ApplyButton(BtnSecondary, bsSecondary, 'Secondary');
  TBootstrapStyle.ApplyButton(BtnSuccess,   bsSuccess,   'Success');
  TBootstrapStyle.ApplyButton(BtnDanger,    bsDanger,    'Danger');
  TBootstrapStyle.ApplyButton(BtnWarning,   bsWarning,   'Warning');
  TBootstrapStyle.ApplyButton(BtnInfo,      bsInfo,      'Info');
  TBootstrapStyle.ApplyButton(BtnLight,     bsLight,     'Light');
  TBootstrapStyle.ApplyButton(BtnDark,      bsDark,      'Dark');
  TBootstrapStyle.ApplyButton(BtnLink,      bsLink,      'Link');

  { ── Row 2: Icon + Text ── }
  TBootstrapStyle.ApplyButton(BtnIPrimary,   bsPrimary,   'Save',      15, 'floppy');
  TBootstrapStyle.ApplyButton(BtnISecondary, bsSecondary, 'Settings',  15, 'pencil');
  TBootstrapStyle.ApplyButton(BtnISuccess,   bsSuccess,   'Confirm',   15, 'check-lg');
  TBootstrapStyle.ApplyButton(BtnIDanger,    bsDanger,    'Delete',    15, 'trash');
  TBootstrapStyle.ApplyButton(BtnIWarning,   bsWarning,   'Alert',     15, 'lightning-charge');
  TBootstrapStyle.ApplyButton(BtnIInfo,      bsInfo,      'Upload',    15, 'upload');

  { ── Row 3: Icon-only ── }
  TBootstrapStyle.ApplyButtonIconOnly(BtnOPrimary,   bsPrimary,   'house',                 18);
  TBootstrapStyle.ApplyButtonIconOnly(BtnOSecondary, bsSecondary, 'download',              18);
  TBootstrapStyle.ApplyButtonIconOnly(BtnOSuccess,   bsSuccess,   'check-lg',              18);
  TBootstrapStyle.ApplyButtonIconOnly(BtnODanger,    bsDanger,    'trash',                 18);
  TBootstrapStyle.ApplyButtonIconOnly(BtnOWarning,   bsWarning,   'lightning-charge-fill', 18);
  TBootstrapStyle.ApplyButtonIconOnly(BtnODark,      bsDark,      'code-slash',            18);

  { ── Row 4: TCornerButton with glyph ── }
  TBootstrapStyle.ApplyCornerButtonGlyph(CbtnPrimary,   bsPrimary,   'plus-lg',         14);
  TBootstrapStyle.ApplyCornerButtonGlyph(CbtnSecondary, bsSecondary, 'pencil',          14);
  TBootstrapStyle.ApplyCornerButtonGlyph(CbtnSuccess,   bsSuccess,   'check-lg',        14);
  TBootstrapStyle.ApplyCornerButtonGlyph(CbtnDanger,    bsDanger,    'trash',           14);
  TBootstrapStyle.ApplyCornerButtonGlyph(CbtnWarning,   bsWarning,   'lightning-charge',14);
  TBootstrapStyle.ApplyCornerButtonGlyph(CbtnInfo,      bsInfo,      'x-lg',            14);

  { ── Section 2: Form Controls ── }
  TBootstrapStyle.ApplyEdit(EditNormal,   14);
  TBootstrapStyle.ApplyEdit(EditPassword, 14);
  TBootstrapStyle.ApplyEdit(EditDisabled, 14);
  TBootstrapStyle.ApplyComboBox(ComboBoxMain,   14);
  TBootstrapStyle.ApplyComboEdit(ComboEditMain, 14);
  TBootstrapStyle.ApplySearchBox(SearchBoxMain, 14);

  { ── Section 3: Memo & List Group ── }
  TBootstrapStyle.ApplyMemo(MemoMain,       14);
  TBootstrapStyle.ApplyListBox(ListBoxMain, 14);

  { ── Section 4: Grids ── }
  TBootstrapStyle.ApplyStringGrid(StringGridMain, 13);
  TBootstrapStyle.ApplyListView(ListViewMain,     13);

  { ── Section 5: Toggle button ── }
  TBootstrapStyle.ApplyButton(BtnToggleBootstrap, bsSuccess,
    'Bootstrap: ON', 14, 'lightning-charge-fill');
end;

procedure TFrameBootstrapShowcase.SetParent(const Value: TFmxObject);
begin
  inherited SetParent(Value);
  if Value <> nil then
    ApplyBootstrapChrome;
end;

procedure TFrameBootstrapShowcase.BtnToggleBootstrapClick(Sender: TObject);
var
  LActive: Boolean;
begin
  LActive := not TBootstrapStyle.GetBootstrapActive;
  TBootstrapStyle.SetBootstrapActive(LActive);
  if LActive then
    TBootstrapStyle.ApplyButton(BtnToggleBootstrap, bsSuccess,
      'Bootstrap: ON', 14, 'lightning-charge-fill')
  else
    BtnToggleBootstrap.Text := 'Bootstrap: OFF';
end;

end.
