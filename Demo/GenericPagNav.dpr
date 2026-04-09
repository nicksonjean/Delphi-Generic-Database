program GenericPagNav;

uses
  System.StartUpCopy,
  FMX.Forms,
  Type.Locale in '..\Source\Types\Float\Type.Locale.pas',
  &Type.Dictionary.Helper in '..\Source\Types\Dictionary\Type.Dictionary.Helper.pas',
  &Type.&Array.Helper in '..\Source\Types\Array\Type.Array.Helper.pas',
  Type.String in '..\Source\Types\String\Type.String.pas',
  Type.Float in '..\Source\Types\Float\Type.Float.pas',
  MimeType in '..\Source\Reflection\MimeType.pas',
  Type.Array.Guard.Intf in '..\Source\Types\Array\Type.Array.Guard.Intf.pas',
  Type.Array in '..\Source\Types\Array\Type.Array.pas',
  Type.Array.Field in '..\Source\Types\Array\Type.Array.Field.pas',
  Type.Array.String in '..\Source\Types\Array\Type.Array.String.pas',
  Type.Array.Variant in '..\Source\Types\Array\Type.Array.Variant.pas',
  Type.Array.String.Helper in '..\Source\Types\Array\Type.Array.String.Helper.pas',
  Type.Array.Variant.Helper in '..\Source\Types\Array\Type.Array.Variant.Helper.pas',
  Type.Array.Field.Helper in '..\Source\Types\Array\Type.Array.Field.Helper.pas',
  Type.Array.Assoc in '..\Source\Types\Array\Type.Array.Assoc.pas',
  Type.DateTime in '..\Source\Types\DateTime\Type.DateTime.pas',
  SmartPointer.Guard.Intf in '..\Source\SmartPointer\SmartPointer.Guard.Intf.pas',
  SmartPointer.Guard in '..\Source\SmartPointer\SmartPointer.Guard.pas',
  SmartPointer.SmartPointer in '..\Source\SmartPointer\SmartPointer.SmartPointer.pas',
  SmartPointer.RefGuard in '..\Source\SmartPointer\SmartPointer.RefGuard.pas',
  SmartPointer.TSmartPointer in '..\Source\SmartPointer\SmartPointer.TSmartPointer.pas',
  GenericPagNavForm in 'GenericPagNavForm.pas' {FGenericPagNavForm};

{$R GenericPagNav.res}

begin
  Application.Initialize;
  Application.CreateForm(TGenericPagNavForm, FGenericPagNavForm);
  Application.Run;
end.
