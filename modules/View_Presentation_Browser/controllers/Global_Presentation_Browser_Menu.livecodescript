script "Global | Presentation | Browser | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Presentation | Browser | Menu
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
   -- called once for each menu
   return tObject
end menu_Target


--> Global | Presentation | Browser | Menu
-
on menu_TestChecked
  put menu_GetChecked (the params)
end menu_TestChecked

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
