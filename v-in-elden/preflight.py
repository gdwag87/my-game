#!/usr/bin/env python3
"""Lay all sheets over each other: list unfilled cells and unresolved references."""
import json, os, sys
D = os.path.join(os.path.dirname(os.path.abspath(__file__)), "design")
S = {n: json.load(open(f"{D}/{n}.json"))["rows"] for n in ["abilities","keys","hud","sounds","hooks"]}
keys = {r["id"] for r in S["keys"]}; hud = {r["id"] for r in S["hud"]}; snd = {r["id"] for r in S["sounds"]}
unfilled, broken = [], []
for sheet, rows in S.items():
    for r in rows:
        for c, v in r.items():
            if v is None:
                unfilled.append(f"{sheet}[{r['id']}].{c}")
            if sheet == "hooks" and c == "verified" and v is False:
                unfilled.append(f"hooks[{r['id']}] not verified in game")
for r in S["abilities"]:
    if r["key"] not in keys: broken.append(f"abilities[{r['id']}].key -> '{r['key']}' missing in keys")
    if r["mechanism"] not in {h["id"] for h in S["hooks"]}: broken.append(f"abilities[{r['id']}].mechanism -> '{r['mechanism']}' missing in hooks")
    if r["hud"] not in ("n/a",) and r["hud"] not in hud: broken.append(f"abilities[{r['id']}].hud -> '{r['hud']}' missing in hud")
    if r["snd"] not in ("n/a",) and r["snd"] not in snd: broken.append(f"abilities[{r['id']}].snd -> '{r['snd']}' missing in sounds")
print(f"{len(unfilled)} unfilled / unverified cell(s), {len(broken)} unresolved reference(s)")
for x in broken: print(" BROKEN :", x)
for x in unfilled: print(" UNFILLED:", x)
sys.exit(1 if (unfilled or broken) else 0)
