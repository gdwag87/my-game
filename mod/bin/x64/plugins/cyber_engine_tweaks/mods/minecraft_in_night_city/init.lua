-- Minecraft in Night City: Minecraft's hotbar, hearts, block placing and breaking inside Cyberpunk 2077.
-- Logic lives here; every number and name comes from data.lua, which is generated from design/*.json.
local D = require("data")

local REACH, STEP = 5.0, 0.1
local EYE_HEIGHT = 1.7
local HOTBAR_SLOTS = 9

local inv = {}                 -- inv[i] = {item = id, count = n}
local selected = 1
local world = {}               -- "x:y:z" -> {block = id, entity = entityID}
local progress, progressKey = 0, nil
local seen = {break_ = 0, place = 0, scroll = 0}
local ready = false

local function key(x, y, z) return x .. ":" .. y .. ":" .. z end
local function cell(v) return math.floor(v) end

local function give(item, n)
  local def = D.items[item]
  if not def then return end
  for i = 1, HOTBAR_SLOTS do
    local s = inv[i]
    if s and s.item == item and s.count < def.stackMax then s.count = s.count + n; return end
  end
  for i = 1, HOTBAR_SLOTS do
    if not inv[i] then inv[i] = {item = item, count = n}; return end
  end
end

local function take(i)
  local s = inv[i]
  if not s then return nil end
  s.count = s.count - 1
  local item = s.item
  if s.count <= 0 then inv[i] = nil end
  return item
end

-- The player's eye and look direction, from the camera system.
local function eye()
  local p = Game.GetPlayer()
  if not p then return nil end
  local pos = p:GetWorldPosition()
  local fwd = Game.GetCameraSystem():GetActiveCameraForward()
  if not fwd then return nil end
  return {x = pos.x, y = pos.y, z = pos.z + EYE_HEIGHT}, {x = fwd.x, y = fwd.y, z = fwd.z}
end

-- Walk the look ray in small steps and stop at the first placed block.
local function rayBlock(o, d)
  local prev
  for t = 0, REACH, STEP do
    local k = key(cell(o.x + d.x * t), cell(o.y + d.y * t), cell(o.z + d.z * t))
    if world[k] then return k, prev, t end
    prev = k
  end
end

local function rayStatic(o, d)
  local from = Vector4.new(o.x, o.y, o.z, 1)
  local to = Vector4.new(o.x + d.x * REACH, o.y + d.y * REACH, o.z + d.z * REACH, 1)
  local ok, hit = Game.GetSpatialQueriesSystem():SyncRaycastByCollisionGroup(from, to, "Static", false, false)
  if ok and hit and hit.position then return hit.position, hit.normal end
end

local function spawnBlock(k, x, y, z, blockId)
  local b = D.blocks[blockId]
  local mesh = D.meshes[b.mesh]
  if not mesh.entityPath then return nil end   -- sheet cell still unfilled: nothing to spawn yet
  local t = WorldTransform.new()
  t:SetPosition(Vector4.new(x + 0.5, y + 0.5, z + 0.5, 1))
  return exEntitySpawner.Spawn(mesh.entityPath, t, b.appearance)
end

local function place()
  local o, d = eye()
  if not o then return end
  local slot = inv[selected]
  if not slot then return end
  local item = D.items[slot.item]
  if not item.places then return end

  local hitKey, prevKey = rayBlock(o, d)
  local x, y, z
  if hitKey and prevKey then
    x, y, z = prevKey:match("(-?%d+):(-?%d+):(-?%d+)")
  else
    local p, n = rayStatic(o, d)
    if not p then return end
    x, y, z = cell(p.x + n.x * 0.5), cell(p.y + n.y * 0.5), cell(p.z + n.z * 0.5)
  end
  x, y, z = tonumber(x), tonumber(y), tonumber(z)
  local k = key(x, y, z)
  if world[k] then return end
  take(selected)
  world[k] = {block = item.places, entity = spawnBlock(k, x, y, z, item.places)}
end

local function breakPlaced(k)
  local w = world[k]
  if w.entity then exEntitySpawner.Despawn(Game.FindEntityByID(w.entity)) end
  give(D.blocks[w.block].drops, 1)
  world[k] = nil
end

local function breakProp()
  local player = Game.GetPlayer()
  local obj = Game.GetTargetingSystem():GetLookAtObject(player, false, false)
  if not obj then return nil end
  local name = tostring(obj:GetClassName()) .. " " .. tostring(obj:GetDisplayName())
  for id, row in pairs(D.breakables) do
    if row.matchValue and name:lower():find(row.matchValue:lower(), 1, true) then return id, obj end
  end
end

local function updateBreaking(dt)
  local player = Game.GetPlayer()
  if not player.mcBreakHeld then progress, progressKey = 0, nil; return end
  local o, d = eye()
  if not o then return end
  local k = rayBlock(o, d)
  local seconds, finish
  if k then
    seconds = D.blocks[world[k].block].breakSeconds
    finish = function() breakPlaced(k) end
  else
    local id, obj = breakProp()
    if not id then progress, progressKey = 0, nil; return end
    k = "prop:" .. id .. ":" .. tostring(obj:GetEntityID().hash)
    seconds = D.breakables[id].breakSeconds
    finish = function()
      give(D.breakables[id].drops, D.breakables[id].dropCount)
      obj:Dispose()
    end
  end
  if k ~= progressKey then progress, progressKey = 0, k end
  progress = progress + dt
  if progress >= seconds then finish(); progress, progressKey = 0, nil end
  currentBreakFraction = math.min(progress / seconds, 1)
end

registerForEvent("onInit", function()
  give("stone", 32); give("planks", 32); give("glass", 16); give("neon", 16)
  ready = true
  print("[Minecraft in Night City] loaded")
end)

registerForEvent("onUpdate", function(dt)
  if not ready then return end
  local player = Game.GetPlayer()
  if not player then return end

  if player.mcScroll ~= seen.scroll then
    selected = (selected - 1 + (player.mcScroll - seen.scroll)) % HOTBAR_SLOTS + 1
    seen.scroll = player.mcScroll
  end
  if player.mcSlot and player.mcSlot > 0 then selected = player.mcSlot; player.mcSlot = 0 end
  if player.mcPlaceCount ~= seen.place then seen.place = player.mcPlaceCount; place() end

  currentBreakFraction = 0
  updateBreaking(dt)
end)

local function health()
  local p = Game.GetPlayer()
  if not p then return 1 end
  return (Game.GetStatPoolsSystem():GetStatPoolValue(p:GetEntityID(), gamedataStatPoolType.Health, true) or 100) / 100
end

registerForEvent("onDraw", function()
  if not ready then return end
  local sw, sh = ImGui.GetDisplaySize()
  local size = D.hud.hotbar.sizePx
  local w = size * HOTBAR_SLOTS + 8
  local flags = ImGuiWindowFlags.NoTitleBar + ImGuiWindowFlags.NoResize + ImGuiWindowFlags.NoMove
    + ImGuiWindowFlags.NoScrollbar + ImGuiWindowFlags.NoInputs + ImGuiWindowFlags.NoBackground
  ImGui.SetNextWindowPos((sw - w) / 2, sh - size - 28)
  ImGui.SetNextWindowSize(w, size + 20)
  if ImGui.Begin("MCraft_Hotbar", flags) then
    for i = 1, HOTBAR_SLOTS do
      local s = inv[i]
      local c = s and D.items[s.item].color or {40, 40, 40}
      ImGui.PushStyleColor(ImGuiCol.Button, ImGui.GetColorU32(c[1] / 255, c[2] / 255, c[3] / 255, i == selected and 1 or 0.65))
      ImGui.Button(s and tostring(s.count) or " ", size - 4, size - 4)
      ImGui.PopStyleColor()
      if i < HOTBAR_SLOTS then ImGui.SameLine(0, 4) end
    end
  end
  ImGui.End()

  -- hearts: ten, from the player's health
  ImGui.SetNextWindowPos((sw - w) / 2, sh - size - 62)
  ImGui.SetNextWindowSize(w, 28)
  if ImGui.Begin("MCraft_Hearts", flags) then
    local full = math.ceil(health() * D.hud.hearts.slots)
    for i = 1, D.hud.hearts.slots do
      ImGui.PushStyleColor(ImGuiCol.Button, ImGui.GetColorU32(i <= full and 0.85 or 0.25, 0.1, 0.1, 1))
      ImGui.Button(" ", 18, 18)
      ImGui.PopStyleColor()
      if i < D.hud.hearts.slots then ImGui.SameLine(0, 2) end
    end
  end
  ImGui.End()

  -- crosshair and break bar
  ImGui.SetNextWindowPos(sw / 2 - 30, sh / 2 + 14)
  ImGui.SetNextWindowSize(60, 24)
  if ImGui.Begin("MCraft_Cross", flags) then
    ImGui.ProgressBar(currentBreakFraction or 0, 56, 8, "")
  end
  ImGui.End()
end)
