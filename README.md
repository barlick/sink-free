Sink.exe: A free very simple folder syncing application for Windows.
Tested on Windows 8, Windows 10 and Windows 11.
By Barlick. Last update 25/10/2025.
          
Simply copy "Sink.exe" to the folder of your choice e.g. "Documents" and run it - That's it as far as "installation" goes.

Here's the documentation:

This "Sink" app can sync files between multiple source and target folders which are defined via the "Configuration" tab.

If you defined just one source and target folder:

Source: i:\data\ Target: e:\data\
          
Then it would work through all files present in i:\data\ and all sub-folders within i:\data\ and check to see if they were present in e:\data\ or the relevant e:\data\ sub-folder.
          
If a file is found that is present in a source folder but isn't present in the corresponding target folder then it will be copied from the source folder to the target folder.
          
It does not have the ability to check file sizes or timestamps so can't detect changes in the source files. It's just a simple "does this source filename exist in the target folder or not?" check.
          
It has no ability to delete files in the target folders, so deleting a file in a source folder will NOT cause that file to be deleted from the target folder when Sink.exe is run.
          
The copy process uses a .tmp temporary file extension for the target file which is renamed to the correct file extension if the copy process is successful.
          
This allows the process to automatically detect failed/interrupted runs that have left incomplete files in the target folders and deal with them.
          
Any files copied to the target folders will be listed in the activity log window in the "Home" tab.

Click "Start" to start the process. That's it.

I use "Sink" on my PCs which have external backup drives to ensure that they keep a copy of all of the files on my home server.
So as new files are added to my server, I periodically run Sink on my PCs (manually at the time of my choosing and usually about once a week) to ensure that they have a full backup which contains those new files.
It's very quick to run as it only copies new files from the server and ignores the files that are already present on the backup drives.
I've been using it for years and it hasn't let me down (yet!).

There are many much more sophisticated "file syncing"/"backup" applications and I've tried several of them but they are all quite complicated (because they can do a lot more than "Sink") so they require extensive configuration and testing.
I wasn't prepared to spend the time to work through their extensive documentation to get them working so hence I just use "Sink" because it's simple and it does everything I want.
If this sounds like you(!), then give Sink a go. It will only take five minutes of your time to work out whether or not it will satisfy your backup/folder syncing requirements.
If it does, then use Sink. If it doesn't then please delete Sink.exe and use something else!

Cheers - Barlick.
