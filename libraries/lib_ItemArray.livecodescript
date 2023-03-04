script "lib_ItemArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_ItemArray
type: library
version: 0.1

/*Some help*/


--> Working on
-
command display_StoryArrayFragments storyArray, pageTitle
   --- display_Data storyArray, pageTitle, "Story Array"
   --
   repeat with itemNum = 1 to item 2 of the extents of storyArray
      put "Story Item" && itemNum into sLabel
      put storyArray [itemNum] into itemArray
      put itemArray ["type"] into itemType
      --
      switch itemType
         case "video"
            itemArray_DisplayVideo itemArray
            break
         case "image"
            itemArray_DisplayImage itemArray
            break
         case "html"
            itemArray_DisplayHtml itemArray
            break
         case "markdown"
            itemArray_DisplayMarkdown itemArray
            break
         default
            -- itemArray_DisplayText itemArray, sLabel
      end switch
   end repeat
end display_StoryArrayFragments

function pageArray_FindFirstMedia pageArray
   put pageArray ["story"] into storyArray
   repeat with itemNum = 1 to item 2 of the extents of storyArray
      put storyArray [itemNum] into itemArray
      put itemArray ["type"] into itemType
      put storyArray [itemNum]["text"] into itemText
      --
      put itemType into resultArray ["mediaType"]
      switch
         case itemType = "video"
            get line 1 of itemText
            put word 1 of it into videoType
            put videoType into itemArray ["videoType"]
            
            switch videoType
               case "HTML5"
                  put word 2 of it into itemArray ["mime"]
                  put word 3 of it into itemArray ["videoURL"]
                  return itemArray
               case "VIMEO"
               case "YOUTUBE"
               default
                  return itemArray
            end switch
         case itemType = "image"
            return itemArray
         case itemArray ["type"] = "html"
            -- should check
            -- "text": "<div style='padding: 12px; background:#eee; width:96%; align=centered;'>\n<a href='https://www.mandalaforchange.com/site/wp-content/uploads/DSC_0151_zps9cc637bc-1.jpg' target='_blank'><img style='display:block; margin:auto; width:100%;' src='https://www.mandalaforchange.com/site/wp-content/uploads/DSC_0151_zps9cc637bc-1.jpg'>\n</a>\n<p class=caption>\nOrganizing Transformation with [[Legislative Theatre]] - [https://www.mandalaforchange.com/site/blog/organizing-transformation-with-legislative-theatre/ mandalaforchange.com]\n</p></div>",
            
            put itemText into resultArray ["html"]
            return resultArray
      end switch
   end repeat
   return empty
end pageArray_FindFirstMedia

command display_InvisibleText @cloneStackName, itemText, dTitle, sLabel, pTitleColour
   if cloneStackName is empty then put "Display Text" into cloneStackName
   if pTitleColour is empty then put "random" into pTitleColour
   --
   stack_CloneInvisible "View|Index|Simple", cloneStackName
   put the result into cloneStackName
   put the long id of control 1 of cd 1 of stack cloneStackName into displayView
   --
   set the label of stack cloneStackName to sLabel
   set the title_Text of displayView to dTitle
   --
   set the card_Margin of displayView to 0
   set the field_Style of displayView to "text"
   -- set the multiple_Hilites of displayView to false
   
   set the title_Colours of displayView to pTitleColour
   set the displayed_Text of displayView to itemText
   --
   return displayView
end display_InvisibleText

command display_ShowInvisible cloneStackName
   -- revIdeEnsureOnscreen cloneStackName -- we use our own version?
   switch
      case "system"
         set the systemWindow of stack cloneStackName to true
         break
      default
         set the style of stack cloneStackName to "palette"
   end switch
   show stack cloneStackName
end display_ShowInvisible


--> ItemArray
-
function itemArray_GetSectionTitle itemArray
   if itemArray ["type"] is not "markdown" then return empty
   --
   put itemArray ["text"] into markDownText
   put word 1 to -1 of line 1 of markDownText into maybeTitle
   --
   switch
      case maybeTitle begins with "# "
      case maybeTitle begins with "* "
         put word 2 to -1 of maybeTitle into sectionTitle
         return sectionTitle
      default
         return empty
   end switch
end itemArray_GetSectionTitle

command itemArray_DisplayText itemArray, sLabel, pTitleColour, pCloneStackName
   put sLabel into dTitle -- for now
   put itemArray ["text"] into itemText
   --
   display_InvisibleText pCloneStackName, itemText, dTitle, sLabel, pTitleColour
   put the result into displayView
   display_ShowInvisible pCloneStackName
   return displayView
end itemArray_DisplayText

command itemArray_DisplayHtml itemArray, sLabel, pTitleColour, pCloneStackName
   -- should check
   -- "text": "<div style='padding: 12px; background:#eee; width:96%; align=centered;'>\n<a href='https://www.mandalaforchange.com/site/wp-content/uploads/DSC_0151_zps9cc637bc-1.jpg' target='_blank'><img style='display:block; margin:auto; width:100%;' src='https://www.mandalaforchange.com/site/wp-content/uploads/DSC_0151_zps9cc637bc-1.jpg'>\n</a>\n<p class=caption>\nOrganizing Transformation with [[Legislative Theatre]] - [https://www.mandalaforchange.com/site/blog/organizing-transformation-with-legislative-theatre/ mandalaforchange.com]\n</p></div>",
   
   put sLabel into dTitle -- for now
   put itemArray ["text"] into itemText
   --
   display_InvisibleText pCloneStackName, itemText, dTitle, sLabel, pTitleColour
   put the result into displayView
   display_ShowInvisible pCloneStackName
   return displayView
end itemArray_DisplayHtml

command itemArray_DisplayMarkdown itemArray, sLabel, pTitleColour, pCloneStackName
   put sLabel into dTitle -- for now
   put itemArray ["text"] into itemMarkdown
   --
   display_InvisibleText pCloneStackName, itemMarkdown, dTitle, sLabel, pTitleColour
   put the result into displayView
   display_ShowInvisible pCloneStackName
   return displayView
end itemArray_DisplayMarkdown


--> ItemArray | Image
-
command itemArray_DisplayImage itemArray, sLabel, pTitleColour, pCloneStackName
   put sLabel into dTitle -- for now
   put itemArray ["text"] into itemMarkdown
   --
   display_InvisibleText pCloneStackName, itemMarkdown, dTitle, sLabel, pTitleColour
   put the result into displayView
   display_ShowInvisible pCloneStackName
   return displayView
end itemArray_DisplayImage

command itemArray_DisplayVideo itemArray
   put itemArray ["text"] into itemText
   --
   get line 1 of itemText
   put word 1 of it into videoType
   
   switch videoType
      case "HTML5"
         put word 2 of it into videoMime
         put word 3 of it into videoURL
         --
         display_Video videoURL
         break
      case "VIMEO"
         put word 2 of it into vimeoID
         put vimeo_GetVideoArray (vimeoID) into videoArray
         display_Data videoArray, vimeoID, "VIMEO"
         break
      case "YOUTUBE"
         put word 2 of it into youtubeID
         put youtube_FetchVideoArray (youtubeID) into videoArray
         display_Data videoArray, youtubeID, "YOUTUBE"
         break
      default
         itemArray_DisplayText itemArray, videoType
   end switch
end itemArray_DisplayVideo
