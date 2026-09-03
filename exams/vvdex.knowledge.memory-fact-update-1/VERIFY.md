# Verify this exam's published result

This directory is a PROOF DESCRIPTOR, not an exam. It states what
`vvdex.knowledge.memory-fact-update-1` measures, the immutable fingerprint of the revision that was
evaluated, and the certification chain recorded for it. It does not carry the
task package, the corpus or world, the visible or hidden tests, the reference
solution or the grader: those are VVDex evaluation material and publishing them
would end the exam.

## What is here

| File | What it is |
| --- | --- |
| `exam.public.json` | what the exam measures, its fingerprint, runtime class, tool categories and limits, its ownership and disclosure level |
| `provenance.public.json` | what the exam is and where it came from |
| `certification-receipt.json` | the exam's promotion chain, exactly as recorded |
| `VERIFY.md` | this file |

## The join key

Everything about this exam joins on one immutable value, the exam fingerprint:

```
2052eec0ff2d3044dc269e3599ae1bfaa45d0d8cd5df9554796105538d226c21
```

`exam.public.json`, `certification-receipt.json`, the campaign's
`summary.json` and the public exam page all state it. A document stating a
different fingerprint describes a different exam revision, and the published
numbers do not apply to it.

## Check the published numbers

The evaluation this exam appears in is `fr-20260901-46eb9548`, in campaign report
`reports/fc-d89e429d2781/`. This exam's disclosure class WITHHOLDS the record's
canonical bytes: a sealed record carries an excerpt of what each rollout
submitted, and on this exam the submission is the graded answer, so publishing
the bytes would publish the answer key. What is published beside the report is
the digest the record states about itself:

```
cat records/fr-20260901-46eb9548.digest.txt
```

A holder of the sealed record — the customer who commissioned the run, or an
auditor under agreement — reproduces that value with `shasum -a 256` over the
canonical bytes, or with `vvdex-env records verify`.

## What is withheld, and why

* task statement and task package
* seed workspace, corpus, question set and browser world
* visible test implementations
* reference/gold solution and expected values
* hidden tests and hidden grader source
* attack probes and canaries
* raw model submissions, answer-bearing diffs and private transcripts

## Retired for future evaluation

Retired for future evaluation on 2026-09-02: post-run public disclosure of answer-bearing submission content. Historical sealed results on this revision are unaffected: the disclosure happened after those runs, so it could not have influenced them.
