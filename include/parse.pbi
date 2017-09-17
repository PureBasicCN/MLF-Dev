EnableExplicit

Global EnumHeader.s, EnumDependancies.s, EnumProcedures.s, Finalyse.b

Declare Analyse(ASMFileName.s)
Declare Parse(Buffer.s)

Procedure Analyse(ASMFileName.s)
  Protected ASMContent.s
  Protected DESCContent.s
  Protected Token
  Protected Buffer.s, CountDependancies, LineStartDependancies = 7, CurrentLine
  Protected HelpFileName.s = "HelpFileName" 
  
  ;-Parse ASM file
  If ReadFile(0, ASMFileName) 
    While Eof(0) = 0
      Buffer = ReadString(0)
      If FindString(Buffer, "; procedure", 0, #PB_String_NoCase) And Not FindString(Buffer, "; procedurereturn", 0, #PB_String_NoCase)
        Token = #True
        ASMContent + Buffer + #CRLF$
        ;Insert public PB_YourProcedure() and PB_YourProcedure after the comment line ; ProcedureDL Yourprocedure
        
        ;Example
        ; ProcedureDLL Add(x, y)
        ; public PB_Add
        ; PB_Add:
        ASMContent + "public PB_" + StringField(StringField(Buffer, 3, " "), 1, "(") + #CRLF$
        ASMContent + "PB_" + StringField(StringField(Buffer, 3, " "), 1, "(") + ":"+ #CRLF$ 
      Else
        If Token = #False
          ASMContent + Buffer + #CRLF$
        Else
          Token = #False
        EndIf
      EndIf
    Wend
    CloseFile(0)
  EndIf
  
  ;-Create ASM file
  If CreateFile(0, "mylib.asm")
    WriteString(0, ASMContent)
    CloseFile(0)
  EndIf
  
  ;-Compose DESC Header
  EnumHeader = "ASM" + #CRLF$
  EnumHeader + "0" + #CRLF$
  EnumHeader + "OBJ" + #CRLF$
  
  ;-Extract and count dependancies
  If ReadFile(0, ASMFileName) 
    While Eof(0) = 0
      Buffer = ReadString(0)
      If FindString(Buffer, "; :System", 0, #PB_String_NoCase)
        Break
      Else
        If CurrentLine >= LineStartDependancies
          CountDependancies + 1
          EnumDependancies + Mid(Buffer, 3) + #CRLF$
        EndIf
      EndIf
      CurrentLine + 1
    Wend
    CloseFile(0)
  EndIf
  
  ;-Extract procedures (Use the procedure Parse)
  If ReadFile(0, ASMFileName) 
    While Eof(0) = 0
      Buffer = ReadString(0)
      If FindString(Buffer, "; procedure", 0, #PB_String_NoCase)
        Parse(Buffer)
      EndIf
    Wend
    CloseFile(0)
  EndIf
  
  ;-Create DESC content filename
  DESCContent = EnumHeader + Str(CountDependancies) + #CRLF$ + #CRLF$ +
                "; " + Str(CountDependancies) + " Dependancies " + #CRLF$ +
                EnumDependancies + #CRLF$ +
                "; Your help file" + #CRLF$ +
                HelpFileName + #CRLF$ + #CRLF$ +
                "; Procedure summary" + #CRLF$ +
                EnumProcedures
  
  ;-Create DESC file
  If CreateFile(0, "mylib.Desc")
    WriteString(0, DESCContent)
    CloseFile(0) 
  EndIf
EndProcedure


;
Procedure Parse(Buffer.s)
  Protected Function.s, Variable.s, ReturnValue.s, n 
  
  Buffer = Trim(Mid(Buffer, 2, Len(Buffer)))
  
  Select LCase(StringField(StringField(Buffer, 1, " "), 1, "."))
    Case "proceduredll", "procedurecdll"
      
      ;-Parse type de procedure
      Select  StringField(StringField(Buffer, 1, " "), 2, ".")
        Case "i", "l"
          ReturnValue =  "Long | StdCall"
          
        Case "s"
          ReturnValue = "String | StdCall"
          
        Default
          ReturnValue = "Long | StdCall"
      EndSelect
      
      ;-Procedure without variable 
      If CountString(Buffer, "()") = 1
        ReturnValue = "None | StdCall"        
      EndIf
      
      Buffer = Trim(Mid(Buffer, Len(Trim(StringField(Buffer, 1, " ")))+1))
      
      Function = "(" + StringField(Buffer, 2, "(") 
      
      Buffer = RemoveString(Buffer, " ")
      
      ;-Extracti procedure name - Extraction du nom de la procedure
      EnumProcedures + StringField(Buffer, 1, "(") + ", "
      
      ;Parameter type
      ; (ok) Byte: The parameter will be a byte (1 byte)
      ; (ok) Word: The parameter will be a word (2 bytes)
      ; (ok) Long: The parameter will be a long (4 bytes)
      ; (ok) String: The parameter will be a string (see below For an explaination of string handling)
      ; (ok) Quad: The parameter will be a quad (8 bytes)
      ; (ok) Float: The parameter will be a float (4 bytes)
      ; (ok) Double: The parameter will be a double (8 bytes)
      ; Any: The parameter can be anything (the compiler won't check the type)
      ; Array: The parameter will be an Array. It will have To be passed like: Array()
      ; LinkedList: The parameter will be an linkedlist. It will have To be passed like: List()
        
      ;Remove first bracket - Supprime la premiére parenthése
      Buffer =  StringField(Buffer, 2, "(")
      
      ;Remove last bracket - Supprime la derniere parenthése
      Buffer =  LSet(Buffer, Len(Buffer)-1)
      
      
      ;Parse each variable - Parse chaque variable 
      For n = 1 To CountString(Buffer, ",") + 1
        Variable = StringField(Buffer, n, ",")
                
        Select StringField(Variable, 2, ".")
          Case "b"
            EnumProcedures + "Bytes, "
            
          Case "i", "l"
            EnumProcedures + "Long, "
            
          Case "d"
            EnumProcedures + "Double, "
            
          Case "f"
            EnumProcedures + "Float, "
            
          Case "q"
            EnumProcedures + "Quad, "

          Case "w"
            EnumProcedures + "Word, "
            
          Case "s"
            EnumProcedures + "String, "
            
          Default
            If Not FindString(ReturnValue, "none", 0, #PB_String_NoCase)
              EnumProcedures + "Long, "
            EndIf
        EndSelect
      Next
      Finalyse = #True
      
    Case "procedurereturn"
      Finalyse = #False
  EndSelect
  
  ;Finalyse
  If Finalyse = #True
    EnumProcedures + Function + " - " + #CRLF$  + ReturnValue + #CRLF$ + #CRLF$
  EndIf
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; FirstLine = 138
; Folding = ---
; EnableXP