# RON Tactical Rifle (Minecraft: Java data pack + resource pack)

Ready or Not–inspired tactical shooter mashup for Minecraft: Java. First feature: one rifle.

- Target: Minecraft Java **1.21.4** (data pack format 61, resource pack format 46) — untested in-game so far.
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
