Older File Deleter - 
- Latest version: OlderFileDeleter_v1.1 (2024-01-30)
- By Phoenix125 | http://www.Phoenix125.com | http://discord.gg/EU7pzPs | kim@kim125.com

----------
 FEATURES
----------
• Deletes files in a folder older than set days and/or keep the defined most recent versions of files and deletes all older versions.
• Can monitor multiple files in multiple folders.
• User-definable execution interval.  Run every hour, daily, weekly, etc.
• Minimal CPU and memory usage.

--------------------------------------------------
 SAMPLE CONFIG (real config used personally by me
--------------------------------------------------
[ --------------- OLDER FILE VERSION DELETER INFORMATION --------------- ]
Author   :  Phoenix125
Version  :  v1.1
Website  :  http://www.Phoenix125.com
Discord  :  http://discord.gg/EU7pzPs
Forum    :  https://phoenix125.createaforum.com/index.php

[--------------- CONFIGURATION ---------------]
Scan Folder(s) Every _ Hours (1-8766) ###=24
Run in background only? (No onscreen notifications) ###=yes
If yes above, number of seconds to display confirmation prompt before automatically deleting (0-600, 0-No Timeout) ###=120
Number of log files to keep (0-730) ###=365

[ --------------- FILES AND FOLDERS --------------- ]
Path&FileName*>DaysOldToKeep>NumberOfNewestVersionsToKeep
              Path&FileName* = Folder & Beginning of Filename. To use script folder, only put in filename
               DaysOldToKeep = Keep all files same as or newer than _ days ago. (Use X to ignore)
NumberOfNewestVersionsToKeep = Number of newest versions to keep. (Use X to ignore)

Add as many lines/files as desired.

--- Example ---
D:\Backups\My Computer Backup*>X>10  |  This will keep the 10 most recent versions of all files beginning with "My Computer Backup".
E:\Camera\Backups\Camera 1*>14>X     |  This will keep 14 days of files beginning with "Camera 1" and delete all older versions.
My Documents Backup>30>X             |  This will keep 30 days of files beginning with "My Documents Backup" in the same folder this program is run.

[ --------------- BEGIN --------------- ]
L:\My backups\GameServer1-Full>15>X
L:\My backups\GameServer1-ServersOnly>8>X
L:\My backups\GameServer2-Full>8>X
L:\My backups\GameServer2-ServersOnly>8>X
L:\My backups\MCE_diff>X>10
L:\My backups\MINIGAMINGPC-Full_diff>15>X
L:\My backups\MINIGAMINGPC-Full_full>X>2
L:\My backups\Plex-Full>31>X
L:\My backups\Plex-VMs>15>X
L:\My backups\VM-MailEnable-Full>31>X
L:\My backups\VM-MailEnable-MailEnable-Only>8>X
L:\My backups\VM-MailEnable-Websites>93>X
L:\My backups\VM-Plex>62>X
[ --------------- END --------------- ]


---------------------------
 UPCOMING PLANNED FEATURES
---------------------------
• GUI for config
• Auto Updater

----------------
 DOWNLOAD LINKS
----------------
Latest Version:       http://www.phoenix125.com/share/olderfiledeleter/OlderFileDeleter.zip
Previous Versions:    http://www.phoenix125.com/share/olderfiledeleter/olderfiledeleterhistory/
Source Code (AutoIT): http://www.phoenix125.com/share/olderfiledeleter/OlderFileDeleter.au3
GitHub:	              https://github.com/phoenix125/OlderFileDeleter

Website: http://www.Phoenix125.com
Discord: http://discord.gg/EU7pzPs
Forum:   https://phoenix125.createaforum.com/index.php

-----------------
 VERSION HISTORY
-----------------
(2024-01-30) v1.1
• Fixed an issue with age-related files. It was not correctly identifying files for deletion.

(2021-02-27) v1.0 Initial Release
• Deletes files in a folder older than set days and/or keep the defined most recent versions of files and deletes all older versions.
• Can monitor multiple files in multiple folders.
• User-definable execution interval.  Run every hour, daily, weekly, etc.
• Minimal CPU and memory usage.
