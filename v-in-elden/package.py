#!/usr/bin/env python3
"""Build the Melty package: our DLL + our ModEngine2 config + a bundled ModEngine2 2.1.0 (MIT, soulsmods/ModEngine2).
Melty's shared ModEngine2 reads only its own config (external_dlls = []), so we ship and launch our own copy."""
import hashlib, os, sys, urllib.request, zipfile
R = os.path.dirname(os.path.abspath(__file__))
VER = sys.argv[1] if len(sys.argv) > 1 else "0.0.2"
ME2_URL = "https://github.com/soulsmods/ModEngine2/releases/download/release-2.1.0/ModEngine-2.1.0.0-win64.zip"
ME2_SHA = "8a5952453a8e3851247ed6a9dd8926ca638cf6135aa96c90298b63f15d8900ef"
cache = os.path.join(R, "dist", "ModEngine-2.1.0.0-win64.zip")
os.makedirs(os.path.dirname(cache), exist_ok=True)
if not os.path.exists(cache): urllib.request.urlretrieve(ME2_URL, cache)
assert hashlib.sha256(open(cache, "rb").read()).hexdigest() == ME2_SHA, "ModEngine2 zip hash mismatch"
CONFIG = """[modengine]
debug = false
external_dlls = ["v_in_elden.dll"]

[extension.mod_loader]
enabled = true
loose_params = false
mods = [{ enabled = true, name = "default", path = "mod" }]

[extension.scylla_hide]
enabled = false
"""
out = os.path.join(R, "dist", f"V-in-Elden-{VER}.zip")
src = zipfile.ZipFile(cache)
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    top = "ModEngine-2.1.0.0-win64/"
    for n in src.namelist():
        rel = n[len(top):]
        if not rel or n.endswith("/"): continue
        keep = rel == "modengine2_launcher.exe" or rel.startswith(("modengine2/bin/", "modengine2/crashpad/", "modengine2/assets/"))
        if keep: z.writestr("me2/" + rel, src.read(n))
    z.writestr("me2/config_eldenring.toml", CONFIG)
    z.writestr("me2/mod/README.txt", "ModEngine2 mod folder for V in the Lands Between (game file overrides go here).\n")
    z.write(os.path.join(R, "plugin/target/x86_64-pc-windows-msvc/release/v_in_elden.dll"), "me2/v_in_elden.dll")
    z.writestr("credits/ModEngine2-LICENSE-MIT.txt", "ModEngine2 2.1.0 by the soulsmods contributors - https://github.com/soulsmods/ModEngine2\n\n"
               + open(os.path.join(R, "third_party/ModEngine2-LICENSE-MIT.txt")).read())
print(out, os.path.getsize(out), hashlib.sha256(open(out, "rb").read()).hexdigest())
