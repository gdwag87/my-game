#!/usr/bin/env python3
"""Preflight the design sheets, then generate datapack/data/ron/function/gen/*.
Sheets in design/ are the source of truth; change them before the code."""
import json, os, sys, zlib, struct

ROOT = os.path.dirname(os.path.abspath(__file__))
def sheet(n): return json.load(open(f"{ROOT}/design/{n}.json"))["rows"]
weapons, sounds, boards = sheet("weapons"), sheet("sounds"), sheet("scoreboards")

# ---- preflight: unfilled cells + unresolved references ----
errs = []
snd_ids = {s["id"] for s in sounds}
for w in weapons:
    for k, v in w.items():
        if v in ("", None): errs.append(f"weapons[{w['id']}].{k} is empty")
        if k.startswith("snd_") and v not in snd_ids:
            errs.append(f"weapons[{w['id']}].{k} -> unknown sound '{v}'")
for s in sounds:
    for k, v in s.items():
        if v in ("", None): errs.append(f"sounds[{s['id']}].{k} is empty")
if errs:
    print("PREFLIGHT FAILED"); [print(" -", e) for e in errs]; sys.exit(1)
print(f"preflight clean: {len(weapons)} weapon(s), {len(sounds)} sound(s), {len(boards)} objective(s)")

G = f"{ROOT}/datapack/data/ron/function/gen"
os.makedirs(G, exist_ok=True)
def put(name, text): open(f"{G}/{name}.mcfunction", "w").write(text)

# objectives
put("objectives", "".join(f"scoreboard objectives add {b['id']} {b['criteria']}\n" for b in boards))

# one function per sound row
for s in sounds:
    sel = "@a[distance=..32]" if s["source"] == "block" else "@a[distance=..48]"
    put(f"snd_{s['id']}", f"playsound {s['sound']} {s['source'] if s['source']!='player' else 'player'} {sel} ~ ~ ~ {s['volume']} {s['pitch']}\n")

# constants + give, from the (single) weapon row
w = weapons[0]
put("consts", "".join(f"scoreboard players set #{k} ron.const {w[k]}\n" for k in
    ["mag_size","reload_ticks","cooldown_semi","burst_cooldown"])
    + f"scoreboard players set #range_steps ron.const {w['range_blocks']*2}\n")
lore = ["Right-click: fire", "Sneak + right-click: fire mode", "Right-click when empty: reload"]
lore_s = ",".join("'" + json.dumps({"text": t, "color": "gray", "italic": False}) + "'" for t in lore)
name_s = "'" + json.dumps({"text": w["name"], "color": "gold", "italic": False}) + "'"
# 1.21.4 takes text components as quoted JSON strings (SNBT text arrived in 1.21.5)
put("give", f'give @s {w["base_item"]}[minecraft:item_model="{w["item_model"]}",'
    f'minecraft:item_name={name_s},minecraft:custom_data={{ron_weapon:"{w["id"]}"}},'
    f'minecraft:max_stack_size=1,minecraft:lore=[{lore_s}]] 1\n')
put("damage", f"damage @s {w['damage']} ron:bullet by @e[tag=ron.shooter,limit=1]\n")
put("recoil", f"rotate @s ~ ~-{w['recoil_pitch_tenths']/10}\n")

# ---- placeholder item texture (original art, written without any image lib) ----
def png(path, w_, h_, px):
    raw = b"".join(b"\x00" + b"".join(bytes(px(x, y)) for x in range(w_)) for y in range(h_))
    def ch(t, d): c = struct.pack(">I", len(d)) + t + d; return c + struct.pack(">I", zlib.crc32(t + d))
    open(path, "wb").write(b"\x89PNG\r\n\x1a\n" + ch(b"IHDR", struct.pack(">IIBBBBB", w_, h_, 8, 6, 0, 0, 0)) + ch(b"IDAT", zlib.compress(raw)) + ch(b"IEND", b""))
# 16x16, four 4px columns: 0=body dark, 1=body light, 2=accent, 3=magazine
pal = [(38,40,44,255),(78,82,90,255),(200,160,40,255),(25,25,28,255)]
png(f"{ROOT}/resourcepack/assets/ron/textures/item/rifle.png", 16, 16, lambda x, y: pal[x // 4])
print("generated datapack gen/ and placeholder texture")
