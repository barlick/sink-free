program sink;

uses
  Forms,
  sinkmain in 'sinkmain.pas' {sinkmainform};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tsinkmainform, sinkmainform);
  Application.Run;
end.
