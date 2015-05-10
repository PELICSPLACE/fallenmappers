# automapper.cmd version 3.142
# ---------------
# last changed: 10 May, 2015 by ~PELIC
# ---------------
# Added handler for attempting to enter closed shops from Shroomism
# Added web retry support from Dasffion
# Added caravan support from Jailwatch
# Added swimming retry from Jailwatch
# Added search and objsearch handling from BakedMage
# Added enhanced climbing and muck support from BakedMage
# VTCifer - Added "room" type movement - used for loong command strings that need to be done in one room
# VTCifer - Added "ice" type movement  - will collect rocks when needs to slow down
# VTCifer - Added more matches for muck (black apes)
# Fixed timings
# Added "treasure map" mode from Isharon
# Replaced "tattered map" with "map" (because the adjective varies)
# VTCifer - Added additional catches for roots
# VTCifer - Added additional catch for Reaver mine -> Non-standard stand up message.  Fixed minor issue with RT and roots.
# 2013-07-24 - Funk - Merged back in previous changes + updates
# Added ice road support from Mhaeric
# Added retry on still recovering from last attack/cast from Funk
# Added retry on stun from Funk
# 24 July, 2013 by ~Funk - added waiting for the galley to show up - var move_BOAT ^The galley has just left|^You look around in vain for the galley
# 24 July, 2013 by ~Funk - added "^You'll need to stand up first" to move_STAND var
# 24 July, 2013 by ~Funk - added "^You almost make it to the top" to climb_FAIL
# 24 July, 2013 by ~Funk - added "^You find yourself stuck in the mud" to move_MUCK var
# 24 July, 2013 by ~Funk - added support for stowing to climb - var move_STOW ^You'll need to free up your hands first|^Not while carrying something in your hands
# PELIC - added missing match for stowing to climb, merged ice logic (minus collecting) from upstream
#
# Related macros
# ---------------
# Add the following macro for toggling powerwalking:
# #macro {P, Control} {#if {$powerwalk = 1}{#var powerwalk 0;#echo *** Powerwalking off}{#var powerwalk 1;#echo *** Powerwalking on}}
#
# Add the following macro for toggling Caravans:
# #macro {C, Control} {#if {$caravan = 1}{#var caravan 0;#echo *** Caravan Following off}{#var caravan 1;#echo *** Caravan Following on}}
#
# Related aliases
# ---------------
# Add the following aliases for toggling dragging:
# #alias {dragoff} {#var drag 0;#var drag.target}
# #alias {dragon} {#var drag 1;#var drag.target $0}
# Add the following aliases for toggling treasure map mode:
# #alias {mapoff} {#var mapwalk 0}
# #alias {mapon} {#var mapwalk 1}
#
# Type ahead declaration
# ---------------
# The following will use a global to set it by character.  This helps when you have both premium and standard accounts.
# Standard Account = 1, Premium Account = 2, LTB Premium = 3
# #var automapper.typeahead 1
#
# debuglevel 10
ABSOLUTE_TOP:
     if !def(automapper.typeahead) then var typeahead 1
     else var typeahead $automapper.typeahead
     # ---------------
     if ($mapwalk) then
          {
               send get my map
               waitforre ^You get|^You are already holding
          }
     var startingStam $stamina
     var failcounter 0
     var depth 0
     var movewait 0
     var closed 0
     var slow_on_ice 0
     var move_OK ^Obvious|^It's pitch dark and you can't see a thing\!
     var move_FAIL ^You can't go there|^What were you referring to|^I could not find what you were referring to\.|^You can't sneak in that direction
     var move_RETRY ^\.\.\.wait|^Sorry\,|^You're still recovering from your recent cast|^You're still recovering from your recent attack|^You are still stunned
     var move_RETREAT ^You are engaged to|^You try to move\, but you're engaged|^While in combat|^You can't do that while engaged
     var move_WEB ^You can't do that while entangled in a web
     var move_WAIT ^You continue climbing|^You begin climbing|^You really should concentrate on your journey|^You step onto a massive stairway|^You squeeze through the brambles
     var move_END_DELAY ^You reach|you reach\.\.\.|^Just when it seems
     var move_STAND ^You must be standing to do that|^You can't do that while (?:lying down|kneeling|sitting)|^Running heedlessly over the rough terrain\, you trip over an exposed root and land face first in the dirt\.|^Stand up first\.|^You'll need to stand up first|^You must stand first\.|a particularly sturdy one finally brings you to your knees\.|You try to roll through the fall but end up on your back\.
     var move_NO_SNEAK ^You can't do that here|^In which direction are you trying to sneak|^Sneaking is an inherently stealthy|^You can't sneak that way|^You can't sneak in that direction
     var move_GO ^Please rephrase that command
     var move_MUCK ^You fall into the .+ with a loud \*SPLUT\*|^You slip in .+ and fall flat on your back\!|^The .+ holds you tightly\, preventing you from making much headway\.|^You make no progress in the mud|^You struggle forward\, managing a few steps before ultimately falling short of your goal\.|^Like a blind\, lame duck|^You find yourself stuck in the mud
     var climb_FAIL ^Trying to judge the climb\, you peer over the edge\.\s*A wave of dizziness hits you\, and you back away from .+\.|^You start down .+\, but you find it hard going\.\s*Rather than risking a fall\, you make your way back up\.|^You attempt to climb down .+\, but you can't seem to find purchase\.|^You pick your way up .+\, but reach a point where your footing is questionable\.\s*Reluctantly\, you climb back down\.|^You make your way up .+\.\s*Partway up\, you make the mistake of looking down\.\s*Struck by vertigo\, you cling to .+ for a few moments\, then slowly climb back down\.|^You approach .+\, but the steepness is intimidating\.$|^You start up .+, but slip after a few feet and fall to the ground\!\s*You are unharmed but feel foolish\.|^You almost make it to the top
     var move_CLOSED ^The door is locked up tightly for the night|^You stop as you realize that the|shop is closed for the night|^Bonk\!\s*You smash your nose\.
     var swim_FAIL ^You struggle|^You work|^You slap|^You flounder
     var move_DRAWBRIDGE ^The guard yells\, \"Lower the bridge|^The guard says\, \"You'll have to wait|^A guard yells\, \"Hey|^The guard yells\, \"Hey
     var move_ROPE.BRIDGE ^.*is already on the rope\.
     var move_BOAT ^The galley has just left|^You look around in vain for the galley
     var move_STOW ^You'll need to free up your hands first|^Not while carrying something in your hands|^You need to empty your hands before you can attempt that\.
     # ---------------
     gosub actions
     goto loop
     # ---------------
actions:
     action var current_path %0 when ^You go
     action put #var powerwalk 0 when eval (($powerwalk = 1) && ($Power_Perceive.LearningRate = 34))
     action var slow_on_ice 1 when ^You had better slow down! The ice is far too treacherous
     action var slow_on_ice 1 when ^At the speed you are traveling, you are going to slip and fall sooner or later
     action (mapper) if %movewait = 0 then shift;if %movewait = 0 then math depth subtract 1;if len("%2") > 0 then echo Next move: %1 when %move_OK
     action (mapper) goto move.failed when %move_FAIL
     action (mapper) goto move.retry when %move_RETRY|%move_WEB
     action (mapper) goto move.stand when %move_STAND
     action (mapper) var movewait 1;goto move.wait when %move_WAIT
     action (mapper) goto move.retreat when %move_RETREAT
     action (mapper) var movewait 0 when %move_END_DELAY

     action (mapper) var closed 1;goto move.closed when %move_CLOSED
     action (mapper) goto move.nosneak when %move_NO_SNEAK
     action (mapper) goto move.go when %move_GO
     action (mapper) goto move.muck when %move_MUCK
     action (mapper) echo Will re-attempt climb in 5 seconds...;send 5 $lastcommand when ^All this climbing back and forth is getting a bit tiresome\. You need to rest a bit before you continue\.
     action (mapper) goto move.retry when %swim_FAIL
     action (mapper) goto move.drawbridge when %move_DRAWBRIDGE
     action (mapper) goto move.rope.bridge when %move_ROPE.BRIDGE
     action (mapper) goto move.boat when %move_BOAT
     action (mapper) goto move.stow when %move_STOW
     return
loop:
     gosub wave
     pause 0.1
     goto loop
wave:
     if (%depth > 0) then return
     if_1 goto wave_do
     goto done
wave_do:
     var depth 0
     if_1 gosub move %1
     if %typeahead < 1 then return
     if_2 gosub move %2
     if %typeahead < 2 then return
     if_3 gosub move %3
     if %typeahead < 3 then return
     if_4 gosub move %4
     if %typeahead < 4 then return
     if_5 gosub move %5
     return
done:
     pause 0.5
     put #parse YOU HAVE ARRIVED!
     exit
move:
     math depth add 1
     var movement $0
     var type real
     if $drag = 1 then
          {
               var type drag
               if matchre("%movement", "(swim|climb|web|muck|rt|wait|stairs|slow|go|script|ice|room) ([\S ]+)") then
                    {
                         var movement drag $drag.target $2
                    }
               else
                    {
                         var movement drag $drag.target %movement
                    }
          }
     else
          {
               if ($hidden) then
                    {
                         var type sneak
                         if !matchre("%movement", "climb|go gate") then
                              {
                                   if matchre("%movement", "go ([\S ]+)") then
                                        {
                                             var movement sneak $1
                                        }
                                   else
                                        {
                                             var movement sneak %movement
                                        }
                              }
                    }
               else
                    {
                         if "%type" = "real" then
                              {
                                   if matchre("%movement", "^(search|swim|climb|web|muck|rt|wait|slow|drag|script|ice|room) ") then
                                        {
                                             var type $1
                                             eval movement replacere("%movement", "^(search|swim|web|muck|rt|wait|slow|script|ice|room) ", "")
                                        }
                                   if matchre("%movement", "^(objsearch) (\S+) (.+)") then
                                        {
                                             var type objsearch
                                             var searchObj $2
                                             var movement $3
                                        }
                              }
                    }
          }
     goto move.%type
move.real:
     send %movement
     goto return
move.power:
     if (%depth > 1) then waiteval (1 = %depth)
     send %movement
     nextroom
     pause 0.1
     matchre MOVE_DONE ^Roundtime\:?|^\[Roundtime\:?|^\(Roundtime\:?
     matchre MOVE_DONE ^Something in the area is interfering
     send perceive
     matchwait
move.room:
     if (%depth > 1) then waiteval (1 = %depth)
     send %movement
     nextroom
     pause 0.1
     goto MOVE_DONE
move.stow:
     send stow left
     wait
     pause 0.1
     send stow right
     wait
     pause 0.1
     send %movement
     pause 0.1
     goto MOVE_DONE
move.boat:
     matchre move.boat.arrived ^The galley (\w*) glides into the dock
     matchwait 60
     send look
     goto move.boat
move.boat.arrived:
     send %movement
     pause 0.1
     goto MOVE_DONE
move.ice:
     if (%depth > 1) then waiteval (1 = %depth)
	if (%slow_on_ice) then pause 15
     send %movement
     goto MOVE_DONE
move.sneak:
     if (%depth > 1) then waiteval (1 = %depth)
     if (!$hidden) then
          {
               pause 0.1
               send hide
               pause 0.1
          }
     pause 0.1
     send sneak %movement
     pause 0.1
     pause 0.1
     goto MOVE_DONE
move.drag:
move.swim:
move.rt:
     if (%depth > 1) then waiteval (1 = %depth)
     send %movement
     pause 0.1
     pause 0.1
     goto MOVE_DONE
move.web:
     if ($webbed) then waiteval (!$webbed)
     pause 0.1
     send %movement
     pause 0.1
     goto MOVE_DONE
move.muck:
     action (mapper) off
     pause
     if (!$standing) then send stand
     matchre move.muck ^You struggle to dig|^Maybe you can reach better that way\, but you'll need to stand up for that to really do you any good\.
     matchre move.muck.done ^You manage to dig|^You will have to kneel closer|^You stand back up.|^You fruitlessly dig
     send dig
     matchwait
move.muck.done:
     action (mapper) on
     goto return.clear
move.slow:
     pause 3
     goto move.real
move.climb:
     if (%depth > 1) then waiteval (1 = %depth)
     matchre MOVE_DONE %move_OK
     matchre MOVE_CLIMB_WITH_APP %climb_FAIL
     send %movement
     matchwait
MOVE_CLIMB_WITH_APP:
     eval climbobject replacere("%movement", "climb ", "")
     pause 0.1
     send appraise %climbobject quick
     MOVE_CLIMB_WITH_APP_1:
     pause 0.1
     pause 0.1
     matchre MOVE_CLIMB_WITH_APP_1 ^\.\.\.wait|^Sorry\,
     matchre MOVE_DONE %move_OK
     matchre MOVE_CLIMB_WITH_ROPE %climb_FAIL
     send %movement
     matchwait
MOVE_CLIMB_WITH_ROPE:
     action (mapper) off
     if !contains("$righthand $lefthand", "heavy rope") then
          {
               pause 0.1
               send get my heavy rope
               wait
               pause 0.1
          }
     if contains("$righthand $lefthand", "heavy rope") then
          {
               send uncoil my heavy rope
               wait
               pause 0.1
          }
     action (mapper) on
     if !contains("$righthand $lefthand", "heavy rope") then goto move.climb
     MOVE_CLIMB_WITH_ROPE_1:
     matchre MOVE_CLIMB_WITH_ROPE_1 ^\.\.\.wait|^Sorry\,
     matchre MOVE_CLIMB_WITH_APP_AND_ROPE %climb_FAIL
     matchre STOW_ROPE %move_OK
     send %movement with my rope
     matchwait
MOVE_CLIMB_WITH_APP_AND_ROPE:
     eval climbobject replacere("%movement", "climb ", "")
     send appraise %climbobject quick
     MOVE_CLIMB_WITH_APP_AND_ROPE_1:
     pause 0.1
     pause 0.1
     matchre MOVE_CLIMB_WITH_APP_AND_ROPE_1 ^\.\.\.wait|^Sorry\,
     matchre MOVE_CLIMB_WITH_APP_AND_ROPE_1 %climb_FAIL
     matchre STOW_ROPE %move_OK
     send %movement with my rope
     matchwait
STOW_ROPE:
     if contains("$righthand $lefthand", "heavy rope") then
          {
               send coil my heavy rope
               wait
               pause 0.1
               send stow my heavy rope
               wait
               pause 0.1
          }
     goto MOVE_DONE
move.search:
     send search
     wait
     pause 0.1
     pause 0.1
     send %movement
     pause 0.1
     pause 0.1
     goto MOVE_DONE
move.objsearch:
     send search %searchObj
     wait
     pause 0.1
     pause 0.1
     send %movement
     pause 0.1
     pause 0.1
     goto MOVE_DONE
move.script:
     if (%depth > 1) then waiteval (1 = %depth)
     action (mapper) off
     match move.script.done MOVE SUCCESSFUL
     match move.failed MOVE FAILED
     send .%movement
     matchwait
move.script.done:
     shift
     math depth subtract 1
     if len("%2") > 0 then echo Next move: %2
     action (mapper) on
     goto MOVE_DONE
move.pause:
     send %movement
     pause
     goto MOVE_DONE
move.stairs:
move.wait:
     if (%movewait) then
          {
               matchre MOVE_DONE ^You reach|you reach|^Just when it seems
               matchwait
          }
     goto MOVE_DONE
move.stand:
     action (mapper) off
     pause 0.1
     pause 0.1
     matchre move.stand %move_RETRY|^Roundtime
     matchre return.clear ^You stand back up
     matchre return.clear ^You are already standing
     send stand
     matchwait
move.retreat:
     action (mapper) off
     if (!$standing) then send stand
     pause 0.1
     if ($hidden) then send unhide
     pause 0.1
     pause 0.1
     matchre move.retreat %move_RETRY|^Roundtime
     matchre move.retreat.done ^You retreat from combat|^You sneak back out of combat
     matchre move.retreat.done ^You are already as far away as you can get
     put -retreat;-retreat
     matchwait
move.retreat.done:
     action (mapper) on
     goto return.clear
move.go:
     send go %movement
     goto MOVE_DONE
move.nosneak:
     if (%closed) then goto move.closed
     eval movement replacere("%movement", "sneak ", "")
     send %movement
     goto MOVE_DONE
move.drawbridge:
     waitforre ^Loose chains clank as the drawbridge settles on the ground with a solid thud\.
     send %movement
     goto MOVE_DONE
move.rope.bridge:
     action instant put -retreat;-retreat when melee range|pole weapon range
     waitforre finally arriving|finally reaching
     action remove melee range|pole weapon range
     send %movement
     goto MOVE_DONE
move.retry:
     echo
     echo *** Retry movement
     echo
     if ($webbed) then waiteval (!$webbed)
     pause 0.1
     goto return.clear
move.closed:
     echo
     echo ********************************
     echo SHOP IS CLOSED FOR THE NIGHT!
     echo ********************************
     echo
     put #parse SHOP CLOSED
     put #parse SHOP CLOSED|
     exit
move.failed:
     # evalmath failcounter %failcounter + 1
     # if %failcounter > 4 then
          # {
               # put #parse AUTOMAPPER MOVEMENT FAILED!
               # put #flash
               # exit
          # }
     # echo
     # echo ********************************
     # echo MOVE FAILED - Type: %type | Movement: %movement | Depth: %depth
     # echo Remaining Path: %0
     # var remaining_path %0
     # eval remaining_path replace ("%0", " ", "|")
     # echo %remaining_path(1)
     # echo %remaining_path(2)
     # echo RETRYING Movement...%failcounter / 5 Tries.
     # echo ********************************
     pause 0.1
     put #parse MOVE FAILED!
     put #parse AUTOMAPPER MOVEMENT FAILED!
     exit
     # if %failcounter > 3 then
     # {
          # echo [Trying: go %remaining_path(2) due to possible movement overload]
          # send go %remaining_path(2)
     # }
     # put #parse MOVE FAILED
     # if %type = "search" then send %type
     # pause
     # echo [Moving: %movement]
     # send %movement
     # matchwait 5
end_retry:
     pause
     goto return.clear
caravan:
     waitforre ^Your .*\, following you\.
     gosub clear
     goto loop
POWERWALK:
     pause 0.1
     matchre POWERWALK ^\.\.\.wait|^Sorry\,
     matchre POWERWALK.DONE ^Roundtime\:?|^\[Roundtime\:?|^\(Roundtime\:?
     matchre POWERWALK.DONE ^Something in the area is interfering
     send perceive
     matchwait
POWERWALK.DONE:
     gosub clear
     pause 0.1
     if ($Attunement.LearningRate = 34) then put #tvar powerwalk 0
     goto loop
mapwalk:
     pause 0.1
     put study my map
     waitforre ^The map has a large \'X\' marked in the middle of it
     gosub clear
     goto loop
return.clear:
     action (mapper) on
     var depth 0
     gosub clear
     pause 0.1
     goto loop
MOVE_DONE:
     if $caravan = 1 then goto caravan
     if $powerwalk = 1 then goto powerwalk
     if $mapwalk = 1 then goto mapwalk
     gosub clear
     pause 0.1
     goto loop
return:
     if $caravan = 1 then goto caravan
     if $powerwalk = 1 then goto powerwalk
     if $mapwalk = 1 then goto mapwalk
     var movewait 0
     pause 0.1
     return
#### EOF