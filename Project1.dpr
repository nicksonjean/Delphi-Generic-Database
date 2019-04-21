program Project1;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Conversion in 'Conversion.pas',
  ArrayAssoc in 'ArrayAssoc.pas',
  SQLConnection in 'SQLConnection.pas',
  MultiDetailAppearanceU in 'MultiDetailAppearanceU.pas';

{$R *.res}

begin
  //ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
