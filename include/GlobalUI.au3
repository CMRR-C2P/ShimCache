; -----------------------------------------------------------------------------
; shimcache UI message handlers
; -----------------------------------------------------------------------------

; limit the minimum size of the GUI
Func WM_GETMINMAXINFO($hWnd, $Msg, $wParam, $lParam)
	#forceref $hWnd, $Msg, $wParam, $lParam
	If ($hWnd = $hGUI) Then
		Local $tagMaxinfo = DllStructCreate("int;int;int;int;int;int;int;int;int;int", $lParam)
		DllStructSetData($tagMaxinfo,  7, $winW + 16) ; min width
		DllStructSetData($tagMaxinfo,  8, $winH + 38) ; min height
		DllStructSetData($tagMaxinfo,  9, 99999) ; max width
		DllStructSetData($tagMaxinfo, 10, 99999) ; max height
		Return $GUI_RUNDEFMSG
	EndIf
EndFunc ;==>WM_GETMINMAXINFO


; WM_NOTIFY message handler
Func WM_NOTIFY( $hWnd, $iMsg, $wParam, $lParam )
	#forceref $hWnd, $iMsg, $wParam
	Local Static $iLvIndex, $iArrayIdx, $iSelected, $tRect = DllStructCreate( $tagRECT ), $pRect = DllStructGetPtr( $tRect ), $hDC
	Local $tNMHDR = DllStructCreate( $tagNMHDR, $lParam )
	Local $hWndFrom = HWnd( DllStructGetData( $tNMHDR, "hWndFrom" ) )
	Local $iCode = DllStructGetData( $tNMHDR, "Code" )

	Switch $hWndFrom
		Case $hList
			Switch $iCode
				Case $NM_CUSTOMDRAW
					Local $tNMLVCustomDraw = DllStructCreate( $tagNMLVCUSTOMDRAW, $lParam )
					Local $dwDrawStage = DllStructGetData( $tNMLVCustomDraw, "dwDrawStage" )
					Switch $dwDrawStage                                ; Specifies the drawing stage
						; Stage 1
						Case $CDDS_PREPAINT                              ; Before the paint cycle begins
							$hDC = DllStructGetData( $tNMLVCustomDraw, "hDC" ) ; Device context
							_WinAPI_SelectObject( $hDC, $hListFont )             ; Set original font
							_WinAPI_SetBkMode( $hDC, $TRANSPARENT )            ; Transparent background
							Return $CDRF_NOTIFYITEMDRAW+$CDRF_NEWFONT      ; Notify the parent window before an item is painted

						; Stage 2
						Case $CDDS_ITEMPREPAINT                          ; Before an item is painted
							$iLvIndex = DllStructGetData( $tNMLVCustomDraw, "dwItemSpec" )                           ; Item index
							$iArrayIdx = DllStructGetData( $tNMLVCustomDraw, "lItemlParam" ) - 1000                  ; Array index
							$iSelected = GUICtrlSendMsg( $idList, $LVM_GETITEMSTATE, $iLvIndex, $LVIS_SELECTED ) ; Item state
							Return $CDRF_NOTIFYSUBITEMDRAW                 ; Notify the parent window before a subitem is painted

						; Stage 3
						Case BitOR( $CDDS_ITEMPREPAINT, $CDDS_SUBITEM )  ; Before a subitem is painted: Default painting of checkbox, image, icon
							Return $CDRF_NOTIFYPOSTPAINT                   ; Notify the parent window after a subitem is painted

						; Stage 4
						Case BitOR( $CDDS_ITEMPOSTPAINT, $CDDS_SUBITEM ) ; After a subitem has been painted: Custom painting of text lines
							Local $iSubItem = DllStructGetData( $tNMLVCustomDraw, "iSubItem" ) ; Subitem index

							; Subitem rectangle
							DllStructSetData( $tRect, "Top", $iSubItem )
							DllStructSetData( $tRect, "Left", $iSubItem ? $LVIR_BOUNDS : $LVIR_LABEL )
							GUICtrlSendMsg( $idList, $LVM_GETSUBITEMRECT, $iLvIndex, $pRect )

							; Subitem text color
							DllCall( "gdi32.dll", "int", "SetTextColor", "handle", $hDC, "int", ( $iSelected And $fListHasFocus ) ? 0xFFFFFF : 0x000000 ) ; _WinAPI_SetTextColor

							; Custom painting of first text line in subitem
							RepaintFirstTextLine( $idList, $iLvIndex, $iSubItem, $iSelected, $fListHasFocus, $hDC, $tRect )

							; Custom painting of second text line in subitem
							If Not $listData[$iArrayIdx][$iSubItem] Then Return $CDRF_NEWFONT
							DllStructSetData( $tRect, "Top", DllStructGetData( $tRect, "Top" ) + 12 ) ; Top margin
							DllCall( "user32.dll", "int", "DrawTextW", "handle", $hDC, "wstr", $listData[$iArrayIdx][$iSubItem], "int", -1, "struct*", $tRect, "uint", $DT_WORD_ELLIPSIS ) ; _WinAPI_DrawText

							Return $CDRF_NEWFONT                           ; $CDRF_NEWFONT must be returned after changing font or colors
					EndSwitch
				Case $NM_KILLFOCUS
					If $fListHasFocus Then
						GUICtrlSendMsg( $idList, $LVM_REDRAWITEMS, 0, $listRows - 1 )
						$fListHasFocus = 0
					EndIf
				Case $NM_SETFOCUS
					If Not $fListHasFocus Then _
						GUICtrlSendMsg( $idList, $LVM_REDRAWITEMS, 0, $listRows - 1 )
					$fListHasFocus = 2
			EndSwitch
	EndSwitch
	Return $GUI_RUNDEFMSG
EndFunc

; WM_ACTIVATE message handler
Func WM_ACTIVATE( $hWnd, $iMsg, $wParam, $lParam )
	#forceref $iMsg, $lParam
	If $hWnd = $hGui Then _
		$fListHasFocus = BitAND( $wParam, 0xFFFF ) ? 1 : 0
	Return $GUI_RUNDEFMSG
EndFunc
