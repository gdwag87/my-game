# MODLOG
- Route: Cyber Engine Tweaks Lua (overlay HUD, spawning, ray casts) + redscript (reads the game's own input actions). Both are installed by Melty.
- Chosen because Melty's engine notes say Observe(OnAction) can't read action names on CET 1.37.1, so redscript wraps PlayerPuppet.OnAction instead.
- Known limits: only keys 1-4 plus the mouse wheel for the hotbar (vanilla has no 5-9 actions and Input Loader isn't installed by Melty). City geometry can't be removed.
- Blockers (see `python3 tools/preflight.py`): cube entity path and per-block appearances, breakable prop match names, mouse action names, vanilla HUD hiding. All need the real game files or a running game.
- Nothing has been run in Cyberpunk yet.
