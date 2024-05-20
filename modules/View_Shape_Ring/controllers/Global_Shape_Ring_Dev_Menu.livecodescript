script "Global | Shape | Ring | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Shape | Ring | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | Shape | Ring | Dev | Menu
-
on menu_EditBehavior ringView
   put the behavior of ringView into bObject 
   edit the script of bObject
end menu_EditBehavior

on menu_IncreaseNodeFactor ringView
   put the node_Factor of ringView into nodeFactor
   add (0.1 * nodeFactor) to nodeFactor
   set the node_Factor of ringView to nodeFactor
end menu_IncreaseNodeFactor

on menu_DecreaseNodeFactor ringView
   put the node_Factor of ringView into nodeFactor
   subtract (0.1 * nodeFactor) from nodeFactor
   set the node_Factor of ringView to nodeFactor
end menu_DecreaseNodeFactor

on menu_RefreshNodes ringView
   put the ring_NodeNumber of ringView into nodeNum
   set the ring_NodeNumber of ringView to nodeNum
end menu_RefreshNodes

private on _
end _

on menu_MenuEdit displayView
   menu_Edit "Global | Shape | Ring | Dev | Menu"
end menu_MenuEdit
