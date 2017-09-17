;MLF - Make Library Factory

Global Title.s = "MLF"
Global Version.s = "0.5 Beta"

Global Lang = 0 ;0 : Fr, 1, En

Structure NewMessage
  Array Translate.s(2)
EndStructure

Global NewMap Catalog.NewMessage()

AddMapElement(Catalog(), "title")
With Catalog()
  \Translate(0) = Title + " version " + Version + " - " + " Création d'une librairie static"
  \Translate(1) = Title + " version " + Version + " - " + " Creating a static library" 
EndWith 

AddMapElement(Catalog(), "welcome")
With Catalog()
  \Translate(0) = "Bienvenue à bord."
  \Translate(1) = "Welcome aboard." 
EndWith 

AddMapElement(Catalog(), "selpbfile")
With Catalog()
  \Translate(0) = "Sélectionnez le code PureBasic à compiler."
  \Translate(1) = "Select the code PureBasic to be compiled." 
EndWith 

AddMapElement(Catalog(), "genasm")
With Catalog()
  \Translate(0) = "Genéré source ASM"
  \Translate(1) = "Generated ASM source" 
EndWith 

AddMapElement(Catalog(), "selpb")
With Catalog()
  \Translate(0) = "Selectionnez code source PB"
  \Translate(1) = "Select source code PB" 
EndWith 


AddMapElement(Catalog(), "viewasm")
With Catalog()
  \Translate(0) = "Voir source ASM"
  \Translate(1) = "View ASM source" 
EndWith 

AddMapElement(Catalog(), "viewdesc")
With Catalog()
  \Translate(0) = "Voir source DESC"
  \Translate(1) = "View DESC source" 
EndWith 

AddMapElement(Catalog(), "save")
With Catalog()
  \Translate(0) = "Sauver"
  \Translate(1) = "Save" 
EndWith 

AddMapElement(Catalog(), "errordesc")
With Catalog()
  \Translate(0) = "Impossible de créer le fichier de description."
  \Translate(1) = "Failed to create description file." 
EndWith 

AddMapElement(Catalog(), "successdesc")
With Catalog()
  \Translate(0) = "Création du fichier le description, terminée."
  \Translate(1) = "Create description file completed."   
EndWith 

AddMapElement(Catalog(), "libexist")
With Catalog()
  \Translate(0) = "Supprimer la librairie si existante et relancer le compilateur."
  \Translate(1) = "Remove the library if it exists and restart the compiler." 
EndWith 

AddMapElement(Catalog(), "errorlib")
With Catalog()
  \Translate(0) = "Impossible de créer la librairie."
  \Translate(1) = "Unable to create library." 
EndWith 

AddMapElement(Catalog(), "successlib")
With Catalog()
  \Translate(0) = "Création de la librairie terminée."
  \Translate(1) = "Create library completed." 
EndWith 

AddMapElement(Catalog(), "errordelete")
With Catalog()
  \Translate(0) = "Imposssible de supprimer le fichier"
  \Translate(1) = "Unable to delete file" 
EndWith 

Procedure InitLang(Gadget)
  AddGadgetItem(Gadget, -1, "Français")
  AddGadgetItem(Gadget, -1, "English")
  SetGadgetState(Gadget, 0)
EndProcedure

Procedure SetLang(Value)
  Lang = Value  
EndProcedure

Procedure.s m(Key.s)
  ProcedureReturn Catalog(key)\Translate(Lang)
EndProcedure

Procedure.s GetCompilerProcessor()
  If #PB_Compiler_Processor = #PB_Processor_x86
    ProcedureReturn "(x86)"
  Else
    ProcedureReturn "(x64)"
  EndIf  
EndProcedure
  




; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 22
; Folding = -
; EnableXP