;-=============================================================================
; 
; Project ...... : MLF : Make Library Factory
; Name ......... : mlf.pb 
; Type ......... : Main Code
; Author ....... : falsam
; CreateDate ... : 16, September 2017
; Compiler ..... : PureBasic V5.60 (x86)
; Flags ........ : Unicode/XP-Skin - Administrator Mode
; Subsystem .... : none
; TargetOS ..... : Windows
; License ...... : ?
; Link ......... : ?
; Description .. : 
;
;==============================================================================
; Changelog:
; 23, September 2017 : Catalog.pbi - Header & German Text added by Bisonte
;==============================================================================

EnableExplicit

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
  
  ;Panel 0 - Select purebasic file, compil and create user lib
  #mfPBFrame
  #mfPBCodeName
  #mfPBSelect
  #mfPBCompil
  #mfLIBCreate
  #mfLibShow
  #mfLog
  
  ;Panel 1 - View ASM code
  #mfASMName
  #mfASMEdit
  
  ;Panel 2 - View and update DESC code (Save is optionel)
  #mfDESCName
  #mfDESCEdit
  #mfDESCUpdate
EndEnumeration

Global PBFileName.s, PathPart.s, FilePart.s;, ExtPart.s

;-Application Summary
Declare   Start()                 ;Fonts, Window and Triggers
Declare   ResetWindow()           ;Init and clear Gadget
Declare   PBSelect()              ;Changed lang
Declare   ASMCreate()             ;Created ASM file, Parsed and modified ASM file and create description (DESC) file 
Declare   OBJCreate()             ;Created OBJ file         
Declare   DESCSave()              ;Saved DESC file if the user changes the source 
Declare   MakeStaticLib()         ;Create User libray
Declare   LibShowUserLib()        ;Show user library folder

Declare   LangChange()            ;Changed lang (French, English)
Declare   ConsoleLog(Buffer.s)    ;Updated console log  
Declare.f AdjustFontSize(Size.l)  ;Load a font and adapt it to the DPI
Declare   FileDelete(FileName.s)  ;Delete file

Declare   Exit()                  ;Exit

IncludePath "include"
IncludeFile "catalog.pbi"
IncludeFile "parse.pbi"
IncludeFile "sounderror.pbi"
IncludeFile "LockResize.pbi"

Start()

Procedure Start()
  ;-Fonts
  LoadFont(#FontGlobal, "", AdjustFontSize(9))
  LoadFont(#FontH1, "", AdjustFontSize(10))
  SetGadgetFont(#PB_Default, FontID(#FontGlobal))
  
  ;-Window
  UseLockGadget()
  OpenWindow(#mf, 0, 0, 800, 600, "", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
  
  ;Select lang
  ComboBoxGadget(#mfLang, WindowWidth(#mf) - 90, 10, 80, 22)
  InitLang(#mfLang)
  
  ;Wrapper Panel
  PanelGadget(#mfPanel, 0, 40, WindowWidth(#mf)+2, WindowHeight(#mf) - 40)
  
  ;Panel : Select code PureBasic to be compiled
  AddGadgetItem (#mfPanel, -1, "")
  FrameGadget(#mfPBFrame, 5, 20, WindowWidth(#mf) - 15, 100, "")
  
  ;File Name
  TextGadget(#mfPBCodeName, 20, 50, WindowWidth(#mf) - 130, 22, "")
  SetGadgetColor(#mfPBCodeName, #PB_Gadget_BackColor, RGB(169, 169, 169))
  
  ;Action
  ButtonGadget(#mfPBSelect, WindowWidth(#mf) - 100, 49, 80, 24, "")
  ButtonGadget(#mfPBCompil, 20, 80, 150, 24, "")
  ButtonGadget(#mfLIBCreate, 180, 80, 150, 24, "")
  ButtonGadget(#mfLibShow, 340, 80, 150, 24, "")  
  
  ;View console log
  ListViewGadget(#mfLog, 5, 130, WindowWidth(#mf) - 15, 400)
  SetGadgetColor(#mfLog, #PB_Gadget_BackColor, RGB(169, 169, 169))
  ConsoleLog(m("welcome"))
  ConsoleLog("PureBasic version : " + Str(#PB_Compiler_Version) + " " + GetCompilerProcessor())
  
  ;Panel : View code ASM
  AddGadgetItem (#mfPanel, -1, "")
  TextGadget(#mfASMName, 5, 10, WindowWidth(#mf) - 15, 22, "") 
  SetGadgetFont(#mfASMName, FontID(#FontH1))
  SetGadgetColor(#mfASMName, #PB_Gadget_BackColor, RGB(192, 192, 192))
  EditorGadget(#mfASMEdit, 5, 35, WindowWidth(#mf) - 15, 470)
  SetGadgetColor(#mfASMEdit, #PB_Gadget_BackColor, RGB(211, 211, 211))
  
  ;Panel : View and/or updated code DESC
  AddGadgetItem(#mfPanel, -1, "")
  TextGadget(#mfDESCName, 5, 10, WindowWidth(#mf) - 15, 22, "") 
  SetGadgetFont(#mfDESCName, FontID(#FontH1))
  SetGadgetColor(#mfDESCName, #PB_Gadget_BackColor, RGB(192, 192, 192))
  EditorGadget(#mfDESCEdit, 5, 35, WindowWidth(#mf) - 15, 460)
  SetGadgetColor(#mfDESCEdit, #PB_Gadget_BackColor, RGB(211, 211, 211))
  ButtonGadget(#mfDESCUpdate, WindowWidth(#mf) - 90, 500, 80, 22, "")
  
  CloseGadgetList()
  ;End Wrapper Panel
  
  LangChange()  ;Displays labels
  ResetWindow() ;Clear gadgets
  
  WindowBounds(#mf, 380, 400, #PB_Ignore, #PB_Ignore)
  
  ;-Resize gadget (Window, Gadget, Left, Top, Right, Bottom)
  LockGadget(#mf, #mfLang, #False, #True, #True, #False)
  LockGadget(#mf, #mfPanel, #True, #True, #True, #True)
  LockGadget(#mf, #mfPBFrame, #True, #True, #True, #False)
  LockGadget(#mf, #mfPBCodeName, #True, #True, #True, #False)
  LockGadget(#mf, #mfPBSelect, #False, #True, #True, #False)
  LockGadget(#mf, #mfLog, #True, #True, #True, #True)
  LockGadget(#mf, #mfASMName, #True, #True, #True, #False)
  LockGadget(#mf, #mfASMEdit, #True, #True, #True, #True)
  LockGadget(#mf, #mfDESCName, #True, #True, #True, #False)
  LockGadget(#mf, #mfDESCEdit, #True, #True, #True, #True)
  LockGadget(#mf, #mfDESCUpdate, #False, #False, #True, #True) 
  
  ;-Triggers
  BindGadgetEvent(#mfLang, @LangChange())           ;Change lang
  BindGadgetEvent(#mfPBSelect, @PBSelect())         ;Select PureBasic code
  BindGadgetEvent(#mfPBCompil, @ASMCreate())        ;Create ASM file, Parsed and modified ASM file and create description (DESC) file 
  BindGadgetEvent(#mfLIBCreate, @OBJCreate())       ;Create OBJ file and User Libray
  BindGadgetEvent(#mfDESCUpdate, @DESCSave())       ;Save DESC file if the user changes the source 
  
  BindGadgetEvent(#mfLibShow, @LIBShowUserLib())    ;Show user library folder
  BindEvent(#PB_Event_CloseWindow, @Exit())         ;Exit
  
  Repeat : WaitWindowEvent() : ForEver
EndProcedure

Procedure ResetWindow()
  DisableGadget(#mfPBCompil, #True)
  DisableGadget(#mfLIBCreate, #True)
  DisableGadget(#mfASMEdit, #True)
  DisableGadget(#mfDESCEdit, #True)
  DisableGadget(#mfDESCUpdate, #True)
EndProcedure

;-
;Select PureBasic filename
Procedure PBSelect()
  PBFileName = OpenFileRequester(m("selpbfile"), "", "PureBasic file | *.pb;*.pbi", 0)  
  If PBFileName
    PathPart = GetPathPart(PBFileName)
    FilePart = GetFilePart(PBFileName, #PB_FileSystem_NoExtension)
    ;ExtPart  = GetExtensionPart(PBFileName)
    ResetWindow()    
    SetGadgetText(#mfPBCodeName, " " + PBFileName)
    DisableGadget(#mfPBCompil, #False)
    ConsoleLog("Click the compile button.") 
  EndIf
EndProcedure

;Create ASM file, Parsed and modified ASM file and create description (DESC) file
Procedure ASMCreate()
  Protected Compiler, Buffer.s, FileName.s, Token.b
  
  ;Delete previous PureBasic.exe file if exist
  FileDelete("PureBasic.exe")
  
  ;Delete previous PureBasic.asm file if exist
  FileDelete("PureBasic.asm")
  
  ;Delete previous library 
  FileName = #DQUOTE$ + #PB_Compiler_Home + "PureLibraries\UserLibraries\" + FilePart + #DQUOTE$
  FileDelete(FileName) ;- Does not work
  
  ;Delete previous PureLibrariesMaker.log
  FileDelete("PureLibrariesMaker.log")
  
  ;Delete YOUR previous ASM Files if exist
  FileDelete(FilePart + ".asm")
  
  ;Delete previous PureBasic.desc file if exist
  FileDelete(FilePart + ".desc")
  
  ;Compile PB -> ASM 
  ConsoleLog("Waiting for compile ...")
  ;Compiler = RunProgram(#PB_Compiler_Home + "Compilers\pbcompiler.exe", #DQUOTE$ + PBFileName + #DQUOTE$ + " /COMMENTED /THREAD " , "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  Compiler = RunProgram(#PB_Compiler_Home + "Compilers\pbcompiler.exe", #DQUOTE$ + PBFileName + #DQUOTE$ + " /COMMENTED " , "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If Compiler
    Token = #True
    While ProgramRunning(Compiler)
      If AvailableProgramOutput(Compiler)
        Buffer = ReadProgramString(Compiler)
        If FindString(Buffer, "Error")
          Token = #False
        EndIf
        ConsoleLog(Buffer)
        SetGadgetItemColor(#mfLog, CountGadgetItems(#mfLog)-1, #PB_Gadget_FrontColor, RGB(255, 0, 0))
      EndIf
    Wend
    CloseProgram(Compiler)
    
    If Token
      FileName = FilePart + ".asm"
      If Not RenameFile("PureBasic.asm", Filename)
        ConsoleLog(m("libexist"))
        ConsoleLog(m("errordelete") + " " + Filename)
      Else
        ConsoleLog("Rename PureBasic.asm to " + FileName + " done." )       
        
        ;Parse ASM (Extract dependancies & procedures and create DESC File) 
        Analyse(FileName)
        
        ;Init ASM Editor
        SetGadgetText(#mfASMName, FileName)
        DisableGadget(#mFASMEdit, #False)
        SetGadgetText(#mFASMEdit, "") ;Clear editor
        If ReadFile(0, Filename, #PB_Ascii)
          While Eof(0) = 0
            AddGadgetItem(#mfASMEdit, -1, ReadString(0))
          Wend
          CloseFile(0)
        EndIf
        
        ;Init DESC editor
        FileName = FilePart + ".desc"
        SetGadgetText(#mfDESCName, FileName)
        DisableGadget(#mfDESCEdit, #False)
        SetGadgetText(#mfDESCEdit, "") ;Clear editor
        If ReadFile(0, Filename)
          While Eof(0) = 0
            AddGadgetItem(#mfDESCEdit, -1, ReadString(0))
          Wend
          CloseFile(0)
          ConsoleLog("You can view the ASM and DESC sources before create your user library")
        EndIf
        
        DisableGadget(#mfLIBCreate, #False)
        DisableGadget(#mfDESCUpdate, #False)
      EndIf 
    Else
      PlaySound(Error)
      MessageRequester("MLF", Buffer)
    EndIf
    
  EndIf
EndProcedure

;Create OBJ File
Procedure OBJCreate()
  Protected Compiler
  Protected ASMFilename.s = #DQUOTE$ + FilePart + ".asm" + #DQUOTE$
  Protected OBJFileName.s = #DQUOTE$ + FilePart + ".obj" + #DQUOTE$
  
  Compiler = RunProgram(#PB_Compiler_Home + "Compilers\FAsm.exe", "" + ASMFilename + " " + OBJFileName, "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If Compiler
    While ProgramRunning(Compiler)
      If AvailableProgramOutput(Compiler)
        ConsoleLog(ReadProgramString(Compiler))
      EndIf
    Wend
    CloseProgram(Compiler) 
    MakeStaticLib()
  EndIf
EndProcedure

;Save DESC file if the user changes the source 
Procedure DESCSave()
  Protected DESCFileName.s = FilePart + ".desc"
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

;Make Static Lib (Use sdk\LibraryMaker.exe")
Procedure MakeStaticLib()  
  Protected Compiler
  Protected SourcePath.s      = #DQUOTE$ + FilePart + ".Desc" + #DQUOTE$
  Protected DestinationPath.s = #DQUOTE$ + #PB_Compiler_Home + "PureLibraries\UserLibraries\" + #DQUOTE$  ; + " /COMPRESSED /NOUNICODEWARNING "
  
  Compiler = RunProgram(#PB_Compiler_Home + "sdk\LibraryMaker.exe ", SourcePath + " /TO " + DestinationPath, "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  
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

Procedure LibShowUserLib()
  RunProgram("explorer.exe",#PB_Compiler_Home + "PureLibraries\UserLibraries", "")  
EndProcedure

;-
;-Tools
Procedure LangChange()
  SetLang(GetGadgetState(#mfLang))
  SetWindowTitle(#mf, m("title"))
  SetGadgetItemText(#mfPanel, 0, m("pancompil"))
  SetGadgetText(#mfPBFrame, m("selpbfile"))
  SetGadgetText(#mfPBSelect, m("pbselect"))
  SetGadgetText(#mfPBCompil, m("pbcompil"))
  SetGadgetText(#mfLIBCreate, m("libcreate"))
  SetGadgetText(#mfLibShow, m("libshow"))  
  SetGadgetItemText(#mfPanel, 1, m("panviewasm"))
  SetGadgetItemText(#mfPanel, 2, m("panviewdesc"))
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

Procedure FileDelete(FileName.s)
  If ReadFile(0, FileName)
    CloseFile(0)
    ConsoleLog("Delete " + Filename + " ...")
    If Not DeleteFile(FileName, #PB_FileSystem_Force)
      ConsoleLog(m("errordelete") + " " + Filename)
    EndIf
  EndIf
EndProcedure

;-The end
Procedure Exit()  
  End
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 218
; FirstLine = 186
; Folding = ------
; EnableXP
; EnableAdmin
; Executable = mlf.exe