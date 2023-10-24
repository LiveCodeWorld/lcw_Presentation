script "Global | Noun | Collection | Menu"
--> MetaData
-
copyright: David Bovil
license: GPLv3
name: Global | Noun | Collection | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Props
-
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
on menu_SearchForIcon displayView
   put LocalArray ["IsPublic"] is true into isPublic
   --
   put lcw_Ask ("Search for an icon...", "Bird") into sQuery
   put noun_FindIcon (sQuery, isPublic) into iconSearchData
   --
   put iconSearchData ["total"] into iconTotal
   if iconTotal > 0 then
      put iconSearchData ["icons"] into indexedIconData
      display_IndexedIconData indexedIconData, sQuery, "Noun Project", "Noun | Collection", "mDoubleUp_NounCollections"
   else
      display_Data iconSearchData, "iconSearchData"
   end if
end menu_SearchForIcon

getprop checked_IsPublic
   return LocalArray ["IsPublic"] is true
end checked_IsPublic
   
on menu_IsPublic dView
   put LocalArray ["IsPublic"] is false into LocalArray ["IsPublic"]
end menu_IsPublic

private on _
end _

on menu_DisplayCollectionData displayView
   put the collection_Data of displayView into collectionData
   display_Data collectionData, "collection_Data"
end menu_DisplayCollectionData

on menu_DisplayCollections
   display_NounCollections
end menu_DisplayCollections

private on __
end __

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

private on ___
end ___

on menu_NounApi
   launch url "https://thenounproject.com/api/"
end menu_NounApi

on submenu_Dev
   return menu_DevTitle()
end submenu_Dev
