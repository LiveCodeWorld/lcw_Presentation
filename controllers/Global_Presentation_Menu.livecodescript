script "Global | Presentation | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Presentation | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
on menu_Init
   -- put model_ListNames ("lcw_Presentation", projectFolder)
   put the model_Names of stack "lcw_Presentation" into LocalArray ["modelNames"]
end menu_Init

getprop menu_Target [tObject]
   return the display_View of tObject
end menu_Target

getprop checked_AnimationEngine
   put animation_EngineIsOn() into isOn
   return isOn
end checked_AnimationEngine

getprop displayPresentationData_Params
   return LocalArray ["modelNames"]
end displayPresentationData_Params

getprop openPresentation_Params
   return LocalArray ["modelNames"]
end openPresentation_Params


--> Global | Presentation | Menu
-
on menu_SavePresentation
   put "Browser,View|Camera,View|Lexon|Contract" into stackNames
   --
   repeat for each item stackName in stackNames
      if exists (stack stackName) is false then next repeat
      --
      put the rect of stack stackName into displayData [stackName]["stackRect"]
      --
      put the stack_Frame of stack stackName into displayData [stackName]["stack_Frame"]
      get the displayed_Data of stack stackName
      if it is an array then put it into displayData [stackName]["displayed_Data"]
   end repeat
   
   put "lcw_Presentation" into modelName
   set the model_Array ["lexon.array"] of stack modelName to displayData
   put the result into filePath
   finder_Reveal filePath
   put filePath
   --
end menu_SavePresentation

on _
end _

on menu_OpenPresentation displayView, shortFile
   put the model_Array [shortFile] of stack "lcw_Presentation" into pData
   --
   repeat for each key stackName in pData
      if exists (stack stackName) is false then next repeat
      --
      put pData [stackName]["stackRect"] into stackRect
      put pData [stackName]["stackFrame"] into stackFrame
      --
      go to stack stackName
      set the rect of stack stackName to stackRect
      set the stack_Frame of stack stackName to stackFrame
   end repeat
end menu_OpenPresentation

on menu_ClosePresentation displayView, shortFile
   put the model_Array [shortFile] of stack "lcw_Presentation" into pData
   --
   repeat for each key stackName in pData
      if exists (stack stackName) is false then next repeat
      --
      delete stack stackName
   end repeat
end menu_ClosePresentation

on menu_DisplayPresentationData displayView, shortFile
   put the model_Array [shortFile] of stack "lcw_Presentation" into pData
   --
   display_Data pData, shortFile, "Presentation Data"
end menu_DisplayPresentationData

on _
end _

on menu_AnimationEngine
   put menu_GetChecked (the params) into isChecked
   animation_EngineStart someBoolean
   put the result into homePath
   go to stack homePath
end menu_AnimationEngine

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplayModelData
   put the model_Data of me into modelData
   -- put the model_Data ["lcw_Presentation"] of me into modelData
   display_Data modelData, "Model Data", "lcw_Presentation"
end menu_DisplayModelData

on _
end _

on menu_CreateNewTransport
   put pageArray_Fetch ("transport.fedwiki.org", "micro-app-maker") into pageArray
   --
   put pageArray_GetSectionItemText ("code", pageArray, "HTML") into someHTML
   put pageArray_GetSectionItemText ("code", pageArray, "CSS") into someCSS
   put pageArray_GetSectionItemText ("code", pageArray, "Javascript") into someJS
   --
   display_PageArray pageArray, "Micro App Maker"
end menu_CreateNewTransport

on menu_FindOriginalPhoto
   display_TestPhoto
end menu_FindOriginalPhoto

on _
end _

on menu_ListCountries
   display_IntentionalCountries
end menu_ListCountries

-- on menu_ListCountry
put ic_FetchCountryData ("Australia", "New South Wales") into icListData
put ic_PageFromListData (icListData) into pageArray
display_PageArray pageArray
end menu_ListCountry

-- on menu_ImportCommunity
-- put "aletheia-springs" into cSlug
put "todos-santos-cohousing-ecovillage" into cSlug
put "1st-intl-model-life-change-ecovillage-and-pioneer-settlement-project" into cSlug
--
put ic_FetchCommunityData (cSlug) into icData
put icData ["name"] into communityTitle
--
display_Data icData, communityTitle, "ic.org"
end menu_ImportCommunity
