# Security and containment

Two separate problems. Keeping the taker inside the exam, and keeping the exam's
answers out of the world. This document states how each is handled, what is
withheld, and where a verifier's reach ends.

## Isolation and containment

**The agent box.** A rollout runs in a container built from the exam's frozen
tree. Every public contract in this repository declares the same policy shape:

| Field | Value on all five exams |
| --- | --- |
| `freeze.networkPolicy` | `deny` |
| `freeze.fsPolicy` | `agent-tree-only` |
| `freeze.secretsPolicy` | `job-envelope-only` |
| `freeze.resourceLimits.network` | `none` |
| `freeze.resourceLimits.readOnlyRoot` | `true` |
| `freeze.resourceLimits.cpus` | `1` |
| `freeze.resourceLimits.memory` | `512m` |
| `freeze.resourceLimits.pids` | `128` |
| `freeze.imageDigest` | a pinned `sha256:` image digest |

Writable paths are declared per exam and are the only paths the model may write.
The model acts only through the actions the exam advertises; the record's
`limits.advertisedTools` is the list, and it differs per family (the browser exam
offers browser actions and no writing tool at all).

**The grade box.** Grading runs after submission, as a separate step, in its own
container with no network. The graded tree's hash must equal the submitted
workspace's hash or the grade is voided. The model never sees the hidden tests or
the reference solution during a rollout.

**The browser box.** For `vvdex.browser.order-desk-1` the application and a real
headless Chromium run inside the model's own network-none box from a frozen
state. The application's state, its audit log and the engine's action ledger sit
outside the model's writable paths, so the grader can require that every change
was driven through the application rather than written into a file.

**The isolation note, stated honestly.** Each receipt carries the certifying
runtime's own note. On these exams it reads: the certifying runtime is a local
Docker runtime on Colima (a Linux VM); isolation is from the Mac host except
explicit bind-mounts of the work directory under a per-user work path; the home
directory, the Docker socket and host secrets are not mounted; runtime network is
`--network=none`. That is what it is, and it is written on the receipt rather
than described as something stronger.

**Containment of the taker.** Provider API lanes are contained by construction:
the provider sees only what the harness sends. Agent CLI lanes run on the host
and are audited after the run from their own session stores, for tool use,
answer-key access, cross-session memory and network use. A lane whose store
cannot be read is withheld. A lane whose CLI keeps its own host toolset with no
way to remove it is excluded as uncertifiable. Containment is never inferred from
configuration.

This is not theoretical. On 2026-09-01 an integrity audit of our own harness
found an agent-CLI lane that kept its full host toolset, reading its own prior
transcripts and, on one exam, the reference solution. Every pass Forge had
recorded before that date was withdrawn — 232 historical rollouts reclassified
from stored evidence, 13 invalid, 115 unverified, 104 verified — and the original
evidence was annotated rather than rewritten. The disclosure is public:
<https://vvdexops.com/integrity/>.

## What is hidden, and why

Publishing any of the following would end the exams it belongs to. None of it is
in this repository.

| Withheld | Why |
| --- | --- |
| Hidden tests | they are the grade; publishing them makes the exam a lookup |
| Reference solutions | the answer key |
| Graders, their configuration and entry command lines | a published grader is a target, and the invocation names the hidden suite's directory |
| Grader control cases | they are near-misses built from the answer |
| Attack probes and their overlays | they are a map of what we tested and how |
| Canary tokens and their registry | a published canary detects nothing |
| The engine (`vvdex-env`) and the Studio | the certification chain, the containment auditor, the verdict state machine and the report renderer |
| Runnable exam packages | they exist to run an exam; this repository exists to verify a result |
| Full transcripts | for answer-key exams a diff is the answer |
| Campaign workspaces | they hold all of the above |

Report transcripts are redacted: a request for a hidden path is recorded as
`[HIDDEN PATH REQUESTED]`, never printed.

## Leak controls

The exam exports in `exams/` were produced by an **allowlist**, not by a
filtered copy, and the allowlist depends on who owns the exam.

A **VVDex-authored** exam exports four files and no others: `exam.public.json`,
`certification-receipt.json`, `provenance.public.json` and `VERIFY.md`. Its task
statement is never read into a published byte, and no contract world travels
with it.

An exam whose ownership declaration names a public upstream repository AND its
licence exports the richer set as well: the task statement (`ISSUE.md` or
`TASK.md`), `contract.public.json`, the upstream `LICENSE` as shipped in the
frozen tree, `THIRD_PARTY_NOTICES.md` and `REPRODUCE.md`.

An exam with no declaration gets the proprietary shape. The absence of a licence
is not permission.

After writing, each export is scanned twice and fails closed:

1. **Private names.** Ten patterns naming the private directories and files: the
   reference-solution directory, the grader directory, the hidden-test
   directory, the probe directory, the grader control-case file, the canary
   registry, the reference-values file, the reference command script, the attack
   directory and the release directory. The patterns are slash- and
   word-anchored, so a legitimate receipt field such as `goldPasses` or
   `graderControls` is not a false positive while a real path reference is
   caught. The literal patterns live in the engine's exporter and are not
   restated here, because a document that spells them out is a document this
   package's own leak scan has to make an exception for.
2. **Private content.** Lines lifted out of the exam's own host-only directories
   — the canary token, hidden-test lines, gold lines — compared against every
   exported byte. A scan that cannot find private material to compare against is
   not a pass: the caller is told which sources were absent.

Absolute host paths are refused anywhere in a public file: the macOS and Linux
home-directory roots, the operator's install prefix, and the two temporary-
directory roots a build can leak. A hit on any of them deletes the export and
fails the publication.

### Two things this repository's own scan found

A scan is only worth reporting when it is told what its findings were.

1. **The full campaign report embedded per-rollout submission diffs.** On an
   answer-key exam a submission diff is the answer. The first build of this
   package carried the grounded-retrieval and cross-session-memory gold answers
   in that PDF's own text, plus the browser exam's target record values. The
   report model was changed rather than the file: a submission on an exam whose
   disclosure class is not `public_source` is replaced, in place, with a stated
   withholding. In `reports/fc-d89e429d2781/fc-d89e429d2781.html` that notice
   stands 120 times, one per proprietary rollout: four exams, three lanes, ten
   rollouts each. The one exam whose submissions are published is
   `public.swe.martinblech-xmltodict-issue-257`, whose graded artefact is a
   patch against a public repository. Rerunning this package's leak scan over
   every published byte, PDFs read through `pdftotext`, finds none of the eight
   answer values and none of the private-content strings rebuilt from the
   exams' own host-only trees.
2. **`bundleRel` in the sealed records.** Each canonical record carries a
   relative path naming where its run bundle sits inside the private workspace,
   of the form `<release dir>/<version>/benchmarks/<runId>`. It matches one of
   the private-name patterns. It is not a host path and it carries no private
   material, and it cannot be edited: the canonical bytes are what the record's
   digest was computed over, and the same bytes are already served from the live
   site. It stands, and it is named here rather than quietly excepted.

### Why the export shape was inverted

The reason is on the record: before 2026-09-02 the proof
package carried three exams as runnable taskset packages, and those packages
dragged the grade-box command line, the staging and anti-cheat logic, the
grader's own configuration, and — in three files — the host build path of the
machine that exported them. A denylist over a tree that size is a promise that
every future file will be remembered.

## What a verifier can check

- That every published record's canonical bytes hash to the digest stated beside
  them.
- That each report states its own digest, invertibly, and that the stated digest
  reproduces.
- That the exam fingerprint agrees across the certification receipt, the public
  contract, the sealed record and the exam's page on the live site.
- That the campaign id is the digest over the sorted record digests, so the
  documents belong to these records and no others.
- That the counts in `campaign.json` and `summary.json` are the counts in the
  records.
- That the exam's task statement is byte for byte what the model received, and
  that the frozen tree's SHA-256 on the receipt names one tree.

## What a verifier cannot check

Stated plainly, because the list is the honest boundary of this package.

- **That the hidden tests are fair, or that they test what the receipt says.**
  They are not published. What is published is that a set of controls landed on
  known verdicts.
- **That the reference solution is the only correct answer.** It is not
  published, and a deterministic grader marks a different-but-correct route as
  wrong.
- **That the exam is unbreakable.** The attack suite proves the probes we wrote
  were blocked.
- **That a rollout happened as described.** The transcripts beyond tool-and-path
  traces are not published, and the engine that produced the record is not
  published. A record attests to its own bytes; it does not attest to itself.
- **That the frozen tree matches the receipt's `frozenTreeSha256`.** The tree is
  the exam and it is not shipped here. The hash names it; it does not let you
  recompute it.
- **The seal.** `certificationEvidenceDigest` reads `"unavailable"` on all five
  exams. There is no bundle digest to check, and none was invented.

## Responsible disclosure

If you find a leak in this package, a way to defeat one of these exams, or a
published number that does not reproduce from the files here, write to
**vamsi@vamsivenkatesh.com**. Please include the file and the exact bytes or
command that show it. A digest that does not reproduce is the strongest possible
report: the digests are the arbiter, and an artifact whose digest does not
reproduce is not ours.
