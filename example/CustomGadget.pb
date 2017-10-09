;Windows only


; This procedure is called once, when the program loads the library
; for the first time. All init stuffs can be done here 
ProcedureDLL AttachProcess()
  Global WindowBackColor = GetSysColor_(#COLOR_3DFACE)
  
  Structure NewGadget
    Text.s
    Align.i
    StyleChange.b  
  EndStructure
  Global NewMap Gadgets.NewGadget()
EndProcedure

;Private procedures
Procedure SetText(Gadget, Buffer.s, Color.i) ;-Change the gadget text content
  Protected Width  = GadgetWidth(Gadget)
  Protected Height = GadgetHeight(Gadget)
  Protected tw, th
  
  FindMapElement(Gadgets(), Str(Gadget))
  
  DrawingMode(#PB_2DDrawing_Transparent)
  tw = TextWidth(Buffer)
  th = TextHeight(Buffer)
  If tw < Width And th < Height
    If Gadgets()\Align = #PB_Text_Center
      DrawText((Width-tw)/2, (Height-th)/2, Buffer, Color)
    Else
      DrawText(0, 0, Buffer, Color)      
    EndIf  
  EndIf  
EndProcedure

Procedure OnEvent() 
  Protected Gadget = EventGadget()
  Protected Event  = EventType()
  
  FindMapElement(Gadgets(), Str(Gadget))
  If Gadgets()\StyleChange
    StartDrawing(CanvasOutput(Gadget))
    Select Event
      Case #PB_EventType_MouseEnter, #PB_EventType_LeftButtonUp
        SetText(Gadget, Gadgets()\Text, RGB(255, 255, 255))
        
      Case #PB_EventType_MouseLeave
        SetText(Gadget, Gadgets()\Text, RGB(0, 0, 0))
        
      Case #PB_EventType_LeftButtonDown
        SetText(Gadget, Gadgets()\Text, RGB(255, 0, 0))
        
    EndSelect    
    StopDrawing()
  EndIf
EndProcedure  

;Public procedures
ProcedureDLL Button(Gadget, x, y, Width, Height, text$) ;-Create a button gadget in a current gadget list.  
  If gadget = #PB_Any 
    Gadget = CanvasGadget(#PB_Any, x, y, Width, Height)
  Else    
    CanvasGadget(Gadget, x, y, Width, Height) 
  EndIf
  
  ;Register gadget
  AddMapElement(Gadgets(), Str(Gadget))
  Gadgets()\Text = text$
  Gadgets()\Align = #PB_Text_Center
  Gadgets()\StyleChange = #True
  
  ;Draw Gadget  
  If StartDrawing(CanvasOutput(Gadget))
    Box(0, 0, Width, Height, WindowBackColor)
    DrawingMode(#PB_2DDrawing_Gradient)
    FrontColor(RGB(128, 128, 128))
    BackColor($FFFFFF)
    LinearGradient(Width/2, 0, Width/2, height)
    RoundBox(0, 0, Width, Height, 4, 4)
    DrawingMode(#PB_2DDrawing_Outlined)
    RoundBox(0, 0, Width, Height, 4, 4, RGB(0, 0, 0))
    SetText(Gadget, text$, RGB(0, 0, 0))
    StopDrawing()
  EndIf 
  
  ;Trigers
  BindGadgetEvent(Gadget, @OnEvent())
  ProcedureReturn Gadget
EndProcedure

ProcedureDLL Text(Gadget, x, y, Width, Height, text$) ;-Create a text gadget in a current gadget list.  
  If gadget = #PB_Any 
    Gadget = CanvasGadget(#PB_Any, x, y, Width, Height)
  Else    
    CanvasGadget(Gadget, x, y, Width, Height) 
  EndIf
  
  ;Register gadget
  AddMapElement(Gadgets(), Str(Gadget))
  Gadgets()\Text = text$
  
  ;Draw Gadget
  If StartDrawing(CanvasOutput(Gadget))
    Box(0, 0, Width, Height, WindowBackColor)
    SetText(Gadget, text$, RGB(0, 0, 0))
    StopDrawing()
  EndIf 
  
  ;Trigers
  BindGadgetEvent(Gadget, @OnEvent())
  ProcedureReturn Gadget
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 57
; FirstLine = 56
; Folding = ---
; EnableXP