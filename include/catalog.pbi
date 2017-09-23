;-=============================================================================
; 
; Project ...... : Make Library Factory
; Name ......... : catalog.pbi
; Type ......... : Translation Include
; Author ....... : falsam
; CreateDate ... : 16, September 2017
; Compiler ..... : PureBasic V5.60 (x86)
; Flags ........ : Unicode/XP-Skin
; Subsystem .... : none
; TargetOS ..... : Windows
; License ...... : ?
; Link ......... : ?
; Description .. : Catalog Include to translate gui - text
;
;==============================================================================
; Changelog:
; 23, September 2017 : Header & German Text added by Bisonte
;==============================================================================

#MLF_MaxLanguage = 2 ; 0 Based (0,1,2)

Global Title.s = "MLF"
Global Version.s = "0.96.2 Alpha"

; 0 = FR, 1 = EN, 2 = DE
Global Lang = 0

Structure NewMessage
  Array Translate.s(#MLF_MaxLanguage)
EndStructure

Global NewMap Catalog.NewMessage()

AddMapElement(Catalog(), "title")
With Catalog()
  \Translate(0) = Title + " version " + Version + " - " + " Création d'une bibliothèque de fonctions utilisateur"
  \Translate(1) = Title + " version " + Version + " - " + " Creating a user library"
  \Translate(2) = Title + " version " + Version + " - " + " Erstelle eine Bibliothek"
EndWith 

AddMapElement(Catalog(), "welcome")
With Catalog()
  \Translate(0) = "Bienvenue à bord."
  \Translate(1) = "Welcome aboard."
  \Translate(2) = "Wilkommen."
EndWith 

;Panel : Select code PureBasic to be compiled
AddMapElement(Catalog(), "pancompil")
With Catalog()
  \Translate(0) = "Compiler un code PureBasic"
  \Translate(1) = "Compile a PureBasic code"
  \Translate(2) = "Kompiliere einen Quellcode"
EndWith 

AddMapElement(Catalog(), "selpbfile")
With Catalog()
  \Translate(0) = "Sélectionnez le code PureBasic à compiler."
  \Translate(1) = "Select the code PureBasic to be compiled." 
  \Translate(2) = "Wähle den zu kompilierenden Quellcode aus." 
  
EndWith 

AddMapElement(Catalog(), "pbselect")
With Catalog()
  \Translate(0) = "Selectionner"
  \Translate(1) = "Select"
  \Translate(2) = "Wähle"
  
EndWith 

AddMapElement(Catalog(), "pbcompil")
With Catalog()
  \Translate(0) = "Compiler"
  \Translate(1) = "Compil"
  \Translate(2) = "Kompiliere"
EndWith 

AddMapElement(Catalog(), "libcreate")
With Catalog()
  \Translate(0) = "Créer bibliothéque"
  \Translate(1) = "Create library"
  \Translate(2) = "Erstelle Bibliothek"
EndWith 

AddMapElement(Catalog(), "libshow")
With Catalog()
  \Translate(0) = "Voir bibliothéques"
  \Translate(1) = "Show libraries"
  \Translate(2) = "Zeige Bibliotheken"
EndWith 


;Panel : View code ASM
AddMapElement(Catalog(), "panviewasm")
With Catalog()
  \Translate(0) = "Voir source ASM"
  \Translate(1) = "View ASM source"
  \Translate(2) = "Zeige ASM Code"
EndWith 

;Panel : View and/or updated code DESC
AddMapElement(Catalog(), "panviewdesc")
With Catalog()
  \Translate(0) = "Voir source DESC"
  \Translate(1) = "View DESC source" 
  \Translate(2) = "Zeige DESC Code"
EndWith 

AddMapElement(Catalog(), "save")
With Catalog()
  \Translate(0) = "Sauver"
  \Translate(1) = "Save" 
  \Translate(2) = "Speichern"
EndWith 

AddMapElement(Catalog(), "errordesc")
With Catalog()
  \Translate(0) = "Impossible de créer le fichier de description."
  \Translate(1) = "Failed to create description file." 
  \Translate(2) = "Erstellung der DESC Datei fehlgeschlagen."
EndWith 

AddMapElement(Catalog(), "successdesc")
With Catalog()
  \Translate(0) = "Création du fichier le description, terminée."
  \Translate(1) = "Create description file completed."
  \Translate(2) = "Erstellung der DESC Datei."
  
EndWith 

AddMapElement(Catalog(), "libexist")
With Catalog()
  \Translate(0) = "Supprimer la librairie si existante et relancer le compilateur."
  \Translate(1) = "Remove the library if it exists and restart the compiler." 
  \Translate(2) = "Ersetze die Bibliothek (falls sie existiert) und starte den Kompiler neu."
EndWith 

AddMapElement(Catalog(), "errorlib")
With Catalog()
  \Translate(0) = "Impossible de créer la librairie."
  \Translate(1) = "Unable to create library." 
  \Translate(2) = "Konnte Bibliothek nicht erstellen."
EndWith 

AddMapElement(Catalog(), "successlib")
With Catalog()
  \Translate(0) = "Création de la librairie terminée."
  \Translate(1) = "Create library completed."
  \Translate(2) = "Bibliothek erstellt."
EndWith 

AddMapElement(Catalog(), "errordelete")
With Catalog()
  \Translate(0) = "Imposssible de supprimer le fichier"
  \Translate(1) = "Unable to delete file"
  \Translate(2) = "Datei konnte nicht gelöscht werden"
EndWith 

Procedure InitLang(Gadget)
  AddGadgetItem(Gadget, -1, "Français")
  AddGadgetItem(Gadget, -1, "English")
  AddGadgetItem(Gadget, -1, "Deutsch")
  SetGadgetState(Gadget, Lang)
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
; CursorPosition = 23
; Folding = -
; EnableXP