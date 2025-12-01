SINK APPLICATION DESCRIPTION:

Sink: A free and easy to use file and folder backup/sync application. Last update 28/11/2025.

Sink is a free and open source cross platform (Windows, Mac and Linux) application.

Sink was coded by and is maintained by: Barlick.
Sink uses parts of the Synapse SMTP & OpenSSL Free Pascal source which is distributed under the BSD Licence to implement the Sink Email Notification capability.

It can be used by anyone but was primarily designed for home and small business users especially those using a locally hosted sever or NAS that need to backup and sync files between local PCs and the sever or NAS.

Sink is designed to be as simple as possible to setup, test and use without having to pay for a commercial backup solution and/or spend hours studying manuals to get your backup processes working.

![[home_screen.png]]

KEY FEATURES:

• 	Sink can run on Windows, Mac and Linux systems and is free and open source.

• 	Each Sink instance on a given PC/server has its own Jobs configuration so each server/PC can backup/sync only the folders relevant to that PC/server.

• 	There is no limit on the number of Sink Jobs that can be configured. Jobs are run in the order in which they were added to the Sink Job Configuration i.e. “top to bottom”.

• 	There is a choice of copy modes (per Job definition): 1: “Copy files from the Source folder that are not present in the Target folder” this is the default and is ideal for simple backup jobs such as copying any new video files that have been added to a source drive to a backup target drive because “video” files don’t change, they either exist on the backup drive or they don’t in which case they will be copied over. 2: “Copy files from the Source folder that are not present in the Target folder OR have been changed in the Source folder” this does the same but will also re-copy files from the source drive that have been changed e.g. a spreadsheet that has been updated regardless of whether than spreadsheet already exists on the target drive so that’s recommended for folders that contain files that DO change over time.

• 	Delete files. This is optional (per Job definition) and is disabled by default. If is IS enabled for a given Job then it will remove any files (and optionally also any folders) that exist on the target/backup drive that no longer exist on the source drive.

• 	Target disk free space checking. This is optional and if enabled then Sink will check the free disk space available on the target drive prior to running a given Job. This prevents Sink from attempting to run that Job if it thinks there’s not enough space on the target drive to complete the file backup/copy operation.

• 	Scheduler: This is optional and is disabled by default. If it’s enabled then you can configure the Sink instance to either run its configured Jobs at system startup + x minutes and/or at specified times for specified days of the week.

• 	Email Notifications: This is optional and is disabled by default. If it’s enabled then you can configure the Sink instance to send Jobs run “success” or “errors occurred” type emails on specified days of the week and also optionally attach the relevant Sink Log file.

• 	Logging: Sink maintains simple human readable text based Log files for each new day and will automatically delete Log files older that a specified number of days. You can also view the Log files from the Sink, Tools menu.

• 	The Sink Configuration for each Sink instance can be exported to a .txt file and re-imported as required via the Sink, Tools menu.

SIMPLE EXAMPLE SINK CONFIGURATION:

This example is based on an imaginary setup consisting of a server and a desktop Windows PC with an external HDD.
The objective is to run Sink on the desktop Windows PC and to configure it to backup a couple of folders on the server to a backup folder on the PC’s external HDD.

The server is mapped to the desktop PC as “i:” (drive “I”). The server has an “i:\Video” and an “i:\TV” folder both containing video files and we want to back those up to the desktop PC’s external drive “D” as “d:\backup\Video\” and “d:\backup\TV\”.

1: Copy the “sink.exe” file to the desktop PC’s “Documents” folder (please feel free to change that to a different folder if you want).
2: Run sink.exe on your desktop PC. NOTE: Windows may complain so tell it to “Run Anyway”...
3: Go to the Sink “Jobs Configuration” tab. NOTE: Please read the “Jobs Configuration Tab detailed information” section if you aren’t sure how to define Sink Jobs.
4: Initially no Jobs will be defined so to set up the fist “Job” you just need to set the “Source Folder” to “i:\Video\” and the “Target Folder” to “d:\backup\Video\”. You can leave the “Mode” as the default “Copy files from the Source folder that are not present in the Target folder” and leave “Delete files from the Target folder that are no longer present in the Source folder after syncing Source and Target folders?” check box option unticked (disabled).
NOTE: The “Delete files from the Target folder that are no longer present in the Source folder after syncing Source and Target folders?” check box option will only be visible if the “Allow Sink to delete files from target folders?” check box option is enabled in Sink, Preferences, General Settings.
5: Click “Apply Changes” – The first “Job” is now defined and saved.
6: Click “New”. This will add a new Job.
7: Set the “Source Folder” to “i:\TV\” and the “Target Folder” to “d:\backup\TV\”. Leave the “Mode” as the default “Copy files from the Source folder that are not present in the Target folder” and leave “Delete files…” OFF.
8: Click “Apply Changes” – The second “Job” is now defined and saved.

That’s it. That configuration has been saved to a “sinkini.txt” file in (typically) your “c:\Users\<your windows username>\AppData\Local\sink\” folder which will be read when Sink next starts up.

To test that this Jobs configuration actually works, you would just need to go to the Sink, Home tab and click the “Start Jobs” button.
That will work through all files in i:\Video\ (and all sub-folders under i:\Video\) and for each file detected, it will check to see if it’s present in d:\backup\Video\. If it’s not present then it will copy it to d:\backup\Video\.
It will then go on to the second Job which will work through all files in i:\TV\ (and all sub-folders under i:\TV\) and for each file detected, it will check to see if it’s present in d:\backup\TV\. If it’s not present then it will copy it to d:\backup\TV\.
You will see a progress bar showing you the total size of all files that need to be copied (for BOTH Jobs) as well as an “estimated time remaining” etc.
Once both Jobs have been completed it will display “Finished” in the Home Tab’s Activity Log window and also show you the “Stats” including the total number of files copied etc.

If you then go and look at the d:\backup\ folder you should find that all of the i:\Video\ and i:\TV\ files are now present in that d:\backup\ folder.

You could then try deleting a random file from your d:\backup\Video folder and then click “Start Jobs” again. Sink should detect that the file you deleted is present in i:\Video\ but no longer present in d:\Video\ so should re-copy that file back into d:\backup\Video\ (and no other files).

That’s all you would need to do if you just need a simple file backup process that copies over only new files added to your source drives/folders.

You can “enhance” this quite a bit, so for reference here is the:

EXAMPLE OF MY CURRENT SINK SETUP:

In my use case, I have the following setup:

• 	A “Home-lab” consisting of a primary TrueNas Linux ZFS file server and an “always on” Windows NUC PC server with an external HDD which needs to contain an exact copy of the primary NAS drive contents. The TrueNas server is about 10 years old so is likely to fail at some point(!) so it’s essential to have a fully working backup of all of its files on the Windows NUC PC server’s external drive.

• 	Two Windows desktop PCs with external HDDs which require up to date copies of specific NAS folders.

• 	A Linux desktop PC which requires its home folder backing up to the NAS.

To manage that I have Sink installed on the Windows NUC PC which is configured to run its Sink Jobs on a schedule which is at 3:00am each morning to automatically keep the NUC PC’s external HDD contents fully up to date and matching the files on the primary TrueNas server. All of its Jobs are configured to use the Mode “Copy files from the Source folder that are not present in the Target folder OR have been changed in the Source folder” and “Delete files…” is also enabled. That ensures that its Jobs target folders should always match the source TrueNas folders and reflect any files that have been added, changed or deleted on the TrueNas server. It is also configured to send email notifications when Sink Jobs have been successfully completed but only once a week just so that I know it’s working and also if any errors occur in which case the relevant Sink Log file is attached so that I can see what caused the problem. It will send error type emails on any day of the week as and when they occur.

The two Windows desktop PCs are configured to run their configured Sink Jobs at Windows startup + 5 minutes. I use that 5 minutes “breathing room” to check for Windows updates etc. and I can cancel the Sink Jobs run if Windows indicates that it requires a reboot to complete its updates. I can also choose to run the Sink Jobs later if I’m in a hurry and need to do something urgently that requires the full resources of the PC although this isn’t normally an issue as Sink Jobs runs are quite well behaved and don’t hog too many system resources so I don’t really notice when it’s running.

The Linux desktop PC is also configured to run its Sink Jobs automatically at Linux startup + 5 minutes to ensure that my home folder is safely backed up to a folder on the TrueNas server. As it’s a Linux system I had to create a mount point for the TrueNas server and ensure that I had the correct read/write permissions etc. I assume that Linux users will know how to do this(!) so I don’t intend to explain that here.

Also, one of the folders on the TrueNas server is a Google Drive backup so I handle that slightly differently.
One of the desktop Windows PCs is configured to run Google Drive in “local file storage” mode so it ensures that it always has actual copies of all my files currently in the Google Drive cloud in a folder on its C drive.
So on that PC I have a Sink Job that copies all files from its C Google Drive folder to a \backup\GoogleDrive\ folder on the TrueNas server and I use the Mode “Copy files from the Source folder that are not present in the Target folder OR have been changed in the Source folder” to ensure that any files added or changed in my Google Drive get copied up to the TrueNas server \backup\GoogleDrive\ folder but I set the Job’s “Delete files…” option OFF (disabled). The reason for that is to ensure that once a file has been copied to to \backup\GoogleDrive\ but is subsequently deleted from Google Drive a copy of it will remain in \backup\GoogleDrive\. That’s useful because it means that I can keep my Google Drive storage very low by periodically deleting files and folders from it that I don’t actually need to be available on my current Google Drive but I keep copies of all of the files that were deleted in the TrueNas \backup\GoogleDrive folder.

So that’s what I use Sink for and I’ve got it configured to handle all of my backup requirements automatically without me having to do anything. I’ve also got the Windows NUC server sending me Sink notification emails occasionally so that I know it’s running smoothly without me having to log in and check it constantly.

It works for me so hopefully you should be able to get it to do the same for you. It only takes a few minutes to rig up a test so you can quickly assess whether Sink is likely to be of use to you.

OK, detailed Sink information follows:

HOME TAB DETAILED INFORMATION:

The Home tab has an “Activity Log Window” which details all activity performed by Sink when running its Jobs.
It also has a Status information panel at the bottom of the screen which tells you what state Sink is in.
It also has a “Start Jobs” button which will run the Sink Jobs defined in the “Jobs Configuration” tab when you click it.
When it’s running you can click the “Stop Jobs” button to stop the process. Sink is designed to be interruptible so you can always stop Sink from running (or close the Sink application) safely at any time.
If you are using the Sink, Preferences, “Scheduler” options then you will also see “Cancel Scheduled Job Run” and “Resume Scheduled Job Run” buttons which are used to take sink in and out of “Scheduled Run Mode”.

JOBS CONFIGURATION DETAILED INFORMATION:

The Jobs Configuration tab has a grid showing all of the currently defined Sink Jobs and an “edit currently selected Job details” panel at the bottom of the screen.

There is no limit on the number of Sink Jobs that can be configured. 

Sink Jobs are run in the order in which they were added to the Sink Job Configuration grid i.e. “top to bottom”.

The “edit currently selected Job details” panel shows you the settings for the currently selected Sink Job. You can click on a Job row in the grid or use the up and down arrow keys to select an existing Job if you need to edit it. If no Jobs are defined as is the case when Sink is first run then the “edit currently selected Jobs details” panel will show blank source and target folder paths and default values for the “Mode” and “Delete files…” options.

The “edit currently selected Job details” panel allows you to set the “Source Folder” and “Target Folder” paths for the currently selected Sink Job. You can either type or paste the required folder path values directly into the relevant text boxes or use the browse folder buttons on the right to select them via the folder select pop-up window.

NOTE: The Sink Source and Target folder paths also accept UNC folder paths e.g. “\\myserver\files\Media\Video\” or “\\192.168.1.193\Media\Video\”.

NOTE: Because Sink can delete files and folders from Job target folders (if the “Allow Sink to delete files from target folders?” and “Allow Sink to delete redundant folders from target drives/folders?” Preferences, General Settings options are enabled) it’s possible for a conflict to arise that would prevent Sink from working safely.

For example: If you had a Job with a source folder defined as “i:\Video\” and a target folder defined as “d:\backup\Video\” and a second job with a source folder defined as “i:\TV\” and a target folder defined as “d:\backup\” and clicked “Apply Changes” then you would see this error message:

“Error: The Specified Target folders: d:\backup\Video\ and d:\backup\ are in conflict. All specified Target folders must be unique and not be a sub-folder of another Target folder. Please correct this and re-apply your changes.”

This is difficult to explain(!) but the reason for this error is that when Sink runs the first Sink Job it would see all source files in “i:\Video\” and then see if they exist in “d:\backup\Video\” any files present in the source folder but not present in the target folder would be copied over to “d:\backup\Video\” - No problem.
But when Sink runs the second Sink job then it would see all source files in “i:\TV\” and then see if they exist in “d:\backup\” any files present in the source folder but not present in the target folder would be copied over to “d:\backup\” but it would then scan for any files that AREN’T present in the source folder “i:\TV\” but ARE present in “d:\backup\” and delete those files from “d:\backup\” so it would delete the contents of the “d:\backup\Video\” folder that were copied over by the first Sink Job because those files aren’t present in “i:\TV\” so that would negate the work done by the first Sink Job.

To resolve this you should simply change the target folder of the second Sink Job to “d:\backup\TV\”. Sink would then be satisfied that no possible target folder conflicts exist.

The “edit currently selected Job details” panel allows you to set the file copy “Mode” for the currently selected Sink Job. 
There is a choice of two copy Modes: 
1: “Copy files from the Source folder that are not present in the Target folder” this is the default and is ideal for simple backup jobs such as copying any new video files that have been added to a source drive to a backup target drive because “video” files tend not to change, they either exist on the backup drive or they don’t in which case they will be copied over. 
2: “Copy files from the Source folder that are not present in the Target folder OR have been changed in the Source folder” this does the same as #1 but will also re-copy files from the source drive that have been changed e.g. a spreadsheet that has been updated regardless of whether than spreadsheet already exists on the target drive so that’s recommended for folders that contain files that DO change over time.

The “edit currently selected Job details” panel allows you to set the “Delete files from the Target folder that are no longer present in the Source folder after syncing Source and Target folders?” check box option for the currently selected Sink Job. 
NOTE: The “Delete files from the Target folder that are no longer present in the Source folder after syncing Source and Target folders?” check box option will only be visible if the “Allow Sink to delete files from target folders?” check box option is enabled in Sink, Preferences, General Settings.
If you tick (enable) the “Delete files from the Target folder that are no longer present in the Source folder after syncing Source and Target folders?” then Sink will remove any files (and optionally also any folders if that option is enabled in Sink, Preferences, General Settings) that exist on the target/backup drive that no longer exist on the source drive.
You only need to enable the “Delete files from the Target folder that are no longer present in the Source folder after syncing Source and Target folders?” option for a given Sink Job if you need to maintain an exact copy of the Job’s source folder in the Jobs’s target folder which reflects any files (or sub folders) that have been deleted from the source folder since the last time the Sink Job was run.

The “edit currently selected Job details” panel has a “New” button to allow you to add a new Sink Job definition and a “Delete” button to allow you to delete the currently selected Sink Job.

The “edit currently selected Job details” panel also has “Apply Changes” and “Discard Changes” buttons which are automatically enabled when you make any changes to a Sink Job. If you click “Apply Changes” then all changes made to any of your Sink Jobs will be saved to the “sinkini.txt” Sink configuration file in (typically) your “c:\Users\<your windows username>\AppData\Local\sink\” folder which will be read when Sink next starts up. 
If you click the “Discard Changes” button then any changes made to your Sink Jobs configuration will be discarded.

PREFERENCES TAB DETAILED INFORMATION:

GENERAL SETTINGS:

The “Allow Sink to delete files from target folders?” check box option is disabled (unticked) by default. If you enable (tick) it then the “Delete files from the Target folder that are no longer present in the Source folder after syncing Source and Target folders?” check box option will become visible in the Jobs configuration “edit currently selected Job details” panel.
If you enable (tick) the “Delete files from the Target folder that are no longer present in the Source folder after syncing Source and Target folders?” for a given Sink Job then Sink will remove any files and optionally also any folders if the “Allow Sink to delete redundant folders from target drives/folders?” option is enabled that exist on the target/backup drive that no longer exist on the source drive.
You only need to enable the “Delete files from the Target folder that are no longer present in the Source folder after syncing Source and Target folders?” option for a given Sink Job if you need to maintain an exact copy of the Job’s source folder in the Jobs’s target folder which reflects any files (or sub folders) that have been deleted from the source folder since the last time the Sink Job was run.

The “Allow Sink to delete redundant folders from target drives/folders?” option is only relevant if the “Allow Sink to delete files from target folders?” check box option is enabled.
If you enable (tick) the “Allow Sink to delete redundant folders from target drives/folders?” option and the “Allow Sink to delete files from target folders?” check box option is ALSO enabled, then Sink will delete any redundant folders from the target folder of a given Sink Job definition when it that Job is run.
This is a separate option because it’s possible that you are happy to delete unwanted files from target folders but want to maintain the source folder’s directory structure on the target drive even if there are no longer any files present in those folders.

The “Allow Sink to run disk free space checks on target drives/folders?” option is disabled (unticked) by default. If you enable it, then Sink will attempt to check the amount of free disk space on a Job’s target drive/folder before attempting to copy any files to it. The initial Job “scan phase” tells Sink the total size of all files that it thinks it needs to copy for this Job so if the free disk space on the target drive/folder is less than the amount of free disk space available (minus the minimum percentage of free disk space that must remain safety margin) then it won’t run that job and will report an error in the Home, Activity Log window and tell you how much disk space would need to be freed up to allow the Job to complete successfully.
My tests indicate that this works OK and should prevent Sink from completely filling up a target/backup drive so it’s safe to enable disk free space checking in most situations.

The “Percentage of minimum free disk space required on target drives/folders below which the disk free space checks will not permit a copy operation” is only relevant if the “Allow Sink to run disk free space checks on target drives/folders?” option is enabled. It defaults to 5% which should be a reasonable default value but you can always change it. 
If we had a target/backup drive with a total capacity of 1Tb and the “Percentage of minimum free disk space required on target drives/folders below which the disk free space checks will not permit a copy operation” is set to 5% then Sink would check that any Job file copy operation would leave at least 5% free space on that drive after the copy operation completed i.e. ~52Gb minimum free disk space.
For external HDD backup drives it’s probably “safe” to drop the minimum to 1% free but it’s generally advised to maintain a higher free disk space % on servers especially RAID based servers as they lose efficiency when free disk space is below 10% (apparently) but please check this for yourself as this may or may not be an issue for your server.

The “Maximum No. of retries allowed within the "set target file date + time file stamp" process” defaults to 10. The retry process is occasionally necessary when copying files over to target/backup drives using Windows because (I think) “Windows Defender” (or whatever AV software you are using) may temporarily place a new file in quarantine for a few seconds whilst it scans it so it’s possible the the “set file date + time stamp” process may not be allowed to complete until that’s done so hence the need for this retry capability. It does seem to work OK so I suggest you leave this set to 10.

The “Sleep time (milliseconds 1000 = 1 second) between retries within the "set target file date + time file stamp" process” defaults to “1000” (1 second) and is used by the set file date + time stamp retry process (see above). 1 second seems to be a sensible default but you can always increase it if Sink reports any issues setting the file date + time file stamps during Job file copy operations.

The “Delete Sink log files older than this many days” option defaults to 30 days. When sink completes a Job run it will check the current date and see if there’s an existing Sink Log file (usually) in the “c:\Users\<your windows username>\AppData\Local\sink\” folder e.g. “sinklogfile_2026-01-30.txt” if Sink was run on the 30th January 2026. If there is an existing Sink Log file for that day then it will append the contents of the Home Activity Log window to that existing Sink Log file otherwise it will create a new Sink Log file for today’s date and copy the Home Activity Log window contents to that new Sink Log file.
That works well and Sink Log files tend not to be too big (a few MB at most in my experience) but this “Delete Sink log files older than this many days“ setting is used by Sink after it has written out a Sink Log file update to delete any Sink Log files older that the specified number of days. 

This prevents Sink from eating up a significant amount of disk space for its Log files. Personally I do not like applications that generate Log files (or any other unused/unwanted/unnecessary files) without a clear automatic method of purging them so this is why this option exists within Sink to ensure it’s well behaved in that regard.

Any changes made to the Sink General Settings settings can be saved by clicking the “Apply Changes” button or discarded by clicking the “Discard Changes” button.

SCHEDULER:

By default Sink requires the user to launch the Sink application and then click the Home, “Start Jobs” button to run Sink Jobs manually but Sink also has a “Scheduler”. The Sink scheduler is optional and can be used to automate when Sink Jobs are run.

If you intend to use the Sink Scheduler then it will be necessary for you to configure your PC/Server to launch Sink automatically after the system has started up.

To do this in Windows, the simplest method is this:

Launch the “Run” window by either clicking Windows+R or clicking “Start” and typing and selecting “Run” from the start menu.

In the “Run” window’s “Open:” text box, type: shell:startup

Press enter and Windows will open the Startup folder in Windows Explorer. Typically this is “c:\Users\<your windows username>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\”.

Right click in that folder and select “New”, “Shortcut”.

In the “Create Shortcut” dialogue window click “Browse” and select “Sink.exe” from whichever folder you copied Sink.exe into (I just use “Documents” but you can put it anywhere you want).

Click “Next” and give the shortcut a suitable name e.g. “sink.exe” and then click “Finish”.

If you then re-boot you should find that Sink starts up automatically after Windows has booted and completed its various startup/initialisation processes. So it’s not instantaneous but usually comes up after a minute or two depending on the speed of your PC/Server and the complexity of it’s startup/initialisation processes.

To do this in Linux you have various options depending on the specific distribution you are using. I assume that Linux users are quite savvy and will be able to work this out for themselves(!).

Here is a description of the various Sink Scheduler options:

The “Run all jobs automatically using the jobs scheduler settings defined below?” check box option is the main control switch that enables or disables the Sink Scheduler. If this is disabled (unticked) then Sink will not use the scheduler so you must enable (tick) this option in order to use the Sink Scheduler.

The “Start the Sink application in Minimized mode if using the jobs scheduler?” check box option is disabled (unticked) by default. If you do enable it and Sink is configured to use the Scheduler (see above) then Sink will attempt to run in “Minimized” window mode after starting up. This appears to work OK in Windows but I’m seeing mixed results when using this option In Linux – I will try to improve this (honest!) but be advised that this option may not work in Linux.

The “Run the jobs scheduler on these days” Monday to Sunday check boxes tell the Sink Scheduler on which days it’s allowed to run Scheduled Sink Job runs. This applies to both scheduled “Run Sink jobs on Sink startup” and also scheduled Sink Job runs at specified “Scheduler run times” (see below). Typically you would want to run this for every day of the week but you might only want to run it on specific days depending on your Jobs configuration and the requirements of the PC/server that Sink is running on so that’s why I included this option.

The “Run jobs on Sink startup?” check box option is disabled (unticked) by default. If you enable (tick) it then Sink will run all Sink Jobs after x minutes delay (see below) when Sink starts up. This is typically used by desktop PCs or Laptops to ensure that Sink will run all Sink Jobs after a few minutes whenever the PC or Laptop boots up each day.

The “Delay (minutes) before running the jobs on Sink startup” option defaults to 5 minutes and is only relevant if the “Run jobs on Sink startup?” check box option is enabled. This gives you 5 minutes of “breathing room” to check for Windows updates etc. and you can cancel the automated Sink Jobs run at startup process if Windows indicates that it requires a reboot to complete its updates. You can also choose to run the Sink Jobs later if you are in a hurry and need to do something urgently that requires the full resources of your PC/Laptop although this isn’t normally an issue as Sink Jobs runs are quite well behaved and don’t hog too many system resources so you shouldn’t really notice when it’s running.

The “Scheduler run times (note: 00:00 means not defined/enabled)” controls consist of 8 hour+minute selectors which allows you to define up to 8 different HH:MM Scheduler run times. By default these are all set to 00:00 which means that they are all “not defined/enabled” if you enter an HH:MM value in one or more of these selectors other than 00:00 e.g. “03:00” and “12:30” then those Scheduled run times are “enabled” and will be used by the Scheduler (3 am and 12:30 pm in this example).

So using all of those Scheduler options together it’s possible to configure Sink to run its Jobs automatically whenever you want it to.

As an example, my “always on” Windows NUC PC server is used to maintain a backup of my primary server and I have configured the Sink scheduler on that NUC PC as:

“Run all jobs automatically using the jobs scheduler settings defined below?” – Enabled.
“Start the Sink application in Minimized mode if using the jobs scheduler?” – Disabled.
“Run the jobs scheduler on these days” – All days Monday to Sunday enabled (ticked).
“Run jobs on Sink startup?” – Disabled.
“Delay (minutes) before running the jobs on Sink startup” - 5 minutes (not relevant as I’m not running Sink Jobs on Sink startup).
“Scheduler run times (note: 00:00 means not defined/enabled)” – 03:00 set in the first HH:MM selector, all other HH:MM selectors set to “00:00”.

So that means “use the Sink Scheduler, allow it to run on every day of the week, don’t run Sink Jobs at startup, run Sink Jobs every day at 3 am.

Hopefully that gives you enough flexibility to configure the Sink Scheduler to run your Sink Jobs whenever you want on each of your PCs, Laptops and Servers depending on their specific requirements.

Any changes made to the Sink Scheduler settings can be saved by clicking the “Apply Changes” button or discarded by clicking the “Discard Changes” button.

EMAIL NOTIFICATIONS:

Sink has the ability to send email notifications after a Sink Jobs run has completed either successfully or with errors.

This is optional and is disabled by default. If you want to use it then you must enable (tick) the “Allow Sink to Send Email Notifications?” check box and you must fill in all of the relevant email settings.

Here is a description of each of the Sink email notification settings:

EMAIL SETTINGS:

The “Allow Sink to Send Email Notifications?” check box is disabled by default and must be enabled (ticked) if you want Sink to send notification emails after a Sink Job run has been completed.

The “Email Host Server” requires the correct email host server e.g. “mail@myemailserver.com”.

The “Email User Name” requires a valid user name for a valid email account known to the host server e.g. “me@myemailserver.com”.

The “Email Password” requires a valid password for the email account.

The “Email Port” requires the correct port to use. Typically this is “587” if using TLS encryption or port “465” if using SSL encryption but you will need to check with your email provider/IT administrator.

The “Use SSL” and “Use TLS” should be enabled (ticked) or disabled (unticked) as appropriate.

The “Email Sender Address” is the sender address that the Sink Notification emails will be “from” e.g. “me@myemailserver.com”.

The “Email Recipient(s) Address” requires one or more valid recipient (to) email addresses e.g. “john.smith@thecompany.com”. If you need more that one recipient then use a semicolon “;” to separate them e.g. “john.smith@thecompany.com;jane.jones@anothercompany.com”.

EMAIL SEND OPTIONS:

The “Email Subject Line for Successfully Completed Sink Jobs Runs” is the email notification “Subject” line to use when a Sink Jobs run completes successfully. It defaults to “Sink file and folder backup/sync application ran successfully.” I suggest you change that to something like “Sink file and folder backup/sync application ran successfully on <Name of PC/Sever>” so that you know which specific PC/Sever sent the email notification.

The “Email Subject Line for Sink Jobs Runs With Errors Reports” is the ”Subject” line to use when a Sink Jobs run completes but with errors reported. I suggest you alter this to also include the PC/Sever name.

The “Attach Sink Log File if a Sink Run Process Was Successful?” check box option should be enabled (ticked) if you want to attach the relevant Sink Log file to a “Sink Run Successful” email notification. I can’t see any reason to do this for successful runs as the automatically generated message text should include sufficient information to tell you what happened without requiring the log file to be attached which will only serve to increase your email storage requirements.

The “Attach Sink Log File if a Sink Run Process Reported Errors?” check box option should be enabled (ticked) if you want to attach the relevant Sink Log file to a “Sink Run Reported Errors” type email notification. This is probably wise to enable as it’s useful to have the relevant Sink Log file attached to “error” type emails.

The “Send Emails for Successfully Completed Sink Jobs Runs on These Days (Max One Per Day)” Monday to Sunday check boxes tell the Sink Scheduler on which days it’s allowed to send “Successfully Completed Sink Jobs Runs” type email notifications. Sink will attempt to limit “Successfully Completed Sink Jobs Runs” type email notifications to just one per day to reduce the number of emails that are sent on a given day that effectively just say that “Sink ran OK on machine x”. On my always on Windows NUC backup server I set this to Monday only so that when I check my emails on Monday morning I can see that “machine x” sent a “sink ran successfully” email when it ran at 3 am Monday morning and I therefore know that Sink is running OK on “machine x” which is all I need to know. If I don’t get that Monday morning email from Sink on “machine x” then I know that I need to log into it and see if Sink needs attention on that machine.

The “Send Emails for Sink Jobs Runs That Reported Errors on These Days” Monday to Sunday check boxes tell the Sink Scheduler on which days it’s allowed to send “Sink Jobs Run Reported Errors” type email notifications. I suggest that you set this to all days of the week so that you are always notified when Sink detects errors.

TEST EMAIL SETTINGS:

This is designed to allow you to test your Sink Email Notification configuration.

The “Test Email Subject Line” defaults to “Test email from the Sink file and folder backup/sync application.” but you might want to append the machine name to that so it’s clear which PC/Sever the test email was sent from.

The “Test Email Message Text” defaults to “This is a test email from the Sink file and folder backup/sync application” please feel free to change that to whatever you want.

The “Test Email Recipient Address” is the email address that you want to send the Sink test email to e.g. “john.smith@thecompany.com”.

The “Send Test Email” button will use the “Email Settings” and the “Test Email Settings” configuration and actually send a test email to the “Test Email Recipient Address”. The results of the test will be listed in the “Test Email Results” window.

Any changes made to the Email Notification settings can be saved by clicking the “Apply Changes” button or discarded by clicking the “Discard Changes” button.

TOOLS TAB DETAILED INFORMATION:

The “Export a current Sink configuration file” tool allows to to take a backup copy of the current Sink configuration for the running Sink instance. It’s just a small text file called “sinkini.txt” by default and you can chose to save it to any folder. This is useful if you have a complicated set of Sink Jobs defined and/or are using the Sink Scheduler or Sink Email Notification systems as that’s quite a lot of configuration and it’s good to know that you can restore it necessary or you need to set up several PCs/Servers using a similar “base” configuration.

The “Import a current Sink configuration file” tool requires you to browse for and select a valid “sinkini.txt” type text file (although it can have a different filename if you renamed it when you exported it) as generated by the “Export a current Sink configuration file” tool (see above). If it’s “valid” then your current Sink configuration will be discarded and replaced with the Sink configuration contained within the selected “sinkini.txt” file. You can use this tool to quickly set up multiple PCs/Servers using a similar “base” configuration held in a “sinkini.txt” file.

The “Browse/open Sink log file” tool lets you browse the Sink Log files folder which is (typically) the “c:\Users\<your windows username>\AppData\Local\sink\” folder. You can easily check how many Sink Log files are present in that folder and how big they are etc. and you can also open any selected Sink Log file which should display it in whichever application is associated with “.txt” text files by your Operating System. NOTE: If you are seeing a large number of Sink Log files and you want Sink to reduce that number of files then please see the “Delete Sink log files older than this many days” notes within the “General Settings” section.

The “Sink Date+Time File Stamps” option is a custom tool designed to avoid unnecessary re-copying of large files that may already exist on your backup drives that weren’t originally copied over by the Sink application so may not have the correct “modified” file date+time stamps which unless “fixed” will cause Sink to re-copy them due to what it thinks (correctly!) is a difference between the files on the source folders and the current copies on the target/backup folders.

It displays this information in a splash screen:

“This option will search through all of the files in all of your defined jobs Source folders and look for matching filenames in the corresponding Target folders.
For any files that are found in a Target folder that have the same filenames as those in the corresponding Source folder it will set the date+time file stamp on the Target file to match the date+time file stamp of the Source file.
This ensures that the jobs copy process will see the same date+time file stamps on both the Source and Target files and will therefore not force a re-copy of the Target files based on non matching date+time file stamps if the relevant Source and Target folder definition uses the '"Copy files from the Source folder that are not present in the Target folder OR have been changed in the Source folder" Copy Mode.
Note the "Copy files from the Source folder that are not present in the Target folder" Copy Mode doesn't look at date+time file stamps so you don''t need to run this process if you only use that Copy Mode.
Syncing the Target folder date+time stamps should help to avoid the unnecessary re-copying of files that already exist in the Target folder just because of mismatched date+time file stamps and is especially relevant if you have (say) a large number of video files in a Target folder which you don''t want to re-copy on the initial Sink.exe copy process.
The Sink.exe copy process will set the Target date+time file stamps to match the Source date+time file stamps after successfully copying files from Source to Target so hence this "Sync Date+Time File Stamps" process only needs to be run once or if you edit your Source and Target folder definitions.
Note: This process will switch to the "Home" tab to show you the progress of the "Sync Date+Time File Stamps" process.
Click "OK" to proceed or "Cancel" to quit.”

Hopefully that explains what the “Sink Date+Time File Stamps” tool does and why you might need to run it.

TECHNICAL INFORMATION

COMPILING SINK USING WINDOWS:

Copy all files from the Sink source code folder from the GitHub Sink repo to a suitable folder e.g. Documents\projects\sink\
Sink was written using the Lazarus Free Pascal IDE so if you want to compile Sink yourself then you will need to install the “Lazarus IDE” application.
Please follow the documentation on their website: https://www.lazarus-ide.org/ and then go to the “Downloads” page.
You will need to download the Lazarus installer from the “Windows (32 and 64 Bits) Direct download” link.
You then need to run that installer which will be named something like “lazarus-4.4-fpc-3.2.2-win32.exe” to install Lazarus. 
NOTE: Windows may attempt to block the Lazarus installer from running in which case click “More Info” and then “Run Anyway” to allow it to install.
Lazarus will want to install itself to the “c:\lazarus\” folder. I recommend that you allow it to do that and also go with the default options during installation.
Please note that the Lazarus app and its associated files uses about 1.5Gb of disk space so it’s not a huge install footprint but is significant (you can always uninstall it later if you are short on disk space).
Once installed, you can then run the Lazarus IDE from the Start menu. Just search for Lazarus and you should see “Lazarus (debug)” – Run that.
On first run go with the default configuration options i.e. “Classic IDE” + “Classic Form Editor” and click “Start IDE”.
Once Lazarus has started, click “Project”, “Open Project” and browse to the folder containing the Sink source code e.g. Documents\projects\sink\ and open the “sink.lpi” “Lazarus Project file”.
That will open the Sink project files and you can then compile it by clicking “Run”, “Build”. You can also compile and run Sink within the Lazarus IDE by clicking the green “Run” button instead.
Once compiled, you should see a file called “sink.exe” in your Documents\projects\sink\lib\i386-win32\ folder. That is the compiled Sink application and you can move it to a different location or run it directly from there.
You can then close the Lazarus IDE.

INSTALLING SINK USING WINDOWS:

Copy the “sink.exe” application from the sink GitHub repo (or use your own version of sink.exe if you have compiled it yourself - see above) to a suitable folder e.g. Document\sink\.
Run sink.exe from your chosen installation folder.
NOTE: Windows may initially attempt to block sink.exe from running in which case click “More Info” and then “Run Anyway” to allow it to run.
You can create a shortcut to run sink.exe from your chosen installation folder or simply pin it to the Start menu or pin it to the “taskbar”.
If you want to use the Sink “Scheduler” feature to automate Sink Job runs then please read the “SCHEDULER” notes which explain how to configure Windows to launch Sink on system startup.

COMPILING SINK USING LINUX:

Copy all files from the Sink source code folder from the GitHub Sink repo to a suitable folder e.g. /home/<your username>/Documents/projects/sink/

Sink was written using the Lazarus Free Pascal IDE so if you want to compile Sink yourself then you will need to install the “Lazarus IDE” application.

Please follow the documentation on their website: https://www.lazarus-ide.org/ and then go to the “Downloads” page.

For Linux (Debian or Fedora based) you will need to download the appropriate version for your Linux distribution.

For Arch Linux, Lazarus is in the “pacman” repo so as at time of writing (December 2025) these terminal commands should work:

To install lazarus on Arch: 

sudo pacman -Sy lazarus
sudo pacman -Sy lazarus-qt5

You should also be able to install lazarus on a Debian/Ubuntu type distro using these terminal commands:

sudo apt install make gdb fpc fpc-source lazarus-ide-qt5 lcl-gtk2 lcl-qt5

You should then be able to run the Lazarus IDE app. 

Once Lazarus has started, click “Project”, “Open Project” and browse to the folder containing the Sink source code e.g. /home/<your username>/Documents/projects/sink/ and open the “sink.lpi” “Lazarus Project file”.
That will open the Sink project files and you can then compile it by clicking “Run”, “Build”. You can also compile and run Sink within the Lazarus IDE by clicking the green “Run” button instead.
Once compiled, you should see a file called “sink.exe” in your /home/<your username>/Documents/projects/sink/lib/x86_64-linux/ folder. That is the compiled Sink application and you can move it to a different location or run it directly from there.
You can then close the Lazarus IDE.

INSTALLING SINK USING LINUX:

Copy the x86 binary "sink" binary from the sink GitHub repo (or use your own version of sink if you have compiled it yourself - see above) to a suitable folder e.g. “/usr/local/bin/”.
You will also need to make it executable so run "sudo chmod +x /usr/local/bin/sink" in the terminal.
You can then try running it from the terminal by typing "sink" to confirm that it runs OK. 
If the sink app won't run from the terminal then I *think* that if you install the "qt5pas" package then that should allow the sink binary to run:
To install qt5pas on Arch: sudo pacman -S qt5pas   
To install qt5pas on Debian/Ubuntu type distro: sudo apt install qt5pas

Once it's working from the terminal then you can (sudo) copy the "sink.desktop" file from the sink repo to your /usr/share/applications folder which should allow you to launch sink from your application launcher/menu.

COMPILING SINK USING MAC:

NOTE: I have used a MAC but that was a few years ago and I don’t currently have access to one but I assume that these general instructions should work:

Copy all files from the Sink source code folder from the GitHub Sink repo to a suitable folder.

Sink was written using the Lazarus Free Pascal IDE so if you want to compile Sink yourself then you will need to install the “Lazarus IDE” application.

Please follow the documentation on their website: https://www.lazarus-ide.org/ and then go to the “Downloads” page.

You will need to download the correct installer for your MAC hardware either “Lazarus macOS aarch64 (Apple M1 or higher)” or “Lazarus macOS x86-64 (Intel)”.

Launch the Lazarus installer, let it install and then run the Lazarus IDE app. 

Once Lazarus has started, click “Project”, “Open Project” and browse to the folder containing the Sink source code and open the “sink.lpi” “Lazarus Project file”.
That will open the Sink project files and you can then compile it by clicking “Run”, “Build”. You can also compile and run Sink within the Lazarus IDE by clicking the green “Run” button instead.

INSTALLING SINK USING MAC:

I don’t provide a MAC sink binary (app) in the sink GitHub repo (because I don’t use MAC and I don’t currently have access to one) so you will need to install Lazarus and compile the Sink app yourself.

Please read the “COMPILING SINK USING MAC” section.

SINK TECHNICAL INFORMATION:

THE SINK FILE COPY PROCESS:

The core procedure for the copy process is in sinkmain.pas “scanforfiles” this is a recursive file and folder scanning procedure which runs for each Sink “Job”.

It has four “scan modes”:

1: scanmode_scanonly: This is the first “pass” and its job is to compare a Job’s source folder contents against its target folder contents and total up the size of all files that it determines it needs to copy. If the a given source file doesn’t exist in the relevant target folder then it will always be copied. If the Sink Job is configured to use the “Copy files from the Source folder that are not present in the Target folder OR have been changed in the Source folder” copy “Mode” then it will also re-copy the source file to the target file if the file size of the source file is different to the file size of the current version of that file present in the target folder OR if the modified date + time file stamp of the source file is different to the modified date + time file stamp of the current version of that file present in the target folder.

2: scanmode_copyfiles: This is the second (main) “pass” and it also compares a Job’s source folder contents against its target folder contents but it then copies any files that determines it needs to copy using the same rules as the “scanmode_scanonly” mode does. It updates the progress bar and “stats” variables as it copies each file. It first attempts to use its “fast” blockread + blockwrite pascal file copying method but this requires full read/write access to the file in the source folder so if that’s not available to it then it will fall back to using the standard “OS copy” method instead.
The Sink file copy process uses a “.tmp” temporary file extension when copying a file from a source folder to a target folder and the target file which is then renamed to the correct file extension if the copy process is successful.
This allows the Sink copy process to automatically detect failed/interrupted runs that have left incomplete files in the target folders and deal with them.
After successfully copying a file Sink will then set the target file’s “modified” date + time stamp to match the source files modified date + time file stamp.

3: scanmode_deletefiles: This is the third “pass” and only runs for a Job if the Sink, Preferences, General Settings switch “Allow Sink to delete files from target folders?” check box option is enabled (ticked) and the Job’s “Delete files from the Target folder that are no longer present in the Source folder after syncing Source and Target folders?” check box is also enabled (ticked).
Once the “scanmode_deletefiles” process has finished for a given Sink Job and the “Allow Sink to delete redundant folders from target drives/folders?” Sink, Preferences, General Settings switch is enabled (ticked) then it will attempt to delete any folders from the target drive/folder that are no longer present in the source drive/folder.

4: scanmode_setfilestamps: This is a custom “pass” and is used only by the Sink, Tools, “Sink Date+Time File Stamps” option.

SINK EMAIL NOTIFICATIONS:

If Sink is running on Windows and the Sink Scheduler is enabled in Sink, Email Notifications, “Allow Sink to Send Email Notifications?” check box is enabled (ticked) then Sink will check to see if the “libeay32.dll” and “ssleay32.dll” files are present in the Sink application folder and if not then it will attempt to downloaded them from the Lazarus source code webpage “ http://packages.lazarus-ide.org/openssl…”.

If Sink is running on Linux and the Sink Scheduler is enabled in Sink, Email Notifications, “Allow Sink to Send Email Notifications?” check box is enabled (ticked) then Sink will require access to the OpenSSL libraries on you Linux system. I haven’t actually used Linux to send emails from Sink so I haven’t checked this out but I assume that if you do a web search for “Lazarus Linux Synapse OpenSSL” (or similar) then you should be able to work out what needs to be installed to get the Linux Sink email process working.

END OF SINK DOCUMENTATION
