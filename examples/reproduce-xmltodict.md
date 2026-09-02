# What can be reproduced for the xmltodict exam, and what cannot

`public.swe.martinblech-xmltodict-issue-257` is the one exam in this repository
built from public open-source software, so it is the one where an outside reader
can go furthest. This page says exactly how far, and where the road ends.

## Can be reproduced

**1. The task statement the model received.** It is in this repository, byte for
byte, and its SHA-256 is in the manifest.

```bash
shasum -a 256 environments/public.swe.martinblech-xmltodict-issue-257/ISSUE.md
python3 -c "import json;print(json.load(open('environments/MANIFEST.json'))['files']['public.swe.martinblech-xmltodict-issue-257/ISSUE.md'])"
```

**2. The upstream issue and pull request.** Both are public and both are named in
the exam's provenance.

- Issue: <https://github.com/martinblech/xmltodict/issues/257>
- Pull request: <https://github.com/martinblech/xmltodict/pull/421>
- Repository: <https://github.com/martinblech/xmltodict> (MIT)

```bash
python3 -c "import json;print(json.load(open('environments/public.swe.martinblech-xmltodict-issue-257/provenance.public.json'))['source'])"
```

**3. The parent commit the tree was frozen at.** The exam's tree is the upstream
repository at `404175512ced7ee915264485f757713df4f2c797`. You can check that
commit out yourself:

```bash
git clone https://github.com/martinblech/xmltodict
cd xmltodict
git checkout 404175512ced7ee915264485f757713df4f2c797
```

That is the upstream state the exam was built from. It is not the frozen agent
tree: the agent tree is a four-file subset with no git history, and its own hash
is recorded on the receipt as
`frozenTreeSha256: 2112c07dcd40e88c7e7100a48c277fc4fab06374ec0d85c419447a451b146797`.
The hash names that tree; it does not let you rebuild it, and this repository
does not ship it.

**4. The certification receipt, and its joins.** The receipt is here, and its
fingerprint must agree with the contract, the sealed record and the exam's live
page.

```bash
python3 -c "import json;print(json.load(open('environments/public.swe.martinblech-xmltodict-issue-257/certification-receipt.json'))['examFingerprint'])"
python3 -c "import json;print(json.load(open('reports/fc-d89e429d2781/records/fr-20260902-6616b188.canonical.json'))['environment']['fingerprint'])"
# both: aa41977120e6ecdddb5c4fc603e8ab23cb272726a86750119969ff4dfc90e297
```

The receipt file's own SHA-256 is bound into the campaign:

```bash
shasum -a 256 environments/public.swe.martinblech-xmltodict-issue-257/certification-receipt.json
python3 -c "import json;print(json.load(open('reports/fc-d89e429d2781/campaign.json'))['certificationReceipts']['public.swe.martinblech-xmltodict-issue-257'])"
# both: 2daeb9d08e5160da032bc8c7e14901533627ccc5c2cbadd06965f7dc8d823760
```

**5. The result, from its sealed record.**

```bash
examples/verify-record.sh reports/fc-d89e429d2781/records/fr-20260902-6616b188.canonical.json
# MATCH
```

The record carries the per-lane outcomes this exam produced in campaign
`fc-d89e429d2781`: `cli/codex` 10/10, `cli/claude-sonnet` 9/10,
`codestral-latest` 0/10, 30 graded rollouts, no lane errors.

## Cannot be reproduced

**The engine is not published.** `vvdex-env` runs the certification chain, the
containment audit, the verdict state machine and the report renderer. It is not
in this repository and it is not open source. Its revision is stamped on the
record as `engine.gitCommit` (`f7b1d6504f95bdc62c8fc0ed67ffbdf1e4769243` for this
record), which identifies it without publishing it.

Consequently:

- **You cannot run this exam.** There is no runnable package here, by design.
- **You cannot re-grade a submission.** The hidden tests are not published.
- **You cannot check the reference solution.** It is not published; what is
  published is that it passed and the untouched tree failed, n=2 each.
- **You cannot recompute the frozen tree's hash.** The tree is the exam.
- **You cannot reproduce a rollout.** Transcripts beyond tool-and-path traces are
  not published, and a rollout depends on a model endpoint at a moment in time.
- **There is no evidence-bundle seal to check.** The receipt's
  `certificationEvidenceDigest` reads `"unavailable"`: the seal stage was not
  recorded on this record, and no digest was manufactured for the column.

What you get instead is a record that attests to its own bytes, receipts whose
every field names the evidence it came from, and a set of joins that fail loudly
if any of it is swapped. That is the trade this package makes, and
[SECURITY.md](../SECURITY.md) states it in full.
