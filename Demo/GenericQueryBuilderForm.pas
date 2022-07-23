unit GenericQueryBuilderForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, FMX.ListBox, FMX.StdCtrls, FMX.Layouts,
  FMX.Controls.Presentation, FMX.TabControl;

type
  TGenericQueryBuilderForm = class(TForm)
    TabControl: TTabControl;
    TabQueryBuilder: TTabItem;
    GroupBoxQueryBuilderArrays: TGroupBox;
    GridPanelLayoutQueryBuilderArray: TGridPanelLayout;
    LabelQueryBuilderArrayString: TLabel;
    LabelQueryBuilderArrayVariant: TLabel;
    LabelQueryBuilderArrayField: TLabel;
    ComboBoxQueryBuilderArrayString: TComboBox;
    ComboBoxQueryBuilderArrayVariant: TComboBox;
    ComboBoxQueryBuilderArrayField: TComboBox;
    MemoQueryBuilderArrayResult: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FGenericQueryBuilderForm: TGenericQueryBuilderForm;

implementation

{$R *.fmx}

end.
