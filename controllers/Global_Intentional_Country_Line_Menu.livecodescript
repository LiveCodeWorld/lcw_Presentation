script "Global | Intentional | Country | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Intentional | Country | Line | Menu
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
   return tObject
end menu_Target

getprop disabled_TestHubspotCreateContact [displayView]
   put _GetArray (displayView) into tArray
   put tArray ["slug"] into icSlug
   put ic_FetchCommunityData (icSlug) into communityData
   --
   put communityData ["contactName"] into contactName
   if text_IsEmpty (missionStatement) then
      return true
   else
      return false
   end if
end disabled_TestHubspotCreateContact

private function _GetArray displayView
   -- put _GetArray (displayView) into tArray
   -- put tArray ["slug"] into icSlug
   
   if the number of items of the selected_Path of displayView = 1 then
      put the selected_Array of displayView into tArray
   else
      put the parent_Array of displayView into tArray
   end if
   return tArray
end _GetArray

private function _GetSlug tObject
   put the display_View of tObject into displayView
   put the selected_Line of displayView into cName
   --
   put the ic_ListData of displayView into icListData
   put ic_FindCommunityArray (cName, icListData) into cArray
   put cArray ["slug"] into icSlug
   return icSlug
end _GetSlug


--> Global | Intentional | Country | Line | Menu
-
on menu_CreateCompanyAndContact displayView
   put _GetSlug (displayView) into icSlug
   --
   ic_CreateCompanyAndContact icSlug
   put the result into resultArray
   --
   display_Data resultArray, "ic_AddAndAssociateContactToCompany"
end menu_CreateCompanyAndContact

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
