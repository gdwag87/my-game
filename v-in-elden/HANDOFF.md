# V in the Lands Between — handoff for a session running ON the player's PC

Goal: Cyberpunk 2077's V (movement, Mantis Blades, Gorilla Arms, Sandevistan, cyberware menu) playable inside Elden Ring.
Host: Elden Ring (offline, via ModEngine2 which Melty installs; EAC off — never start the game another way).
Cyberpunk 2077: required game only because V's look/sounds are read from the player's own install at first Play. Nothing from either game ships.
Solo only. Elden Ring version Melty accepts: >= 2.7.1.0 <= 2.7.1.1. Free, offline mod (Melty says ER mods stay offline).

Stages: 1 movement -> 2 combat -> 3 cyberware menu/HUD -> 4 V's real model/animations (stretch, may only partly work).

State: design/*.json sheets exist; `python3 preflight.py` reports 29 unfilled/unverified cells. All must be read from the running
game (animation ids, SpEffect ids, sound cues, key collisions, hook addresses) — do not guess. No code generated yet.

Next steps on the PC: (1) find install folders of Elden Ring and Cyberpunk; (2) look at Melty's ER Mario recipe via mashup_info as a
working example; (3) set up universal-modder (github.com/rehan-remade/universal-modder, skills/mod-any-game/SKILL.md);
(4) fill the sheet cells from the game; (5) build stage 1 as a DLL loaded through ModEngine2; (6) test via Melty's Test button.
Publishing uses Melty's tools (list_my_mods, create_mod, start_upload, submit_release...). Token is NOT stored here.

## Progress (cloud session, 2026-10-06)
- Field note found: universal-modder knowledge/games/elden-ring/cs2-conversion-*.md (same pattern: other game's character/movement in ER via native Rust DLL). Sheets updated from it.
- Stage 0 DLL (plugin/): loads, waits for the game window, logs to v_in_elden.log next to the DLL, logs ability key presses. Touches no game memory.
  Build: `python3 gen.py && cd plugin && cargo xwin build --release --target x86_64-pc-windows-msvc`.
- Draft recipe (melty.recipe.draft.json): validate_recipe = valid, one click yes. Unverified: does ModEngine2 load our DLL from that config? -> play once through Melty, then read {managed}/modengine2/v_in_elden.log.
- Melty draft (PRIVATE, never publish unless the user says so): "V in the Lands Between", modId e6b29b58-38de-4ffc-9426-90e047745810,
  Studio https://melty.gg/studio/e6b29b58-38de-4ffc-9426-90e047745810. Release 0.0.1 = draft, one click yes, awaiting the user's Test.
  User wants V's real assets: convert them from the user's own Cyberpunk install on their PC only; nothing from either game is uploaded.
