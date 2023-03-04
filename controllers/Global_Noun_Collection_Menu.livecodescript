script "Global | Noun | Collection | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Noun | Collection | Menu
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
   put the display_View of tObject into displayView
   --
   put the indexed_IconData of displayView into LocalArray ["indexedIconData"]
   put the icon_NameData of displayView into LocalArray ["iconNameData"]
   --
   return displayView
end menu_Target

getprop checked_FilterForSvgs [displayView]
   put LocalArray ["isFiltered"] is true into isFiltered
   return isFiltered
end checked_FilterForSvgs


--> Global | Noun | Collection | Menu
-
on menu_FilterForSvgs displayView
   put LocalArray ["indexedIconData"] into indexedIconData
   -- display_Data indexedIconData, "indexedIconData"
   --
   if LocalArray ["isFiltered"] is true then
      put false into LocalArray ["isFiltered"]
   else
      put noun_FilterIndexIconData (indexedIconData) into indexedIconData
      put true into LocalArray ["isFiltered"]
   end if
   --
   put noun_ConstructIconNameData (indexedIconData) into iconNameData
   put keys (iconNameData) into newKeys
   sort newKeys
   --
   set the displayed_Index of displayView to newKeys
end menu_FilterForSvgs

on _
end _
