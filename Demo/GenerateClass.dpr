program GenerateClass;

uses
  System.StartUpCopy,
  FMX.Forms,
  GenerateClassForm in 'GenerateClassForm.pas' {FGenerateClassDemoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGenerateClassDemoForm, FGenerateClassDemoForm);
  Application.Run;
end.
