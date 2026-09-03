#!/bin/sh
# Verify this package against its own manifest, and every published record
# against the digest it states about itself. No network, no dependencies
# beyond a POSIX shell, shasum and python3.
set -eu
cd "$(dirname "$0")"
python3 - <<'PY'
import hashlib, json, os, sys
man = json.load(open("MANIFEST.json"))
files = man["files"]
bad, missing = [], []
for rel, want in sorted(files.items()):
    if not os.path.isfile(rel):
        missing.append(rel); continue
    got = hashlib.sha256(open(rel, "rb").read()).hexdigest()
    if got != want:
        bad.append(rel)
on_disk = {os.path.relpath(os.path.join(b, f), ".")
           for b, ds, fs in os.walk(".") for f in fs
           if ".git" not in b.split(os.sep)}
extra = sorted(on_disk - set(files) - {"MANIFEST.json"})
print(f"manifest: {len(files)} files | missing {len(missing)} | mismatched {len(bad)} | unlisted {len(extra)}")
for rel in (missing + bad + extra)[:20]:
    print("   ", rel)

records = 0
checked = 0
withheld = 0
for base, _, fs in os.walk("reports"):
    for f in fs:
        if f.endswith(".digest.txt"):
            records += 1
            stated = open(os.path.join(base, f)).read().strip()
            canonical = os.path.join(base, f[:-len(".digest.txt")] + ".canonical.json")
            if os.path.isfile(canonical):
                got = hashlib.sha256(open(canonical, "rb").read()).hexdigest()
                checked += 1
                if got != stated:
                    bad.append(canonical)
                    print("RECORD DIGEST MISMATCH:", canonical)
            else:
                withheld += 1
print(f"records: {records} digests | {checked} recomputed from published bytes | "
      f"{withheld} whose bytes are withheld (the exam's disclosure class)")
sys.exit(1 if (missing or bad or extra) else 0)
PY
echo "OK: every file matches the manifest and every published record recomputes its digest."
