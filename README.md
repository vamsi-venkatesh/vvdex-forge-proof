<!--
Every number in this file is traceable to a repository artifact. The file and
field behind each one is listed in CLAIMS.md, and `python3
examples/check-readme-matrix.py` rebuilds the matrix and the headline from
reports/fc-d89e429d2781/summary.json and campaign.json and fails on any
difference.
-->

# VVDex Forge, proof package

## 1. What VVDex Forge is

VVDex Forge is an evaluation system for AI agents. It authors an exam, certifies
it before any model sees it, runs models against it inside a sealed box, grades
the result in a separate step, and seals the outcome into a record that hashes
to a stated digest.

This repository is the proof that the system ran and that the published numbers
are the ones the sealed records state. It is not a distribution of exams and it
is not a release of the engine. Publishing a result grants no licence to the
instrument that produced it.

## Annotation certification evidence

Forge also evaluates multimodal annotations: robotic video, image objects, text
labels, structured records and audio events. Five certified fixtures are
published as safe descriptors, provenance, certification receipts and aggregate
reports. Read [ANNOTATION.md](ANNOTATION.md) for their scope and links.

These are fixture certification results. They do not add attempts, model passes,
or another model lane to the September 1–2 campaign below. The existing matrix
and campaign arithmetic remain unchanged.

## 2. The evidence

**5 certified evaluation environments · 5 families · 150 attempts · 148 graded rollouts · 93 certified passes**

Those are task-specific measurements on the five environments described below,
taken on 2026-09-01 and 2026-09-02 in campaign `fc-d89e429d2781`. They are not a
universal model leaderboard. A cell in the matrix says how one model lane did on
one exam, ten times, and it says nothing about any other task, any other version
of the same model, or any other scaffold.

The counts break down as 93 certified passes, 55 model failures, 2 lane errors,
0 withheld and 0 invalid. Lane errors are provider or CLI failures. They are not
model results and they sit outside the numerator and the denominator alike.

Three superseded campaigns are kept in the same shape and cited only as history:
`fc-3194f803055c` (52 certified passes), `fc-72fe6f91c29e` (41) and
`fc-8626f712e26f` (8). Each of their reports states HISTORICAL on its own cover.

## 3. The matrix

Campaign `fc-d89e429d2781`, three model lanes, five exams, ten rollouts per
cell. Cells read passes over graded rollouts, and a lane error is stated beside
the fraction rather than folded into it.

| Model lane | SWE | RAG | Memory | Harness | Browser | Certified passes |
| --- | --- | --- | --- | --- | --- | --- |
| `cli/codex` | 10/10 | 10/10 | 10/10 | 10/10 | 10/10 | 50 of 50 countable |
| `cli/claude-sonnet` | 9/10 | 1/10 | 10/10 | 10/10 | 10/10 | 40 of 50 countable |
| `codestral-latest` | 0/10 | 0/9 + 1 lane error | 2/10 | 0/10 | 1/9 + 1 lane error | 3 of 48 countable |

Column key: SWE is `public.swe.martinblech-xmltodict-issue-257`, RAG is
`vvdex.knowledge.grounded-rag-1`, Memory is
`vvdex.knowledge.memory-fact-update-1`, Harness is
`vvdex.harness.fault-recovery-1`, Browser is `vvdex.browser.order-desk-1`.

Lane totals with 95% Wilson intervals, read from `summary.json`:

| Lane | Certified passes | Rate | 95% CI |
| --- | --- | --- | --- |
| `cli/codex` | 50 of 50 countable | 100.00% | 92.87% to 100.00% |
| `cli/claude-sonnet` | 40 of 50 countable | 80.00% | 66.96% to 88.76% |
| `codestral-latest` | 3 of 48 countable | 6.25% | 2.15% to 16.84% |

These are campaign aggregates across these five exams. They are not a ranking of
the models.

`python3 examples/check-readme-matrix.py` rebuilds this table from
`reports/fc-d89e429d2781/summary.json`, checks every cell against the
independent per-cell counts in `campaign.json`, and fails if the table above
differs by a character.

## 4. The five capability families

Each exam belongs to one family, and no family appears twice.

| Family | Exam | What it asks |
| --- | --- | --- |
| Software repair (public OSS SWE) | [`public.swe.martinblech-xmltodict-issue-257`](exams/public.swe.martinblech-xmltodict-issue-257/) | Fix a real defect from a public repository against a frozen parent tree, graded by a hidden suite. |
| Grounded retrieval (RAG) | [`vvdex.knowledge.grounded-rag-1`](exams/vvdex.knowledge.grounded-rag-1/) | Answer only from the supplied corpus, cite exactly the supporting sources, and say when the corpus has no answer. |
| Cross-session memory | [`vvdex.knowledge.memory-fact-update-1`](exams/vvdex.knowledge.memory-fact-update-1/) | Answer from the newer authoritative roster rather than the stale carried memory, and acknowledge the change. |
| Tool and harness fault recovery | [`vvdex.harness.fault-recovery-1`](exams/vvdex.harness.fault-recovery-1/) | Carry out a code fix through a deliberately unreliable tool loop, graded from the recorded tool trace. |
| Browser and computer use | [`vvdex.browser.order-desk-1`](exams/vvdex.browser.order-desk-1/) | Correct one order in a real admin application, driven through a real headless browser. |

## 5. How Forge works

1. **Author.** An exam is written as a task package: a seed workspace, a
   contract that declares the runtime and the tools on offer, a reference
   solution, a hidden grader and a set of adversarial probes.
2. **Certify.** The chain in section 6 runs before any model sees the exam. An
   exam that fails a stage is not promoted.
3. **Freeze.** The agent-visible tree is hashed. The hash is on every receipt as
   `frozenTreeSha256`, and the exam's own content fingerprint is the join key
   that every later artifact names.
4. **Run.** Each rollout runs in a container with `network: none`, a read-only
   root, `cpus: 1`, `memory: 512m`, `pids: 128` and a per-command timeout of 120
   seconds. The model writes only inside the declared writable paths and acts
   only through the actions the exam advertises.
5. **Grade.** Grading happens after submission, in a separate step, in its own
   container with no network. The graded tree's hash must equal the submitted
   workspace's hash or the grade is voided.
6. **Seal.** The outcome becomes a record whose digest is a SHA-256 over its own
   canonical JSON with the digest slot zeroed. The campaign id is a digest over
   the sorted record digests, so the same records always name the same campaign.

## 6. The certification model

Six stages, each recorded in `exams/<examId>/certification-receipt.json`, and
each receipt names the evidence field every value came from in its own `sources`
block.

| Stage | Recorded on all five historical campaign receipts |
| --- | --- |
| Reference pass | rate 1.0, expected 1.0, over n=2 |
| Baseline fail | rate 0.0, expected 0.0, over n=2 |
| Grader controls | `distinguished: true`; case count per exam, below |
| Attack probes | 10 probes, 10 blocked, 0 trivial exploits, `passedForPromotion: true` |
| Freeze | a `frozenTreeSha256` naming one tree, and a pinned `sha256:` image digest |
| Runtime policy | network deny, agent-tree-only filesystem, read-only root |

Reference pass is recorded as a boolean-shaped condition rather than a score:
the reference solution passes the hidden grader, and the untouched tree fails
it. Both must hold, and both are on the receipt.

Grader control cases are 7 on `public.swe.martinblech-xmltodict-issue-257`,
`vvdex.knowledge.grounded-rag-1` and `vvdex.knowledge.memory-fact-update-1`, 9
on `vvdex.browser.order-desk-1`, and 12 on `vvdex.harness.fault-recovery-1`. The
families with more ways to fake an end state carry more cases.

A grader verdict is not yet a result. A rollout counts as a certified pass only
when five conditions hold together: the grader accepted the submitted workspace,
containment was verified, provenance is complete, no integrity invariant fired,
and no verdict-bearing harness suspicion is open. Outcomes are named exactly:
certified pass, model fail, lane error, withheld, invalid. Only the first two
enter the counts, in both directions.

## 7. Security and the hidden-evaluation boundary

An exam survives only while its answers stay out of the world. Two problems are
handled separately: keeping the taker inside the box, and keeping the exam's
material out of what gets published.

Containment is verified per rollout, never inferred from configuration. Provider
lanes are contained by construction. Agent CLI lanes run on the host and are
audited after the run from their own session stores. A lane whose store cannot
be read is withheld, and a lane whose CLI keeps its own host toolset with no way
to remove it is excluded as uncertifiable. For campaign `fc-d89e429d2781` all
three lanes read `verified_contained` on all five records.

This is not theoretical. On 2026-09-01 an integrity audit of our own harness
found an agent CLI lane that kept its full host toolset. Every pass Forge had
recorded before that date was withdrawn, and 232 historical rollouts were
reclassified from stored evidence alone: 104 verified, 115 unverified, 13
invalid. The original evidence was annotated rather than rewritten. The
disclosure is public at <https://vvdexops.com/integrity/>.

Every export is scanned before publication and fails closed. The scans look for
private directory and file names, absolute host paths, the answer values read
out of each exam's own key at scan time, and long lines lifted out of each
exam's host-only tree. On the harness family a further scan blocks the fault
schedule's own mechanics, because that schedule is the exam. What the scans
found in this package, including the finding that changed the report model, is
written up in [SECURITY.md](SECURITY.md).

## 8. What is public, and what is private

Public in this repository:

* one proof descriptor per exam: what it measures, its content fingerprint,
  runtime class, tool categories, limits, ownership and disclosure level;
* the certification receipt for each exam;
* the sealed record digests, and for every record a sanitized projection:
  identity, lanes, per-rollout outcome, stages, elapsed time and tool-name
  counts, and result counts;
* the campaign reports, `campaign.json` and `summary.json`;
* the upstream issue text and licence of the one third-party exam.

Private, and absent from this repository: task statements and task packages,
seed workspaces, corpora, question sets and browser worlds, visible test
implementations, reference solutions and expected values, hidden tests and
hidden grader source, attack probes and canaries, raw model submissions,
answer-bearing diffs and private transcripts. Each exam's own descriptor lists
this under `publicDisclosureLevel.withheldFromThisExport`.

The four VVDex-authored exams carry a four-file descriptor and nothing else:
`exam.public.json`, `certification-receipt.json`, `provenance.public.json` and
`VERIFY.md`. Where a public artifact would otherwise show submitted content it
says so in as many words, rather than leaving a gap that reads as a broken
document.

## 9. Verification, and reproducing the proof

Python 3 standard library, plus `shasum` or `sha256sum`. No engine, no install,
no network except the last command.

```bash
git clone <this repository> forge-proof && cd forge-proof

# 1. every file against the manifest, and every published record digest
./verify.sh

# 2. the five-exam summary: matrix, lane totals, record digests
python3 examples/inspect-campaign.py reports/fc-d89e429d2781/summary.json

# 3. the published matrix, rebuilt from the campaign artifacts and diffed
#    against the table in this README
python3 examples/check-readme-matrix.py

# 4. one record's digest, cross-checked against every place stating it
examples/verify-record.sh reports/fc-d89e429d2781/records/fr-20260902-6616b188.digest.txt

# 5. every vvdexops.com URL this repository names (needs the network)
examples/check-links.sh
```

[VERIFICATION.md](VERIFICATION.md) walks the same checks by hand: the record
digest, a report's self-check, the fingerprint joins across receipt, contract
and record, and the campaign id. It also separates the two kinds of checking,
because they are not the same and only one of them can be run here.

**Available publicly:** artifact and digest verification. Every file listed in
`MANIFEST.json` hashes to the SHA-256 stated for it, and every record digest
string agrees with itself across the `.digest.txt` file, the record projection,
the campaign summary, the report manifests and the verification receipts.

**Available to a holder of the canonical record, under agreement:** recomputing
a record digest from the sealed bytes. No canonical record body is published
here, on any record, so that check cannot be run from this repository and
nothing here claims it can. Access to sealed evidence is arranged through
<https://vvdexops.com/connect/>; no terms are promised in advance.

## 10. Public OSS example: xmltodict issue #257

One exam is built on public material, and only because its ownership says so.
`public.swe.martinblech-xmltodict-issue-257` is issue #257 of
`martinblech/xmltodict`, an MIT-licensed project. The upstream issue, its fix
and the pull request are public, so the task statement, the upstream `LICENSE`
and the public contract travel with the exam.

That class covers the task, not the grader. The hidden tests written against
that public bug, and everything else the certification chain is built from, are
VVDex's own work, so this exam's sealed record body is withheld like every
other. What is published for it is the record digest and a sanitized
projection.

[`examples/reproduce-xmltodict.md`](examples/reproduce-xmltodict.md) walks it end
to end: the task statement the model received, the upstream issue and pull
request, the parent commit the tree was frozen at, and the point where the road
ends, which is the hidden suite. The exam construction around that public task
is VVDex's own work and is not covered by the upstream licence. See
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## 11. What Forge proves

Only what the records and the receipts substantiate.

* **The certification chain ran, per exam, and its results are recorded.** Each
  receipt carries the reference-pass and baseline-fail outcomes, the grader
  control-case count and whether the cases were distinguished, the probe count
  and how many were blocked, the frozen tree's SHA-256 and the runtime policy.
* **Containment was verified on every counted rollout.** Each record's
  containment block names a verdict per lane. For `fc-d89e429d2781` all three
  lanes read `verified_contained` on all five records.
* **Grading is deterministic.** No exam in this package is graded by a language
  model judging another language model. Grading is hidden tests, an end state
  compared to a frozen key, or a recorded tool trace.
* **The record digests agree wherever they are stated.** A record's digest is
  the same string in the `.digest.txt` file, the record projection, the campaign
  summary, the report manifest and the verification receipt, and the campaign id
  is a digest over the sorted record digests. Recomputing a digest from the
  sealed bytes needs the canonical record, which is not published here.
* **Lane errors are separated from model failures.** A provider or CLI failure
  never enters a capability count in either direction.

## 12. What Forge does not claim

* **No universal capability ranking.** These are five task-specific exams on two
  dates. Nothing here ranks the models in general.
* **No claim about models outside these exams**, or about other versions,
  settings, scaffolds or prompts of the same models.
* **No claim that the exams are unbreakable.** The attack suite proves the
  probes we wrote were blocked. A rule list catches what it describes, and a
  determined attacker is not a scripted one.
* **The intervals are wide.** Ten rollouts per cell is ten. A 10 of 10 cell has a
  95% Wilson interval of 72.3% to 100%, and where two lanes' intervals overlap,
  nothing here separates them.
* **The receipts have unavailable fields.** `certificationEvidenceDigest` reads
  `"unavailable"` on all five historical campaign exams, because the seal stage was not recorded on
  these records and no digest was manufactured to fill the column. On
  `vvdex.browser.order-desk-1` and `vvdex.harness.fault-recovery-1`,
  `certificationVersion` and `certifiedAt` read `"unavailable"` as well.
* **The engine is not published.** You can verify the outputs published here.
  You cannot re-run the chain from this repository, and this repository does not
  let you reproduce a rollout.

## 13. Live reports

* Campaign report, `fc-d89e429d2781`: <https://vvdexops.com/reports/fc-d89e429d2781/>
* Executive PDF: <https://vvdexops.com/reports/fc-d89e429d2781/fc-d89e429d2781-executive.pdf>
* Full PDF: <https://vvdexops.com/reports/fc-d89e429d2781/fc-d89e429d2781.pdf>
* Featured exam pages: <https://vvdexops.com/featured/>
* Integrity disclosure: <https://vvdexops.com/integrity/>
* Verify a record in the browser: <https://vvdexops.com/verify/>
* Terms: <https://vvdexops.com/terms/>

## 14. Ownership and terms

© VVDex. All rights reserved. Public materials are provided for viewing,
evaluation and verification. Reuse, redistribution, derivative benchmark
creation, training use, republication or commercial use requires written
permission unless a specific file states otherwise.

VVDex-authored evaluation material stays proprietary. Publication of a result
does not place an exam, or any part of it, under an open-source or open-content
licence, and this repository is not an open-source release of Forge. The one
exception is the upstream project's own material in the xmltodict exam, which
keeps the upstream MIT licence.

While this repository is public on GitHub, GitHub's Terms of Service grant every
user of the Service certain rights in it, including the right to view it and to
fork it within the Service. Nothing here is intended to remove or narrow those
rights, and to the extent anything reads as though it does, GitHub's Terms
govern instead. Those rights are the ones GitHub's Terms give and no more:
making this repository public grants no additional licence in VVDex materials,
open-source or otherwise, and no permission to reuse, redistribute, republish,
build a derivative benchmark from, or train on them outside the Service.
[TERMS.md](TERMS.md) states this in full.

* [TERMS.md](TERMS.md), who owns what is published here and what may be done
  with it.
* [OWNERSHIP.md](OWNERSHIP.md), the file-level ownership and terms map, every
  path with its owner and terms.
* [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md), the one upstream project and
  the line between its rights and VVDex's exam design.
* [CLAIMS.md](CLAIMS.md), every number in this repository's documents mapped to
  the artifact and field it is read from.

The other documents here: [ARCHITECTURE.md](ARCHITECTURE.md) for the lifecycle
and the evidence model, [METHODOLOGY.md](METHODOLOGY.md) for the chain stage by
stage and the statistics, [SECURITY.md](SECURITY.md) for isolation and the leak
controls, [VERIFICATION.md](VERIFICATION.md) for what a reader can check.

Built and operated by VVDex, Magdeburg, DE. Written permission and access to
sealed evidence under agreement are arranged through
<https://vvdexops.com/connect/>.
