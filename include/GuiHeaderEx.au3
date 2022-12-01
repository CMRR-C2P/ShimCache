#include-once
#include <WinAPITheme.au3>

Func _GUICtrlHeader_SetItemHeightByFont( $hHeader, $iHeight, $bRestoreTheme = True )
	; Remove Header theme
	_WinAPI_SetWindowTheme( $hHeader, "", "" )

	; Get font of Header control
	; Copied from _GUICtrlGetFont example by KaFu
	; See https://www.autoitscript.com/forum/index.php?showtopic=124526
	Local $hDC = _WinAPI_GetDC( $hHeader ), $hFont = _SendMessage( $hHeader, $WM_GETFONT )
	Local $hObject = _WinAPI_SelectObject( $hDC, $hFont ), $lvLogFont = DllStructCreate( $tagLOGFONT )
	_WinAPI_GetObject( $hFont, DllStructGetSize( $lvLogFont ), DllStructGetPtr( $lvLogFont ) )
	Local $hHdrfont = _WinAPI_CreateFontIndirect( $lvLogFont ) ; Original Header font
	_WinAPI_SelectObject( $hDC, $hObject )
	_WinAPI_ReleaseDC( $hHeader, $hDC )

	; Set height of Header items by applying text font with suitable height
	$hFont = _WinAPI_CreateFont( $iHeight, 0 )
	_WinAPI_SetFont( $hHeader, $hFont )
	_WinAPI_DeleteObject( $hFont )

	; Restore Header theme
	If $bRestoreTheme Then _
		_WinAPI_SetWindowTheme( $hHeader )

	; Return original Header font
	Return $hHdrfont
EndFunc
