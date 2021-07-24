script "behavior_ViewRoughRectangle"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewRoughRectangle
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
private function _GetRoughRect roughHTML
   put lineOffset ("svg.appendChild", roughHTML) into lineNum
   put line lineNum of roughHTML into scriptLine
   put token 5 of scriptLine into rLeft
   put token 7 of scriptLine into rTop
   put token 9 of scriptLine into rRight
   put token 11 of scriptLine into rBottom
   --
   return rLeft,rTop,rRight,rBottom
end _GetRoughRect

private command _SetRoughRect @roughHTML, newRect
   put lineOffset ("svg.appendChild", roughHTML) into lineNum
   --
   put item 1 of newRect into rLeft
   put item 2 of newRect into rTop
   put item 3 of newRect into rRight
   put item 4 of newRect into rBottom
   --
   put rLeft into token 5 of line lineNum of roughHTML
   put rTop into token 7 of line lineNum of roughHTML
   put rRight into token 9 of line lineNum of roughHTML
   put rBottom into token 11 of line lineNum of roughHTML
   --
   return lineNum
end _SetRoughRect

private command _Init
   put _BrowserWidget() into browserWidget
   put scaffold_GetTemplate ("Rough Blue") into roughHTML
   --
   set the browser_HtmlText of browserWidget to roughHTML
   set the browser_Element of browserWidget to "svg"
end _Init

on preOpenControl
   _Init
   pass preOpenControl
end preOpenControl

private function _GetBodyHtml
   put _BrowserWidget() into browserWidget
   put the browser_HtmlText of browserWidget into roughHTML
   --
   put html_GetBody (roughHTML) into bodyHTML
   return bodyHTML
end _GetBodyHtml

private command _SetBodyHtml bodyHTML
   put _BrowserWidget() into browserWidget
   put the browser_HtmlText of browserWidget into roughHTML
   --
   html_SetBody roughHTML, bodyHTML
   --
   set the browser_HtmlText of browserWidget to roughHTML
end _SetBodyHtml

private function _ConstructSvgStyleArray newRect, sBgColour
   if newRect is empty then
      put "100%" into sWidth
      put "100%" into sHeight
   else
      put item 3 of newRect - item 1 of newRect into sWidth
      put item 4 of newRect - item 2 of newRect into sHeight
      put "px" after sWidth
      put "px" after sHeight
   end if
   --
   put "block" into styleArray ["display"]
   put sBgColour into styleArray ["background-color"]
   put sWidth into styleArray ["width"]
   put sHeight into styleArray ["height"]
   --
   return styleArray
end _ConstructSvgStyleArray

private function _ConstructSvgStyle newRect, sBgColour
   local styleArray
   put _ConstructSvgStyleArray (newRect, sBgColour) into svgStyle
   combine svgStyle using ";" and ":"
   return svgStyle
end _ConstructSvgStyle

getprop rough_SvgElement
   put _GetBodyHtml() into bodyHTML
   --
   revXMLDeleteAllTrees
   put revXMLCreateTree (bodyHTML, false, true, false) into treeID
   --
   -- put revXMLTree (treeID, "body", CR, tab, true, -1) into nodeOutline
   -- put scrapeID_GetDivText (treeID, attributeName, attributeValue) into someContent
   -- put revXMLMatchingNode (treeID, "body", "svg", "id", "svg", 2) into svgNode
   -- put revXMLMatchingNode (treeID, "body", "svg", "id", "svg", -1) into svgNode
   put "/body/svg" into svgNode
   put revXMLAttributes (treeID, svgNode, tab, CR) into svgAttributeArray
   split svgAttributeArray using CR and tab
   --
   put "/body/script" into scriptNode
   put revXMLNodeContents (treeID, scriptNode) into scriptContents
   --
   revXMLDeleteTree treeID
   --
   put svgAttributeArray ["id"] into svgNodeID
   put svgAttributeArray ["style"] into styleArray
   split styleArray using ";"and ":"
   --
   combine styleArray using CR and tab
   return styleArray
   
   put scrape_GetDiv (bodyHTML, "id", "svg", false) into svgElement
   return svgElement
end rough_SvgElement


--> Props
-
getprop rough_HTML
   put _BrowserWidget() into browserWidget
   put the browser_HtmlText of browserWidget into roughHTML
   return roughHTML
end rough_HTML

setprop rough_HTML roughHTML
   put _BrowserWidget() into browserWidget
   set the browser_HtmlText of browserWidget to roughHTML
   return browserWidget
end rough_HTML

setprop rough_CanvasRect [sBgColour] newRect
   put _GetBodyHtml() into bodyHTML
   put "/body/svg" into svgNode
   --
   if sBgColour is empty then put "yellow" into sBgColour
   put _ConstructSvgStyle (newRect, sBgColour) into newStyle
   --
   put revXMLCreateTree (bodyHTML, false, true, false) into treeID
   revXMLSetAttribute treeID, svgNode, "style", newStyle
   put revXMLText (treeID ) into newBodyHTML
   delete line 1 of newBodyHTML -- the XML header
   revXMLDeleteTree treeID
   --
   _SetBodyHtml newBodyHTML
   return newBodyHTML
end rough_CanvasRect

getprop graphic_Rect
   put _GraphicObject() into gObject
   put the rect of gObject into gRect
   return gRect
end graphic_Rect

getprop rough_Rect
   put _BrowserWidget() into browserWidget
   put the browser_HtmlText of browserWidget into roughHTML
   --
   put _GetRoughRect (roughHTML) into rRect
   return rRect
end rough_Rect

setprop rough_Rect sRect
   put _BrowserWidget() into browserWidget
   put the browser_HtmlText of browserWidget into roughHTML
   --
   _SetRoughRect roughHTML, sRect
   --
   lock screen
   set the show_Browser of me to true
   set the browser_HtmlText of browserWidget to roughHTML
   set the browser_Element of browserWidget to "svg"
   unlock screen
   --
   return roughHTML
end rough_Rect

getprop fill_Colour
   put _GraphicObject() into gObject
   put the backgroundcolor of gObject into sColour
   return sColour
end fill_Colour

setprop fill_Colour sColour
   put _GraphicObject() into gObject
   set the backgroundcolor of gObject to sColour
   set the opaque of gObject to true
end fill_Colour

getprop show_Browser
   put the visible of _BrowserWidget() into sBoolean
   return sBoolean
end show_Browser

setprop show_Browser sBoolean
   set the visible of _BrowserWidget() to sBoolean
end show_Browser


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

command LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   put the inner_Rect [pRect] of me into iRect
   
   -- do your geometry here
   set the rect of _GraphicObject() to iRect
   set the rect of _BrowserWidget() to iRect
   unlock screen
end LayoutControl


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object

private function _GraphicObject
   return the long id of grc 1 of me
end _GraphicObject

private function _BrowserWidget
   return the long id of control "Rough Browser" of me
end _BrowserWidget
