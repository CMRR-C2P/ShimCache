#include-once

Func _GUICtrlListView_GetHeightToFitRows( $hListView, $iRows )
	; Get height of Header control
	Local $tRect = _WinAPI_GetClientRect( $hListView )
	Local $hHeader = _GUICtrlListView_GetHeader( $hListView )
	Local $tWindowPos = _GUICtrlHeader_Layout( $hHeader, $tRect )
	Local $iHdrHeight = DllStructGetData( $tWindowPos , "CY" )
	; Get height of ListView item 0 (item 0 must exist)
	Local $aItemRect = _GUICtrlListView_GetItemRect( $hListView, 0, 0 )
	; Return height of ListView to fit $iRows items
	; Including Header height and 8 pixels of additional room
	Return ( $aItemRect[3] - $aItemRect[1] ) * $iRows + $iHdrHeight + 8
EndFunc

Func _GUICtrlListView_SetItemHeightByFont( $hListView, $iHeight )
	; Get font of ListView control
	; Copied from _GUICtrlGetFont example by KaFu
	; See https://www.autoitscript.com/forum/index.php?showtopic=124526
	Local $hDC = _WinAPI_GetDC( $hListView ), $hFont = _SendMessage( $hListView, $WM_GETFONT )
	Local $hObject = _WinAPI_SelectObject( $hDC, $hFont ), $lvLOGFONT = DllStructCreate( $tagLOGFONT )
	_WinAPI_GetObject( $hFont, DllStructGetSize( $lvLOGFONT ), DllStructGetPtr( $lvLOGFONT ) )
	Local $hLVfont = _WinAPI_CreateFontIndirect( $lvLOGFONT ) ; Original ListView font
	_WinAPI_SelectObject( $hDC, $hObject )
	_WinAPI_ReleaseDC( $hListView, $hDC )
	_WinAPI_DeleteObject( $hFont )

	; Set height of ListView items by applying text font with suitable height
	$hFont = _WinAPI_CreateFont( $iHeight, 0 )
	_WinAPI_SetFont( $hListView, $hFont )
	_WinAPI_DeleteObject( $hFont )

	; Restore font of Header control
	Local $hHeader = _GUICtrlListView_GetHeader( $hListView )
	If $hHeader Then _WinAPI_SetFont( $hHeader, $hLVfont )

	; Return original ListView font
	Return $hLVfont
EndFunc
