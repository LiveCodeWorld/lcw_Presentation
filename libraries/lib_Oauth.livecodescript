script "lib_Oauth"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Oauth
type: library
version: 0.1

/*
command launch_FlickrRequestURL
   put flickroAuth_ConstructRequestURL() into requestURL
   launch url requestURL
end launch_FlickrRequestURL

function flickroAuth_ConstructRequestURL
   put "https://www.flickr.com/services/oauth/request_token" into restEndPoint
   put "http://127.0.0.1:54303/" into callBackURL
   --
   put flickr_ConstructRequestTokenParamArray (callBackUrl) into requestArray
   put flickr_GetRequestSig (restEndPoint, callBackUrl) into oAuthSignature
   put oAuthSignature into requestArray ["oauth_signature"]
   put _SortAndEncodeString (requestArray) into paramString
   --
   put restEndPoint & "?" & paramString into requestURL
   return requestURL
end flickroAuth_ConstructRequestURL

function flickr_GetRequestSig restEndPoint, callBackUrl
   put flickr_GetConsumerSecret() into consumerSecret
   put flickr_ConstructRequestTokenParamArray (callBackUrl) into requestArray
   oauth_DeconstructRequestArray requestArray, timeStamp, authNonce, consumerKey, authVersion, callbackURL, signatureMethod
   --
   /*
   -- put flickr_ConstructOauthKey() into oauthKey
   -- flickr_ConstructParamBits "GET", someUrl, paramArray, urlParamBit, baseString
   -- put sha1_HMAC (baseString, oauthKey) into oAuthSignature
   */
   
   put oAuth_ConstructSignature ("GET", restEndPoint, consumerKey, consumerSecret, callBackUrl, timeStamp, authNonce) into oAuthSignature
   return oAuthSignature
end flickr_GetRequestSig

-- function flickr_FetchRequestToken
put "https://www.flickr.com/services/oauth/request_token" into restEndPoint
put "http://127.0.0.1:54303/" into callBackURL
--
put flickr_GetRequestSig (restEndPoint, callBackUrl) into oAuthSignature
--
put "?" & urlParamBit after someUrl
put "&oauth_signature=" & urlencode (oauthSignature) after someURL

put url someURL into someResponse
return someResponse
end flickr_FetchRequestToken
*/

--> Working on
-
function oAuth_ConstructRequestURL restURL, requestArray, constructedSig
   -- order does not matter for url params
   url_SplitParams restURL, restEndPoint, restParamBit
   put the result into restParamArray
   --
   put "oauth_consumer_key=" & urlencode (requestArray["oauth_consumer_key"]) & "&" after urlBit
   put "oauth_signature_method=" & urlencode (requestArray["oauth_signature_method"]) & "&" after urlBit
   --
   put "oauth_timestamp=" & urlencode (requestArray ["oauth_timestamp"]) & "&" after urlBit
   put "oauth_nonce=" & urlencode (requestArray ["oauth_nonce"]) & "&" after urlBit
   put "oauth_version=" & urlencode (requestArray["oauth_version"]) & "&" after urlBit
   --
   put url_ConstructParamBit (restParamArray) & "&" after urlBit
   --
   put "oauth_signature=" & urlencode (constructedSig) after urlBit
   --
   put restEndPoint & "?" & urlBit into requestURL
   --
   return requestURL
end oAuth_ConstructRequestURL

function oAuth_ConstructRequestArray restMethod, restURL, consumerKey, consumerSecret, pCallbackURL, pTimeStamp, pAuthNonce
   put _CollectRequestParamArray (consumerKey, pTimeStamp, pAuthNonce, pCallbackURL) into requestArray
   url_SplitParams restURL, restEndPoint, restParamBit
   put the result into restParamArray
   union requestArray with restParamArray
   --
   put oAuth_ConstructSignature (restMethod, restURL, consumerKey, consumerSecret, pCallbackURL, pTimeStamp, pAuthNonce) into oauthSignature
   put oauthSignature into requestArray ["oauth_signature"]
   --
   return requestArray
end oAuth_ConstructRequestArray

private function _CollectRequestParamArray consumerKey, pTimeStamp, pAuthNonce, pCallbackURL, pSigMethod, pOauthVersion
   -- collect basic stuff
   if pAuthNonce is empty then
      put uuid() into pAuthNonce
      replace "-" with empty in pAuthNonce
      put char 1 to 11 of pAuthNonce into pAuthNonce
   end if
   if pSigMethod is empty then put "HMAC-SHA1" into pSigMethod
   if pTimeStamp is empty then put the seconds into pTimeStamp
   if pOauthVersion is empty then put "1.0" into pOauthVersion
   --
   if pCallbackURL is not empty then
      put pCallbackURL into paramArray ["oauth_callback"]
   end if
   --
   put consumerKey into paramArray ["oauth_consumer_key"]
   --
   put pAuthNonce into paramArray ["oauth_nonce"]
   put pSigMethod into paramArray ["oauth_signature_method"]
   put pTimeStamp into paramArray ["oauth_timestamp"]
   put pOauthVersion into paramArray ["oauth_version"]
   --
   return paramArray
end _CollectRequestParamArray

function oAuth_ConstructSignature restMethod, restURL, consumerKey, consumerSecret, pCallbackURL, pTimeStamp, pAuthNonce
   -- https://developer.twitter.com/en/docs/authentication/oauth-1-0a/creating-a-signature
   
   put oAuth_ConstructBaseString (restMethod, restURL, consumerKey, pCallbackURL, pTimeStamp, pAuthNonce) into baseString
   put _ConstructSignatureKey (consumerSecret) into signatureKey
   put sha1_HMAC (baseString, signatureKey) into oAuthSignature
   --
   return oAuthSignature
end oAuth_ConstructSignature

function oAuth_ConstructBaseString restMethod, restURL, consumerKey, pCallbackURL, pTimeStamp, pAuthNonce
   url_SplitParams restURL, restEndPoint, restParamBit
   put the result into restParamArray
   
   # Convert the HTTP Method to uppercase and set the output string equal to this value.
   put toupper (restMethod) into baseString
   put "&" after baseString
   
   # Percent encode the URL and append it to the output string.
   put oAuth_PercentEncode (restEndPoint) after baseString
   put "&" after baseString
   
   # Construct the parameter string from components encoding params and keys.
   put oAuth_CollectRequestParamString (consumerKey, restParamArray, pTimeStamp, pAuthNonce, pCallbackURL) into paramString
   
   # Percent encode the parameter string and append it to the output string.
   put oAuth_PercentEncode (paramString) after baseString
   
   # Test base string
   put baseString into testString
   if "%" is among the lines of testString then throw "Error"
   set the linedelimiter to "&"
   if the number of lines of baseString = 3 then
      return baseString
   else
      throw "Error"
   end if
end oAuth_ConstructBaseString

function oAuth_CollectRequestParamString consumerKey, restParamArray, pTimeStamp, pAuthNonce, pCallbackURL, pSigMethod, pOauthVersion
   put _CollectRequestParamArray (consumerKey, pTimeStamp, pAuthNonce, pCallbackURL, pSigMethod, pOauthVersion) into requestArray
   union requestArray with restParamArray
   put _SortAndEncodeString (requestArray) into paramString
   return paramString
end oAuth_CollectRequestParamString

private function _SortAndEncodeString paramArray
   put keys (paramArray) into paramkeys
   sort paramKeys
   repeat for each line paramKey in paramkeys
      put paramArray [paramKey] into paramValue
      put oAuth_PercentEncode (paramKey) & "=" & oAuth_PercentEncode (paramValue) & "&" after encodedString
   end repeat
   delete char -1 of encodedString
   return encodedString
end _SortAndEncodeString

command url_SplitParams restURL, @restEndPoint, @restParamBit
   set the itemdelimiter to "?"
   put item 1 of restURL into restEndPoint
   --
   put item 2 to -1 of restURL into restParamBit
   --
   put restParamBit into restParamArray
   split restParamArray using "&" and "="
   return restParamArray
end url_SplitParams


--> oAuth
-
function url_ConstructParamBit paramArray
   put the keys of paramArray into pKeys
   sort pKeys
   repeat for each line paramKey in pKeys
      put paramArray [paramKey] into paramValue
      put urlencode (paramKey) & "=" & urlencode (paramValue) & "&" after urlBit
   end repeat
   delete char -1 of urlBit
   return urlBit
end url_ConstructParamBit

function oAuth_ConstructRequestHeader restMethod, restEndPoint, consumerKey, consumerSecret, pCallbackURL, pTimeStamp, pAuthNonce
   put oAuth_ConstructRequestArray (restMethod, restEndPoint, consumerKey, consumerSecret, pCallbackURL, pTimeStamp, pAuthNonce) into requestArray
   put _ConstructHeader (requestArray) into extraHeaders
   return extraHeaders
end oAuth_ConstructRequestHeader

command oauth_DeconstructRequestArray requestArray, @timeStamp, @authNonce, @consumerKey, @authVersion, @callbackURL, @signatureMethod
   put word 1 to -1 of requestArray ["oauth_timestamp"] into timeStamp
   put word 1 to -1 of requestArray ["oauth_nonce"] into authNonce
   put word 1 to -1 of requestArray ["oauth_consumer_key"] into consumerKey
   
   put word 1 to -1 of requestArray ["oauth_version"] into authVersion
   get word 1 to -1 of requestArray ["oauth_callback"]
   put urldecode (it) into callbackURL
   
   put word 1 to -1 of requestArray ["oauth_signature_method"] into signatureMethod
end oauth_DeconstructRequestArray

function oAuth_PercentEncode someText
   /*
   -- https://developer.twitter.com/en/docs/authentication/oauth-1-0a/percent-encoding-parameters
   
   This is a modified version of urlencode used in creating sigs
   The current version is a quick hack.
   Todo: look at the documentation and code a complete verison of this function  (http://www.marcworrell.com/article-2943-en.html)
   
   OAuth encoding only allows letters, numbers and the following 4 punctuation marks: “_”, “-“, “.” and “~”. All other characters must be encoded.
   
   You will likely not notice the difference until you come to call methods that include things like title etc, as most parameters will not contain data that is encoded differently with the above compared to standard url encoding.
   
   A little post I found covering some of the differences is here: http://www.marcworrell.com/article-2943-en.html
   */
   
   put urlencode (someText) into someText
   replace "+" with "%20" in someText
   replace "%7E" with "~" in someText
   return someText
end oAuth_PercentEncode


--> Private
-
private function _ConstructSignatureKey consumerSecret, pTokenSecret
   /*
   The specification states that the shared HMAC key is the consumer secret, the "&" separator, and the token secret (or the empty string if no token secret has been established yet)
   
   The key that is used together with the sha1 digest function in creating and HMAC signature is derived from
   the concatenated values of the Consumer Secret and Token Secret, separated by an '&'.
   
   The tokenSecret may be given in a previous call to the api for that particular stage of the provess,
   or it may be empty
   
   -- http://www.wackylabs.net/2011/12/oauth-and-flickr-part-2/
   
   Key = Consumer Secret + “&” + Token Secret
   
   To generate a SHA1 signature you require two things. 
   First a key. For OAuth the signature key is made up of two parts, your consumer secret, and your token secret (for whichever token you are using at the time). 
   As this is the first stage you have neither, so your token secret is simply an empty string.
   */
   
   put oAuth_PercentEncode (consumerSecret) & "&" into signatureKey
   if pTokenSecret is not empty then
      put oAuth_PercentEncode (pTokenSecret) after signatureKey
   end if
   return signatureKey
end _ConstructSignatureKey

private function _ConstructHeader requestArray
   /*
   # Append the string “OAuth ” (including the space at the end) to DST.
   For each key/value pair of the 7 parameters listed above:
   Percent encode the key and append it to DST.
   Append the equals character ‘=’ to DST.
   Append a double quote ‘”’ to DST.
   Percent encode the value and append it to DST.
   Append a double quote ‘”’ to DST.
   If there are key/value pairs remaining, append a comma ‘,’ and a space ‘ ‘ to DST.
   */
   
   put "authorization: OAuth " into extraHeaders
   --
   put keys (requestArray) into paramkeys
   sort paramKeys
   repeat for each line paramKey in paramkeys
      put requestArray [paramKey] into paramValue
      --
      get oAuth_PercentEncode (paramValue)
      put oAuth_PercentEncode (paramKey) & "=" & kwote(it) & ", " after extraHeaders
   end repeat
   delete char -2 to -1 of extraHeaders
   return extraHeaders
end _ConstructHeader

private command _ConstructParamBits restMethod, restEndPoint, paramArray, @urlParamBit, @baseString
   -- http://www.wackylabs.net/2011/12/oauth-and-flickr-part-2/
   
   -- encode the params
   put keys (paramArray) into paramkeys
   sort paramKeys
   repeat for each line paramKey in paramkeys
      put paramArray [paramKey] into paramValue
      get oAuth_PercentEncode (paramValue)
      put paramKey & "=" & kwote(it) & "&" after urlParamBit
      put paramKey & "=" & kwote(it) & "&" after partiallyEncodedParamBit
   end repeat
   delete char -1 of urlParamBit
   delete char -1 of partiallyEncodedParamBit
   --
   put oAuth_PercentEncode (partiallyEncodedParamBit) into encodedParamBit
   --
   put restMethod & "&" & oAuth_PercentEncode (restEndPoint) &"&"& encodedParamBit into baseString
end _ConstructParamBits


--> Oauth
-
private function _EncodeSecondBit consumerKey, someTicks, oauthNonce, pCallbackURL
   if pCallbackURL is not emmpty then
      put "oauth_callback=" & oAuth_PercentEncode (callbackURL) into secondBit
      put "&" after secondBit
   end if
   
   put "oauth_consumer_key=" & oAuth_PercentEncode (consumerKey) after secondBit
   put "&" after secondBit
   
   put "oauth_nonce=" & oauthNonce after secondBit
   put "&" after secondBit
   
   put "oauth_signature_method=HMAC-SHA1" after secondBit
   put "&" after secondBit
   
   put "oauth_timestamp=" & someTicks after secondBit
   put "&" after secondBit
   
   put "oauth_version=1.0" after secondBit
   
   put oAuth_PercentEncode (secondBit) into encodedSecondBit
   
   return encodedSecondBit
end _EncodeSecondBit


--> Deps
-
command jsonrpc_SetHeaders pExtraHeaders
   put "Content-type: application/json" into someHeader
   put CR & "Accept: application/json" after someHeader
   put CR & "Accept-Charset: utf-8" after someHeader
   -- put CR & "Accept: */*" after someHeader
   -- put CR & "Accept-Encoding: gzip, deflate, br" after someHeader
   -- put CR &  "user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36" after someHeader
   --
   if pExtraHeaders is not empty then
      put CR & word 1 to -1 of pExtraHeaders after someHeader
   end if
   --
   put word 1 to -1 of someHeader into someHeader
   set the httpHeaders to someHeader
   return someHeader
end jsonrpc_SetHeaders

function sha1_HMAC someText, someKey
   /*
   This function should use the built in cypher function
   For now we cal openssl via the shell
   And have to write out a temporary file
   
   -- Compute a simplified hash-based message authentication code (HMAC)
   -- for a message using SHA3-256.  Consider using the full RFC 2104
   -- HMAC algorithm.
   put randomBytes(32) into tKey -- Save this key for later!
   put textEncode("Try my LiveCode app", "UTF-8") into tMessage
   get messageDigest(tKey & messageDigest(tKey & tMessage, \
         "SHA3-256"), "SHA3-256")
   */
   
   set the itemdelimiter to slash
   get the tempname
   put item 1 to -2 of it into tempFolder
   set the defaultfolder to tempFolder
   put item -1 of it & ".txt" into shortTempFile
   
   put someText into url ("file:" & shortTempFile)
   
   -- put "openssl dgst -sha1 -hmac" && kwote(someKey) && "-binary sometext.txt | openssl base64" into someShell
   put "openssl dgst -sha1 -hmac" && quote & someKey & quote && "-binary" && shortTempFile && "| openssl base64" into someShell
   put shell (SomeShell) into shellResult -- includes linebreak at the end
   return word 1 to -1 of shellResult
end sha1_HMAC
