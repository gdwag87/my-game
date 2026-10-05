# Minecraft in Night City

A Cyberpunk 2077 mod (single player) that brings Minecraft's hotbar, hearts, block placing and block breaking into Night City.

**Status: DRAFT, source only, not yet tested in the game.**

- Requires: Cyberpunk 2077 with Cyber Engine Tweaks, RED4ext and redscript (Melty installs these automatically).
- Inspired by Minecraft; the player does not need Minecraft.
- Controls: mouse wheel or 1-4 pick a hotbar slot, right mouse places, hold left mouse breaks (blocks you placed, plus crates, trash cans and barrels).

## Layout
- `design/*.json` are the source of truth (blocks, items, breakables, controls, HUD, hooks).
- `python3 tools/preflight.py` lists unfilled cells, unverified cells and broken references.
- `python3 tools/generate.py` writes `mod/.../data.lua` and `input.reds` from the sheets (`--draft` builds while preflight is not clean).
- `mod/` is the folder tree that goes into the game folder.
