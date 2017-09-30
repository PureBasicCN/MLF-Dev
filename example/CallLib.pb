ProcedureDLL Reset()
  Global n  = 10  
EndProcedure

ProcedureDLL Init()
   Reset()
EndProcedure

ProcedureDLL GetValue()
  ProcedureReturn n
EndProcedure



; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 5
; Folding = -
; EnableXP