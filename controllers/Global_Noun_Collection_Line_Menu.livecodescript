script "Global | Noun | Collection | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Noun | Collection | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_IsSimple
   return true
end menu_IsSimple

getprop menu_Target [tObject]
   -- called once for each menu
   return the display_View of tObject
end menu_Target

private function _GetIconID displayView
   -- quick hack
   put the selected_Line of displayView into iconName
   put word -1 of iconName into iconID
   return iconID
end _GetIconID

private function _GetIconData displayView
   put the selected_Line of displayView into iconName
   put the icon_NameData of displayView into iconNameData
   put iconNameData [iconName]["data"] into iconData
   return iconData
end _GetIconData


--> Global | Noun | Collection | Line | Menu
-
on menu_DisplayIcon displayView
   put _GetIconID (displayView) into iconID
   put _GetIconData (displayView) into iconData
   put the selected_Line of displayView into iconName
   --
   put noun_FetchIconPath (iconID) into svgPathText
   --
   display_Clone "View|Button|Svg", iconName, svgPathText, "icon_PathText", "mouse", "toplevel"
   put the result into svgButton
   -- display_ToolStack svgButton
   --
   -- set the icon_Data of svgButton to iconData
end menu_DisplayIcon

on menu_DisplayNounSvg displayView
   put _GetIconID (displayView) into iconID
   display_NounIcon iconID
end menu_DisplayNounSvg

on menu_LaunchIcon displayView
   put _GetIconData (displayView) into iconData
   --
   launch_NounIcon iconData
end menu_LaunchIcon

on menu_NounIconBrowser displayView
   put _GetIconData (displayView) into iconData
   --
   display_NounBrowser iconData
end menu_NounIconBrowser

on _
end _

on menu_FetchIconPath displayView
   put _GetIconID (displayView) into iconID
   --
   put noun_FetchIconPath (iconID)
end menu_FetchIconPath

on menu_GetItemData displayView
   -- no nested info like "collections, tags, uploader"
   put _GetIconData (displayView) into iconData
   --
   put the selected_Line of displayView into iconName
   display_Data iconData, iconName, "Local Icon Data"
end menu_GetItemData

on menu_FetchIconData displayView
   -- contains nested info like "collections, tags, uploader"
   put _GetIconID (displayView) into iconID
   put noun_FetchIconData (iconID) into iconData
   --
   put the selected_Line of displayView into iconName
   display_Data iconData, iconName, "Fetched Icon Data"
end menu_FetchIconData
