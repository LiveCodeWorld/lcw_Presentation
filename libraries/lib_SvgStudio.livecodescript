script "lib_SvgStudio"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_SvgStudio
type: library
version: 0.2


--> Variable
-
local LocalArray


--> Working on
-
command display_SvgStudio relPath
   put svgStudio_Get (relPath) into svgXML
   display_SvgButton svgXML
   return the result
end display_SvgStudio

command display_GeneratedSvg
   put svgStudio_RetrieveData ("Tiger") into rData
   display_Data rData
   --
   put "Arthur Dent" into sPrompt
   put svgStudio_Generate (sPrompt) into svgXML
   
   display_SvgButton svgXML, sPrompt
   -- display_SVG svgFile, pStackLabel, pStackStyle, pLocOrRect
end display_GeneratedSvg


--> SvgStudio | Params
-
function svgStudio_GetDetailLevel
   put LocalArray ["detail_level"] into dLevel
   if dLevel is empty then put "standard" into dLevel
   return dLevel
end svgStudio_GetDetailLevel

command svgStudio_SetDetailLevel dLevel
   put dLevel into LocalArray ["detail_level"]
end svgStudio_SetDetailLevel

function svgStudio_ListDetailLevels
   return "minimal,low,standard,high,maximal"
end svgStudio_ListDetailLevels

function svgStudio_GetStyle
   put LocalArray ["style"] into sStyle
   if sStyle is empty then put "automatic" into sStyle
   return sStyle
end svgStudio_GetStyle

command svgStudio_SetStyle sStyle
   put sStyle into LocalArray ["style"]
end svgStudio_SetStyle

function svgStudio_ListStyles
   return "automatic,default,cartoon style,contour,icon,line_art,logo,manga_style,papercut,silhouette"
end svgStudio_ListStyles

function svgStudio_GenerateArray pWidth, pHeight, pDetailLevel, pIterations, pSamples, pStrength, pSeed, pMaskUrl
   local paramArray
   
   if pIterations is empty then put 15 into pIterations
   put pIterations into paramArray ["n_iterations"]
   
   if pSamples is empty then put 1 into pSamples
   put pSamples into paramArray ["n_samples"]
   	
   if pWidth is empty then put 768 into pWidth
   put pWidth into paramArray ["width"]
   
   if pHeight is empty then put 768 into pHeight
   put pHeight into paramArray ["height"]
   
   if pDetailLevel is empty then put "standard" into pDetailLevel
   put pDetailLevel into paramArray ["detail_level"]
   
   if pStrength is empty then put 0.75 into pStrength
   put pStrength into paramArray ["strength"]
   
   if pSeed is empty then put 42 into pSeed
   put pSeed into paramArray ["Seed"]
   
   put pMaskUrl into paramArray ["mask_url"]
   return paramArray
end svgStudio_GenerateArray


--> SvgStudio
-
function svgStudio_GetToken
   -- This token corresponds to a budget of 100 units and will expire on October 01, 2025.
   put secret_Get ("svgStudio") into apiToken
   return apiToken
end svgStudio_GetToken

command svgStudio_SetToken apiToken
   secret_Set "svgStudio", apiToken
end svgStudio_SetToken

function svgStudio_Generate sPrompt, pImageUrl, pStyle, pParamArray, pToken
   /* 
   curl -X POST https://svgstud.io/generate/ \
   -H "Content-Type: application/json" \
         -d '{"prompt":"friendly alien with smartphone"}'
   */
   if pStyle is empty then put "automatic" into pStyle
   if pToken is empty then
      put svgStudio_GetToken() into pToken
   end if
   
   put sPrompt into pParamArray ["prompt"]
   put pImageUrl into pParamArray ["image_url"]
   put pStyle into pParamArray ["style"]
   put pToken into pParamArray ["token"]
   
   put svgStudio_RestUrl ("/generate/") into restUrl
   put jsonrpc_PostArray (pParamArray, restUrl) into rData
   --
   put rData [1] into relPath
   put svgStudio_Get (relPath) into svgXML
   return svgXML
end svgStudio_Generate

function svgStudio_Get relPath
   put svgStudio_RestUrl (relPath) into svgURL
   put url svgURL into svgXML
   return svgXML
end svgStudio_Get

function svgStudio_RetrieveData sPrompt, pImageUrl, pWeight, pDedup, pResultNum
   # Retrieve similar SVGs for a query
   -- curl "https://svgstud.io/retrieve/?prompt=friendly+alien&n_results=5"
   
   # Construct paramArray
   put sPrompt into pParamArray ["prompt"]
   put pImageUrl into pParamArray ["image_url"]
   --
   if pWeight is empty then put 0.015 into pWeight
   put pWeight into pParamArray ["aesthetic_weight"]
   --
   if pDedup is empty then put false into pDedup
   put pDedup into pParamArray ["deduplication"]
   --
   if pResultNum is empty then put 10 into pResultNum
   put pResultNum into pParamArray ["n_results"]
   
   put svgStudio_RestUrl ("/retrieve/") into restUrl
   put jsonrpc_PostArray (pParamArray, restUrl) into rData
   --
   return rData
end svgStudio_RetrieveData

function svgStudio_TokenBudget
   -- curl "https://svgstud.io/token_budget/?token=YOUR_TOKEN"
   
   # Check your remaining token budget
   put "https://svgstud.io/token_budget/?token=" & apiToken into restURL
   put jsonrpc_GetArray (restURL) into rData
   display_Data rData
end svgStudio_TokenBudget

function svgStudio_RequestToken
   -- https://svgstud.io/request_token
end svgStudio_RequestToken

function svgStudio_RestUrl restPath
   put "https://svgstud.io" into restStem
   put restStem & restPath into restUrl
   return restUrl
end svgStudio_RestUrl


--> SvgStudio
-


--> Deps
-
