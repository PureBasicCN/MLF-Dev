;MLF - Parse ASM (Extract dependancies & procedures and create DESC File) 

EnableExplicit

Global EnumHeader.s, EnumDependancies.s, EnumProcedures.s, Finalyse.b
Global ProcedureName.s, PreviousProcedureName.s, PreviousProcedureParameters.s

Declare Analyse(ASMFileName.s)
Declare Parse(Buffer.s)

Procedure Analyse(ASMFileName.s)
  Protected ASMContent.s, ASMCountDependancies, ASMLineStartDependancies = 7, ASMCurrentLine
  Protected DESCContent.s, DESCHelpFileName.s = "DESCHelpFileName" 
  Protected Buffer.s, Token
  
  ;-Parse and create ASM file
  If ReadFile(0, ASMFileName) 
    While Eof(0) = 0
      Buffer = ReadString(0)
      If FindString(Buffer, "; procedure", 0, #PB_String_NoCase) And Not FindString(Buffer, "; procedurereturn", 0, #PB_String_NoCase)
        Token = #True
        
        ;Normalize (Removes unnecessary spaces)       
        Repeat 
          Buffer = ReplaceString(Buffer, "  ", " ")
        Until FindString(Buffer, "  ") = 0        
        
        ASMContent + Buffer + #CRLF$
        ;Insert "public PB_YourProcedure()" and "PB_YourProcedure" after the comment line "; ProcedureDLL Yourprocedure"
        
        ;Example
        ; ; ProcedureDLL Add(x, y)
        ; public PB_Add
        ; PB_Add:
        ProcedureName = StringField(StringField(Buffer, 3, " "), 1, "(")
        
        ASMContent + "public PB_" + ProcedureName + #CRLF$
        ASMContent + "PB_" + ProcedureName + ":"+ #CRLF$ 
      Else
        If Token = #False
          ASMContent + Buffer + #CRLF$
        Else
          Token = #False
        EndIf
      EndIf
    Wend
    CloseFile(0)
    
    ;Create ASM file
    If CreateFile(0, ASMFileName)
      WriteString(0, ASMContent)
      CloseFile(0)
    EndIf  
  EndIf
  
  
  ;-Compose DESC Header
  EnumHeader = "ASM" + #CRLF$   ; Langage used to code the library: ASM or C
  EnumHeader + "0" + #CRLF$     ; Number of windows DLL than the library need
  EnumHeader + "OBJ" + #CRLF$   ; Library type (Can be OBJ or LIB).  
  
  EnumDependancies = ""         ; Enumeration of dependencies.
  EnumProcedures = ""           ; Enumeration of procedures.
  
  
  ;-Extract and count dependancies (Number of PureBasic library needed by the library.)
  If ReadFile(0, ASMFileName) 
    While Eof(0) = 0
      Buffer = ReadString(0)
      If FindString(Buffer, "; :System", 0, #PB_String_NoCase)
        Break
      Else
        If ASMCurrentLine >= ASMLineStartDependancies
          ASMCountDependancies + 1
          EnumDependancies + Mid(Buffer, 3) + #CRLF$
        EndIf
      EndIf
      ASMCurrentLine + 1
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
    Parse(#EOT$)
    
    
    ;-Create DESC content filename
    DESCContent = EnumHeader + Str(ASMCountDependancies) + #CRLF$ + #CRLF$ +
                  "; " + Str(ASMCountDependancies) + " Dependancies " + #CRLF$ +
                  EnumDependancies + #CRLF$ +
                  "; Your help file" + #CRLF$ +
                  DESCHelpFileName + #CRLF$ + #CRLF$ +
                  "; Procedure summary" + #CRLF$ +
                  EnumProcedures
    
    ;-Create DESC file
    If CreateFile(0,  GetFilePart(ASMFileName, #PB_FileSystem_NoExtension) + ".desc")
      WriteString(0, DESCContent)
      CloseFile(0) 
    EndIf
  EndIf 
EndProcedure

;
Procedure Parse(Buffer.s)  
  Protected ProcedureType.s       ;Type .s, .i, .... 
  Protected ProcedureParameters.s ;(Buffer$, Position.i
  Protected ProcedureParametersEnd.s ;]]])
  Protected Variable.s, n
  Protected DefaultValue.b        ;Variable has a default value
  Protected CountParameters, CurrentParameter.i       
  Protected Token
  
  If Buffer <> #EOT$
    Buffer = Trim(Mid(Buffer, 2, Len(Buffer)))
  EndIf 
  
  ;Isole public procedure
  If LCase(StringField(StringField(Buffer, 1, " "), 1, ".")) = "proceduredll" Or Buffer = #EOT$
    ProcedureName = Trim(StringField(Buffer, 1, "("))
    If FindString(ProcedureName, PreviousProcedureName) = 0
      If PreviousProcedureName <> ""
        ConsoleLog("- Parse : " + PreviousProcedureName + PreviousProcedureParameters)
        Buffer = PreviousProcedureName + PreviousProcedureParameters
        Token = #True
      EndIf
      PreviousProcedureName = ProcedureName 
      PreviousProcedureParameters = Mid(Buffer, FindString(Buffer, "("))
    Else
      PreviousProcedureParameters = Mid(Buffer, FindString(Buffer, "("))
    EndIf 
  EndIf
  
  If LCase(StringField(StringField(Buffer, 1, " "), 1, ".")) = "procedurereturn"
    Token = #True
  EndIf
  
  If Token = #True
    Select LCase(StringField(StringField(Buffer, 1, " "), 1, "."))
      Case "proceduredll", "procedurecdll"
        
        ;-Parse procedure type
        Select  StringField(StringField(Buffer, 1, " "), 2, ".")
          Case "i", "l"  
            ProcedureType =  "Long | StdCall"
            
          Case "s"
            ProcedureType = "String | StdCall | Unicode"
            
          Default
            ProcedureType = "Long | StdCall"
        EndSelect
        
        ;-Procedure without variable 
        If CountString(Buffer, "()") = 1
          CountParameters = 0
        Else
          CountParameters = CountString(Buffer, ",") + 1
        EndIf
        
        ;-Remove "ProcedureDLL"
        Buffer = Trim(Mid(Buffer, Len(Trim(StringField(Buffer, 1, " ")))+1))
        ProcedureName = StringField(Buffer, 1, "(")
        EnumProcedures + ProcedureName + ", "
        
        ;-Parse each variable
        
        ;Parameter type (Code : Coce done, ? : No test, Bug : Bad result)
        ; (Code ?) Byte: The parameter will be a byte (1 byte)
        ; (Cone ?) Word: The parameter will be a word (2 bytes)
        ; (Cone Done) Long: The parameter will be a long (4 bytes)
        ; (Code Done) String: The parameter will be a string (see below For an explaination of string handling)
        ; (Code ?) Quad: The parameter will be a quad (8 bytes)
        ; (Code Bug) Float: The parameter will be a float (4 bytes)
        ; (Code ?) Double: The parameter will be a double (8 bytes)
        ; Any: The parameter can be anything (the compiler won't check the type)
        ; (Done Bug) Array: The parameter will be an Array. It will have To be passed like: Array()
        ; LinkedList: The parameter will be an linkedlist. It will have To be passed like: List()
        
        ;Remove first bracket and last bracket
        ProcedureParameters =  Mid(Buffer, FindString(Buffer, "("), Len(Buffer) -1)
        Buffer = Mid(ProcedureParameters, 2, Len(ProcedureParameters) - 2)
        
        ProcedureParameters = "("
        
        If CountParameters <> 0
          For n = 1 To CountString(Buffer, ", ") + 1
            Variable = Trim(StringField(Buffer, n, ","))
            CurrentParameter + 1
            
            ConsoleLog("Parse parameter : " +  Variable)
            
            If FindString(Variable, "=")
              Variable = Trim(StringField(Variable, 1, "="))
              DefaultValue = #True
            EndIf
            
            Select StringField(Variable, 2, ".")
              Case "b"
                If DefaultValue
                  EnumProcedures + "[Byte], "
                Else
                  EnumProcedures + "Byte, "
                EndIf
                
              Case "i", "l"
                If DefaultValue
                  EnumProcedures + "[Long], "
                Else
                  EnumProcedures + "Long, "
                EndIf
                
              Case "d"
                If DefaultValue
                  EnumProcedures + "[Double], "
                Else
                  EnumProcedures + "Double, "
                EndIf
                
              Case "f"
                If DefaultValue
                  EnumProcedures + "[Float], "
                Else
                  EnumProcedures + "Float, "
                EndIf
                
              Case "q"
                If DefaultValue
                  EnumProcedures + "[Quad], "
                Else
                  EnumProcedures + "Quad, "
                EndIf
                
              Case "w"
                If DefaultValue
                  EnumProcedures + "[Word], "
                Else
                  EnumProcedures + "Word, "
                EndIf
                
              Case "s"
                If DefaultValue
                  EnumProcedures + "[String], "
                Else
                  EnumProcedures + "String, "
                EndIf
                
              Default
                If FindString(Variable, "$")
                  If DefaultValue
                    EnumProcedures + "[String], "
                  Else
                    EnumProcedures + "String, "
                  EndIf
                  
                ElseIf FindString(Variable, "Array", 0, #PB_String_NoCase)
                  EnumProcedures + "Array, "
                  
                ElseIf Not FindString(ProcedureType, "none", 0, #PB_String_NoCase)
                  EnumProcedures + "Long, "
                EndIf
            EndSelect
            
            If CurrentParameter = 1
              If DefaultValue
                ProcedureParameters + "[" + Variable
                ProcedureParametersEnd + "]"
              Else
                ProcedureParameters + Variable
              EndIf
            Else
              If DefaultValue 
                ProcedureParameters + " [, " + Variable
                ProcedureParametersEnd + "]"
              Else
                ProcedureParameters + " , " + Variable
              EndIf
            EndIf
          Next
          
          DefaultValue = #False
        EndIf 
        Finalyse = #True
        
      Case "procedurereturn"
        Finalyse = #False
    EndSelect
  EndIf 
  
  ;Finalyse
  If Finalyse = #True
    ProcedureParameters + ProcedureParametersEnd + ")"
    EnumProcedures + ProcedureParameters + " - Your IDE help description " + #CRLF$  + ProcedureType + #CRLF$ + #CRLF$
  EndIf
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 198
; FirstLine = 187
; Folding = ------
; EnableXP