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


constant NounEendpoint = "http://api.thenounproject.com"

--> Working on
-


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
