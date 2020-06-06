program GenericDatabase;

uses
  System.StartUpCopy,
  FMX.Forms,
  Connection in '..\Source\Connection\Connection.pas',
  EventDriven in '..\Source\EventDriven\EventDriven.pas',
  Locale in '..\Source\Types\Locale\Locale.pas',
  Connector in '..\Source\Connector\Connector.pas',
  FMX.ListView.Extension in '..\Source\Extensions\FMX.ListView\FMX.ListView.Extension.pas',
  FMX.Edit.Extension in '..\Source\Extensions\FMX.Edit\FMX.Edit.Extension.pas',
  FMX.Grid.Helper in '..\Source\Helpers\FMX.Grid\FMX.Grid.Helper.pas',
  FMX.ListBox.Helper in '..\Source\Helpers\FMX.ListBox\FMX.ListBox.Helper.pas',
  FMX.ListView.Helper in '..\Source\Helpers\FMX.ListView\FMX.ListView.Helper.pas',
  FMX.StringGrid.Helper in '..\Source\Helpers\FMX.StringGrid\FMX.StringGrid.Helper.pas',
  FMX.Edit.Helper in '..\Source\Helpers\FMX.Edit\FMX.Edit.Helper.pas',
  FMX.ComboEdit.Helper in '..\Source\Helpers\FMX.ComboEdit\FMX.ComboEdit.Helper.pas',
  FMX.ComboBox.Helper in '..\Source\Helpers\FMX.ComboBox\FMX.ComboBox.Helper.pas',
  FMX.Objects.Helper in '..\Source\Helpers\FMX.Objects\FMX.Objects.Helper.pas',
  DictionaryHelper in '..\Source\Helpers\DictionaryHelper\DictionaryHelper.pas',
  ArrayHelper in '..\Source\Helpers\ArrayHelper\ArrayHelper.pas',
  MimeType in '..\Source\Reflection\MimeType.pas',
  TimeDate in '..\Source\Types\TimeDate.pas',
  Float in '..\Source\Types\Float.pas',
  &String in '..\Source\Types\String.pas',
  &Array in '..\Source\Types\Array.pas',
  GenericDatabaseForm in 'GenericDatabaseForm.pas' {FGenericDatabaseForm};

{$R *.res}

begin
  //ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TGenericDatabaseForm, FGenericDatabaseForm);
  Application.Run;
end.