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

getprop checked_ResizeGraphic [mTarget]
   if the long id of the target is not the long id of me then pass checked_ResizeGraphic
   put the resize_Graphic of mTarget into someBoolean
   return someBoolean
end checked_ResizeGraphic

getprop checked_ConstrainGraphic [mTarget]
   if the long id of the target is not the long id of me then pass checked_ConstrainGraphic
   put the constrain_Graphic of mTarget into someBoolean
   return someBoolean
end checked_ConstrainGraphic

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

getprop personType_Param [mTarget]
   put the person_Type of mTarget into someType
   return someType
end personType_Param

getprop personType_Params [mTarget]
   put the person_Types of mTarget into someTypes
   return someTypes
end personType_Params


--> Global | Image | Masked | Menu
-
on menu_PersonType mTarget, someType
   set the person_Type of mTarget to someType
end menu_PersonType

on menu_SetLabel mTarget
   put the graphic_Label of mTarget into sLabel
   put lcw_Ask ("Seet the label...", sLabel, "Label", mTarget) into sLabel
   --
   set the graphic_Label of mTarget to sLabel
end menu_SetLabel

on menu_BurnImage mTarget
   set the burnt_Image of mTarget to true
end menu_BurnImage

on menu_SizeImage mTarget, someSize
   set the burnt_ImageWidth of mTarget to someSize
end menu_SizeImage

on menu_RestoreImageFile mTarget
   -- dispatch "image_RestoreSettings" to mTarget
   set the burnt_Image of mTarget to false
end menu_RestoreImageFile

on _
end _

on menu_ShowImage mTarget
   put the show_Image of mTarget is false into someBoolean
   set the show_Image of mTarget to someBoolean
end menu_ShowImage

on menu_ShowImageBorder mTarget
   put the show_ImageBorder of mTarget is false into someBoolean
   set the show_ImageBorder of mTarget to someBoolean
end menu_ShowImageBorder

on menu_ResizeGraphic mTarget
   put the resize_Graphic of mTarget is false into someBoolean
   set the resize_Graphic of mTarget to someBoolean
end menu_ResizeGraphic

on menu_ConstrainGraphic mTarget
   put the constrain_Graphic of mTarget is false into someBoolean
   set the constrain_Graphic of mTarget to someBoolean
end menu_ConstrainGraphic

on menu_ResizeQuality mTarget, someQuality
   set the image_ResizeQuality of mTarget to someQuality
end menu_ResizeQuality

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on submenu_Image
   return "Global | Image | Menu"
end submenu_Image

on menu_ShowRounded mTarget
   put the show_Rounded of mTarget is false into someBoolean
   set the show_Rounded of mTarget to someBoolean
end menu_ShowRounded
