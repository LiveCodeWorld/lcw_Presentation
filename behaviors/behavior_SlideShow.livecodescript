script "behavior_SlideShow"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_SlideShow
type: behavior
version: 0.1


--> Variables
-
local LocalArray

--> Working on
-
command show_DisplayMedia
   put the show_ModelName of me into showModelName
   put the slide_Array of me into slideArray
   
   put slideArray ["title"] into pageTitle
   put slideArray ["story"] into storyArray
   --
   if storyArray is an array then
      display_StoryArrayFragments storyArray, pageTitle
   else
      display_Data slideArray, pageTitle, "Story Array"
   end if
end show_DisplayMedia

command display_SlideArray slideArray, showModelName
   put showModelName into cloneStackName
   put pageArray_SectionData (slideArray) into sectionData
   repeat with sectionNum = 1 to item 2 of the extents of sectionData
      put showModelName && sectionNum into sLabel
      put sectionData [sectionNum]["sectionTitle"] into sectionTitle
      put sectionData [sectionNum]["section"] into sectionArray
      --
      put pageSection_ConstructMarkDown (sectionArray) into sectionText
      --
      display_InvisibleText cloneStackName, sectionText, sectionTitle, sLabel, pTitleColour
      put the result into displayView
      display_ShowInvisible cloneStackName
   end repeat
end display_SlideArray

command test_Media
   put the show_ModelName of me into showModelName
   put the slide_Array of me into slideArray
   put slideArray ["title"] into pageTitle
   put slideArray ["story"] into storyArray
   put "random" into pTitleColour
   --
   if storyArray is an array then
      display_SlideArray slideArray, showModelName
   end if
end test_Media

function pageSection_ConstructMarkDown sectionArray
   put the keys of sectionArray into itemNums
   sort numeric of itemNums
   repeat for each line itemNum in itemNums
      put sectionArray [itemNum] into itemArray
      put itemArray ["text"] into itemText
      --
      put itemText & CR&CR after sectionText
   end repeat
   delete char -2 to -1 of sectionText
   --
   return sectionText
end pageSection_ConstructMarkDown


--> Events | Slide
-
on keyDown kName
   put _TitleView() into vObject
   switch kName
      case "m"
         show_DisplayMedia
         break
      case "t"
         test_Media
         break
      case " "
         dispatch "textSize_ToggleShrink" to vObject
         break
      default
         put the params
   end switch
end keyDown

on arrowkey whichArrow
   -- if the commandKey is not down then pass arrowkey
   switch whichArrow
      case "right"
         nextSlide
         break
      case "left"
         previousSlide
         break
      case "Up"
         put the title_TextSize of me into oSize
         if the shiftKey is "Down" then
            set the title_TextSize [true] of me to (oSize + 5)
         else
            set the title_TextSize [true] of me to (oSize + 1)
         end if
         break
      case "Down"
         put the title_TextSize of me into oSize
         if the shiftKey is "Down" then
            set the title_TextSize [true] of me to (oSize - 5)
         else
            set the title_TextSize [true] of me to (oSize - 1)
         end if
         break
      default
         pass arrowkey
   end switch
end arrowkey


--> Show
-
getprop show_AutoSizeStyle
   put show_GetValue ("minTextSize") into minTextSize
   put show_GetValue ("maxTextSize") into maxTextSize
   --
   switch
      case minTextSize is empty
         return "none"
      case maxTextSize = minTextSize
         return "fixed"
      case maxTextSize > minTextSize
         return "auto"
      default
         return "broken"
   end switch   
end show_AutoSizeStyle

setprop show_AutoSizeStyle pHow
   put _TitleView() into titleView
   --
   lock screen
   put the slide_Number of me into oNum
   repeat with slideNum = 1 to the slide_LastNum of titleView
      set the cursor to busy
      switch
         case pHow = "auto"
            put the title_TextSize of titleView into tSize
            put tSize & comma after tSizeList
            slide_SetNumber slideNum, true
            show_SetSlideFormat slideNum, "textSize", tSize
            break
         case pHow is a number
            show_SetSlideFormat slideNum, "textSize", pHow
            break
         case pHow is empty
            show_SetSlideFormat slideNum, "textSize", empty
            break
      end switch
   end repeat
   delete char -1 of tSizeList
   --
   switch
      case pHow = "auto"
         set the slide_Number of me to oNum
         put min (tSizeList) into minTextSize
         put max (tSizeList) into maxTextSize
         --
         show_SetValue "minTextSize", minTextSize
         show_SetValue "maxTextSize", maxTextSize
         break
      case pHow is a number
         show_SetValue "minTextSize", pHow
         show_SetValue "maxTextSize", pHow
         break
      case pHow is empty
         show_SetValue "minTextSize", empty
         show_SetValue "maxTextSize", empty
         break
   end switch
   --
   unlock screen
end show_AutoSizeStyle

getprop show_TextSize
   put minTextSize & comma & maxTextSize & CR & tSizeList into tInfo
   return tInfo
end show_TextSize

command slide_SetNumber slideNum, pAutoSize
   if slideNum is not a number then put 1 into slideNum
   put _TitleView() into titleView
   --
   put slideNum into LocalArray ["slideNum"]
   put the slide_Array [slideNum] of me into slideArray
   _DeconstructSlideArray slideArray, slideTitle, synopsis
   --
   if pAutoSize is true then
      set the title_Text ["auto"] of titleView to slideTitle
   else
      put show_GetSlideFormat (slideNum, "textSize") into tSize
      if tSize is a number then
         set the title_Text [tSize] of titleView to slideTitle
      else
         set the title_Text ["auto"] of titleView to slideTitle
      end if
   end if
   --
   return slideArray
end slide_SetNumber


--> Working on
-
command slide_Loop
   put the keys of sitemapArray into pTitles
   repeat with itemNum = 1 to item 2 of the extents of sitemapArray
      put sitemapArray [itemNum]["title"] into pTitle
      put sitemapArray [itemNum]["synopsis"] into synopsis
      put sitemapArray [itemNum]["links"] into linkArray
      put sitemapArray [itemNum]["slug"] into pSlug
      --
      set the title_Text of vObject to pTitle
      --
      slide_Wait
   end repeat
end slide_Loop

command slide_Wait
   repeat
      get the keysdown
      switch it
         case empty
            break
         case 32 -- spacebar
            exit repeat
            break
         case 65361 -- left
            exit to top
            break
         case 65363 -- right
            break
         default
            put it
      end switch
   end repeat
end slide_Wait


--> Slide
-
on nextSlide
   put the slide_NextNum of me into nextNum
   set the slide_Number of me to nextNum
end nextSlide

on previousSlide
   put the slide_PreviousNum of me into previousNum
   set the slide_Number of me to previousNum
end previousSlide


--> SlideShow
-

--> Show | Model
-
function show_GetSlideFormat slideNum, someKey
   put LocalArray ["slideModel"][slideNum]["format"][someKey] into someValue
   return someValue
end show_GetSlideFormat

command show_SetSlideFormat slideNum, someKey, someValue
   put someValue into LocalArray ["slideModel"][slideNum]["format"][someKey]
end show_SetSlideFormat

function show_GetValue someKey
   put LocalArray ["showMetaData"][someKey] into someValue
   return someValue
end show_GetValue

command show_SetValue someKey, someValue
   put someValue into LocalArray ["showMetaData"][someKey]
   return LocalArray ["showMetaData"]
end show_SetValue

getprop show_ModelName
   return LocalArray ["showModelName"]
end show_ModelName

setprop show_ModelName showModelName
   put showModelName into LocalArray ["showModelName"]
end show_ModelName

getprop show_MetaData
   return LocalArray ["showMetaData"]
end show_MetaData

setprop show_MetaData showMetaData
   put showMetaData into showMetaData
end show_MetaData

getprop show_Model
   return LocalArray ["slideModel"]
end show_Model

setprop show_Model slideModel
   put slideModel into LocalArray ["slideModel"]
end show_Model


--> Slide | Model
-
getprop slide_Array [slideNum]
   if slideNum is empty then
      put the slide_Number of me into slideNum
   end if
   put the show_Model of me into slideModel
   put slideModel [slideNum] into slideArray
   return slideArray
end slide_Array

setprop slide_Array [slideNum] slideArray
   put the show_Model of me into slideModel
   put slideArray into slideModel [slideNum]
   set the show_Model of me to slideModel
   return slideModel
end slide_Array


--> Slide | Props
-
getprop slide_PreviousNum
   put the slide_Number of me into slideNum
   put the slide_LastNum of me into lastNum
   if slideNum = 1 then
      put lastNum into previousNum
   else
      put slideNum - 1 into previousNum 
   end if
   return previousNum
end slide_PreviousNum

getprop slide_NextNum
   put the slide_Number of me into slideNum
   put the slide_LastNum of me into lastNum
   if slideNum = lastNum then
      put 1 into nextNum
   else
      put slideNum + 1 into nextNum
   end if
   return nextNum
end slide_NextNum

getprop slide_LastNum
   put the show_Model of me into slideModel
   put item 2 of the extents of slideModel into lastNum
   return lastNum
end slide_LastNum

getprop slide_Number
   put LocalArray ["slideNum"] into slideNum
   if slideNum is not a number then put 1 into slideNum
   return slideNum
end slide_Number

setprop slide_Number slideNum
   switch slideNum
      case "next"
         put the slide_NextNum of me into nextNum
         slide_SetNumber nextNum
         break
      case "previous"
         put the slide_PreviousNum of me into previousNum
         slide_SetNumber previousNum
         break
      case "first"
         slide_SetNumber 1
         break
      case "last"
         put the slide_LastNum of me into lastNum
         slide_SetNumber lastNum
         break
      default
         slide_SetNumber slideNum
   end switch
   put the result into slideArray
   --
   return slideArray
end slide_Number


--> Private
-
private function _TitleView
   put the long id of group 1 of me into titleView
   return titleView
end _TitleView

private command _DeconstructSlideArray slideArray, @slideTitle, @synopsis
   put slideArray ["title"] into slideTitle
end _DeconstructSlideArray
