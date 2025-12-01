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
                    lEmailRecipientAddress : string;
                    lEmailSubjectLine : string;
                    lEmailMessageTextStringList : TStringList;
                    iEmailAttachementFileName : string) : string;

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
                    lEmailRecipientAddress : string;
                    lEmailSubjectLine : string;
                    lEmailMessageTextStringList : TStringList;
                    iEmailAttachementFileName : string) : string;
var
 ct,x : integer;
 tempEmailRecipientAddress,thisemailaddress : string;

function strip(s : string) : string;
var
 i : integer;
begin
 i := length(s);
 while (i > 0) and (s[i] = ' ') do dec(i);
 setlength(s,i);
 result := s;
end;

function stripfront(s : string) : string;
var
 i,l : integer;
begin
 i := 1;  l := length(s);
 while (i <= l) and (s[i] = ' ') do inc(i);
 delete(s,1,i-1);
 result := s;
end;

begin
 if IsOpenSSLAvailable then
  begin
   Mail := TSendMail.Create;
   try
    try
     // Mail
     Mail.Sender := lEmailSenderAddress;
     if pos(';',lEmailRecipientAddress) > 0 then
      begin
       tempEmailRecipientAddress := lEmailRecipientAddress;
       while length(tempEmailRecipientAddress) > 1 do
        begin
         x := pos(';',tempEmailRecipientAddress);
         if x > 0 then
          begin
           thisemailaddress := copy(tempEmailRecipientAddress,1,x-1);
           thisemailaddress := stringreplace(thisemailaddress,';','',[rfreplaceall]);
           thisemailaddress := stringreplace(thisemailaddress,'"','',[rfreplaceall]);
           thisemailaddress := strip(stripfront(thisemailaddress));
           if pos('@',thisemailaddress) > 0 then
            begin
             Mail.Receivers.Add(thisemailaddress);
            end;
           tempEmailRecipientAddress := copy(tempEmailRecipientAddress,x+1,length(tempEmailRecipientAddress));
           if length(tempEmailRecipientAddress) > 1 then
            begin
             tempEmailRecipientAddress := strip(stripfront(tempEmailRecipientAddress));
             if copy(tempEmailRecipientAddress,length(tempEmailRecipientAddress),1) <> ';' then tempEmailRecipientAddress := tempEmailRecipientAddress + ';';
            end;
          end;
        end;
      end
      else Mail.Receivers.Add(strip(stripfront(lEmailRecipientAddress)));
     Mail.Subject := lEmailSubjectLine;
     if lEmailMessageTextStringList.Count > 0 then
      begin
       ct := 0;
       while ct < lEmailMessageTextStringList.count do
        begin
         Mail.Message.Add(lEmailMessageTextStringList[ct]);
         inc(ct);
        end;
      end;
     if iEmailAttachementFileName <> '' then
      begin
       Mail.Attachments.Add(iEmailAttachementFileName);
      end;
     // SMTP
     Mail.Smtp.UserName := lEmailUserName;
     Mail.Smtp.Password := lEmailPassword;
     Mail.Smtp.Host := lEmailHostServer;
     Mail.Smtp.Port := lEmailPort;
     Mail.Smtp.SSL := lEmailUseSSL;
     Mail.Smtp.TLS := lEmailUseTLS;
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

