ProcedureDLL Add(x, y);- Simple ADD                        
  ProcedureReturn x + y
EndProcedure

ProcedureDLL Sub(x, y);-Simple sub                         
  ProcedureReturn x - y
EndProcedure

ProcedureDLL Null()   ;-Null!! It's useless. 
EndProcedure


; IDE Options = PureBasic 5.60 (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 8
; Folding = -
; EnableXP
; Executable = mydll.dll