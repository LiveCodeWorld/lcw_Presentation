script "Global | Image | Masked | Menu"
--> MetaData
-
license: GPLv3
name: Global | Image | Masked | Menu
type: controller
version: 0.1


--> Menu | Props
-
getprop sizeImage_Param [mTarget]
   put the burnt_ImageWidth of mTarget into someSize
   put the formatted_ImageWidth of mTarget into fWidth
   if someSize = fWidth then 
      return "full"
   else
      return someSize
   end if
end sizeImage_Param

getprop sizeImage_Params
   return "full,-,50,100,150,200,250,300,350,400"
end sizeImage_Params

getprop resizeQuality_Param [mTarget]
   put the image_ResizeQuality of mTarget into someQuality
   return someQuality
end resizeQuality_Param

getprop resizeQuality_Params
   return "normal,good,best"
end resizeQuality_Params

getprop checked_ShowImage [mTarget]
   put the show_Image of mTarget into someBoolean
   return someBoolean
end checked_ShowImage

getprop checked_ShowRounded [mTarget]
   put the show_Rounded of mTarget into someBoolean
   return someBoolean
end checked_ShowRounded

getprop checked_ShowImageBorder [mTarget]
   put the show_ImageBorder of mTarget into someBoolean
   return someBoolean
end checked_ShowImageBorder

-- getprop burn_Image [mTarget]
return the burnt_Image of mTarget
end burn_Image

getprop resize_Graphic [mTarget]
   if the long id of the target is not the long id of me then pass resize_Graphic
   put the resize_Graphic of mTarget into someBoolean
   return someBoolean
end resize_Graphic

getprop constrain_Graphic [mTarget]
   if the long id of the target is not the long id of me then pass constrain_Graphic
   put the constrain_Graphic of mTarget into someBoolean
   return someBoolean
end constrain_Graphic

getprop disabled_ResizeQuality [mTarget]
   if the burnt_Image of mTarget is true then return true
   
   put the resize_Graphic of mTarget into canResize
   if canResize is true then
      return false
   else
      return true
   end if
end disabled_ResizeQuality

getprop disabled_BurnImage [mTarget]
   put the burnt_Image of mTarget into isBurnt
   if isBurnt is true then
      return true
   else
      return false
   end if
end disabled_BurnImage

getprop disabled_RestoreImageFile [mTarget]
   put the burnt_Image of mTarget into isBurnt
   if isBurnt is true then
      return false
   else
      return true
   end if
end disabled_RestoreImageFile

getprop personType_Prop [mTarget]
   put the person_Type of mTarget into someType
   return someType
end personType_Prop

getprop personType_Props [mTarget]
   put the person_Types of mTarget into someTypes
   return someTypes
end personType_Props


--> Global | Image | Masked | Menu
-
on menu_PersonType mTarget, someType
   set the person_Type of mTarget to someType
end menu_PersonType

on _
end _

on menu_BurnImage mTarget
   set the burnt_Image of mTarget to true
end menu_BurnImage

-- on menu_BurnImageTo mTarget, someSize
   set the burnt_Image [someSize] of mTarget to true
end menu_BurnImageTo

on menu_SizeImage mTarget, someSize
   set the burnt_ImageWidth of mTarget to someSize
end menu_SizeImage

on menu_RestoreImageFile mTarget
   -- dispatch "image_RestoreSettings" to mTarget
   set the burnt_Image of mTarget to false
end menu_RestoreImageFile

on menu_ChooseImage mTarget
   answer file "Select an image..."
   if it is empty then exit to top
   
   set the image_File of mTarget to it
   set the image_ResizeQuality of mTarget to "best"
end menu_ChooseImage

on _
end _

on menu_ShowImage mTarget, someBoolean
   set the show_Image of mTarget to someBoolean
end menu_ShowImage

on menu_ShowImageBorder mTarget, someBoolean
   set the show_ImageBorder of mTarget to someBoolean
end menu_ShowImageBorder

on menu_ResizeGraphic mTarget, someBoolean
   set the resize_Graphic of mTarget to someBoolean
end menu_ResizeGraphic

on menu_ResizeQuality mTarget, someQuality
   set the image_ResizeQuality of mTarget to someQuality
end menu_ResizeQuality

on menu_ConstrainGraphic mTarget, someBoolean
   set the constrain_Graphic of mTarget to someBoolean
end menu_ConstrainGraphic

on _
end _

on submenu_Image
   return "Global | Image | Menu"
end submenu_Image


on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_ShowRounded mTarget, someBoolean
   set the show_Rounded of mTarget to someBoolean
end menu_ShowRounded
