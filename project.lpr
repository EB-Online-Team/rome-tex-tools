program project;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX}
  cthreads,
     {$ENDIF} {$IFDEF HASAMIGA}
  athreads,
     {$ENDIF}
  Interfaces,
  Forms,
  Main,
  Utils;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Title := 'RomeTexTools';
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
