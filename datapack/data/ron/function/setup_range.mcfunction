# builds a small firing range in front of you: floor, backstop, 4 target zombies (no AI)
execute at @s positioned ^ ^ ^3 run fill ~-6 ~-1 ~ ~6 ~-1 ~30 minecraft:stone_bricks
execute at @s positioned ^ ^ ^3 run fill ~-6 ~ ~31 ~6 ~5 ~31 minecraft:smooth_stone
execute at @s positioned ^ ^ ^3 run fill ~-6 ~ ~ ~6 ~4 ~30 minecraft:air
execute at @s positioned ^ ^ ^3 run fill ~-6 ~ ~ ~-6 ~4 ~30 minecraft:smooth_stone
execute at @s positioned ^ ^ ^3 run fill ~6 ~ ~ ~6 ~4 ~30 minecraft:smooth_stone
execute at @s positioned ^ ^ ^3 run summon minecraft:zombie ~ ~ ~8 {NoAI:1b,Silent:1b,PersistenceRequired:1b,CustomName:'"Target 8m"',Tags:["ron.target"],ArmorItems:[{},{},{},{id:"minecraft:iron_helmet",count:1}],HandItems:[{},{}]}
execute at @s positioned ^ ^ ^3 run summon minecraft:zombie ~-3 ~ ~16 {NoAI:1b,Silent:1b,PersistenceRequired:1b,CustomName:'"Target 16m"',Tags:["ron.target"]}
execute at @s positioned ^ ^ ^3 run summon minecraft:zombie ~3 ~ ~24 {NoAI:1b,Silent:1b,PersistenceRequired:1b,CustomName:'"Target 24m"',Tags:["ron.target"]}
execute at @s positioned ^ ^ ^3 run summon minecraft:armor_stand ~ ~ ~28 {CustomName:'"Wall test"',Tags:["ron.target"]}
function ron:give
tellraw @s {"text":"[RON] Range built. Targets are 8, 16, 24 m away. Right-click to fire.","color":"gold"}
