#!/bin/sh
# Verify this package. Two things are checkable here and they are different
# things, so the output says which is which.
#
#   (a) ARTIFACT AND DIGEST VERIFICATION, available to anyone holding this
#       repository. Every listed file's sha256 against MANIFEST.json, and every
#       record digest string cross-checked between the places that state it:
#       the *.digest.txt file, the record projection's sourceRecordDigest, the
#       campaign summary's records[], and the per-record verification receipt.
#
#   (b) SEALED-RECORD RECOMPUTATION, which this repository cannot do. No
#       canonical record body is published, so no digest here is recomputed
#       from the bytes it describes. That check belongs to a holder of the
#       canonical record under agreement; see VERIFICATION.md.
#
# No network, no dependencies beyond a POSIX shell and python3.
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
print(f"(a) manifest: {len(files)} files | missing {len(missing)} | "
      f"mismatched {len(bad)} | unlisted {len(extra)}")
for rel in (missing + bad + extra)[:20]:
    print("   ", rel)

# Two DIFFERENT digests live in this tree and they must not be compared with
# each other:
#   recordDigest  is the digest of the SEALED CANONICAL RECORD, stated by
#                   <evalId>.digest.txt, by the projection's sourceRecordDigest
#                   and by summary.json records[].recordDigest.
#   recordSha256  is the digest of the REPORT'S OWN record JSON, stated by
#                   <evalId>.manifest.json and <evalId>.verification.txt.
def agree(groups, label):
    disagreeing = []
    multi = 0
    for key, places in sorted(groups.items()):
        values = {v for v in places.values() if v}
        if len(values) > 1:
            disagreeing.append(key)
            print(f"{label} DISAGREEMENT:", key, places)
        elif len([v for v in places.values() if v]) > 1:
            multi += 1
    print(f"(a) {label}: {len(groups)} record(s) | {multi} stated in more than one "
          f"place and agreeing | {len(disagreeing)} disagreeing")
    return disagreeing

canon, report = {}, {}
for base, _, fs in os.walk("reports"):
    for f in sorted(fs):
        full = os.path.join(base, f)
        if f.endswith(".digest.txt"):
            canon.setdefault(f[:-len(".digest.txt")], {})["digest.txt"] = \
                open(full).read().strip()
        elif f.endswith(".record.public.json"):
            doc = json.load(open(full))
            canon.setdefault(f[:-len(".record.public.json")], {})["projection"] = \
                (doc.get("sourceRecordDigest") or {}).get("sha256")
        elif f == "summary.json":
            for rec in json.load(open(full)).get("records") or []:
                canon.setdefault(rec.get("evalId"), {})["summary.json"] = \
                    rec.get("recordDigest")
        elif f.endswith(".manifest.json"):
            doc = json.load(open(full))
            report.setdefault(f[:-len(".manifest.json")], {})["manifest.json"] = \
                doc.get("recordSha256")
        elif f.endswith(".verification.txt"):
            for line in open(full):
                if line.strip().startswith("recordSha256:"):
                    report.setdefault(f[:-len(".verification.txt")], {})\
                        ["verification.txt"] = line.split(":", 1)[1].strip()
disagree = agree(canon, "sealed record digest") + agree(report, "report record digest")

canonical = [os.path.join(b, f) for b, _, fs in os.walk("reports")
             for f in fs if f.endswith(".canonical.json")]
proj = [f for b, _, fs in os.walk("reports") for f in fs
        if f.endswith(".record.public.json")]
print(f"(b) sealed-record recomputation: not available here | "
      f"{len(canonical)} canonical record body/bodies published | "
      f"{len(proj)} sanitized projection(s) published")
if canonical:
    print("    UNEXPECTED: this package publishes no canonical record bodies.")
sys.exit(1 if (missing or bad or extra or disagree or canonical) else 0)
PY
echo "OK: every file matches the manifest and every record digest agrees wherever it is stated."
echo "Recomputing a digest from the sealed record it describes needs the canonical record; see VERIFICATION.md."
