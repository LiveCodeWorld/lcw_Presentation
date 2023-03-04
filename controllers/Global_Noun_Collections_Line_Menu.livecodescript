script "Global | Noun | Collections | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Noun | Collections | Line | Menu
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
   put the display_View of tObject into displayView
   --
   put the selected_Line of displayView into collectionName
   put the collection_Data of displayView into collectionData
   put the cName_Array of displayView into cNameArray
   --
   put cNameArray [collectionName]["itemNum"] into itemNum
   put collectionData [itemNum] into collectionArray
   put collectionArray ["slug"] into collectionSlug
   --
   put collectionName into LocalArray ["collectionName"]
   put collectionArray into LocalArray ["collectionArray"]
   put collectionSlug into LocalArray ["collectionSlug"]
   --
   return displayView
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget

getprop test_Param [mTarget]
   return "b"
end test_Param

getprop test_Params [mTarget]
   return "a,b,c"
end test_Params

getprop checked_TestChecked
   return true
end checked_TestChecked

getprop disabled_Test
   return false -- true, "delete"
end disabled_Test


--> Global | Noun | Collections | Line | Menu
-
on menu_DisplayCollection displayView
   put LocalArray ["collectionArray"] into collectionArray
   put LocalArray ["collectionSlug"] into collectionSlug
   --
   display_NounCollection collectionSlug, collectionArray
end menu_DisplayCollection

on _
end _

on menu_DisplayCollectionArray displayView
   put LocalArray ["collectionName"] into collectionName
   put LocalArray ["collectionArray"] into collectionArray
   put LocalArray ["collectionSlug"] into collectionSlug
   --
   display_Data collectionArray, collectionName, "collectionArray"
end menu_DisplayCollectionArray

on menu_FetchCollectionData displayView
   put LocalArray ["collectionName"] into collectionName
   put LocalArray ["collectionArray"] into collectionArray
   put LocalArray ["collectionSlug"] into collectionSlug
   --
   -- put noun_FetchCollectionIconData (collectionSlug) into collectionIconsData
   put noun_FetchCollectionData (collectionSlug) into collectionData
   --
   display_Data collectionData, collectionName, "noun_FetchCollectionData (collectionSlug)"
end menu_FetchCollectionData
