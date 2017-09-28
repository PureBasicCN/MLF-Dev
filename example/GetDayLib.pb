ProcedureDLL.s GetDay(Day) ;-Gives the day of the week
  
  Protected Dim Days.s(6)
  
  Days(0) = "Monday"  
  Days(1) = "Thuesday"
  Days(2) = "Wednesday"
  Days(3) = "Thursday"
  Days(4) = "Friday"
  Days(5) = "Satuday"
  Days(6) = "Sunday"
  
  ProcedureReturn Days(Day)
EndProcedure

 
  
  
  
  
; IDE Options = PureBasic 5.60 (Windows - x86)
; Folding = -
; EnableXP