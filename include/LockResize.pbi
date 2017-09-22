;LockResizeGadget.pbi Version 2.00
;
;Create : 07 Aout 2012
;Update : 19 Septembre 2017
;

;OS : Window, Linux (En principe), OSx (En principe)
;PB 4.51, --> 5.61
;
;
;Contributors
; Falsam
;
; Licence : Use As You Like
;

Declare __ResizeWindow()

;
; Initialisation
Procedure UseLockGadget()    
  Structure Gadget
    Window.i      
  
    Gadget.i  
  
    DeltaLeft.i   
    DeltaTop.i         
    DeltaRight.i       
    DeltaBottom.i  
  
    Width.i
    Height.i      
  
    LockLeft.b    
    LockTop.b     
    LockRight.b   
    LockBottom.b  
    
    HorizontalCenter.b
    VerticalCenter.b
  EndStructure      
  
  Global NewMap  Windows()
  Global NewList LockGadgets.Gadget()
EndProcedure

; 
;Fixe (#True) ou pas (#False) les bords d'un gadget sur une fenêtre.
;Centre (#True) ou pas (#False) un gadget horizontalement et/ou verticalement.
Procedure LockGadget(Window.i, Gadget.i, LockLeft.b, LockTop.b, LockRight.b, LockBottom.b, HorizontalCenter.b = #False, VerticalCenter.b = #False)
  BindEvent(#PB_Event_SizeWindow, @__ResizeWindow())
  
  AddElement(LockGadgets())
  
  With LockGadgets()
  
    \Gadget = Gadget
    \Window = window
    
    \LockLeft = Lockleft
    \LockTop = Locktop
    \LockRight = Lockright
    \LockBottom = LockBottom
    \HorizontalCenter = HorizontalCenter
    \VerticalCenter = VerticalCenter
    
    \DeltaLeft = GadgetX(Gadget)
    \DeltaTop = GadgetY(Gadget)     
    \DeltaRight = WindowWidth(Window) - GadgetX(Gadget) - GadgetWidth(Gadget)
    \DeltaBottom = WindowHeight(Window) - GadgetY(Gadget) - GadgetHeight(Gadget)
    
    \Width = GadgetWidth(Gadget)
    \Height = GadgetHeight(Gadget)
  EndWith

EndProcedure


;
; Unlock un ou tous(Gadget.l=#True) les gadget d'une fenetre
Procedure UnlockGadget(Window.l, Gadget.l=#True)
  ForEach LockGadgets()
    If LockGadgets()\Window = Window
      If LockGadgets()\Gadget = Gadget Or Gadget=#True
        DeleteElement(LockGadgets())
      EndIf
    EndIf
  Next
EndProcedure

;
; Redimensionne les gadgets mémorisés dans la liste.
Procedure __ResizeGadgets(Window.i)
  Protected Gadget.i, X.i, Y.i, W.i, H.i
      
    ForEach LockGadgets()
      If LockGadgets()\Window = Window      
        With LockGadgets()
          
          Gadget = \Gadget
          X = WindowWidth(window) - \DeltaRight - \Width
          Y = WindowHeight(window) - \DeltaBottom - \Height
          W = #PB_Ignore
          H = #PB_Ignore 
          
          If \LockRight = #False
            X = #PB_Ignore
          EndIf
          
          If \LockBottom = #False
            Y = #PB_Ignore
          EndIf
          
          If \LockLeft = #True   
            X = \DeltaLeft
          EndIf
              
          If \LockTop = #True
            Y = \DeltaTop
          EndIf        
                  
          If \LockRight = #True
            W = WindowWidth(Window) - X - \DeltaRight
          EndIf
          
          If \LockBottom = #True
            H = WindowHeight(Window) - Y - \DeltaBottom
          EndIf
          
          If \HorizontalCenter = #True
            X = (WindowWidth(Window) - \Width)/2
          EndIf
          
          If \VerticalCenter = #True
            Y = (WindowHeight(Window) - \Height)/2
          EndIf
                    
          ResizeGadget(Gadget, X, Y, W, H)
        EndWith
      EndIf
    Next
EndProcedure

Procedure __ResizeWindow()
  __ResizeGadgets(EventWindow())
EndProcedure

; 
; Détruit la Liste et libère toutes les ressources associées
Procedure FreeLockGadget()
  ResetList(LockGadgets())  
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; Folding = ---
; EnableXP
; EnableUnicode