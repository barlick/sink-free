program sink;

{$MODE Delphi}

uses
  Forms, datetimectrls, Interfaces,
  sinkmain in 'sinkmain.pas', sinkemail {sinkmainform};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tsinkmainform, sinkmainform);
  Application.Run;
end.
