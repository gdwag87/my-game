# runs as/at the player who right-clicked a carrot on a stick
scoreboard players set @s ron.use 0
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{ron_weapon:"rifle"}] run return 0
execute if predicate ron:sneaking run return run function ron:toggle_mode
execute if score @s ron.reload matches 1.. run return 0
execute if score @s ron.ammo matches ..0 run return run function ron:reload_start
execute if score @s ron.cd matches 1.. run return 0
function ron:shoot_round
execute if score @s ron.mode matches 1 run scoreboard players set @s ron.burst 5
execute if score @s ron.mode matches 0 run scoreboard players operation @s ron.cd = #cooldown_semi ron.const
execute if score @s ron.mode matches 1 run scoreboard players operation @s ron.cd = #burst_cooldown ron.const
