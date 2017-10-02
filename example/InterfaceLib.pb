;MLF - Example Interface 
;Contributor : vincent78955 (French Forum) 

Interface I_Rect
Draw()
Erase()
GetX()
EndInterface

Structure S_Rect
*vTable
x1.l
x2.l
y1.l
y2.l
EndStructure

Procedure Draw_Rectangle(*this.S_Rect)
;…
EndProcedure

Procedure Erase_Rectangle(*this.S_Rect)
;…
EndProcedure

Procedure _GetX(*this.S_Rect)
  ProcedureReturn *this\x1
EndProcedure

ProcedureDLL MyRect(x1.l, x2.l, y1.l, y2.l)
  *Rect.S_Rect = AllocateMemory(SizeOf(S_Rect))
  *Rect\vTable = ?Table_Rect
  *Rect\x1 = x1
  *Rect\x2 = x2
  *Rect\y1 = y1
  *Rect\y2 = y2
  ProcedureReturn *Rect
EndProcedure

DataSection
Table_Rect:  
  Data.i @Draw_Rectangle()
  Data.i @Erase_Rectangle()
  Data.i @_Getx()
EndDataSection

; To be tested like this ...
;Interface Rectangle
;Draw()
;Erase()
;GetX()
;EndInterface

;Rect1.Rectangle = MyRect(50000, 10, 0, 20)

;Debug Rect1\GetX()


; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 1
; Folding = -
; EnableXP
; Executable = C:\Users\Eric\Desktop\test.exe