# Methodology

What an exam has to survive before a score off it means anything, and what the
numbers in this repository are counted over. Each stage below states what it
proves and what it does not, because a stage described only by what it catches
teaches a reader to trust it further than it goes.

## The certification chain

Run per exam, before any model sees it. The recorded outcome of each stage is on
`exams/<examId>/certification-receipt.json`.

**Contract.** The exam declares its identity and version, family, grader entry
point, licence and classification. The declaration is validated before any other
stage runs.
*Does not prove* that the exam is any good. It proves the exam is well-formed and
that its handling rules were stated up front rather than decided later.

**Gold proof.** The reference solution must pass the hidden grader, the untouched
tree must fail it, the grader must not be visible to the model, and no part of
the reference may leak into the tree the model is given. Recorded on the receipt
as `referencePass` and `baselineFail`; on all five exams here, rate 1.0 and rate
0.0 respectively, each over n=2.
*Does not prove* that the exam is hard, or that the reference is the only correct
answer. It rules out the exam nobody can pass and the exam that is already passed
before the model starts.

**Grader controls.** Submissions that must land on known verdicts: untouched tree
(fail), reference (pass), incomplete fix (fail), plausible lookalike (fail),
planted test hook (fail), planted reward file (fail), reference again after the
tampering attempts (pass). Families with more ways to fake an end state carry
more cases. The two wrong-but-plausible cases must fail for different reasons,
read from the failing test sets rather than inferred from an exit code. Every
receipt here records `distinguished: true`, and `graderControls.cases` reads 7
on `public.swe.martinblech-xmltodict-issue-257`,
`vvdex.knowledge.grounded-rag-1` and `vvdex.knowledge.memory-fact-update-1`, 9
on `vvdex.browser.order-desk-1`, and 12 on `vvdex.harness.fault-recovery-1`.
*Does not prove* that no wrong answer passes. It proves the specific wrong answers
we could think of do not, and that the grader ignored material planted to bend
it. A probe set is a floor.

**Attack suite.** Scripted probes attack the grade rather than the task:
rewriting or deleting tests, planting collection hooks, reaching for the answer
key, writing outside the allowed paths, opening the network. The exam passes only
when no probe finds a trivial exploit and the reference still passes after the
whole suite has run. Recorded on all five receipts as 10 probes, 10 blocked, 0
trivial exploits.
*Does not prove* that the exam is unbreakable. It proves the cheap breaks are
closed. A determined attacker is not a scripted one.

**Canary.** Each hidden test file carries a unique marker registered in a
host-only file the model can never reach. If exam material surfaces where it
should not, the marker names the file it came from.
*Does not prove* that the exam has not leaked. A canary is detection, not
prevention, and it detects only a leak that carries the marker.

**Publication scan.** Before any exam material is shown to anyone, a scanner
reads the model-facing tree and the published material against a pattern list and
against the reference solution byte for byte, and refuses on a single finding.
*Does not prove* that the exam contains nothing sensitive. It proves that nothing
matching the rules we wrote was found.

**Freeze.** What passes is frozen: a hash over the tree the model is given
(`frozenTreeSha256`), the parent commit where the exam comes from a repository,
and the container image digest where the freeze was taken inside a container. A
freeze taken without a container runtime records a null image digest honestly and
must be re-frozen by a promotion pass.
*Does not prove* anything about a score. It is what makes a score quotable: a
result belongs to one freeze.

**Container promotion.** The whole chain is re-run inside a network-none
container and the exam is sealed against the image it was certified with.
*Does not prove* that every exam is promoted. It is a separate pass, recorded per
exam, and where it has not run the exam says so.

**Seal.** The evidence set is sealed under one bundle digest inside the source
workspace. **For all five exams in this repository this stage was not recorded**,
and each receipt's `certificationEvidenceDigest` reads `"unavailable"` rather
than carrying a manufactured digest.

## From a grader verdict to a certified result

Certifying an exam is half the job. A score is quoted only when the run is
certified too, and that is five conditions, each recorded separately on every
rollout.

1. **Grader.** The hidden tests accepted the submitted workspace, graded in a
   separate container with no network. The graded tree's hash must equal the
   submitted workspace's hash or the grade is voided.
2. **Containment.** The taker was proven to have acted only through the exam's
   actions. Provider API lanes are contained by construction. Agent CLI lanes are
   audited after the run from their own session stores for tool use, answer-key
   access, cross-session memory and network use. A lane whose store cannot be
   read is withheld; a lane whose CLI keeps its own host toolset with no way to
   remove it is excluded as uncertifiable.
3. **Provenance.** The record carries the exam identity and revision fingerprint
   the result belongs to.
4. **Integrity invariants.** Evidence mismatch, isolation breach, an unsubmitted
   green workspace, a zeroed or altered digest: any of these and the row is
   invalid or withheld, never a pass.
5. **Harness review.** The run judges itself (API-failure share, identical
   failure across unrelated providers, starvation, containment). Each fired rule
   is classified diagnostic or verdict-bearing; a verdict-bearing suspicion the
   record cannot clear from its own certification receipts withholds the affected
   cells. The rule on every record here reads: *a suspect examiner may not blame
   the model.* On all five records in campaign `fc-d89e429d2781`,
   `harnessReview.suspect` is `false` and `withheldCount` is 0.

## Outcome names

Exactly five, and only the first two enter capability counts, in both directions.

| Outcome | Meaning |
| --- | --- |
| `certified_pass` | all five conditions held |
| `model_fail` | a real result under verified containment |
| `lane_error` | provider or CLI failure, not a model result |
| `withheld` | conditions unproven; neither a pass nor a failure |
| `invalid` | an integrity invariant fired |

Campaign `fc-d89e429d2781` totals: 150 attempts, 148 graded, 93 `certified_pass`,
55 `model_fail`, 2 `lane_error`, 0 `withheld`, 0 `invalid`.

## Stage semantics, and applicability

Every rollout is placed on a six-stage funnel: Inspected, Edited, Ran tests,
Submitted, Graded, Passed hidden tests. The funnel is the primary reading of a
run, because where a model stops says more than a single pass percentage does.

A stage is applicable to an exam only if the exam **offers** the capability the
stage measures, read from the record's own `limits.advertisedTools`. The Edited
stage requires a writing tool (`write_file`, `edit_file` or `run_command`); the
Ran tests stage requires `run_tests`. A stage the exam never offered renders
**N/A**, never `0 of N`, which would read as a failure to do something the exam
never asked for.

The browser exam in this repository is the worked example. Its
`advertisedTools` are `list_files, read_file, submit, browser_open,
browser_snapshot, browser_click, browser_fill, browser_select, browser_press,
browser_back`: no writing tool, no test tool. Its funnel counts for Edited and
Ran tests are 0 on every lane, and those two stages are N/A for that exam rather
than zeros to be read as failures.

## Denominators

**Lane errors leave every denominator.** A rollout the lane ended — a provider
API failure or an infrastructure failure — is reported but never graded, so it
is in no rate, no interval and no pass@k. The records state this themselves:

> n counts evaluable rollouts only: attempts minus lane errors. A rollout the
> lane ended (API or runtime failure) is reported but never graded, so it is in
> no rate, interval or pass@k.

In campaign `fc-d89e429d2781` this is why the `codestral-latest` lane reads 3 of
48 countable and not 3 of 50: two of its rollouts were lane errors, one on the
RAG exam and one on the browser exam. Both are shown beside the fractions in the
matrix — `0/9 + 1 lane error`, `1/9 + 1 lane error` — and neither is a model
failure.

## Intervals

Rates carry a 95% Wilson score interval (z = 1.959963984540054), not the normal
approximation. The records state the reason:

> Wilson score interval, not the normal approximation. The normal approximation
> collapses to a zero-width interval at 0 successes, which would print a 0/2 run
> as '0%, certain'.

`pass@k` is unbiased, `1 - C(n-c, k) / C(n, k)`, and reported only for k up to
the number of rollouts actually run: there is no pass@5 in a 2-rollout run.

Below the low-N threshold (10 rollouts) a report shows raw counts and refuses to
present percentages as stable rates. No record's canonical bytes are published
here, so this repository substantiates `lowN` through the published projections,
each of which carries `lowN: false` per lane. `lowNThreshold` is a sealed-record
field, and a holder of the sealed records reads it there. The historical
campaign `fc-8626f712e26f` is a one-rollout-per-lane run and its summary carries
no lane intervals at all.

Ten rollouts is still ten. A 10/10 cell has a 95% Wilson interval of 72.3–100%.
Where two lanes' intervals overlap, nothing in this repository ranks them.

## Family-aware wording

The reports and public pages describe a run in the words of the exam's own
family, not in one template. A browser exam's unaccepted submission is *a final
application state*, not *a change*; its workflow phrase is *inspect and open the
application, drive it through the declared browser actions to the required state,
submit, and be accepted by the independent grader*, while an editing exam's is
*inspect the workspace, produce a correct edit, verify it with the visible tests,
and submit*. The limitations section of each exam page is written per family
too, and this repository reproduces those per-family limitations in
[README.md](README.md).

The point is not style. A run described in a family's wrong vocabulary invites a
reader to count a stage the exam never had.

## Determinism of publication

- A record's digest is SHA-256 over its canonical JSON (keys sorted, separators
  `,` and `:` with no spaces, non-ASCII escaped) with `recordDigest.sha256` set
  to sixty-four `0` characters. That serialization is not published here; a
  holder of the sealed record hashes it and reaches the digest in the
  `.digest.txt` file.
- The campaign id is a digest over the sorted record digests. The same records
  always name the same campaign, and a changed record names a different one.
- Campaign documents are regenerated from records only, and fail generation if
  they disagree with them. Regenerating the package twice from the same records
  produces the same bytes, PDFs included.
- Verification has three verdicts, and the middle one matters: a record written
  before the digest mechanism existed reads `unattested`, never `failed`.
  Reporting an absent digest as tampering teaches a reader to ignore the check.
  Unattested records are refused for publication.

## Grading is deterministic

No exam in this repository is graded by a language model judging another language
model. A grader is a program: hidden tests executed against the submitted
workspace, an end state compared exactly to a frozen key, or a recorded tool
trace read under a declared fault schedule. Two families stood blocked until
2026-09-02 for exactly this reason — browser use and harness evaluation — and
each now carries a certified exam because the deterministic grader was built
first.

The cost belongs in the same paragraph as the benefit: a deterministic grader
marks a correct answer reached through a different entry point as wrong, and
where a hidden suite grades one module rather than a whole product, that limit is
written on the exam.

## Contamination

An exam built from a public upstream fix is public upstream: the issue, the pull
request and the merge commit are all on the internet, and a model may have seen
them. That applies to `public.swe.martinblech-xmltodict-issue-257` in this
repository, whose issue and pull request are linked from its
`provenance.public.json`. Each exam records where its fix sits relative to a
model's training cutoff rather than averaging that into a headline. Held-out
variants are the answer to contamination; the published provenance and contract
files in this repository carry no held-out-variant claim for any of the five
exams.
