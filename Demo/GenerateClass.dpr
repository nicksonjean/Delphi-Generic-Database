program GenerateClass;

uses
  System.StartUpCopy,
  FMX.Forms,
  GenerateClassForm in 'GenerateClassForm.pas' {FGenerateClassForm};

{$R *.res}

begin
  //ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TGenerateClassForm, FGenerateClassForm);
  Application.Run;
end.
