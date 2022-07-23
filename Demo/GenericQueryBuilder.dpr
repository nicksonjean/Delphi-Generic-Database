program GenericQueryBuilder;

uses
  System.StartUpCopy,
  FMX.Forms,
  GenericQueryBuilderForm in 'GenericQueryBuilderForm.pas' {GenericQueryBuilderForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGenericQueryBuilderForm, FGenericQueryBuilderForm);
  Application.Run;
end.
