# manual reload: /function ron:reload
execute unless score @s ron.reload matches 1.. unless score @s ron.ammo = #mag_size ron.const run function ron:reload_start
