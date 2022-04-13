; shimcache
; Patrick Bolan, UMN CMRR
; Created Oct 10, 2009
; A small gui for saving and recalling shim sets on 
; Siemens vb15 scanners. Uses the command-line AdjValidate 
; tool available on the IDEA website.
; Versions:
; 20091010 - Created
; 20120813 - Updated for vb17 

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
	Local $GetID, $SetID, $ClearID, $ClearAllID, $ClearUnselectedID, $AboutID
	
	; Everything is done in a temporary directory
	FileChangeDir('C:\Temp')
	
	GUICreate("ShimCache (for AdjValidate vb17)", 740, 204)

	; The Get button
	$GetID = GUICtrlCreateButton("Get", 2, 2, 50, 20)
	GUICtrlSetOnEvent($GetID, "OnGet")
	
	; The Set button
	$SetID = GUICtrlCreateButton("Set", 60, 2, 50, 20)
	GUICtrlSetOnEvent($SetID, "OnSet")
	
	; The Clear button
	$ClearID = GUICtrlCreateButton("Delete All", 120, 2, 100, 20)
	GUICtrlSetOnEvent($ClearID, "OnClearAll")	
	

	; The Exit button
	$ExitID = GUICtrlCreateButton("Exit", 685, 2, 50, 20)
	GUICtrlSetOnEvent($ExitID, "OnExit")
	GUISetOnEvent($GUI_EVENT_CLOSE, "OnExit")
	
	; The list box
	$ListId = GUICtrlCreateListView("#|TimeStamp|X|Y|Z|XY|XZ|YZ|Z2|X2Y2|", 2, 25, 734, 135)
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
	$shimvals = GetShimStringFromFile($ShimsetFilename)
	
	; Show this value in the edit area
	GUICtrlSetData($EditID, $shimvals)
	if (stringcompare($shimvals, "") == 0) Then
		; No need for a message box, just delete the File 
		MsgBox(48, "Error", "Failed to parse the shimset file")
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
		;$shimvals = FileReadLine($shimsetFilename)
		$shimvals = GetShimStringFromFile($shimsetFilename)
		
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
 


; Returns an empty string if fail; otherwise a space-delimitied string of 8 floats
Func GetShimStringFromFile($fname)
   Local $shimString, $file
   $shimString = ""
   
   $file = FileOpen($fname, 0)
   if ($file = -1) Then
	  MsgBox(48, "Error", "Failed to open the shimset file")
   Else
	  ConsoleWrite("Parsing file " & $fname & @CRLF)
	  
	  ; Logic: while !eof, readline, test by formatting, if good return, else next line
	  While 1
		 Local $line = FileReadLine($file)
		 If @error = -1 Then ExitLoop
		 ConsoleWrite("Read line: " & $line & @CRLF)
		 		 
		 Local $retval = StringSplit($line, " ")
		 ConsoleWrite("Found " & $retval[0] & " strings, first is <" & $retval[1] & ">, isFloat=" & StringIsInt($retval[1]) & @CRLF )
		 If ($retval[0] >= 8) AND (StringIsFloat($retval[1]) OR StringIsInt($retval[1])) Then
			; $retval[0] is the # of strings found. Returns 9, 1 is empty
			; This is probably Correct
			$shimString = $line
			ExitLoop
		 EndIf

	  WEnd
	  
   EndIf
   
   FileClose($file)

   ; Convert from space delimited to | delimited
   ;ConsoleWrite("Returning: " & StringReplace($shimstring, " ", "|") )
   ConsoleWrite("Returning: " & $shimstring & @CRLF)
   Return $shimstring
EndFunc


Func UpdateListView()
	Local $files, $fname, $count, $idx
	Local $timestamp, $shimvals, $shimstring
	
	; Clear it out first
	_GUICtrlListView_DeleteAllItems($ListID)
	
	$files = GetShimsetFiles()
	$count = _ArrayMaxIndex($files)
	
	For $idx = 1 To $count		
		; Extract the timestamp from the filename
		$timestamp = GetTimestampFromFilename($files[$idx])
		$shimstring = GetShimStringFromFile($files[$idx])
		$shimvals = StringReplace($shimstring, " ", "|")
		
		GUICtrlCreateListViewItem($idx & "|" & $timestamp & "|" & $shimvals, $ListId)			
	next
	
EndFunc


Func GetTimestampFromFilename($fname)
	; THis is hardwired, assuming the filename is shimset_YYYYMMDDHHMMSS.txt
	Return StringTrimLeft(StringTrimRight($fname, 4), 8)
EndFunc



Func OnExit()
	Exit
EndFunc   ;==>OnExit
