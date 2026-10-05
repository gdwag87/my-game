function ron:gen/objectives
function ron:gen/consts
tellraw @a [{"text":"[RON] ","color":"gold"},{"text":"Tactical Rifle pack loaded. Run ","color":"gray"},{"text":"/function ron:give","color":"yellow","clickEvent":{"action":"suggest_command","value":"/function ron:give"}},{"text":" (and /function ron:setup_range)","color":"gray"}]
