; Resident
Structure s_struct
  List MyList.s()
EndStructure

; Userlib
ProcedureDLL AddList(*p.s_struct, String.s)  
  If *p
    AddElement(*p\MyList())
    *p\MyList() = String
  EndIf
EndProcedure

; Test Code
; *p.s_struct = AllocateStructure(s_struct)
; 
; AddList(*p, "Hello")
; AddList(*p, "There")
; 
; ForEach *p\MyList()
;   Debug *p\MyList()
; Next
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 5
; Folding = -
; EnableXP