# Verification

Nothing here asks for trust. Each claim binds to a digest you can recompute with
`shasum` and a JSON reader. Four checks, in the order a skeptical reader would
run them.

## 1. A sealed record's digest

Each `reports/<campaignId>/records/<evalId>.canonical.json` is the exact
serialization its digest was computed over: canonical JSON, keys sorted,
separators `,` and `:` with no spaces, non-ASCII escaped, and
`recordDigest.sha256` set to sixty-four `0` characters. The digest the record
states about itself is in the `.digest.txt` beside it.

```bash
cd reports/fc-d89e429d2781/records
shasum -a 256 fr-20260902-6616b188.canonical.json
cat fr-20260902-6616b188.digest.txt
```

The two must be equal. The script does it for you and prints `MATCH` or
`MISMATCH`:

```bash
examples/verify-record.sh reports/fc-d89e429d2781/records/fr-20260902-6616b188.canonical.json
```

Expected for all five records in campaign `fc-d89e429d2781`:

| Record | Environment | Digest |
| --- | --- | --- |
| `fr-20260902-6616b188` | `public.swe.martinblech-xmltodict-issue-257` (public source) | `138425da59aabc18aa208c339aa41919f387e1ecb80fb725cfed8f7d6ba78713` |
| `fr-20260902-2e7f4171` | `vvdex.knowledge.grounded-rag-1` | `157ec324a925c0b10fc8769d01f628b6143c40a00fa2dc70ea309a70e55a37a8` |
| `fr-20260901-46eb9548` | `vvdex.knowledge.memory-fact-update-1` | `1127e8356d42d31767a3ddc4d6c6cd0a515f5bbf7239ef0a82129e00fc2e6900` |
| `fr-20260902-a6f12b64` | `vvdex.harness.fault-recovery-1` | `d5a8264aa0c20dd67c14879856a744e2ff1ab79da35ea8bcea92b4ba1ea14d5f` |
| `fr-20260902-6e618c05` | `vvdex.browser.order-desk-1` | `59f94854d78f7ce174866ff114505b2b41ca2333f287f40b604fbb38cc267da5` |

The same check runs in a browser at <https://vvdexops.com/verify/> using
WebCrypto; nothing is uploaded.

## 2. The PDFs' self-check

A report states its own SHA-256 with the digest's own slot zeroed, so the check
is exactly invertible: replace every occurrence of the stated digest with
sixty-four `0` characters, hash the file, and the result must equal the stated
digest. That scheme is what makes a rendered document able to name itself
without a circular hash.

What the PDFs in this repository let you check without leaving the repository is
the join back to the records. Read the text out of a PDF and compare:

```bash
pdftotext -q reports/fc-d89e429d2781/fc-d89e429d2781-executive.pdf - | grep recordDigest
```

The campaign executive PDF names all five records with their digests. They must
agree with `reports/fc-d89e429d2781/records/*.digest.txt`, which they do; §1
above is the check that closes the loop. Each standalone executive PDF states
its exam's fingerprint, which §3 below joins to the receipt, the contract and
the record.

Only executive PDFs are published here. **The full campaign PDF is deliberately
not in this repository.** It embeds per-rollout submission diffs, and on
answer-key exams a submission diff is the answer: its text contains the RAG and
memory exams' gold answers verbatim, dozens of times. A proof package must not
carry the answer key, so it was left out. The full document, its *Verification*
chapter and its Appendix B artifact-digest table are published with the release,
not here.

Those release-side artifacts — the standalone report HTML, the standalone report
PDF, the run evidence bundle, the per-rollout JSON files, and the
`*.manifest.json` and `*.verification.txt` files that spell the three-line
procedure out per report — are checkable against the published release rather
than against these files, and this repository does not pretend otherwise. The
certified evidence seal reads *not available in this package*, matching the
`"unavailable"` on the receipts.

## 3. The exam fingerprint joins

The exam fingerprint is the join key. It is the same string in four places, and
the four must agree or the receipt describes a different exam revision than the
result.

```bash
# 1. the certification receipt
python3 -c "import json;print(json.load(open('exams/public.swe.martinblech-xmltodict-issue-257/certification-receipt.json'))['examFingerprint'])"

# 2. the public contract (published for this exam because its ownership
#    declaration names a public upstream repository and its licence)
python3 -c "import json;print(json.load(open('exams/public.swe.martinblech-xmltodict-issue-257/contract.public.json'))['fingerprint'])"

# 3. the sealed record's canonical bytes
python3 -c "import json;print(json.load(open('reports/fc-d89e429d2781/records/fr-20260902-6616b188.canonical.json'))['environment']['fingerprint'])"

# 4. the exam's page on the live site
#    https://vvdexops.com/featured/martinblech-xmltodict-issue-257/
```

All four are `aa41977120e6ecdddb5c4fc603e8ab23cb272726a86750119969ff4dfc90e297`.

The other four exams are VVDex-authored, so what this repository carries for
each of them is a proof descriptor: `exam.public.json`, the certification
receipt, `provenance.public.json` and `VERIFY.md`. The fingerprint join still
runs — descriptor, receipt, record and live page must all state the same
value — but there is no `contract.public.json` and no task statement to join
against, because neither is published for a proprietary exam.

| Exam | Exam fingerprint |
| --- | --- |
| `public.swe.martinblech-xmltodict-issue-257` (public source) | `aa41977120e6ecdddb5c4fc603e8ab23cb272726a86750119969ff4dfc90e297` |
| `vvdex.knowledge.grounded-rag-1` | `4880a527ef97ca2f3fe6b57be026c3dc1be51e9e104d79fc13a3e558331dda92` |
| `vvdex.knowledge.memory-fact-update-1` | `2052eec0ff2d3044dc269e3599ae1bfaa45d0d8cd5df9554796105538d226c21` |
| `vvdex.harness.fault-recovery-1` | `4a206fbfe8fb70fb3e37943705065a8599fab492e495dca326279781ee960b1e` |
| `vvdex.browser.order-desk-1` | `8d404ee5d5ab71456de3d3df0b8ca69271d8810767a694f71c6e45e72fc347bf` |

A second join runs through the receipt file itself. `campaign.json` carries a
`certificationReceipts` map of exam id to the SHA-256 of that exam's receipt
file, so the receipt in `exams/` and the receipt the campaign was built against
are provably the same bytes:

```bash
shasum -a 256 exams/public.swe.martinblech-xmltodict-issue-257/certification-receipt.json
python3 -c "import json;print(json.load(open('reports/fc-d89e429d2781/campaign.json'))['certificationReceipts']['public.swe.martinblech-xmltodict-issue-257'])"
```

Both are `87ba9833637f004939e1a7b2d3a69b2d0e0e37b1040ef5d403eb9c392695bee0`.
`summary.json` carries the same map, per record, as
`records[].certificationReceiptSha256`.

Every file in this repository has its SHA-256 in
[`MANIFEST.json`](MANIFEST.json), and `./verify.sh` checks all of them at once
and then recomputes every published record digest:

```bash
./verify.sh

# or one file at a time
shasum -a 256 exams/vvdex.browser.order-desk-1/exam.public.json
python3 -c "import json;print(json.load(open('MANIFEST.json'))['files']['exams/vvdex.browser.order-desk-1/exam.public.json'])"
```

## Where the bytes are withheld

Four of the five records' canonical bytes are not published. A sealed record
carries an excerpt of what each rollout submitted, and on an exam whose graded
output is an answer or a world state that excerpt is the answer. Those records
ship as `<evalId>.digest.txt` beside a `<evalId>.canonical.WITHHELD.txt` that
states the digest and the reason. The digest is the digest of the sealed record
as it exists in the Forge; a holder of that record — the customer who
commissioned the run, or an auditor under agreement — reproduces it with
`shasum -a 256` or `vvdex-env records verify` and reaches the printed value.
`./verify.sh` reports how many were recomputed and how many are withheld, so a
withheld record is visible as a fact rather than read as a pass.

## 4. The campaign id

The campaign id is a digest over the sorted record digests. The same records
always name the same campaign, and a changed record names a different one, so the
documents in `reports/fc-d89e429d2781/` cannot be re-pointed at a different set
of records without changing the directory's own name.

```bash
python3 examples/inspect-campaign.py reports/fc-d89e429d2781/summary.json
```

prints the five-exam matrix, the lane totals with their Wilson intervals, and the
five record digests the id is computed over.

## What the checks do not cover

Read [SECURITY.md](SECURITY.md) § *What a verifier cannot check* before quoting
any of this. In short: the digests prove these bytes are the published bytes and
that the documents were derived from these records. They do not prove the hidden
tests are fair, that the reference is the only correct answer, or that the exam
is unbreakable, and they cannot recompute the frozen tree, which is not shipped.

If a digest here does not reproduce, the artifact is not ours. That is the
design. Report it to vamsi@vamsivenkatesh.com.
