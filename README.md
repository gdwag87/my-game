# RON Tactical Rifle (Minecraft: Java data pack + resource pack)

Ready or Not–inspired tactical shooter mashup for Minecraft: Java. First feature: one rifle.

- Target: Minecraft Java **26.3** (data pack format 121, resource pack format 97). Needs Java 25 (the launcher installs it).
- Right-click: fire (raycast, damage, particles, sound). Sneak + right-click: toggle SEMI / BURST.
- 30-round magazine; right-click when empty (or `/function ron:reload`) starts a 2 s reload.
- Action bar shows fire mode and ammo.
- `/function ron:give` gives the rifle; `/function ron:setup_range` builds a firing range with targets.

## Layout
- `design/*.json` – source-of-truth sheets (weapons, sounds, scoreboards, hooks, hud)
- `build.py` – preflights the sheets, then generates `datapack/data/ron/function/gen/*` and the placeholder texture
- `datapack/`, `resourcepack/` – the packs (copy into a world's `datapacks/` and the `resourcepacks/` folder)

## Assets
All art and sound are original/vanilla placeholders. No Ready or Not assets are included, and none should be
committed: a published Melty release is downloaded by every player.

## Install note
The pack adds a custom damage type (`ron:bullet`, so rapid bursts aren't swallowed by Minecraft's hit cooldown).
Damage types load when a world opens, so **add the data pack, then close and reopen the world** (a plain `/reload` isn't enough the first time).

## Tested
26.3 dedicated server: pack loads with no errors; fire/damage/ammo/reload/toggle logic run with stand-in entities.
Earlier on 1.21.4 with a scripted player:
Give command, right-click fire, damage, wall blocking, ammo count, recoil, SEMI/BURST toggle (sneak + right-click),
3-round burst damage, empty -> reload -> 30 rounds, action-bar HUD text, `setup_range`. Not tested: how the model/sounds
look and sound in a real client.
