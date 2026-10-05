# runs as the entity that was hit
scoreboard players set #hit ron.tmp 1
particle minecraft:damage_indicator ~ ~1 ~ 0.2 0.3 0.2 0.1 6
particle minecraft:block{block_state:"minecraft:redstone_block"} ~ ~1 ~ 0.15 0.25 0.15 0.05 12
execute as @a[tag=ron.shooter,limit=1] at @s run function ron:gen/snd_hit
function ron:gen/damage
