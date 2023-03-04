script "Global | Shape | Hexagon | Menu"
--> MetaData
-
license: GPLv3
name: Global | Shape | Hexagon | Menu
type: controller
version: 0.1


--> Global | Shape | Hexagon | Menu
-
on menu_TestPoints hObject
   put the hexagon_Points of hObject into hPoints
   put the graphic_Object of hObject into gObject
   put the effective points of gObject & CR&CR & hPoints
end menu_TestPoints

on _
end _

on menu_InitHexagon sHexagon
   put the rect of sHexagon into oRect
   lock screen
   dispatch "hexagon_InitPoints" to sHexagon
   -- dispatch "LayoutControl" to sHexagon with oRect
   unlock screen
end menu_InitHexagon

on menu_Points sHexagon, gNum
   put the hexagon_Points of sHexagon
end menu_Points

on submenu_Tools
return "Global | Shape | Hexagon | Tools | Menu"
end submenu_Tools
