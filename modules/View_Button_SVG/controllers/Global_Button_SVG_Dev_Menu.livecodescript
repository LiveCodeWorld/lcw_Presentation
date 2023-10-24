script "Global | Button | SVG | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Button | SVG | Dev | Menu
type: controller
author: David Bovill
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
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop checked_NounApiKey
   put noun_GetConsumerKey() into apiKey
   return apiKey is not empty
end checked_NounApiKey

getprop checked_NounSecret
   put noun_GetApiSecret() into apiSecret
   return apiSecret is not empty
end checked_NounSecret


--> Global | Button | SVG | Dev | Menu
-
on menu_DiplaySvgPath svgButton
   put the iconPath of svgButton into svgPath
   display_Text svgPath, "the iconPath of svgButton"
end menu_DiplaySvgPath

private command _
end _

on menu_DisplayIconData svgButton
   put the icon_Data of svgButton into iconData
   --
   display_Data iconData
end menu_DisplayIconData

private command __
end __

on menu_NounApiKey
   put noun_GetConsumerKey() into apiKey
   put lcw_Ask("Set  the Noun ApiKey...", apiKey) into apiKey
   noun_SetConsumerKey apiKey
end menu_NounApiKey

on menu_NounSecret
   put noun_GetApiSecret() into apiSecret
   put lcw_Ask ("Set the Noun Api Secret...", apiSecret) into apiSecret
   noun_SetApiSecret apiSecret
end menu_NounSecret
