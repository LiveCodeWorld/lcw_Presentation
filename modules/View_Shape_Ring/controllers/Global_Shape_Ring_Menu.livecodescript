﻿script "Global | Shape | Ring | Menu"
--> MetaData
-
license: GPLv3
name: Global | Shape | Ring | Menu
type: controller
version: 0.1


--> Menu | Props
-
getprop nodeNumber_Param [ringView]
   put the ring_NodeNumber of ringView into pointNum
   return pointNum
end nodeNumber_Param

getprop nodeNumber_Params
   return "0,-,3,4,5,6,7,8,9"
end nodeNumber_Params

getprop checked_ShowRing [ringView]
   return the ring_Visible of ringView
end checked_ShowRing

getprop checked_ShowPeople [ringView]
   return the people_Visible of ringView
end checked_ShowPeople

getprop checked_NumberPeople [mTarget]
   put the number_People of mTarget into someBoolean
   return someBoolean
end checked_NumberPeople

getprop checked_ShowBorder [ringView]
   put the showborder of ringView into someBoolean
   return someBoolean
end checked_ShowBorder

getprop disabled_Test [ringView]
   return false
end disabled_Test


--> Global | Shape | Ring | Menu
-
on menu_NodeNumber ringView, pointNum
   local pInitialRotation
   set the ring_NodeNumber [pInitialRotation] of ringView to pointNum
end menu_NodeNumber

on menu_InitialRotation ringView
   put the initial_Rotation of ringView into sRotation
   put lcw_Ask ("Set the initial_Rotation...", sRotation, "Rotation", ringView) into sRotation
   --
   set the initial_Rotation of ringView to sRotation
end menu_InitialRotation

private on _
end _

on menu_ShowPeople ringView
   put the people_Visible of ringView is false into someBoolean
   set the people_Visible of ringView to someBoolean
end menu_ShowPeople

on menu_NumberPeople mTarget
   put the number_People of mTarget is false into someBoolean
   set the number_People of mTarget to someBoolean
end menu_NumberPeople

on menu_ClearPeople ringView
   dispatch "clear_Nodes" to ringView
end menu_ClearPeople

private on __
end __

on menu_ShowRing ringView
   put the ring_Visible of ringView is false into someBoolean
   set the ring_Visible of ringView to someBoolean
end menu_ShowRing

on menu_ShowBorder ringView
   put the showborder of ringView is false into someBoolean
   set the showborder of ringView to someBoolean
end menu_ShowBorder

private on ___
end ___

on submenu_Dev
   return menu_DevTitle ("Global | Shape | Ring | Menu")
end submenu_Dev
