;-=============================================================================
; 
; Project ...... : Make Library Factory
; Name ......... : media.pbi
; Type ......... : Include
; Author ....... : falsam
; CreateDate ... : 16, September 2017
; Compiler ..... : PureBasic V5.60 (x86)
; Flags ........ : Unicode/XP-Skin
; Subsystem .... : none
; TargetOS ..... : Windows
; License ...... : ?
; Link ......... : https://github.com/MLF4PB/MLF-Alpha/archive/master.zip
; Description .. : Application sounds
;
;==============================================================================
; Credit sound http://freesound.org
; Credit image Oma (English forum) and GallyHC (French Forum)
;==============================================================================

UsePNGImageDecoder()
Global PBOpen     = CatchImage(#PB_Any, ?pbopen)
Global PBCompil   = CatchImage(#PB_Any, ?pbcompil)
Global PBCompild  = CatchImage(#PB_Any, ?pbcompild)
Global LIBCompil  = CatchImage(#PB_Any, ?libcompil)
Global LIBCompild = CatchImage(#PB_Any, ?libcompild)
Global LIBView    = CatchImage(#PB_Any, ?libview)
Global Grip       = CatchImage(#PB_Any, ?Grip)

InitSound()
Global Error    = CatchSound(#PB_Any, ?error)
Global Success  = CatchSound(#PB_Any, ?success)

DataSection
  ;Image 
  pbopen:     ;Image select PureBasic file code
  IncludeBinary "image/open2.png"
  
  pbcompil:   ;Image compil enable
  IncludeBinary "image/compile.png"
  
  pbcompild:  ;Image compil disable
  IncludeBinary "image/compile_d.png"
  
  libcompil:  ;Image compil lib enable
  IncludeBinary "image/compilerun.png"
  
  libcompild: ;Image compil lib disable
  IncludeBinary "image/compilerun_d.png"
  
  libview:    ;Image view all lib 
  IncludeBinary "image/findfile.png"
  
  grip:       :;Resize window
  IncludeBinary "image/grip.png"
  
  ;Sound
  error:
  IncludeBinary "sound/error.wav"
  
  success:
  IncludeBinary "sound/success.wav"
  
EndDataSection
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 63
; FirstLine = 14
; EnableXP