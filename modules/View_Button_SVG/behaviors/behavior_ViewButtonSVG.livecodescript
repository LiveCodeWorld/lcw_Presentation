script "behavior_ViewButtonSVG"
--> MetaData
-
license: GPLv3
name: behavior_ViewButtonSVG
type: behavior
version: 0.2


--> Events
-

--> Drag
-
on dragDrop
   put the long id of me into displayView
   --
   put the dragdata ["text"] into dData ["text"]
   put the dragdata ["files"] into dData ["files"]
   put the dragdata ["html"] into dData ["html"]
   put the dragdata ["image"] into dData ["image"]
   --
   -- display_Data dData, "More Dropped Data"
   put dData ["html"] into html
   if html is not empty then
      put dData ["text"] into someURL
      put "https://thenounproject.com/icon/(.*)/" into regEx
      if matchText (someURL, regEx, nameID) is true then
         -- diversity-6183633
         set the itemdelimiter to "-"
         put item -1 of nameID into iconID
         put item 1 of nameID into iconName
         --
         display_NounIcon iconID, displayView
      end if
   end if
end dragDrop

on dragEnter
   set the dragAction to "link"
end dragEnter

on mouseDown pButton
   if pButton = 3 then
      menu_PopUp "Global | Button | SVG | Menu"
   else
      if word 1 of the target = "image" then
         if the burnt_Image of me is true then
            grab me
         else
            grab the target
         end if
      end if
   end if
end mouseDown


--> Props
-
getprop icon_SvgXml
   put _SvgWidget() into svgWidget
   --
   put the uOPN ["svgXML"] of svgWidget into svgXML
   return svgXML
end icon_SvgXml

setprop icon_SvgXml svgXML
   put _SvgWidget() into svgWidget
   --
   put svg_GetPathText (svgXML) into pathText
   set the icon_PathText of svgWidget to pathText
   set the uOPN ["svgXML"] of svgWidget to svgXML
   --
   return pathText
end icon_SvgXml

getprop icon_PathText
   put the iconPath of _SvgWidget() into iconPathText
   return iconPathText
end icon_PathText

setprop icon_PathText iconPathText
   put _SvgWidget() into svgWidget
   set the iconPath of svgWidget to iconPathText
   return svgWidget
end icon_PathText

getprop icon_Width
   return the width of me
end icon_Width

setprop icon_Width [someMargin] someWidth
   lock screen
   if someMargin is not empty then
      set the margins of me to someMargin
   end if
   put the square_Rect [someWidth] of me into squareRect
   if the rect of me = squareRect then
      LayoutControl squareRect
   else
      set the rect of me to squareRect
   end if
   unlock screen
end icon_Width

getprop icon_Margin
   return the margins of me
end icon_Margin

setprop icon_Margin someMargin
   put the rect of me into oRect
   lock screen
   set the margins of me to someMargin
   LayoutControl oRect
   unlock screen
end icon_Margin

getprop icon_Name
   put _SvgWidget() into _SvgWidget
   put the iconPresetName of _SvgWidget into iName
   return iName
end icon_Name

setprop icon_Name iName
   put _SvgWidget() into _SvgWidget
   set the iconPresetName of _SvgWidget to iName
   return _SvgWidget
end icon_Name


--> Objects
-
getprop svgIcon_View
   return the long id of me
end svgIcon_View

getprop view_Object
   return the long id of me
end view_Object

private function _SvgWidget
   return the long id of me
end _SvgWidget
