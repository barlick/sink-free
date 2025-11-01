unit sinkmain;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, ImgList, Grids, Buttons,LazFileUtils;

const
 runmodecopyfiles : integer = 0;
 runmodesetfilestamps : integer = 1;

 copyifnotpresent : integer = 0;
 copyifnotpresentorchanged : integer = 1;

type
  source_and_target_rec = record
   sourcefolder : string;
   targetfolder : string;
   copymode : integer;
   deletefiles : boolean;
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
    LabelTE: TLabel;
    LabelTR: TLabel;
    LabelTET: TLabel;
    LabelTRT: TLabel;
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
    source_and_target_array : array of source_and_target_rec;
    source_and_target_array_count : integer;
    master_filesize : int64;
    master_bytes_written : int64;
    abort : boolean;
    PT1,PTL : TDateTime;
    appdir : string;
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
 (*
 Result := PathIn;
 if PathIn <> '' then
  if PathIn[Length(PathIn)] <> '\' then
   Result := PathIn + '\';
  *)
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
 T : TDateTime;
 throughput,numsec,onepercent,progpos : double;
 throughputstr : string;

function NumberOfSeconds(tim: TDateTime): double;
var H,m,s,l: word;
begin
 DecodeTime(tim,h,m,s,l);
 result := s + (m * 60) + (h * 3600);
end;

begin
 master_bytes_written := master_bytes_written + numw;
 onepercent := master_filesize / 1000; // Note that progbar.max = 1000 not 100 so as to improve the granularity of the progress bar.
 progpos := master_bytes_written / onepercent;
 if master_filesize - master_bytes_written < onepercent then progpos := 1000;
 ProgressBarBR.Position := trunc(progpos);

 PTL := now;
 T := PTL - PT1;
 LabelTET.Caption := FormatDateTime('hh:mm.ss', T); // Time elapsed.
 // So ProgressBarBR.Position = number of bytes written and "T" is the elapsed time, so throughput bytes per second = ProgressBarBR.Position/T.
 if T > 0  then
  begin
   numsec := NumberOfSeconds(T);
   if numsec > 0 then
    begin
     throughput := master_bytes_written; // Bytes written.
     throughput := throughput/1024; // 1024 = kilo bytes.
     throughput := throughput/1024; // 1024 = Mega bytes.
     throughputstr := ' Read+Write Speed '+sr(throughput/numsec,12,1) + ' MB/s';
    end;
  end
  else
  begin
   throughputstr := '';
  end;

 if master_bytes_written > 0 then
  begin
   T := (PTL - PT1) * (1 - master_filesize / master_bytes_written);
  end
  else T := 0;
 LabelTRT.Caption := FormatDateTime('hh:mm.ss', T) + throughputstr; // Time remaning + Throughout

end;

procedure Tsinkmainform.run_process(runmode : integer);
var
 sourcefolder,targetfolder : string;
 copymode : integer;
 deletefiles : boolean;
 pass,ct : integer;

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
   writeln(testfile,'This is a test file from Optima (Checking validity of foldername).');
  end;
 closefile(testfile);
 if ioresult = 0 then begin end;
 erase(testfile);
 if ioresult = 0 then begin end;
 {$I+}
 matf := err = 0;
 result := matf;
end;

function fn_optimacopyfile(fromfile,tofile : string) : boolean;
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
  end;
 assignfile(f,fromfile);  reset(f,1);
 assignfile(f1,tofile);   rewrite(f1,1);
 new(psave);
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
 dispose(psave);
 result := filesize(f) = filesize(f1);
 closefile(f); closefile(f1);
 if ioresult = 0 then begin end;
 if result then // OK, if it worked, then rename the tofile.tmp to tofile.<correct file extension>:
  begin
   propertofile := ChangeFileExt(tofile,origfileext);
   deletefile(propertofile); // In case the target file exists we need to delete it just in case.
   renamefile(tofile,propertofile);
  end
  else // Didn't work - kill the duff target file.
  begin
   ActivityLogMemo.Lines.Add('Error: Unable to copy "'+extractfilename(fromfile)+'" from "'+extractfilepath(fromfile)+'" check file access permissions.');
   deletefile(tofile);
  end;
 if ioresult = 0 then begin end;
 {$I+}
end;

procedure scanforfiles(scanmode : integer; startpath : string; copymode : integer; deletefiles : boolean);
var
 mySearchRec : sysutils.TSearchRec;
 ReturnValue : integer;
 s : string;
 doit,oktosettimestamp : boolean;
 sourceFileDateTime,targetFileDateTime : TDateTime;
 sourceFileSize,targetFileSize : Int64;
begin
 {$I-}
 try
  ReturnValue:=FindFirst(startpath+'*',faAnyFile,mysearchrec);
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
     scanforfiles(scanmode,delimitpath(startpath+mysearchrec.name),copymode,deletefiles);
    end
    else if (mySearchRec.Attr and faDirectory = 0) and
            (pos('THUMBS.DB',uppercase(mySearchRec.name)) = 0) and
            (pos('INDEXERVOLUMEGUID',uppercase(mySearchRec.name)) = 0) then
    begin
     application.processmessages;
     doit := false;
     oktosettimestamp := false;
     s := stringreplace(startpath+mysearchrec.name,sourcefolder,targetfolder,[rfreplaceall,rfignorecase]);

     if scanmode = 2 then // Scanmode = "2" = delete files present in targetfolder that are not present in the sourcefolder. The "startpath" is the targetfolder.
      begin
       if deletefiles then
        begin
         s := stringreplace(startpath+mysearchrec.name,targetfolder,sourcefolder,[rfreplaceall,rfignorecase]);
         if not fileexists(s) then // Not present in Source folder?
          begin
           ActivityLogMemo.Lines.Add('File "'+mysearchrec.name+'" in the Target folder "'+targetfolder+'" does not exist in the Source folder "'+sourcefolder+'" so deleting it.');
           deletefile(startpath+mysearchrec.name);
          end;
        end;
      end
      else if scanmode = 3 then // 3 = setfilestamps mode.
      begin
       sourceFileDateTime := 0; sourceFileSize := 0; targetFileDateTime := 0; targetFileSize := 0;
       if fileexists(s) then
        begin
         oktosettimestamp := false;
         try
          if GetFileDetails(startpath+mysearchrec.name,sourceFileDateTime,sourceFileSize) then oktosettimestamp := true;
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
          doit := false;
         end;
        end;
      end
      else
      begin
       // OK, If "copymode" = copyifnotpresent (0) or copyifnotpresentorchanged (1) and the source file does not exist in the target folder then we DO want to copy it:
       oktosettimestamp := false;
       if not fileexists(s) then
        begin
         try
          if GetFileDetails(startpath+mysearchrec.name,sourceFileDateTime,sourceFileSize) then oktosettimestamp := true;
          doit := true;
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
               end
               else
               begin
                // Size is same but what about the timestamps?
                if abs(sourceFileDateTime - targetFileDateTime) > encodetime(0,1,0,0) then // > 1 minute differnet? (so as not to risk odd differences in timestamps between different file systems 1 minute should be "safe").
                 begin
                  doit := true;
                 end;
               end;
             end;
           end;
         except
          doit := false;
         end;
        end;
      end;
     if scanmode <> 2 then // 2 = Delete files mode so don't do any of this stuff:
      begin
       if doit then
        begin
         // Copy: startpath+mysearchrec.name to "s":
         if scanmode = 3 then // 3 = setfilestamps mode.
          begin
           try
            FileSetDate(s,DateTimeToFileDate(sourcefiledatetime));
            ActivityLogMemo.Lines.Add('Set file date+time for "'+mysearchrec.name+'" in "'+targetfolder+'".');
           except
            ActivityLogMemo.Lines.Add('Error: Failed to set file date+time for "'+mysearchrec.name+'" in "'+targetfolder+'".');
           end;
          end
          else if scanmode = 0 then // Scan only...
          begin
           pathlabel.caption := 'Scanning Folder: '+startpath;
           filenamelabel.caption := 'Scanning File: '+mysearchrec.name;
           application.processmessages;
           if fileexists(startpath+mysearchrec.name) then
            begin
             master_filesize := master_filesize + mysearchrec.Size;
            end;
          end
          else if scanmode = 1 then // Main "copy files" scan mode:
          begin
           if fileexists(startpath+mysearchrec.name) then
            begin
             pathlabel.caption := 'Coping From: '+startpath;
             filenamelabel.caption := 'Coping File: '+mysearchrec.name;
             application.processmessages;
             if fn_make_and_test_folder(extractfilepath(s)) then
              begin
               if fn_optimacopyfile(startpath+mysearchrec.name,s) then;
               if oktosettimestamp then
                begin
                 if fileexists(s) then
                  begin
                   // OK: Set the date time stamp on the "new" target file (s) to match the date time stamp on the source file:
                   try
                    FileSetDate(s,DateTimeToFileDate(sourcefiledatetime));
                   except
                    ActivityLogMemo.Lines.Add('Error: Failed to set file date+time for "'+s+'".');
                   end;
                  end;
                end;
               ActivityLogMemo.Lines.Add('Copied "'+mysearchrec.name+'"');
              end
              else
              begin
               ActivityLogMemo.Lines.Add('Error: Failed to create/access Target folder "'+extractfilepath(s)+'".');
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
   end;
 end;
end;

procedure sync_folders(scanmode : integer; sourcefolder : string; copymode : integer; deletefiles : boolean);
begin
 pathlabel.caption := 'Scanning: '+sourcefolder;
 filenamelabel.caption := '';
 scanforfiles(scanmode,sourcefolder,copymode,deletefiles);
end;

begin
 abort := false;
 ActivityLogMemo.Clear;
 progressbarbr.visible := false;
 LabelTET.Caption := '......';
 LabelTRT.Caption := '......';
 PT1 := now;
 try
  master_filesize := 0; master_bytes_written := 0;
  if source_and_target_array_count > 0 then
   begin
    if runmode = runmodecopyfiles then
     begin
      pass := 0;
      while (pass <= 1) and not abort do
       begin
        if pass = 1 then
         begin
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
          if pass = 0 then
           begin
            ActivityLogMemo.Lines.Add('Scanning source folder "'+sourcefolder+'".');
            ActivityLogMemo.Lines.Add('Comparing with target folder "'+targetfolder+'".');
           end;
          sync_folders(pass,sourcefolder,copymode,deletefiles);
          inc(ct);
         end;
        inc(pass);
       end;
      // OK, now got back through the source_and_target_array and if any of them have the "deletfiles" option enabled the do an extra pass (2) to delete any files that are present in
      // the target folder but are NOT present in the source folder:
      ct := 0;
      while (ct < source_and_target_array_count) and not abort do
       begin
        if source_and_target_array[ct].deletefiles then
         begin
          sourcefolder := source_and_target_array[ct].sourcefolder;
          targetfolder := source_and_target_array[ct].targetfolder;
          copymode := source_and_target_array[ct].copymode;
          deletefiles := source_and_target_array[ct].deletefiles;
          ActivityLogMemo.Lines.Add('Scanning source folder "'+sourcefolder+'".');
          ActivityLogMemo.Lines.Add('Comparing with target folder "'+targetfolder+'" to locate any files that need to be deleted.');
          sync_folders(2,targetfolder,copymode,deletefiles); // Pass "2" = delete files.
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
        sync_folders(3,sourcefolder,copymode,deletefiles); // Pass "3" = set filestamps on target folder files.
        inc(ct);
       end;
     end;
   end;

  if abort then
   begin
    pathlabel.caption := 'Process was stopped.';
    ActivityLogMemo.Lines.Add('Process was stopped.');
   end
   else
   begin
    pathlabel.caption := 'Finished';
    ActivityLogMemo.Lines.Add('Finished.');
   end;
  filenamelabel.caption := '';
 finally
  progressbarbr.visible := false;
  LabelTET.Caption := '......';
  LabelTRT.Caption := '......';
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
 assignfile(f,appdir + 'sinkini.txt');
 reset(f);
 if ioresult = 0 then
  begin
   while not eof(f) do
    begin
     readln(f,s);
     // Is it a "[Source Folder]"? If so them MUST be followed be "[Target Folder]" line so read them both:
     copymode := copyifnotpresent; deletefiles := false;
     if uppercase(copy(s,1,15)) = '[SOURCE FOLDER]' then // Legacy type file.
      begin
       targetfolder := '';
       sourcefolder := copy(s,16,length(s));
       readln(f,targetfolder);
       if uppercase(copy(targetfolder,1,15)) = '[TARGET FOLDER]' then
        begin
         targetfolder := copy(targetfolder,16,length(targetfolder));
        end;
       if (sourcefolder <> '') and (targetfolder <> '') then
        begin
         inc(source_and_target_array_count); setlength(source_and_target_array,source_and_target_array_count);
         source_and_target_array[source_and_target_array_count-1].sourcefolder := delimitpath(sourcefolder);
         source_and_target_array[source_and_target_array_count-1].targetfolder := delimitpath(targetfolder);
         source_and_target_array[source_and_target_array_count-1].copymode := copymode;
         source_and_target_array[source_and_target_array_count-1].deletefiles := deletefiles;
        end;
      end
      else
      begin
       // New type sink.ini:
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
 assignfile(f,appdir + 'sinkini.txt');
 rewrite(f);
 if ioresult = 0 then
  begin
   if source_and_target_array_count > 0 then
    begin
     writeln(f,'# Sink.exe configuration file. If you are no longer using the Sink.exe file syncing/backup applidation then you can safely delete this file.');
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
 maxwidth := sinkmainform.width - 30;
 if maxwidth < 0 then maxwidth := 1;

 newcolwidth := maxwidth div 2;
 if newcolwidth < 0 then newcolwidth := 1;
 SourceAndTargetFoldersStringGrid.ColWidths[0] := newcolwidth;

 newcolwidth := (sinkmainform.width - SourceAndTargetFoldersStringGrid.ColWidths[0]) - 30;
 if newcolwidth < 0 then newcolwidth := 1;
 SourceAndTargetFoldersStringGrid.ColWidths[1] := newcolwidth;
end;

procedure Tsinkmainform.FormShow(Sender: TObject);

function fn_determine_appdir : boolean;
begin
 result := false;
 sinkmainform.appdir := GetAppConfigDir(false);
 if sinkmainform.appdir = '' then
  begin
   sinkmainform.appdir := GetAppConfigDir(true);
   if sinkmainform.appdir = '' then
    begin
     sinkmainform.appdir := GetUserDir;
    end;
  end;
 if sinkmainform.appdir <> '' then
  begin
   try
    result := true;
    sinkmainform.appdir := DelimitPath(sinkmainform.appdir);
    CreateDir(sinkmainform.appdir);
   except
   end;
  end
  else
  begin
   showmessage('Error: Unable to determine Application Configuration folder.');
  end;
end;

begin
 pathlabel.caption := ''; filenamelabel.caption := ''; progressbarbr.visible := false; ActivityLogMemo.Clear; stopbutton.visible := false; startbutton.Visible := true;
 LabelTET.Caption := '......';
 LabelTRT.Caption := '......';
 if not fn_determine_appdir then
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
