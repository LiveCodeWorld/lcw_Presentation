script "lib_DisplayNoun"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_DisplayNoun
type: library
version: 0.1

/*Some help*/


--> Working on
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


--> Display | Events
-
on drop_NounUrl dTarget
   put the dragdata ["text"] into droppedURL
   switch
      case matchText (droppedURL, "https://thenounproject.com/term/(.+)/(.+)/", iconTerm, iconID)
         display_NounIcon iconID, "system"
         break
      case matchText (droppedURL, "https://thenounproject.com/(.+)/collection/(.+)/\?i=(.+)" , authorName, collectionSlug, iconID)
         -- https://thenounproject.com/konkapp/collection/vaccine/?i=4020707
         display_NounIcon iconID, "system"
         display_NounCollection collectionSlug
         break
      case matchText (droppedURL, "https://thenounproject.com/(.+)/collection/(.+)/" , authorName, collectionSlug)
         display_NounCollection collectionSlug
         break
      default
         put droppedURL
   end switch
end drop_NounUrl

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


--> Display | Noun
-
command display_NounCollection collectionSlug
   put noun_FetchCollectionData (collectionSlug) into collectionsData
   if collectionsData is empty then return empty
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
   display_SetInteractions displayView, "Noun | Collections", "mDoubleUp_DisplayCollection"
   --
   set the collection_Data of displayView to collectionData
   set the cName_Array of displayView to cNameArray
   --
   return displayView
end display_NounCollections

command display_NounIcon iconID, pStackStyle, pLocOrRect
   if pStackStyle is empty then put "palette" into pStackStyle
   if pLocOrRect is empty then put "mouse" into pLocOrRect
   --
   put noun_FetchIconData (iconID) into iconData
   put iconData ["Term"] into iconTerm
   put iconData ["icon_url"] into iconURL
   put noun_ConstructIconName (iconData) into iconName
   --
   if iconURL is empty then
      put iconData ["preview_url"] into previewUrl
      put url previewUrl into someImage
      --
      display_Image someImage, iconName, "Icon Image", pStackStyle, pLocOrRect
      put the result into imageView
      set the icon_Data of imageView to iconData
      --
      if the shiftKey is "down" then
         display_Data iconData, iconTerm, "Noun Icon"
         put the result into displayView
      end if
      --
      return imageView
   else
      put url iconURL into svgXML
      --
      -- display_NounSvgXml svgXML, iconData, pStackStyle, pLocOrRect
      put noun_FetchIconPath (iconID) into svgPathText
      display_SvgIcon iconName, svgPathText, iconData
      put the result into svgButton
      --
      return svgButton
   end if
end display_NounIcon

command display_SvgIcon iconName, svgPathText, pNounIconData
   display_Clone "View|Button|Svg", iconName, svgPathText, "icon_PathText", "mouse", "toplevel"
   put the result into svgButton
   if exists (svgButton) is false then
      breakpoint
      return empty
   end if
   
   set the name of svgButton to iconName
   -- display_ToolStack svgButton
   --
   if pNounIconData is an array then
      set the icon_Data of svgButton to pNounIconData
   end if
   return svgButton
end display_SvgIcon

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

function noun_FetchIconSvg iconID
   put noun_FetchIconData (iconID) into iconData
   put iconData ["Term"] into iconTerm
   put iconData ["icon_url"] into iconURL
   put noun_ConstructIconName (iconData) into iconName
   --
   put url iconURL into svgXML
   return svgXML
end noun_FetchIconSvg

function noun_FetchIconPath iconID
   put noun_FetchIconSvg (iconID) into svgXML
   put svg_GetPathText (svgXML) into svgPathText
   --
   return svgPathText
end noun_FetchIconPath
