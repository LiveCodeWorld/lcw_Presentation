script "lib_Animation"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Animation
type: library
version: 0.1

/*
Some utility scripts to set up and interact with AnimationEngine
*/


--> Working on
-
-- on libraryStack
if ae_IsActive() is true then pass libraryStack
--
ae_Start true
put the result into homePath
go to stack homePath
end libraryStack

function ae_IsActive
   -- was "animation_EngineIsOn"
   put "animationEngine" is among the lines of the stacksinuse into sBloolean
   return sBloolean
end ae_IsActive



--> Animation
-
command ae_Start someBoolean
   put env_ConstructHomePath ("animationEngine") into homePath
   if exists (stack homePath) is false then return empty
   --
   if someBoolean is true then
      start using stack homePath
   else
      stop using stack homePath
   end if
   return homePath
end ae_Start


--> Deps
-
