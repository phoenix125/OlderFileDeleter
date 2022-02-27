#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\phoenixtray.ico
#AutoIt3Wrapper_Outfile=Builds\Older File Version Deleter.exe
#AutoIt3Wrapper_Compression=3
#AutoIt3Wrapper_Res_Comment=By Phoenix125
#AutoIt3Wrapper_Res_Description=Deletes older file versions by age or number of files.
#AutoIt3Wrapper_Res_Fileversion=1.0
#AutoIt3Wrapper_Res_ProductName=Older File Version Deleter
#AutoIt3Wrapper_Res_ProductVersion=1.0
#AutoIt3Wrapper_Res_CompanyName=http://www.Phoenix125.com
#AutoIt3Wrapper_Res_LegalCopyright=http://www.Phoenix125.com
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Icon_Add=Resources\phoenixfaded.ico
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/mo
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Date.au3>
#include <File.au3>
#include <Array.au3>
#include <String.au3>
#include <TrayConstants.au3>

Global $aUtilName = "Older File Version Deleter"
Global $aUtilVersion = "v1.0" ; (2021-12-26)
Global $aUtilityVer = $aUtilName & " " & $aUtilVersion
Global $aUtilVerNumber = 0
; 0 = v1.0

Global $aIniFile = @ScriptDir & "\" & $aUtilName & ".ini"
Global $aIniFailFile = @ScriptDir & "\___INI_FAIL_VARIABLES___.txt"
Global $aFolderLog = @ScriptDir & "\_Log\"
DirCreate($aFolderLog)
Global $aLogFile = $aFolderLog & $aUtilName & "_Log_" & @YEAR & "-" & @MON & "-" & @MDAY & ".txt"
Global $aConfigHeader = " --------------- CONFIGURATION --------------- "
Global $aFoldersHeader = " --------------- FILES TO DELETE --------------- "
Global $aSplash
Global $lSplash = $aUtilName & " " & $aUtilVersion & @CRLF & @CRLF

If @Compiled = 0 Then
	Global $aIconFile = @ScriptDir & "\" & $aUtilName & "_Icons.exe"
Else
	Global $aIconFile = @ScriptFullPath
EndIf

Global $xFilesDeleteAge[1]
$xFilesDeleteAge[0] = "Temp"
Global $xFilesDeleteQnty[1]
$xFilesDeleteQnty[0] = "Temp"
LogWrite("============================ " & $aUtilityVer & " Started ============================")
ReadUini()
If $aBackgroundOnlyYN = "no" Then $aSplash = _Splash($lSplash)
Global $tInit = TimerInit()
$tInit = _DateAdd('h', 0 - $aScanQHours, $tInit)
_Tray()

While True ;**** Loop Until Closed ****
	If TimerDiff($tInit) > ($aScanQHours * 3600000) Then
		If $aBackgroundOnlyYN = "no" Then
			SplashOff()
			Local $tMB = MsgBox($MB_YESNOCANCEL, $aUtilityVer, "Scan and delete files now?" & @CRLF & @CRLF & _
					"Click (YES) to run NOW." & @CRLF & _
					"Click (NO) to skip this instance." & @CRLF & _
					"Click (CANCEL) to exit program.", $aPromptTimeout)
			If $tMB = 6 Then ; Yes
				$aSplash = _Splash($lSplash & "Scanning...")
				$tInit = TimerInit()
				_ScanAndDelete()
			ElseIf $tMB = 7 Then ; No
				$tInit = TimerInit()
				_Splash("Scan cancelled. Will scan again in " & $aScanQHours & " hours.", 2000)
			ElseIf $tMB = 2 Then ; Cancel
				_ExitUtil()
				$tInit = TimerInit()
				_ScanAndDelete()
			EndIf
		Else
			$tInit = TimerInit()
			_ScanAndDelete()
		EndIf
	EndIf
	Local $tDiff = Round(((($aScanQHours * 3600000) - (TimerDiff($tInit))) / 3600000), 1)
	TrayItemSetText($iTrayNextScan, "Next scan in " & $tDiff & " hours")
	Sleep(60000)
WEnd

Func _ScanAndDelete()
	TraySetIcon(@ScriptName, 201)
	For $t = 0 To ($aFilesTotal - 1)
		_GetFilesToDelete($t)
	Next
	_ArrayDelete($xFilesDeleteAge, 0)
	_ArrayDelete($xFilesDeleteQnty, 0)
	For $t = 0 To (UBound($xFilesDeleteAge) - 1)
		If $aBackgroundOnlyYN = "no" Then ControlSetText($aSplash, "", "Static1", "Deleting by Age: " & ($t + 1) & "/" & UBound($xFilesDeleteAge) & @CRLF & $xFilesDeleteAge[$t])
		LogWrite("[DEL AGE] Deleting " & ($t + 1) & " of " & (UBound($xFilesDeleteAge) - 1) & ":" & $xFilesDeleteAge[$t])
		FileDelete($xFilesDeleteAge[$t])
	Next
	For $t = 0 To (UBound($xFilesDeleteQnty) - 1)
		If $aBackgroundOnlyYN = "no" Then ControlSetText($aSplash, "", "Static1", "Deleting by Quantity: " & ($t + 1) & "/" & UBound($xFilesDeleteQnty) & @CRLF & $xFilesDeleteQnty[$t])
		LogWrite("[DEL QTY] Deleting " & ($t + 1) & " of " & (UBound($xFilesDeleteQnty) - 1) & ":" & $xFilesDeleteQnty[$t])
		FileDelete($xFilesDeleteQnty[$t])
	Next
	If $aBackgroundOnlyYN = "no" Then
		Local $tLabel = "----- DELETED BY AGE -----" & @CRLF & StringReplace(_ArrayToString($xFilesDeleteAge), "|", @CRLF) & @CRLF & @CRLF & "----- DELETED BY QUANTITY -----" & @CRLF & StringReplace(_ArrayToString($xFilesDeleteQnty), "|", @CRLF)
		Local $tString = StringSplit($tLabel, @CRLF, 1)
		Local $tHt = $tString[0] * 20 + 100
		$aSplash = _Splash($lSplash & $tLabel, 5000, 1000, $tHt)
	EndIf
	SplashOff()
	TraySetIcon(@ScriptName, 99)
EndFunc   ;==>_ScanAndDelete
Func _Tray()
	Opt("TrayMenuMode", 3) ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.
	Opt("TrayOnEventMode", 1)
	GUISetIcon($aIconFile, 99)
	Global $iTrayUtilName = TrayCreateItem($aUtilName & " " & $aUtilVersion)
	TrayItemSetOnEvent(-1, "TrayUtilName")
	TrayCreateItem("") ; Create a separator line.
	Global $iTrayScanNow = TrayCreateItem("Scan and delete now")
	TrayItemSetOnEvent(-1, "TrayScanNow")
	Global $iTrayPause = TrayCreateItem("Pause program")
	TrayItemSetOnEvent(-1, "TrayPause")
	TrayCreateItem("") ; Create a separator line.
	Global $iTrayViewLatestLog = TrayCreateItem("View latest log")
	TrayItemSetOnEvent(-1, "TrayViewLatestLog")
	Global $iTrayViewConfig = TrayCreateItem("View config file")
	TrayItemSetOnEvent(-1, "TrayViewConfig")
	TrayCreateItem("") ; Create a separator line.
	Global $iTrayAbout = TrayCreateItem("About")
	TrayItemSetOnEvent(-1, "TrayAbout")
	Global $iTrayUpdateUtilCheck = TrayCreateItem("Check for program update")
	TrayItemSetOnEvent(-1, "TrayUpdateUtilCheck")
	TrayCreateItem("") ; Create a separator line.
	Global $tDiff = Round(((($aScanQHours * 3600000) - (TimerDiff($tInit))) / 3600000), 0)
	Global $iTrayNextScan = TrayCreateItem("Next scan in " & $tDiff & " hours")
	TrayItemSetOnEvent(-1, "TrayNextScan")
;~ 	TrayItemSetState(-1, $TRAY_DISABLE)
	Global $iTrayResetTimer = TrayCreateItem("Reset Timer")
	TrayItemSetOnEvent(-1, "TrayResetTimer")
	TrayCreateItem("") ; Create a separator line.
	Global $iTrayExit = TrayCreateItem("Exit program")
	TrayItemSetOnEvent(-1, "TrayExit")
;~ If $aCheckForUpdate = "yes" Then
;~ 	TrayItemSetState($iTrayUpdateServPause, $TRAY_ENABLE)
;~ 	TrayItemSetState($iTrayUpdateServUnPause, $TRAY_DISABLE)
;~ Else
;~ 	TrayItemSetState($iTrayUpdateServPause, $TRAY_DISABLE)
;~ 	TrayItemSetState($iTrayUpdateServUnPause, $TRAY_ENABLE)
;~ EndIf
EndFunc   ;==>_Tray
Func TrayUtilName()
	ShellExecute("http://www.phoenix125.com")
EndFunc   ;==>TrayUtilName
Func TrayScanNow()
	$tInit = TimerInit()
	_ScanAndDelete()
EndFunc   ;==>TrayScanNow
Func TrayPause()
	SplashOff()
	MsgBox($MB_OK, $aUtilityVer, $aUtilityVer & " Paused.  Press OK to resume.")
EndFunc   ;==>TrayPause
Func TrayViewLatestLog()
	$aLogFile = $aFolderLog & $aUtilName & "_Log_" & @YEAR & "-" & @MON & "-" & @MDAY & ".txt"
	ShellExecute($aLogFile)
EndFunc   ;==>TrayViewLatestLog
Func TrayViewConfig()
	ShellExecute($aIniFile)
EndFunc   ;==>TrayViewConfig
Func TrayAbout()
	MsgBox($MB_SYSTEMMODAL, $aUtilName, $aUtilName & @CRLF & "Version: " & $aUtilVersion & @CRLF & @CRLF & "Install Path: " & @ScriptDir & @CRLF & @CRLF & "Discord: http://discord.gg/EU7pzPs" & @CRLF & "Website: http://www.phoenix125.com", 15)
EndFunc   ;==>TrayAbout
Func TrayUpdateUtilCheck()
	MsgBox($MB_SYSTEMMODAL, $aUtilName, "Coming soon!", 10)
EndFunc   ;==>TrayUpdateUtilCheck
Func TrayNextScan()
	Local $tDiff = Round(((($aScanQHours * 3600000) - (TimerDiff($tInit))) / 3600000), 1)
	_Splash("Next scan in " & $tDiff & " hours", 2000)
EndFunc   ;==>TrayNextScan
Func TrayResetTimer()
	$tInit = TimerInit()
	Local $tDiff = Round(((($aScanQHours * 3600000) - (TimerDiff($tInit))) / 3600000), 1)
	_Splash("Timer reset.  Next scan in " & $tDiff & " hours", 2500)
EndFunc   ;==>TrayResetTimer
Func TrayExit()
	_ExitUtil()
EndFunc   ;==>TrayExit

Func _GetFilesToDelete($tNo)
	Local $tFolder = _FolderFromPath($xFileName[$tNo])
	Local $tFilename = _FileNameFromPath($xFileName[$tNo])
	$tFilename = StringReplace($tFilename, "*", "")
	LogWrite("[ SCAN  ] Scanning [" & $tFolder & "] for [" & $tFilename & "] files...")
	If $aBackgroundOnlyYN = "no" Then ControlSetText($aSplash, "", "Static1", "Scanning [" & $tFolder & "] for " & @CRLF & "[" & $tFilename & "] files...")
	Local $xFiles = _FileListToArray($tFolder, "*", $FLTA_FILESFOLDERS)
	Local $xFileMatch[1]
	$xFileMatch[0] = $tFilename
	Local $xFileAge[1]
	$xFileAge[0] = $tFilename
	If IsArray($xFiles) Then
		For $n = 1 To $xFiles[0]
			Local $sFilename = _FileNameFromPath($xFiles[$n])
			Local $sAge = _DateDiffInSeconds(StringReplace($tFolder & "\", "\\", "\") & $xFiles[$n])
			If _StringStartsWith($sFilename, $tFilename) Then
				_ArrayAdd($xFileMatch, $tFolder & "?" & $sFilename & "?" & $sAge & "?" & UBound($xFileMatch))
				_ArrayAdd($xFileAge, $sAge)
			EndIf
		Next
		If $xFileMaxAgeDays[$tNo] > -1 Then ; Delete by age
			For $n = 1 To (UBound($xFileAge) - 1)
				Local $tSplit = StringSplit($xFileMatch[$n], "?")
;~ 				If $tSplit[0] <> 4 Then MsgBox(0, "Kim", "ERROR") ;kim125er!
				Local $tFldr = $tSplit[1]
				Local $tFN = $tSplit[2]
				Local $tAge = $tSplit[3]
				Local $tNum = $tSplit[4]
				If ($xFileMaxAgeDays[$tNo] * 86400) < $tAge Then _ArrayAdd($xFilesDeleteAge, $tFldr & $tFN)
			Next
		EndIf
		_ArrayDelete($xFileAge, 0)
		_ArraySort($xFileAge)
		If $xFileMaxFiles[$tNo] > -1 And IsArray($xFileAge) Then
			If $xFileMaxFiles[$tNo] < UBound($xFileAge) Then
				Local $tRange = "0-" & ($xFileMaxFiles[$tNo] - 1)
				_ArrayDelete($xFileAge, $tRange)
				Local $tDelete = 0
				For $n = 1 To (UBound($xFileMatch) - 1) ;file
					Local $tSplit = StringSplit($xFileMatch[$n], "?")
					Local $tFldr = $tSplit[1]
					Local $tFN = $tSplit[2]
					Local $tAge = $tSplit[3]
					Local $tNum = $tSplit[4]
					For $m = 0 To (UBound($xFileAge) - 1) ;age
						If $xFileAge[$m] = $tAge Then
							$tDelete += 1
							_ArrayAdd($xFilesDeleteQnty, $tFldr & $tFN)
							ExitLoop
						EndIf
					Next
				Next
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_GetFilesToDelete

Func _FileNameFromPath($tPath)
	Local $sDrive = "", $sDir = "", $sFilename = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($tPath, $sDrive, $sDir, $sFilename, $sExtension)
	Return $aPathSplit[3] & $aPathSplit[4]
EndFunc   ;==>_FileNameFromPath
Func _FolderFromPath($tPath)
	Local $sDrive = "", $sDir = "", $sFilename = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($tPath, $sDrive, $sDir, $sFilename, $sExtension)
	Return $aPathSplit[1] & $aPathSplit[2]
EndFunc   ;==>_FolderFromPath
Func _DateDiffInSeconds($filename)
	If Not FileExists($filename) Then Return -1
	Local $filetime = FileGetTime($filename)
	If UBound($filetime) = 6 Then
		Local $tempDate = $filetime[0] & "/" & $filetime[1] & "/" & $filetime[2] & " " & $filetime[3] & ":" & $filetime[4] & ":" & $filetime[5]
		Local $currDate = @YEAR & "/" & @MON & "/" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC
		Return _DateDiff("s", $tempDate, $currDate)
	EndIf
EndFunc   ;==>_DateDiffInSeconds
Func _StringStartsWith($string, $start, $case = 0)
	If StringInStr($string, ".") = 0 Then Return 0
	If StringLen($start) > StringLen($string) Then Return 0
	If $case > 0 Then
		If StringLeft($string, StringLen($start)) == $start Then Return 1
	Else
		If StringLeft($string, StringLen($start)) = $start Then Return 1
	EndIf
	Return 0
EndFunc   ;==>_StringStartsWith
Func _ExitUtil()
	MsgBox(0, $aUtilityVer, "Thank you for using " & $aUtilName & "." & @CRLF & @CRLF & _
			"Please report any problems or comments to: " & @CRLF & "Discord: http://discord.gg/EU7pzPs or " & @CRLF & _
			"Forum: http://phoenix125.createaforum.com/index.php. " & @CRLF & @CRLF & "Visit http://www.Phoenix125.com", 20)
	Exit
EndFunc   ;==>_ExitUtil
Func LogWrite($Msg)
	$Msg = StringReplace($Msg, @CRLF, "|")
	$Msg = StringReplace($Msg, @CR, "|")
	$Msg = StringReplace($Msg, @LF, "|")
	$aLogFile = $aFolderLog & $aUtilName & "_Log_" & @YEAR & "-" & @MON & "-" & @MDAY & ".txt"
	Local $tFileSize = FileGetSize($aLogFile)
	If $tFileSize > 10000000 Then
		FileMove($aLogFile, $aFolderLog & $aUtilName & "_Log_" & @YEAR & "-" & @MON & "-" & @MDAY & "-Part1.txt")
		FileWriteLine($aLogFile, _NowCalc() & " Log File Split.  First file:" & $aFolderLog & $aUtilName & "_Log_" & @YEAR & "-" & @MON & "-" & @MDAY & "-Part1.txt")
	EndIf
	If $Msg <> "" Then FileWriteLine($aLogFile, _NowCalc() & " " & $Msg)
EndFunc   ;==>LogWrite
Func PurgeLogFile()
	$aPurgeLogFileName = @ScriptDir & $aUtilName & "_PurgeLogFile.bat"
	FileDelete($aPurgeLogFileName)
	FileWriteLine($aPurgeLogFileName, "for /f ""tokens=* skip=" & $aLogQuantity & """ %%F in " & Chr(40) & "'dir """ & $aFolderLog & $aUtilName & "_Log_*.txt"" /o-d /tc /b'" & Chr(41) & " do del """ & $aFolderLog & "%%F""")
	LogWrite("Deleting log files >" & $aLogQuantity)
	Run($aPurgeLogFileName, "", @SW_HIDE)
EndFunc   ;==>PurgeLogFile
Func _Splash($tTxt, $tTime = 0, $tWidth = 400, $tHeight = 125)
	Local $tPID = SplashTextOn($aUtilName, $tTxt, $tWidth, $tHeight, -1, -1, $DLG_MOVEABLE, "")
	If $tTime > 0 Then
		Sleep($tTime)
		SplashOff()
	EndIf
	Return $tPID
EndFunc   ;==>_Splash
Func ReadUini()
	LogWrite("[CONFIG ] Importing settings from " & $aUtilName & ".ini")
	Local $iIniError = ""
	Local $iIniFail = 0
	Local $iniCheck = ""
	Local $aChar[3]
	For $i = 1 To 13
		$aChar[0] = Chr(Random(97, 122, 1)) ;a-z
		$aChar[1] = Chr(Random(48, 57, 1)) ;0-9
		$iniCheck &= $aChar[Random(0, 1, 1)]
	Next
	Global $aScanQHours = IniRead($aIniFile, $aConfigHeader, "Scan Folder(s) Every _ Hours (1-8766) ###", $iniCheck)
	Global $aBackgroundOnlyYN = IniRead($aIniFile, $aConfigHeader, "Run in background only? (No onscreen notifications) ###", $iniCheck)
	Global $aPromptTimeout = IniRead($aIniFile, $aConfigHeader, "If yes above, number of seconds to display confirmation prompt before automatically deleting (0-600, 0-No Timeout) ###", $iniCheck)
	Global $aLogQuantity = IniRead($aIniFile, $aConfigHeader, "Number of log files to keep (0-730) ###", $iniCheck)
	If $iniCheck = $aScanQHours Then
		$aScanQHours = 24
		$iIniFail += 1
		$iIniError = $iIniError & "ScanQHours, "
	ElseIf $aScanQHours < 1 Then
		$aScanQHours = 1
	ElseIf $aScanQHours > 8766 Then
		$aScanQHours = 8766
	EndIf
	If $iniCheck = $aBackgroundOnlyYN Then
		$aBackgroundOnlyYN = "no"
		$iIniFail += 1
		$iIniError = $iIniError & "PromptYN, "
	ElseIf $aBackgroundOnlyYN <> "yes" And $aBackgroundOnlyYN <> "no" Then
		$aBackgroundOnlyYN = "no"
	EndIf
	If $iniCheck = $aPromptTimeout Then
		$aPromptTimeout = 120
		$iIniFail += 1
		$iIniError = $iIniError & "PromptTimeout, "
	ElseIf $aPromptTimeout < 0 Then
		$aPromptTimeout = 0
	ElseIf $aPromptTimeout > 600 Then
		$aPromptTimeout = 600
	EndIf
	If $iniCheck = $aLogQuantity Then
		$aLogQuantity = 120
		$iIniFail += 1
		$iIniError = $iIniError & "LogQuantity, "
	ElseIf $aLogQuantity < 0 Then
		$aLogQuantity = 0
	ElseIf $aLogQuantity > 730 Then
		$aLogQuantity = 730
	EndIf
	If $iIniFail > 0 Then iniFileCheck($iIniFail, $iIniError)
	Local $tFileRead = FileRead($aIniFile)
	If StringLen($tFileRead) > 1000 Then
		Local $tParams = _ArrayToString(_StringBetween($tFileRead, "[ --------------- BEGIN --------------- ]" & @CRLF, "[ --------------- END --------------- ]"))
		Local $tString = StringSplit($tParams, @CRLF, 3)
		_ArrayDelete($tString, UBound($tString) - 1)
		Global $aFilesTotal = UBound($tString)
		Local $tError = ""
		Global $xFileName[$aFilesTotal]
		Global $xFileMaxAgeDays[$aFilesTotal]
		Global $xFileMaxFiles[$aFilesTotal]
		For $t = 0 To ($aFilesTotal - 1)
			Local $tSplit = StringSplit($tString[$t], ">")
			$xFileName[$t] = $tSplit[1]
			$xFileMaxAgeDays[$t] = $tSplit[2]
			$xFileMaxFiles[$t] = $tSplit[3]
			If $xFileName[$t] <> "X" Then
				Local $tFN = _FolderFromPath($xFileName[$t])
				If $tFN = "" Then
					$tFN = @ScriptDir
					$xFileName[$t] = $tFN & "\" & $xFileName[$t]
					$xFileName[$t] = StringReplace($xFileName[$t], "\\", "\")
				EndIf
			EndIf
			If $xFileMaxAgeDays[$t] = "X" Then $xFileMaxAgeDays[$t] = -1
			If $xFileMaxFiles[$t] = "X" Then $xFileMaxFiles[$t] = -1
		Next
		Local $tToDelete = ""
		For $t = 0 To ($aFilesTotal - 1)
			If $xFileName[$t] = "X" Then
				$aFilesTotal -= 1
				$tToDelete &= $t & ";"
			EndIf
		Next
		If StringLen($tToDelete) > 0 Then
			$tToDelete = StringTrimRight($tToDelete, 1)
			_ArrayDelete($xFileName, $tToDelete)
			_ArrayDelete($xFileMaxAgeDays, $tToDelete)
			_ArrayDelete($xFileMaxFiles, $tToDelete)
		EndIf
	EndIf
EndFunc   ;==>ReadUini
Func iniFileCheck($iIniFail, $iIniError)
	Local $tFileLen = FileRead($aIniFile)
	If $tFileLen > 100 Then
		Local $aMyDate, $aMyTime
		_DateTimeSplit(_NowCalc(), $aMyDate, $aMyTime)
		Local $iniDate = StringFormat("%04i.%02i.%02i.%02i%02i", $aMyDate[1], $aMyDate[2], $aMyDate[3], $aMyTime[1], $aMyTime[2])
		FileMove($aIniFile, $aIniFile & "_" & $iniDate & ".bak", 1)
		UpdateIni()
		;		FileWriteLine($aIniFailFile, _NowCalc() & " INI MISMATCH: Found " & $iIniFail & " missing variable(s) in " & $aUtilName & ".ini. Backup created and all existing settings transfered to new INI. Please modify INI and restart.")
		Local $iIniErrorCRLF = StringRegExpReplace($iIniError, ", ", @CRLF & @TAB)
		FileWriteLine($aIniFailFile, _NowCalc() & @CRLF & " ---------- Parameters missing or changed ----------" & @CRLF & @CRLF & @TAB & $iIniErrorCRLF)
		LogWrite(" INI MISMATCH: Found " & $iIniFail & " missing variable(s) in " & $aUtilName & ".ini. Backup created and all existing settings transfered to new INI. Please modify INI and restart.")
		LogWrite(" INI MISMATCH: Parameters missing: " & $iIniFail)
		SplashOff()
		MsgBox(4096, "INI MISMATCH", "INI FILE WAS UPDATED." & @CRLF & "Found " & $iIniFail & " missing variable(s) in " & $aUtilName & ".ini:" & @CRLF & @CRLF & $iIniError & @CRLF & @CRLF & _
				"Backup created and all existing settings transfered to new INI." & @CRLF & @CRLF & "Click OK to open config." & @CRLF & @CRLF & "File created: ___INI_FAIL_VARIABLES___.txt", 60)
		ShellExecute($aIniFailFile)
		_ExitUtil()
	Else
		UpdateIni()
		ShellExecute($aIniFile)
		Sleep(1000)
		MsgBox(0, $aUtilName, "Config file created.  Please make any changes and restart program.", 60)
		_ExitUtil()
	EndIf
EndFunc   ;==>iniFileCheck
Func UpdateIni()
	Local $tParams = "No"
	Local $tFileRead = FileRead($aIniFile)
	If StringLen($tFileRead) > 1000 Then $tParams = _ArrayToString(_StringBetween($tFileRead, "[ --------------- BEGIN --------------- ]" & @CRLF, "[ --------------- END --------------- ]"))
	FileDelete($aIniFile)
	FileWriteLine($aIniFile, "[ --------------- " & StringUpper($aUtilName) & " INFORMATION --------------- ]")
	FileWriteLine($aIniFile, "Author   :  Phoenix125")
	FileWriteLine($aIniFile, "Version  :  " & $aUtilVersion)
	FileWriteLine($aIniFile, "Website  :  http://www.Phoenix125.com")
	FileWriteLine($aIniFile, "Discord  :  http://discord.gg/EU7pzPs")
	FileWriteLine($aIniFile, "Forum    :  https://phoenix125.createaforum.com/index.php")
	FileWriteLine($aIniFile, @CRLF)
	IniWrite($aIniFile, $aConfigHeader, "Scan Folder(s) Every _ Hours (1-8766) ###", $aScanQHours)
	IniWrite($aIniFile, $aConfigHeader, "Run in background only? (No onscreen notifications) ###", $aBackgroundOnlyYN)
	IniWrite($aIniFile, $aConfigHeader, "If yes above, number of seconds to display confirmation prompt before automatically deleting (0-600, 0-No Timeout) ###", $aPromptTimeout)
	IniWrite($aIniFile, $aConfigHeader, "Number of log files to keep (0-730) ###", $aLogQuantity)
	FileWriteLine($aIniFile, @CRLF)
	FileWriteLine($aIniFile, "[ --------------- FILES AND FOLDERS --------------- ]")
	FileWriteLine($aIniFile, 'Path&FileName*>DaysOldToKeep>NumberOfNewestVersionsToKeep')
	FileWriteLine($aIniFile, '              Path&FileName* = Folder & Beginning of Filename. To use script folder, only put in filename')
	FileWriteLine($aIniFile, '               DaysOldToKeep = Keep all files same as or newer than _ days ago. (Use X to ignore)')
	FileWriteLine($aIniFile, 'NumberOfNewestVersionsToKeep = Number of newest versions to keep. (Use X to ignore)')
	FileWriteLine($aIniFile, @CRLF)
	FileWriteLine($aIniFile, 'Add as many lines/files as desired.')
	FileWriteLine($aIniFile, @CRLF)
	FileWriteLine($aIniFile, '--- Example ---')
	FileWriteLine($aIniFile, 'D:\Backups\My Computer Backup*>X>10  |  This will keep the 10 most recent versions of all files beginning with "My Computer Backup".')
	FileWriteLine($aIniFile, 'E:\Camera\Backups\Camera 1*>14>X     |  This will keep 14 days of files beginning with "Camera 1" and delete all older versions.')
	FileWriteLine($aIniFile, 'My Documents Backup>30>X             |  This will keep 30 days of files beginning with "My Documents Backup" in the same folder this program is run.')
	FileWriteLine($aIniFile, @CRLF)
	FileWriteLine($aIniFile, "[ --------------- BEGIN --------------- ]")
	If $tParams <> "No" Then
		FileWrite($aIniFile, $tParams)
	Else
		FileWriteLine($aIniFile, 'X>X>X')
		FileWriteLine($aIniFile, 'X>X>X')
		FileWriteLine($aIniFile, 'X>X>X')
		FileWriteLine($aIniFile, 'X>X>X')
		FileWriteLine($aIniFile, 'X>X>X')
	EndIf
	FileWriteLine($aIniFile, "[ --------------- END --------------- ]")
EndFunc   ;==>UpdateIni
