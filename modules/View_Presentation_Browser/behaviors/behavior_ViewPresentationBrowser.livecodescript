script "behavior_ViewPresentationBrowser"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewPresentationBrowser
type: behavior
version: 0.1


--> Events
-
on dragEnter
   set the dragAction to "link"
   pass dragEnter
end dragEnter

on dragDrop
   get the dragsource
   put the dragData into someUrl
   set the itemdelimiter to ":"
   if item 1 of someUrl is among the items of "http:https" then
      set the browser_Url of me to someUrl
   end if
   pass dragDrop
end dragDrop

on resizeControl
   LayoutControl
end resizeControl

--> Geometry
-
command LayoutControl pRect
   if pRect is empty then put the rect of me into pRect
   set the rect of me to pRect
end LayoutControl


--> Browser | Props
-
getprop browser_URL
   put the browser_View of me into browserView
   put the url of browserView into someUrl
   return someUrl
end browser_URL

setprop browser_URL someUrl
   put the browser_View of me into browserView
   set the url of browserView to someUrl
   return browserView
end browser_URL


--> View | Object
-
getprop browser_View
    return the long id of me
end browser_View
