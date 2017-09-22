ProcedureDLL.s GetCPUName()
  Protected sBuffer.s
  Protected Zeiger1.l, Zeiger2.l, Zeiger3.l, Zeiger4.l
 
  !MOV eax, $80000002
  !CPUID
  ; the CPU-Name is now stored in EAX-EBX-ECX-EDX
  !MOV [p.v_Zeiger1], EAX ; move eax to the buffer
  !MOV [p.v_Zeiger2], EBX ; move ebx to the buffer
  !MOV [p.v_Zeiger3], ECX ; move ecx to the buffer
  !MOV [p.v_Zeiger4], EDX ; move edx to the buffer
 
  ;Now move the content of Zeiger (4*4=16 Bytes to a string
  sBuffer = PeekS(@Zeiger1, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger2, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger3, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger4, 4, #PB_Ascii)
 
  ;Second Part of the Name
  !MOV eax, $80000003
  !CPUID
  ; the CPU-Name is now stored in EAX-EBX-ECX-EDX
  !MOV [p.v_Zeiger1], EAX ; move eax to the buffer
  !MOV [p.v_Zeiger2], EBX ; move ebx to the buffer
  !MOV [p.v_Zeiger3], ECX ; move ecx to the buffer
  !MOV [p.v_Zeiger4], EDX ; move edx to the buffer
 
  ;Now move the content of Zeiger (4*4=16 Bytes to a string
  sBuffer + PeekS(@Zeiger1, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger2, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger3, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger4, 4, #PB_Ascii)
  
  ;Third Part of the Name
  !MOV eax, $80000004
  !CPUID
  ; the CPU-Name is now stored in EAX-EBX-ECX-EDX
  !MOV [p.v_Zeiger1], EAX ; move eax to the buffer
  !MOV [p.v_Zeiger2], EBX ; move ebx to the buffer
  !MOV [p.v_Zeiger3], ECX ; move ecx to the buffer
  !MOV [p.v_Zeiger4], EDX ; move edx to the buffer
 
  ;Now move the content of Zeiger (4*4=16 Bytes to a string
  sBuffer + PeekS(@Zeiger1, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger2, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger3, 4, #PB_Ascii)
  sBuffer + PeekS(@Zeiger4, 4, #PB_Ascii)
 
  ProcedureReturn sBuffer
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x86)
; Folding = -
; EnableXP