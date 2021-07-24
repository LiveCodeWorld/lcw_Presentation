script "lib_Oauth"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Oauth
type: library
version: 0.1

/*
*/

--> Working on
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

command test_Noun
   local pTimeStamp, pAuthNonce
   put "https://api.thenounproject.com/oauth/usage" into restEndPoint
   put "http://api.thenounproject.com/icon/1" into restEndPoint
   --
   put noun_GetConsumerKey() into consumerKey
   put noun_GetApiSecret() into consumerSecret
   --
   put oAuth_ConstructRequestHeader ("GET", restEndPoint, consumerKey, consumerSecret, pTimeStamp, pAuthNonce) into extraHeaders
   
   -- set the httpheaders to extraHeaders
   jsonrpc_SetHeaders extraHeaders
   put url restEndPoint into someJson
   --
   put extraHeaders & CR&CR & someJson
   -- display_JSON someJson
end test_Noun

function oAuth_ConstructRequestHeader restMethod, restEndPoint, consumerKey, consumerSecret, pCallbackURL, pTimeStamp, pAuthNonce
   put oAuth_ConstructRequestArray (restMethod, restEndPoint, consumerKey, consumerSecret, pCallbackURL, pTimeStamp, pAuthNonce) into requestArray
   put _ConstructHeader (requestArray) into extraHeaders
   return extraHeaders
end oAuth_ConstructRequestHeader

function oAuth_ConstructRequestArray restMethod, restEndPoint, consumerKey, consumerSecret, pCallbackURL, pTimeStamp, pAuthNonce
   put _CollectRequestParamArray (consumerKey, pTimeStamp, pAuthNonce, pCallbackURL) into requestArray
   --
   put oAuth_ConstructSignature (restMethod, restEndPoint, consumerKey, consumerSecret, pCallbackURL, pTimeStamp, pAuthNonce) into oauthSignature
   put oauthSignature into requestArray ["oauth_signature"]
   --
   return requestArray
end oAuth_ConstructRequestArray

function oAuth_ConstructSignature restMethod, restEndPoint, consumerKey, consumerSecret, pCallbackURL, pTimeStamp, pAuthNonce
   -- https://developer.twitter.com/en/docs/authentication/oauth-1-0a/creating-a-signature
   
   put oAuth_ConstructBaseString (restMethod, restEndPoint, consumerKey, pCallbackURL, pTimeStamp, pAuthNonce) into baseString
   put _ConstructSignatureKey (consumerSecret) into signatureKey
   put sha1_HMAC (baseString, signatureKey) into oAuthSignature
   --
   return oAuthSignature
end oAuth_ConstructSignature

function oAuth_ConstructBaseString restMethod, restEndPoint, consumerKey, pCallbackURL, pTimeStamp, pAuthNonce
   -- was "flickr_OauthConstructBaseString"
   
   # Convert the HTTP Method to uppercase and set the output string equal to this value.
   put toupper (restMethod) into baseString
   
   # Append the ‘&’ character to the output string.
   put "&" after baseString
   
   # Percent encode the URL and append it to the output string.
   put oAuth_PercentEncode (restEndPoint) after baseString
   
   # Append the ‘&’ character to the output string.
   put "&" after baseString
   
   # Construct the parameter string from components encoding params and keys.
   put oAuth_CollectRequestParamString (consumerKey, pTimeStamp, pAuthNonce, pCallbackURL) into paramString
   
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

function oAuth_CollectRequestParamString consumerKey, pTimeStamp, pAuthNonce, pCallbackURL, pSigMethod, pOauthVersion
   put _CollectRequestParamArray (consumerKey, pTimeStamp, pAuthNonce, pCallbackURL, pSigMethod, pOauthVersion) into requestArray
   put _SortAndEncodeString (requestArray) into paramString
   return paramString
end oAuth_CollectRequestParamString

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

private function _CollectRequestParamArray consumerKey, pTimeStamp, pAuthNonce, pCallbackURL, pSigMethod, pOauthVersion
   /*
   -- was "flickr_ConstructRequestTokenParamArray"
   Might need query params
   or content os a ppos
   */
   if pAuthNonce is empty then put uuid() into pAuthNonce
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
   --
   if pExtraHeaders is not empty then
      put CR & word 1 to -1 of pExtraHeaders after someHeader
   end if
   --
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
