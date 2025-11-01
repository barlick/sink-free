program sink;

{$MODE Delphi}

uses
  Forms, Interfaces,
  sinkmain in 'sinkmain.pas' {sinkmainform};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tsinkmainform, sinkmainform);
  Application.Run;
end.
