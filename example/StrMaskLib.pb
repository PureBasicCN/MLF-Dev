;Example procedure with optional parameters 

ProcedureDLL.s StrMask(Value$) ;-Transforms a string into monetary format. 
  ProcedureReturn Value$ + " €"
EndProcedure

ProcedureDLL.s StrMask2(Value$, CurrencySymbol$ = "€")
  ProcedureReturn Value$ + " " + CurrencySymbol$
EndProcedure

ProcedureDLL.s StrMask3(Value$, CurrencySymbol$ = "€", Negative.i = #True)
  Protected Buffer.s
  
  If Negative = #True
    Buffer = "-" + Value$ + " " + CurrencySymbol$
  EndIf
  ProcedureReturn Buffer
EndProcedure


; IDE Options = PureBasic 5.60 (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 2
; Folding = -
; EnableXP
; Executable = mydll.dll