# VVDex Forge — proof package

**5 certified evaluation environments · 5 families · 150 attempts · 148 graded rollouts · 93 certified passes**

Campaign `fc-d89e429d2781`, published 2026-09-02. Every number here is read
from [`reports/fc-d89e429d2781/summary.json`](reports/fc-d89e429d2781/summary.json)
and [`reports/fc-d89e429d2781/campaign.json`](reports/fc-d89e429d2781/campaign.json),
which are regenerated from the sealed records in
[`reports/fc-d89e429d2781/records/`](reports/fc-d89e429d2781/records/) and from
nothing else.

These are task-specific evaluations across the five exams described here.
They are not a universal model leaderboard. A cell below says how one model lane
did on one exam, ten times, on 2026-09-01 and 2026-09-02, and it says nothing
about any other task.

## The evidence

| Where | What it is |
| --- | --- |
| [`reports/fc-d89e429d2781/records/`](reports/fc-d89e429d2781/records/) | the digest each of the five sealed evaluation records states about itself, and — for the one exam whose graded artefact is public upstream source — its canonical bytes. The other four records' bytes are withheld: a sealed record carries an excerpt of what each rollout submitted, and on those exams the submission is the graded answer |
| [`reports/fc-d89e429d2781/`](reports/fc-d89e429d2781/) | the campaign report (full and executive), the five standalone executive reports, `campaign.json`, `summary.json` |
| [`exams/`](exams/) | one **proof descriptor** per exam: what it measures, its immutable fingerprint, runtime class, tool categories, limits, ownership, disclosure level, and its certification receipt. The exams themselves are not here |
| [`reports/fc-3194f803055c/`](reports/fc-3194f803055c/), [`reports/fc-72fe6f91c29e/`](reports/fc-72fe6f91c29e/), [`reports/fc-8626f712e26f/`](reports/fc-8626f712e26f/) | three superseded campaigns, in the same shape as the current one. Each report states HISTORICAL on its own cover |
| [`MANIFEST.json`](MANIFEST.json) | the SHA-256 of every file in this repository. `./verify.sh` checks all of them and recomputes every published record digest |

Check a record in one command:

```bash
examples/verify-record.sh reports/fc-d89e429d2781/records/fr-20260902-6616b188.canonical.json
```

Print the matrix and the lane totals from the campaign summary:

```bash
python3 examples/inspect-campaign.py reports/fc-d89e429d2781/summary.json
```

Check the whole package against its own manifest:

```bash
./verify.sh
```

[`examples/reproduce-xmltodict.md`](examples/reproduce-xmltodict.md) walks the
one public-OSS exam end to end: what an outside reader can reproduce, and where
the road ends.

## What this repository is not

It is **proof**, not a distribution of exams. VVDex Forge is not an open-source
exam repository, and publishing a result grants no licence to the instrument
that produced it.

For the four VVDex-authored exams this repository carries a four-file proof
descriptor and nothing else: no task statement, no corpus or question set, no
seed workspace or browser world, no visible or hidden tests, no reference
solution, no grader, no attack probes, no raw model submissions and no
answer-bearing diffs. Where a public artifact would otherwise show submitted
content it says so in as many words — *Submission content withheld —
proprietary evaluation material.* — rather than leaving a gap that reads as a
broken document.

One exam is different, and only because its ownership says so: the xmltodict
task is third-party open source under the upstream MIT licence, so its task
statement, its upstream `LICENSE` and its public contract travel with it. See
[TERMS.md](TERMS.md), [OWNERSHIP.md](OWNERSHIP.md) and
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## What this is

VVDex Forge is an evaluation system for AI agents. An exam is certified before
any model sees it: the reference solution must pass the hidden grader, the
untouched tree must fail it, the grader must land a set of control submissions
on known verdicts, and an attack suite must fail to reach the grader or the
answer key. What passes is frozen under a content hash, and every later result
names that hash.

A grader verdict is not a result. A result is certified only when five separate
conditions hold on that rollout: the grader accepted the submitted workspace,
containment was verified, provenance is complete, no integrity invariant fired,
and no verdict-bearing harness suspicion is open. Outcomes are named exactly:
certified pass, model fail, lane error, withheld, invalid. Only the first two
enter the counts, in both directions.

This repository is the proof, not the product. The engine that runs the chain
(`vvdex-env`), the Studio, the hidden tests, the reference solutions, the
graders, the control cases and the attack probes are not published. See
[SECURITY.md](SECURITY.md) for what is withheld and why, and
[VERIFICATION.md](VERIFICATION.md) for what a reader can check without them.

## Why it was built this way

An evaluation number is worth what its evidence is worth. Three failure modes
motivated the design, and each one had already happened somewhere:

1. An exam that is passed before the model starts, or that nobody can pass. The
   gold proof and the baseline fail rule both out.
2. A grader that accepts a wrong answer that looks right. The control cases
   feed it near-misses that must fail, and for different reasons.
3. A run whose taker was not contained. On 2026-09-01 an integrity audit found
   exactly that in our own harness and withdrew every pass Forge had recorded
   before that date. The disclosure is public:
   <https://vvdexops.com/integrity/>.

## The matrix

Campaign `fc-d89e429d2781`, three model lanes, five exams, ten rollouts per
cell. Cells read `passes/graded`, and a lane error is stated beside the fraction
rather than folded into it.

| Model lane | SWE | RAG | Memory | Harness | Browser | Certified passes |
| --- | --- | --- | --- | --- | --- | --- |
| `cli/codex` | 10/10 | 10/10 | 10/10 | 10/10 | 10/10 | 50 of 50 countable |
| `cli/claude-sonnet` | 9/10 | 1/10 | 10/10 | 10/10 | 10/10 | 40 of 50 countable |
| `codestral-latest` | 0/10 | 0/9 + 1 lane error | 2/10 | 0/10 | 1/9 + 1 lane error | 3 of 48 countable |

Lane rates with 95% Wilson intervals, from `summary.json`:

- `cli/codex` — 50/50, 100.00%, 95% CI 92.87–100.00%
- `cli/claude-sonnet` — 40/50, 80.00%, 95% CI 66.96–88.76%
- `codestral-latest` — 3/48, 6.25%, 95% CI 2.15–16.84%

Column key: SWE = `public.swe.martinblech-xmltodict-issue-257`, RAG =
`vvdex.knowledge.grounded-rag-1`, Memory =
`vvdex.knowledge.memory-fact-update-1`, Harness =
`vvdex.harness.fault-recovery-1`, Browser = `vvdex.browser.order-desk-1`.

The two lane errors are provider or CLI failures. They are not model results and
they are outside the numerator and the denominator alike. Total attempts 150,
graded 148, certified passes 93, model fails 55, withheld 0, invalid 0.

## The five exams

| Exam | Family | What it asks |
| --- | --- | --- |
| [`public.swe.martinblech-xmltodict-issue-257`](exams/public.swe.martinblech-xmltodict-issue-257/) | software repair (public OSS SWE) | Fix a real defect from `martinblech/xmltodict` issue #257 against a frozen parent tree, graded by a hidden suite written from the upstream fix. |
| [`vvdex.knowledge.grounded-rag-1`](exams/vvdex.knowledge.grounded-rag-1/) | grounded retrieval | Answer only from the supplied corpus, cite exactly the supporting sources, and say when the corpus has no answer. |
| [`vvdex.knowledge.memory-fact-update-1`](exams/vvdex.knowledge.memory-fact-update-1/) | cross-session memory | Answer from the newer authoritative roster rather than the stale carried memory, and acknowledge the change. |
| [`vvdex.harness.fault-recovery-1`](exams/vvdex.harness.fault-recovery-1/) | harness evaluation | Work through a deliberately unreliable tool loop — transient tool errors, injected instructions, truncated writes — and be graded from the recorded tool trace on recovery and on non-compliance with the injected instructions. |
| [`vvdex.browser.order-desk-1`](exams/vvdex.browser.order-desk-1/) | browser and computer use | Correct one order in a real admin application, driven through a real headless browser inside the network-none box. |

## What Forge proves

Only what the records and receipts substantiate.

- **The certification chain ran, per exam, and its results are recorded.** Each
  receipt in `exams/<examId>/certification-receipt.json` carries the
  reference-pass rate, the baseline-fail rate, the grader control-case count and
  whether they were distinguished, the attack probe count and how many were
  blocked, the frozen tree's SHA-256, and the runtime policy. Each field names
  its source in the receipt's own `sources` block.
- **Containment was verified on every counted rollout.** Each record's
  `containment` block names a verdict per lane. For campaign `fc-d89e429d2781`
  all three lanes read `verified_contained` on all five records, with
  `breached: 0` and `unverified: 0`.
- **Grading is deterministic.** No exam in this package is graded by a language
  model judging another language model. Grading is hidden tests, an end state
  compared to a frozen key, or a recorded tool trace.
- **The records recompute.** Every `*.canonical.json` here hashes to the digest
  in the `*.digest.txt` beside it, and the campaign id is a digest over the
  sorted record digests, so the same records always name the same campaign.
  Where the bytes are withheld, the digest is still published and a holder of
  the sealed record — the customer who commissioned the run, or an auditor
  under agreement — reproduces it with `shasum -a 256` or `vvdex-env records
  verify`. `./verify.sh` reports both counts rather than passing silently.
- **Lane errors are separated from model failures.** A provider or CLI failure
  is a `lane_error` and never enters a capability count in either direction.

## What Forge does not claim

- **No universal capability ranking.** These are five task-specific exams. A
  lane's score here is a statement about these exams on these dates.
- **No claim about models outside these exams**, or about other versions,
  settings, scaffolds or prompts of the same models.
- **No claim that the exams are unbreakable.** The attack suite proves the
  probes we wrote were blocked. A rule list catches what it describes, and a
  determined attacker is not a scripted one.
- **The intervals are wide.** Ten rollouts per cell is ten. A 10/10 cell has a
  95% Wilson interval of 72.3–100%; the lane intervals above are the honest
  width. Where two lanes' intervals overlap, nothing here ranks them.
- **The receipts have unavailable fields.** `certificationEvidenceDigest` reads
  `"unavailable"` on all five exams: the seal stage was not recorded on these
  records, and no digest was manufactured to fill the column. On
  `vvdex.browser.order-desk-1` and `vvdex.harness.fault-recovery-1`,
  `certificationVersion` and `certifiedAt` also read `"unavailable"`.
- **The engine is not open source.** You can verify the outputs published here.
  You cannot re-run the chain from this repository, and this repository does not
  let you reproduce a rollout.

## Limitations, per family

Stated per family, from the same text the public exam pages are generated from.

- **Software repair (public OSS SWE).** The fix, the issue and the pull request
  are public upstream, so a model may have seen them; the exam records where its
  fix sits relative to a model's training cutoff rather than averaging that away.
  A hidden suite grades one module, not a whole product.
- **Grounded retrieval.** The grader compares answers to a key
  (case-insensitive, whitespace and a trailing period ignored) and requires the
  citation set to match exactly. A correct answer phrased outside the key's form
  is marked wrong.
- **Cross-session memory.** Both the updated answer and an acknowledgement of
  the change are required. A correct answer that does not record the change
  fails.
- **Harness fault recovery.** Grading reads the submitted workspace and the raw
  tool trace. It measures harness behaviour under a declared fault schedule, not
  code knowledge, and the schedule is applied deterministically rather than
  sampled.
- **Browser and computer use.** A correct-looking end state is not enough: every
  change must be driven through the application, so a state file written
  directly fails. The grader reads the application's end state, its audit log
  and the engine's action ledger.

Across all five: a deterministic grader marks a correct answer reached through a
different entry point as wrong. That cost is real and it belongs beside the
benefit.

## Live pages

- Campaign report — <https://vvdexops.com/reports/fc-d89e429d2781/>
- Featured exams — <https://vvdexops.com/featured/>
- Verify a record in the browser — <https://vvdexops.com/verify/>
- Integrity disclosure — <https://vvdexops.com/integrity/>
- Methodology — <https://vvdexops.com/methodology/>

## The documents in this repository

- [ARCHITECTURE.md](ARCHITECTURE.md) — the lifecycle from authoring to sealed
  evidence, the model-run architecture, and the evidence model.
- [METHODOLOGY.md](METHODOLOGY.md) — the certification chain stage by stage,
  what each stage does not prove, denominators, Wilson intervals, and the
  determinism of publication.
- [SECURITY.md](SECURITY.md) — the isolation model, what is hidden and why,
  the leak controls, and what a verifier can and cannot check.
- [VERIFICATION.md](VERIFICATION.md) — how to check a record digest, a PDF's
  self-check, the receipt fingerprint joins, and the campaign id.
- [TERMS.md](TERMS.md) — who owns what is published here and what may be done
  with it. VVDex-authored evaluation material stays proprietary; publication
  grants no open-source licence.
- [OWNERSHIP.md](OWNERSHIP.md) — the file-level ownership and terms map: every
  path, its owner, and its terms.
- [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) — the one upstream project,
  its licence, and the line between its rights and VVDex's exam design.

Built and operated by VVDex (Magdeburg, DE). Contact: vamsi@vamsivenkatesh.com
