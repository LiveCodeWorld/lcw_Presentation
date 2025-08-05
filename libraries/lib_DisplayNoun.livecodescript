script "lib_DisplayNoun"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_DisplayNoun
type: library
version: 0.2

/*Some help*/


--> Working on
-

--> Display | Events
-
on drop_NounUrl dTarget
   put the dragdata ["text"] into droppedURL
   switch
      case matchText (droppedURL, "https://thenounproject.com/term/(.+)/(.+)/", iconTerm, iconID)
         display_NounIcon iconID
         break
      case matchText (droppedURL, "https://thenounproject.com/(.+)/collection/(.+)/\?i=(.+)" , authorName, collectionSlug, iconID)
         -- https://thenounproject.com/konkapp/collection/vaccine/?i=4020707
         display_NounIcon iconID
         display_NounCollection collectionSlug
         break
      case matchText (droppedURL, "https://thenounproject.com/(.+)/collection/(.+)/" , authorName, collectionSlug)
         display_NounCollection collectionSlug
         break
      default
         put droppedURL
   end switch
end drop_NounUrl


--> Display
-
command launch_NounIcon iconData
   if iconData is a number then
      put iconData into iconID
      display_NounIcon iconID
   else
      put "https://thenounproject.com" & iconData ["permalink"] into nounURL
      launch url nounURL
   end if
end launch_NounIcon

command display_NounIcon iconID, pDisplayView, pSvgButton, pStackStyle, pLocOrRect
   if pStackStyle is empty then put "palette" into pStackStyle
   --
   put noun_FetchIconData (iconID) into iconData
   --
   put iconData ["Term"] into iconTerm
   put iconData ["icon_url"] into iconURL
   put noun_ConstructIconName (iconData) into iconName
   --
   if iconURL is not empty then
      _DisplaySvgIcon iconID, iconURL, iconName, iconData, pSvgButton
      put the result into svgButton
      if the shiftKey is "Up" then
         return svgButton
      end if
   end if
   --
   if iconURL is empty or the shiftKey is "Down" then
      _DisplayIconimage iconData, iconName, pDisplayView, pStackStyle
      put the result into imageView
      if iconURL is empty then
         return imageView
      else
         return svgButton
      end if
   end if
end display_NounIcon

command display_SvgIcon iconName, svgPathText, pNounIconData, pDisplayView
   put iconName into stackLabel
   
   # Display
   display_ModuleInstance "View|Button|Svg", svgPathText, stackLabel, pDisplayView, "icon_PathText"
   put the result into svgButton
   
   if pNounIconData is an array then
      set the icon_Data of svgButton to pNounIconData
   end if
   return svgButton
end display_SvgIcon

command display_NounBrowser iconData
   if iconData is a number then
      put iconData into iconID
      put noun_FetchIconData (iconID) into iconData
   end if
   --
   put iconData ["permalink"] into nounURL
   put "https://thenounproject.com" & nounURL into nounURL
   --
   display_Browser nounURL
   return the result
end display_NounBrowser

on mDoubleUp_DisplayCollection displayView, cName
   put the collection_Data of displayView into collectionData
   put the cName_Array of displayView into cNameArray
   --
   put cNameArray [cName]["itemNum"] into itemNum
   put collectionData [itemNum] into collectionArray
   put collectionArray ["slug"] into collectionSlug
   --
   display_NounCollection collectionSlug, collectionArray
end mDoubleUp_DisplayCollection

on mDoubleUp_NounCollections displayView, iconName
   if the optionKey is "Down" then breakpoint
   --
   put the collections_Data of displayView into collectionsData
   put collectionsData ["icons"] into collectionIconsData
   put the icon_NameData of displayView into iconNameData
   --
   put iconNameData [iconName]["data"] into iconData
   put iconNameData [iconName]["id"] into iconID
   --
   display_NounIcon iconID
   put the result into displayView
   set the icon_Data of displayView to iconData
   --
   -- display_Data iconData, iconName, "Noun Icon Data"
   return displayView
end mDoubleUp_NounCollections


--> Display
-
command display_NounTagIcons tagName, pPublicDomian, pMaxPageNum
   put noun_FetchTaggedIconData (tagName, pPublicDomian, pMaxPageNum) into indexedIconData
   --   
   display_IndexedIconData indexedIconData, tagName, "Tagged Noun Icons", "Noun | Collection", "mDoubleUp_NounCollections"
   put the result into displayView
   --
   return displayView
end display_NounTagIcons

command display_IndexedIconData indexedIconData, pTitle, pLabel, pMenuBit, pDoubleUp
   put noun_ConstructIconNameData (indexedIconData) into iconNameData
   put keys (iconNameData) into iconNames
   sort iconNames
   --
   display_Data iconNames, pTitle, pLabel
   put the result into displayView
   display_SetInteractions displayView, pMenuBit, pDoubleUp
   --
   set the indexed_IconData of displayView to indexedIconData
   set the icon_NameData of displayView to iconNameData
   --
   return displayView
end display_IndexedIconData


--> Display | Noun
-
command display_NounCollection collectionSlug
   put noun_FetchCollectionData (collectionSlug) into collectionsData
   if collectionsData is empty then
      -- breakpoint
      return empty
   end if
   --
   put collectionsData ["icons"] into indexedIconData
   put collectionsData ["collection"] into collectionArray
   put collectionsData ["total"] into totalIcons
   --
   put collectionArray ["id"] into collectionID
   put collectionArray ["name"] into collectionName
   put collectionArray ["slug"] into collectionSlug
   --
   display_IndexedIconData indexedIconData, collectionName, "Noun Collection", "Noun | Collection", "mDoubleUp_NounCollections"
   put the result into displayView
   --
   set the collections_Data of displayView to collectionsData
   set the total_Icons of displayView to totalIcons
   set the page_Num of displayView to 1
   --
   return displayView
end display_NounCollection

command display_NounCollections
   if the optionKey is "Down" then breakpoint
   --
   put noun_FetchCollectionsData() into collectionData
   repeat with itemNum = 1 to item 2 of the extents of collectionData
      put collectionData [itemNum]["name"] into cName
      put itemNum into cNameArray [cName]["itemNum"]
   end repeat
   --
   put the keys of cNameArray into cNames
   sort cNames
   --
   display_Data cNames, "Noun Collections", "The Noun Project"
   put the result into displayView
   display_SetInteractions displayView, "Noun | Collection", "mDoubleUp_DisplayCollection"
   --
   set the collection_Data of displayView to collectionData
   set the cName_Array of displayView to cNameArray
   --
   return displayView
end display_NounCollections

command display_NounSvgXml svgXML, pNounIconData, pStackStyle, pLocOrRect
   put the tempName & ".svg" into svgFile
   put svgXML into url ("file:" & svgFile)
   --
   display_SVG svgFile, "Noun SVG Icon", pStackStyle, pLocOrRect
   put the result into svgView
   set the icon_Data of svgView to iconData
   --
   set the menu_Title of svgView to "Global | Noun | Icon | Svg | Menu"
   put "" into someIndex
   display_ObjectTools svgView, someIndex, iconName, "Noun Icon Tools", "Noun | Icon | Svg", ""
   return svgView
end display_NounSvgXml


--> Private
-
private command _DisplayIconimage iconData, iconName, pDisplayView, pStackStyle
   -- put iconData ["preview_url"] into previewUrl
   put iconData ["thumbnail_url"] into thumbnailURL
   put url thumbnailURL into someImage
   --
   -- display_Image someImage, iconName, empty, pStackStyle
   display_ModuleInstance "View|Image", someImage, iconName, pDisplayView, "displayed_Array", pStackStyle   
   put the result into imageView
   
   # Set menus and store icondat
   set the icon_Data of imageView to iconData
   display_SetMenu imageView, "Noun | Icon"
   --
   return imageView
end _DisplayIconimage

private command _DisplaySvgIcon iconID, iconURL, iconName, iconData, pSvgButton
   -- display_NounSvgXml svgXML, iconData, pStackStyle, pLocOrRect
   put url iconURL into svgXML
   --
   put noun_FetchIconPath (iconID) into svgPathText
   if exists (pSvgButton) then
      put pSvgButton into svgButton
   else
      display_SvgIcon iconName, svgPathText, iconData
      put the result into svgButton
   end if
   --
   set the icon_Data of svgButton to iconData
   return svgButton
end _DisplaySvgIcon
