; This function is called automatically when program starts
ProcedureDLL AttachProcess()
  MessageRequester("Info", "This is our init function")
EndProcedure

;This function is called automatically when program ends
ProcedureDLL DetachProcess()
  MessageRequester("Information", "This is our End function")
EndProcedure

;Your public procedures
ProcedureDLL Add(x, y) ;- Simple Add 
  ProcedureReturn x+y
EndProcedure

ProcedureDLL Sub(x, y) ;- Simple Sub
  ProcedureReturn x-y
EndProcedure

;Test
; ;Call AttachProcess()
; Debug "Start" 
; Delay(2000)
; Debug Add(2, 3)
; Delay(2000)
; Debug Sub(20, 10)
; Delay(2000)
; Debug "fin"
; Delay(2000)
;Call DetachProcess()
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 3
; Folding = -
; EnableXP