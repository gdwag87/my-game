# one bullet: ammo, sound, recoil, raycast. Runs as/at the shooter.
scoreboard players remove @s ron.ammo 1
function ron:gen/snd_fire
tag @s add ron.shooter
scoreboard players set #hit ron.tmp 0
scoreboard players operation #range ron.tmp = #range_steps ron.const
# start at the eyes, then drop the anchor so ^ steps don't re-add the eye offset
execute anchored eyes positioned ^ ^ ^ anchored feet positioned ^ ^ ^0.5 run function ron:ray/step
tag @s remove ron.shooter
# recoil (pitch from the weapons sheet)
function ron:gen/recoil
