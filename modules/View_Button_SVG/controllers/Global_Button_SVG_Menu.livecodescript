script "Global | Button | SVG | Menu"
--> MetaData
-
license: GPLv3
name: Global | Button | SVG | Menu
type: controller
version: 0.2

/* 
A default view menu for experimenting with SVG buttons in Livecode.
*/

local LocalArray

--> Meu | Props
-
getprop menu_Target [tObject]
   put the view_Object of tObject into svgView
   return svgView
end menu_Target

getprop setIconFamily_Param
   return getCurrentIconFamily()
end setIconFamily_Param

getprop setIconFamily_Params
   return iconFamilies()
end setIconFamily_Params

getprop setIcon_Param [svgButton]
   put the iconName of svgButton into iName
   return iName
end setIcon_Param

getprop setIcon_Params
   return iconNames()
end setIcon_Params

getprop importSvg_Params
   get the openstacks
   filter it with "Display SVG*"
   return it
end importSvg_Params

getprop disabled_DisplayIconData [svgButton]
   put the icon_Data of svgButton into iconData
   return iconData is not an array
end disabled_DisplayIconData


--> Global | Button | SVG | Menu
-
on menu_DisplayNounCollections
   display_NounCollections
end menu_DisplayNounCollections

on menu_GenerateIcon svgButton
   # Prompt
   put "Image prompt..." into sQuestion
   put "Marvin the paranoid robot from Hitchhikers Guide to the Galaxy" into sDefault
   -- put lcw_Ask (sQuestion, sDefault, svgButton) into sPrompt
   ask sQuestion with sDefault
   if the result is "Cancel" then exit to top
   put it into sPrompt
   
   # Params
   put svgStudio_GetStyle() into sStyle
   put svgStudio_GetDetailLevel() into dLevel
   --
   put 6/9*768 into sHeight
   put svgStudio_GenerateArray (768, sHeight, dLevel) into pArray
   
   # Generate
   put svgStudio_Generate (sPrompt, sStyle, pArray) into svgXML
   
   # Display
   if the shiftKey is "down" then
      display_SvgButton svgXML, sPrompt
   else
      put svg_GetPathText (svgXML) into svgPathText
      set the icon_PathText of svgButton to svgPathText
   end if
end menu_GenerateIcon

on menu_Style svgButton, sStyle
   svgStudio_SetStyle sStyle
end menu_Style

getprop style_Param
   return svgStudio_GetStyle()
end style_Param

getprop style_Params
   return svgStudio_ListStyles()
end style_Params

on menu_Detail svgButton, dLevel
   svgStudio_SetDetailLevel dLevel
end menu_Detail

getprop detail_Param
   return svgStudio_GetDetailLevel()
end detail_Param

getprop detail_Params
   return svgStudio_ListDetailLevels()
end detail_Params

private command _
end _

on menu_SetIcon svgButton, iName
   set the iconPresetName of svgButton to iName
end menu_SetIcon

on menu_SetIconFamily svgButton, fName
   setCurrentIconFamily fName
end menu_SetIconFamily

on menu_ResetIcon svgButton
   put the icon_Data of svgButton into iconData
   put iconData ["id"] into iconID
   --
   put noun_FetchIconData (iconID) into iconData
   --
   display_Data iconData
end menu_ResetIcon

private command __
end __

on submenu_Library
   return "Global | Svg | Library | Menu"
end submenu_Library

on menu_ImportSvg svgButton, vStackName
   put the long id of control 1 of stack vStackName into svgView
   --
   put the svg_XML of svgView into svgXML
   -- display_Text svgXML, "the svg_XML of svgView"
   --
   put svg_GetPathText (svgXML) into svgPathText
   set the iconPath of svgButton to svgPathText
end menu_ImportSvg

private command ___
end ___

on submenu_Assets
   return "Global | Svg | Assets | Menu"
end submenu_Assets

on submenu_Dev
   return menu_DevTitle("Global | Button | SVG | Menu")
end submenu_Dev

