script "Global | Rough | Rectangle | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Rough | Rectangle | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
on menu_Init tObject
   -- called only once for top menu
   pass menu_Init
end menu_Init

getprop menu_Target [tObject]
   -- put the display_View of tObject into dView
   if the view_Name of tObject = "View|Rough|Rectangle" then return tObject
   put the displayed_Object of tObject into roughView
   return roughView
end menu_Target

getprop menu_CheckTarget [roughView]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget

getprop checked_ShowBrowser [roughView]
   put the show_Browser of roughView into sBoolean
   return sBoolean
end checked_ShowBrowser


--> Global | Rough | Rectangle | Menu
-
on menu_SetSvgCanvas roughView
   put the graphic_Rect of roughView into gRect
   set the rough_CanvasRect of roughView to gRect
end menu_SetSvgCanvas

on menu_DisplayRoughHtml roughView
   put the rough_HTML of roughView into roughHTML
   display_Text roughHTML, "roughHTML"
end menu_DisplayRoughHtml

on menu_SetRoughRect roughView
   put the graphic_Rect of roughView into rRect
   put lcw_Ask ("Set the rect...", rRect) into rRect
   set the rough_Rect of roughView to rRect
end menu_SetRoughRect

on menu_SetRough roughView
   put the graphic_Rect of roughView into gRect
   set the rough_Rect of roughView to gRect
end menu_SetRough

on _
end _

on menu_FillColour roughView
   set the fill_Colour of roughView to "green"
end menu_FillColour

on menu_ShowBrowser roughView
   put the show_Browser of roughView is false into toggleVisible
   set the show_Browser of roughView to toggleVisible
end menu_ShowBrowser

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_InitScaffold browserView
   dispatch "preOpenControl" to browserView
end menu_InitScaffold

on _
end _

on menu_TestSvg roughView
   put the browser_Element of browserView
end menu_TestSvg

on menu_TestRoughen roughView
   put "http://livecode.world/assets/graph/hierarchical.svg" into svgURL
   --
   put env_GetRepoFolder() & "sketchviz-docker/sketchviz/" into someDir
   put the defaultfolder into oDir
   --
   set the defaultfolder to someDir
   put url svgURL into url "file:downloaded.svg"
   put "node roughen.js 'downloaded.svg' 'roughened.svg'" into someShell
   get shell (someShell) -- (node:34706) ExperimentalWarning: The fs.promises API is experimental
   --
   set the defaultfolder to oDir
   --
   put someDir & "roughened.svg" into svgFile
   display_SVG svgFile, "roughened.svg"
end menu_TestRoughen

--  on menu_Filled roughView
set the rough_Filled ["green"] of roughView to true
end menu_Filled

on menu_Experiment roughView
   put roughView
end menu_Experiment


--> Deps
-
