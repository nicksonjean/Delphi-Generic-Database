program GenericDemo;
uses
  FastMM5 in '..\Source\Vendor\FastMM5\FastMM5.pas',
  System.StartUpCopy,
  FMX.Forms,
  XSuperJSON in '..\Source\Vendor\XSuperObject\XSuperJSON.pas',
  XSuperObject in '..\Source\Vendor\XSuperObject\XSuperObject.pas',
  FMX.FireMonkey.Parser in '..\Source\Helpers\FMX.ListView\FMX.FireMonkey.Parser.pas',
  FMX.ListView in '..\Source\Helpers\FMX.ListView\FMX.ListView.pas',
  FMX.ListView.TextButtonFix in '..\Source\Helpers\FMX.ListView\FMX.ListView.TextButtonFix.pas',
  FMX.ListView.Types in '..\Source\Helpers\FMX.ListView\FMX.ListView.Types.pas',
  FMX.ListView.Extension in '..\Source\Helpers\FMX.ListView\FMX.ListView.Extension.pas',
  FMX.Edit.Suggest.Messages in '..\Source\Helpers\FMX.Edit\FMX.Edit.Suggest.Messages.pas',
  FMX.Edit.Extension in '..\Source\Helpers\FMX.Edit\FMX.Edit.Extension.pas',
  FMX.Grid.Helper in '..\Source\Helpers\FMX.Grid\FMX.Grid.Helper.pas',
  FMX.ListBox.Helper in '..\Source\Helpers\FMX.ListBox\FMX.ListBox.Helper.pas',
  FMX.ListView.Helper in '..\Source\Helpers\FMX.ListView\FMX.ListView.Helper.pas',
  FMX.StringGrid.Helper in '..\Source\Helpers\FMX.StringGrid\FMX.StringGrid.Helper.pas',
  Masks in '..\Source\Classes\Masks\Masks.pas',
  FMX.Edit.Helper in '..\Source\Helpers\FMX.Edit\FMX.Edit.Helper.pas',
  FMX.ComboEdit.Helper in '..\Source\Helpers\FMX.ComboEdit\FMX.ComboEdit.Helper.pas',
  FMX.ComboEdit.Extension in '..\Source\Helpers\FMX.ComboEdit\FMX.ComboEdit.Extension.pas',
  FMX.ComboBox.Helper in '..\Source\Helpers\FMX.ComboBox\FMX.ComboBox.Helper.pas',
  FMX.Objects.Helper in '..\Source\Helpers\FMX.Objects\FMX.Objects.Helper.pas',
  FMX.Style.Helper in '..\Source\Helpers\FMX.Style\FMX.Style.Helper.pas',
  &Type.Dictionary.Helper in '..\Source\Types\Dictionary\Type.Dictionary.Helper.pas',
  &Type.&Array.Helper in '..\Source\Types\Array\Type.Array.Helper.pas',
  EventDelegate in '..\Source\Classes\EventDelegate\EventDelegate.pas',
  MimeType in '..\Source\Reflection\MimeType.pas',
  RTTI in '..\Source\Reflection\RTTI.pas',
  EventDriven.All in '..\Source\EventDriven\EventDriven.All.pas',
  Mail.SChannel in '..\Source\Classes\Mailer\Mail.SChannel.pas',
  &Type.All in '..\Source\Types\Type.All.pas',
  SmartPointer.All in '..\Source\SmartPointer\SmartPointer.All.pas',
  Connection.All in '..\Source\Connection\Connection.All.pas',
  Connector.All in '..\Source\Connector\Connector.All.pas',
  GenericDemoForm in 'GenericDemoForm.pas' {TGenericDemoForm},
  Frame.Connection in 'Frames\Frame.Connection.pas' {TFrameConnection: TFrame},
  Frame.Connector in 'Frames\Frame.Connector.pas' {TFrameConnector: TFrame},
  Frame.DataTypes in 'Frames\Frame.DataTypes.pas' {TFrameDataTypes: TFrame},
  Frame.PagNav in 'Frames\Frame.PagNav.pas' {TFramePagNav: TFrame},
  Frame.BootstrapShowcase in 'Frames\Frame.BootstrapShowcase.pas' {FrameBootstrapShowcase: TFrame};

{$R *.res}
{$R 'Resources\Fonts\fonts.res'}
begin
  FastMM_EnterDebugMode;
  FastMM_MessageBoxEvents := [];
  FastMM_LogToFileEvents := FastMM_LogToFileEvents + [
    mmetUnexpectedMemoryLeakDetail,
    mmetUnexpectedMemoryLeakSummary
  ];
  // Load embedded fonts BEFORE Application.Initialize so DirectWrite
  // includes them in its font collection from the very first query.
  TFontResourceHelper.RegisterFontFromResource('BOOTSTRAP_ICONS');
  Application.Initialize;
  Application.CreateForm(TGenericDemoForm, FGenericDemoForm);
  Application.Run;
  ReportMemoryLeaksOnShutdown := True;
end.
