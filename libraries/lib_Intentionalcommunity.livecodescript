script "lib_Intentionalcommunity"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_IntentionalCommunity
type: library
version: 0.1

/*
This library interfaces with the unnofical api for "https://www.ic.org/directory/"
*/


--> Working on
-
command _CreateCompanyContact
   put communityData ["contactName"] into contactName
   put word 1 to -2 of contactName into postData ["properties"]["firstname"]
   put word -1 of contactName into postData ["properties"]["lastname"]
end _CreateCompanyContact


--> Display
-
command display_IntentionalCountry someCountry, displayView
   put ic_FetchCountryData (someCountry) into icListData
   put ic_GetCommunityIndex (icListData) into communityIndex
   --
   display_Data communityIndex, "All", someCountry, displayView
   put the result into displayView
   set the ic_ListData of displayView to icListData
   put icListData ["listings"] into listingData
   put ic_ConstructNamedData (listingData) into namedData
   set the named_Data of displayView to namedData
   --
   display_SetInteractions displayView, "Intentional | Country", "mDoubleUp_DisplayCommunity"
   return displayView
end display_IntentionalCountry

command display_IntentionalCommunity icSlug, pCommunityData
   -- display_Data cArray, cName, "Intentional Community"
   if pCommunityData is not an array then
      put ic_FetchCommunityData (icSlug) into pCommunityData
   end if
   --
   put pCommunityData ["name"] into cName
   display_Data pCommunityData, cName, "Intentional Community"
   put the result into displayView
   --
   display_SetInteractions displayView, "Intentional | Community", "mDoubleUp_DisplayCommunityProp"
   --
   return displayView
end display_IntentionalCommunity

command display_IntentionalCountries
   put ic_CountryList (true) into cList
   replace comma with CR in cList
   --
   display_Data cList, "Countries", "IC"
   put the result into displayView
   --
   display_SetInteractions displayView, "Intentional | Community", "mDoubleUp_DisplayCountry"
   return displayView
end display_IntentionalCountries


--> Display | Events
-
on mDoubleUp_DisplayCommunityProp  dObject, cProp
   put cProp
end mDoubleUp_DisplayCommunityProp

on mDoubleUp_DisplayCommunity dObject, cName
   put the display_View of dObject into displayView
   put the ic_ListData of displayView into icListData
   put ic_FindCommunityArray (cName, icListData) into communityData
   put communityData ["slug"] into icSlug
   --
   if the shiftKey is "down" then
      set the cursor to watch
      display_IntentionalCommunity icSlug
   else
      display_IntentionalCommunity icSlug, communityData
   end if
   put the result into displayView
   return displayView
end mDoubleUp_DisplayCommunity

on mDoubleUp_DisplayCountry fieldObject, someCountry
   display_IntentionalCountry someCountry
end mDoubleUp_DisplayCountry


--> IC
-
function ic_FilterByCommunityType icListData, someType
   put icListData ["listings"] into listingData
   --
   put 1 into fNum
   repeat with itemNum = 1 to item 2 of the extents of listingData
      put listingData [itemNum] into itemArray
      put itemArray ["name"] into cName
      put itemArray ["communityTypes"] into typeArray
      repeat for each key typeNum in typeArray
         put typeArray [typeNum] into testType
         if testType begins with someType then
            put cName & CR after cNames
            put itemArray into filteredArray [fNum]
            add 1 to fNum
            exit repeat
         end if
      end repeat
   end repeat
   delete char -1 of cNames
   return cNames
end ic_FilterByCommunityType

function ic_ConstructNamedData listingData
   repeat with itemNum = 1 to item 2 of the extents of listingData
      put listingData [itemNum] into itemArray
      put itemArray ["name"] into someName
      put itemArray into nameData [someName]
   end repeat
   return nameData
end ic_ConstructNamedData

function ic_GetCommunityIndex icListData
   put icListData ["listings"] into listingData
   --
   repeat with itemNum = 1 to item 2 of the extents of listingData
      put listingData [itemNum]["name"] into cName
      put cName & CR after communityIndex
   end repeat
   delete char -1 of communityIndex
   sort communityIndex
   --
   return communityIndex
end ic_GetCommunityIndex

function ic_FindCommunityArray cName, icListData
   put icListData ["listings"] into listingData
   --
   repeat with itemNum = 1 to item 2 of the extents of listingData
      put listingData [itemNum] into cArray
      if cArray ["name"] = cName then
         return cArray
      end if
   end repeat
   return empty
end ic_FindCommunityArray

function ic_FilterCommunityArray icListData, someKey, someValue
   put icListData ["listings"] into listingData
   --
   put 1 into fNum
   repeat with itemNum = 1 to item 2 of the extents of listingData
      put listingData [itemNum] into cArray
      if cArray [someKey] = someValue then
         put cArray into filteredArray [fNum]
         add 1 to fNum
      end if
   end repeat
   return filteredArray
end ic_FilterCommunityArray


--> IC | Create
-
command ic_CreateCompanyAndContact icSlug
   put ic_FetchCommunityData (icSlug) into communityData
   --
   put communityData ["name"] into cName
   if hubspot_MatchCompany (cName) is true then
      put merge ("error, company name '[[cName]]' already exists") into errorArray ["error"]
      return errorArray
   end if
   
   put ic_ConstructCompanyPostData (communityData) into postData
   --
   hubspot_CreateCompany postData
   put the result into createdCompanyArray
   put createdCompanyArray ["id"] into companyID
   --
   ic_AddAndAssociateContactToCompany communityData, companyID
   put the result into createdContactArray
   --
   put createdCompanyArray into resultArray ["company"]
   put createdContactArray into resultArray ["contact"]
   return resultArray
end ic_CreateCompanyAndContact

command ic_AddAndAssociateContactToCompany communityData, pHubspotCompanyID
   -- not ic id
   put communityData ["contactName"] into contactName
   if text_IsEmpty (contactName) then return "error, contactName is empty"
   --
   put word -1 of contactName into lastName
   put word 1 to -2 of contactName into firstName
   if hubspot_MatchContact (firstName, lastName) is true then
      -- should re-link it
      return "error, contact [[contactName]] already exists"
   end if
   --
   put ic_ConstructContactPostData (communityData, pHubspotCompanyID) into postData
   --
   hubspot_CreateContact postData
   put the result into resultArray
   --
   return resultArray
end ic_AddAndAssociateContactToCompany


--> IC | Construct
-
function ic_ConstructContactPostData communityData, pCompanyID
   put communityData ["contactName"] into contactName
   if text_IsNotEmpty (missionStatement) then
      put word -1 of contactName into postData ["properties"]["lastname"]
      put word 1 to -2 of contactName into postData ["properties"]["firstname"]
   end if
   
   _AddContactAddressPostData postData, communityData
   _AddPostData postData, "contactPhone", communityData, "phone"
   
   if pCompanyID is not empty then
      put pCompanyID into postData ["properties"]["associatedcompanyid"]
   end if
   /*
   _AddPostData postData, "socialUrl", communityData, "domain"
   _AddPostData postData, "websiteUrl", communityData, "website"
   _AddPostData postData, "facebookUrl", communityData, "facebook_company_page"
   _AddTwitterPostData postData, communityData
   */
   --
   return postData
end ic_ConstructContactPostData

function ic_ConstructCompanyPostData communityData
   put communityData ["id"] into cID
   put communityData ["slug"] into cSlug
   --
   put communityData ["communityStatus"] into communityStatus
   put communityData ["missionStatement"] into missionStatement
   put communityData ["keywords"] into keyWordList
   --
   put communityData ["mapCoordinates"]["latitude"] into mapLat
   put communityData ["mapCoordinates"]["longitude"] into mapLong
   
   /*
   put ",linkedin_company_page,linkedinbio" after it
   put "owneremail,ownername" after it
   */
   
   -- put ",notes_last_contacted,notes_last_updated,notes_next_activity_date" after it
   put "RENEWABLES_ENVIRONMENT" into postData ["properties"]["industry"]
   put communityData ["description"] into someDescription
   -- should use Hubspot engagements api - https://legacydocs.hubspot.com/docs/methods/engagements/get_engagement
   -- _AddPostData postData, "description", communityData, "domain"
   
   -- get "about_us,createdate,description,is_public,name,phone,type"
   put communityData ["name"] into postData ["properties"]["name"]
   _AddPostData postData, "contactPhone", communityData, "phone"
   
   -- put ",domain,website,facebook_company_page,facebookfans" after it
   -- put communityData ["businessUrl"] into postData ["properties"]["website"]
   --
   _AddPostData postData, "socialUrl", communityData, "domain"
   _AddPostData postData, "websiteUrl", communityData, "website"
   _AddPostData postData, "facebookUrl", communityData, "facebook_company_page"
   --
   _AddTwitterPostData postData, communityData
   _AddAddressPostData postData, communityData
   
   _AddPostData postData, "currentResidencies", communityData, "numberofemployees"
   _AddPostData postData, "startedPlanning", communityData, "founded_year"
   --
   return postData
end ic_ConstructCompanyPostData

private command _AddAboutPostData @postData, communityData
   put communityData ["missionStatement"] into missionStatement
   if text_IsNotEmpty (missionStatement) then
      put missionStatement into aboutUs
   end if
   
   put communityData ["keywords"] into keyWordList
   if text_IsNotEmpty (keyWordList) then
      if aboutUs is empty then
         put keyWordList into aboutUs
      else
         put CR&CR & keyWordList after aboutUs
      end if
   end if
   --
   if text_IsNotEmpty (aboutUs) then
      put aboutUs into postData ["properties"]["about_us"]
   end if
end _AddAboutPostData

private command _AddAddressPostData @postData, communityData
   -- put ",address,address2,city,state,country,zip,timezone" after it
   put communityData ["contactAddress"] into addressArray
   --
   get addressArray ["lineOne"]
   if text_IsNotEmpty (it) then
      put it into postData ["properties"]["address"]
   end if
   --
   get addressArray ["lineTwo"]
   if text_IsNotEmpty (it) then
      put it into postData ["properties"]["address2"]
   end if
   --
   _AddPostData postData, "city", communityData, "city"
   _AddPostData postData, "state", communityData, "state"
   _AddPostData postData, "country", communityData, "country"
   --
   get addressArray ["zipCode"]
   if text_IsNotEmpty (it) then
      put it into postData ["properties"]["zip"]
   end if
end _AddAddressPostData

private command _AddContactAddressPostData @postData, communityData
   -- put ",address,address2,city,state,country,zip,timezone" after it
   put communityData ["contactAddress"] into addressArray
   --
   put addressArray ["lineOne"] into lineOne
   if text_IsNotEmpty (lineOne) then put lineOne into someAddress
   put addressArray ["lineTwo"] into lineTwo
   if text_IsNotEmpty (lineTwo) then
      if someAddress is empty then
         put lineTwo into someAddress
      else
         put comma && lineTwo after someAddress
      end if
   end if
   if someAddress is not empty then
      put someAddress into postData ["properties"]["address"]
   end if
   --
   _AddPostData postData, "city", communityData, "city"
   _AddPostData postData, "state", communityData, "state"
   _AddPostData postData, "country", communityData, "country"
   --
   get addressArray ["zipCode"]
   if text_IsNotEmpty (it) then
      put it into postData ["properties"]["zip"]
   end if
end _AddContactAddressPostData

private command _AddTwitterPostData @postData, communityData
   -- put ",twitterbio,twitterfollowers,twitterhandle" after it
   -- https://twitter.com/BenMoOreLess
   
   get communityData ["twitterUrl"]
   set the itemdelimiter to slash
   put item -1 of it into twitterhandle
   set the itemdelimiter to comma
   --
   if text_IsNotEmpty (twitterhandle) then
      put twitterhandle into postData ["properties"]["twitterhandle"]
   end if
end _AddTwitterPostData

private command _AddPostData @postData, icKey, communityData, hsPropKey
   put communityData [icKey] into someValue
   if text_IsNotEmpty (someValue) then
      put someValue into postData ["properties"][hsPropKey]
   end if
end _AddPostData

private command _AddMetadata @pageArray, cName, communityData
   pageArray_AddMarkdown pageArray, "# Metadata"
   put cName && "json" into metaDataTitle
   pageArray_AddJsonArray pageArray, communityData, metaDataTitle
end _AddMetadata

function ic_CountryList pSort
   get "United States,Amazonas,Argentina,Australia,Austria,Belgium,Belize,Bolivia,Brazil,Bulgaria,Cambodia,Canada,Chile,China,Colombia,Costa Rica,Czech Republic,Denmark,Ecuador,France,Germany,Greece,Guatemala,Hungary,Iceland,India,Indonesia,Bali,Ireland,Israel,Italy,Jamaica,Japan,Mexico,World-wide,Moldova,Netherlands,New Zealand,Norway,Panama,Paraguay,Peru,Philippines,Poland,Portugal,Romania,Slovenia,Spain,Sweden,Switzerland,Taiwan,Tanzania,Thailand,Ukraine,United Kingdom,Uruguay,Venezuela"
   if pSort is true then sort items of it
   return it
end ic_CountryList


--> IC | Country
-
function ic_PageFromCountry someCountry
   put ic_FetchCountryData (someCountry) into icListData
   --
   put ic_ConstructCountryUrl (someCountry) into icCountryUrl
   put ic_PageFromListData (icListData, someCountry, icCountryUrl) into pageArray
   return pageArray
end ic_PageFromCountry


--> IC | URLs
-
function ic_ConstructCountryUrl someCountry
   put urlEncode (someCountry) into someCountry
   put merge ("https://www.ic.org/directory/listings/?country=[[someCountry]]") into icCountryURL
   return icCountryURL
end ic_ConstructCountryUrl

function ic_ConstructFicUrl cSlug
   put merge ("https://www.ic.org/directory/[[cSlug]]/") into ficURL
   return ficURL
end ic_ConstructFicUrl


--> IC
-
function ic_PageFromCommunityData communityData
   -- put utf8_Decode ("❅ Golden Rule ✯ Rainbow - Community & Demo - Farm ❅")
   put communityData ["id"] into cID
   put communityData ["name"] into cName
   put communityData ["slug"] into cSlug
   --
   put communityData ["createdAt"] into createdAt
   put communityData ["updatedAt"] into updatedAt
   --
   put communityData ["websiteUrl"] into websiteUrl
   put communityData ["socialUrl"] into socialUrl
   put communityData ["facebookUrl"] into facebookUrl
   put communityData ["businessUrl"] into businessUrl
   --
   put communityData ["contactName"] into contactName
   put communityData ["contactPhone"] into contactPhone
   --
   put communityData ["description"] into someDescription
   put communityData ["communityStatus"] into communityStatus
   put communityData ["missionStatement"] into missionStatement
   put communityData ["keywords"] into keyWordList
   put communityData ["isFicMember"] into isFicMember
   --
   put communityData ["communityTypes"] into cTypeIndexedArray
   put communityData ["facilities"] into facilityIndexArray
   --
   put communityData ["mapCoordinates"]["latitude"] into mapLat
   put communityData ["mapCoordinates"]["longitude"] into mapLong
   put communityData ["location"]["longitude"] into locationType -- eg "rural"
   --
   put communityData ["contactAddress"] into addressArray
   put communityData ["city"] into someCity
   put communityData ["state"] into someState
   put communityData ["country"] into someCountry
   --
   put communityData ["image"]["imageUrl"] into imageUrl
   put communityData ["image"]["thumbnailUrl"] into thumbnailUrl
   put communityData ["galleryImages"] into galleryImageArray
   --
   put ic_ConstructFicUrl (cSlug) into ficURL
   put "[[" & cName & "]]" into imageCaption
   --
   -- html_Strip someDescription
   put word 1 to -1 of replacetext (someDescription, "(<(.|\n)+?>)", empty) into someDescription
   --
   put pageArray_Construct (cName, someDescription) into pageArray
   _AddImage pageArray, imageURL, imageCaption, ficURL
   --
   _AddContactButton pageArray, communityData
   --
   _AddKeywords pageArray, keyWordList
   _AddMission pageArray, missionStatement, thumbnailURL, imageCaption, ficURL
   --
   _AddWebLinks pageArray, websiteUrl, socialUrl, facebookUrl, businessUrl, ficURL
   _AddAddress pageArray, someCity, someState, someCountry, addressArray
   _AddMap pageArray, mapLat, mapLong, locationType, cName
   --
   _AddVideos pageArray, communityData
   --
   _AddMetadata pageArray, cName, communityData
   --
   pageArray_StripJournal pageArray
   return pageArray
end ic_PageFromCommunityData

private command _AddContactButton @pageArray, communityData
   put communityData ["contactName"] into contactName
   put communityData ["contactPhone"] into contactPhone
   --
   if text_IsNotEmpty (contactName) then
      put contactName into hiddenKeyValueArray ["contactName"]
      put contactPhone into hiddenKeyValueArray ["contactPhone"]
      --
      put platform_RestUrl ("intentional/createContact") into restURL
      --
      pageArray_AddButton pageArray, "Create Contact", restURL, hiddenKeyValueArray
   end if
end _AddContactButton

private command _AddVideos @pageArray, communityData
   put communityData ["youtubeids"] into tubeIndexedArray
   put item 2 of the extents of tubeIndexedArray into maxItemNum
   if maxItemNum < 1 then return false
   --
   put communityData ["name"] into cName
   put communityData ["slug"] into cSlug
   --
   put ic_ConstructFicUrl (cSlug) into ficURL
   put "[[" & cName & "]]" into imageCaption
   put fedwiki_ConstructImageCaption (imageCaption, ficURL) into videoDescription
   --
   pageArray_AddMarkdown pageArray, "# Videos"
   --
   repeat with itemNum = 1 to maxItemNum
      put tubeIndexedArray [itemNum] into youtubeID
      --
      pageArray_AddVideo pageArray, youtubeID, "YOUTUBE", videoDescription
   end repeat
   return true
end _AddVideos

private command _AddThumbnail @pageArray, thumbnailURL, imageCaption, ficURL
   if text_IsNotEmpty (imageURL) then
      pageArray_AddThumbnail pageArray, thumbnailURL, imageCaption, ficURL
   end if
end _AddThumbnail

private command _AddMission @pageArray, missionStatement, thumbnailURL, imageCaption, ficURL
   pageArray_AddMarkdown pageArray, "# Mission"
   _AddThumbnail pageArray, thumbnailURL, imageCaption, ficURL
   pageArray_AddMarkdown pageArray, missionStatement
end _AddMission

private command _AddKeywords @pageArray, keyWordList
   text_ClearNull keyWordList
   put md_ConstructKeyWordLinkSection (keyWordList) into linkedKeyWords
   put "__Keywords:__" && linkedKeyWords into mdKeySection
   --
   pageArray_AddMarkdown pageArray, mdKeySection
end _AddKeywords

private command _AddImage @pageArray, imageURL, imageCaption, ficURL
   if text_IsNotEmpty (imageURL) then
      pageArray_AddImage pageArray, imageURL, imageCaption, ficURL
   end if
end _AddImage

private command _AddMap @pageArray, mapLat, mapLong, locationType, cName
   if mapLat is not empty then
      put "[[" & cName & "]]" into pinText
      put pinText into mapText
      if text_IsNotEmpty (locationType) then
         put space & "(" & locationType & ")" after mapText
      end if
      --
      pageArray_AddMap pageArray, mapLat, mapLong, mapText, 12, pinText
   end if
end _AddMap

private command _AddWebLinks @pageArray, websiteUrl, socialUrl, facebookUrl, businessUrl, ficURL
   put ic_ConstructWebLinkMarkdown (websiteUrl, socialUrl, facebookUrl, businessUrl, ficURL) into mdLinkSection
   pageArray_AddMarkdown pageArray, mdLinkSection
end _AddWebLinks

private command _AddAddress @pageArray, someCity, someState, someCountry, addressArray
   put ic_ConstructAddressMarkdown (someCity, someState, someCountry, addressArray) into contactAddress
   pageArray_AddMarkdown pageArray, "# Community Address"
   pageArray_AddMarkdown pageArray, contactAddress
end _AddAddress


--> IC | PageArray
-
function ic_PageFromCommunityTypeData communityTypeData, pPageTitle
   -- display_Data communityTypeData
   put ic_PageFromListData (communityTypeData, pPageTitle) into pageArray
   return pageArray
end ic_PageFromCommunityTypeData

function ic_PageFromListData icListData, pPageTitle, linkURL
   if pPageTitle is emmpty then put "IC Listing" into pPageTitle
   put icListData ["listings"] into listData
   put item 2 of the extents of listData into maxItemNum
   --
   put merge ("Here is a listing of [[maxItemNum]] intentional communities.") into someMarkdown
   put space & "You can view the lisiting on the Foundation for Intentional Community ([[FIC]]) site here" after someMarkdown
   put space & markdown_ExternalLinkLine (linkURL) after someMarkdown
   --
   put pageArray_Construct (pPageTitle, someMarkdown) into pageArray
   pageArray_AddMarkdown pageArray, "---"
   --
   repeat with itemNum = 1 to maxItemNum
      --
      put listData [itemNum] into listArray
      put ic_ConstructListElementHtml (listArray) into someHtml
      --
      pageArray_AddHtml pageArray, someHtml
   end repeat
   --
   pageArray_StripJournal pageArray
   return pageArray
end ic_PageFromListData

function ic_ConstructWebLinkMarkdown websiteUrl, socialUrl, facebookUrl, businessUrl, icURL
   put "# Links" & CR&CR into someMarkdown
   --
   markdown_AddLinkLine someMarkdown, icURL, "FIC:"
   markdown_AddLinkLine someMarkdown, websiteUrl, "Website:"
   markdown_AddLinkLine someMarkdown, socialUrl, "Social:"
   markdown_AddLinkLine someMarkdown, facebookUrl, "FaceBook"
   markdown_AddLinkLine someMarkdown, businessUrl, "Business:"
   --
   return someMarkdown
end ic_ConstructWebLinkMarkdown

function ic_ConstructAddressMarkdown someCity, someState, someCountry, addressArray
   get addressArray ["lineOne"]
   if text_IsNotEmpty (it) then put it & CR after contactAddress
   --
   get addressArray ["lineTwo"]
   if text_IsNotEmpty (it) then put it & CR after contactAddress
   -- put addressArray ["type"] into line 3 of contactAddress
   --
   put addressArray ["zipCode"] into someZip
   --
   if text_IsNotEmpty (someCity) then
      put markdown_Link(someCity) & ", " after contactAddress
   end if
   if text_IsNotEmpty (someState) then
      put markdown_Link(someState) & ", " after contactAddress
   end if
   if text_IsNotEmpty (someCountry) then
      put markdown_Link(someCountry) & ", " after contactAddress
   end if
   --
   delete char -2 to -1 of contactAddress
   --
   if text_IsNotEmpty (someZip) then
      put space & someZip after contactAddress
   end if
   --
   return contactAddress
end ic_ConstructAddressMarkdown

function ic_ConstructListElementHtml listArray
   local someHTML
   put CR into someDelim
   --
   put listArray ["id"] into icID
   put listArray ["name"] into icName
   put listArray ["slug"] into icSlug
   put listArray ["thumbnailURL"] into thumbnailURL
   --
   put listArray ["city"] into icCity
   put listArray ["state"] into icState
   put listArray ["country"] into icCountry
   --
   put listArray ["openToMembership"] into openToMembership
   put listArray ["openToVisitors"] into openToVisitors
   --
   put listArray ["createdAt"] into rfc8601Date
   put date_8601ToInternet (rfc8601Date) into createdAt
   put listArray ["updatedAt"] into rfc8601Date
   put date_8601ToInternet (rfc8601Date) into updatedAt
   --
   put listArray ["communityStatus"] into communityStatus
   if communityStatus contains "(" AND ")" is not in communityStatus then
      -- hack to fix strange data bug
      put ")" after communityStatus
   end if
   put listArray ["communityTypes"] into communityTypeArray
   put listArray ["spiritual"] into spiritualArray
   
   --
   -- put "<a href='[[panelLink]]'>" & someDelim after htmlTemplate
   --
   put "<h2>[[icName]]</h2>" & someDelim after htmlTemplate
   --
   switch thumbnailURL
      case empty
      case "null"
         break
      default
         put icName into imageAlt
         put "<div class='item image ui-sortable-handle'>" & someDelim after htmlTemplate
         put "<img class='thumbnail' src='[[thumbnailURL]]' alt='[[imageAlt]]' >" & someDelim after htmlTemplate
         put "</div>" & someDelim after htmlTemplate
   end switch
   --
   put "<h3><small>[[icCity]], [[icState]], [[icCountry]] - <em>[[communityStatus]]</em></small></h3>" & someDelim after htmlTemplate
   --
   put "<b>Visitors Accepted: </b>[[openToVisitors]]" & someDelim after htmlTemplate
   put "<br>" & someDelim after htmlTemplate
   put "<b>Open to New Members: </b>[[openToMembership]]" & someDelim after htmlTemplate
   put "<br>" & someDelim after htmlTemplate
   --
   put item 2 of the extents of communityTypeArray into mmaxItem
   if mmaxItem > 0 then
      put "<b>Community Types: </b>" & someDelim after htmlTemplate
      repeat with itemNum = 1 to mmaxItem
         put communityTypeArray [itemNum] & ", " after htmlTemplate
      end repeat
      put someDelim into char -2 to -1 of htmlTemplate
   end if
   --
   put "<p>" & someDelim after htmlTemplate
   --
   convert updatedAt to short date
   put "<b>Updated on: </b>[[updatedAt]]" after htmlTemplate
   put " | " after htmlTemplate
   convert createdAt to short date
   put "<b>Created on: </b>[[createdAt]]" & someDelim after htmlTemplate
   --
   put "</p>" & someDelim after htmlTemplate
   --
   put icSlug into hiddenKeyValueArray ["icSlug"]
   put platform_RestUrl ("intentional/importCommunity") into restURL
   put fedwiki_ConstructButtonForm ("Import", restURL, hiddenKeyValueArray) into formHTML
   put formHTML & someDelim after htmlTemplate
   --
   put "<hr>" after htmlTemplate
   -- put "</a>" after htmlTemplate
   --
   put merge (htmlTemplate) into someHTML
   return word 1 to -1 of someHTML
end ic_ConstructListElementHtml


--> IC | Fetch
-
function ic_FetchCommunityData cSlug
   put "https://www.ic.org/wp-json/v1/directory/entry/?slug=" & cSlug into someURL
   put url someURL into someJSON
   --
   put json_ToArray (someJSON) into icData
   return icData
end ic_FetchCommunityData

function ic_FetchCommunityTypeData communityType
   -- Commune
   put "https://www.ic.org/wp-json/v1/directory/entries/?type=" & communityType into someURL
   put url someURL into someJSON
   put json_ToArray (someJSON) into communityTypeData
   --
   put communityTypeData ["totalCount"] into totalCount
   put totalCount div 25 into maxPageNum
   if totalCount mod 25 > 0 then
      add 1 to maxPageNum
   end if
   --
   repeat with pageNum = 2 to maxPageNum
      set the cursor to busy
      put merge ("https://www.ic.org/wp-json/v1/directory/entries/?page=[[pageNum]]&type=[[communityType]]") into someURL
      put url someURL into someJSON
      put json_ToArray (someJSON) into nextCommunityTypeData
      put nextCommunityTypeData ["listings"] into listingArray
      repeat for each key itemNum in listingArray
         put 25*(pageNum - 1) + itemNum into newItemNum
         put listingArray [itemNum] into communityTypeData ["listings"][newItemNum]
      end repeat
   end repeat
   return communityTypeData
end ic_FetchCommunityTypeData

function ic_FetchCommunityDescriptionData communityDescription
   -- https://www.ic.org/wp-json/v1/directory/entries/?description=coop
   put "https://www.ic.org/wp-json/v1/directory/entries/?description=" & communityDescription into someURL
   put url someURL into someJSON
   put json_ToArray (someJSON) into communityDescriptionData
   --
   put communityDescriptionData ["totalCount"] into totalCount
   put totalCount div 25 into maxPageNum
   if totalCount mod 25 > 0 then
      add 1 to maxPageNum
   end if
   --
   repeat with pageNum = 2 to maxPageNum
      set the cursor to busy
      put merge ("https://www.ic.org/wp-json/v1/directory/entries/?page=[[pageNum]]&description=[[communityDescription]]") into someURL
      put url someURL into someJSON
      put json_ToArray (someJSON) into nextCommunityDescriptionData
      put nextCommunityDescriptionData ["listings"] into listingArray
      repeat for each key itemNum in listingArray
         put 25*(pageNum - 1) + itemNum into newItemNum
         put listingArray [itemNum] into communityDescriptionData ["listings"][newItemNum]
      end repeat
   end repeat
   return communityDescriptionData
end ic_FetchCommunityDescriptionData

function ic_FetchCountryData someCountry, pProvence
   put "https://www.ic.org/wp-json/v1/directory/entries/?country=" & urlEncode (someCountry) into someURL
   switch
      case pProvence is empty
         break
      case someCountry = "United States"
         put "&state=" & urlEncode (pProvence) after someURL
         break
      default
         put "&province=" & urlEncode (pProvence) after someURL
   end switch
   --
   put url someURL into someJSON
   put json_ToArray (someJSON) into icListData
   return icListData
end ic_FetchCountryData


--> Deps
-
function date_8601ToInternet rfc8601Date
   if rfc8601Date contains "T" then
      get rfc8601Date
      replace "T" with CR in it
      put line 1 of it into someDate
      put line 2 of it into timeBit
      switch
         case timeBit contains "-"
            set the itemdelimiter to "-"
            put item 1 of timeBit into someTime
            put "-" & item 2 of timeBit into someTimeZone
            break
         case timeBit contains "+"
            set the itemdelimiter to "+"
            put item 1 of timeBit into someTime
            put item 2 of timeBit into someTimeZone
            break
         case timeBit contains "Z"
            set the itemdelimiter to "Z"
            put item 1 of timeBit into someTime
            put "Z" into someTimeZone
            break
         default
            breakpoint
            put timeBit into someTime
            put "Z" into someTimeZone
      end switch
   else
      put word 1 of rfc8601Date into someDate
      put word 2 of rfc8601Date into someTime
      put word 3 of rfc8601Date into someTimeZone
   end if
   
   replace "-" with comma in someDate
   put someDate into someDateItems
   --
   set the itemdelimiter to ":"
   if the number of items of someTime = 1 then
      put char 1 to 2 of someTime into colonHours
      put char 3 to 4 of someTime into colonMinutes
      put char 5 to -1 of someTime into colonSeconds
   else
      put item 1 of someTime into colonHours
      put item 2 of someTime into colonMinutes
      put item 3 of someTime into colonSeconds
   end if
   if colonSeconds is empty then
      put 0 into colonSeconds
   end if
   --
   set the itemdelimiter to comma
   if someTimeZone contains "Z" is false then
      if colonHours is a number AND colonMinutes is a number AND colonSeconds is a number then
         put colonHours * 60*60 into someSeconds
         add colonMinutes*60 to someSeconds
         add colonSeconds to someSeconds
         --
         set the itemdelimiter to ":"
         if the number of items of someTimeZone = 1 then
            put char 1 to -3 of someTimeZone into tzHours
            put char -2 to -1 of someTimeZone into tzMinutes
         else
            put item 1 of someTimeZone into tzHours
            put item 2 of someTimeZone into tzMinutes
         end if
         
         if tzHours is a number AND tzMinutes is a number then
            if tzHours > 0 then
               add tzHours*60*60 to someSeconds
               add tzMinutes*60 to someSeconds
            else
               add tzHours*60*60 to someSeconds
               subtract tzMinutes*60 from someSeconds               
            end if
            --
            if someSeconds < 0 then
               -- steal a day
               add 24*60*60 to someSeconds
               --
               set the itemdelimiter to comma
               put item 3 of someDateItems into someDay
               subtract 1 from someDay
               put someDay into item 3 of someDateItems
            end if
            
            put (someSeconds  div (60*60)) into colonHours
            put (someSeconds  mod (60*60)) into secondsRemaining
            put (secondsRemaining  div 60) into colonMinutes
            put (secondsRemaining  mod 60) into colonSeconds
         end if
      end if
   end if
   --
   set the itemdelimiter to comma
   put colonHours into item 4 of someDateItems
   put colonMinutes into item 5 of someDateItems
   if colonSeconds is empty then
      put 0 into item 6 of someDateItems 
   else
      put trunc (colonSeconds) into item 6 of someDateItems 
   end if
   put 0 into item 7 of someDateItems
   --
   convert someDateItems to internet date
   return someDateItems
end date_8601ToInternet
