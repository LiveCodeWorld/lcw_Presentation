script "lib_Ball"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Ball
type: library
version: 0.1

/*
This stack is all about creating and animating particles, whichh for now are just small balls.
We look to animate them asynchronously.
*/

--> Variables
-
local LocalArray


--> Working on
-
getprop ball_Objects
   put the card_Object of the target into cObject
   put the top_Controls of cObject into aGraphics
   filter aGraphics with "graphic *"
   -- put the number of graphics of cObject into maxNum
   repeat for each line aGraphic in aGraphics
      if the short name of aGraphic = "ballName" then
         put aGraphic & CR after ballObjects
      end if
   end repeat
   delete char -1 of ballObjects
   return ballObjects 
end ball_Objects


--> Props
-
getprop ball_Stopped
   return LocalArray ["ball_Stopped"] is true
end ball_Stopped

setprop ball_Stopped sBoolean
   put sBoolean into LocalArray ["ball_Stopped"]
end ball_Stopped

setprop ball_Path [speedDiameterColour] pathPoints
   put item 1 of speedDiameterColour into pSpeed
   put item 2 of speedDiameterColour into pBallDiameter
   put item 3 of speedDiameterColour into pColour
   if pSpeed is empty then put 1 into pSpeed
   --
   put line 1 of pathPoints into pathStart
   _SetTemplategraphic pathStart, pColour, pBallDiameter
   --
   if word 1 of the target = "group" then
      create graphic ballName in the target
   else
      create graphic ballName
   end if
   put it into newBall
   set the layermode of newBall to "dynamic"
   --
   set the movepolygonal ["currentpoints"] of newBall to pathPoints
   set the movepolygonal ["step"] of newBall to pSpeed
   --
   return newBall
end ball_Path

setprop ball_Speed bSpeed
   -- should check ballgraphic
   if bSpeed is empty then put 1 into bSpeed
   put the long id of the target into ballGraphic
   --
   set the movepolygonal ["step"] of ballGraphic to pSpeed
   return ballGraphic
end ball_Speed


--> Ball
-
on ball_DeleteAll pCardObject
   if exists (pCardObject) is false then
      put the card_Object of the target into pCardObject
   end if
   put the ball_Objects of pCardObject into ballObjects
   --
   repeat for each line ballObject in ballObjects
      delete ballObject
   end repeat
end ball_DeleteAll

on ball_PathAnimate ballGraphic
   if the movePolygonal["moveDone"] of ballGraphic is true then
      put the movePolygonal ["endpoint"] of ballGraphic into endpoint
      set the loc of ballGraphic to endpoint
      set the movePolygonal ["moveDone"] of ballGraphic to false
      --
      send "delete ballGraphic" to ballGraphic in 2 ticks
   else if the ball_Stopped of ballGraphic is not true then
      send "movePolygonal" to ballGraphic
      send "ball_PathAnimate ballGraphic" to ballGraphic in 5 milliseconds
   end if 
end ball_PathAnimate

command ball_Create pSpeed, pColour
   if pSpeed is empty then put 1 into pSpeed
   --
   put the long id of grc "Path" into pathGraphic
   put the points of pathGraphic into pathPoints
   put line 1 of pathPoints into pathStart
   --
   _SetTemplategraphic pathStart, pColour
   --
   create graphic ballName
   put it into newBall
   set the layermode of newBall to "dynamic"
   --
   set the behavior of newBall to the long id of btn "Ball Behavior"
   set the movepolygonal ["currentpoints"] of newBall to pathPoints
   set the movepolygonal ["step"] of newBall to pSpeed
   --
   return newBall
end ball_Create


--> Ball | lib_Flatworld
-
on ball_Animate someNode, dof, arrivedMessage
   if arrivedMessage is empty then put "strobeNode" into arrivedMessage
   put arrivedMessage into p2p_Message
   put the front_ArrowLinks of someNode into frontLinks
   repeat for each line someArrow in frontLinks
      ball_AnimateArrow someArrow, dof
   end repeat
end ball_Animate

on ball_AnimateArrow arrowObject, dof
   put the link_Object of arrowObject into dObject
   if the visible of dObject is true then
      put the points of arrowObject into frontPoints
      put line 1 of frontPoints into fromPoint
      put line 2 of frontPoints into toPoint
      
      put ball_FlatCreate (fromPoint, arrowObject, "") into ballObject
      
      set the degrees_OfFreedom of ballObject to dof
      set the destination_Object of ballObject to dObject
      
      put 30 into lastStepNum
      set the last_StepNum of ballObject to lastStepNum
      
      get loc_TranslationVector(fromPoint, toPoint, xVector, yVector)
      
      put xVector/lastStepNum into xStep
      put yVector/lastStepNum into yStep
      set the x_Step of ballObject to xStep
      set the y_Step of ballObject to yStep
      
      set the this_stepNum of ballObject to 1
      set the last_loc of ballObject to fromPoint
      ball_Move ballObject
   end if
end ball_AnimateArrow

function ball_FlatCreate ballLoc, frontLink, ballStyle
   switch ballStyle
      case "big"
         break
      default
         put "772,256,783,267" into smallRect
   end switch
   put the layer of frontLink into arrowLayer
   
   lock screen
   create graphic "Ball 2"
   put it into createdGraphic
   
   if ballLoc is empty then put the loc of createdGraphic into ballLoc
   set the style of createdGraphic to "oval"
   set the filled of createdGraphic to true
   set the linesize of createdGraphic to 1
   set the rect of createdGraphic to smallRect
   set the loc of createdGraphic to ballLoc
   
   put the relayergroupedcontrols into oStiffLayer
   set the relayergroupedcontrols to true
   set the layer of createdGraphic to (arrowLayer + 1)
   set the relayergroupedcontrols to oStiffLayer
   choose browse tool
   unlock screen
   return createdGraphic
end ball_FlatCreate

on ball_Move ballObject
   -- was "moveBall" from Flatworld
   put the this_stepNum of ballObject into stepNum
   put the last_stepNum of ballObject into lastStepNum
   if stepNum = lastStepNum then
      put the destination_Object of ballObject into dObject
      put the degrees_OfFreedom of ballObject into dof
      delete ballObject
      
      if dof > 1 then
         subtract 1 from dof
         ball_Animate dObject, dof
      end if
      send p2p_Message to dObject
      return empty
   end if
   
   put the x_Step of ballObject into xStep
   put the y_Step of ballObject into yStep
   
   put the last_loc of ballObject into lastLoc
   put loc_TranslateByVector(lastLoc, xStep, yStep) into newLoc
   set the loc of ballObject to newLoc
   
   set the last_loc of ballObject to newLoc
   set the this_stepNum of ballObject to (stepNum + 1)
   send "ball_Move ballObject" to me in 3 ticks
end ball_Move
 
 
--> Private
-
private command _SetTemplategraphic pathStart, pColour, pBallDiameter
   if pBallDiameter is empty then put 20 into pBallDiameter
   if pColour is empty then put colour_GetRandom() into pColour
   set the backgroundcolor of the templategraphic to pColour
   --
   set the style of the templategraphic to "oval"
   set the width of the templategraphic to pBallDiameter
   set the height of the templategraphic to pBallDiameter
   set the location of the templategraphic to pathStart
   set the opaque of the templategraphic to "true"
   --
   return the properties of templategraphic
end _SetTemplategraphic


--> Deps
-
private function colour_GetRandom
   -- was "randomColour"
   put random(255) into item 1 of someColour
   put random(255) into item 2 of someColour
   put random(255) into item 3 of someColour
   return someColour
end colour_GetRandom
