program GenericPagNav;

uses
  System.StartUpCopy,
  FMX.Forms,
  Locale in '..\Source\Types\Locale\Locale.pas',
  DictionaryHelper in '..\Source\Helpers\DictionaryHelper\DictionaryHelper.pas',
  ArrayHelper in '..\Source\Helpers\ArrayHelper\ArrayHelper.pas',
  MimeType in '..\Source\Reflection\MimeType.pas',
  TimeDate in '..\Source\Types\TimeDate.pas',
  Float in '..\Source\Types\Float.pas',
  Strings in '..\Source\Types\Strings.pas',
  IArray in '..\Source\Types\IArray.pas',
  ArrayAssoc in '..\Source\Types\Array\ArrayAssoc.pas',
  ArrayField in '..\Source\Types\Array\ArrayField.pas',
  ArrayString in '..\Source\Types\Array\ArrayString.pas',
  ArrayVariant in '..\Source\Types\Array\ArrayVariant.pas',
  ArrayFieldHelper in '..\Source\Types\Array\Helpers\ArrayFieldHelper.pas',
  ArrayStringHelper in '..\Source\Types\Array\Helpers\ArrayStringHelper.pas',
  ArrayVariantHelper in '..\Source\Types\Array\Helpers\ArrayVariantHelper.pas',
  SmartPointer.IGuard.Intf in '..\Source\SmartPointer\SmartPointer.IGuard.Intf.pas',
  SmartPointer.Guard in '..\Source\SmartPointer\SmartPointer.Guard.pas',
  SmartPointer.ISmartPointer in '..\Source\SmartPointer\SmartPointer.ISmartPointer.pas',
  SmartPointer.RefGuard in '..\Source\SmartPointer\SmartPointer.RefGuard.pas',
  SmartPointer.TSmartPointer in '..\Source\SmartPointer\SmartPointer.TSmartPointer.pas',
  GenericPagNavForm in 'GenericPagNavForm.pas' {FGenericPagNavForm};

{$R GenericPagNav.res}

begin
  Application.Initialize;
  Application.CreateForm(TGenericPagNavForm, FGenericPagNavForm);
  Application.Run;
end.
