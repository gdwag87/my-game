# one 0.5-block step of the bullet. Context: at the current ray point, facing the shooter's aim.
# entity whose hitbox contains this point (dx=dy=dz=0 tests the point)
execute as @e[dx=0,dy=0,dz=0,tag=!ron.shooter,type=!#ron:ignored,limit=1,sort=nearest] at @s run function ron:ray/hit
execute if score #hit ron.tmp matches 1 run return 0
# solid block stops the bullet
execute unless block ~ ~ ~ #ron:passable run return run function ron:ray/impact
# tracer
particle minecraft:crit ~ ~ ~ 0 0 0 0 1 normal
scoreboard players remove #range ron.tmp 1
execute if score #range ron.tmp matches 1.. positioned ^ ^ ^0.5 run function ron:ray/step
