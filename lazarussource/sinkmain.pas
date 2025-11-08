unit sinkmain;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, ImgList, Grids, Buttons,LazFileUtils,FileUtil;

const
 runmodecopyfiles : integer = 0;
 runmodesetfilestamps : integer = 1;

 scanmode_scanonly : integer = 0;
 scanmode_copyfiles : integer = 1;
 scanmode_deletefiles : integer = 2;
 scanmode_setfilestamps : integer = 3;

 copyifnotpresent : integer = 0;
 copyifnotpresentorchanged : integer = 1;

type
  source_and_target_rec = record
   sourcefolder : string;
   targetfolder : string;
   copymode : integer;
   deletefiles : boolean;
   scan_filesize : int64; // Number of bytes that will be copied for this "source_and_target_rec" detected during scanmode_scanonly.
  end;

  { Tsinkmainform }

  Tsinkmainform = class(TForm)
    PageControl1: TPageControl;
    DocumentationTabSheet: TTabSheet;
    Memo1: TMemo;
    HomeTabSheet: TTabSheet;
    ConfigurationTabSheet: TTabSheet;
    ImageList1: TImageList;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SourceAndTargetFoldersStringGrid: TStringGrid;
    Panel3: TPanel;
    NewBitBtn: TBitBtn;
    DeleteBitBtn: TBitBtn;
    SourceFolderEdit: TEdit;
    TargetFolderEdit: TEdit;
    SourceFolderLabel: TLabel;
    TargetFolderLabel: TLabel;
    SourceFolderBrowseBitBtn: TBitBtn;
    TargetFolderBrowseBitBtn: TBitBtn;
    ApplyChangesBitBtn: TBitBtn;
    DiscardChangesBitBtn: TBitBtn;
    Panel2: TPanel;
    pathLabel: TLabel;
    filenameLabel: TLabel;
    Label1: TLabel;
    Panel1: TPanel;
    StartButton: TBitBtn;
    ActivityLogMemo: TMemo;
    Stopbutton: TBitBtn;
    LabelTimeElapsed: TLabel;
    LabelTimeRemaining: TLabel;
    copymodeComboBox: TComboBox;
    ProgressBarBR: TProgressBar;
    Label2: TLabel;
    DeleteFilesCheckBox: TCheckBox;
    setfilestampsbutton: TBitBtn;
    procedure StartButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SourceAndTargetFoldersStringGridClick(Sender: TObject);
    procedure SourceFolderBrowseBitBtnClick(Sender: TObject);
    procedure TargetFolderBrowseBitBtnClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure NewBitBtnClick(Sender: TObject);
    procedure DeleteBitBtnClick(Sender: TObject);
    procedure SourceFolderEditChange(Sender: TObject);
    procedure TargetFolderEditChange(Sender: TObject);
    procedure ApplyChangesBitBtnClick(Sender: TObject);
    procedure DiscardChangesBitBtnClick(Sender: TObject);
    procedure StopbuttonClick(Sender: TObject);
    procedure copymodeComboBoxChange(Sender: TObject);
    procedure DeleteFilesCheckBoxClick(Sender: TObject);
    procedure setfilestampsbuttonClick(Sender: TObject);
  private
    { Private declarations }
    preference_switch_allow_deletefiles : boolean;
    preference_switch_allow_deletefolders : boolean;
    preference_switch_allow_diskfree_checks : boolean;
    preference_switch_min_freediskspace_percent : int64;
    preference_switch_FileSetDateMaxPasses : int64;
    preference_switch_FileSetDateSleepTime : int64;
    source_and_target_array : array of source_and_target_rec;
    source_and_target_array_count : integer;
    stats_filesize : int64;
    stats_bytes_written : int64;
    stats_numfiles_copied : int64;
    stats_numfiles_scanned : int64;
    stats_filesize_scanned : int64;
    stats_numfiles_deleted : int64;
    stats_numerrors : int64;
    abort : boolean;
    processstarttime : TDateTime;
    copyfilesstarttime : TDateTime;
    copyfilesendtime : TDateTime;
    usersettingsdir : string;
    targetfolderfoldersstringlist : TStringlist;
    filesinsourcealsointargetstringlist : TStringlist;
    filesinsourcealsointargetstringlist_count : int64;
    filesinsourcealsointargetstringlist_maxsize : int64;
    filesinsourcealsointargetstringlist_bytesadded : int64;
    filesinsourcealsointargetstringlist_lastfilenameadded : string;
    ok_to_use_filesinsourcealsointargetstringlist : boolean;
  public
    { Public declarations }
    procedure load_ini_settings;
    procedure save_ini_settings;
    procedure fill_in_SourceAndTargetFoldersStringGrid;
    function fn_SourceAndTargetFoldersStringGrid_has_changed : boolean;
    procedure run_process(runmode : integer);
    procedure sIncProgress(numw : int64);
  end;

var
  sinkmainform: Tsinkmainform;

implementation

{$R *.lfm}

function fn_OSVersion: string;
begin
  {$IFDEF LCLcarbon}
  fn_OSVersion := 'Mac';
  {$ELSE}
  {$IFDEF Linux}
  fn_OSVersion := 'Linux';
  {$ELSE}
  {$IFDEF UNIX}
  fn_OSVersion := 'Linux';
  {$ELSE}
  {$IFDEF WINDOWS}
  fn_OSVersion:= 'Windows';
  {$ENDIF}
  {$ENDIF}
  {$ENDIF}
  {$ENDIF}
end;

function HumanReadableNumbytes(Bytes: Int64): string;
var
 Units: array[0..7] of string = ('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB');
 Factor: Integer;
 Size: Double;
begin
 Size := Bytes;
 Factor := 0;
 while (Size >= 1024) and (Factor < High(Units)) do
  begin
   Size := Size / 1024;
   Inc(Factor);
  end;
 Result := Format('%.2f %s', [Size, Units[Factor]]);
end;

function GetFileDetails(sFileName : string; var FileDateTime : TDateTime; var iFileSize : int64) : boolean;
var
  SearchRec : TSearchRec;
begin
  Result := false;
  FileDateTime := 0;
  iFileSize := 0;

  if FindFirst(sFileName, faANYFILE, SearchRec) = 0 then
  begin
   FileDateTime := SearchRec.TimeStamp;
   iFileSize := Searchrec.Size;
   FindClose(SearchRec);
   Result := true;
  end;
end;

function DelimitPath(PathIn : string) : string;
begin
 result := AppendPathDelim(PathIn);
end;

function sr(s : real; intpart,fractpart : integer) : string;
var
 st : string;
begin
 str(s:intpart:fractpart,st);
 result := st;
end;

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

function BrowseFolderDlg(StartFolder : string) : string;
begin
 Result := StartFolder; // return the folder we started with.
 try
  if DirectoryExists(StartFolder) then
   sinkmainform.SelectDirectoryDialog1.InitialDir := StartFolder
  else
   sinkmainform.SelectDirectoryDialog1.InitialDir := '';
  // fire up the dialog
  if sinkmainform.SelectDirectoryDialog1.Execute then
   begin
    Result := sinkmainform.SelectDirectoryDialog1.FileName;
    Result := Delimitpath(result);
   end;
 finally
 end;
end;

procedure Tsinkmainform.sIncProgress(numw : int64);
var
 timenow,T : TDateTime;
 percentcomplete,throughput,numsec,onepercent,progpos : double;
 throughputstr : string;

function NumberOfSeconds(tim: TDateTime): double;
var H,m,s,l: word;
begin
 DecodeTime(tim,h,m,s,l);
 result := s + (m * 60) + (h * 3600);
end;

begin
 stats_bytes_written := stats_bytes_written + numw;
 onepercent := stats_filesize / ProgressBarBR.Max; // Note that progbar.max = 1000 not 100 so as to improve the granularity of the progress bar.
 progpos := stats_bytes_written / onepercent;
 if stats_filesize - stats_bytes_written < onepercent then progpos := ProgressBarBR.Max;
 if stats_filesize < stats_bytes_written then progpos := ProgressBarBR.Max; // Make sure we don't fall off the end.
 ProgressBarBR.Position := trunc(progpos);
 if progpos >= ProgressBarBR.Max then
  begin
   percentcomplete := 100;
  end
  else
  begin
   if ProgressBarBR.Max <> 0 then
    begin
     percentcomplete := (progpos / ProgressBarBR.Max) * 100;
    end
    else percentcomplete := 100;
  end;

 timenow := now;
 T := timenow - copyfilesstarttime;
 LabelTimeElapsed.Caption := 'Time Elapsed: ' + FormatDateTime('hh:mm.ss', T); // Time elapsed.
 // So stats_bytes_written = number of bytes written and "T" is the elapsed time, so throughput bytes per second = stats_bytes_written/seconds elapsed (now - copy files start time).
 if T > 0  then
  begin
   numsec := NumberOfSeconds(T);
   if numsec > 0 then
    begin
     throughput := stats_bytes_written; // Bytes written.
     throughputstr := ' Read+Write Speed '+ HumanReadableNumbytes(trunc(throughput/numsec))+'/s';
    end;
  end
  else
  begin
   throughputstr := '';
  end;

 if stats_bytes_written > 0 then
  begin
   T := (timenow - copyfilesstarttime) * (1 - stats_filesize / stats_bytes_written);
  end
  else T := 0;
 LabelTimeRemaining.Caption := 'Time Remaining: ' + FormatDateTime('hh:mm.ss', T) +' (' + sr(percentcomplete,3,2)+'% complete)'+ throughputstr; // Time remaning + Throughout
end;

procedure Tsinkmainform.run_process(runmode : integer);
var
 sourcefolder,targetfolder,s1 : string;
 statsstringlist : TStringList;
 copymode : integer;
 deletefiles : boolean;
 pass,ct,ct1 : integer;

function fn_make_and_test_folder(foldername : string) : boolean; {returns false if no go} // Danny 1-10-2014 FB 10604.
var
 matf : boolean;
 testfile : textfile;
 err : integer;
begin
 {Ensure "foldername" exists}
 {$I-}
 foldername := strip(stripfront(foldername));
 foldername := delimitpath(foldername);
 ForceDirectories(strip(stripfront(foldername)));
 if ioresult = 0 then begin end;
 {OK, that directory should be there, let's try to access it..}
 assignfile(testfile,foldername+'TEST.TXT');
 rewrite(testfile);
 err := ioresult;
 if err = 0 then
  begin
   writeln(testfile,'This is a test file from the Sink app (Checking validity of foldername).');
  end;
 closefile(testfile);
 if ioresult = 0 then begin end;
 erase(testfile);
 if ioresult = 0 then begin end;
 {$I+}
 matf := err = 0;
 result := matf;
end;

function fn_sinkcopyfile(fromfile,tofile : string) : boolean;
type
 ppsave = array[1..1048576] of char; // 1MB (1024 bytes * 1024).
var
 f,f1 : file;
 numr,numw : longint;
 psave : ^ppsave;
 propertofile,origfileext : string;
 ct : integer;
begin
 {$I-}
 // Note the intended target file's file extension and then copy it as .tmp:
 result := false;
 origfileext := ExtractFileExt(tofile);
 if uppercase(origfileext) = '.TMP' then // If we are unlucky enough to be copying a .tmp file then use the .$$$ temport file extension instead.
  begin
   tofile := ChangeFileExt(tofile,'.$$$');
  end
  else
  begin
   tofile := ChangeFileExt(tofile,'.tmp'); // OK to use the standard .tmp file extension then.
  end;
 if fileexists(tofile) then // If a .tmp (or .$$$) version of "tofile" is present in the target folder then assume it's a partial copy of the file left over from a previous failed/interrupted run and kill it:
  begin
   deletefile(tofile);
   if ioresult = 0 then begin end;
  end;
 assignfile(f,fromfile);  reset(f,1);
 if ioresult <> 0 then
  begin
   closefile(f); if ioresult = 0 then begin end;
   ActivityLogMemo.Lines.Add('Error: Unable to read from "'+extractfilename(fromfile)+'" from "'+extractfilepath(fromfile)+'" check file access permissions.');
   inc(stats_numerrors);
  end
  else
  begin
   assignfile(f1,tofile);   rewrite(f1,1);
   if ioresult <> 0 then
    begin
     closefile(f); if ioresult = 0 then begin end;
     closefile(f1); if ioresult = 0 then begin end;
     ActivityLogMemo.Lines.Add('Error: Unable to write to "'+extractfilename(tofile)+'" from "'+extractfilepath(tofile)+'" check file access permissions.');
     inc(stats_numerrors);
    end
    else
    begin
     new(psave);
     try
      ct := 0; numr := 0; numw := 0;
      repeat
       blockread(f,psave^,1048576,numr);
       blockwrite(f1,psave^,numr,numw);
       sIncProgress(numw);
       if ct = 20 then
        begin
         application.processmessages;
         ct := 0;
        end;
       inc(ct);
      until (numr = 0) or (numr <> numw) or abort;
     finally
      dispose(psave);
     end;
     result := filesize(f) = filesize(f1);
     closefile(f);
     if ioresult = 0 then begin end;
     closefile(f1);
     if ioresult = 0 then begin end;
     if result then // OK, if it worked, then rename the tofile.tmp to tofile.<correct file extension>:
      begin
       propertofile := ChangeFileExt(tofile,origfileext);
       deletefile(propertofile); // In case the target file exists we need to delete it just in case.
       if ioresult = 0 then begin end;
       if NOT renamefile(tofile,propertofile) then
        begin
         result := false;
         ActivityLogMemo.Lines.Add('Error: Unable to rename "'+tofile+' to "'+propertofile+'.');
         inc(stats_numerrors);
        end;
       if ioresult = 0 then begin end;
      end
      else // Didn't work - kill the duff target file.
      begin
       ActivityLogMemo.Lines.Add('Error: Unable to copy "'+extractfilename(fromfile)+'" from "'+extractfilepath(fromfile)+'" check file access permissions.');
       inc(stats_numerrors);
       deletefile(tofile);
       if ioresult = 0 then begin end;
      end;
     if ioresult = 0 then begin end;
    end;
  end;
 {$I+}
end;

function fn_my_FileSetDate(filename : string; requiredfiledatetime : TDateTime) : boolean;
var
 newFileDateTime,differencedt : TDateTime;
 newFileSize : int64;
 FileSetDateResult : Longint;
 workedok : boolean;
 FileSetDatepass,FileSetDateMaxpass,sleep_time : int64;
begin
 sleep_time := preference_switch_FileSetDateSleepTime; // Msec... (1000 = 1 second).
 if sleep_time <= 0 then sleep_time := 500;
 FileSetDateMaxpass := preference_switch_FileSetDateMaxPasses;
 if FileSetDateMaxpass <= 0 then FileSetDateMaxpass := 1;
 result := false; workedok := false; FileSetDatepass := 1;
 while not workedok and (FileSetDatepass < FileSetDateMaxpass) do
  begin
   try
    if FileSetDatepass > 1 then
     begin
      ActivityLogMemo.Lines.Add('Problem setting date timestamnp on '+filename+' will wait for 1 second and try again.');
      sleep(sleep_time);
     end;
    FileSetDateResult := FileSetDate(filename,DateTimeToFileDate(requiredfiledatetime));
    if FileSetDateResult = 0 then
     begin
      // Check it:
      newFileDateTime := 0; newFileSize := 0;
      if GetFileDetails(filename,newFileDateTime,newFileSize) then
       begin
        if abs(newFileDateTime - requiredFileDateTime) > encodetime(0,1,0,0) then
         begin
          // Different by at least one minute.
          differencedt := newFileDateTime - requiredFileDateTime;
          if differencedt >= 0 then
           begin
            FileSetDateResult := FileSetDate(filename,DateTimeToFileDate(requiredfiledatetime-differencedt));
            if FileSetDateResult <> 0 then
             begin
              //showmessage('failed to set date for: '+filename+' FileSetDateResult='+inttostr(FileSetDateResult));
             end;
           end
           else
           begin
            FileSetDateResult := FileSetDate(filename,DateTimeToFileDate(requiredfiledatetime+differencedt));
            if FileSetDateResult <> 0 then
             begin
              //showmessage('failed to set date for: '+filename+' FileSetDateResult='+inttostr(FileSetDateResult));
             end;
           end;
          if GetFileDetails(filename,newFileDateTime,newFileSize) then
           begin
            if abs(newFileDateTime - requiredFileDateTime) < encodetime(0,1,0,0) then
             begin
              workedok := true;
              result := true; // OK, that worked.
             end;
           end;
         end
         else // < 1 minute out so OK.
         begin
          workedok := true;
          result := true;
         end;
       end
       else
       begin
        ActivityLogMemo.Lines.Add('Error: Failed inside "fn_my_FileSetDate". Possible network connection issue?');
        inc(stats_numerrors);
        abort := true;
       end;
     end
     else
     begin
      //showmessage('failed to set date for: '+filename+' FileSetDateResult='+inttostr(FileSetDateResult));
     end;
   except
    result := false;
   end;
   inc(FileSetDatepass);
  end;
end;

procedure add_to_filesinsourcealsointargetstringlist(targetfilename : string);
var
 x : integer;
begin
 if ok_to_use_filesinsourcealsointargetstringlist then
  begin
   if filesinsourcealsointargetstringlist_lastfilenameadded <> targetfilename then // Don't bother storing this targetfilename if we just aded it.
    begin
     inc(filesinsourcealsointargetstringlist_count);
     filesinsourcealsointargetstringlist.Add(targetfilename);
     x := (length(targetfilename) + 2);
     filesinsourcealsointargetstringlist_bytesadded := filesinsourcealsointargetstringlist_bytesadded + x;
     if filesinsourcealsointargetstringlist_count mod(1000) = 0 then
      begin
       // Every 1000th file check to see if we have gone over the "filesinsourcealsointargetstringlist_maxsize".
       if filesinsourcealsointargetstringlist_bytesadded > filesinsourcealsointargetstringlist_maxsize then
        begin
         // OK: Got too big so nuke it.
         filesinsourcealsointargetstringlist.clear;
         filesinsourcealsointargetstringlist_count := 0;
         ok_to_use_filesinsourcealsointargetstringlist := false;
        end;
      end;
    end;
   filesinsourcealsointargetstringlist_lastfilenameadded := targetfilename; // Note the last targetfilename we just added.
  end;
end;

procedure scanforfiles(scanmode,source_and_target_array_slot : integer; startpath : string; copymode : integer; deletefiles : boolean);
var
 mySearchRec : sysutils.TSearchRec;
 ReturnValue : integer;
 s : string;
 doit,oktosettimestamp,thistargetfileexists,skip : boolean;
 sourceFileDateTime,targetFileDateTime : TDateTime;
 sourceFileSize,targetFileSize : Int64;
begin
 {$I-}
 try
  ReturnValue:=FindFirst(startpath+'*',faAnyFile,mysearchrec);
  if ReturnValue <> 0 then
   begin
    ActivityLogMemo.Lines.Add('Error: Failed inside "scanforfiles". Possible network connection issue?');
    inc(stats_numerrors);
    abort := true;
   end;
  While (ReturnValue=0) and not abort do
   begin
    application.processmessages;
    // This is a directory, so add the folder name to "startpath" and then recursively call the "scanforfiles" routine to go and scan it i.e. the function calls itself.
    if ((mySearchRec.Attr and faDirectory)>0) and
       (mySearchRec.name<>'.') and
       (mySearchRec.name<>'..') and
       (pos('THUMBS.DB',uppercase(mySearchRec.name)) = 0) and
       (pos('INDEXERVOLUMEGUID',uppercase(mySearchRec.name)) = 0) then
    begin
     if scanmode = scanmode_deletefiles then
      begin
       targetfolderfoldersstringlist.add(delimitpath(startpath+mysearchrec.name));
      end;
     scanforfiles(scanmode,source_and_target_array_slot,delimitpath(startpath+mysearchrec.name),copymode,deletefiles);
    end
    else if (mySearchRec.Attr and faDirectory = 0) and
            (pos('THUMBS.DB',uppercase(mySearchRec.name)) = 0) and
            (pos('INDEXERVOLUMEGUID',uppercase(mySearchRec.name)) = 0) then
    begin
     application.processmessages;
     doit := false;
     oktosettimestamp := false;
     s := stringreplace(startpath+mysearchrec.name,sourcefolder,targetfolder,[rfreplaceall,rfignorecase]);

     if scanmode = scanmode_scanonly then // Scan only mode so increment count of files scanned.
      begin
       inc(stats_numfiles_scanned);
       stats_filesize_scanned := stats_filesize_scanned + mysearchrec.Size;
      end;

     if scanmode = scanmode_deletefiles then // Scanmode = "2" = delete files present in targetfolder that are not present in the sourcefolder. The "startpath" is the targetfolder.
      begin
       if deletefiles then
        begin
         s := stringreplace(startpath+mysearchrec.name,targetfolder,sourcefolder,[rfreplaceall,rfignorecase]);
         skip := false;
         if ok_to_use_filesinsourcealsointargetstringlist then
          begin
           if filesinsourcealsointargetstringlist.IndexOf(startpath+mysearchrec.name) <> -1 then
            begin
             // It's OK, this file "startpath+mysearchrec.name" in the target folder was seen in the copy/file checking process so we don't need to check to see if we can delete it.
             skip := true;
            end;
          end;
         if not skip then
          begin
           if not fileexists(s) then // Not present in Source folder?
            begin
             ActivityLogMemo.Lines.Add('File "'+mysearchrec.name+'" in the Target folder "'+targetfolder+'" does not exist in the Source folder "'+sourcefolder+'" so deleting it.');
             deletefile(startpath+mysearchrec.name);
             inc(stats_numfiles_deleted);
            end;
          end;
        end;
      end
      else if scanmode = scanmode_setfilestamps then // 3 = setfilestamps mode.
      begin
       sourceFileDateTime := 0; sourceFileSize := 0; targetFileDateTime := 0; targetFileSize := 0;
       if fileexists(s) then
        begin
         oktosettimestamp := false;
         try
          if GetFileDetails(startpath+mysearchrec.name,sourceFileDateTime,sourceFileSize) then
           begin
            oktosettimestamp := true;
           end
           else
           begin
            ActivityLogMemo.Lines.Add('Error: Failed inside "scanforfiles". Possible network connection issue?');
            inc(stats_numerrors);
            abort := true;
            doit := false;
           end;
         except
          oktosettimestamp := false
         end;
         if oktosettimestamp then doit := true;
         try
          if oktosettimestamp and GetFileDetails(s,targetFileDateTime,targetFileSize) then
           begin
            if abs(sourceFileDateTime - targetFileDateTime) < encodetime(0,1,0,0) then // < 1 minute differnet? If so, then don't bother updating the target file's date + time stamp.
             begin
              doit := false;
             end;
           end;
         except
          ActivityLogMemo.Lines.Add('Error: Failed inside "scanforfiles". Possible network connection issue?');
          inc(stats_numerrors);
          abort := true;
          doit := false;
         end;
        end;
      end
      else
      begin
       // OK, If "copymode" = copyifnotpresent (0) or copyifnotpresentorchanged (1) and the source file does not exist in the target folder then we DO want to copy it:
       oktosettimestamp := false;
       thistargetfileexists := fileexists(s);
       if thistargetfileexists then
        begin
         if scanmode = scanmode_copyfiles then // Only update the "filesinsourcealsointargetstringlist" when in the "Main "copy files" scan mode (saves a little time).
          begin
           add_to_filesinsourcealsointargetstringlist(s);
          end;
        end;
       if not thistargetfileexists then
        begin
         try
          doit := true;
          if GetFileDetails(startpath+mysearchrec.name,sourceFileDateTime,sourceFileSize) then
           begin
            oktosettimestamp := true;
           end
           else
           begin
            ActivityLogMemo.Lines.Add('Error: Failed inside "scanforfiles". Possible network connection issue?');
            inc(stats_numerrors);
            abort := true;
            doit := false;
           end;
         except
          doit := false;
         end;
        end
        else if copymode = copyifnotpresentorchanged then
        begin
         // Source file does not exist in the target folder but copymode = copyifnotpresentorchanged so if the file size of the source and target file is different then we DO want to (re)copy this file:
         try
          if GetFileDetails(startpath+mysearchrec.name,sourceFileDateTime,sourceFileSize) then
           begin
            oktosettimestamp := true;
            if GetFileDetails(s,targetFileDateTime,targetFileSize) then
             begin
              if sourceFileSize <> targetFileSize then
               begin
                doit := true;
                if scanmode = scanmode_scanonly then // Scan only...
                 begin
                  // We are going to delete this targetfile and replace it with a newer version so decrement the Number of bytes that will be copied for this "source_and_target_rec" detected during scanmode_scanonly:
                  source_and_target_array[source_and_target_array_slot].scan_filesize := source_and_target_array[source_and_target_array_slot].scan_filesize - targetFileSize;
                  // Note: We ARE going to (re)copy this file to target so don't decrement the overall total of bytes to copy "stats_filesize".
                 end;
               end
               else
               begin
                // Size is same but what about the timestamps?
                if abs(sourceFileDateTime - targetFileDateTime) > encodetime(0,1,0,0) then // > 1 minute differnet? (so as not to risk odd differences in timestamps between different file systems 1 minute should be "safe").
                 begin
                  doit := true;
                  if scanmode = scanmode_scanonly then // Scan only...
                   begin
                    // We are going to delete this targetfile and replace it with a newer version so decrement the Number of bytes that will be copied for this "source_and_target_rec" detected during scanmode_scanonly:
                    source_and_target_array[source_and_target_array_slot].scan_filesize := source_and_target_array[source_and_target_array_slot].scan_filesize - targetFileSize;
                    // Note: We ARE going to (re)copy this file to target so don't decrement the overall total of bytes to copy "stats_filesize".
                   end;
                 end;
               end;
             end;
           end
           else
           begin
            ActivityLogMemo.Lines.Add('Error: Failed inside "scanforfiles". Possible network connection issue?');
            inc(stats_numerrors);
            abort := true;
            doit := false;
           end;
         except
          ActivityLogMemo.Lines.Add('Error: Failed inside "scanforfiles". Possible network connection issue?');
          inc(stats_numerrors);
          abort := true;
          doit := false;
         end;
        end;
      end;
     if abort then doit := false;
     if scanmode <> scanmode_deletefiles then // 2 = Delete files mode so don't do any of this stuff:
      begin
       // Apparently delphi "assignfile" has a limit of 259 char limit so can't do those using "fn_sinkcopyfile".
       if doit then
        begin
         if (length(startpath+mysearchrec.name) > MaxPathLen) or (length(s) > MaxPathLen) then
          begin
           ActivityLogMemo.Lines.Add('Error: Source folder + filename is too long the max_path length on this OS is '+inttostr(MaxPathLen)+' bytes. Skipping "'+startpath+mysearchrec.name+'".');
           inc(stats_numerrors);
           doit := false;
          end;
        end;
       if doit then
        begin
         // Copy: startpath+mysearchrec.name to "s":
         if scanmode = scanmode_setfilestamps then // 3 = setfilestamps mode.
          begin
           try
            if fn_my_FileSetDate(s,sourcefiledatetime) then
             begin
              ActivityLogMemo.Lines.Add('Set file date+time for "'+mysearchrec.name+'" in "'+targetfolder+'".');
             end
             else
             begin
              ActivityLogMemo.Lines.Add('Error: Failed to set file date+time for "'+mysearchrec.name+'" in "'+targetfolder+'".');
              inc(stats_numerrors);
             end;
           except
            ActivityLogMemo.Lines.Add('Error: Exception: Failed to set file date+time for "'+mysearchrec.name+'" in "'+targetfolder+'".');
            inc(stats_numerrors);
            abort := true;
           end;
          end
          else if scanmode = scanmode_scanonly then // Scan only...
          begin
           pathlabel.caption := 'Scanning Folder: '+startpath;
           filenamelabel.caption := 'Scanning File: '+mysearchrec.name;
           application.processmessages;
           if fileexists(startpath+mysearchrec.name) then
            begin
             stats_filesize := stats_filesize + mysearchrec.Size;
             source_and_target_array[source_and_target_array_slot].scan_filesize := source_and_target_array[source_and_target_array_slot].scan_filesize + mysearchrec.Size; // Number of bytes that will be copied for this "source_and_target_rec" detected during scanmode_scanonly.
            end;
          end
          else if scanmode = scanmode_copyfiles then // Main "copy files" scan mode:
          begin
           if fileexists(startpath+mysearchrec.name) then
            begin
             pathlabel.caption := 'Coping From: '+startpath;
             filenamelabel.caption := 'Coping File: '+mysearchrec.name;
             application.processmessages;
             if fn_make_and_test_folder(extractfilepath(s)) then
              begin
               if fn_sinkcopyfile(startpath+mysearchrec.name,s) then
                begin
                 inc(stats_numfiles_copied);
                 add_to_filesinsourcealsointargetstringlist(s);
                 if oktosettimestamp then
                  begin
                   if fileexists(s) then
                    begin
                     ActivityLogMemo.Lines.Add('Copied "'+mysearchrec.name+'"');
                     // OK: Set the date time stamp on the "new" target file (s) to match the date time stamp on the source file:
                     try
                      if NOT fn_my_FileSetDate(s,sourcefiledatetime) then
                       begin
                        ActivityLogMemo.Lines.Add('Error: Failed to set file date+time for "'+s+'".');
                        inc(stats_numerrors);
                       end;
                     except
                      ActivityLogMemo.Lines.Add('Error: Exception: Failed to set file date+time for "'+s+'".');
                      inc(stats_numerrors);
                     end;
                    end;
                  end
                  else
                  begin
                   if fileexists(s) then
                    begin
                     ActivityLogMemo.Lines.Add('Copied "'+mysearchrec.name+'"');
                    end;
                  end;
                end;
              end
              else
              begin
               ActivityLogMemo.Lines.Add('Error: Failed to create/access Target folder "'+extractfilepath(s)+'".');
               inc(stats_numerrors);
              end;
            end;
          end;
        end;
      end;
    end;
    ReturnValue:=FindNext(mySearchRec);
   end;
  findclose(mysearchrec); // Release the memory claimed by using this instance of searchrec.
 except
  on e : exception do
   begin
    ActivityLogMemo.Lines.Add('Error: Failed inside "scanforfiles". Possible network connection issue?');
    inc(stats_numerrors);
    abort := true;
   end;
 end;
end;

procedure sync_folders(scanmode,source_and_target_array_slot : integer; sourcefolder : string; copymode : integer; deletefiles : boolean);
begin
 pathlabel.caption := 'Scanning: '+sourcefolder;
 filenamelabel.caption := '';
 scanforfiles(scanmode,source_and_target_array_slot,sourcefolder,copymode,deletefiles);
end;

function fn_disk_free_check(source_and_target_array_slot : integer) : boolean;
var
 targetfolder : string;
 bytestocopy,targetfreespacebytes,targetactualdisksize,targetfreespacebytesremaining,min_target_freediskspace_percent : int64;
begin
 result := true; // Assume OK.
 targetfolder := source_and_target_array[source_and_target_array_slot].targetfolder;
 try
  min_target_freediskspace_percent := preference_switch_min_freediskspace_percent; // Default is 5% minimum disk free space remaining on target drive(s) after file copy process.
  if min_target_freediskspace_percent < 0 then min_target_freediskspace_percent := 0;
  if min_target_freediskspace_percent > 100 then min_target_freediskspace_percent := 100;
  bytestocopy := source_and_target_array[source_and_target_array_slot].scan_filesize;
  if bytestocopy < 0 then bytestocopy := 0;
  if (targetfolder <> '') and (bytestocopy > 0) then
   begin
    if fn_make_and_test_folder(extractfilepath(targetfolder)) then
     begin
      if (fn_Osversion = 'Windows') or (fn_OSversion = 'Linux') then
       begin
        SetCurrentDir(targetfolder);
        targetfreespacebytes := Diskfree(0);
        targetactualdisksize := DiskSize(0);
        // OK, so how much targetfreespacebytes would be left after wed copied bytestocopy to it?
        targetfreespacebytesremaining := targetfreespacebytes - bytestocopy;
        if targetfreespacebytesremaining <= 0 then
         begin
          // Not enough space free on target drive/folder:
          ActivityLogMemo.Lines.Add('Error: Disk free space check on target drive/folder "'+targetfolder+'" reports '+HumanReadableNumbytes(targetfreespacebytes)+' of free space but we need to copy '+HumanReadableNumbytes(bytestocopy)+' to it so this copy operation can''t be run.');
          result := false;
         end
         else
         begin
          // OK, so that's enough phisical space on the target drive but would the resulting space remaining be less than the minimum allowed percentage free disk space that must remain after a copy operation?
          if targetactualdisksize > 0 then
           begin
            if targetfreespacebytesremaining < (targetactualdisksize/100)*min_target_freediskspace_percent then
             begin
              ActivityLogMemo.Lines.Add('Error: Disk free space check on target drive/folder "'+targetfolder+'" reports '+HumanReadableNumbytes(targetfreespacebytes)+' of free space but we need to copy '+HumanReadableNumbytes(bytestocopy)+' which would leave less than '+sr(min_target_freediskspace_percent,3,0)+'% space remaining.');
              ActivityLogMemo.Lines.Add('You would need to free up '+HumanReadableNumbytes(trunc((targetactualdisksize/100)*min_target_freediskspace_percent))+' of space on "'+targetfolder+'" to resolve this issue.');
              result := false;
             end
             else
             begin
              // All good.
              ActivityLogMemo.Lines.Add('Disk free space check on target drive/folder "'+targetfolder+'" reports '+HumanReadableNumbytes(targetfreespacebytes)+' of free space and we need to copy '+HumanReadableNumbytes(bytestocopy)+' to it so this copy operation should run OK.');
             end;
           end
           else
           begin
            ActivityLogMemo.Lines.Add('Error: Disk free space check on target drive/folder "'+targetfolder+'" was unable to determine the size of the target drive/folder.');
            result := false;
           end;
         end;
       end
       else
       begin
        ActivityLogMemo.Lines.Add('Note: The disk free space check can only run for Windows or Linux/Unix systems so no disk free space check as been run.');
       end;
     end
     else
     begin
      ActivityLogMemo.Lines.Add('Error: Disk free space check on target drive/folder "'+targetfolder+'" was unable to access the that drive/folder.');
      result := false;
     end;
   end;
 except
  ActivityLogMemo.Lines.Add('Error: Failed to run disk free space check for target folder "'+targetfolder+'". No files will be copied to this target folder.');
  result := false; // Failed...
 end;
end;

begin
 abort := false;
 targetfolderfoldersstringlist := TStringlist.create;
 filesinsourcealsointargetstringlist := TStringlist.create;
 statsstringlist := TStringList.create;
 filesinsourcealsointargetstringlist_count := 0;
 filesinsourcealsointargetstringlist_bytesadded := 0;
 ok_to_use_filesinsourcealsointargetstringlist := true;
 filesinsourcealsointargetstringlist_lastfilenameadded := '';
 ActivityLogMemo.Clear;
 progressbarbr.visible := false;
 LabelTimeElapsed.Caption := 'Time Elapsed: ......';
 LabelTimeRemaining.Caption := 'Time Remaining: ......';
 copyfilesstarttime := now; processstarttime := now; copyfilesendtime := now;
 try
  targetfolderfoldersstringlist.clear;
  filesinsourcealsointargetstringlist.clear;
  filesinsourcealsointargetstringlist.Sorted := true;
  statsstringlist.clear;
  stats_filesize := 0; stats_bytes_written := 0; stats_numfiles_scanned := 0; stats_numfiles_copied := 0; stats_filesize_scanned := 0; stats_numfiles_deleted := 0; stats_numerrors := 0;
  if source_and_target_array_count > 0 then
   begin
    if runmode = runmodecopyfiles then
     begin
      pass := scanmode_scanonly;
      while (pass <= scanmode_copyfiles) and not abort do
       begin
        if pass = scanmode_copyfiles then
         begin
          copyfilesstarttime := now; // Reset start time one we actually start the copy process.
          ProgressBarBR.Position := 0;
          try
           ProgressBarBR.Max := 1000;
          except
          end;
          progressbarbr.visible := true;
         end;
        ct := 0;
        while (ct < source_and_target_array_count) and not abort do
         begin
          sourcefolder := source_and_target_array[ct].sourcefolder;
          targetfolder := source_and_target_array[ct].targetfolder;
          copymode := source_and_target_array[ct].copymode;
          deletefiles := source_and_target_array[ct].deletefiles;
          if pass = scanmode_scanonly then
           begin
            ActivityLogMemo.Lines.Add('Scanning source folder "'+sourcefolder+'".');
            ActivityLogMemo.Lines.Add('Comparing with target folder "'+targetfolder+'".');
           end;
          if pass = scanmode_scanonly then
           begin
            source_and_target_array[ct].scan_filesize := 0; // Zero the scan_filesize (bytes) for this source_and_target_rec:
            sync_folders(scanmode_scanonly,ct,sourcefolder,copymode,deletefiles);
           end
           else if pass = scanmode_copyfiles then
           begin
            if preference_switch_allow_diskfree_checks then // Are we allowed to run disk free checks on the target drives?
             begin
              if fn_disk_free_check(ct) then
               begin
                sync_folders(scanmode_copyfiles,ct,sourcefolder,copymode,deletefiles);
               end;
             end
             else
             begin
              sync_folders(scanmode_copyfiles,ct,sourcefolder,copymode,deletefiles);
             end;
           end;
          inc(ct);
         end;
        inc(pass);
       end;
      copyfilesendtime := now; // Remember when copy files process finished.
      // OK, now got back through the source_and_target_array and if any of them have the "deletfiles" option enabled the do an extra pass (2) to delete any files that are present in
      // the target folder but are NOT present in the source folder.
      // NB: We can only delete files if the "preference_switch_allow_deletefiles" is enabled.
      ct := 0;
      while (ct < source_and_target_array_count) and not abort and preference_switch_allow_deletefiles do
       begin
        if source_and_target_array[ct].deletefiles then
         begin
          sourcefolder := source_and_target_array[ct].sourcefolder;
          targetfolder := source_and_target_array[ct].targetfolder;
          copymode := source_and_target_array[ct].copymode;
          deletefiles := source_and_target_array[ct].deletefiles;
          ActivityLogMemo.Lines.Add('Scanning source folder "'+sourcefolder+'".');
          ActivityLogMemo.Lines.Add('Comparing with target folder "'+targetfolder+'" to locate any files that need to be deleted.');
          targetfolderfoldersstringlist.clear;
          sync_folders(scanmode_deletefiles,ct,targetfolder,copymode,deletefiles); // Pass "2" = delete files.
          // NB: We can only delete redundant folders from the target folder if the "preference_switch_allow_deletefolders" is enabled.
          if (targetfolderfoldersstringlist.Count > 0) and preference_switch_allow_deletefolders then
           begin
            ct1 := 0;
            while (ct1 < targetfolderfoldersstringlist.count) and not abort do
             begin
              //ActivityLogMemo.Lines.Add('scanmode_deletefiles saw this folder in target: '+targetfolderfoldersstringlist[ct1]);
              s1 := stringreplace(targetfolderfoldersstringlist[ct1],targetfolder,sourcefolder,[rfreplaceall,rfignorecase]);
              //ActivityLogMemo.Lines.Add('So on source that would be: '+s1);
              if not DirectoryExists(s1) then
               begin
                if DeleteDirectory(targetfolderfoldersstringlist[ct1],false) then
                 begin
                  ActivityLogMemo.Lines.Add('This folder does not exist on the source so has been deleted from the target: '+targetfolderfoldersstringlist[ct1]);
                 end
                 else
                 begin
                  ActivityLogMemo.Lines.Add('Error: This folder does not exist on the source but could not be deleted from the target: '+targetfolderfoldersstringlist[ct1]);
                  inc(stats_numerrors);
                 end;
               end;
              inc(ct1);
             end;
           end;
         end;
        inc(ct);
       end;
     end
     else if runmode = runmodesetfilestamps then
     begin
      ct := 0;
      while (ct < source_and_target_array_count) and not abort do
       begin
        sourcefolder := source_and_target_array[ct].sourcefolder;
        targetfolder := source_and_target_array[ct].targetfolder;
        copymode := source_and_target_array[ct].copymode;
        deletefiles := source_and_target_array[ct].deletefiles;
        sync_folders(scanmode_setfilestamps,ct,sourcefolder,copymode,deletefiles); // Pass "3" = set filestamps on target folder files.
        inc(ct);
       end;
     end;
   end;

  statsstringlist.clear;
  statsstringlist.Add(' ');
  statsstringlist.Add('Stats:');
  statsstringlist.Add('Number of files scanned: '+inttostr(stats_numfiles_scanned));
  statsstringlist.Add('Total size of files scanned: '+HumanReadableNumbytes(stats_filesize_scanned));
  statsstringlist.Add('Number of files copied from Source to Target folders: '+inttostr(stats_numfiles_copied));
  statsstringlist.Add('Total size of files copied: '+HumanReadableNumbytes(stats_bytes_written));
  statsstringlist.Add('Number of files deleted: '+inttostr(stats_numfiles_deleted));
  statsstringlist.Add('Number of errors/warnings reported: '+inttostr(stats_numerrors));
  if copyfilesendtime > copyfilesstarttime then
   begin
    statsstringlist.Add('Total time taken for the copy files process: '+ FormatDateTime('hh:mm.ss',(copyfilesendtime - copyfilesstarttime)));
   end
   else
   begin
    statsstringlist.Add('Total time taken for the copy files process: '+ FormatDateTime('hh:mm.ss',0));
   end;
  statsstringlist.Add('Total overall time taken (for the scan, copy and delete files processes): '+ FormatDateTime('hh:mm.ss',(now - processstarttime)));

  //filesinsourcealsointargetstringlist.SaveToFile('C:\Users\Danny\Desktop\filesinsourcealsointargetstringlist.txt');

  if abort then
   begin
    pathlabel.caption := 'Process was stopped.';
    ActivityLogMemo.Lines.Add(' ');
    ActivityLogMemo.Lines.Add('Process was stopped.');
    if statsstringlist.count > 0 then
     begin
      ct := 0;
      while (ct < statsstringlist.count) do
       begin
        ActivityLogMemo.Lines.Add(statsstringlist[ct]);
        inc(ct);
       end;
     end;
   end
   else
   begin
    pathlabel.caption := 'Finished';
    ActivityLogMemo.Lines.Add(' ');
    ActivityLogMemo.Lines.Add('Finished.');
    if statsstringlist.count > 0 then
     begin
      ct := 0;
      while (ct < statsstringlist.count) do
       begin
        ActivityLogMemo.Lines.Add(statsstringlist[ct]);
        inc(ct);
       end;
     end;
   end;
  filenamelabel.caption := '';
 finally
  progressbarbr.visible := false;
  LabelTimeElapsed.Caption := 'Time Elapsed: ......';
  LabelTimeRemaining.Caption := 'Time Remaining: ......';
  targetfolderfoldersstringlist.clear;
  targetfolderfoldersstringlist.free;
  filesinsourcealsointargetstringlist.clear;
  filesinsourcealsointargetstringlist.free;
  statsstringlist.clear;
  statsstringlist.free;
  abort := false; // Ready for next run...
 end;
end;

procedure Tsinkmainform.SourceAndTargetFoldersStringGridClick(Sender: TObject);
begin
 sourcefolderedit.Text := SourceAndTargetFoldersStringGrid.cells[0,SourceAndTargetFoldersStringGrid.Row];
 targetfolderedit.Text := SourceAndTargetFoldersStringGrid.cells[1,SourceAndTargetFoldersStringGrid.Row];
 if SourceAndTargetFoldersStringGrid.cells[2,SourceAndTargetFoldersStringGrid.Row] <> '' then
  begin
   try
    copymodecombobox.ItemIndex := strtoint(SourceAndTargetFoldersStringGrid.cells[2,SourceAndTargetFoldersStringGrid.Row]);
   except
    copymodecombobox.ItemIndex := 0; // copyifnotpresent
   end;
  end
  else
  begin
   copymodecombobox.ItemIndex := 0; // copyifnotpresent
  end;
 if SourceAndTargetFoldersStringGrid.cells[3,SourceAndTargetFoldersStringGrid.Row] <> '' then
  begin
   deletefilescheckbox.Checked := SourceAndTargetFoldersStringGrid.cells[3,SourceAndTargetFoldersStringGrid.Row] = 'Y';
  end
  else
  begin
   deletefilescheckbox.Checked := false;
  end;
 SourceAndTargetFoldersStringGrid.Col := 0;
 FormResize(Sender);
end;

procedure Tsinkmainform.SourceFolderBrowseBitBtnClick(Sender: TObject);
var
 stemp : string;
begin
 sTemp := BrowseFolderDlg(sourcefolderedit.text);
 if sTemp <> '' then
  sourcefolderedit.text := sTemp;
 SourceAndTargetFoldersStringGrid.cells[0,SourceAndTargetFoldersStringGrid.Row] := sourcefolderedit.Text;
 if fn_SourceAndTargetFoldersStringGrid_has_changed then
  begin
   applychangesbitbtn.Enabled := true;
   discardchangesbitbtn.Enabled := true;
  end;
end;

procedure Tsinkmainform.SourceFolderEditChange(Sender: TObject);
begin
 SourceAndTargetFoldersStringGrid.cells[0,SourceAndTargetFoldersStringGrid.Row] := sourcefolderedit.Text;
 if fn_SourceAndTargetFoldersStringGrid_has_changed then
  begin
   applychangesbitbtn.Enabled := true;
   discardchangesbitbtn.Enabled := true;
  end;
end;


procedure Tsinkmainform.TargetFolderBrowseBitBtnClick(Sender: TObject);
var
 stemp : string;
begin
 sTemp := BrowseFolderDlg(targetfolderedit.text);
 if sTemp <> '' then
  targetfolderedit.text := sTemp;
 SourceAndTargetFoldersStringGrid.cells[1,SourceAndTargetFoldersStringGrid.Row] := targetfolderedit.Text;
 if fn_SourceAndTargetFoldersStringGrid_has_changed then
  begin
   applychangesbitbtn.Enabled := true;
   discardchangesbitbtn.Enabled := true;
  end;
end;

procedure Tsinkmainform.TargetFolderEditChange(Sender: TObject);
begin
 SourceAndTargetFoldersStringGrid.cells[1,SourceAndTargetFoldersStringGrid.Row] := targetfolderedit.Text;
 if fn_SourceAndTargetFoldersStringGrid_has_changed then
  begin
   applychangesbitbtn.Enabled := true;
   discardchangesbitbtn.Enabled := true;
  end;
end;

procedure Tsinkmainform.copymodeComboBoxChange(Sender: TObject);
begin
 try
  SourceAndTargetFoldersStringGrid.cells[2,SourceAndTargetFoldersStringGrid.Row] := inttostr(copymodecombobox.ItemIndex);
 except
  SourceAndTargetFoldersStringGrid.cells[2,SourceAndTargetFoldersStringGrid.Row] := '0'; // copyifnotpresent
 end;
 if fn_SourceAndTargetFoldersStringGrid_has_changed then
  begin
   applychangesbitbtn.Enabled := true;
   discardchangesbitbtn.Enabled := true;
  end;
end;

procedure Tsinkmainform.DeleteFilesCheckBoxClick(Sender: TObject);
begin
 if deletefilescheckbox.Checked then SourceAndTargetFoldersStringGrid.cells[3,SourceAndTargetFoldersStringGrid.Row] := 'Y' else SourceAndTargetFoldersStringGrid.cells[3,SourceAndTargetFoldersStringGrid.Row] := 'N';
 if fn_SourceAndTargetFoldersStringGrid_has_changed then
  begin
   applychangesbitbtn.Enabled := true;
   discardchangesbitbtn.Enabled := true;
  end;
end;

procedure Tsinkmainform.fill_in_SourceAndTargetFoldersStringGrid;
var
 ct : integer;
 sourcefolder,targetfolder : string;
 copymode : integer;
 deletefiles : boolean;
begin
 SourceAndTargetFoldersStringGrid.rowcount := 2;
 SourceAndTargetFoldersStringGrid.cells[0,0] := 'Source Folders';
 SourceAndTargetFoldersStringGrid.cells[1,0] := 'Target Folders';
 SourceAndTargetFoldersStringGrid.cells[2,0] := '';
 SourceAndTargetFoldersStringGrid.cells[3,0] := '';
 SourceAndTargetFoldersStringGrid.cells[0,1] := '';
 SourceAndTargetFoldersStringGrid.cells[1,1] := '';
 SourceAndTargetFoldersStringGrid.cells[2,1] := '';
 SourceAndTargetFoldersStringGrid.cells[3,1] := '';
 copymodecombobox.ItemIndex := 0; // copyifnotpresent
 deletefilescheckbox.Checked := false;
 if source_and_target_array_count > 0 then
  begin
   ct := 0;
   while ct < source_and_target_array_count do
    begin
     if ct > 0 then SourceAndTargetFoldersStringGrid.rowcount := SourceAndTargetFoldersStringGrid.rowcount + 1;
     sourcefolder := source_and_target_array[ct].sourcefolder;
     SourceAndTargetFoldersStringGrid.cells[0,ct+1] := sourcefolder;
     targetfolder := source_and_target_array[ct].targetfolder;
     SourceAndTargetFoldersStringGrid.cells[1,ct+1] := targetfolder;
     copymode := source_and_target_array[ct].copymode;
     SourceAndTargetFoldersStringGrid.cells[2,ct+1] := inttostr(copymode);
     deletefiles := source_and_target_array[ct].deletefiles;
     if deletefiles then SourceAndTargetFoldersStringGrid.cells[3,ct+1] := 'Y' else SourceAndTargetFoldersStringGrid.cells[3,ct+1] := 'N';
     inc(ct);
    end;
  end;
 SourceAndTargetFoldersStringGrid.Row := 1;
 SourceAndTargetFoldersStringGridClick(nil);
 applychangesbitbtn.Enabled := false;
 discardchangesbitbtn.Enabled := false;
end;

procedure Tsinkmainform.NewBitBtnClick(Sender: TObject);
var
 s,t : string;
begin
 s := SourceAndTargetFoldersStringGrid.cells[0,SourceAndTargetFoldersStringGrid.rowcount-1];
 t := SourceAndTargetFoldersStringGrid.cells[1,SourceAndTargetFoldersStringGrid.rowcount-1];
 if (s <> '') and (t <> '') then
  begin
   SourceAndTargetFoldersStringGrid.rowcount := SourceAndTargetFoldersStringGrid.rowcount + 1;
   SourceAndTargetFoldersStringGrid.Row := SourceAndTargetFoldersStringGrid.rowcount -1;
   SourceAndTargetFoldersStringGridClick(nil);
   applychangesbitbtn.Enabled := true;
   discardchangesbitbtn.Enabled := true;
  end;
end;

procedure Tsinkmainform.DeleteBitBtnClick(Sender: TObject);
var
 ct,maxrows : integer;
begin
 if SourceAndTargetFoldersStringGrid.row = SourceAndTargetFoldersStringGrid.rowcount -1 then
  begin
   // Last row.
   if SourceAndTargetFoldersStringGrid.Row = 1 then
    begin
     // last and only row...
     SourceAndTargetFoldersStringGrid.rowcount := 2;
     SourceAndTargetFoldersStringGrid.cells[0,1] := '';
     SourceAndTargetFoldersStringGrid.cells[1,1] := '';
     SourceAndTargetFoldersStringGrid.cells[2,1] := '';
     SourceAndTargetFoldersStringGrid.cells[3,1] := '';
     SourceAndTargetFoldersStringGrid.Row := 1;
     SourceAndTargetFoldersStringGridClick(nil);
     applychangesbitbtn.Enabled := true;
     discardchangesbitbtn.Enabled := true;
    end
    else
    begin
     // Just delete last row then.
     SourceAndTargetFoldersStringGrid.cells[0,SourceAndTargetFoldersStringGrid.rowcount -1] := '';
     SourceAndTargetFoldersStringGrid.cells[1,SourceAndTargetFoldersStringGrid.rowcount -1] := '';
     SourceAndTargetFoldersStringGrid.cells[2,SourceAndTargetFoldersStringGrid.rowcount -1] := '';
     SourceAndTargetFoldersStringGrid.cells[3,SourceAndTargetFoldersStringGrid.rowcount -1] := '';
     SourceAndTargetFoldersStringGrid.rowcount := SourceAndTargetFoldersStringGrid.rowcount -1;
     SourceAndTargetFoldersStringGrid.Row := SourceAndTargetFoldersStringGrid.rowcount-1;
     SourceAndTargetFoldersStringGridClick(nil);
     applychangesbitbtn.Enabled := true;
     discardchangesbitbtn.Enabled := true;
    end;
  end
  else
  begin
   // > 1 row avaiable..e.g. I am on row 2 of 4, so shuffle 3 to 2, 4 to 3 and delete last row.
   ct := SourceAndTargetFoldersStringGrid.row;
   maxrows := SourceAndTargetFoldersStringGrid.rowcount-1;
   while ct < maxrows do
    begin
     SourceAndTargetFoldersStringGrid.cells[0,ct] := SourceAndTargetFoldersStringGrid.cells[0,ct+1];
     SourceAndTargetFoldersStringGrid.cells[1,ct] := SourceAndTargetFoldersStringGrid.cells[1,ct+1];
     SourceAndTargetFoldersStringGrid.cells[2,ct] := SourceAndTargetFoldersStringGrid.cells[2,ct+1];
     SourceAndTargetFoldersStringGrid.cells[3,ct] := SourceAndTargetFoldersStringGrid.cells[3,ct+1];
     ct := ct + 1;
    end;
   // Now delete last row.
   SourceAndTargetFoldersStringGrid.cells[0,SourceAndTargetFoldersStringGrid.rowcount -1] := '';
   SourceAndTargetFoldersStringGrid.cells[1,SourceAndTargetFoldersStringGrid.rowcount -1] := '';
   SourceAndTargetFoldersStringGrid.cells[2,SourceAndTargetFoldersStringGrid.rowcount -1] := '';
   SourceAndTargetFoldersStringGrid.cells[3,SourceAndTargetFoldersStringGrid.rowcount -1] := '';
   SourceAndTargetFoldersStringGrid.rowcount := SourceAndTargetFoldersStringGrid.rowcount -1;
   SourceAndTargetFoldersStringGrid.Row := SourceAndTargetFoldersStringGrid.rowcount-1;
   SourceAndTargetFoldersStringGridClick(nil);
   applychangesbitbtn.Enabled := true;
   discardchangesbitbtn.Enabled := true;
  end;
end;

procedure Tsinkmainform.DiscardChangesBitBtnClick(Sender: TObject);
begin
 load_ini_settings;
 fill_in_SourceAndTargetFoldersStringGrid;
end;

procedure Tsinkmainform.load_ini_settings;
var
 s,sourcefolder,targetfolder : string;
 x,copymode : integer;
 finished,deletefiles : boolean;
 f : textfile;
begin
 {$I-}
 source_and_target_array_count := 0; setlength(source_and_target_array,source_and_target_array_count);
 assignfile(f,usersettingsdir + 'sinkini.txt');
 reset(f);
 if ioresult = 0 then
  begin
   while not eof(f) do
    begin
     readln(f,s);
     // New type sink.ini:
     if pos('<PREFERENCE_SWITCH_ALLOW_DELETEFILES>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       preference_switch_allow_deletefiles := s = 'Y';
      end;
     if pos('<PREFERENCE_SWITCH_ALLOW_DELETEFOLDERS>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       preference_switch_allow_deletefolders := s = 'Y';
      end;
     if pos('<PREFERENCE_SWITCH_ALLOW_DISKFREE_CHECKS>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       preference_switch_allow_diskfree_checks := s = 'Y';
      end;
     if pos('<PREFERENCE_SWITCH_MIN_FREEDISKSPACE_PERCENT>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       preference_switch_min_freediskspace_percent := strtoint(s);
      end;
     if pos('<PREFERENCE_SWITCH_FILESETDATEMAXPASSES>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       preference_switch_FileSetDateMaxPasses := strtoint(s);
      end;
     if pos('<PREFERENCE_SWITCH_FILESETDATESLEEPTIME>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       preference_switch_FileSetDateSleepTime := strtoint(s);
      end;
     if pos('<START_DEFINITION>',uppercase(s)) > 0 then
      begin
       sourcefolder := ''; targetfolder := ''; copymode := copyifnotpresent; deletefiles := false;
       finished := false;
       while not finished and not eof(f) do
        begin
         readln(f,s);
         s := strip(stripfront(s));
         if copy(s,1,1) <> '#' then // Ignore comments.
          begin
           if pos('SOURCE_FOLDER=',uppercase(s)) > 0 then
            begin
             x := pos('=',uppercase(s));
             s := copy(s,x+1,length(s));
             s := strip(stripfront(s));
             sourcefolder := s;
            end
            else if pos('TARGET_FOLDER=',uppercase(s)) > 0 then
            begin
             x := pos('=',uppercase(s));
             s := copy(s,x+1,length(s));
             s := strip(stripfront(s));
             targetfolder := s;
            end
            else if pos('COPY_MODE=',uppercase(s)) > 0 then
            begin
             x := pos('=',uppercase(s));
             s := copy(s,x+1,length(s));
             s := strip(stripfront(s));
             try
              copymode := strtoint(s);
             except
              copymode := copyifnotpresent;
             end;
            end
            else if pos('DELETE_FILES=',uppercase(s)) > 0 then
            begin
             x := pos('=',uppercase(s));
             s := copy(s,x+1,length(s));
             s := strip(stripfront(s));
             deletefiles := uppercase(copy(s,1,1)) = 'Y';
            end
            else if pos('<END_DEFINITION>',uppercase(s)) > 0 then
            begin
             finished := true;
             if (sourcefolder <> '') and (targetfolder <> '') then
              begin
               inc(source_and_target_array_count); setlength(source_and_target_array,source_and_target_array_count);
               source_and_target_array[source_and_target_array_count-1].sourcefolder := delimitpath(sourcefolder);
               source_and_target_array[source_and_target_array_count-1].targetfolder := delimitpath(targetfolder);
               source_and_target_array[source_and_target_array_count-1].copymode := copymode;
               source_and_target_array[source_and_target_array_count-1].deletefiles := deletefiles;
              end;
            end;
          end;
        end;
      end;
    end;
   end;
 closefile(f); if ioresult = 0 then;
end;

procedure Tsinkmainform.save_ini_settings;
var
 sourcefolder,targetfolder : string;
 f : textfile;
 ct : integer;
begin
 {$I-}
 assignfile(f,usersettingsdir + 'sinkini.txt');
 rewrite(f);
 if ioresult = 0 then
  begin
   if source_and_target_array_count > 0 then
    begin
     writeln(f,'# Sink.exe configuration file. If you are no longer using the Sink.exe file syncing/backup applidation then you can safely delete this file.');

     writeln(f,'# Are we allowed to delete files from target folders (preference_switch_allow_deletefiles)?');
     if preference_switch_allow_deletefiles then
      writeln(f,'<preference_switch_allow_deletefiles>=Y')
     else
     writeln(f,'<preference_switch_allow_deletefiles>=N');

     writeln(f,'# Are we allowed to delete folders from target drives/folders (preference_switch_allow_deletefolders)?');
     if preference_switch_allow_deletefolders then
      writeln(f,'<preference_switch_allow_deletefolders>=Y')
     else
     writeln(f,'<preference_switch_allow_deletefolders>=N');

     writeln(f,'# Are we allowed to run disk free checks on the target drives (preference_switch_allow_diskfree_checks)?');
     if preference_switch_allow_diskfree_checks then
      writeln(f,'<preference_switch_allow_diskfree_checks>=Y')
     else
     writeln(f,'<preference_switch_allow_diskfree_checks>=N');

     writeln(f,'# Minimum disk free space remaining on target drive(s) before copy process is allowed to run (preference_switch_min_freediskspace_percent).');
     writeln(f,'<preference_switch_min_freediskspace_percent>='+inttostr(trunc(preference_switch_min_freediskspace_percent)));

     writeln(f,'# No. of retries allowed in the set file date+time stamp process (preference_switch_FileSetDateMaxPasses).');
     writeln(f,'<preference_switch_FileSetDateMaxPasses>='+inttostr(trunc(preference_switch_FileSetDateMaxPasses)));

     writeln(f,'# Sleep time in milliseconds (1000 = 1 second) between retries in the set file date+time stamp process (preference_switch_FileSetDateSleepTime).');
     writeln(f,'<preference_switch_FileSetDateSleepTime>='+inttostr(trunc(preference_switch_FileSetDateSleepTime)));

     writeln(f,'# Start of source and target folder jobs definitions:');
     ct := 0;
     while ct < source_and_target_array_count do
      begin
       sourcefolder := source_and_target_array[ct].sourcefolder;
       targetfolder := source_and_target_array[ct].targetfolder;
       if (sourcefolder <> '') and (targetfolder <> '') then
        begin
         writeln(f,'<Start_Definition>');
         writeln(f,' Source_Folder='+sourcefolder);
         writeln(f,' Target_Folder='+targetfolder);
         writeln(f,' Copy_Mode='+inttostr(source_and_target_array[ct].copymode));
         if source_and_target_array[ct].deletefiles then
          begin
           writeln(f,' Delete_Files=Y');
          end
          else
          begin
           writeln(f,' Delete_Files=N');
          end;
         writeln(f,'<End_Definition>');
        end;
       inc(ct);
      end;
    end;
  end;
 closefile(f); if ioresult = 0 then;
end;

procedure Tsinkmainform.ApplyChangesBitBtnClick(Sender: TObject);
var
 ct,ct1 : integer;
 sourcefolder,targetfolder,thistargetfolder,testtargetfolder,mes : string;
 copymode : integer;
 deletefiles,bad : boolean;
begin
 // Transfer grid to array and then save to ini.
 source_and_target_array_count := 0; setlength(source_and_target_array,source_and_target_array_count);
 ct := 1;
 while ct < SourceAndTargetFoldersStringGrid.rowcount do
  begin
   sourcefolder := SourceAndTargetFoldersStringGrid.cells[0,ct];
   targetfolder := SourceAndTargetFoldersStringGrid.cells[1,ct];
   if SourceAndTargetFoldersStringGrid.cells[2,ct] = '' then
    begin
     copymode := copyifnotpresent;
    end
    else
    begin
     try
      copymode := strtoint(SourceAndTargetFoldersStringGrid.cells[2,ct]);
     except
      copymode := copyifnotpresent;
     end;
    end;
   deletefiles := SourceAndTargetFoldersStringGrid.cells[3,ct] = 'Y';
   if (sourcefolder <> '') and (targetfolder <> '') then
    begin
     inc(source_and_target_array_count); setlength(source_and_target_array,source_and_target_array_count);
     source_and_target_array[source_and_target_array_count-1].sourcefolder := delimitpath(sourcefolder);
     source_and_target_array[source_and_target_array_count-1].targetfolder := delimitpath(targetfolder);
     source_and_target_array[source_and_target_array_count-1].copymode := copymode;
     source_and_target_array[source_and_target_array_count-1].deletefiles := deletefiles;
    end;
   inc(ct);
  end;
 // Sanity check the targetfolders to make sure thay are unique and safe to use:
 bad := false;
 if source_and_target_array_count > 1 then // OK it only one defined.
  begin
   ct := 0;
   while (ct < source_and_target_array_count) and not bad do
    begin
     ct1 := 0;
     while (ct1 < source_and_target_array_count) and not bad do
      begin
       if ct <> ct1 then // Don't do yourself.
        begin
         thistargetfolder := source_and_target_array[ct].targetfolder;
         testtargetfolder := source_and_target_array[ct1].targetfolder;
         // OK, two different folders e.g. "d:\backup\" and "d:\backup\files\" - no good.
         if uppercase(thistargetfolder) = uppercase(testtargetfolder) then
          begin
           bad := true; // Exact match - no good.
          end
          else
          begin
           if length(thistargetfolder) > length(testtargetfolder) then // E.g. "d:\backup\files\" (this) and "d:\backup\" (test) no good:
            begin
             if copy(uppercase(testtargetfolder),1,length(testtargetfolder)) = copy(uppercase(thistargetfolder),1,length(testtargetfolder)) then
              begin
               bad := true;
              end;
            end;
          end;
         if bad then
          begin
           mes := 'Error: The Specified Target folders:'+#13+#13+
                  '"'+thistargetfolder+'"'+#13+
                  'and:'+#13+
                  '"'+testtargetfolder+'"'+#13+#13+
                  'Are in conflict.'+#13+#13+
                  'All specified Target folders must be unique and not be a sub-folder of another Target folder.'+#13+#13+
                  'Please correct this and re-apply your changes.';
           if messagedlg(mes,mterror,[mbok],0) = mrok then begin end;
          end;
        end;
       inc(ct1);
      end;
     inc(ct);
    end;
  end;
 if not bad then
  begin
   save_ini_settings;
  end;
 fill_in_SourceAndTargetFoldersStringGrid;
end;

function Tsinkmainform.fn_SourceAndTargetFoldersStringGrid_has_changed : boolean;
var
 ct : integer;
 sourcefolder,targetfolder : string;
 copymode : integer;
 deletefiles : boolean;
begin
 result := false;
 if source_and_target_array_count = SourceAndTargetFoldersStringGrid.rowcount-1 then
  begin
   ct := 1;
   while (ct < SourceAndTargetFoldersStringGrid.rowcount) and not result do
    begin
     sourcefolder := SourceAndTargetFoldersStringGrid.cells[0,ct];
     targetfolder := SourceAndTargetFoldersStringGrid.cells[1,ct];
     if SourceAndTargetFoldersStringGrid.cells[2,ct] = '' then
      begin
       copymode := copyifnotpresent;
      end
      else
      begin
       try
        copymode := strtoint(SourceAndTargetFoldersStringGrid.cells[2,ct]);
       except
        copymode := copyifnotpresent;
       end;
      end;
     deletefiles := SourceAndTargetFoldersStringGrid.cells[3,ct] = 'Y';
     if (source_and_target_array[ct-1].sourcefolder <> sourcefolder) or
        (source_and_target_array[ct-1].targetfolder <> targetfolder) or
        (source_and_target_array[ct-1].copymode <> copymode) or
        (source_and_target_array[ct-1].deletefiles <> deletefiles) then
      begin
       result := true; // Difference detected.
      end;
     inc(ct);
    end;
  end
  else
  begin
   result := true; // Must have changed...
  end;
end;

procedure Tsinkmainform.FormResize(Sender: TObject);
var
 maxwidth,newcolwidth : integer;
begin
 SourceAndTargetFoldersStringGrid.Col := 0;
 maxwidth := sinkmainform.width - 30;
 if maxwidth < 0 then maxwidth := 1;

 newcolwidth := maxwidth div 2;
 if newcolwidth < 0 then newcolwidth := 1;
 SourceAndTargetFoldersStringGrid.ColWidths[0] := newcolwidth;

 newcolwidth := (sinkmainform.width - SourceAndTargetFoldersStringGrid.ColWidths[0]) - 10;
 if newcolwidth < 0 then newcolwidth := 1;
 SourceAndTargetFoldersStringGrid.ColWidths[1] := newcolwidth;
end;

procedure Tsinkmainform.FormShow(Sender: TObject);

function fn_determine_usersettingsdir : boolean;
begin
 result := false;
 sinkmainform.usersettingsdir := GetAppConfigDir(false);
 if sinkmainform.usersettingsdir = '' then
  begin
   sinkmainform.usersettingsdir := GetAppConfigDir(true);
   if sinkmainform.usersettingsdir = '' then
    begin
     sinkmainform.usersettingsdir := GetUserDir;
    end;
  end;
 if sinkmainform.usersettingsdir <> '' then
  begin
   try
    result := true;
    sinkmainform.usersettingsdir := DelimitPath(sinkmainform.usersettingsdir);
    CreateDir(sinkmainform.usersettingsdir);
   except
   end;
  end
  else
  begin
   showmessage('Error: Unable to determine Application Configuration folder.');
  end;
end;

begin
 SourceAndTargetFoldersStringGrid.ColWidths[2] := 0;
 SourceAndTargetFoldersStringGrid.ColWidths[3] := 0;
 PageControl1.ActivePageIndex := 0;
 pathlabel.caption := ''; filenamelabel.caption := ''; progressbarbr.visible := false; ActivityLogMemo.Clear; stopbutton.visible := false; startbutton.Visible := true;
 ActivityLogMemo.Lines.Add('Sink v1.2 Compiled 7-11-2025. Waiting to start.');
 filesinsourcealsointargetstringlist_maxsize := (1024 * 1024) * 100; // Allow 100Mb max for "filesinsourcealsointargetstringlist".
 LabelTimeElapsed.Caption := 'Time Elapsed: ......';
 LabelTimeRemaining.Caption := 'Time Remaining: ......';

 // Set default preference switch values:
 preference_switch_allow_deletefiles := true; // Are we allowed to delete files from target folders?
 preference_switch_allow_deletefolders := true; // Are we alowed to delete folders from target folders?
 preference_switch_allow_diskfree_checks := true; // Are we allowed to run disk free checks on the target drives?
 preference_switch_min_freediskspace_percent := 5; // Default to 5% minimum disk free space remaining on target drive(s) after file copy process.
 preference_switch_FileSetDateMaxPasses := 10; // Default to 10 retries in the filesetdate function.
 preference_switch_FileSetDateSleepTime := 1000; // Default to 1 second sleep time between retries in the filesetdate function.

 if not fn_determine_usersettingsdir then
  begin
   application.Terminate;
  end
  else
  begin
   load_ini_settings;
   fill_in_SourceAndTargetFoldersStringGrid;
  end;
end;

procedure Tsinkmainform.StartButtonClick(Sender: TObject);
begin
 // OK: Go:
 startbutton.Visible := false; stopbutton.visible := true; configurationtabsheet.Enabled := false; documentationtabsheet.Enabled := false; setfilestampsbutton.Enabled := false;
 abort := false;
 try
  run_process(runmodecopyfiles);
 finally
  stopbutton.visible := false; startbutton.Visible := true; configurationtabsheet.Enabled := true; documentationtabsheet.Enabled := true; setfilestampsbutton.Enabled := true;
 end;
end;

procedure Tsinkmainform.StopbuttonClick(Sender: TObject);
begin
 abort := true;
end;

procedure Tsinkmainform.setfilestampsbuttonClick(Sender: TObject);
var
 mes : string;
begin
 // OK: Go:
 mes := 'This option will search through all of the files in all of your defined Source folders and look for matching filenames in the corresponding Target folders.'+#13+
        'For any files that are found in a Target folder that have the same filenames as those in the corresponding Source folder it will set the date+time file'+#13+
        'stamp on the Target file to match the date+time file stamp of the Source file.'+#13+
        ''+#13+
        'This ensures that the copy process will see the same date+time file stamps on both the Source and Target files and will therefore not force a re-copy'+#13+
        'of the Target files based on non matching date+time file stamps if the relevant Source and Target folder definition uses the'+#13+
        '"Copy files from the Source folder that are not present in the Target folder OR have been changed in the Source folder" Copy Mode.'+#13+
        ''+#13+
        'Note the "Copy files from the Source folder that are not present in the Target folder" Copy Mode'+#13+
        'doesn''t look at date+time file stamps so you don''t need to run this process if you only use that Copy Mode.'+#13+
        ''+#13+
        'Syncing the Target folder date+time stamps should help to avoid the unnecessary re-copying of files that already exist in the Target folder just because of'+#13+
        'mismatched date+time file stamps and is especially relevant if you have (say) a large number of video files in a Target folder which you don''t want to re-copy'+#13+
        'on the initial Sink.exe copy process.'+#13+
        ''+#13+
        'The Sink.exe copy process will set the Target date+time file stamps to match the Source date+time file stamps after successfully copying files from'+#13+
        'Source to Target so hence this "Sync Date+Time File Stamps" process only needs to be run once or if you edit your Source and Target folder definitions.'+#13+
        ''+#13+
        'Click "OK" to proceed or "Cancel" to quit.';
 if Dialogs.MessageDlg(mes,mtwarning,[mbok,mbcancel],0) = mrok then
  begin
   startbutton.Visible := false; stopbutton.visible := true; configurationtabsheet.Enabled := false; documentationtabsheet.Enabled := false; setfilestampsbutton.Enabled := false;
   try
    run_process(runmodesetfilestamps);
   finally
    stopbutton.visible := false; startbutton.Visible := true; configurationtabsheet.Enabled := true; documentationtabsheet.Enabled := true; setfilestampsbutton.Enabled := true;
   end;
  end;
end;

end.
