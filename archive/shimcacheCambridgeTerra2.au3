; shimcache
; Patrick Bolan, UMN CMRR
; Created Oct 10, 2009
;
; Chris Rodgers, Cambridge
; Updated to support 7T Terra VE11R 12 Dec 2017
;
; A small gui for saving and recalling shim sets on
; Siemens VE11R scanners. Uses the command-line AdjValidate
; tool available on the IDEA website.
; Versions:
; 20091010- Created
; 20171212- Update for VE11R

#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <Constants.au3>
#Include <Array.au3>
#Include <GuiListView.au3>


Opt('MustDeclareVars', 1)
Opt("GUIOnEventMode", 1)

Global $ExitID
Global $EditID
Global $ListID
Global $AdjValidateProgram = "c:\medcom\bin\adjvalidate.exe"

_Main()

Func _Main()
	Local $GetID, $SetID, $ClearID, $ClearAllID, $ClearUnselectedID, $AboutID, $windowWidth

	; Set the window width
	$windowWidth = 940

	; Everything is done in a temporary directory
	FileChangeDir('C:\Temp')

	GUICreate("ShimCache (for AdjValidate VE11R)", $windowWidth, 204)

	; The Get button
	$GetID = GUICtrlCreateButton("Get", 2, 2, 50, 20)
	GUICtrlSetOnEvent($GetID, "OnGet")

	; The Set button
	$SetID = GUICtrlCreateButton("Set", 60, 2, 50, 20)
	GUICtrlSetOnEvent($SetID, "OnSet")

	; The Clear button
	$ClearID = GUICtrlCreateButton("Delete Selected", 120, 2, 100, 20)
	GUICtrlSetOnEvent($ClearID, "OnClear")

	; The Clear All button
	$ClearUnselectedID = GUICtrlCreateButton("Delete Unselected", 230, 2, 100, 20)
	GUICtrlSetOnEvent($ClearUnselectedID, "OnClearUnselected")

	; The Clear All button
	$ClearAllID = GUICtrlCreateButton("Delete All", 340, 2, 60, 20)
	GUICtrlSetOnEvent($ClearAllID, "OnClearAll")

	; The About Button
	$AboutID = GUICtrlCreateButton("About", $windowWidth-100-2, 2, 50, 20)
	GUICtrlSetOnEvent($AboutID, "OnAbout")
	GUISetOnEvent($GUI_EVENT_CLOSE, "OnAbout")


	; The Exit button
	$ExitID = GUICtrlCreateButton("Exit", $windowWidth-50-2, 2, 50, 20)
	GUICtrlSetOnEvent($ExitID, "OnExit")
	GUISetOnEvent($GUI_EVENT_CLOSE, "OnExit")

	; The list box
	$ListId = GUICtrlCreateListView("#|TimeStamp|X|Y|Z|Z2|ZX|ZY|X2-Y2|XY|Z3|Z2X|Z2Y|Z(X2-Y2)|", 2, 25, $windowWidth-2, 135)
	;GUICtrlCreateListViewItem("1|20091008085023|1000.1|2343.2|-3923.2|23.4|-233.3|3092.0|-2312.1|23.2", $ListId)
	UpdateListView()

	; The edit box
	$EditID = GUICtrlCreateEdit(@WorkingDir, 2, 165, 734, 35, BitOr($ES_READONLY, $ES_MULTILINE))

	GUISetState()  ; display the GUI

	While 1
		Sleep(1000)
	WEnd
EndFunc   ;==>_MainS

;--------------- Functions ---------------
Func OnGet()

	Local $OldStr, $ProcID, $shimvals
	Local $ShimsetFilename

	$ShimsetFilename = "shimset_" & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & ".txt"

	;$ProcID = ShellExecuteWait("ls", "", @WorkingDir, "", @SW_HIDE)
	$ProcID = RunWait(@ComSpec & " /c" & "AdjValidate -shim -mp -get > " & $ShimsetFilename, @WorkingDir, @SW_HIDE)

	; Look at the file and see if it is OK
	$shimvals = FileReadLine($ShimsetFilename)
	GUICtrlSetData($EditID, $shimvals)
	if(stringcompare(StringLeft($shimvals, 5), "error", 2) == 0 ) Then
		; No need for a message box, just delete the File
		FileDelete($ShimsetFilename)
	EndIf

	UpdateListView()
EndFunc   ;==>OnYes


; Set the current selected one
Func OnSet()
	Local $curitem = GUICtrlRead($ListID)

	If $curitem == 0 Then
		MsgBox(48, "Error", "Select a shimset first")
	Else
		;Local $values = _GUICtrlListView_GetItemTextArray($ListId, $curitem)
		Local $values = StringSplit( GUICtrlRead($curitem) , "|")
		Local $timestamp = $values[2]

		; Recreate filename
		Local $shimsetFilename, $shimvals
		$shimsetFilename = "shimset_" & $timestamp & ".txt"

		Local $fh = FileOpen($shimsetFilename)
		FileReadLine($fh)
		FileReadLine($fh)
		; Now read the shims
		$shimvals = FileReadLine($fh)

		FileClose($fh)

		Local $cmd = "AdjValidate -shim -mp -set " & $shimvals
		local $exitcode = RunWait(@ComSpec & " /c" & $cmd, @WorkingDir, @SW_HIDE)
		if $exitcode == 0 Then
			GUICtrlSetData($EditID, $cmd & @CRLF & "succeeded")
		else
			GUICtrlSetData($EditID, $cmd & @CRLF & "**** FAILED: protocol not open ****")
		endif

	EndIf


EndFunc


; Deletes all the shim Files
Func OnClearAll()
	Local $retval, $files
	$files = GetShimsetFiles()

	; Confirm
	if( MsgBox(33, "Confirm", "Delete " & _ArrayMaxIndex($files) & " shimset files?") == 1 ) then

		For $file In $files
			FileDelete($file)
		Next

		UpdateListView()
	EndIf
EndFunc


; Deletes the selected shim Files
Func OnClear()

	Local $curitem = GUICtrlRead($ListID)
	Local $values = StringSplit( GUICtrlRead($curitem) , "|")
	Local $timestamp = $values[2]

	; Recreate filename
	Local $shimsetFilename, $shimvals
	$shimsetFilename = "shimset_" & $timestamp & ".txt"

	FileDelete($shimsetFilename)
	UpdateListView()

EndFunc

; Deletes all the shim Files
Func OnClearUnselected()
	Local $retval, $files
	$files = GetShimsetFiles()

	; Figure out filename for selected
	Local $curitem = GUICtrlRead($ListID)
	Local $values = StringSplit( GUICtrlRead($curitem) , "|")
	Local $timestamp = $values[2]

	; Recreate filename
	Local $shimsetFilename, $shimvals
	$shimsetFilename = "shimset_" & $timestamp & ".txt"


	For $file In $files
		if(stringcompare($file, $shimsetFilename, 2) == 0 ) Then
			; do nothing
		else
			FileDelete($file)
		EndIf
	Next

	UpdateListView()

EndFunc

; Returns an array of the names of the shimset filenames
Func GetShimsetFiles()
	Local $FilenameArray[1]
	Local $search, $fname

	$search = FileFindFirstFile("shimset_*.txt")

	; Check if the search was successful
	If $search = -1 Then
		Return $FilenameArray
	EndIf

	; Add each file to the array
	While 1
		$fname = FileFindNextFile($search)
		If @error Then ExitLoop
		_ArrayAdd($FilenameArray, $fname)
	WEnd

	; Close the search handle
	FileClose($search)

	Return $FilenameArray
EndFunc


Func UpdateListView()
	Local $files, $fname, $count, $idx
	Local $timestamp, $shimvals

	; Clear it out first
	_GUICtrlListView_DeleteAllItems($ListID)

	$files = GetShimsetFiles()
	$count = _ArrayMaxIndex($files)

	For $idx = 1 To $count
		; Extract the timestamp from the filename
		$timestamp = GetTimestampFromFilename($files[$idx])
		$shimvals = GetShimValuesFromFile($files[$idx])
		GUICtrlCreateListViewItem($idx & "|" & $timestamp & "|" & $shimvals, $ListId)
	next

EndFunc


Func GetTimestampFromFilename($fname)
	; THis is hardwired, assuming the filename is shimset_YYYYMMDDHHMMSS.txt
	Return StringTrimLeft(StringTrimRight($fname, 4), 8)
EndFunc

; Returns a string of 12 values delimited by |
Func GetShimValuesFromFile($fname)
	; Skip two lines of debug output on VE11R
	Local $fh = FileOpen($fname)
	FileReadLine($fh)
	FileReadLine($fh)
	; Now read the shims
	Local $line = FileReadLine($fh)
	FileClose($fh)

	; Convert from space delimited to | delimited
	Return StringReplace($line, " ", "|")
EndFunc

Func OnExit()
	Exit
EndFunc   ;==>OnExit

Func OnAbout()
	MsgBox($MB_OK, "About Shimcache", "An AutoIt script that calls Siemens' AdjValidate program. Public domain software, by Christopher Rodgers (christopher.rodgers@cardiov.ox.ac.uk ) and Patrick Bolan (bola0035@umn.edu). ")
EndFunc
