unit sinkemail;

{$mode delphi}

interface

uses
 Classes, XMailer,SysUtils,zipper, fphttpclient;

var
 Mail: TSendMail;

function IsOpenSSLAvailable: Boolean;
function send_email(lEmailHostServer : string;
                    lEmailUserName : string;
                    lEmailPassword : string;
                    lEmailPort : string;
                    lEmailUseSSL : boolean;
                    lEmailUseTLS : boolean;
                    lEmailSenderAddress : string;
                    lEmailTestRecipientAddress : string;
                    lEmailTestSubjectLine : string;
                    lEmailTestMessageText : string) : string;

implementation

function IsOpenSSLAvailable: Boolean;
  {$IFDEF WIN64}
  const
    cOpenSSLURL = 'http://packages.lazarus-ide.org/openssl-1.0.2j-x64_86-win64.zip';
  {$ENDIF}
  {$IFDEF WIN32}
  const
    cOpenSSLURL = 'http://packages.lazarus-ide.org/openssl-1.0.2j-i386-win32.zip';
  {$ENDIF}
  {$IFDEF MSWINDOWS}
var
  UnZipper: TUnZipper;
  FHTTPClient: TFPHTTPClient;
  ParamPath, LibeayDLL, SsleayDLL, ZipFile: String;
  {$EndIf}
begin
  {$IFDEF MSWINDOWS}
  ParamPath := ExtractFilePath(ParamStr(0));
  LibeayDLL := ParamPath + 'libeay32.dll';
  SsleayDLL := ParamPath + 'ssleay32.dll';
  Result := FileExists(libeaydll) and FileExists(ssleaydll);
  if not Result then
  begin
    ZipFile := ParamPath + ExtractFileName(cOpenSSLURL);
    FHTTPClient := TFPHTTPClient.Create(nil);
    try
      try
        FHTTPClient.Get(cOpenSSLURL, ZipFile);
       except
       end;
    finally
      FHTTPClient.Free;
    end;
    if FileExists(ZipFile) then
    begin
      UnZipper := TUnZipper.Create;
      try
        try
          UnZipper.FileName := ZipFile;
          UnZipper.Examine;
          UnZipper.UnZipAllFiles;
        except
        end;
      finally
        UnZipper.Free;
      end;
      DeleteFile(ZipFile);
      Result := FileExists(libeaydll) and FileExists(ssleaydll);
    end;
  end;
  {$ELSE}
  result := True;
  {$ENDIF}
end;

function send_email(lEmailHostServer : string;
                    lEmailUserName : string;
                    lEmailPassword : string;
                    lEmailPort : string;
                    lEmailUseSSL : boolean;
                    lEmailUseTLS : boolean;
                    lEmailSenderAddress : string;
                    lEmailTestRecipientAddress : string;
                    lEmailTestSubjectLine : string;
                    lEmailTestMessageText : string) : string;
begin
 if IsOpenSSLAvailable then
  begin
   Mail := TSendMail.Create;
   try
    try
     // Mail
     Mail.Sender := lEmailSenderAddress;
     Mail.Receivers.Add(lEmailTestRecipientAddress);
     Mail.Subject := lEmailTestSubjectLine;
     Mail.Message.Add(lEmailTestMessageText);
     // SMTP
     Mail.Smtp.UserName := lEmailUserName;
     Mail.Smtp.Password := lEmailPassword;
     Mail.Smtp.Host := lEmailHostServer;
     Mail.Smtp.Port := lEmailPort;
     Mail.Smtp.SSL := lEmailUseSSL;
     Mail.Smtp.TLS := lEmailUseTLS;
     (*
     Mail.Sender := 'sinkauthenticator@gmx.co.uk';
     Mail.Receivers.Add('barlicktaylorst@gmail.com');
     Mail.Subject := 'Test subject.';
     Mail.Message.Add('Test message.');
     // SMTP
     Mail.Smtp.UserName := 'sinkauthenticator@gmx.co.uk';
     Mail.Smtp.Password := 'sinkauthenticator';
     Mail.Smtp.Host := 'mail.gmx.net'; // 'pop.gmx.com'; // 'imap.gmx.net'; // 'mail.gmx.net';
     Mail.Smtp.Port := '587';
     Mail.Smtp.SSL := false;
     Mail.Smtp.TLS := true;
     *)
     Mail.Send;
     result := 'E-mail sent successfully!';
    except
     on E: Exception do
      result := E.Message;
    end;
   finally
    Mail.Free;
   end;
  end
  else result := 'Error: Open SSL is not available.';
end;

end.

