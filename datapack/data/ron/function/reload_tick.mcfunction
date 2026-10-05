# cancel if the rifle is put away
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{ron_weapon:"rifle"}] run return run scoreboard players set @s ron.reload 0
scoreboard players remove @s ron.reload 1
execute if score @s ron.reload matches 0 run function ron:reload_done
