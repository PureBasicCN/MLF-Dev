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
; Link ......... : https://github.com/MLF4PB/MLF-Alpha/archive/master.zip
; Description .. : 
;
;==============================================================================
; Changelog:
; 23, September 2017 : Catalog.pbi  - Header & German Text added by Bisonte
; 24, September 2017 : Catalog.pbi  - Russian Text add by mestnyi
; 24, September 2017 : Parse.pbi    - Add Normalise() Format procedure name + parameters by GallyHC
; 27, September 2017 : Parse.pbi    - Add toolbar and help for each procedure
; 01, October 2017   : mlf.pb       - MLF command line File + pbcompil.b + libcreate.b 
;==============================================================================

EnableExplicit

Enumeration Font
  #FontGlobal  
  #FontH1
EndEnumeration

Enumeration Window
  #mf
EndEnumeration

Enumeration Menu
  #mfLogMenu  
EndEnumeration

Enumeration Gadget
  ;Select the application language 
  #mfLang  
  
  ;Panel
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
  
  ;Panel 2 - View and update DESC code (Update is optionel)
  #mfDESCName
  #mfDESCEdit
  #mfDESCUpdate
EndEnumeration

;Version
Global Title.s = "MLF"
Global Version.s = "1.20 Beta"

;Current PureBasic file
Global PBFileName.s, PathPart.s, FilePart.s

;-Application Summary
Declare   Start()                 ;Fonts, Window and Triggers
Declare   LogMenu()               ;Log Popup Menu (Clear & Copy)
Declare   LogEvent()              ;Log Events  
Declare   ResetWindow()           ;Init and clear Gadget
Declare   PBSelect()              ;Select PureBasic file name
Declare   PBCompil()              ;Created ASM file, Parsed and save ASM file and create description (DESC) file 
Declare   OBJCreate()             ;Created OBJ file         
Declare   MakeStaticLib()         ;Create User libray
Declare   LibShowUserLib()        ;Show user library folder

Declare   DESCSave()              ;Saved DESC file if the user changes the source 

Declare   LangChange()            ;Changed lang (French, English, Deutch, Russian)
Declare   ConsoleLog(Buffer.s)    ;Updated console log  
Declare.f AdjustFontSize(Size.l)  ;Load a font and adapt it to the DPI
Declare   FileDelete(FileName.s)  ;Delete file
Declare.s GetCompilerProcessor()  ;Return (x86) or (x64)  
Declare   Exit()                  ;Exit

IncludePath "include"
IncludeFile "catalog.pbi"         ;Lang
IncludeFile "parse.pbi"           ;Parse ASM (Extract dependancies and procedures and create DESC File)
IncludeFile "media.pbi"           ;Media image and sound 
IncludeFile "LockResize.pbi"      ;Automatically resize the elements of a form.

Start()

Procedure Start()  
  ;-Fonts
  LoadFont(#FontGlobal, "", AdjustFontSize(10))
  LoadFont(#FontH1, "", AdjustFontSize(11))
  SetGadgetFont(#PB_Default, FontID(#FontGlobal))
  
  ;-Window
  UseLockGadget()
  OpenWindow(#mf, 0, 0, 800, 650, "", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget)
  WindowBounds(#mf, 390, 400, #PB_Ignore, #PB_Ignore)
    
  ;ToolBar
  ButtonImageGadget(#mfPBSelect, 10, 10, 40, 40, ImageID(PBOpen))
  ButtonImageGadget(#mfPBCompil, 60, 10, 40, 40, ImageID(PBCompil))
  ButtonImageGadget(#mfLIBCreate, 110, 10, 40, 40, ImageID(LIBCompil))
  ButtonImageGadget(#mfLibShow, 160, 10, 40, 40, ImageID(LIBView))  
  
  ;Log Menu PopUp
  If CreatePopupMenu(#mfLogMenu)
    MenuItem(1, m("logclear"))
    MenuItem(2, m("logcopy"))
  EndIf
  
  ;Select lang
  ComboBoxGadget(#mfLang, WindowWidth(#mf) - 90, 15, 80, 22)
  InitLang(#mfLang)
  
  ;Wrapper Panel
  PanelGadget(#mfPanel, 0, 60, WindowWidth(#mf)+2, WindowHeight(#mf) - 65)
  
  ;Panel : Select code PureBasic to be compiled
  AddGadgetItem (#mfPanel, -1, "")
  FrameGadget(#mfPBFrame, 5, 20, WindowWidth(#mf) - 15, 70, "")
  
  ;PureBasic File Name
  ComboBoxGadget(#mfPBCodeName, 20, 50, WindowWidth(#mf) - 45, 22)
  
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
    
  LangChange()  ;Displays window labels
  ResetWindow() ;Clear gadgets
   
  ;-Resize gadget (Window, Gadget, Left, Top, Right, Bottom)
  LockGadget(#mf, #mfLang, #False, #True, #True, #False)
  LockGadget(#mf, #mfPanel, #True, #True, #True, #True)
  LockGadget(#mf, #mfPBFrame, #True, #True, #True, #False)
  LockGadget(#mf, #mfPBCodeName, #True, #True, #True, #False)
  LockGadget(#mf, #mfLog, #True, #True, #True, #True)
  LockGadget(#mf, #mfASMName, #True, #True, #True, #False)
  LockGadget(#mf, #mfASMEdit, #True, #True, #True, #True)
  LockGadget(#mf, #mfDESCName, #True, #True, #True, #False)
  LockGadget(#mf, #mfDESCEdit, #True, #True, #True, #True)
  LockGadget(#mf, #mfDESCUpdate, #False, #False, #True, #True) 
  
  ;-Triggers
  BindGadgetEvent(#mfLang, @LangChange())           ;Change lang
  BindGadgetEvent(#mfPBSelect, @PBSelect())         ;Select PureBasic code
  BindGadgetEvent(#mfPBCodeName, @PBSelect())       ;Select PureBasic code  
  BindGadgetEvent(#mfPBCompil, @PBCompil())         ;Create ASM file, Parsed and modified ASM file and create description (DESC) file 
  BindGadgetEvent(#mfLIBCreate, @OBJCreate())       ;Create OBJ file and User Libray
  BindGadgetEvent(#mfDESCUpdate, @DESCSave())       ;Save DESC file if the user changes the source
  BindGadgetEvent(#mfLog, @LogMenu(), #PB_EventType_RightClick)
  BindGadgetEvent(#mfLibShow, @LIBShowUserLib())    ;Show user library folder
  
  BindMenuEvent(#mfLogMenu, 1, @LogEvent())
  BindMenuEvent(#mfLogMenu, 2, @LogEvent())
  
  BindEvent(#PB_Event_CloseWindow, @Exit())         ;Exit
  
  ;-MLF is launched on the command line
  If CountProgramParameters() 
    PBFileName = Trim(ProgramParameter(0))
    AddGadgetItem(#mfPBCodeName, 0, PBFileName)
    SetGadgetState(#mfPBCodeName, 0)
    ConsoleLog(Str(CountProgramParameters()))
    ConsoleLog("Receiving the file " + PBFileName)
    PBSelect()
    
    If Val(ProgramParameter(1)) = #True
      If PBCompil() And Val(ProgramParameter(2)) = #True
        MakeStaticLib()
      EndIf
    EndIf
  EndIf
  
  ;Loop
  Repeat : WaitWindowEvent() : ForEver
EndProcedure

Procedure ResetWindow()
  DisableGadget(#mfPBCompil, #True)
  SetGadgetAttribute(#mfPBCompil, #PB_Button_Image, ImageID(PBCompild))
  
  DisableGadget(#mfLIBCreate, #True)
  SetGadgetAttribute(#mfLIBCreate, #PB_Button_Image, ImageID(LIBCompild))
  
  DisableGadget(#mfASMEdit, #True)
  SetGadgetText(#mfASMName, "")
  SetGadgetText(#mfASMEdit, "")
  
  DisableGadget(#mfDESCEdit, #True)
  SetGadgetText(#mfDESCName, "")
  SetGadgetText(#mfDESCEdit, "")
  
  DisableGadget(#mfDESCUpdate, #True)
EndProcedure

;- Log Menu
Procedure LogMenu()
  DisplayPopupMenu(0, WindowID(0))   
EndProcedure

Procedure LogEvent()
  Protected n, Buffer.s
  
  Select EventMenu()
    Case 1 ;Clear Log
      ClearGadgetItems(#mfLog)
      
    Case 2 ;Log Copy
      For n = 0 To CountGadgetItems(#mfLog) - 1
        Buffer + GetGadgetItemText(#mfLog, n) + #CRLF$
      Next
      SetClipboardText(Buffer)
  EndSelect
EndProcedure

;-
;Select PureBasic filename
Procedure PBSelect()
  Protected Selector = EventGadget()
  Protected PBPreviousFileName.s = PBFileName
  
  If Selector = #mfPBSelect
    PBFileName = OpenFileRequester(m("selpbfile"), "", "PureBasic file | *.pb;*.pbi", 0)  
  Else
    PBFileName = Trim(GetGadgetItemText(#mfPBCodeName, GetGadgetState(#mfPBCodeName)))
  EndIf
    
  If PBFileName <> ""
    PathPart = GetPathPart(PBFileName)
    FilePart = GetFilePart(PBFileName, #PB_FileSystem_NoExtension)
    ResetWindow()    
    
    If Selector = #mfPBSelect
      AddGadgetItem(#mfPBCodeName, 0, " " + PBFileName)
      SetGadgetState(#mfPBCodeName, 0)
    EndIf
    
    DisableGadget(#mfPBCompil, #False)
    SetGadgetAttribute(#mfPBCompil, #PB_Button_Image, ImageID(PBCompil))
    ConsoleLog("Click the compile button.")
  Else
    PBFileName = PBPreviousFileName
  EndIf
EndProcedure

;Create ASM file, Parsed and modified ASM file and create description (DESC) file
Procedure PBCompil()
  Protected Compiler, Buffer.s, FileName.s, Token.b
  
  ;Delete previous PureBasic.exe file if exist
  FileDelete("PureBasic.exe")
  
  ;Delete previous PureBasic.asm file if exist
  FileDelete("PureBasic.asm")
  
  ;Delete previous library if exist
  FileName = #PB_Compiler_Home + "PureLibraries\UserLibraries\" + FilePart  
  FileDelete(FileName)

  ;Delete previous PureLibrariesMaker.log if exist
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
        ConsoleLog(m("errordelete") + " " + Filename)
      Else
        ConsoleLog("Rename PureBasic.asm to " + FileName + " done." )       
        
        ;Extract dependancies & procedures from ASM file and create DESC File        
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
        EndIf
        
        DisableGadget(#mfLIBCreate, #False)
        SetGadgetAttribute(#mfLIBCreate, #PB_Button_Image, ImageID(LIBCompil))    
        DisableGadget(#mfDESCUpdate, #False)
        
        ConsoleLog("You can view the ASM and DESC sources before create your user library")
        PlaySound(Success)

        FileDelete("purebasic.exe")
      EndIf 
    Else
      PlaySound(Error)
      MessageRequester("MLF", Buffer)
    EndIf 
  EndIf
  ProcedureReturn Token
EndProcedure

;Create OBJ File : Use fasm.exe
Procedure OBJCreate()
  Protected Compiler
  Protected ASMFilename.s = #DQUOTE$ + FilePart + ".asm" + #DQUOTE$
  Protected OBJFileName.s = #DQUOTE$ + FilePart + ".obj" + #DQUOTE$
  
  Compiler = RunProgram(#PB_Compiler_Home + "Compilers\Fasm.exe", "" + ASMFilename + " " + OBJFileName, "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
  If Compiler
    While ProgramRunning(Compiler)
      If AvailableProgramOutput(Compiler)
        ConsoleLog(ReadProgramString(Compiler))
      EndIf
    Wend
    CloseProgram(Compiler) 
    
    ;Create user library
    MakeStaticLib()
  EndIf
EndProcedure

;Make Static Lib : Use sdk\LibraryMaker.exe

;LibraryMaker can take several arguments in parameter To allow easy scripting:
; /ALL                : Process all the .desc files found in the source directory
; /COMPRESSED         : Compress the library (much smaller And faster To load, but slower To build)
; /To <Directory>     : Destination directory
; /CONSTANT MyConstant: Defines a constant For the preprocessor
; Example C:\LibraryMaker.exe c:\PureBasicDesc\ /TO C:\PureBasic\PureLibraries\ /ALL /COMPRESSED
Procedure MakeStaticLib()  
  Protected Compiler
  Protected SourcePath.s      = #DQUOTE$ + FilePart + ".Desc" + #DQUOTE$
  Protected OBJPath.s         = FilePart + ".obj" 
  Protected DestinationPath.s = #DQUOTE$ + #PB_Compiler_Home + "PureLibraries\UserLibraries\" + #DQUOTE$
  
  If FileSize(OBJPath) <> -1 
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
      PlaySound(Success)
    Else
      ConsoleLog(m("errorlib"))
      PlaySound(Error)
    EndIf
  Else
    ConsoleLog(m("errorobj"))
    PlaySound(Error)
  EndIf
EndProcedure

;Show User libraries
Procedure LibShowUserLib()
  RunProgram("explorer.exe", #PB_Compiler_Home + "PureLibraries\UserLibraries", "")  
EndProcedure

;-
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



;-
;-Tools
Procedure LangChange()
  SetLang(GetGadgetState(#mfLang))
  SetWindowTitle(#mf, m("title"))
  SetGadgetItemText(#mfPanel, 0, m("pancompil"))
  SetGadgetText(#mfPBFrame, m("selpbfile"))
  GadgetToolTip(#mfPBSelect, m("pbselect"))
  GadgetToolTip(#mfPBCompil, m("pbcompil"))
  GadgetToolTip(#mfLIBCreate, m("libcreate"))
  GadgetToolTip(#mfLibShow, m("libshow"))  
  SetGadgetItemText(#mfPanel, 1, m("panviewasm"))
  SetGadgetItemText(#mfPanel, 2, m("panviewdesc"))
  SetGadgetText(#mfDESCUpdate, m("save"))
  SetMenuItemText(#mfLogMenu, 1, m("logclear"))
  SetMenuItemText(#mfLogMenu, 2, m("logcopy"))
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
  If FileSize(FileName) <> -1
    ConsoleLog("Delete " + Filename + " ...")
    If Not DeleteFile(FileName, #PB_FileSystem_Force)
      ConsoleLog(m("errordelete") + " " + Filename)
    EndIf
  EndIf
EndProcedure

Procedure.s GetCompilerProcessor()
  If #PB_Compiler_Processor = #PB_Processor_x86
    ProcedureReturn "(x86)"
  Else
    ProcedureReturn "(x64)"
  EndIf  
EndProcedure

;-The end
Procedure Exit()  
  End
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 67
; FirstLine = 39
; Folding = -------
; Markers = 258
; EnableXP
; EnableAdmin
; Executable = mlf.exe