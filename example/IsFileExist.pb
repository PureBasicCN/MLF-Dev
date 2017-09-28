ProcedureDLL IsFileExist(FileName.s) ;- Does a file exist?
  If FileSize(FileName) <> -1
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 4
; Folding = -
; EnableXP