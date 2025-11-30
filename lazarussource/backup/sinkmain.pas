unit sinkmain;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ImgList, Grids, Buttons, Spin, Menus,
  LazFileUtils, FileUtil, DateTimePicker,DateUtils,sinkemail;

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
   job_failed : boolean;
  end;

  { Tsinkmainform }

  Tsinkmainform = class(TForm)
    AllowDeletefilesCheckBox: TCheckBox;
    AllowDeleteFoldersCheckBox: TCheckBox;
    AllowDiskFreeChecksCheckBox: TCheckBox;
    ViewDocumentationInYourTextEditorBitBtn: TBitBtn;
    EmailRecipientAddressEdit: TEdit;
    EmailAllowSinktoSendEmailNotificationsCheckBox: TCheckBox;
    EmailSendTestEmailBitBtn: TBitBtn;
    EmailSenderAddressEdit: TEdit;
    EmailAttachLogfileForErrorRunsCheckBox: TCheckBox;
    EmailAttachLogfileForSuccessfulRunsCheckBox: TCheckBox;
    EmailHostServerEdit: TEdit;
    EmailPasswordEdit: TEdit;
    EmailPortSpinEdit: TSpinEdit;
    EmailTestRecipientAddressEdit: TEdit;
    EmailSendIfErrorDaysOfTheWeekCheckGroup: TCheckGroup;
    EmailSendIfSuccessfulDaysOfTheWeekCheckGroup: TCheckGroup;
    EmailSubjectForErrorRunsEdit: TEdit;
    EmailSubjectForSuccessfulRunsEdit: TEdit;
    EmailPanel: TPanel;
    EmailTestMessageTextEdit: TEdit;
    EmailTestSubjectLineEdit: TEdit;
    EmailUserNameEdit: TEdit;
    EmailUseSSLCheckBox: TCheckBox;
    EmailUseTLSCheckBox: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    EmailTestEmailResultsMemo: TMemo;
    NavPanel: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    ResumeScheduledJobsbutton: TBitBtn;
    PreferencesSchedulerRunTime1DateTimePicker: TDateTimePicker;
    PreferencesSchedulerRunTime2DateTimePicker: TDateTimePicker;
    PreferencesSchedulerRunTime3DateTimePicker: TDateTimePicker;
    PreferencesSchedulerRunTime4DateTimePicker: TDateTimePicker;
    PreferencesSchedulerRunTime5DateTimePicker: TDateTimePicker;
    PreferencesSchedulerRunTime6DateTimePicker: TDateTimePicker;
    PreferencesSchedulerRunTime7DateTimePicker: TDateTimePicker;
    PreferencesSchedulerRunTime8DateTimePicker: TDateTimePicker;
    PreferencesSchedulerRunTimesGroupBox: TGroupBox;
    Label7: TLabel;
    PreferencesSchedulerRunJobsAfterSinkStartupCheckBox: TCheckBox;
    PreferencesSchedulerDaysOfTheWeekCheckGroup: TCheckGroup;
    PreferencesSchedulerStartMinimizedIfUsingShedulerCheckBox: TCheckBox;
    PreferencesSchedulerUseSchedulerCheckBox: TCheckBox;
    deletelogfilesolderthandaysSpinEdit: TSpinEdit;
    FileSetDateMaxPassesSpinEdit: TSpinEdit;
    FileSetDateSleepTimeSpinEdit: TSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    MinFreeDiskSpacePercentSpinEdit: TSpinEdit;
    OpenDialog1: TOpenDialog;
    PreferencesSchedulerPanel: TPanel;
    PreferencesPageControl: TPageControl;
    PreferencesPanel: TPanel;
    SaveDialog1: TSaveDialog;
    PreferencesGeneralSettingsTabSheet: TTabSheet;
    PreferencesSchedulerTabSheet: TTabSheet;
    PreferencesSchedulerDelayMinutesForStartupRunSpinEdit: TSpinEdit;
    SchedulerTimer: TTimer;
    CancelScheduledJobsbutton: TBitBtn;
    EmailTabSheet: TTabSheet;
    ToolsPanel: TPanel;
    PreferencesApplyChangesBitBtn: TBitBtn;
    PreferencesDiscardChangesBitBtn: TBitBtn;
    PageControl1: TPageControl;
    DocumentationTabSheet: TTabSheet;
    Memo1: TMemo;
    HomeTabSheet: TTabSheet;
    ConfigurationTabSheet: TTabSheet;
    ImageList1: TImageList;
    Panel4: TPanel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SourceAndTargetFoldersStringGrid: TStringGrid;
    Panel3: TPanel;
    NewBitBtn: TBitBtn;
    DeleteBitBtn: TBitBtn;
    SourceFolderEdit: TEdit;
    PreferencesTabSheet: TTabSheet;
    ToolsTabSheet: TTabSheet;
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
    StatusLabel: TLabel;
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
    TreeView1: TTreeView;
    TreeView2: TTreeView;
    procedure AllowDeletefilesCheckBoxChange(Sender: TObject);
    procedure CancelScheduledJobsbuttonClick(Sender: TObject);
    procedure ConfigurationTabSheetEnter(Sender: TObject);
    procedure ConfigurationTabSheetExit(Sender: TObject);
    procedure EmailSendTestEmailBitBtnClick(Sender: TObject);
    procedure PreferencesApplyChangesBitBtnClick(Sender: TObject);
    procedure PreferencesDiscardChangesBitBtnClick(Sender: TObject);
    procedure PreferencesSchedulerDaysOfTheWeekCheckGroupItemClick(
     Sender: TObject; Index: integer);
    procedure PreferencesTabSheetExit(Sender: TObject);
    procedure ResumeScheduledJobsbuttonClick(Sender: TObject);
    procedure SchedulerTimerTimer(Sender: TObject);
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
    procedure TreeView1DblClick(Sender: TObject);
    //procedure TreeView1KeyDown(Sender: TObject; var Key: Word;
    // Shift: TShiftState);
    procedure TreeView1KeyDown(Sender: TObject; var Key: Word);
    procedure TreeView2Click(Sender: TObject);
    procedure ViewDocumentationInYourTextEditorBitBtnClick(Sender: TObject);
  private
    { Private declarations }
    factive : boolean;
    preference_switch_allow_deletefiles : boolean;
    preference_switch_allow_deletefolders : boolean;
    preference_switch_allow_diskfree_checks : boolean;
    preference_switch_min_freediskspace_percent : int64;
    preference_switch_FileSetDateMaxPasses : int64;
    preference_switch_FileSetDateSleepTime : int64;
    preference_switch_delete_log_files_older_than_days : int64;
    PreferencesSchedulerUseScheduler : boolean;
    PreferencesSchedulerStartMinimizedIfUsingSheduler : boolean;
    PreferencesSchedulerRunJobsAfterSinkStartup : boolean;
    PreferencesSchedulerDelayMinutesForStartupRun : Int64;
    PreferencesSchedulerDaysOfTheWeek : string; // PreferencesSchedulerDaysOfTheWeekCheckGroup.Checked[0..6] e.g. "YNNYNYN".
    PreferencesSchedulerRunTime1 : TDateTime;
    PreferencesSchedulerRunTime2 : TDateTime;
    PreferencesSchedulerRunTime3 : TDateTime;
    PreferencesSchedulerRunTime4 : TDateTime;
    PreferencesSchedulerRunTime5 : TDateTime;
    PreferencesSchedulerRunTime6 : TDateTime;
    PreferencesSchedulerRunTime7 : TDateTime;
    PreferencesSchedulerRunTime8 : TDateTime;
    EmailAllowSinktoSendEmailNotifications : boolean;
    EmailHostServer : string;
    EmailUserName : string;
    EmailPassword : string;
    EmailPort : Int64;
    EmailUseSSL : boolean;
    EmailUseTLS : boolean;
    EmailSenderAddress : string;
    EmailSubjectForSuccessfulRuns : string;
    EmailSubjectForErrorRuns : string;
    EmailAttachLogfileForSuccessfulRuns : boolean;
    EmailAttachLogfileForErrorRuns : boolean;
    EmailSendIfSuccessfulDaysOfTheWeek : string;
    EmailSendIfErrorDaysOfTheWeek : string;
    EmailTestSubjectLine : string;
    EmailTestMessageText : string;
    EmailTestRecipientAddress : string;
    EmailRecipientAddress : string;
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
    status_app_startup_datetime : TDateTime;
    email_last_success_email_sent : TDateTime;
    status_next_sheduled_run_datetime : TDateTime;
    status_done_app_startup_run : boolean;
  public
    { Public declarations }
    procedure enable_tab_controls;
    procedure disable_tab_controls;
    procedure set_sink_run_status;
    procedure set_default_preference_switch_values; // Set default preference switch values:
    procedure setup_tools_options; // Set up the "Tools" options:
    procedure load_ini_settings;
    procedure save_ini_settings;
    procedure Save_ActivityLogMemo_to_Log_File(var logfilename : string);
    procedure purge_old_Log_Files;
    procedure fill_in_SourceAndTargetFoldersStringGrid;
    procedure set_preferences_controls;
    procedure transfer_preferences_controls_to_preferences;
    function fn_SourceAndTargetFoldersStringGrid_has_changed : boolean;
    procedure run_process(runmode : integer);
    procedure sIncProgress(numw : int64);
    function fn_email_settings_ok : string;
  end;

var
  sinkmainform: Tsinkmainform;
  mynode,mynode1,mynode2,mynode3 : TTreenode;
  mynode4,mynode5 : TTreenode;
  mynode6,mynode7 : TTreenode;

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

function Tsinkmainform.fn_email_settings_ok : string;
begin
 result := ''; // Return blank if all OK.
 if (strip(stripfront(EmailHostServer)) = '') or
    (strip(stripfront(EmailUserName)) = '') or
    (strip(stripfront(EmailPassword)) = '') or
    (EmailPort <=1) or
    (strip(stripfront(EmailSenderAddress)) = '') or
    (strip(stripfront(EmailRecipientAddress)) = '') then
  begin
   result := 'Unable to send emails. Please ensure that all of the Email Notification settings have been filled in (Email Host Server, Email User Name, Email Password, Email Port > 1, Email Sender Address and Email Recipient(s) Address).';
  end;
end;

procedure Tsinkmainform.enable_tab_controls;
begin
 configurationtabsheet.Enabled := true; documentationtabsheet.Enabled := true; preferencestabsheet.Enabled := true; toolstabsheet.Enabled := true;
end;

procedure Tsinkmainform.disable_tab_controls;
begin
 configurationtabsheet.Enabled := false; documentationtabsheet.Enabled := TRUE; preferencestabsheet.Enabled := false; toolstabsheet.Enabled := false;
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
 sourcefolder,targetfolder,s1,attachmentstr,resultstr,logfilename,subjectstr : string;
 statsstringlist,emailmessagestringlist : TStringList;
 copymode : integer;
 deletefiles : boolean;
 pass,ct,ct1,num_jobs_failed : integer;
 today_day_of_week : integer;

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
 err : boolean;
 thisFileDateTime : TDateTime;
 thisFileSize : int64;
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
   // That didn't work, so try OS "copyfile" instead:
   closefile(f); if ioresult = 0 then begin end;
   err := false;
   if copyfile(fromfile,tofile,[cffOverWriteFile],err) then
    begin
     thisFileDateTime := 0; thisFileSize := 0;
     if GetFileDetails(tofile,thisFileDateTime,thisFileSize) then
      begin
       sIncProgress(thisFileSize);
      end;
     propertofile := ChangeFileExt(tofile,origfileext);
     deletefile(propertofile); // In case the target file exists we need to delete it just in case.
     if ioresult = 0 then begin end;
     if NOT renamefile(tofile,propertofile) then
      begin
       result := false;
       ActivityLogMemo.Lines.Add('Error: Unable to rename "'+tofile+' to "'+propertofile+'.');
       inc(stats_numerrors);
      end
      else
      begin
       result := true; // OK, it worked using OS "copyfile"...
      end;
     if ioresult = 0 then begin end;
     //ActivityLogMemo.Lines.Add('Used OS file copy to copy "'+extractfilename(fromfile)+'" from "'+extractfilepath(fromfile)+'" to "'+extractfilepath(tofile)+'".');
    end
    else // No go...
    begin
     ActivityLogMemo.Lines.Add('Error: Unable to read from "'+extractfilename(fromfile)+'" from "'+extractfilepath(fromfile)+'" check file access permissions.');
     inc(stats_numerrors);
    end;
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

function fn_my_FileSetDate(source_and_target_array_slot : integer; filename : string; requiredfiledatetime : TDateTime) : boolean;
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
        source_and_target_array[source_and_target_array_slot].job_failed := true;
       end;
     end
     else
     begin
      //showmessage('failed to set date for: '+filename+' FileSetDateResult='+inttostr(FileSetDateResult));
     end;
   except
    result := false;
    source_and_target_array[source_and_target_array_slot].job_failed := true;
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
    source_and_target_array[source_and_target_array_slot].job_failed := true;
   end;
  While (ReturnValue=0) and not abort and NOT source_and_target_array[source_and_target_array_slot].job_failed do
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
            source_and_target_array[source_and_target_array_slot].job_failed := true;
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
          source_and_target_array[source_and_target_array_slot].job_failed := true;
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
            source_and_target_array[source_and_target_array_slot].job_failed := true;
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
            source_and_target_array[source_and_target_array_slot].job_failed := true;
            doit := false;
           end;
         except
          ActivityLogMemo.Lines.Add('Error: Failed inside "scanforfiles". Possible network connection issue?');
          inc(stats_numerrors);
          source_and_target_array[source_and_target_array_slot].job_failed := true;
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
            if fn_my_FileSetDate(source_and_target_array_slot,s,sourcefiledatetime) then
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
            source_and_target_array[source_and_target_array_slot].job_failed := true;
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
                      if NOT fn_my_FileSetDate(source_and_target_array_slot,s,sourcefiledatetime) then
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
               source_and_target_array[source_and_target_array_slot].job_failed := true;
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
    source_and_target_array[source_and_target_array_slot].job_failed := true;
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
              ActivityLogMemo.Lines.Add('You would need to free up '+HumanReadableNumbytes((trunc((targetactualdisksize/100)*min_target_freediskspace_percent) - trunc(targetfreespacebytes)) + trunc(bytestocopy))+' of space on "'+targetfolder+'" to resolve this issue.');
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
 emailmessagestringlist := TStringList.create;
 filesinsourcealsointargetstringlist_count := 0;
 filesinsourcealsointargetstringlist_bytesadded := 0;
 ok_to_use_filesinsourcealsointargetstringlist := true;
 filesinsourcealsointargetstringlist_lastfilenameadded := '';

 purge_old_Log_Files; // Kill any old log files.

 ActivityLogMemo.Clear;
 ActivityLogMemo.Lines.Add(' ');
 ActivityLogMemo.Lines.Add('Started jobs running '+datetimetostr(now));
 ActivityLogMemo.Lines.Add(' ');
 progressbarbr.visible := false;
 LabelTimeElapsed.Caption := 'Time Elapsed: ......';
 LabelTimeRemaining.Caption := 'Time Remaining: ......';
 copyfilesstarttime := now; processstarttime := now; copyfilesendtime := now;
 num_jobs_failed := 0; stats_numerrors := 0;
 try
  targetfolderfoldersstringlist.clear;
  filesinsourcealsointargetstringlist.clear;
  filesinsourcealsointargetstringlist.Sorted := true;
  statsstringlist.clear;
  stats_filesize := 0; stats_bytes_written := 0; stats_numfiles_scanned := 0; stats_numfiles_copied := 0; stats_filesize_scanned := 0; stats_numfiles_deleted := 0;
  // Mark all jobs (source_and_target_array records) as "job failed = false".
  if source_and_target_array_count > 0 then
   begin
    ct := 0;
    while ct < source_and_target_array_count do
     begin
      source_and_target_array[ct].job_failed := false;
      inc(ct);
     end;
   end;
  // OK, start working through the jobs in source_and_target_array:
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
            if NOT fn_make_and_test_folder(extractfilepath(targetfolder)) then
             begin
              source_and_target_array[ct].job_failed := true; // Can't access the target folder so we can't continue with this job.
              ActivityLogMemo.Lines.Add('Error: Unabled to access target folder "'+targetfolder+'" so unable to run this job.');
             end;
           end;
          if NOT source_and_target_array[ct].job_failed then
           begin
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
           end;
          inc(ct); // On to the next job.
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
        if NOT source_and_target_array[ct].job_failed then // DO NOT RUN "DELETE FILES" FOR JOBS THAT FAILED.
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
        if NOT fn_make_and_test_folder(extractfilepath(targetfolder)) then
         begin
          source_and_target_array[ct].job_failed := true; // Can't access the target folder so we can't continue with this job.
          ActivityLogMemo.Lines.Add('Error: Unabled to access target folder "'+targetfolder+'" so unable to set file stamps for this job.');
         end;
        if NOT source_and_target_array[ct].job_failed then // Can't access the target folder so we can't continue with this job.
         begin
          sync_folders(scanmode_setfilestamps,ct,sourcefolder,copymode,deletefiles); // Pass "3" = set filestamps on target folder files.
         end;
        inc(ct);
       end;
     end;
   end;

  statsstringlist.clear;
  statsstringlist.Add(' ');
  statsstringlist.Add('Stats:');
  statsstringlist.Add('Total number of jobs run: '+inttostr(source_and_target_array_count));
  ct := 0;
  if source_and_target_array_count > 0 then
   begin
    while ct < source_and_target_array_count do
     begin
      if source_and_target_array[ct].job_failed then inc(num_jobs_failed);
      inc(ct);
     end;
   end;
  statsstringlist.Add('Number of jobs that failed: '+inttostr(num_jobs_failed));
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
  filenamelabel.caption := '';  logfilename := '';
  Save_ActivityLogMemo_to_Log_File(logfilename);
  // OK: Do we need to send any emails?
  if EmailAllowSinktoSendEmailNotifications then // Are we allowed to send Sink email notifications?
   begin
    if (num_jobs_failed > 0) or (stats_numerrors > 0) then // Errors occured.
     begin
      today_day_of_week := DayOfTheWeek(now); // DayOfTheWeek is the ISO-conformal function where the week begins with Monday: 1 = Monday, 7 = Sunday
      if copy(EmailSendIfErrorDaysOfTheWeek,today_day_of_week,1) = 'Y' then // OK to send on today's day of the week?
       begin
        emailmessagestringlist.clear;
        emailmessagestringlist.add('Errors were reported during the last Sink run on this machine. Statistics follow.');
        if EmailAttachLogfileForErrorRuns then emailmessagestringlist.add('Today''s Sink Log File has also been attached for reference.');
        if statsstringlist.count > 0 then
         begin
          ct := 0;
          while (ct < statsstringlist.count) do
           begin
            emailmessagestringlist.add(statsstringlist[ct]);
            inc(ct);
           end;
         end;
        if EmailAttachLogfileForErrorRuns and fileexists(logfilename) then attachmentstr := logfilename else attachmentstr := '';
        subjectstr := EmailSubjectForErrorRuns; if strip(stripfront(subjectstr)) = '' then subjectstr := 'ERRORS: Sink file and folder backup/sync application ran with errors reported.'; // Just in case they blanked the erorrs run subject text.
        try
         if fn_email_settings_ok = '' then // "fn_email_settings_ok" returns blank string if all key email settings have been populated.
          begin
           resultstr := send_email(EmailHostServer,
                                   EmailUserName,
                                   EmailPassword,
                                   inttostr(EmailPort),
                                   EmailUseSSL,
                                   EmailUseTLS,
                                   EmailSenderAddress,
                                   EmailRecipientAddress,
                                   subjectstr,
                                   emailmessagestringlist,
                                   attachmentstr); // No attachement path+filename required for test email.
          end
          else resultstr := fn_email_settings_ok;
         resultstr := 'Attempted to send Sink Notification Email. Result: '+resultstr;
        except
         resultstr := 'Failed to send error notification email.';
        end;
        ActivityLogMemo.Lines.Add(resultstr);
       end;
     end
     else // Ran successfully.
     begin
      today_day_of_week := DayOfTheWeek(now); // DayOfTheWeek is the ISO-conformal function where the week begins with Monday: 1 = Monday, 7 = Sunday
      if copy(EmailSendIfSuccessfulDaysOfTheWeek,today_day_of_week,1) = 'Y' then // OK to send on today's day of the week?
       begin
        if trunc(email_last_success_email_sent) <> trunc(now) then // Try to limit to 1 success email per day so if we have already sent one today then do nothing.
         begin
          emailmessagestringlist.clear;
          emailmessagestringlist.add('The last Sink run on this machine was Successful. Statistics follow.');
          if EmailAttachLogfileForSuccessfulRuns then emailmessagestringlist.add('Today''s Sink Log File has also been attached for reference.');
          if statsstringlist.count > 0 then
           begin
            ct := 0;
            while (ct < statsstringlist.count) do
             begin
              emailmessagestringlist.add(statsstringlist[ct]);
              inc(ct);
             end;
           end;
          if EmailAttachLogfileForSuccessfulRuns and fileexists(logfilename) then attachmentstr := logfilename else attachmentstr := '';
          subjectstr := EmailSubjectForSuccessfulRuns; if strip(stripfront(subjectstr)) = '' then subjectstr := 'Sink file and folder backup/sync application ran successfully.'; // Just in case they blanked the success run subject text.
          try
           email_last_success_email_sent := now;
           if fn_email_settings_ok = '' then // "fn_email_settings_ok" returns blank string if all key email settings have been populated.
            begin
             resultstr := send_email(EmailHostServer,
                                     EmailUserName,
                                     EmailPassword,
                                     inttostr(EmailPort),
                                     EmailUseSSL,
                                     EmailUseTLS,
                                     EmailSenderAddress,
                                     EmailRecipientAddress,
                                     subjectstr,
                                     emailmessagestringlist,
                                     attachmentstr); // No attachement path+filename required for test email.
            end
            else resultstr := fn_email_settings_ok;
           resultstr := 'Attempted to send Sink Notification Email. Result: '+resultstr;
          except
           resultstr := 'Failed to send error notification email.';
          end;
          ActivityLogMemo.Lines.Add(resultstr);
         end;
       end;
     end;
   end;
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
  emailmessagestringlist.clear;
  emailmessagestringlist.free;
  abort := false; // Ready for next run...
  set_sink_run_status; // Resent the jobs schedule timer.
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
 //set_sink_run_status;
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
     if pos('<PREFERENCE_SWITCH_DELETE_LOG_FILES_OLDER_THAN_DAYS>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       preference_switch_delete_log_files_older_than_days := strtoint(s);
      end;
     if pos('<PREFERENCESSCHEDULERUSESCHEDULER>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerUseScheduler := s = 'Y';
      end;
     if pos('<PREFERENCESSCHEDULERSTARTMINIMIZEDIFUSINGSHEDULER>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerStartMinimizedIfUsingSheduler := s = 'Y';
      end;
     if pos('<PREFERENCESSCHEDULERRUNJOBSAFTERSINKSTARTUP>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerRunJobsAfterSinkStartup := s = 'Y';
      end;
     if pos('<PREFERENCESSCHEDULERDELAYMINUTESFORSTARTUPRUN>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerDelayMinutesForStartupRun := strtoint(s);
      end;
     if pos('<PREFERENCESSCHEDULERDAYSOFTHEWEEK>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerDaysOfTheWeek := s;
      end;
     if pos('<PREFERENCESSCHEDULERRUNTIME1>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerRunTime1 := strtotime(s);
      end;
     if pos('<PREFERENCESSCHEDULERRUNTIME2>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerRunTime2 := strtotime(s);
      end;
     if pos('<PREFERENCESSCHEDULERRUNTIME3>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerRunTime3 := strtotime(s);
      end;
     if pos('<PREFERENCESSCHEDULERRUNTIME4>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerRunTime4 := strtotime(s);
      end;
     if pos('<PREFERENCESSCHEDULERRUNTIME5>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerRunTime5 := strtotime(s);
      end;
     if pos('<PREFERENCESSCHEDULERRUNTIME6>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerRunTime6 := strtotime(s);
      end;
     if pos('<PREFERENCESSCHEDULERRUNTIME7>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerRunTime7 := strtotime(s);
      end;
     if pos('<PREFERENCESSCHEDULERRUNTIME8>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       PreferencesSchedulerRunTime8 := strtotime(s);
      end;

     if pos('<EMAILALLOWSINKTOSENDEMAILNOTIFICATIONS>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       EmailAllowSinktoSendEmailNotifications := s = 'Y';
      end;
     if pos('<EMAILHOSTSERVER>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(s));
       EmailHostServer := s;
      end;
     if pos('<EMAILUSERNAME>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(s));
       EmailUserName := s;
      end;
     if pos('<EMAILPASSWORD>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(s));
       EmailPassword := s;
      end;
     if pos('<EMAILPORT>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       EmailPort := strtoint(s);
      end;
     if pos('<EMAILUSESSL>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       EmailUseSSL := s = 'Y';
      end;
     if pos('<EMAILUSETLS>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       EmailUseTLS := s = 'Y';
      end;
     if pos('<EMAILSENDERADDRESS>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(s));
       EmailSenderAddress := s;
      end;
     if pos('<EMAILSUBJECTFORSUCCESSFULRUNS>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(s));
       EmailSubjectForSuccessfulRuns := s;
      end;
     if pos('<EMAILSUBJECTFORERRORRUNS>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(s));
       EmailSubjectForErrorRuns := s;
      end;
     if pos('<EMAILATTACHLOGFILEFORSUCCESSFULRUNS>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       EmailAttachLogfileForSuccessfulRuns := s = 'Y';
      end;
     if pos('<EMAILATTACHLOGFILEFORERRORRUNS>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       EmailAttachLogfileForErrorRuns := s = 'Y';
      end;
     if pos('<EMAILSENDIFSUCCESSFULDAYSOFTHEWEEK>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       EmailSendIfSuccessfulDaysOfTheWeek := s;
      end;
     if pos('<EMAILSENDIFERRORDAYSOFTHEWEEK>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(uppercase(s)));
       EmailSendIfErrorDaysOfTheWeek := s;
      end;
     if pos('<EMAILTESTSUBJECTLINE>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(s));
       EmailTestSubjectLine := s;
      end;
     if pos('<EMAILTESTMESSAGETEXT>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(s));
       EmailTestMessageText := s;
      end;
     if pos('<EMAILTESTRECIPIENTADDRESS>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(s));
       EmailTestRecipientAddress := s;
      end;
     if pos('<EMAILRECIPIENTADDRESS>',uppercase(s)) > 0 then
      begin
       x := pos('=',uppercase(s));
       s := copy(s,x+1,length(s));
       s := strip(stripfront(s));
       EmailRecipientAddress := s;
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

procedure Tsinkmainform.purge_old_Log_Files;
var
 mysearchrec : TSearchRec;
 ReturnValue : integer;
 failed : boolean;
 thisfiledatetime : TDateTime;
 oldestalloweddate : TDateTime;
begin
 failed := false;
 if preference_switch_delete_log_files_older_than_days <= 0 then
  begin
   oldestalloweddate := now - 1;
  end
  else
  begin
   oldestalloweddate := now - preference_switch_delete_log_files_older_than_days;
  end;
 ReturnValue:=FindFirst(usersettingsdir+'sinklogfile*.txt',faAnyFile,mysearchrec);
 While (ReturnValue=0) and not failed do
  begin
   if (mySearchRec.Attr and faDirectory = 0) then
    begin
     thisfiledatetime := mysearchrec.TimeStamp;
     if thisfiledatetime < oldestalloweddate then
      begin
       if deletefile(usersettingsdir+mysearchrec.name) then
        begin
        end
        else failed := true;
      end;
    end;
   ReturnValue:=FindNext(mySearchRec);
  end;
 findclose(mysearchrec); // Release the memory claimed by using this instance of searchrec.
end;

procedure Tsinkmainform.Save_ActivityLogMemo_to_Log_File(var logfilename : string);
var
 todaystr,s : string;
 y,m,d : word;
 f,f1 : textfile;
 failed : boolean;
begin
 {$I-}
 // Do we have a log file for today?
 decodedate(now,y,m,d);
 todaystr := inttostr(y)+'-'+inttostr(m)+'-'+inttostr(d);
 logfilename := usersettingsdir+'sinklogfile_'+todaystr+'.txt';
 if fileexists(usersettingsdir+'sinklogfile_'+todaystr+'.txt') then
  begin
   failed := false;
   ActivityLogMemo.Lines.SaveToFile(usersettingsdir+'sinklogfile_temp.txt');
   if fileexists(usersettingsdir+'sinklogfile_temp.txt') then
    begin
     assignfile(f,usersettingsdir+'sinklogfile_'+todaystr+'.txt');
     if ioresult = 0 then
      begin
       append(f);
       if ioresult = 0 then
        begin
         assignfile(f1,usersettingsdir+'sinklogfile_temp.txt');
         reset(f1);
         if ioresult = 0 then
          begin
           while not eof(f1) and not failed do
            begin
             readln(f1,s); if ioresult <> 0 then failed := true;
             writeln(f,s); if ioresult <> 0 then failed := true;
            end;
           closefile(f); if ioresult <> 0 then failed := true;
           closefile(f1); if ioresult <> 0 then failed := true;
           if deletefile(usersettingsdir+'sinklogfile_temp.txt') then begin end;
           if ioresult <> 0 then failed := true;
          end
          else failed := true;
        end
        else failed := true;
      end
      else failed := true;
    end;
   if failed then
    begin
     // OK? delete todays file and replace it:
     if deletefile(usersettingsdir+'sinklogfile_'+todaystr+'.txt') then
      begin
       ActivityLogMemo.Lines.SaveToFile(usersettingsdir+'sinklogfile_'+todaystr+'.txt');
      end;
    end;
  end
  else
  begin
   // No, so create a new one with the contents of ActivityLogMemo:
   ActivityLogMemo.Lines.SaveToFile(usersettingsdir+'sinklogfile_'+todaystr+'.txt');
  end;
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

     writeln(f,'# Delete Sink log files older than x days (preference_switch_delete_log_files_older_than_days).');
     writeln(f,'<preference_switch_delete_log_files_older_than_days>='+inttostr(trunc(preference_switch_delete_log_files_older_than_days)));

     writeln(f,'# Start of Scheduler settings:');

     if PreferencesSchedulerUseScheduler then
      writeln(f,'<PreferencesSchedulerUseScheduler>=Y')
     else
      writeln(f,'<PreferencesSchedulerUseScheduler>=N');

     if PreferencesSchedulerStartMinimizedIfUsingSheduler then
      writeln(f,'<PreferencesSchedulerStartMinimizedIfUsingSheduler>=Y')
     else
     writeln(f,'<PreferencesSchedulerStartMinimizedIfUsingSheduler>=N');

     if PreferencesSchedulerRunJobsAfterSinkStartup then
      writeln(f,'<PreferencesSchedulerRunJobsAfterSinkStartup>=Y')
     else
      writeln(f,'<PreferencesSchedulerRunJobsAfterSinkStartup>=N');

     writeln(f,'<PreferencesSchedulerDelayMinutesForStartupRun>='+inttostr(PreferencesSchedulerDelayMinutesForStartupRun));

     writeln(f,'<PreferencesSchedulerDaysOfTheWeek>='+PreferencesSchedulerDaysOfTheWeek);

     writeln(f,'<PreferencesSchedulerRunTime1>='+timetostr(PreferencesSchedulerRunTime1));
     writeln(f,'<PreferencesSchedulerRunTime2>='+timetostr(PreferencesSchedulerRunTime2));
     writeln(f,'<PreferencesSchedulerRunTime3>='+timetostr(PreferencesSchedulerRunTime3));
     writeln(f,'<PreferencesSchedulerRunTime4>='+timetostr(PreferencesSchedulerRunTime4));
     writeln(f,'<PreferencesSchedulerRunTime5>='+timetostr(PreferencesSchedulerRunTime5));
     writeln(f,'<PreferencesSchedulerRunTime6>='+timetostr(PreferencesSchedulerRunTime6));
     writeln(f,'<PreferencesSchedulerRunTime7>='+timetostr(PreferencesSchedulerRunTime7));
     writeln(f,'<PreferencesSchedulerRunTime8>='+timetostr(PreferencesSchedulerRunTime8));

     writeln(f,'# Start of Email Notifications settings:');
     if EmailAllowSinktoSendEmailNotifications then
      writeln(f,'<EmailAllowSinktoSendEmailNotifications>=Y')
     else
      writeln(f,'<EmailAllowSinktoSendEmailNotifications>=N');
     writeln(f,'<EmailHostServer>='+EmailHostServer);
     writeln(f,'<EmailUserName>='+EmailUserName);
     writeln(f,'<EmailPassword>='+EmailPassword);
     writeln(f,'<EmailPort>='+inttostr(trunc(EmailPort)));
     if EmailUseSSL then
      writeln(f,'<EmailUseSSL>=Y')
     else
      writeln(f,'<EmailUseSSL>=N');
     if EmailUseTLS then
      writeln(f,'<EmailUseTLS>=Y')
     else
      writeln(f,'<EmailUseTLS>=N');
     writeln(f,'<EmailSenderAddress>='+EmailSenderAddress);
     writeln(f,'<EmailRecipientAddress>='+EmailRecipientAddress);
     writeln(f,'<EmailSubjectForSuccessfulRuns>='+EmailSubjectForSuccessfulRuns);
     writeln(f,'<EmailSubjectForErrorRuns>='+EmailSubjectForErrorRuns);
     if EmailAttachLogfileForSuccessfulRuns then
      writeln(f,'<EmailAttachLogfileForSuccessfulRuns>=Y')
     else
     writeln(f,'<EmailAttachLogfileForSuccessfulRuns>=N');
     if EmailAttachLogfileForErrorRuns then
      writeln(f,'<EmailAttachLogfileForErrorRuns>=Y')
     else
     writeln(f,'<EmailAttachLogfileForErrorRuns>=N');
     writeln(f,'<EmailSendIfSuccessfulDaysOfTheWeek>='+EmailSendIfSuccessfulDaysOfTheWeek);
     writeln(f,'<EmailSendIfErrorDaysOfTheWeek>='+EmailSendIfErrorDaysOfTheWeek);
     writeln(f,'<EmailTestSubjectLine>='+EmailTestSubjectLine);
     writeln(f,'<EmailTestMessageText>='+EmailTestMessageText);
     writeln(f,'<EmailTestRecipientAddress>='+EmailTestRecipientAddress);

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


procedure Tsinkmainform.set_preferences_controls;
var
 ct : integer;
begin
 AllowDeleteFilesCheckbox.Checked := preference_switch_allow_deletefiles;
 AllowDeleteFoldersCheckbox.Checked := preference_switch_allow_deletefolders;
 AllowDiskFreeChecksCheckbox.Checked := preference_switch_allow_diskfree_checks;
 MinFreeDiskSpacePercentSpinEdit.Value := preference_switch_min_freediskspace_percent;
 FileSetDateMaxPassesSpinEdit.Value := preference_switch_FileSetDateMaxPasses;
 FileSetDateSleepTimeSpinEdit.Value := preference_switch_FileSetDateSleepTime;
 deletelogfilesolderthandaysSpinEdit.Value := preference_switch_delete_log_files_older_than_days;

 PreferencesSchedulerUseSchedulerCheckBox.Checked := PreferencesSchedulerUseScheduler;
 PreferencesSchedulerStartMinimizedIfUsingShedulerCheckBox.Checked := PreferencesSchedulerStartMinimizedIfUsingSheduler;
 PreferencesSchedulerRunJobsAfterSinkStartupCheckBox.Checked := PreferencesSchedulerRunJobsAfterSinkStartup;
 PreferencesSchedulerDelayMinutesForStartupRunSpinEdit.Value := PreferencesSchedulerDelayMinutesForStartupRun;
 ct := 0; while ct <= 6 do begin PreferencesSchedulerDaysOfTheWeekCheckGroup.Checked[ct] := false; inc(ct); end;
 if PreferencesSchedulerDaysOfTheWeek <> '' then
  begin
   ct := 1;
   while ct <= length(PreferencesSchedulerDaysOfTheWeek) do
    begin
     if PreferencesSchedulerDaysOfTheWeek[ct] = 'Y' then PreferencesSchedulerDaysOfTheWeekCheckGroup.Checked[ct-1] := true;
     inc(ct);
    end;
  end;
 PreferencesSchedulerRunTime1DateTimePicker.DateTime := PreferencesSchedulerRunTime1;
 PreferencesSchedulerRunTime2DateTimePicker.DateTime := PreferencesSchedulerRunTime2;
 PreferencesSchedulerRunTime3DateTimePicker.DateTime := PreferencesSchedulerRunTime3;
 PreferencesSchedulerRunTime4DateTimePicker.DateTime := PreferencesSchedulerRunTime4;
 PreferencesSchedulerRunTime5DateTimePicker.DateTime := PreferencesSchedulerRunTime5;
 PreferencesSchedulerRunTime6DateTimePicker.DateTime := PreferencesSchedulerRunTime6;
 PreferencesSchedulerRunTime7DateTimePicker.DateTime := PreferencesSchedulerRunTime7;
 PreferencesSchedulerRunTime8DateTimePicker.DateTime := PreferencesSchedulerRunTime8;

 EmailAllowSinktoSendEmailNotificationsCheckBox.checked := EmailAllowSinktoSendEmailNotifications;
 EmailHostServerEdit.Text := EmailHostServer;
 EmailUserNameEdit.Text := EmailUserName;
 EmailPasswordEdit.Text := EmailPassword;
 EmailPortSpinEdit.value := EmailPort;
 EmailUseSSLCheckBox.checked := EmailUseSSL;
 EmailUseTLSCheckBox.checked := EmailUseTLS;
 EmailSenderAddressEdit.text := EmailSenderAddress;
 EmailRecipientAddressEdit.text := EmailRecipientAddress;
 EmailSubjectForSuccessfulRunsEdit.text := EmailSubjectForSuccessfulRuns;
 EmailSubjectForErrorRunsEdit.text := EmailSubjectForErrorRuns;
 EmailAttachLogfileForSuccessfulRunsCheckBox.checked := EmailAttachLogfileForSuccessfulRuns;
 EmailAttachLogfileForErrorRunsCheckBox.checked := EmailAttachLogfileForErrorRuns;
 ct := 0; while ct <= 6 do begin EmailSendIfSuccessfulDaysOfTheWeekCheckGroup.Checked[ct] := false; inc(ct); end;
 if EmailSendIfSuccessfulDaysOfTheWeek <> '' then
  begin
   ct := 1;
   while ct <= length(EmailSendIfSuccessfulDaysOfTheWeek) do
    begin
     if EmailSendIfSuccessfulDaysOfTheWeek[ct] = 'Y' then EmailSendIfSuccessfulDaysOfTheWeekCheckGroup.Checked[ct-1] := true;
     inc(ct);
    end;
  end;
 ct := 0; while ct <= 6 do begin EmailSendIfErrorDaysOfTheWeekCheckGroup.Checked[ct] := false; inc(ct); end;
 if EmailSendIfErrorDaysOfTheWeek <> '' then
  begin
   ct := 1;
   while ct <= length(EmailSendIfErrorDaysOfTheWeek) do
    begin
     if EmailSendIfErrorDaysOfTheWeek[ct] = 'Y' then EmailSendIfErrorDaysOfTheWeekCheckGroup.Checked[ct-1] := true;
     inc(ct);
    end;
  end;
 EmailTestSubjectLineEdit.text := EmailTestSubjectLine;
 EmailTestMessageTextEdit.text := EmailTestMessageText;
 EmailTestRecipientAddressEdit.text := EmailTestRecipientAddress;

 PreferencesApplyChangesBitBtn.enabled := false;
 PreferencesDiscardChangesBitBtn.Enabled := false;
end;

procedure Tsinkmainform.transfer_preferences_controls_to_preferences;
var
 ct : integer;
begin
 preference_switch_allow_deletefiles := AllowDeleteFilesCheckbox.Checked;
 preference_switch_allow_deletefolders := AllowDeleteFoldersCheckbox.Checked;
 preference_switch_allow_diskfree_checks := AllowDiskFreeChecksCheckbox.Checked;
 preference_switch_min_freediskspace_percent := MinFreeDiskSpacePercentSpinEdit.Value;
 preference_switch_FileSetDateMaxPasses := FileSetDateMaxPassesSpinEdit.Value;
 preference_switch_FileSetDateSleepTime := FileSetDateSleepTimeSpinEdit.Value;
 preference_switch_delete_log_files_older_than_days := deletelogfilesolderthandaysSpinEdit.Value;

 PreferencesSchedulerUseScheduler := PreferencesSchedulerUseSchedulerCheckBox.Checked;
 PreferencesSchedulerStartMinimizedIfUsingSheduler := PreferencesSchedulerStartMinimizedIfUsingShedulerCheckBox.Checked;
 PreferencesSchedulerRunJobsAfterSinkStartup := PreferencesSchedulerRunJobsAfterSinkStartupCheckBox.Checked;
 PreferencesSchedulerDelayMinutesForStartupRun := PreferencesSchedulerDelayMinutesForStartupRunSpinEdit.Value;
 PreferencesSchedulerDaysOfTheWeek := '';
 ct := 0;
 while ct <= 6 do
  begin
   if PreferencesSchedulerDaysOfTheWeekCheckGroup.Checked[ct] then PreferencesSchedulerDaysOfTheWeek := PreferencesSchedulerDaysOfTheWeek + 'Y' else PreferencesSchedulerDaysOfTheWeek := PreferencesSchedulerDaysOfTheWeek + 'N';
   inc(ct);
  end;
 PreferencesSchedulerRunTime1 := PreferencesSchedulerRunTime1DateTimePicker.DateTime;
 PreferencesSchedulerRunTime2 := PreferencesSchedulerRunTime2DateTimePicker.DateTime;
 PreferencesSchedulerRunTime3 := PreferencesSchedulerRunTime3DateTimePicker.DateTime;
 PreferencesSchedulerRunTime4 := PreferencesSchedulerRunTime4DateTimePicker.DateTime;
 PreferencesSchedulerRunTime5 := PreferencesSchedulerRunTime5DateTimePicker.DateTime;
 PreferencesSchedulerRunTime6 := PreferencesSchedulerRunTime6DateTimePicker.DateTime;
 PreferencesSchedulerRunTime7 := PreferencesSchedulerRunTime7DateTimePicker.DateTime;
 PreferencesSchedulerRunTime8 := PreferencesSchedulerRunTime8DateTimePicker.DateTime;

 EmailAllowSinktoSendEmailNotifications := EmailAllowSinktoSendEmailNotificationsCheckbox.Checked;
 EmailHostServer := EmailHostServerEdit.Text;
 EmailUserName := EmailUserNameEdit.Text;
 EmailPassword := EmailPasswordEdit.Text;
 EmailPort := EmailPortSpinEdit.Value;
 EmailUseSSL := EmailUseSSLCheckbox.Checked;
 EmailUseTLS  := EmailUseTLSCheckbox.Checked;
 EmailSenderAddress := EmailSenderAddressEdit.Text;
 EmailRecipientAddress := EmailRecipientAddressEdit.Text;
 EmailSubjectForSuccessfulRuns := EmailSubjectForSuccessfulRunsEdit.Text;
 EmailSubjectForErrorRuns := EmailSubjectForErrorRunsEdit.Text;
 EmailAttachLogfileForSuccessfulRuns := EmailAttachLogfileForSuccessfulRunsCheckbox.Checked;
 EmailAttachLogfileForErrorRuns := EmailAttachLogfileForErrorRunsCheckbox.Checked;
 EmailSendIfSuccessfulDaysOfTheWeek := '';
 ct := 0;
 while ct <= 6 do
  begin
   if EmailSendIfSuccessfulDaysOfTheWeekCheckGroup.Checked[ct] then EmailSendIfSuccessfulDaysOfTheWeek := EmailSendIfSuccessfulDaysOfTheWeek + 'Y' else EmailSendIfSuccessfulDaysOfTheWeek := EmailSendIfSuccessfulDaysOfTheWeek + 'N';
   inc(ct);
  end;
 EmailSendIfErrorDaysOfTheWeek := '';
 ct := 0;
 while ct <= 6 do
  begin
   if EmailSendIfErrorDaysOfTheWeekCheckGroup.Checked[ct] then EmailSendIfErrorDaysOfTheWeek := EmailSendIfErrorDaysOfTheWeek + 'Y' else EmailSendIfErrorDaysOfTheWeek := EmailSendIfErrorDaysOfTheWeek + 'N';
   inc(ct);
  end;
 EmailTestSubjectLine := EmailTestSubjectLineEdit.Text;
 EmailTestMessageText := EmailTestMessageTextEdit.Text;
 EmailTestRecipientAddress := EmailTestRecipientAddressEdit.Text;
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
   set_sink_run_status;
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

procedure Tsinkmainform.StartButtonClick(Sender: TObject);
begin
 // OK: Go:
 startbutton.Visible := false; stopbutton.visible := true;
 disable_tab_controls;
 abort := false;
 try
  ResumeScheduledJobsbutton.visible := false;
  pathlabel.caption := ''; // Clear the "you can click..." info in "pathlabel".
  run_process(runmodecopyfiles);
 finally
  stopbutton.visible := false; startbutton.Visible := true;
  enable_tab_controls;
 end;
end;

procedure Tsinkmainform.AllowDeletefilesCheckBoxChange(Sender: TObject);
begin
 if factive then
  begin
   PreferencesApplyChangesBitBtn.enabled := true;
   PreferencesDiscardChangesBitBtn.Enabled := true;
  end;
end;

procedure Tsinkmainform.ConfigurationTabSheetEnter(Sender: TObject);
begin
 if preference_switch_allow_deletefiles then
  begin
   DeleteFilesCheckBox.visible := true;
  end
  else
  begin
   DeleteFilesCheckBox.visible := false;
  end;
end;

procedure Tsinkmainform.ConfigurationTabSheetExit(Sender: TObject);
begin
 // Trow away any unsaved "Configuration" tab changes:
 if DiscardChangesBitBtn.Enabled then
  begin
   DiscardChangesBitBtnClick(Sender);
  end;
end;

procedure Tsinkmainform.PreferencesApplyChangesBitBtnClick(Sender: TObject);
begin
 transfer_preferences_controls_to_preferences;
 save_ini_settings;
 set_sink_run_status;
 PreferencesApplyChangesBitBtn.enabled := false;
 PreferencesDiscardChangesBitBtn.Enabled := false;
end;

procedure Tsinkmainform.PreferencesDiscardChangesBitBtnClick(Sender: TObject);
begin
 set_preferences_controls;
 save_ini_settings;
 //set_sink_run_status;
 PreferencesApplyChangesBitBtn.enabled := false;
 PreferencesDiscardChangesBitBtn.Enabled := false;
end;

procedure Tsinkmainform.PreferencesSchedulerDaysOfTheWeekCheckGroupItemClick(
 Sender: TObject; Index: integer);
begin
 if factive then
  begin
   if index > -1 then
    begin
     PreferencesApplyChangesBitBtn.enabled := true;
     PreferencesDiscardChangesBitBtn.Enabled := true;
    end;
  end;
end;

procedure Tsinkmainform.PreferencesTabSheetExit(Sender: TObject);
begin
 // Trow away any unsaved "Preferences" tab changes:
 if PreferencesDiscardChangesBitBtn.Enabled then
  begin
   PreferencesDiscardChangesBitBtnClick(Sender);
  end;
end;

procedure Tsinkmainform.StopbuttonClick(Sender: TObject);
begin
 abort := true;
end;

procedure Tsinkmainform.TreeView1DblClick(Sender: TObject);
var
 err,failed,fileisok : boolean;
 f : textfile;
 s,mes : string;
begin
 if TreeView1.selected = mynode2 then // Export a current Sink configuration file
  begin
   savedialog1.FileName := 'sinkini.txt';
   SaveDialog1.Title := 'Save a current Sink configuration file';
   if savedialog1.Execute then
    begin
     err := false;
     if copyfile(usersettingsdir + 'sinkini.txt',savedialog1.FileName,[],err) then
      begin
       if fileexists(savedialog1.FileName) then
        begin
         messagedlg('Sink configuration file saved to: '+savedialog1.FileName,mtinformation,[mbok],0);
        end;
      end;
    end;
  end
  else if TreeView1.selected = mynode3 then // Import a saved Sink configuration file
  begin
   OpenDialog1.DefaultExt := '*.txt';
   OpenDialog1.Filter := 'Text files|*.txt';
   OpenDialog1.FilterIndex := 1;
   OpenDialog1.FileName := 'sinkini.txt';
   OpenDialog1.Title := 'Open a saved Sink configuration file';
   if OpenDialog1.Execute then
    begin
     if fileexists(OpenDialog1.FileName) then
      begin
       // Check it...
       try
        try
         failed := false; fileisok := false;
         assignfile(f,OpenDialog1.FileName);
         reset(f);
         if ioresult = 0 then
          begin
           while not eof(f) and not failed and not fileisok do
            begin
             readln(f,s);
             if pos('SINK.EXE CONFIGURATION FILE',uppercase(s)) > 0 then
              begin
               fileisok := true;
              end;
            end;
          end
          else failed := true;
        except
         failed := true; fileisok := false;
        end;
       finally
        closefile(f); if ioresult = 0 then begin end;
       end;
       if fileisok then
        begin
         // Looks like a valis sinkini.txt file has been selected.
         if copyfile(OpenDialog1.FileName,usersettingsdir + 'sinkini.txt',[cffOverWriteFile],err) then
          begin
           // OK: load it and reinitialise the configuration and preferences controls:
           load_ini_settings;
           fill_in_SourceAndTargetFoldersStringGrid;
           set_preferences_controls;
           messagedlg('The Sink configuration has been updated.',mtinformation,[mbok],0);
          end
          else
          begin
           messagedlg('Error: Unable to copy the selecteed Sink configuration file:'+#13+#10+'"'+OpenDialog1.FileName+'"'+#13+#10+'to:'+#13+#10+'"'+usersettingsdir+'sinkini.txt"'+#13+#10+'The Sink configuration has not been changed.',mterror,[mbok],0);
          end;
        end
        else
        begin
         // Couldn't verify the selected file so report an error:
         messagedlg('Error: Unable to verify the selected file:'+#13+#10+'"'+OpenDialog1.FileName+'"'+#13+#10+'as a valid Sink configuration file.'+#13+#10+'The Sink configuration has not been changed.',mterror,[mbok],0);
        end;
      end;
    end;
  end
  else if TreeView1.selected = mynode5 then // Browse/open Sink log files:
  begin
   OpenDialog1.DefaultExt := 'sinklogfile*.txt';
   OpenDialog1.Filter := 'Sink log files|sinklogfile*.txt';
   OpenDialog1.FilterIndex := 1;
   OpenDialog1.FileName := '';
   OpenDialog1.InitialDir := usersettingsdir;
   OpenDialog1.Title := 'Open a Sink log file';
   if OpenDialog1.Execute then
    begin
     if fileexists(OpenDialog1.FileName) then
      begin
       try
        if not OpenDocument(OpenDialog1.FileName) then
         begin
          messagedlg('Error: Unable to open the selected Sink log file:'+#13+#10+'"'+OpenDialog1.FileName+'"',mterror,[mbok],0);
         end;
       except
        messagedlg('Error: Unable to open the selected Sink log file:'+#13+#10+'"'+OpenDialog1.FileName+'"',mterror,[mbok],0);
       end;
      end;
    end;
  end
  else if TreeView1.selected = mynode7 then // Sync Date+Time File Stamps
  begin
   // OK: Go:
   mes := 'This option will search through all of the files in all of your defined jobs Source folders and look for matching filenames in the corresponding Target folders.'+#13+
          'For any files that are found in a Target folder that have the same filenames as those in the corresponding Source folder it will set the date+time file'+#13+
          'stamp on the Target file to match the date+time file stamp of the Source file.'+#13+
          ''+#13+
          'This ensures that the jobs copy process will see the same date+time file stamps on both the Source and Target files and will therefore not force a re-copy'+#13+
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
          'Note: This process will switch to the "Home" tab to show you the progress of the "Sync Date+Time File Stamps" process.'+#13+
          ''+#13+
          'Click "OK" to proceed or "Cancel" to quit.';
   if Dialogs.MessageDlg(mes,mtwarning,[mbok,mbcancel],0) = mrok then
    begin
     pagecontrol1.ActivePage := HomeTabSheet; // Switch to the Home tab.
     startbutton.Visible := false; stopbutton.visible := true;
     disable_tab_controls;
     try
      run_process(runmodesetfilestamps);
     finally
      stopbutton.visible := false; startbutton.Visible := true;
      enable_tab_controls;
     end;
    end;
  end;
end;

procedure Tsinkmainform.TreeView1KeyDown(Sender: TObject; var Key: Word);
begin
 if key = vk_return then
  begin
   TreeView1DblClick(sender);
  end;
end;

procedure Tsinkmainform.set_default_preference_switch_values; // Set default preference switch values:
begin
 preference_switch_allow_deletefiles := false; // Are we allowed to delete files from target folders? - FALSE by default.
 preference_switch_allow_deletefolders := false; // Are we alowed to delete folders from target folders? - FALSE by default.
 preference_switch_allow_diskfree_checks := true; // Are we allowed to run disk free checks on the target drives?
 preference_switch_min_freediskspace_percent := 5; // Default to 5% minimum disk free space remaining on target drive(s) after file copy process.
 preference_switch_FileSetDateMaxPasses := 10; // Default to 10 retries in the filesetdate function.
 preference_switch_FileSetDateSleepTime := 1000; // Default to 1 second sleep time between retries in the filesetdate function.
 preference_switch_delete_log_files_older_than_days := 30; // Delete Sink log files older than 30 days by default.

 PreferencesSchedulerUseScheduler := false;
 PreferencesSchedulerStartMinimizedIfUsingSheduler := false;
 PreferencesSchedulerRunJobsAfterSinkStartup := false;
 PreferencesSchedulerDelayMinutesForStartupRun := 5;
 PreferencesSchedulerDaysOfTheWeek := 'NNNNNNN';
 PreferencesSchedulerRunTime1 := 0;
 PreferencesSchedulerRunTime2 := 0;
 PreferencesSchedulerRunTime3 := 0;
 PreferencesSchedulerRunTime4 := 0;
 PreferencesSchedulerRunTime5 := 0;
 PreferencesSchedulerRunTime6 := 0;
 PreferencesSchedulerRunTime7 := 0;
 PreferencesSchedulerRunTime8 := 0;

 EmailAllowSinktoSendEmailNotifications := false;
 EmailHostServer := '';
 EmailUserName := '';
 EmailPassword := '';
 EmailPort := 587;
 EmailUseSSL := false;
 EmailUseTLS := true;
 EmailSenderAddress := '';
 EmailRecipientAddress := '';
 EmailSubjectForSuccessfulRuns := 'Sink file and folder backup/sync application ran successfully.';
 EmailSubjectForErrorRuns := 'ERRORS: Sink file and folder backup/sync application ran with errors reported.';
 EmailAttachLogfileForSuccessfulRuns := false;
 EmailAttachLogfileForErrorRuns := true;
 EmailSendIfSuccessfulDaysOfTheWeek := 'YYYYYYY';
 EmailSendIfErrorDaysOfTheWeek := 'YYYYYYY';
 EmailTestSubjectLine := 'Test email from the Sink file and folder backup/sync application.';
 EmailTestMessageText := 'This is a test email from the Sink file and folder backup/sync application.';
 EmailTestRecipientAddress := '';
end;

procedure Tsinkmainform.setup_tools_options; // Set up the "Tools" options:
begin
 TreeView1.items.clear;
 TreeView1.ShowButtons := false;
 TreeView1.ShowRoot := false;
 mynode := nil;

 mynode6 := TreeView1.items.AddFirst(mynode,'Utilities');  mynode6.ImageIndex := 5;  mynode6.SelectedIndex := 5;
 mynode7 := TreeView1.items.AddChild(mynode6,'Sync Date+Time File Stamps'); mynode7.ImageIndex := 4; mynode7.SelectedIndex := 4;

 mynode4 := TreeView1.items.AddFirst(mynode,'Sink Log Files');  mynode4.ImageIndex := 5;  mynode4.SelectedIndex := 5;
 mynode5 := TreeView1.items.AddChild(mynode4,'Browse/open Sink log files'); mynode5.ImageIndex := 4; mynode5.SelectedIndex := 4;

 mynode1 := TreeView1.items.AddFirst(mynode,'Sink Configuration');  mynode1.ImageIndex := 5;  mynode1.SelectedIndex := 5;
 mynode2 := TreeView1.items.AddChild(mynode1,'Export a current Sink configuration file'); mynode2.ImageIndex := 4; mynode2.SelectedIndex := 4;
 mynode3 := TreeView1.items.AddChild(mynode1,'Import a saved Sink configuration file'); mynode3.ImageIndex := 4; mynode3.SelectedIndex := 4;

 mynode1.Expanded := true;
 mynode4.Expanded := true;
 mynode6.Expanded := true;
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
 factive := false;
 try
  SchedulerTimer.Enabled := false;
  status_app_startup_datetime := now;
  status_done_app_startup_run := false;
  email_last_success_email_sent := 0;

  pagecontrol1.ActivePage := HomeTabSheet; // Switch to the Home tab.
  PreferencesPageControl.ActivePage := PreferencesGeneralSettingsTabSheet; // Set the Preferences page control to the "General Settings" tab.
  SourceAndTargetFoldersStringGrid.ColWidths[2] := 0;
  SourceAndTargetFoldersStringGrid.ColWidths[3] := 0;
  pathlabel.caption := ''; filenamelabel.caption := ''; progressbarbr.visible := false; ActivityLogMemo.Clear; stopbutton.visible := false; startbutton.Visible := true;
  filesinsourcealsointargetstringlist_maxsize := (1024 * 1024) * 100; // Allow 100Mb max for "filesinsourcealsointargetstringlist".
  LabelTimeElapsed.Caption := 'Time Elapsed: ......';
  LabelTimeRemaining.Caption := 'Time Remaining: ......';
  set_default_preference_switch_values; // Set default preference switch values:
  setup_tools_options; // Set up the "Tools" options:
  if fn_determine_usersettingsdir then
   begin
    load_ini_settings;
    fill_in_SourceAndTargetFoldersStringGrid;
    set_preferences_controls;
    set_sink_run_status;
    if SchedulerTimer.Enabled and PreferencesSchedulerStartMinimizedIfUsingSheduler then
     begin
      application.Minimize;
     end;
   end
   else
   begin
    application.Terminate;
   end;
 finally
  factive := true;
 end;
end;

procedure Tsinkmainform.set_sink_run_status;
const
 max_SchedulerRunTimes : integer = 8;
var
 today_day_of_week,this_day_of_week,ct : integer;
 startuprundatetime,dt,closestdiff,curdate,relevanttime : TDateTime;
 s,startupinfo : string;
 can_run_at_startup,found,startfromtoday : boolean;
 SchedulerRunTimes : array of TDateTime;
 SchedulerRunTimes_count : integer;
 dayofweekarray : array[1..7] of string;
begin
 try
  SchedulerTimer.Enabled := false;
  CancelScheduledJobsbutton.visible := false;
  ResumeScheduledJobsbutton.visible := false;
  StatusLabel.Caption:= 'Status:'; pathlabel.caption := '';
  status_next_sheduled_run_datetime := 0; // Inactive.

  dayofweekarray[1] := 'Monday'; dayofweekarray[2] := 'Tuesday'; dayofweekarray[3] := 'Wednesday'; dayofweekarray[4] := 'Thursday'; dayofweekarray[5] := 'Friday'; dayofweekarray[6] := 'Saturday'; dayofweekarray[7] := 'Sunday';
  if source_and_target_array_count = 0 then
   begin
    StatusLabel.Caption:= 'Status: No Jobs have been configured so there is nothing to do.';
   end
   else
   begin
    if PreferencesSchedulerUseScheduler then
     begin
      // OK, we are using the scheduler. What's the next run time?
      // Are any "job sheduler run days" defined?
      if pos('Y',uppercase(PreferencesSchedulerDaysOfTheWeek)) = 0 then
       begin
        // No so report nothing to do:
        StatusLabel.Caption:= 'Status: No Jobs Scheduler "run on days of the week" are set so there are no possible sheduled run times. Waiting for you to click "Start" to run the Jobs manually.';
       end
       else
       begin
        // OK, we are allowed to run on at least one day of the week...
        // What's the day of the week for today?
        can_run_at_startup := false;
        startupinfo := '';
        today_day_of_week := DayOfTheWeek(status_app_startup_datetime); // DayOfTheWeek is the ISO-conformal function where the week begins with Monday: 1 = Monday, 7 = Sunday
        StatusLabel.Caption:= 'Status: No Jobs Scheduler run times have been detected so waiting for you to click "Start" to run the Jobs manually.';
        if copy(PreferencesSchedulerDaysOfTheWeek,today_day_of_week,1) = 'Y' then
         begin
          // OK, I am allowed to run scheduled jobs today.
          // Am I allowed to run at startup + x minutes?
          if PreferencesSchedulerRunJobsAfterSinkStartup and NOT status_done_app_startup_run then
           begin
            if PreferencesSchedulerDelayMinutesForStartupRun <= 0 then PreferencesSchedulerDelayMinutesForStartupRun := 1; // Min is start up time + 1 minutes.
            startuprundatetime := status_app_startup_datetime + encodetime(0,PreferencesSchedulerDelayMinutesForStartupRun,0,0);
            if now < startuprundatetime then
             begin
              // OK: Can run at startuprundatetime.
              can_run_at_startup := true; status_next_sheduled_run_datetime := startuprundatetime;
              status_done_app_startup_run := true; // OK: Don't run this again until next startup.
              s := ''; if PreferencesSchedulerDelayMinutesForStartupRun > 1 then s := 's';
              StatusLabel.Caption:= 'Status: Job Scheduler indicates that we need to run at Sink start up time + '+inttostr(PreferencesSchedulerDelayMinutesForStartupRun)+ ' minute'+s+' so will next run all Jobs automatically Today at '+datetimetostr(startuprundatetime)+'.';
              pathlabel.caption := 'Note: You can click "Cancel Scheduled Jobs Run" to cancel the scheduler and switch to manual mode.';
              disable_tab_controls; // Disable all tabs to prevent users changing settings when the schedule timer is running.
              SchedulerTimer.Enabled := true;
              CancelScheduledJobsbutton.visible := true;
              ResumeScheduledJobsbutton.visible := false;
             end
             else if PreferencesSchedulerRunJobsAfterSinkStartup then
             begin
              // OK, we are set to run at atartup but not today, so what's the next day I CAN run at startup.
              curdate := trunc(status_app_startup_datetime) + 1;
              found := false;
              while (curdate < curdate + 8) and not found do
               begin
                this_day_of_week := DayOfTheWeek(curdate); // DayOfTheWeek is the ISO-conformal function where the week begins with Monday: 1 = Monday, 7 = Sunday
                if copy(PreferencesSchedulerDaysOfTheWeek,this_day_of_week,1) = 'Y' then
                 begin
                  found := true;
                  StatusLabel.Caption:= 'Status: Job Scheduler indicates that we will next run when Sink start up on '+dayofweekarray[this_day_of_week]+' ' + datetostr(curdate)+'.';
                  startupinfo := ' Or when Sink is restarted on that date.';
                 end;
                curdate := curdate + 1;
               end;
             end;
           end
           else if PreferencesSchedulerRunJobsAfterSinkStartup then
           begin
            // OK, we are set to run at atartup but not today, so what's the next day I CAN run at startup.
            curdate := trunc(status_app_startup_datetime) + 1;
            found := false;
            while (curdate < curdate + 8) and not found do
             begin
              this_day_of_week := DayOfTheWeek(curdate); // DayOfTheWeek is the ISO-conformal function where the week begins with Monday: 1 = Monday, 7 = Sunday
              if copy(PreferencesSchedulerDaysOfTheWeek,this_day_of_week,1) = 'Y' then
               begin
                found := true;
                StatusLabel.Caption:= 'Status: Job Scheduler indicates that we will next run when Sink start up on '+dayofweekarray[this_day_of_week]+' ' + datetostr(curdate)+'.';
                startupinfo := ' Or when Sink is restarted on that date.';
               end;
              curdate := curdate + 1;
             end;
           end;
         end
         else // Say when we CAN next run at startup.
         begin
          if PreferencesSchedulerRunJobsAfterSinkStartup then
           begin
            // OK, we are set to run at atartup but not today, so what's the next day I CAN run at startup.
            curdate := trunc(status_app_startup_datetime) + 1;
            found := false;
            while (curdate < curdate + 8) and not found do
             begin
              this_day_of_week := DayOfTheWeek(curdate); // DayOfTheWeek is the ISO-conformal function where the week begins with Monday: 1 = Monday, 7 = Sunday
              if copy(PreferencesSchedulerDaysOfTheWeek,this_day_of_week,1) = 'Y' then
               begin
                found := true;
                StatusLabel.Caption:= 'Status: Job Scheduler indicates that we will next run when Sink start up on '+dayofweekarray[this_day_of_week]+' ' + datetostr(curdate)+'.';
                startupinfo := ' Or when Sink is restarted on that date.';
               end;
              curdate := curdate + 1;
             end;
           end;
         end;
        if not can_run_at_startup then
         begin
          // OK, can't do the run at start up thing (today) so we now need to see if any sheduler run times are defined.
          SchedulerRunTimes := nil;
          setlength(SchedulerRunTimes,0); SchedulerRunTimes_count := 0;
          ct := 1;
          while ct <= max_SchedulerRunTimes do
           begin
            case ct of
             1 : dt := PreferencesSchedulerRunTime1;
             2 : dt := PreferencesSchedulerRunTime2;
             3 : dt := PreferencesSchedulerRunTime3;
             4 : dt := PreferencesSchedulerRunTime4;
             5 : dt := PreferencesSchedulerRunTime5;
             6 : dt := PreferencesSchedulerRunTime6;
             7 : dt := PreferencesSchedulerRunTime7;
             8 : dt := PreferencesSchedulerRunTime8;
             else dt := 0;
            end;
            if dt <> 0 then
             begin
              inc(SchedulerRunTimes_count);
              setlength(SchedulerRunTimes,SchedulerRunTimes_count);
              SchedulerRunTimes[SchedulerRunTimes_count-1] := dt;
             end;
            inc(ct);
           end;
          if SchedulerRunTimes_count > 0 then
           begin
            // OK we have scheduled run times so given the time now, what's the earliest run time that > now?
            if copy(PreferencesSchedulerDaysOfTheWeek,today_day_of_week,1) = 'Y' then // If we can run today then we need to compare the run times against the current time.
             begin
              relevanttime := frac(now);
             end
             else // Otherwise, check the run times against midnight on days after tomorrow.
             begin
              relevanttime := 0;
             end;
            closestdiff := -1;
            ct := 0;
            while (ct < SchedulerRunTimes_count) do
             begin
              if SchedulerRunTimes[ct] > relevanttime then
               begin
                if (SchedulerRunTimes[ct] - relevanttime < closestdiff) or (closestdiff = -1) then
                 begin
                  closestdiff := SchedulerRunTimes[ct] - relevanttime;
                  status_next_sheduled_run_datetime := SchedulerRunTimes[ct];
                 end;
               end;
              inc(ct);
             end;
            startfromtoday := true;
            if status_next_sheduled_run_datetime = 0 then
             begin
              // OK, can't do any more scheduled runs today because the time now has exceeded the last defined run time so we need to re-calculate the status_next_sheduled_run_datetime based on midnight and disallow the code
              // below to use curdate = today.
              relevanttime := 0;
              closestdiff := -1;
              ct := 0;
              while (ct < SchedulerRunTimes_count) do
               begin
                if SchedulerRunTimes[ct] > relevanttime then
                 begin
                  if (SchedulerRunTimes[ct] - relevanttime < closestdiff) or (closestdiff = -1) then
                   begin
                    closestdiff := SchedulerRunTimes[ct] - relevanttime;
                    status_next_sheduled_run_datetime := SchedulerRunTimes[ct];
                   end;
                 end;
                inc(ct);
               end;
              startfromtoday := false;
             end;
            if status_next_sheduled_run_datetime > 0 then // e.g. 14:00
             begin
              // OK: So what's the next run day I can use?
              curdate := trunc(now);
              if startfromtoday = false then curdate := curdate + 1; // Move to tomorrow then.
              found := false;
              while (curdate < curdate + 8) and not found do
               begin
                this_day_of_week := DayOfTheWeek(curdate); // DayOfTheWeek is the ISO-conformal function where the week begins with Monday: 1 = Monday, 7 = Sunday
                if copy(PreferencesSchedulerDaysOfTheWeek,this_day_of_week,1) = 'Y' then
                 begin
                  found := true;
                  status_next_sheduled_run_datetime := curdate + status_next_sheduled_run_datetime;
                  if curdate = trunc(now) then
                   begin
                    StatusLabel.Caption:= 'Status: Next scheduled Jobs run time is Today ' + datetimetostr(status_next_sheduled_run_datetime) + '.';
                   end
                   else
                   begin
                    StatusLabel.Caption:= 'Status: Next scheduled Jobs run time is ' + dayofweekarray[this_day_of_week] + ' ' + datetimetostr(status_next_sheduled_run_datetime) + '.' + startupinfo;
                   end;
                  pathlabel.caption := 'Note: You can click "Cancel Scheduled Jobs Run" to cancel the scheduler and switch to manual mode.';
                  disable_tab_controls; // Disable all tabs to prevent users changing settings when the schedule timer is running.
                  SchedulerTimer.Enabled := true;
                  CancelScheduledJobsbutton.visible := true;
                  ResumeScheduledJobsbutton.visible := false;
                 end;
                curdate := curdate + 1;
               end;
             end;
           end
           else
           begin
            if pos('we will next run',StatusLabel.Caption) = 0 then
             begin
              StatusLabel.Caption:= 'Status: No Jobs Scheduler run times have been defined so waiting for you to click "Start" to run the Jobs manually.';
             end;
           end;
         end;
       end;
     end
     else
     begin
      StatusLabel.Caption:= 'Status: No Jobs Scheduler run times are defined so waiting for you to click "Start" to run the Jobs manually.';
     end;
   end;
 finally
  setlength(SchedulerRunTimes,0);
 end;
end;

procedure Tsinkmainform.SchedulerTimerTimer(Sender: TObject);
begin
 if now > status_next_sheduled_run_datetime then
  begin
   SchedulerTimer.Enabled := false;
   pagecontrol1.ActivePage := HomeTabSheet; // Switch to the Home tab.
   StartButtonClick(Sender);
  end;
end;

procedure Tsinkmainform.CancelScheduledJobsbuttonClick(Sender: TObject);
begin
 SchedulerTimer.Enabled := false;
 StatusLabel.Caption:= 'Status: The Jobs Scheduler has been cancelled. Click "Resume Scheduled Jobs Run" to re-start it or click "Start" to run Jobs manually.';
 pathlabel.caption := '';
 CancelScheduledJobsbutton.visible := false;
 ResumeScheduledJobsbutton.visible := true;
 enable_tab_controls;
end;

procedure Tsinkmainform.ResumeScheduledJobsbuttonClick(Sender: TObject);
begin
 set_sink_run_status;
end;

procedure Tsinkmainform.EmailSendTestEmailBitBtnClick(Sender: TObject);
var
 EmailTestMessageTextStringList : TStringList;
begin
 EmailTestEmailResultsMemo.Clear;
 EmailTestMessageTextStringList := TStringList.Create;
 try
  EmailTestMessageTextStringList.Add(EmailTestMessageTextEdit.Text);
  if fn_email_settings_ok = '' then // "fn_email_settings_ok" returns blank string if all key email settings have been populated.
   begin
    EmailTestEmailResultsMemo.Lines.Text := send_email(EmailHostServerEdit.Text,
                                                       EmailUserNameEdit.Text,
                                                       EmailPasswordEdit.Text,
                                                       inttostr(EmailPortSpinEdit.Value),
                                                       EmailUseSSLCheckbox.Checked,
                                                       EmailUseTLSCheckbox.Checked,
                                                       EmailSenderAddressEdit.Text,
                                                       EmailTestRecipientAddressEdit.Text,
                                                       EmailTestSubjectLineEdit.Text,
                                                       EmailTestMessageTextStringList,
                                                       ''); // No attachement path+filename required for test email.
   end
   else
   begin
    EmailTestEmailResultsMemo.Lines.Text := fn_email_settings_ok;
   end;
 finally
  EmailTestMessageTextStringList.clear;
  EmailTestMessageTextStringList.free;
 end;
end;

procedure Tsinkmainform.TreeView2Click(Sender: TObject);
var
 searchtext : string;
 mynode : TTreenode;

procedure navigateto(searchtext : string);
var
 ct : integer;
 found : boolean;
 onepercent,thispercent : real;
begin
 ct := 0; found := false;
 while (ct < memo1.Lines.Count) and not found do
  begin
   if strip(stripfront(memo1.Lines[ct])) = searchtext then
    begin
     found := true;
    end
    else inc(ct);
  end;
 if found then
  begin
   onepercent := memo1.Lines.Count;
   onepercent :=  onepercent / 100;
   thispercent := ct / onepercent;
   memo1.VertScrollBar.Position := 0;
   application.ProcessMessages;
   //memo1.VertScrollBar.Position := trunc(thispercent);
   Memo1.CaretPos := Point(0, ct);
   application.ProcessMessages;
  end;
end;

begin
 try
  mynode := treeview2.Selected;
  searchtext := uppercase(mynode.Text) + ':';
  if searchtext <> '' then
   begin
    navigateto(searchtext);
   end;
 except
 end;
end;

procedure Tsinkmainform.ViewDocumentationInYourTextEditorBitBtnClick(
 Sender: TObject);
begin
 try
  Memo1.Lines.SaveToFile(usersettingsdir+'sink_documentation.txt');
  if fileexists(usersettingsdir+'sink_documentation.txt') then
   begin
    if not OpenDocument(usersettingsdir+'sink_documentation.txt') then
     begin
     end;
   end;
 except
 end;
end;


end.
