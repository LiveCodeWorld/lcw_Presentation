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
function noun_ConstructedSig restURL, consumerKey, timeStamp, authNonce
   put noun_GetApiSecret() into consumerSecret
   put oAuth_ConstructSignature ("GET", restURL, consumerKey, consumerSecret, "", timeStamp, authNonce) into constructedSig
   return constructedSig
end noun_ConstructedSig


--> Noun | Auth
-
function noun_ApiUsage
   put "https://api.thenounproject.com/oauth/usage" into restURL
   --
   put noun_FetchData (restURL) into resultArray
   put resultArray ["icon"] into iconData
   return iconData
   
end noun_ApiUsage

function noun_FetchIconData iconID
   put "https://api.thenounproject.com/icon/" & iconID into restURL
   -- put "?include_png_1200=1" after restURL
   --
   put noun_FetchData (restURL) into resultArray
   put resultArray ["icon"] into iconData
   return iconData
end noun_FetchIconData

function noun_FetchData restURL
   put noun_ConstructURL (restURL) into restURL
   put url restURL into someJSON
   put json_ToArray (someJSON) into resultArray
   return resultArray
end noun_FetchData

function noun_ConstructURL restURL, pTimeStamp, pAuthNonce
   put noun_GetConsumerKey() into consumerKey
   put noun_GetApiSecret() into consumerSecret
   --
   put oAuth_ConstructRequestArray ("GET", restURL, consumerKey, consumerSecret, "", pTimeStamp, pAuthNonce) into requestArray
   --
   put requestArray ["oauth_timestamp"] into timeStamp
   put requestArray ["oauth_nonce"] into authNonce
   put noun_ConstructedSig (restURL, consumerKey, timeStamp, authNonce) into constructedSig
   --
   put oAuth_ConstructRequestURL (restURL, requestArray, constructedSig) into requestURL
   return requestURL
end noun_ConstructURL


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

function noun_FetchCollectionsDataPage pageNum
   constant restEndPoint = "https://api.thenounproject.com/collections"
   
   put restEndPoint & "?limit=50&page=" & pageNum into restURL
   put noun_FetchData (restURL) into resultArray
   put resultArray ["Collections"] into collectionArray
   return collectionArray
end noun_FetchCollectionsDataPage

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


--> Deps
-
function test_NounRestURL restURL
   -- https://api.thenounproject.com/icon/1?oauth_consumer_key=00d313ddb35c4ba580f08959ddb7c146&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1627168116&oauth_nonce=D9SxqmfDq6l&oauth_version=1.0&oauth_signature=JM43dUM8O44VLQwu36GSar8v6O4%3D
   set the itemdelimiter to "?"
   put item 1 of restURL into restEndPoint
   put item 2 to -1 of restURL into requestArray
   --
   split requestArray using "&" and "="
   -- display_Array requestArray, "Url Params"
   --
   oauth_DeconstructRequestArray requestArray, timeStamp, authNonce, consumerKey, authVersion, callbackURL, signatureMethod
   put noun_ConstructedSig (restEndPoint, consumerKey, timeStamp, authNonce) into constructedSig
   put noun_ConstructURL (restEndPoint, timeStamp, authNonce) into constructedURL
   
   put urlEncode (constructedSig) = requestArray ["oauth_signature"] into sigSame
   put constructedURL = restURL into urlSame
   -- put "urlSame:" && urlSame &CR& "sigSame:" && sigSame & CR & restURL & CR & constructedURL
   return urlSame AND sigSame
end test_NounRestURL

-- on test_NounUrl
put "https://api.thenounproject.com/icon/1" into restEndPoint
put noun_ConstructURL (restEndPoint) into restURL
--
display_NounUrl restURL
end test_NounUrl

-- on test_StoredNounUrl
put pageArray_FetchItem ("test.livecode.world", "noun-project-test", "959e0d1a8f786b97") into someURL
replace CR with empty in someURL
--
display_NounUrl someURL
end test_StoredNounUrl

-- on test_NounSig
--
/*
GET /icon/1?oauth_consumer_key=00d313ddb35c4ba580f08959ddb7c146&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1627156821&oauth_nonce=fIxFnd5ZChz&oauth_version=1.0&oauth_signature=zq9R30DgmgFysMHgKgPefSNijAg%3D HTTP/1.1
*/
put pageArray_FetchItem ("test.livecode.world", "noun-project-test", "f07dc0eebd267186") into requestArray
replace CR with empty in requestArray

replace quote with empty in requestArray
delete word 1 of requestArray
replace space with empty in requestArray
split requestArray using comma and "="
oauth_DeconstructRequestArray requestArray, timeStamp, authNonce, consumerKey, authVersion, callbackURL, signatureMethod
put requestArray ["oauth_signature"] into oauthSignature
--
put "https://api.thenounproject.com/icon/1" into restEndPoint
--
put noun_GetConsumerKey() into consumerKey
put noun_ConstructedSig (restEndPoint, consumerKey, timeStamp, authNonce) into constructedSig

put noun_ConstructURL (restEndPoint, timeStamp, authNonce) into restURL
put url restURL into resultJSON
--
get oAuth_PercentEncode (constructedSig)
put (oauthSignature = it) & CR & it & CR & oauthSignature & CR&CR & restURL & CR&CR & resultJSON
end test_NounSig

-- command test_Noun
local pTimeStamp, pAuthNonce
-- put "https://api.thenounproject.com/oauth/usage" into restEndPoint
put "https://api.thenounproject.com/icon/1" into restEndPoint
--
put noun_GetConsumerKey() into consumerKey
put noun_GetApiSecret() into consumerSecret
--
put oAuth_ConstructRequestHeader ("GET", restEndPoint, consumerKey, consumerSecret) into extraHeaders

-- set the httpheaders to extraHeaders
jsonrpc_SetHeaders extraHeaders
put url restEndPoint into someJson
--
put extraHeaders & CR&CR & someJson
-- display_JSON someJson
end test_Noun

