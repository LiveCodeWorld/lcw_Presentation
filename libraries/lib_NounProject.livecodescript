script "lib_NounProject"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_NounProject
type: library
version: 0.1

/*
require "oauth"

consumer = OAuth::Consumer.new("your-api-key", "your-api-secret")
access_token = OAuth::AccessToken.new consumer
endpoint = "http://api.thenounproject.com/icon/1"

response = access_token.get(endpoint)
puts response.body
*/


--> Working on
-
function noun_FetchIconPath iconID
   put noun_FetchIconSvg (iconID) into svgXML
   if svgXML is empty then
      return empty
   else
      put svg_GetPathText (svgXML) into svgPathText
      return svgPathText
   end if
end noun_FetchIconPath

function noun_FetchIconSvg iconID
   put noun_FetchIconData (iconID) into iconData
   put iconData ["icon_url"] into iconURL
   if iconURL is empty then return empty
   --
   put url iconURL into svgXML
   return svgXML
end noun_FetchIconSvg

function noun_FetchCollectionsDataPage pageNum
   --v1 only
   put "https://api.thenounproject.com/collections" into restEndPoint
   --
   put restEndPoint & "?limit=50&page=" & pageNum into restURL
   --
   put noun_FetchData (restURL) into resultArray
   put resultArray ["Collections"] into collectionArray
   return collectionArray
end noun_FetchCollectionsDataPage

function test_Noun sQuery, pIsPublic
   put noun_FindIcon (sQuery, pIsPublic) into iconData
   put iconData ["icons"] into iconArray
   return iconData ["total"]
end test_Noun


--> Non | Rest
-
function noun_FetchData restURL
   put _AddUrlParams (restURL) into restURL
   put jsonrpc_GetArray (restURL) into resultArray
   return resultArray
end noun_FetchData

function _ConstructRestUrl restBit
   constant NounRestUrl = "https://api.thenounproject.com/v2/"
   --
   put NounRestUrl & restBit into restURL
   return restURL
end _ConstructRestUrl


--> Noun | Auth
-
function noun_ApiUsage
   -- was "https://api.thenounproject.com/oauth/usage"
   put _ConstructRestUrl ("client/usage") into restURL
   --
   put noun_FetchData (restURL) into resultArray
   put resultArray ["icon"] into iconData
   return iconData
end noun_ApiUsage

function noun_FindIcon sQuery, pIsPublic
   put "icon/" into restBit
   put _ConstructRestUrl (restBit) into restURL
   --
   put "?query=" & urlencode (sQuery) after restURL
   put "&include_svg=1" after restURL
   --
   if the paramCount > 1 then
      if pIsPublic is true then
         put "&" after restURL
         put "limit_to_public_domain=1" after restURL
      else if pIsPublic is false then
         put "&" after restURL
         put "limit_to_public_domain=0" after restURL
      end if
   end if
   --
   put noun_FetchData (restURL) into iconData
   return iconData
end noun_FindIcon

function noun_DownloadIcon iconID, pHexColor, pFiletype, pSize
   if pFiletype is empty then put "svg" into pFiletype
   if pHexColor is empty then
      -- put colour_NameToRgb ("black") into sRGB
      -- put colour_RgbToHex("0,0,0") into pHexColor
      put "000000" into pHexColor
   end if
   --
   put "icon/" & iconID & "/download" into restBit
   put _ConstructRestUrl (restBit) into restURL
   put "?" after restURL
   put "color=" & pHexColor after restURL
   put "&" after restURL
   put "filetype=" & pFiletype after restURL
   --
   if the paramCount > 1 then
      if pFiletype = "png" AND pSize > 20 AND pSize < 1200 then
         --- Size of png (minimum of 20, maximum of 1200)
         put "&" after restURL
         put "size=" & pSize after restURL
      end if
   end if
   --
   put noun_FetchData (restURL) into resultArray
   put resultArray ["icon"] into iconData
   return iconData
end noun_DownloadIcon

function noun_FetchIconData iconID, pThumbnailSize
   put "icon/" & iconID into restBit
   put _ConstructRestUrl (restBit) into restURL
   --
   if the paramCount > 1 then
      put "?" after restURL
      if pThumbnailSize is among the items of "42,84,200" then
         put "thumbnail_size=" & pThumbnailSize after restURL
         put "&" after restURL
      end if
      delete char -1 of restURL
   end if
   --
   put noun_FetchData (restURL) into resultArray
   put resultArray ["icon"] into iconData
   return iconData
end noun_FetchIconData


--> Noun
-
-- function noun_FetchTaggedIconData tagName, pPublicDomian
-- https://api.thenounproject.com/icons/money?limit_to_public_domain=1

put "https://api.thenounproject.com/icons/" & tagName into restURL
if pPublicDomian is true then
   put "?limit_to_public_domain=1" after restURL
end if
put noun_FetchData (restURL) into resultArray
return resultArray
end noun_FetchTaggedIconData

function noun_FetchTaggedIconData tagName, pPublicDomian, pMaxPageNum
   local indexedIconData
   --
   if pMaxPageNum is empty then put 20 into pMaxPageNum
   repeat with pageNum = 1 to pMaxPageNum
      set the cursor to busy
      put noun_FetchTaggedIconPageData (tagName, pageNum, pPublicDomian) into indexedIconArray
      if indexedIconArray is empty then
         exit repeat
      end if
      --
      iData_AddIndexArray indexedIconData, indexedIconArray
   end repeat
   return indexedIconData
end noun_FetchTaggedIconData

function noun_FetchTaggedIconPageData tagName, pPageNum, pPublicDomian
   -- https://api.thenounproject.com/icons/money?limit_to_public_domain=1   
   put "https://api.thenounproject.com/icons/" & tagName into restEndPoint
   
   if pPageNum is empty then put 1 into pPageNum
   put restEndPoint & "?limit=50&page=" & pPageNum into restURL
   --
   if pPublicDomian is true then
      put "&limit_to_public_domain=1" after restURL
   end if
   --
   put noun_FetchData (restURL) into resultArray
   put resultArray ["icons"] into indexedIconData -- nothing else useful
   --
   return indexedIconData
end noun_FetchTaggedIconPageData

function noun_FetchCollectionsData pMaxPageNum
   local collectionData
   --
   if pMaxPageNum is empty then put 20 into pMaxPageNum
   repeat with pageNum = 1 to pMaxPageNum
      set the cursor to busy
      put noun_FetchCollectionsDataPage (pageNum) into collectionArray
      if collectionArray is empty then exit repeat
      --
      iData_AddIndexArray collectionData, collectionArray
   end repeat
   return collectionData
end noun_FetchCollectionsData

function noun_FilterIndexIconData indexedIconData
   put 1 into newItemNum
   repeat with itemNum = 1 to item 2 of the extents of indexedIconData
      put indexedIconData [itemNum] into iconData
      if iconData ["icon_Url"] is not empty then
         put iconData into svgIndexedIconData [newItemNum]
         add 1 to newItemNum
      end if
   end repeat
   return svgIndexedIconData
end noun_FilterIndexIconData

function noun_ConstructIconNameData collectionIconsData
   repeat with itemNum = 1 to item 2 of the extents of collectionIconsData
      put collectionIconsData [itemNum] into iconData
      put iconData ["id"] into iconID
      put noun_ConstructIconName (iconData) into iconName
      put iconID into iconNameData [iconName]["id"]
      put iconData into iconNameData [iconName]["data"]
   end repeat
   return iconNameData
end noun_ConstructIconNameData

function noun_ConstructIconName iconData
   put iconData ["term"] into iconTerm
   put iconData ["id"] into iconID
   --
   put text_InitialCaps (iconTerm) && iconID into iconName
   return iconName
end noun_ConstructIconName

function noun_FetchCollectionIconData collectionSlug
   put noun_FetchCollectionData (collectionSlug) into collectionArray
   put collectionArray ["icons"] into collectionIconsData -- prob same as in collectionData
   --
   return collectionIconsData
end noun_FetchCollectionIconData

function noun_FetchCollectionData collectionSlug
   put merge ("https://api.thenounproject.com/collection/[[collectionSlug]]/icons") into restURL
   put noun_FetchData (restURL) into collectionArray
   return collectionArray
end noun_FetchCollectionData


--> Noun | Project
-
function noun_GetConsumerKey
   put secret_Get ("NounProjectApiKey", "NounProjectApiKey") into consumerKey
   return consumerKey
end noun_GetConsumerKey

command noun_SetConsumerKey consumerKey
   secret_Set "NounProjectApiKey", consumerKey, "NounProjectApiKey"
end noun_SetConsumerKey

function noun_GetApiSecret
   put secret_Get ("NounProjectApiSecret", "NounProjectApiSecret") into consumerSecret
   return consumerSecret
end noun_GetApiSecret

command noun_SetApiSecret consumerSecret
   secret_Set "NounProjectApiSecret", consumerSecret, "NounProjectApiSecret"
end noun_SetApiSecret


--> Private
-
private function _AddUrlParams restURL, pTimeStamp, pAuthNonce
   put noun_GetConsumerKey() into consumerKey
   put noun_GetApiSecret() into consumerSecret
   --
   put empty into callbackURL
   put oAuth_ConstructRequestArray ("GET", restURL, consumerKey, consumerSecret, callbackURL, pTimeStamp, pAuthNonce) into requestArray
   put requestArray ["oauth_signature"] into constructedSig
   
   put requestArray ["oauth_timestamp"] into timeStamp
   put requestArray ["oauth_nonce"] into authNonce
   put _ConstructedSig (restURL, consumerKey, timeStamp, authNonce) into constructedSig
   ---
   put oAuth_ConstructRequestURL (restURL, requestArray, constructedSig) into requestURL
   --
   return requestURL
end _AddUrlParams

private function _ConstructedSig restURL, consumerKey, timeStamp, authNonce
   put noun_GetApiSecret() into consumerSecret
   put oAuth_ConstructSignature ("GET", restURL, consumerKey, consumerSecret, "", timeStamp, authNonce) into constructedSig
   return constructedSig
end _ConstructedSig
