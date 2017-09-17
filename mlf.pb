;MLF - Make Library Factory - 0.5 Alpha 

;Contributor    : falsam

;PureBasic      : 5.60 (x86)
;Compil option  : Administrator Mode

;16 September 2017 - First version  

EnableExplicit

IncludePath "include"
IncludeFile "catalog.pbi"
IncludeFile "parse.pbi"

Enumeration Font
  #FontGlobal  
  #FontH1
EndEnumeration

Enumeration Window
  #mf
EndEnumeration

Enumeration Gadget
  #mfLang  
  #mfPanel
  
  ;Panel 0
  #mfPBFrame
  #mfPBCodeName
  #mfPBSelect
  #mfPBCompil
  #mfASMCompil
  #mfLIBCompil
  #mfLog
  
  ;Panel 1
  #mFASMName
  #mfASMEdit
  
  ;Panel 2 
  #mfDESCName
  #mfDESCEdit
  #mfDESCUpdate
EndEnumeration

Global PBFileName.s, PathPart.s, FilePart.s, ExtPart.s

;-Application Summary
Declare   Start()                 ;Fonts, Window and Triggers

Declare   PBSelect()              ;Changed lang
Declare   ASMCreate()             ;Created ASM file, Parsed and modified ASM file and create description (DESC) file 
Declare   OBJCreate()             ;Created OBJ file         
Declare   DESCSave()              ;Saved DESC file if the user changes the source 
Declare   MakeStaticLib()         ;Create User libray

Declare   LangChange()            ;Changed lang (French, English)
Declare   ConsoleLog(Buffer.s)    ;Updated console log  
Declare.f AdjustFontSize(Size.l)  ;Load a font and adapt it to the DPI

Declare   Exit()                  ;Exit

Start()

Procedure Start()
  ;-Fonts
  LoadFont(#FontGlobal, "", AdjustFontSize(9))
  LoadFont(#FontH1, "", AdjustFontSize(10))
  SetGadgetFont(#PB_Default, FontID(#FontGlobal))
  
  ;-Window
  OpenWindow(#mf, 0, 0, 800, 600, m("title"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
  
  ;Select lang
  ComboBoxGadget(#mfLang, WindowWidth(#mf) - 90, 10, 80, 22)
  InitLang(#mfLang)
  
  ;Wrapper
  PanelGadget(#mfPanel, 0, 40, WindowWidth(#mf)+2, WindowHeight(#mf) - 40)
  AddGadgetItem (#mfPanel, -1, m("genasm"))
  FrameGadget(#mfPBFrame, 5, 20, WindowWidth(#mf) - 15, 100, m("selpbfile"))
  
  ;File Name
  TextGadget(#mfPBCodeName, 20, 50, WindowWidth(#mf) - 130, 22, "")
  SetGadgetColor(#mfPBCodeName, #PB_Gadget_BackColor, RGB(169, 169, 169))
  
  ;Action
  ButtonGadget(#mfPBSelect, WindowWidth(#mf) - 100, 49, 80, 24, "Select")
  ButtonGadget(#mfPBCompil, 20, 80, 80, 24, "Create ASM")
  DisableGadget(#mfPBCompil, #True)
  ButtonGadget(#mfASMCompil, 110, 80, 80, 24, "Create OBJ")
  DisableGadget(#mfASMCompil, #True)
  ButtonGadget(#mfLIBCompil, 200, 80, 80, 24, "Create LIB")
  DisableGadget(#mfLIBCompil, #True)
    
  ;View console log
  ListViewGadget(#mfLog, 5, 130, WindowWidth(#mf) - 15, 400, #PB_Editor_ReadOnly)
  SetGadgetColor(#mfLog, #PB_Gadget_BackColor, RGB(169, 169, 169))
  ConsoleLog(m("welcome"))
  ConsoleLog("PureBasic version : " + Str(#PB_Compiler_Version) + " " + GetCompilerProcessor())
  
  ;View code ASM
  AddGadgetItem (#mfPanel, -1, m("viewasm"))
  TextGadget(#mFASMName, 5, 10, WindowWidth(#mf) - 15, 22, "") 
  SetGadgetFont(#mFASMName, FontID(#FontH1))
  SetGadgetColor(#mFASMName, #PB_Gadget_BackColor, RGB(192, 192, 192))
  EditorGadget(#mfASMEdit, 5, 35, WindowWidth(#mf) - 15, 470)
  SetGadgetColor(#mfASMEdit, #PB_Gadget_BackColor, RGB(211, 211, 211))
  
  ;View code DESC
  AddGadgetItem(#mfPanel, -1, m("viewdesc"))
  TextGadget(#mfDESCName, 5, 10, WindowWidth(#mf) - 15, 22, "") 
  SetGadgetFont(#mfDESCName, FontID(#FontH1))
  SetGadgetColor(#mfDESCName, #PB_Gadget_BackColor, RGB(192, 192, 192))
  EditorGadget(#mfDESCEdit, 5, 35, WindowWidth(#mf) - 15, 460)
  SetGadgetColor(#mfDESCEdit, #PB_Gadget_BackColor, RGB(211, 211, 211))
  ButtonGadget(#mfDESCUpdate, WindowWidth(#mf) - 90, 500, 80, 22, m("save"))
  CloseGadgetList()
  
  ;-Triggers
  BindGadgetEvent(#mfLang, @LangChange())           ;Change lang
  BindGadgetEvent(#mfPBSelect, @PBSelect())         ;Select PureBasic code
  BindGadgetEvent(#mfPBCompil, @ASMCreate())        ;Create ASM file, Parsed and modified ASM file and create description (DESC) file 
  BindGadgetEvent(#mfASMCompil, @OBJCreate())       ;Create OBJ file
  BindGadgetEvent(#mfDESCUpdate, @DESCSave())       ;Save DESC file if the user changes the source 
  BindGadgetEvent(#mfLIBCompil, @MakeStaticLib())   ;Create User libray
  BindEvent(#PB_Event_CloseWindow, @Exit())         ;Exit
  
  Repeat : WaitWindowEvent() : ForEver
EndProcedure

;-
;Select PureBasic filename
Procedure PBSelect()
  PBFileName = OpenFileRequester(m("selpbfile"), "", "PB file | *.pb", 0)  
  If PBFileName
    PathPart = GetPathPart(PBFileName)
    FilePart = GetFilePart(PBFileName)
    ExtPart  = GetExtensionPart(PBFileName)
    
    SetGadgetText(#mfPBCodeName, " " + PBFileName)
    DisableGadget(#mfPBCompil, #False)
    ConsoleLog("Click the Create ASM button.") 
  EndIf
EndProcedure

;Create ASM file, Parsed and modified ASM file and create description (DESC) file
Procedure ASMCreate()
  Protected Compiler, Buffer.s, FileName.s
  
  ;Delete previous library
  FileName = #DQUOTE$ + #PB_Compiler_Home + "PureLibraries\UserLibraries\" + LSet(FilePart, Len(FilePart) - Len(ExtPart)-1) + #DQUOTE$
  If ReadFile(0, FileName)
    CloseFile(0)
    ConsoleLog("Delete previous LIB file")
    If Not DeleteFile(FileName, #PB_FileSystem_Force)
      ConsoleLog(m("errordelete") + " " + Filename)
    EndIf
  EndIf
  
  ;Delete previous PureLibrariesMaker.log
  FileName = "PureLibrariesMaker.log" 
  If ReadFile(0, FileName)
    CloseFile(0)
    If Not DeleteFile(FileName, #PB_FileSystem_Force)
      ConsoleLog(m("errordelete") + " " + Filename)
    EndIf
  EndIf    
  
  ;Delete YOUR previous ASM Files if exist
  FileName = LSet(FilePart, Len(FilePart) - Len(ExtPart)) + "asm" 
  If ReadFile(0, FileName)
    CloseFile(0)
    ConsoleLog("Delete your previous ASM file")
    If Not DeleteFile(FileName, #PB_FileSystem_Force)
      ConsoleLog(m("errordelete") + " " + Filename)
    EndIf
  EndIf    
  
  ;Delete previous PureBasic.exe file if exist
  FileName = "PureBasic.exe" 
  If ReadFile(0, FileName)
    CloseFile(0)
    ConsoleLog("Delete previous PureBasic.exe")
    If Not DeleteFile(FileName, #PB_FileSystem_Force)
      ConsoleLog(m("errordelete") + " " + Filename)
    EndIf
  EndIf    
  
  ;Delete previous PureBasic.asm file if exist
  FileName = "PureBasic.asm" 
  If ReadFile(0, FileName)
    CloseFile(0)
    ConsoleLog("Delete previous purebasic.asm")
    If Not DeleteFile(FileName, #PB_FileSystem_Force)
      ConsoleLog(m("errordelete") + " " + Filename)
    EndIf
  EndIf    
  
  ;Compile PB -> ASM 
  ConsoleLog("Waiting for compile ...")
  Compiler = RunProgram(#PB_Compiler_Home + "Compilers\pbcompiler.exe", #DQUOTE$ + PBFileName + #DQUOTE$ + " /COMMENTED" , "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If Compiler
    While ProgramRunning(Compiler)
      If AvailableProgramOutput(Compiler)
        ReadProgramString(Compiler)
        Buffer = ReadProgramString(Compiler)
        ConsoleLog(Buffer)
      EndIf
    Wend
    CloseProgram(Compiler)
    ;DeleteFile("PureBasic.exe", #PB_FileSystem_Force)
    
    FileName = LSet(FilePart, Len(FilePart) - Len(ExtPart)) + "asm"
    If Not RenameFile("PureBasic.asm", Filename)
      ConsoleLog(m("libexist"))
      ConsoleLog(m("errordelete") + " " + Filename)
    Else
      ConsoleLog("Rename PureBasic.asm to " + FileName)       
      
      ;Parse ASM (Extract dependancies & procedures and create DESC File) 
      Analyse(FileName)
      
      ;Show ASM
      SetGadgetText(#mFASMName, FileName)
      SetGadgetText(#mFASMEdit, "") ;Clear editor
      If ReadFile(0, Filename)
        While Eof(0) = 0
          AddGadgetItem(#mfASMEdit, -1, ReadString(0))
        Wend
        CloseFile(0)
      EndIf
      
      ;Show DESC
      FileName = LSet(FilePart, Len(FilePart) - Len(ExtPart)) + "desc"  
      SetGadgetText(#mfDESCName, FileName)
      SetGadgetText(#mfDESCEdit, "") ;Clear editor
      If ReadFile(0, Filename)
        While Eof(0) = 0
          AddGadgetItem(#mfDESCEdit, -1, ReadString(0))
        Wend
        CloseFile(0)
        ConsoleLog("You can view the ASM and DESC sources before create OBJ")
      EndIf
      DisableGadget(#mfASMCompil, #False)
    EndIf 
  EndIf
EndProcedure

;Create OBJ File
Procedure OBJCreate()
  Protected Compiler
  Protected ASMFilename.s = #DQUOTE$ + LSet(FilePart, Len(FilePart) - Len(ExtPart)) + "asm" + #DQUOTE$
  Protected OBJFileName.s = #DQUOTE$ + LSet(FilePart, Len(FilePart) - Len(ExtPart)) + "obj" + #DQUOTE$
    
  Compiler = RunProgram(#PB_Compiler_Home + "Compilers\FAsm.exe", "" + ASMFilename + " " + OBJFileName, "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If Compiler
    While ProgramRunning(Compiler)
      If AvailableProgramOutput(Compiler)
        ConsoleLog(ReadProgramString(Compiler))
      EndIf
    Wend
    CloseProgram(Compiler) 
    DisableGadget(#mfLIBCompil, #False)
  EndIf
EndProcedure

;Save DESC file if the user changes the source 
Procedure DESCSave()
  Protected DESCFileName.s = LSet(FilePart, Len(FilePart) - Len(ExtPart)) + "desc"
  Protected DESCContent.s = GetGadgetText(#mfDESCEdit)
  
  If CreateFile(0, DESCFileName)
    If WriteString(0, DESCContent)
      ConsoleLog(m("successdesc"))
      MessageRequester("Informaton", m("successdesc"))
    Else
      ConsoleLog(m("errordesc"))
      MessageRequester("Informaton", m("errordesc"))
    EndIf
    CloseFile(0)
  EndIf  
EndProcedure

;Make Static Lib
Procedure MakeStaticLib()  
  Protected Compiler
  Protected SourcePath.s      = #DQUOTE$ + LSet(FilePart, Len(FilePart) - Len(ExtPart)) + "Desc" + #DQUOTE$
  Protected DestinationPath.s = #DQUOTE$ + #PB_Compiler_Home + "PureLibraries\UserLibraries\" + #DQUOTE$  
  
  Compiler = RunProgram(#PB_Compiler_Home + "sdk\LibraryMaker.exe", SourcePath + " /TO " + DestinationPath, "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  
  If Compiler
    While ProgramRunning(Compiler)
      If AvailableProgramOutput(Compiler)
        ConsoleLog(ReadProgramString(Compiler))
      EndIf
    Wend
    CloseProgram(Compiler)
    If ReadFile(0, "PureLibrariesMaker.log")
      While Eof(0) = 0
        ConsoleLog(ReadString(0))
      Wend      
    EndIf
    ConsoleLog(m("successlib"))
  Else
    ConsoleLog(m("errorlib"))
  EndIf
EndProcedure

;-
;-Tools
Procedure LangChange()
  SetLang(GetGadgetState(#mfLang))
  SetWindowTitle(#mf, m("title"))
  SetGadgetItemText(#mfPanel, 0, m("genasm"))
  SetGadgetText(#mfPBFrame, m("selpbfile"))
  SetGadgetItemText(#mfPanel, 1, m("viewasm"))
  SetGadgetItemText(#mfPanel, 2, m("viewdesc"))
  SetGadgetText(#mfDESCUpdate, m("save"))
EndProcedure

Procedure ConsoleLog(Buffer.s)
  Protected TimeStamp.s = "[" + FormatDate("%hh:%ii:%ss", Date()) + "]  "
  
  AddGadgetItem(#mfLog, -1, TimeStamp + Buffer)
  SetGadgetState(#mfLog, CountGadgetItems(#mfLog) -1)
EndProcedure

Procedure.f AdjustFontSize(Size.l)
  Define lPpp.l = GetDeviceCaps_(GetDC_(#Null), #LOGPIXELSX)
  ProcedureReturn (Size * 96) / lPpp
EndProcedure

;-The end
Procedure Exit()  
  End
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 4
; Folding = ------
; Markers = 53,122
; EnableXP
; EnableAdmin
; Executable = mlf.exe