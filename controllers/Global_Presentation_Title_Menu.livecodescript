script "Global | Presentation | Title | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Presentation | Title | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [vObject]
   -- called once for each menu
   return vObject
end menu_Target

getprop checked_Lock [vObject]
   put the title_Locked of vObject into titleLocked
   return titleLocked
end checked_Lock

getprop checked_FixAutoSizes [vObject]
   put the show_AutoSizeStyle of vObject into modelTextSizes
   switch
      case modelTextSizes = "auto"
         return true 
      case modelTextSizes is empty
      case modelTextSizes is a number
      default
         return false
   end switch  
end checked_FixAutoSizes

getprop autosize_Param [vObject]
   -- return "auto"
   put the show_AutoSizeStyle of vObject into autoSizeStyle
   return autoSizeStyle
end autosize_Param

getprop autosize_Params
   -- return "auto,fixed,frozen,-,none"
   return the hkey_CaseConditions ["M menu_AutoSize"] of me 
end autosize_Params

getprop checked_AddBehavior [vObject]
   put _BehaviorAdded (vObject) into isAdded
   return isAdded
end checked_AddBehavior

getprop setShowModel_Param [vObject]
   put the show_ModelName of vObject into showModelName
   return showModelName
end setShowModel_Param

getprop setShowModel_Params [vObject]
   return the hkey_CaseConditions ["M menu_SetShowModel"] of me
end setShowModel_Params

private function _BehaviorAdded vObject
   put _PresentationBehaviors() into pObjects
   --
   put the card_Object of vObject into cObject
   put the behavior_Objects of cObject into bObjects
   return bObjects = pObjects
end _BehaviorAdded

private function _PresentationBehaviors
   put the name of stack "behavior_ViewTemplateCard" into bObjects
   put CR & the name of stack "behavior_SlideShow" after bObjects
   return bObjects
end _PresentationBehaviors


--> Global | Presentation | Title | Menu
-
on menu_Shrink vObject
   put the title_TextSize of vObject into tSize
   repeat with nSize = tSize down to 1
      set the title_CentredSize of vObject to nSize
      wait 1 tick
   end repeat
   
   /*
   subtract 6 from shrinkSize
   put tSize * -1 into shrinkSize
   set the animate_TextSize of vObject to shrinkSize
   --
   put shrinkSize
   */
end menu_Shrink

on menu_Grow vObject
   put the title_TextSize of vObject into oSize
   --
   set the animate_TextSize of vObject to -10
   --
   put the title_TextSize of vObject into newSize
   put newSize - oSize
end menu_Grow

on menu_Lock vObject 
   put not the title_Locked of vObject into toggleLocked
   set the title_Locked of vObject to toggleLocked
end menu_Lock

on _
end _

on menu_AutoSize vObject, pSizeHow
   switch pSizeHow
      case "auto"
         set the show_AutoSizeStyle of vObject to "auto"
         break
      case "fixed"
         put the title_TextSize of vObject into tSize
         put lcw_Ask ("Set a fixed text-size for all slides?", tSize, vObject) into tSize
         set the show_AutoSizeStyle of vObject to tSize
         break
      case "none"
         set the show_AutoSizeStyle of vObject to "empty"
         break
   end switch
end menu_AutoSize

on menu_FixAutoSizes vObject
   if the show_AutoSizeStyle of vObject = "auto" then
      set the show_AutoSizeStyle of vObject to empty
   else
      set the show_AutoSizeStyle of vObject to "auto"
   end if
end menu_FixAutoSizes

on _
end _

on menu_AddBehavior vObject
   put the card_Object of vObject into cObject
   put _BehaviorAdded (vObject) into isAdded
   put the show_Model of vObject into slideModel
   put the slide_Number of vObject into oNum
   --
   if isAdded is true then
      put the name of stack "behavior_ViewTemplateCard" into bObject
      set the behavior_Objects of cObject to bObject
   else
      put _PresentationBehaviors() into bObjects
      set the behavior_Objects of cObject to bObjects
   end if
   --
   set the show_Model of vObject to slideModel
   set the slide_Number of vObject to oNum
end menu_AddBehavior

on menu_SetShowModel vObject, showModelName
   switch showModelName
      case "Lineup"
         get "http://liquidlaw.org/view/welcome-visitors/view/lexon/view/how-legislative-theatre-works/view/legislative-theatre-with-lexon/view/stress-test-contracts"
         put it into lineupURL
         --
         put fedwiki_FetchLineUpData (lineUpURL) into lineUpData
         --
         put lineUpData ["wikiDomain"] into wikiDomain 
         put lineUpData ["lineUp"] into slideModel
         --
         break
      case "visualjam.org"
         put "visualjam.org" into wikiDomain
         put fedwiki_FetchSitemapArray (wikiDomain) into slideModel
         break
   end switch
   --
   set the show_Model of vObject to slideModel
   set the slide_Number of vObject to 1
   set the show_ModelName of vObject to showModelName
end menu_SetShowModel

on menu_DisplayShowModel vObject
   put the show_Model of vObject into slideModel
   put the show_ModelName of vObject into showModelName
   --
   display_Data slideModel, showModelName, "Slide Model"
end menu_DisplayShowModel

on _
end _

on menu_SetSlideMargins vObject
   put the margins of vObject into vMargins
   --
   put lcw_Ask ("Set the margins of this view:", vMargins, vObject) into newMargins
   --
   lock screen
   set the margins of vObject to newMargins
   dispatch "LayoutControl" to vObject
   unlock screen
end menu_SetSlideMargins

on _
end _

on submenu_Bullets
   return "Global | Presentation | Title and Bullets | Menu"
end submenu_Bullets

on submenu_Geometry
   return "Global | View | Geometry | Menu"
end submenu_Geometry

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_DisplayModuleTools vObject
   put the module_Name of vObject into moduleName
   display_ModuleTools moduleName
end menu_DisplayModuleTools

on _
end _

on menu_TestTitle vObject
   set the title_Text of vObject to "Hello World"
end menu_TestTitle

on menu_Next vObject
   set the slide_Number of vObject to "next"
end menu_Next

on menu_Previous vObject
   set the slide_Number of vObject to "previous"
end menu_Previous

on _
end _

on menu_ViewBehavior vObject
   put the behavior of vObject into bObject
   if exists (bObject) then
      edit the script of bObject
   else
      edit the script of vObject
   end if
end menu_ViewBehavior

on menu_CardBehaviors vObject
   put the card_Object of vObject into cObject
   put the behavior_Objects of cObject into bObjects
   repeat for each line bObject in bObjects
      if exists (bObject) then
         edit the script of bObject
      else
         put bObject & CR after badBehaviorObjects
      end if
   end repeat
   delete char -1 of badBehaviorObjects
   --
   if badBehaviorObjects is not empty then
      put badBehaviorObjects
   end if
end menu_CardBehaviors

on menu_LayoutControl pView, pHow
   switch pHow
      case "auto"
      case "scale"
      case "default size"
   end switch
   put word 1 of pHow into pHow
   dispatch "LayoutControl" to pView with empty,pHow
end menu_LayoutControl

on menu_FixScale pView
   dispatch "fix_Scaled" to pView
end menu_FixScale
