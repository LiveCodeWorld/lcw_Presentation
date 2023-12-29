script "Global | Noun | Icon | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Noun | Icon | Menu
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
   -- put display_MenuTarget (tObject) into dView
   put the display_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

function pageArray_ConstructIcon imageURL, iconData, iWidth, iHeight, pPageDescription, pSize
   -- put iconData ["Term"] into iconTerm
   if pSize is empty then
      if iWidth < 400 then
         put "thumbnail" into pSize
      else
         put "wide" into pSize
      end if
   end if
   put noun_ConstructIconName (iconData) into pageTitle
   put "https://thenounproject.com" & iconData ["permalink"] into iSource
   put iconData ["attribution"] into imageCaption
   --
   put pageArray_ConstructImage (imageURL, pageTitle, pPageDescription, imageCaption, iSource, iWidth, iHeight, pSize) into pageArray
   return pageArray
end pageArray_ConstructIcon

command _FetchMediaIconFile iconData, @someImage, @downloadFile, @imageURL, @photoPath
   put iconData ["icon_url"] into iconURL
   put iconData ["preview_url"] into previewURL
   --
   switch
      case previewURL is not empty
         put previewURL into imageURL
         break
      case iconURL is not empty
         put iconURL into imageURL
         break
   end switch
   -- 
   put url imageURL into someImage
   put md5_Hash (someImage) into imageHash
   put wiki_PhotoAssetPath (imageHash, imageURL) into photoPath
   put _DownloadFile (imageURL, exportFolder, imageHash) into downloadFile
   --
   put _ShortFile (imageHash, imageURL) into shortFile
   put "http://media.localhost:3000/assets/plugins/image/" & shortFile into imageURL
   
   return downloadFolder
end _FetchMediaIconFile

function wiki_PhotoAssetPath imageHash, imageURL
   put _ShortFile (imageHash, imageURL) into shortFile
   return "/assets/plugins/image/" & shortFile
end wiki_PhotoAssetPath

private function _DownloadFile downloadURL, exportFolder, imageHash
   put wiki_MediaAssetFolder() into exportFolder
   text_AddTrailing exportFolder, slash
   put _ShortFile (imageHash, downloadURL) into shortFile
   put exportFolder & shortFile into downloadFile
   return downloadFile
end _DownloadFile

private function _ShortFile imageHash, imageURL
   set the itemdelimiter to "."
   put item -1 of imageURL into fileExt
   put imageHash & "." & fileExt into shortFile
   return shortFile
end _ShortFile


--> Global | Noun | Icon | Menu
-
on menu_ExportNounIcon imageView
   -- "size": "wide"
   -- "size": "thumbnail"
   
   put the formattedwidth of imageView into iWidth
   put the formattedheight of imageView into iHeight
   put the icon_Data of imageView into iconData
   
   _FetchMediaIconFile iconData, someImage, downloadFile, imageURL, photoPath
   --
   if there is not a file downloadFile then
      put someImage into url ("binfile:/" & downloadFile)
   end if
   --
   put empty into pageDescription
   put pageArray_ConstructIcon (photoPath, iconData, iWidth, iHeight, pageDescription) into pageArray
   -- put pageArray_ConstructImage (imageURL, iconName, iconTerm, linkURL, imageCaption) into pageArray
   --
   put wiki_Browser() into browserVIew
   set the ghost_PageArray of browserVIew to pageArray
   -- set the page_Array of browserVIew to pageArray
   
   if the shiftKey is "Down" then
      finder_Reveal downloadFile
   end if
   return downloadFile
end menu_ExportNounIcon

private function _AskDownloadFile downloadURL, exportFolder, imageHash
   put _DownloadFile (downloadURL, exportFolder, imageHash) into downloadFile
   --
   if there is a file downloadFile then
      ask file "Select a different filename..." with exportFolder as sheet
      put it into downloadFile
      if there is a file downloadFile then
         lcw_AnswerWarning "File already exists!"
      end if
   end if
   --
   return downloadFile
end _AskDownloadFile

private on _
end _

on menu_Behavior imageView
   put the behavior of imageView into bObject
   edit the script of bObject
end menu_Behavior

on menu_ModuleTools imageView
   put the view_Name of imageView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Image
   return "Global | Image | Menu"
end submenu_Image

on submenu_Dev
   return menu_DevTitle ("Global | Noun | Icon | Menu")
end submenu_Dev

