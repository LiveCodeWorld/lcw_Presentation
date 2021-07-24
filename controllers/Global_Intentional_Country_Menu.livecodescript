script "Global | Intentional | Country | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Intentional | Country | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- called once for each menu
   return the display_View of tObject
end menu_Target

getprop filterByHubspot_Param [displayView]
   put the title_Text of displayView into cType
   return cType
end filterByHubspot_Param

getprop filterByHubspot_Params
   return "Indexed,Not Indexed,-,All"
end filterByHubspot_Params

getprop filterByType_Param [displayView]
   put the title_Text of displayView into cType
   return cType
end filterByType_Param

getprop filterByType_Params
   return "Cohousing,Commune,Ecovillage,Shared,Spiritual,Traditional,Transition,Unspecified,-,All"
end filterByType_Params

getprop switchCounty_Param [displayView]
   put the stack_Label of displayView into displayedCountry
   return displayedCountry
end switchCounty_Param

getprop switchCounty_Params
   return ic_CountryList()
end switchCounty_Params


--> Global | Intentional | Country | Menu
-
on menu_SwitchCounty displayView, someCountry
   set the cursor to watch
   if the shiftkey is "down" then
      display_IntentionalCountry someCountry
   else
      display_IntentionalCountry someCountry, displayView
   end if
end menu_SwitchCounty

on menu_FilterByType displayView, cType
   put the ic_ListData of displayView into icListData
   --
   if cType = "All" then
      put the named_Data of displayView into namedData
      put the keys of namedData into cNames
      sort cNames
   else
      put ic_FilterByCommunityType (icListData, cType) into cNames
   end if
   --
   set the displayed_Index of displayView to cNames
   set the title_Text of displayView to cType
end menu_FilterByType

on menu_FilterByHubspot displayView, hType
   lock screen  
   switch hType
      case "all"
         menu_FilterCommunities displayView, "all"    
         break
      case "Indexed"
         put hubspot_FindNamedData() into hubspotNamedData
         put the named_Data of displayView into icNamedData
         --
         difference icNamedData with hubspotNamedData
         --
         put the keys of icNamedData into notInhubSpot
         sort notInhubSpot
         set the displayed_Index of displayView to notInhubSpot
         break
      default
         put hubspot_FindNamedData() into hubspotNamedData
         put the named_Data of displayView into icNamedData
         --
         difference icNamedData with hubspotNamedData
         --
         put the keys of icNamedData into notInhubSpot
         sort notInhubSpot
         set the displayed_Index of displayView to notInhubSpot
   end switch
   --
   unlock screen
end menu_FilterByHubspot
   
on _
end _

on menu_Refresh displayView
   put the stack_Label of displayView into someCountry
   display_IntentionalCountry someCountry
end menu_Refresh

on _
end _

on menu_HubspotContacts
   display_HubContacts
end menu_HubspotContacts

on menu_HubspotCompanies
   display_HubspotCompanies
end menu_HubspotCompanies

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_ColourHubspot displayView
   lock screen
   menu_FilterCommunities displayView, "all"
   
   put hubspot_FindNamedData() into hubspotNamedData
   put the named_Data of displayView into icNamedData
   --
   difference icNamedData with hubspotNamedData
   put the keys of icNamedData into notInhubSpot
   sort notInhubSpot
   --
   set the coloured_Lines ["red"] of displayView to notInhubSpot
   unlock screen
end menu_ColourHubspot

on _
end _

on menu_HubspotLibrary displayView
   edit the script of stack "lib_Hubspot"
end menu_HubspotLibrary

on menu_ConstructTypes displayView
   put the ic_ListData of displayView into icListData
   --
   put icListData ["listings"] into listingData
   --
   put 1 into fNum
   repeat with itemNum = 1 to item 2 of the extents of listingData
      put listingData [itemNum] into itemArray
      put itemArray ["name"] into cName
      put itemArray ["communityTypes"] into typeArray
      repeat for each key typeNum in typeArray
         put typeArray [typeNum] into testType
         put word 1 of testType into typeName
         put testType into tNameArray [typeName]
      end repeat
   end repeat
   put the keys of tNameArray into typeNames
   sort typeNames
   replace CR with comma in typeNames
   put typeNames
end menu_ConstructTypes

on _
end _

on menu_DisplayCommuniytData
   put _GetSlug (displayView) into icSlug
   put ic_FetchCommunityData (icSlug) into communityData
   display_Data communityData, "ic_FetchCommunityData(icSlug)"
   --
   put ic_PageFromCommunityData (communityData) into pageArray
   display_PageArray pageArray
end menu_DisplayCommuniytData

on test_TestCommunity displayView
   put _GetSlug (displayView) into icSlug
   --
   put ic_FetchCommunityData (icSlug) into communityData
   display_Data communityData, icSlug
   --
   put ic_PageFromCommunityData (communityData) into pageArray
   display_PageArray pageArray
end test_TestCommunity
