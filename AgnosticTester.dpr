program AgnosticTester;

uses
  System.StartUpCopy,
  FMX.Forms,
  SQLConnection in 'SQLConnection\SQLConnection.pas',
  EventDriven in 'SQLConnection\EventDriven\EventDriven.pas',
  Locale in 'SQLConnection\Types\Locale\Locale.pas',
  Connector in 'SQLConnection\Connector\Connector.pas',
  FMX.ListView.Extension in 'SQLConnection\Extensions\FMX.ListView\FMX.ListView.Extension.pas',
  FMX.Edit.Extension in 'SQLConnection\Extensions\FMX.Edit\FMX.Edit.Extension.pas',
  FMX.Grid.Helper in 'SQLConnection\Helpers\FMX.Grid\FMX.Grid.Helper.pas',
  FMX.ListBox.Helper in 'SQLConnection\Helpers\FMX.ListBox\FMX.ListBox.Helper.pas',
  FMX.ListView.Helper in 'SQLConnection\Helpers\FMX.ListView\FMX.ListView.Helper.pas',
  FMX.StringGrid.Helper in 'SQLConnection\Helpers\FMX.StringGrid\FMX.StringGrid.Helper.pas',
  FMX.Edit.Helper in 'SQLConnection\Helpers\FMX.Edit\FMX.Edit.Helper.pas',
  FMX.ComboEdit.Helper in 'SQLConnection\Helpers\FMX.ComboEdit\FMX.ComboEdit.Helper.pas',
  FMX.ComboBox.Helper in 'SQLConnection\Helpers\FMX.ComboBox\FMX.ComboBox.Helper.pas',
  FMX.Objects.Helper in 'SQLConnection\Helpers\FMX.Objects\FMX.Objects.Helper.pas',
  DictionaryHelper in 'SQLConnection\Helpers\DictionaryHelper\DictionaryHelper.pas',
  ArrayHelper in 'SQLConnection\Helpers\ArrayHelper\ArrayHelper.pas',
  MimeType in 'SQLConnection\Reflection\MimeType.pas',
  TimeDate in 'SQLConnection\Types\TimeDate.pas',
  Float in 'SQLConnection\Types\Float.pas',
  &String in 'SQLConnection\Types\String.pas',
  &Array in 'SQLConnection\Types\Array.pas',
  AgnosticTesterForm in 'AgnosticTesterForm.pas' {FAgnosticTesterForm};

{$R *.res}

begin
  //ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TAgnosticTesterForm, FAgnosticTesterForm);
  Application.Run;
end.