ProcedureDLL MessageInit()
  Structure NewMessage
    message.s
  EndStructure
  Global NewList Messages.NewMessage()
EndProcedure

ProcedureDLL StoreMessage(Buffer.s)
  AddElement(Messages())
  Messages()\message = Buffer
EndProcedure

ProcedureDLL.s ShowMessages()
  Protected Buffer.s
  
  ForEach Messages()
    Buffer + Messages()\message + #CRLF$
  Next
  ProcedureReturn Buffer
EndProcedure

   


; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 15
; Folding = -
; EnableXP