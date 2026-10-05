#!/usr/bin/env python3
"""Lay every design sheet over the others: list unfilled cells, unverified cells and broken references.
Exit 0 only when the preflight is clean."""
import json, sys, glob, os

root = os.path.join(os.path.dirname(__file__), "..", "design")
sheets = {}
for p in sorted(glob.glob(os.path.join(root, "*.json"))):
    d = json.load(open(p))
    sheets[d["sheet"]] = d

unfilled, unverified, badrefs = [], [], []
for name, s in sheets.items():
    for i, row in enumerate(s["rows"]):
        rid = row.get("id", i)
        for col, spec in s["columns"].items():
            v = row.get(col)
            where = f"{name}[{rid}].{col}"
            if v is None:
                if spec.get("required"):
                    unfilled.append(where)
                continue
            ref = spec.get("ref")
            if ref:
                tsheet, tcol = ref.split(".")
                ok = tsheet in sheets and any(r.get(tcol) == v for r in sheets[tsheet]["rows"])
                if not ok:
                    badrefs.append(f"{where} -> {ref} = {v!r}")
            if spec.get("needsVerify") and col not in row.get("_verified", []):
                unverified.append(where)

def show(title, items):
    print(f"{title}: {len(items)}")
    for x in items:
        print("  -", x)

show("Unfilled cells", unfilled)
show("Unresolved references", badrefs)
show("Unverified cells (not yet seen working in the game)", unverified)
clean = not (unfilled or badrefs or unverified)
print("PREFLIGHT", "CLEAN" if clean else "NOT CLEAN")
sys.exit(0 if clean else 1)
