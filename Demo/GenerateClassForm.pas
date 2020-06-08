unit GenerateClassForm;

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
  Fmx.Bind.Navigator;

type
  TGenerateClassForm = class(TForm)
    PagPanelLayout: TGridPanelLayout;
    PagButtonFirst: TCornerButton;
    PagButtonPrior: TCornerButton;
    PagButtonNext: TCornerButton;
    PagButtonLast: TCornerButton;
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
    BindNavigator1: TBindNavigator;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FGenerateClassForm: TGenerateClassForm;

implementation

{$R *.fmx}

{
dbNavigator1.VisibleButtons := [nbFirst,nbPrior,nbNext,nbLast,nbInsert,nbEdit,nbPost,nbCancel,nbRefresh]
}

end.
