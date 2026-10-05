# new players start with a full magazine
execute as @a unless score @s ron.ammo matches -2147483648..2147483647 run scoreboard players operation @s ron.ammo = #mag_size ron.const
# right-click
execute as @a[scores={ron.use=1..}] at @s run function ron:trigger
# timers
execute as @a[scores={ron.reload=1..}] at @s run function ron:reload_tick
execute as @a[scores={ron.burst=1..}] at @s run function ron:burst_tick
scoreboard players remove @a[scores={ron.cd=1..}] ron.cd 1
# HUD while holding the rifle
execute as @a if items entity @s weapon.mainhand *[minecraft:custom_data~{ron_weapon:"rifle"}] run function ron:hud
