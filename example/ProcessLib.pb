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


; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 14
; Folding = -
; EnableXP