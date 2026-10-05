execute if score @s ron.mode matches 0 run scoreboard players set @s ron.mode 2
execute if score @s ron.mode matches 1 run scoreboard players set @s ron.mode 0
execute if score @s ron.mode matches 2 run scoreboard players set @s ron.mode 1
function ron:gen/snd_mode
