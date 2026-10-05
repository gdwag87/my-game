-- GENERATED from design/*.json by tools/generate.py. Do not edit: change the sheet.
-- STATUS: DRAFT, preflight not clean, untested in game
local M = {}
M.meshes = {
  ["cube_unit"] = {id="cube_unit",entityPath=nil,sizeMetres=1.0,collision=true},
}
M.items = {
  ["stone"] = {id="stone",name="Stone",stackMax=64,places="stone",color={125,125,125}},
  ["dirt"] = {id="dirt",name="Dirt",stackMax=64,places="dirt",color={134,96,67}},
  ["planks"] = {id="planks",name="Planks",stackMax=64,places="planks",color={162,130,78}},
  ["glass"] = {id="glass",name="Glass",stackMax=64,places="glass",color={175,220,230}},
  ["concrete"] = {id="concrete",name="Concrete",stackMax=64,places="concrete",color={90,92,98}},
  ["neon"] = {id="neon",name="Neon Block",stackMax=64,places="neon",color={255,40,160}},
  ["scrap"] = {id="scrap",name="Scrap Metal",stackMax=64,places=nil,color={150,150,160}},
}
M.blocks = {
  ["stone"] = {id="stone",name="Stone",mesh="cube_unit",appearance=nil,breakSeconds=1.5,drops="stone"},
  ["dirt"] = {id="dirt",name="Dirt",mesh="cube_unit",appearance=nil,breakSeconds=0.75,drops="dirt"},
  ["planks"] = {id="planks",name="Planks",mesh="cube_unit",appearance=nil,breakSeconds=1.0,drops="planks"},
  ["glass"] = {id="glass",name="Glass",mesh="cube_unit",appearance=nil,breakSeconds=0.4,drops="glass"},
  ["concrete"] = {id="concrete",name="Concrete",mesh="cube_unit",appearance=nil,breakSeconds=2.0,drops="concrete"},
  ["neon"] = {id="neon",name="Neon Block",mesh="cube_unit",appearance=nil,breakSeconds=0.6,drops="neon"},
}
M.breakables = {
  ["crate"] = {id="crate",matchKind="nameContains",matchValue=nil,breakSeconds=1.0,drops="planks",dropCount=2},
  ["trash_can"] = {id="trash_can",matchKind="nameContains",matchValue=nil,breakSeconds=0.8,drops="scrap",dropCount=2},
  ["barrel"] = {id="barrel",matchKind="nameContains",matchValue=nil,breakSeconds=1.2,drops="scrap",dropCount=3},
}
M.controls = {
  ["break"] = {id="break",gameAction=nil,binding="left mouse (hold)",effect="input_action"},
  ["place"] = {id="place",gameAction=nil,binding="right mouse",effect="input_action"},
  ["scroll_next"] = {id="scroll_next",gameAction="NextWeapon",binding="mouse wheel down",effect="input_action"},
  ["scroll_prev"] = {id="scroll_prev",gameAction="PreviousWeapon",binding="mouse wheel up",effect="input_action"},
  ["slot_1"] = {id="slot_1",gameAction="WeaponSlot1",binding="1",effect="input_action"},
  ["slot_2"] = {id="slot_2",gameAction="WeaponSlot2",binding="2",effect="input_action"},
  ["slot_3"] = {id="slot_3",gameAction="WeaponSlot3",binding="3",effect="input_action"},
  ["slot_4"] = {id="slot_4",gameAction="WeaponSlot4",binding="4",effect="input_action"},
}
M.hud = {
  ["hotbar"] = {id="hotbar",anchor="bottom-center",slots=9,sizePx=48,source="inventory_state"},
  ["hearts"] = {id="hearts",anchor="above-hotbar-left",slots=10,sizePx=20,source="player_health"},
  ["crosshair"] = {id="crosshair",anchor="center",slots=1,sizePx=16,source="inventory_state"},
  ["break_bar"] = {id="break_bar",anchor="below-crosshair",slots=1,sizePx=60,source="inventory_state"},
}
return M
