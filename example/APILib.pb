ProcedureDLL.s GetOSName()
  Protected Size
  Protected Name$
  Protected Result
  Protected Key
  
  Size=#MAX_PATH
  Name$=Space(Size)
  Result=RegOpenKeyEx_(#HKEY_LOCAL_MACHINE,"SOFTWARE\Microsoft\Windows NT\CurrentVersion",0,#KEY_ALL_ACCESS,@Key)
  If Result=0
    RegQueryValueEx_(Key,"ProductName",0,0,@Name$,@Size)
    RegCloseKey_(Key)
  EndIf
  ProcedureReturn Name$
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; ExecutableFormat = Shared dll
; Folding = -
; EnableXP
; Executable = mydll.dll#,X[?q