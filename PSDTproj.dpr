program PSDTproj;

uses
  Forms,
  PSDT in 'PSDT.pas' {Form1},
  DataHandler in 'DataHandler.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
