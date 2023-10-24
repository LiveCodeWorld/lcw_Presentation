script "behavior_ViewButtonSVG"
--> MetaData
-
license: GPLv3
name: behavior_ViewButtonSVG
type: behavior
version: 0.1


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
      -- menu_PopUp "Global | Governance | Person | Menu"
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

on resizecontrol
   LayoutControl
end resizecontrol


--> Props
-
getprop icon_PathText
   put the iconPath of _svgWidget() into iconPathText
   return iconPathText
end icon_PathText

setprop icon_PathText iconPathText
   put _svgWidget() into svgWidget
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
   put _SvgWidget() into _svgWidget
   put the iconPresetName of _svgWidget into iName
   return iName
end icon_Name

setprop icon_Name iName
   put _SvgWidget() into _svgWidget
   set the iconPresetName of _svgWidget to iName
   return _svgWidget
end icon_Name


--> Geometry
-
command LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   lock screen
   put _SvgWidget() into svgWidget
   put the inner_Rect [pRect] of me into innerRect
   set the rect of svgWidget to innerRect
   unlock screen
end LayoutControl

private function _svgWidget
   return the long id of widget 1 of me
end _svgWidget
