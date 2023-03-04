script "Global | Button | SVG | Menu"
--> MetaData
-
license: GPLv3
name: Global | Button | SVG | Menu
type: controller
version: 0.2

/* 
*/

local LocalArray

--> Meu | Props
-
getprop menu_Target [tObject]
   pass menu_Target
end menu_Target

getprop menu_IsSimple
   return true
end menu_IsSimple

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
   
private command _
end _

on submenu_Library
   return "Global | Svg | Library | Menu"
end submenu_Library

on menu_DisplayIconData svgButton
   put the icon_Data of svgButton into iconData
   --
   display_Data iconData
end menu_DisplayIconData

private command __
end __

on submenu_Assets
   return "Global | Svg | Assets | Menu"
end submenu_Assets

on menu_DiplaySvgPath svgButton
   put the iconPath of svgButton into svgPath
   display_Text svgPath, "the iconPath of svgButton"
end menu_DiplaySvgPath

on menu_DisplayNounCollections
   display_NounCollections
end menu_DisplayNounCollections

on menu_ImportSvg svgButton, vStackName
   put the long id of control 1 of stack vStackName into svgView
   --
   put the svg_XML of svgView into svgXML
   -- display_Text svgXML, "the svg_XML of svgView"
   --
   put svg_GetPathText (svgXML) into svgPathText
   set the iconPath of svgButton to svgPathText
end menu_ImportSvg

private command __
end __

on menu_TestTemplate
   put scaffold_GetTemplate ("SVG") into svgTemplate
   test_Svg svgTemplate
end menu_TestTemplate

