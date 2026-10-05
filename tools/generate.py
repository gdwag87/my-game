#!/usr/bin/env python3
"""Generate mod/.../data.lua from the design sheets. Refuses to build unless preflight is clean;
--draft builds anyway and stamps the output as an untested draft."""
import json, glob, os, subprocess, sys

here = os.path.dirname(__file__)
draft = "--draft" in sys.argv
pre = subprocess.run([sys.executable, os.path.join(here, "preflight.py")], capture_output=True, text=True)
if pre.returncode != 0 and not draft:
    print(pre.stdout); sys.exit("Preflight not clean: fix the sheets first (or pass --draft).")

S = {}
for p in glob.glob(os.path.join(here, "..", "design", "*.json")):
    d = json.load(open(p)); S[d["sheet"]] = d

def lua(v):
    if v is None: return "nil"
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, (int, float)): return repr(v)
    if isinstance(v, list): return "{" + ",".join(lua(x) for x in v) + "}"
    return '"' + str(v).replace("\\", "\\\\").replace('"', '\\"') + '"'

def table(name, rows, key="id"):
    out = [f"M.{name} = {{"]
    for r in rows:
        fields = ",".join(f"{k}={lua(v)}" for k, v in r.items() if not k.startswith("_"))
        out.append(f'  ["{r[key]}"] = {{{fields}}},')
    out.append("}")
    return "\n".join(out)

dest = os.path.join(here, "..", "mod", "bin", "x64", "plugins", "cyber_engine_tweaks", "mods", "minecraft_in_night_city")
os.makedirs(dest, exist_ok=True)
stamp = "-- GENERATED from design/*.json by tools/generate.py. Do not edit: change the sheet.\n"
stamp += f"-- STATUS: {'DRAFT, preflight not clean, untested in game' if pre.returncode else 'preflight clean'}\n"
body = stamp + "local M = {}\n" + "\n".join(
    table(n, S[n]["rows"]) for n in ("meshes", "items", "blocks", "breakables", "controls", "hud")) + "\nreturn M\n"
open(os.path.join(dest, "data.lua"), "w").write(body)

# redscript: the actions to watch, taken from the controls sheet
rs = os.path.join(here, "..", "mod", "r6", "scripts", "minecraft_in_night_city")
os.makedirs(rs, exist_ok=True)
tpl = open(os.path.join(here, "input.reds.in")).read()
actions = {r["id"]: r["gameAction"] for r in S["controls"]["rows"]}
for k, v in actions.items():
    tpl = tpl.replace("{{" + k + "}}", v or "__UNSET__")
open(os.path.join(rs, "input.reds"), "w").write("// GENERATED from design/controls.json\n" + tpl)
print("generated", "(draft)" if pre.returncode else "(clean)")
