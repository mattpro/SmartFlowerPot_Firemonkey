program SmartFlowerPotScanner;

uses
  System.StartUpCopy,
  FMX.Forms,
  main in 'main.pas' {Form1},
  SmartFlowerPot in 'SmartFlowerPot.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
