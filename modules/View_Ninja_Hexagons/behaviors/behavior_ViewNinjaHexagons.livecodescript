script "behavior_ViewNinjaHexagons"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewNinjaHexagons
type: behavior
version: 0.1

/*
Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.
*/

--> Variables
-
local LocalArray


--> Working on
-
getprop hex_Hilite
   put LocalArray ["hexHilite"] into sBoolean
   return sBoolean
end hex_Hilite

setprop hex_Hilite sBoolean
   put the hexRing_View of the target into hexObject
   if exists (hexObject) is false then return empty
   --
   put LocalArray ["hexHilite"] into oHilite
   if (oHilite is not true) AND (sBoolean is true) then
      set the backgroundcolor of hexObject to "orange"
      --
      put the width of hexObject into LocalArray ["oHexWidth"]
      -- set the hex_Animate of hexObject to 1
   else if sBoolean is false then
      put LocalArray ["oHexWidth"] into oHexWidth
      if oHexWidth is a number then set the hexRing_Diameter of hexObject to oHexWidth
      --
      set the backgroundcolor of hexObject to "black"
   end if
   put sBoolean is true into LocalArray ["hexHilite"]
   --
   return hexObject
end hex_Hilite

getprop hexRing_Effect
   put the dropshadow of _LeftHex() into sArray
   return sArray
end hexRing_Effect

setprop hexRing_Effect sArray
   put the dropshadow of _LeftHex() into sArray
   
   lock screen
   set the dropshadow of _LeftHex() to sArray
   set the dropshadow of _TopLeftHex() to sArray
   set the dropshadow of _TopRightHex() to sArray
   set the dropshadow of _RightHex() to sArray
   set the dropshadow of _BottomRightHex() to sArray
   set the dropshadow of _BottomLeftHex() to sArray
   unlock screen
end hexRing_Effect

function hex_PointWithin sPoint
   switch
      case within (_LeftHex(), sPoint)
         return _LeftHex()
      case within (_TopLeftHex(), sPoint)
         return _TopLeftHex()
      case within (_TopRightHex(), sPoint)
         return _TopRightHex()
      case within (_RightHex(), sPoint)
         return _RightHex()
      case within (_BottomRightHex(), sPoint)
         return _BottomRightHex()
      case within (_BottomLeftHex(), sPoint)
         return _BottomLeftHex()
      default
         return empty
   end switch 
end hex_PointWithin

getprop hexRing_Visible
   return the visible of _LeftHex()
end hexRing_Visible

setprop hexRing_Visible sBoolean
   lock screen
   set the visible of _LeftHex() to sBoolean
   set the visible of _TopLeftHex() to sBoolean
   set the visible of _TopRightHex() to sBoolean
   set the visible of _RightHex() to sBoolean
   set the visible of _BottomRightHex() to sBoolean
   set the visible of _BottomLeftHex() to sBoolean
   unlock screen
end hexRing_Visible

getprop hexCentre_Diameter
   return the width of _CentreHex()
end hexCentre_Diameter

getprop hexRing_Diameter
   return the width of _LeftHex()
end hexRing_Diameter

setprop hexRing_Diameter sWidth
   _SetHexRingDiameter sWidth
end hexRing_Diameter

setprop hex_Animate [eWidth] howSlow
   put the long id of the target into hexObject
   --
   hexObject_Animate hexObject, howSlow, eWidth
end hex_Animate

command hexObject_Animate hexObject, pHowSlow, pEndWidth, pStartWidth
   if pHowSlow is empty then put 2 into pHowSlow
   if pStartWidth is empty then put the width of hexObject into pStartWidth
   if pEndWidth is empty then put 1.2*pStartWidth into pEndWidth
   
   put 10 into stepNum
   put (pEndWidth - pStartWidth)/stepNum into stepValue
   --
   _SetHexRingRect hexObject, pStartWidth
   repeat (stepNum - 2)
      add stepValue to sWidth
      _SetHexRingRect hexObject, pStartWidth
      wait pHowSlow milliseconds
   end repeat
   _SetHexRingRect hexObject, pEndWidth
end hexObject_Animate

command hexRing_Animate sWidth, eWidth
   put 10 into stepNum
   put (eWidth - sWidth)/stepNum into stepValue
   --
   _SetHexRingDiameter sWidth
   repeat (stepNum - 2)
      add stepValue to sWidth
      _SetHexRingDiameter sWidth
   end repeat
   _SetHexRingDiameter eWidth
end hexRing_Animate

private command _SetHexRingDiameter sWidth
   lock screen
   _SetHexRingRect _LeftHex(), sWidth
   _SetHexRingRect _TopLeftHex(), sWidth
   _SetHexRingRect _TopRightHex(), sWidth
   _SetHexRingRect _RightHex(), sWidth
   _SetHexRingRect _BottomRightHex(), sWidth
   _SetHexRingRect _BottomLeftHex(), sWidth
   unlock screen
end _SetHexRingDiameter

command _SetHexRingRect hexObject, sWidth
   put the loc of hexObject into hexLoc
   put rect_LocWidthHeight (hexLoc, sWidth, sWidth) into hexRect
   set the rect of hexObject to hexRect
   set the loc of hexObject to hexLoc
end _SetHexRingRect

command _SetFromEffective
   get the effective points of _BackHex()
   --
   put line 1 of it into rightLoc
   put line 2 of it into bottomRightLoc
   put line 3 of it into bottomLeftLoc
   put line 4 of it into leftLoc
   put line 5 of it into topLeftLoc
   put line 6 of it into topRightLoc
   --
   set the loc of _RightHex() to rightLoc
   set the loc of _TopRightHex() to topRightLoc
   set the loc of _TopLeftHex() to topLeftLoc
   set the loc of _LeftHex() to leftLoc
   set the loc of _BottomLeftHex() to bottomLeftLoc
   set the loc of _BottomRightHex() to bottomRightLoc
end _SetFromEffective

command LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   put the inner_Rect [pRect] of me into innerRect
   put item 3 of innerRect - item 1 of innerRect into iWidth
   put item 4 of innerRect - item 2 of innerRect into iHeight
   put min (iWidth,iHeight) into newHeight
   put rect_GetCentre (pRect) into centreLoc
   -- get rect_LocWidthHeight (centreLoc, newHeight, newHeight)
   
   put newHeight/2 into cHeight
   put rect_LocWidthHeight (centreLoc, cHeight, cHeight) into centreRect
   set the rect of _CentreHex() to centreRect
   
   -- points with + 2 = grc width
   put 344/196 * cHeight into backWidth
   put rect_LocWidthHeight (centreLoc, backWidth, backWidth) into backRect
   set the rect of _BackHex() to backRect
   
   put 0.6 * cHeight into hexRingDiameter
   set the hexRing_Diameter of me to hexRingDiameter
   _SetFromEffective
   
   unlock screen
end LayoutControl

getprop centre_Hex
   return _CentreHex()
end centre_Hex

getprop left_Hex
   return _LeftHex()
end left_Hex

private function _BackHex
   return the long id of graphic "Background" of me
end _BackHex

private function _CentreHex
   return the long id of control "Centre Hexagon" of me
end _CentreHex

private function _LeftHex
   return the long id of control "Left Hexagon" of me
end _LeftHex

private function _RightHex
   return the long id of control "Right Hexagon" of me
end _RightHex

private function _TopLeftHex
   return the long id of control "TopLeft Hexagon" of me
end _TopLeftHex

private function _TopRightHex
   return the long id of control "TopRight Hexagon" of me
end _TopRightHex

private function _BottomLeftHex
   return the long id of control "BottomLeft Hexagon" of me
end _BottomLeftHex

private function _BottomRightHex
   return the long id of control "BottomRight Hexagon" of me
end _BottomRightHex


--> Events
-
on resizeControl
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl


--> Events | Custom
-
on refreshDisplay
   put the rect of me into viewRect
   LayoutControl viewRect
end refreshDisplay


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object

