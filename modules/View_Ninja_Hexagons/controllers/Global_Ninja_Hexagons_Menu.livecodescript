script "Global | Ninja | Hexagons | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Ninja | Hexagons | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
-- getprop menu_Target [tObject]
return the display_View of tObject
end menu_Target

-- getprop menu_CheckTarget [mTarget]
-- use to do initialisation
pass menu_CheckTarget
menu_CheckTarget

getprop checked_HexRing [vObject]
   put the hexRing_Visible of vObject into sBoolean
   return sBoolean
end checked_HexRing


--> Global | Ninja | Hexagons | Menu
-
on menu_HexRing vObject
   put the hexRing_Visible of vObject into sBoolean
   set the hexRing_Visible of vObject to (sBoolean is false)
end menu_HexRing

on menu_SetGeometry vObject
   dispatch "TestLayout" to vObject with the rect of vObject
end menu_SetGeometry

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment displayView
   put displayView
end menu_Experiment


--> Deps
-
