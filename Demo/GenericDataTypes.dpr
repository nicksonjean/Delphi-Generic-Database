program GenericDataTypes;

uses
  System.StartUpCopy,
  FMX.Forms,
  Connection in '..\Source\Connection\Connection.pas',
  EventDriven in '..\Source\EventDriven\EventDriven.pas',
  Locale in '..\Source\Types\Locale\Locale.pas',
  RTTI in '..\Source\Reflection\RTTI.pas',
  Connector in '..\Source\Connector\Connector.pas',
  OptionsInteger in '..\Source\Connector\OptionsInteger.pas',
  OptionsArray in '..\Source\Connector\OptionsArray.pas',
  OptionsJSON in '..\Source\Connector\OptionsJSON.pas',
  XSuperJSON in '..\Source\Vendor\XSuperObject\XSuperJSON.pas',
  XSuperObject in '..\Source\Vendor\XSuperObject\XSuperObject.pas',
  FMX.FireMonkey.Parser in '..\Source\Extensions\FMX.ListView\FMX.FireMonkey.Parser.pas',
  FMX.ListView in '..\Source\Extensions\FMX.ListView\FMX.ListView.pas',
  FMX.ListView.TextButtonFix in '..\Source\Extensions\FMX.ListView\FMX.ListView.TextButtonFix.pas',
  FMX.ListView.Types in '..\Source\Extensions\FMX.ListView\FMX.ListView.Types.pas',
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
  Strings in '..\Source\Types\Strings.pas',
  ArrayAssoc in '..\Source\Types\Array\ArrayAssoc.pas',
  ArrayField in '..\Source\Types\Array\ArrayField.pas',
  ArrayString in '..\Source\Types\Array\ArrayString.pas',
  ArrayVariant in '..\Source\Types\Array\ArrayVariant.pas',
  ArrayFieldHelper in '..\Source\Types\Array\Helpers\ArrayFieldHelper.pas',
  ArrayStringHelper in '..\Source\Types\Array\Helpers\ArrayStringHelper.pas',
  ArrayVariantHelper in '..\Source\Types\Array\Helpers\ArrayVariantHelper.pas',
  IArray in '..\Source\Types\IArray.pas',
  ISmartPointer in '..\Source\SmartPointer\ISmartPointer.pas',
  TSmartPointer in '..\Source\SmartPointer\TSmartPointer.pas',
  GenericDataTypesForm in 'GenericDataTypesForm.pas' {GenericDataTypesForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGenericDataTypesForm, FGenericDataTypesForm);
  Application.Run;
end.
