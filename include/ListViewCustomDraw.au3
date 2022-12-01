#include-once

Func RepaintFirstTextLine( $idListView, $iIndex, $iSubItem, $bSel, $bFocus, $hDC, $tRect, $iCol0LeftMargin = 2 )
	Local Static $tLVitem = DllStructCreate( $tagLVITEM ), $pLVitem = DllStructGetPtr( $tLVitem )
	Local Static $tBuffer = DllStructCreate( "wchar Text[4096]" ), $pBuffer = DllStructGetPtr( $tBuffer )
	Local Static $hBrushNormal = _WinAPI_CreateSolidBrush( 0xFFFFFF ), $hBrushHighLight = _WinAPI_GetSysColorBrush( $COLOR_HIGHLIGHT ), $hBrushButtonFace = _WinAPI_GetSysColorBrush( $COLOR_BTNFACE )

	; Delete default painting of first text line because it's painted in the middle of the subitem
	DllCall( "user32.dll", "int", "FillRect", "handle", $hDC, "struct*", $tRect, "handle", $bSel ? ( $bFocus ? $hBrushHighLight : $hBrushButtonFace ) : $hBrushNormal ) ; _WinAPI_FillRect

	; Left margin of item text
	DllStructSetData( $tRect, "Left", DllStructGetData( $tRect, "Left" ) + ( $iSubItem ? 6 : $iCol0LeftMargin ) )

	; Extract first text line directly from ListView
	DllStructSetData( $tLVitem, "Mask", $LVIF_TEXT )
	DllStructSetData( $tLVitem, "SubItem", $iSubItem )
	DllStructSetData( $tLVitem, "Text", $pBuffer )
	DllStructSetData( $tLVitem, "TextMax", 4096 )
	GUICtrlSendMsg( $idListView, $LVM_GETITEMTEXTW, $iIndex, $pLVitem )

	; Draw first text line in item
	DllCall( "user32.dll", "int", "DrawTextW", "handle", $hDC, "wstr", DllStructGetData( $tBuffer, "Text" ), "int", -1, "struct*", $tRect, "uint", $DT_WORD_ELLIPSIS ) ; _WinAPI_DrawText
EndFunc

Func RepaintFirstTextLineCol0( $idListView, $iIndex, $iSubItem, $bSel, $bFocus, $hDC, $tRect, $iCol0LeftMargin = 2 )
	Local Static $tLVitem = DllStructCreate( $tagLVITEM ), $pLVitem = DllStructGetPtr( $tLVitem )
	Local Static $tBuffer = DllStructCreate( "wchar Text[4096]" ), $pBuffer = DllStructGetPtr( $tBuffer )
	Local Static $hBrushNormal = _WinAPI_CreateSolidBrush( 0xFFFFFF ), $hBrushHighLight = _WinAPI_GetSysColorBrush( $COLOR_HIGHLIGHT ), $hBrushButtonFace = _WinAPI_GetSysColorBrush( $COLOR_BTNFACE )

	; Column 0 issue due to column 0 and other columns have different left margins
	DllStructSetData( $tRect, "Left", DllStructGetData( $tRect, "Left" ) - 8 )

	; Delete default painting of first text line because it's painted in the middle of the subitem
	DllCall( "user32.dll", "int", "FillRect", "handle", $hDC, "struct*", $tRect, "handle", $bSel ? ( $bFocus ? $hBrushHighLight : $hBrushButtonFace ) : $hBrushNormal ) ; _WinAPI_FillRect

	; Restore left margin
	DllStructSetData( $tRect, "Left", DllStructGetData( $tRect, "Left" ) + 8 )

	; Left margin of item text
	DllStructSetData( $tRect, "Left", DllStructGetData( $tRect, "Left" ) + ( $iSubItem ? 6 : $iCol0LeftMargin ) )

	; Extract first text line directly from ListView
	DllStructSetData( $tLVitem, "Mask", $LVIF_TEXT )
	DllStructSetData( $tLVitem, "SubItem", $iSubItem )
	DllStructSetData( $tLVitem, "Text", $pBuffer )
	DllStructSetData( $tLVitem, "TextMax", 4096 )
	GUICtrlSendMsg( $idListView, $LVM_GETITEMTEXTW, $iIndex, $pLVitem )

	; Draw first text line in item
	DllCall( "user32.dll", "int", "DrawTextW", "handle", $hDC, "wstr", DllStructGetData( $tBuffer, "Text" ), "int", -1, "struct*", $tRect, "uint", $DT_WORD_ELLIPSIS ) ; _WinAPI_DrawText
EndFunc

Func ClearSubitem( $bSel, $bFocus, $hDC, $tRect )
	Local Static $hBrushNormal = _WinAPI_CreateSolidBrush( 0xFFFFFF ), $hBrushHighLight = _WinAPI_GetSysColorBrush( $COLOR_HIGHLIGHT ), $hBrushButtonFace = _WinAPI_GetSysColorBrush( $COLOR_BTNFACE )

	; Delete default painting of first text line because it's painted in the middle of the subitem
	DllCall( "user32.dll", "int", "FillRect", "handle", $hDC, "struct*", $tRect, "handle", $bSel ? ( $bFocus ? $hBrushHighLight : $hBrushButtonFace ) : $hBrushNormal ) ; _WinAPI_FillRect
EndFunc

Func DrawFirstTextLine( $idListView, $iIndex, $iSubItem, $hDC, $tRect, $iCol0LeftMargin = 2 )
	Local Static $tLVitem = DllStructCreate( $tagLVITEM ), $pLVitem = DllStructGetPtr( $tLVitem )
	Local Static $tBuffer = DllStructCreate( "wchar Text[4096]" ), $pBuffer = DllStructGetPtr( $tBuffer )

	; Left margin of item text
	DllStructSetData( $tRect, "Left", DllStructGetData( $tRect, "Left" ) + ( $iSubItem ? 6 : $iCol0LeftMargin ) )

	; Extract first text line directly from ListView
	DllStructSetData( $tLVitem, "Mask", $LVIF_TEXT )
	DllStructSetData( $tLVitem, "SubItem", $iSubItem )
	DllStructSetData( $tLVitem, "Text", $pBuffer )
	DllStructSetData( $tLVitem, "TextMax", 4096 )
	GUICtrlSendMsg( $idListView, $LVM_GETITEMTEXTW, $iIndex, $pLVitem )

	; Draw first text line in item
	DllCall( "user32.dll", "int", "DrawTextW", "handle", $hDC, "wstr", DllStructGetData( $tBuffer, "Text" ), "int", -1, "struct*", $tRect, "uint", $DT_WORD_ELLIPSIS ) ; _WinAPI_DrawText
EndFunc
