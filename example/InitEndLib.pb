; This function is called automatically when program starts
; Delete this procedure from the description file
ProcedureDLL Init()
  MessageRequester("Info", "This is our init function")
EndProcedure

;This function is called automatically when program ends
;Delete this procedure from the description file 
ProcedureDLL Free()
  MessageRequester("Information", "This is our End function")
EndProcedure

;Your public procedures
ProcedureDLL Add(x, y)
  ProcedureReturn x+y
EndProcedure

ProcedureDLL Sub(x, y)
  ProcedureReturn x-y
EndProcedure


; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 19
; Folding = -
; EnableXP