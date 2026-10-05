# burst of 3: counter 5 -> 0, extra rounds at 3 and 1
scoreboard players remove @s ron.burst 1
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{ron_weapon:"rifle"}] run return run scoreboard players set @s ron.burst 0
execute if score @s ron.ammo matches ..0 run return run scoreboard players set @s ron.burst 0
execute if score @s ron.burst matches 3 run function ron:shoot_round
execute if score @s ron.burst matches 1 run function ron:shoot_round
