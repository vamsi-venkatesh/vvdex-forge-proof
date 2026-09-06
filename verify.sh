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
def verify_annotations(root):
    from pathlib import Path
    import hashlib, json, re
    root = Path(root)
    expected = {"vvdex.annotation." + name for name in (
        "robot-video-1", "image-object-1", "text-labeling-1",
        "structured-data-1", "audio-events-1")}
    found = {p.name for p in (root / "exams").glob("vvdex.annotation.*")}
    errors = []
    if found != expected:
        errors.append("annotation fixture inventory does not match the five-fixture release")
    for env_id in sorted(found):
        folder = root / "exams" / env_id
        try:
            docs = {name: json.loads((folder / name).read_text()) for name in (
                "exam.public.json", "certification-receipt.json", "report.public.json",
                "provenance.public.json", "digests.json")}
            desc, receipt, report = (docs[name] for name in (
                "exam.public.json", "certification-receipt.json", "report.public.json"))
            fingerprint = desc["examFingerprint"]
            if not isinstance(fingerprint, str) or not fingerprint or fingerprint == "unavailable":
                raise ValueError("missing fingerprint")
            for doc in (desc, receipt, report):
                if doc["examId"] != env_id or doc["examFingerprint"] != fingerprint:
                    raise ValueError("identity or fingerprint join failed")
            if report["schema"] != "vvdex.forge.annotation-certification-report/v1":
                raise ValueError("unexpected report schema")
            if report["certificationState"] != "certified":
                raise ValueError("certification boundary failed")
            campaign = report["modelCampaign"]
            if campaign is not None:
                if not isinstance(campaign, dict):
                    raise ValueError("unbound model campaign")
                cid = campaign.get("campaignId")
                if not isinstance(cid, str) or not re.fullmatch(r"fc-[0-9a-f]{8,64}", cid):
                    raise ValueError("invalid campaign identity")
                if campaign.get("reportUrl") != "/reports/" + cid + "/" or campaign.get("summaryUrl") != "/reports/" + cid + "/summary.json":
                    raise ValueError("campaign path join failed")
                target = root / "reports" / cid / "summary.json"
                if any(p.is_symlink() for p in (root / "reports", target.parent, target)) or not target.is_file():
                    raise ValueError("unsafe campaign summary path")
                raw = target.read_bytes()
                if hashlib.sha256(raw).hexdigest() != campaign.get("summarySha256"):
                    raise ValueError("campaign summary digest mismatch")
                summary = json.loads(raw)
                block = summary["annotationCampaign"]
                tasks = [t for t in block["tasks"] if t.get("environmentId") == env_id]
                if summary.get("campaignId") != cid or len(tasks) != 1:
                    raise ValueError("campaign task identity mismatch")
                task = tasks[0]
                if campaign.get("examFingerprint") != fingerprint or task.get("examFingerprint") != fingerprint:
                    raise ValueError("campaign fingerprint mismatch")
                if campaign.get("coverage") != block.get("coverage") or campaign.get("models") != task.get("models"):
                    raise ValueError("campaign outcome join failed")
                if desc["annotation"].get("modelCampaign") != campaign:
                    raise ValueError("descriptor campaign binding mismatch")
            if report["annotation"] != desc["annotation"]:
                raise ValueError("annotation descriptor join failed")
            actual = hashlib.sha256((folder / "certification-receipt.json").read_bytes()).hexdigest()
            if report["certificationReceiptSha256"] != actual:
                raise ValueError("receipt digest join failed")
            seal = receipt["certificationEvidenceDigest"]
            if not isinstance(seal, str) or not re.fullmatch(r"[0-9a-f]{64}", seal):
                raise ValueError("missing private certification bundle digest")
            digests = docs["digests.json"]
            present = {p.name for p in folder.iterdir() if p.is_file() and p.name != "digests.json"}
            if set(digests) != present:
                raise ValueError("adjacent digest inventory mismatch")
            for name, want in digests.items():
                target = folder / name
                if Path(name).name != name or target.is_symlink() or not target.is_file():
                    raise ValueError("unsafe digest path")
                if hashlib.sha256(target.read_bytes()).hexdigest() != want:
                    raise ValueError("adjacent artifact digest mismatch")
        except (OSError, ValueError, KeyError, TypeError, AttributeError):
            errors.append(env_id + ": annotation evidence verification failed")
    return errors, len(found)

annotation_errors, annotation_count = verify_annotations(".")
print(f"(a) annotation certification: {annotation_count} fixtures | {len(annotation_errors)} errors")
for error in annotation_errors:
    print("    " + error)
def verify_capabilities(root, strict=False):
    import json
    import re
    from pathlib import Path
    root = Path(root)
    path = root / 'capabilities/index.json'
    if not path.is_file():
        return ['capability index is missing'], 0
    errors, identities, cells = [], set(), {}
    referenced_inventories, projected_inventories = {}, {}
    try:
        index = json.loads(path.read_text())
        if index.get('schemaVersion') != 'forge-capabilities/v1' or index.get('projection') != 'public':
            errors.append('unexpected capability schema or disclosure projection')
        outcome_keys = {'certified_pass': 'certifiedPasses', 'model_fail': 'modelFailures',
                        'lane_error': 'laneErrors', 'withheld': 'withheld', 'invalid': 'invalid'}
        campaigns = {c['id']: set(c['recordDigests']) for c in index['campaigns']}
        for group in index['taxonomy']:
            if group.get('composite') is not None:
                errors.append('unsupported category composite')
            for cell in group['measurements']:
                if cell['id'] in cells:
                    errors.append('duplicate measurement identity')
                cells[cell['id']] = cell
                counts = dict.fromkeys(['attempts', 'graded', *outcome_keys.values()], 0)
                for ref in cell['evidenceRefs']:
                    href = ref['href']
                    if not re.fullmatch(r'/reports/fc-[a-z0-9]+/summary.json', href):
                        errors.append('invalid capability evidence path')
                        continue
                    summary = json.loads((root / href.lstrip('/')).read_text())
                    matching = [r for r in summary['records'] if r['evalId'] == ref['evalId']]
                    if len(matching) != 1 or matching[0]['recordDigest'] != ref['recordDigest']:
                        errors.append('capability record commitment disagrees with campaign')
                    elif matching[0]['environmentId'] != cell['exam']['id']:
                        errors.append('capability exam disagrees with campaign')
                    if ref['recordDigest'] not in campaigns.get(summary['campaignId'], set()):
                        errors.append('capability campaign membership is missing')
                    projection_path = root / 'capabilities/records' / (ref['evalId'] + '.record.public.json')
                    if not projection_path.is_file():
                        projection_path = root / href.lstrip('/').replace('/summary.json', '') / 'records' / (ref['evalId'] + '.record.public.json')
                    projection_rollouts = None
                    if projection_path.is_file():
                        projection = json.loads(projection_path.read_text())
                        source = projection.get('sourceRecordDigest') or {}
                        if (projection.get('evalId') != ref['evalId']
                                or projection.get('environmentId') != cell['exam']['id']
                                or source.get('sha256') != ref['recordDigest']):
                            errors.append('capability record projection identity disagrees')
                        projection_rollouts = {row.get('id'): row for row in projection.get('rollouts') or []}
                        inventory_key = (ref['recordDigest'], cell['lane']['identity'])
                        lane_ids = {attempt_id for attempt_id, projected in projection_rollouts.items()
                                    if projected.get('lane') == cell['lane']['identity']}
                        previous_inventory = projected_inventories.setdefault(inventory_key, lane_ids)
                        if previous_inventory != lane_ids:
                            errors.append('record projection inventory is inconsistent')
                    elif strict:
                        errors.append('capability record projection is missing')
                    ref_attempt_ids = set()
                    for attempt in ref['attempts']:
                        ref_attempt_ids.add(attempt['id'])
                        key = (ref['recordDigest'], attempt['id'])
                        if key in identities:
                            errors.append('capability attempt is counted more than once')
                        identities.add(key)
                        counts['attempts'] += 1
                        outcome = outcome_keys.get(attempt['certifiedOutcome'])
                        if outcome is None:
                            errors.append('unknown certified outcome')
                        else:
                            counts[outcome] += 1
                        if projection_rollouts is not None:
                            projected = projection_rollouts.get(attempt['id'])
                            if projected is None:
                                errors.append('capability attempt is absent from record projection')
                            else:
                                verdicts = projected.get('verdicts') or {}
                                projected_outcome = projected.get('effectiveCertifiedOutcome', verdicts.get('certified'))
                                if projected.get('lane') != cell['lane']['identity']:
                                    errors.append('capability attempt lane disagrees with record projection')
                                if projected_outcome != attempt['certifiedOutcome']:
                                    errors.append('capability attempt outcome disagrees with record projection')
                    inventory_key = (ref['recordDigest'], cell['lane']['identity'])
                    referenced_inventories.setdefault(inventory_key, set()).update(ref_attempt_ids)
                counts['graded'] = counts['certifiedPasses'] + counts['modelFailures']
                if counts != cell['counts']:
                    errors.append('capability counts disagree with sealed attempt projection')
                expected_rate = counts['certifiedPasses'] / counts['graded'] if counts['graded'] >= 10 else None
                if cell['rate'] != expected_rate:
                    errors.append('capability rate disagrees with stated denominator')
            for coverage in group.get('coverageItems', []):
                if any(ref not in cells for ref in coverage['measurementRefs']):
                    errors.append('coverage references an absent measurement')
                for lane in coverage.get('laneSummaries', []):
                    selected = [cells[ref] for ref in lane['measurementRefs']]
                    expected = {k: sum(c['counts'][k] for c in selected) for k in lane['counts']}
                    if lane['counts'] != expected:
                        errors.append('coverage accounting disagrees with measurements')
        if index['attempts']['unique'] != len(identities):
            errors.append('unique attempt accounting disagrees')
        for inventory_key in set(referenced_inventories) | set(projected_inventories):
            if ((strict or inventory_key in projected_inventories)
                    and referenced_inventories.get(inventory_key, set()) != projected_inventories.get(inventory_key, set())):
                errors.append('capability attempt inventory disagrees with record projection')
        memberships = sum(sum(digest in digests for digests in campaigns.values()) for digest, _ in identities)
        if index['attempts']['memberships'] != memberships:
            errors.append('campaign membership accounting disagrees')
        for pair in index['comparisons']:
            if pair['left'] not in cells or pair['right'] not in cells:
                errors.append('comparison references an absent measurement')
    except (OSError, ValueError, KeyError, TypeError):
        errors.append('capability evidence is malformed or incomplete')
    return errors, len(cells)

capability_errors, capability_count = verify_capabilities(".", strict=True)
print(f"(a) capabilities: {capability_count} measurements | {len(capability_errors)} errors")
for error in capability_errors:
    print("    " + error)
sys.exit(1 if (missing or bad or extra or disagree or canonical or annotation_errors or capability_errors) else 0)
PY
echo "OK: every file matches the manifest and every record digest agrees wherever it is stated."
echo "Recomputing a digest from the sealed record it describes needs the canonical record; see VERIFICATION.md."
