unit sinkmain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, ImgList, Grids, Buttons, cxControls, cxContainer, cxEdit,
  cxProgressBar, jpeg, pngimage;

type
  source_and_target_rec = record
   sourcefolder : string;
   targetfolder : string;
  end;

  Tsinkmainform = class(TForm)
    PageControl1: TPageControl;
    DocumentationTabSheet: TTabSheet;
    Memo1: TMemo;
    HomeTabSheet: TTabSheet;
    ConfigurationTabSheet: TTabSheet;
    ImageList1: TImageList;
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
    ProgressBarBR: TcxProgressBar;
    Panel1: TPanel;
    StartButton: TBitBtn;
    ActivityLogMemo: TMemo;
    Stopbutton: TBitBtn;
    LabelTE: TLabel;
    LabelTR: TLabel;
    LabelTET: TLabel;
    LabelTRT: TLabel;
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
  private
    { Private declarations }
    source_and_target_array : array of source_and_target_rec;
    source_and_target_array_count : integer;
    master_filesize : int64;
    abort : boolean;
    PT1,PTL : TDateTime;
  public
    { Public declarations }
    procedure load_ini_settings;
    procedure save_ini_settings;
    procedure fill_in_SourceAndTargetFoldersStringGrid;
    function fn_SourceAndTargetFoldersStringGrid_has_changed : boolean;
    procedure run_process;
    procedure sIncProgress(numw : longint);
  end;

var
  sinkmainform: Tsinkmainform;

implementation

{$R *.dfm}

uses dhpstrutils,shlobj,activex,PBFolderDialog;


function DelimitPath(PathIn : string) : string;
begin
 Result := PathIn;
 if PathIn <> '' then
  if PathIn[Length(PathIn)] <> '\' then
   Result := PathIn + '\';
end;

function GetLocation(Folder: DWord): String;
// Very useful function for retrieving windows paths.
// Couple of examples :
// Desktop call : GetLocation(CSIDL_DESKTOP)
// Programs (ie Start Menu/Programs) call : GetLocation(CSIDL_PROGRAMS)
// My Documents call : GetLocation(CSIDL_PERSONAL)
//
// Full List of tags
//
// History                CSIDL_HISTORY
// Desktop                CSIDL_DESKTOP
// My Documents           CSIDL_PERSONAL
// My Computer            CSIDL_DRIVES
// My Network Places      CSIDL_NETWORK
// Internet Cache         CSIDL_INTERNET_CACHE
// Cookies                CSIDL_COOKIES
// Windows Directory      CSIDL_WINDOWS
// System Directory       CSIDL_SYSTEM
// Program Files          CSIDL_PROGRAM_FILES
// My Pictures            CSIDL_MYPICTURES
// Common Files           CSIDL_PROGRAM_FILES_COMMON
// Common Documents       CSIDL_COMMON_DOCUMENTS
// User application date foldeer: CSIDL_APPDATA
//
// Note : You will need to put "ShlObj" in your uses clause since the CSIDL_
//        bits come from there.
var
 PIDList: PItemIDList;
 Buf: array[0..MAX_PATH] of Char;
 Malloc: IMalloc;
begin
 if SHGetSpecialFolderLocation(Application.Handle, Folder, PIDList) <> NOERROR then
  Dialogs.MessageDlg('Unable to find folder', mtError, [mbOk], 0);
 if SHGetPathFromIDList(PIDList, Buf) then
  Result := StrPas(Buf);
 if (SHGetMalloc(Malloc) = NOERROR) then
  Malloc.Free(PIDList);
 Result := DelimitPath(Result);
end;

function BrowseFolderDlg(StartFolder : string) : string;
var
 FolderDlg : TPBFolderDialog;
begin
 Result := StartFolder; // return the folder we started with.
 FolderDlg := TPBFolderDialog.Create(Application);
 try
  FolderDlg.Flags := [ShowPath, EditBox, IncludeURLs, UsageHint, Validate];
  // check if a valid start folder was passed
  if DirectoryExists(StartFolder) then
   FolderDlg.Folder := StartFolder
  else
   FolderDlg.Folder := GetLocation(CSIDL_PERSONAL); // default to my documents if path is invalid.
  // fire up the dialog
  if FolderDlg.Execute then
   begin
    Result := FolderDlg.SelectedFolder;
    // appears to miss '\' out on the end, so add it in
    if Length(Result) > 0 then
     if Result[Length(Result)] <> '\' then
      Result := Result + '\';
   end;
 finally
  FolderDlg.Free;
 end;
end;

procedure Tsinkmainform.sIncProgress(numw : longint);
var
 T : TDateTime;
 throughput,numsec : double;
 throughputstr : string;

function NumberOfSeconds(tim: TDateTime): double;
var H,m,s,l: word;
begin
 DecodeTime(tim,h,m,s,l);
 result := s + (m * 60) + (h * 3600);
end;

begin
 ProgressBarBR.Position := ProgressBarBR.Position + numw;

 PTL := now;
 T := PTL - PT1;
 LabelTET.Caption := FormatDateTime('hh:mm.ss', T); // Time elapsed.
 // So ProgressBarBR.Position = number of bytes written and "T" is the elapsed time, so throughput bytes per second = ProgressBarBR.Position/T.
 if T > 0  then
  begin
   numsec := NumberOfSeconds(T);
   if numsec > 0 then
    begin
     throughput := ProgressBarBR.Position; // Bytes written.
     throughput := throughput/1024; // 1024 = kilo bytes.
     throughput := throughput/1024; // 1024 = Mega bytes.
     throughputstr := ' Read+Write Speed '+sr(throughput/numsec,12,1) + ' MB/s';
    end;
  end
  else
  begin
   throughputstr := '';
  end;

 if ProgressBarBR.Position > 0 then
  begin
   T := (PTL - PT1) * (1 - ProgressBarBR.properties.Max / ProgressBarBR.Position);
  end
  else T := 0;
 LabelTRT.Caption := FormatDateTime('hh:mm.ss', T) + throughputstr; // Time remaning + Throughout

end;

procedure Tsinkmainform.run_process;
var
 sourcefolder,targetfolder : string;
 dtop : string;
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
 if foldername = '' then foldername := '\';
 if copy(foldername,length(foldername),1) <> '\' then foldername := foldername + '\';
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
 propertofile,origfileext,killfile : string;
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
 ct := 0;
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
   renamefile(tofile,propertofile);
  end
  else // Didn't work - kill the duff target file.
  begin
   deletefile(tofile);
  end;
 if ioresult = 0 then begin end;
 {$I+}
end;

procedure scanforfiles(scanmode : integer; startpath : string);
var
 mySearchRec : sysutils.TSearchRec;
 ReturnValue : integer;
 s : string;
 doit : boolean;
begin
 {$I-}
 try
  ReturnValue:=FindFirst(startpath+'*.*',faAnyFile,mysearchrec);
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
     scanforfiles(scanmode,startpath+mysearchrec.name+'\');
    end
    else if (mySearchRec.Attr and faDirectory = 0) and
            (pos('THUMBS.DB',uppercase(mySearchRec.name)) = 0) and
            (pos('INDEXERVOLUMEGUID',uppercase(mySearchRec.name)) = 0) then
    begin
     application.processmessages;
     doit := false;
     s := stringreplace(startpath+mysearchrec.name,sourcefolder,targetfolder,[rfreplaceall,rfignorecase]);
     if not fileexists(s) then doit := true;
     // Danny 10-8-2023:
     // Apparently delphi "assignfile" has a limit of 259 char limit so can't do those...
     if length(startpath+mysearchrec.name) > 258 then doit := false;
     if length(s) > 258 then doit := false;
     if doit then
      begin
       // Copy: startpath+mysearchrec.name to "s":
       if scanmode = 0 then // Scan only...
        begin
         pathlabel.caption := 'Scanning Folder: '+startpath;
         filenamelabel.caption := 'Scanning File: '+mysearchrec.name;
         application.processmessages;
         master_filesize := master_filesize + mysearchrec.Size;
        end
        else
        begin
         pathlabel.caption := 'Coping From: '+startpath;
         filenamelabel.caption := 'Coping File: '+mysearchrec.name;
         application.processmessages;
         if fn_make_and_test_folder(extractfilepath(s)) then
         begin
          if fn_optimacopyfile(startpath+mysearchrec.name,s) then;
          ActivityLogMemo.Lines.Add('Copied "'+mysearchrec.name+'"');
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

procedure sync_folders(scanmode : integer; sourcefolder,targetfolder : string);
begin
 pathlabel.caption := 'Scanning: '+sourcefolder;
 filenamelabel.caption := '';
 scanforfiles(scanmode,sourcefolder);
end;

begin
 abort := false;
 ActivityLogMemo.Clear;
 progressbarbr.visible := false;
 LabelTET.Caption := '......';
 LabelTRT.Caption := '......';
 PT1 := now;
 try
  master_filesize := 0;
  if source_and_target_array_count > 0 then
   begin
    pass := 0;
    while (pass <= 1) and not abort do
     begin
      if pass = 1 then
       begin
        ProgressBarBR.Position := 0;
        ProgressBarBR.properties.Max := master_filesize;
        progressbarbr.visible := true;
       end;
      ct := 0;
      while (ct < source_and_target_array_count) and not abort do
       begin
        sourcefolder := source_and_target_array[ct].sourcefolder;
        targetfolder := source_and_target_array[ct].targetfolder;
        if pass = 0 then
         begin
          ActivityLogMemo.Lines.Add('Scanning source folder "'+sourcefolder+'".');
          ActivityLogMemo.Lines.Add('Comparing with target folder "'+targetfolder+'".');
         end;
        sync_folders(pass,sourcefolder,targetfolder);
        inc(ct);
       end;
      inc(pass);
     end;
   end;

  dtop := GetLocation(CSIDL_DESKTOP); // Local...
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

procedure Tsinkmainform.fill_in_SourceAndTargetFoldersStringGrid;
var
 ct : integer;
 sourcefolder,targetfolder : string;
begin
 SourceAndTargetFoldersStringGrid.rowcount := 2;
 SourceAndTargetFoldersStringGrid.cells[0,0] := 'Source Folders';
 SourceAndTargetFoldersStringGrid.cells[1,0] := 'Target Folders';
 SourceAndTargetFoldersStringGrid.cells[0,1] := '';
 SourceAndTargetFoldersStringGrid.cells[1,1] := '';
 if source_and_target_array_count > 0 then
  begin
   ct := 0;
   while ct < source_and_target_array_count do
    begin
     if ct > 0 then SourceAndTargetFoldersStringGrid.rowcount := SourceAndTargetFoldersStringGrid.rowcount + 1;
     sourcefolder := source_and_target_array[ct].sourcefolder;
     targetfolder := source_and_target_array[ct].targetfolder;
     SourceAndTargetFoldersStringGrid.cells[0,ct+1] := sourcefolder;
     SourceAndTargetFoldersStringGrid.cells[1,ct+1] := targetfolder;
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
     ct := ct + 1;
    end;
   // Now delete last row.
   SourceAndTargetFoldersStringGrid.cells[0,SourceAndTargetFoldersStringGrid.rowcount -1] := '';
   SourceAndTargetFoldersStringGrid.cells[1,SourceAndTargetFoldersStringGrid.rowcount -1] := '';
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
 s,appdatafolder,sourcefolder,targetfolder : string;
 f : textfile;
begin
 {$I-}
 source_and_target_array_count := 0; setlength(source_and_target_array,source_and_target_array_count);
 appdatafolder := GetLocation(CSIDL_APPDATA);
 assignfile(f,appdatafolder + 'sinkini.txt');
 reset(f);
 if ioresult = 0 then
  begin
   while not eof(f) do
    begin
     readln(f,s);
     // Is it a "[Source Folder]"? If so them MUST be followed be "[Target Folder]" line so read them both:
     if uppercase(copy(s,1,15)) = '[SOURCE FOLDER]' then
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
        end;
      end;
    end;
   end;
 closefile(f); if ioresult = 0 then;
end;

procedure Tsinkmainform.save_ini_settings;
var
 appdatafolder,sourcefolder,targetfolder : string;
 f : textfile;
 ct : integer;
begin
 {$I-}
 appdatafolder := GetLocation(CSIDL_APPDATA);
 assignfile(f,appdatafolder + 'sinkini.txt');
 rewrite(f);
 if ioresult = 0 then
  begin
   if source_and_target_array_count > 0 then
    begin
     ct := 0;
     while ct < source_and_target_array_count do
      begin
       sourcefolder := source_and_target_array[ct].sourcefolder;
       targetfolder := source_and_target_array[ct].targetfolder;
       if (sourcefolder <> '') and (targetfolder <> '') then
        begin
         writeln(f,'[Source Folder]'+sourcefolder);
         writeln(f,'[Target Folder]'+targetfolder);
        end;
       inc(ct);
      end;
    end;
  end;
 closefile(f); if ioresult = 0 then;
end;

procedure Tsinkmainform.ApplyChangesBitBtnClick(Sender: TObject);
var
 ct : integer;
 sourcefolder,targetfolder : string;
begin
 // Transfer grid to array and then save to ini.
 source_and_target_array_count := 0; setlength(source_and_target_array,source_and_target_array_count);
 ct := 1;
 while ct < SourceAndTargetFoldersStringGrid.rowcount do
  begin
   sourcefolder := SourceAndTargetFoldersStringGrid.cells[0,ct];
   targetfolder := SourceAndTargetFoldersStringGrid.cells[1,ct];
   if (sourcefolder <> '') and (targetfolder <> '') then
    begin
     inc(source_and_target_array_count); setlength(source_and_target_array,source_and_target_array_count);
     source_and_target_array[source_and_target_array_count-1].sourcefolder := delimitpath(sourcefolder);
     source_and_target_array[source_and_target_array_count-1].targetfolder := delimitpath(targetfolder);
    end;
   inc(ct);
  end;
 save_ini_settings;
 fill_in_SourceAndTargetFoldersStringGrid;
end;

function Tsinkmainform.fn_SourceAndTargetFoldersStringGrid_has_changed : boolean;
var
 ct : integer;
 sourcefolder,targetfolder : string;
begin
 result := false;
 if source_and_target_array_count = SourceAndTargetFoldersStringGrid.rowcount-1 then
  begin
   ct := 1;
   while (ct < SourceAndTargetFoldersStringGrid.rowcount) and not result do
    begin
     sourcefolder := SourceAndTargetFoldersStringGrid.cells[0,ct];
     targetfolder := SourceAndTargetFoldersStringGrid.cells[1,ct];
     if (source_and_target_array[ct-1].sourcefolder <> sourcefolder) or
        (source_and_target_array[ct-1].targetfolder <> targetfolder) then
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
begin
 pathlabel.caption := ''; filenamelabel.caption := ''; progressbarbr.visible := false; ActivityLogMemo.Clear; stopbutton.visible := false; startbutton.Visible := true;
 LabelTET.Caption := '......';
 LabelTRT.Caption := '......';
 load_ini_settings;
 fill_in_SourceAndTargetFoldersStringGrid;
end;

procedure Tsinkmainform.StartButtonClick(Sender: TObject);
begin
 // OK: Go:
 startbutton.Visible := false; stopbutton.visible := true; configurationtabsheet.Enabled := false; documentationtabsheet.Enabled := false;
 try
  run_process;
 finally
  stopbutton.visible := false; startbutton.Visible := true; configurationtabsheet.Enabled := true; documentationtabsheet.Enabled := true;
 end;
end;

procedure Tsinkmainform.StopbuttonClick(Sender: TObject);
begin
 abort := true;
end;

end.
