script "lib_DisplaySvgXml"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplaySvgXml
type: library
version: 0.1


--> Working on
-


--> Display | SvgXml
-
command display_SvgXml svgXML, pTitle, pStyle, pRectHow
   clone_Module "View|Image|Svg", svgXML, pTitle, "Svg XML", pStyle, pRectHow
   put the result into svgView
   return svgView
end display_SvgXml

command clone_Module vName, sData, pTitle, pStackLabel, pStyle, pRectHow, pToolContext
   if pToolContext is empty then
      put the name of me into pToolContext
   end if
   
   # Clone
   clone_Invisible pTitle, pStackLabel, vName
   put the result into dView
   
   # Set Data
   set the displayed_Data [pTitle] of dView to sData
   
   # Set the stack rect
   put the formatted_Rect [pRectHow] of dView into sRect
   if sRect is a rect then
      set the stack_Rect of dView to sRect
   end if
   
   # Show
   put the stack_Name of dView into cStackName
   set the visible of stack cStackName to true
   
   # Set Controllers
   put default_MenuBit (mTitle, pStackLabel) into mBit
   set the menu_TitleBit [pToolContext] of dView to mBit
   
   # Set context for new (menu) tool creation
   set the tool_Context of dView to pToolContext
   return dView
end clone_Module

function default_MenuBit mTitle, pStackLabel
   if pStackLabel is empty then
      put menu_Bit (pTitle) into mBit
      return mBit
   end if
   
   set the itemdelimiter to "|"
   put mTitle into middleBit
   put word 1 to -1 of item 1 of mTitle into firstBit
   switch firstBit
      case "View"
      case "Layout"
      case "Global"
         delete item 1 of middleBit
         break
   end switch
   --
   put word 1 to -1 of item -1 of mTitle into lastBit
   if lastBit = "Menu" then
      delete item -1 of middleBit
   end if
   --
   return word 1 to -1 of middleBit
end default_MenuBit

command clone_Invisible pTitle, pStackLabel, pViewName
   -- was display_InvisibleTool
   if pViewName is empty then put "View|Data" into pViewName
   
   # Name & Clone
   put stack_CleanName ("Display" && pTitle) into cloneName
   put there is a stack cloneName into stackExisted
   if stackExisted then
      put cloneName into cloneStackName
   else
      stack_CloneInvisible pViewName, cloneName
      put the result into cloneStackName
      if pStackLabel is not empty then
         set the label of stack cloneStackName to pStackLabel
      end if
   end if
   
   # Display View
   put the module_View of cd 1 of stack cloneStackName into dView
   if exists (dView) then return dView
   
   # Default Display View
   if exists (control 1 of cd 1 of stack cloneStackName) is false then
      breakpoint
      return "Error, could not find dView:" && cloneStackName
   end if
   
   put the long id of control 1 of cd 1 of stack cloneStackName into dView
   return dView
end clone_Invisible


--> Deps
-
