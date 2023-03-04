script "Global | Noun | Collections | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Noun | Collections | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- called once for each menu
   return the display_View of tObject
end menu_Target

getprop displayIconFamily_Param
   return getCurrentIconFamily()
end displayIconFamily_Param

getprop displayIconFamily_Params
   return iconFamilies()
end displayIconFamily_Params


--> Global | Svg | Library | Menu
-


--> Global | Noun | Collections | Menu
-
on menu_SearchForKeyword displayView
   put lcw_Ask ("Enter a keyword to search...", "cow", displayView) into sKeyWord
   --
   display_NounTagIcons sKeyWord
end menu_SearchForKeyword

on menu_SearchPublicDomain displayView
   put lcw_Ask ("Enter a keyword to search...", "cow", displayView) into sKeyWord
   --
   display_NounTagIcons sKeyWord, true
end menu_SearchPublicDomain

on menu_AskCollection displayView
   put lcw_Ask ("Enter a collection slug...", "futuristic-technology", displayView) into collectionSlug
   --
   display_NounCollection collectionSlug
end menu_AskCollection

on _
end _

on submenu_IconLibrary
   return "Global | Svg | Library | Menu"
end submenu_IconLibrary

on menu_DisplayIconFamily svgView, iFamilyName
   display_IconFamily iFamilyName
end menu_DisplayIconFamily

on _RefreshNounCollections
   display_NounCollections
end _RefreshNounCollections

-- on menu_ReFetchData displayView
put noun_FetchCollectionsData() into collectionData
display_Data collectionData, "noun_FetchCollectionsData()"
--
display_NounCollections
end menu_ReFetchData

-- on menu_DisplayData displayView
put the displayed_Data of displayView into afds
put the collection_Data of displayView into collectionData
put the cName_Array of displayView into cNameArray
--
display_Data collectionData
end menu_DisplayData
