script "lib_Animation"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: lib_Animation
type: library
version: 0.1

/*Some help*/


--> Working on
-


--> Animation
-
function animation_EngineIsOn
   put "animationEngine" is among the lines of the stacksinuse into isON
   return isOn
end animation_EngineIsOn

command animation_EngineStart someBoolean
   put env_ConstructHomePath ("animationEngine") into homePath
   if exists (stack homePath) is false then return empty
   --
   if someBoolean is true then
      stop using stack homePath
   else
      start using stack homePath
   end if
   return homePath
end animation_EngineStart


--> Deps
-
