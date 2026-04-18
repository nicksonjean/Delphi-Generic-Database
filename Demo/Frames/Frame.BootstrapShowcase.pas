unit Frame.BootstrapShowcase;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Rtti,
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
  FMX.Consts,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.SearchBox,
  FMX.ListView,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
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
    LayFormsMemo: TLayout;
    LblMemo: TLabel;
    MemoMain: TMemo;
    { Section 3: Lists }
    RectSectionLists: TRectangle;
    RectListsHeader: TRectangle;
    LblListsTitle: TLabel;
    RectListsDivider: TRectangle;
    LayListsBody: TLayout;
    LayListsLeft: TLayout;
    ListBoxMain: TListBox;
    LayListsRight: TLayout;
    ListViewMain: TListView;
    { Section 4: Grids }
    RectSectionGrid: TRectangle;
    RectGridHeader: TRectangle;
    LblGridTitle: TLabel;
    RectGridDivider: TRectangle;
    LayGridBody: TLayout;
    LayGridLeft: TLayout;
    StringGridMain: TStringGrid;
    LayGridMid: TLayout;
    GridExample: TGrid;
    { Section 5: Toggle }
    RectSectionToggle: TRectangle;
    RectToggleHeader: TRectangle;
    LblToggleTitle: TLabel;
    RectToggleDivider: TRectangle;
    LayToggleBody: TLayout;
    BtnToggleBootstrap: TButton;
    procedure BtnToggleBootstrapClick(Sender: TObject);
  private
    FGridDemoCells: TArray<TArray<string>>;
    procedure PopulateData;
    procedure SetupGridExample;
    procedure GridExampleGetValue(Sender: TObject; const ACol, ARow: Integer; var AValue: TValue);
    procedure GridExampleSetValue(Sender: TObject; const ACol, ARow: Integer; const AValue: TValue);
    procedure ApplyBootstrapChrome;
    procedure RelayoutShowcaseColumns;
  protected
    procedure SetParent(const Value: TFmxObject); override;
    procedure Resize; override;
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

procedure TFrameBootstrapShowcase.RelayoutShowcaseColumns;
const
  GAP = 12;
var
  InnerW, InnerH, CellW: Single;
begin
  { Form controls: 3 equal columns (33% / 33% / 34% via same cell width + gaps). }
  if (LayFormsBody <> nil) and (LayFormsLeft <> nil) and (LayFormsRight <> nil) and
     (LayFormsMemo <> nil) and (LayFormsBody.Width > 8) then
  begin
    InnerW := LayFormsBody.Width - LayFormsBody.Padding.Left - LayFormsBody.Padding.Right;
    InnerH := LayFormsBody.Height - LayFormsBody.Padding.Top - LayFormsBody.Padding.Bottom;
    CellW := (InnerW - 2 * GAP) / 3;
    LayFormsLeft.Align := TAlignLayout.None;
    LayFormsRight.Align := TAlignLayout.None;
    LayFormsMemo.Align := TAlignLayout.None;
    LayFormsRight.Margins.Left := 0;
    LayFormsMemo.Margins.Left := 0;
    LayFormsLeft.Position.X := LayFormsBody.Padding.Left;
    LayFormsLeft.Position.Y := LayFormsBody.Padding.Top;
    LayFormsLeft.Width := CellW;
    LayFormsLeft.Height := InnerH;
    LayFormsRight.Position.X := LayFormsLeft.Position.X + CellW + GAP;
    LayFormsRight.Position.Y := LayFormsBody.Padding.Top;
    LayFormsRight.Width := CellW;
    LayFormsRight.Height := InnerH;
    LayFormsMemo.Position.X := LayFormsRight.Position.X + CellW + GAP;
    LayFormsMemo.Position.Y := LayFormsBody.Padding.Top;
    LayFormsMemo.Width := CellW;
    LayFormsMemo.Height := InnerH;
  end;

  { Lists: ListBox | ListView (50 / 50). }
  if (LayListsBody <> nil) and (LayListsLeft <> nil) and (LayListsRight <> nil) and
     (LayListsBody.Width > 8) then
  begin
    InnerW := LayListsBody.Width - LayListsBody.Padding.Left - LayListsBody.Padding.Right;
    InnerH := LayListsBody.Height - LayListsBody.Padding.Top - LayListsBody.Padding.Bottom;
    CellW := (InnerW - GAP) / 2;
    LayListsLeft.Align := TAlignLayout.None;
    LayListsRight.Align := TAlignLayout.None;
    LayListsRight.Margins.Left := 0;
    LayListsLeft.Position.X := LayListsBody.Padding.Left;
    LayListsLeft.Position.Y := LayListsBody.Padding.Top;
    LayListsLeft.Width := CellW;
    LayListsLeft.Height := InnerH;
    LayListsRight.Position.X := LayListsLeft.Position.X + CellW + GAP;
    LayListsRight.Position.Y := LayListsBody.Padding.Top;
    LayListsRight.Width := CellW;
    LayListsRight.Height := InnerH;
  end;

  { Grids: TStringGrid | TGrid (50 / 50). }
  if (LayGridBody <> nil) and (LayGridLeft <> nil) and (LayGridMid <> nil) and
     (LayGridBody.Width > 8) then
  begin
    InnerW := LayGridBody.Width - LayGridBody.Padding.Left - LayGridBody.Padding.Right;
    InnerH := LayGridBody.Height - LayGridBody.Padding.Top - LayGridBody.Padding.Bottom;
    CellW := (InnerW - GAP) / 2;
    LayGridLeft.Align := TAlignLayout.None;
    LayGridMid.Align := TAlignLayout.None;
    LayGridMid.Margins.Left := 0;
    LayGridLeft.Position.X := LayGridBody.Padding.Left;
    LayGridLeft.Position.Y := LayGridBody.Padding.Top;
    LayGridLeft.Width := CellW;
    LayGridLeft.Height := InnerH;
    LayGridMid.Position.X := LayGridLeft.Position.X + CellW + GAP;
    LayGridMid.Position.Y := LayGridBody.Padding.Top;
    LayGridMid.Width := CellW;
    LayGridMid.Height := InnerH;
  end;
end;

procedure TFrameBootstrapShowcase.Resize;
begin
  inherited;
  RelayoutShowcaseColumns;
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

  SetupGridExample;
end;

procedure TFrameBootstrapShowcase.SetupGridExample;
var
  Col: TStringColumn;
  R:   Integer;
begin
  SetLength(FGridDemoCells, 4);
  for R := 0 to 3 do
    SetLength(FGridDemoCells[R], 3);

  FGridDemoCells[0][0] := 'host';
  FGridDemoCells[0][1] := 'string';
  FGridDemoCells[0][2] := 'localhost';
  FGridDemoCells[1][0] := 'port';
  FGridDemoCells[1][1] := 'integer';
  FGridDemoCells[1][2] := '5432';
  FGridDemoCells[2][0] := 'database';
  FGridDemoCells[2][1] := 'string';
  FGridDemoCells[2][2] := 'myapp_db';
  FGridDemoCells[3][0] := 'username';
  FGridDemoCells[3][1] := 'string';
  FGridDemoCells[3][2] := 'admin';

  GridExample.BeginUpdate;
  try
    if GridExample.ColumnCount = 0 then
    begin
      Col := TStringColumn.Create(GridExample);
      Col.Header := 'Name';
      Col.Width  := 100;
      GridExample.AddObject(Col);

      Col := TStringColumn.Create(GridExample);
      Col.Header := 'Type';
      Col.Width  := 100;
      GridExample.AddObject(Col);

      Col := TStringColumn.Create(GridExample);
      Col.Header := 'Value';
      Col.Width  := 120;
      GridExample.AddObject(Col);
    end;

    GridExample.RowCount := 4;
    GridExample.OnGetValue := GridExampleGetValue;
    GridExample.OnSetValue := GridExampleSetValue;

    if GridExample.Model <> nil then
    begin
      GridExample.Model.DefaultDrawing := True;
      GridExample.Model.DataStored     := False;
    end;
  finally
    GridExample.EndUpdate;
  end;
end;

procedure TFrameBootstrapShowcase.GridExampleGetValue(Sender: TObject; const ACol, ARow: Integer;
  var AValue: TValue);
begin
  if (ARow >= 0) and (ARow < Length(FGridDemoCells)) and
     (ACol >= 0) and (ACol < Length(FGridDemoCells[ARow])) then
    AValue := FGridDemoCells[ARow][ACol]
  else
    AValue := '';
end;

procedure TFrameBootstrapShowcase.GridExampleSetValue(Sender: TObject; const ACol, ARow: Integer;
  const AValue: TValue);
begin
  if (ARow >= 0) and (ARow < Length(FGridDemoCells)) and
     (ACol >= 0) and (ACol < Length(FGridDemoCells[ARow])) then
    FGridDemoCells[ARow][ACol] := AValue.AsString;
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

  { ── Section 2: Form Controls — labels ── }
  TBootstrapStyle.ApplyFormLabel(LblEditNormal,   14);
  TBootstrapStyle.ApplyFormLabel(LblEditPassword, 14);
  TBootstrapStyle.ApplyFormLabel(LblEditDisabled, 14);
  TBootstrapStyle.ApplyFormLabel(LblComboBox,     14);
  TBootstrapStyle.ApplyFormLabel(LblComboEdit,    14);
  TBootstrapStyle.ApplyFormLabel(LblSearchBox,    14);
  TBootstrapStyle.ApplyFormLabel(LblMemo,         14);

  { ── Section 2: Form Controls — inputs ── }
  TBootstrapStyle.ApplyEdit(EditNormal,   14);
  TBootstrapStyle.ApplyEdit(EditPassword, 14);
  TBootstrapStyle.ApplyEdit(EditDisabled, 14);
  TBootstrapStyle.ApplyComboBox(ComboBoxMain,   14);
  TBootstrapStyle.ApplyComboEdit(ComboEditMain, 14);
  TBootstrapStyle.ApplySearchBox(SearchBoxMain, 14);

  { ── Section 2 (cont.): Textarea in 3rd column ── }
  TBootstrapStyle.ApplyMemo(MemoMain, 14);

  { ── Section 3: Lists ── }
  TBootstrapStyle.ApplyListBox(ListBoxMain, 14);
  TBootstrapStyle.ApplyListView(ListViewMain, 13);

  { ── Section 4: Grids ── }
  TBootstrapStyle.ApplyStringGrid(StringGridMain, 13);
  TBootstrapStyle.ApplyGrid(GridExample, 13);

  { ── Section 5: Toggle button ── }
  TBootstrapStyle.ApplyButton(BtnToggleBootstrap, bsSuccess,
    'Bootstrap: ON', 14, 'lightning-charge-fill');
end;

procedure TFrameBootstrapShowcase.SetParent(const Value: TFmxObject);
begin
  inherited SetParent(Value);
  if Value <> nil then
  begin
    ApplyBootstrapChrome;
    RelayoutShowcaseColumns;
  end;
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
