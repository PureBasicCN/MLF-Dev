ProcedureDLL MessageInit() ;-Init Messages
  Structure NewMessage
    message.s
  EndStructure
  Global NewList Messages.NewMessage()
EndProcedure

ProcedureDLL StoreMessage(Buffer.s) ;-Adds a message in the queue
  AddElement(Messages())
  Messages()\message = Buffer
EndProcedure

ProcedureDLL.s ShowMessages() ;-Displays all messages
  Protected Buffer.s
  
  ForEach Messages()
    Buffer + Messages()\message + #CRLF$
  Next
  ProcedureReturn Buffer
EndProcedure

   


; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 12
; Folding = -
; EnableXP