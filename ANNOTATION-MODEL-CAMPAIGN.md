# Annotation model campaign

Campaign `fc-ec21239c00aa`, completed September 6, 2026, records **40 attempts:
25 strict passes and 15 model failures**. All 40 attempts were graded; lane
errors, withheld outcomes and invalid outcomes are each zero. The observed model
was `gpt-5.5`, running through `cli/codex-gpt-5.5` on the operator's signed-in
ChatGPT subscription, without API-key inference.

| Task | Attempts | Strict passes | Model failures | Mean quality score |
| --- | --- | --- | --- | --- |
| Image objects | 10 | 5 | 5 | 0.995091 |
| Robotic video | 10 | 0 | 10 | 0.280058 |
| Text labeling | 10 | 10 | 0 | 1.000000 |
| Structured data | 10 | 10 | 0 | 1.000000 |
| Audio events | N/A | N/A | N/A | N/A |

Quality scores are on a 0–1 scale and rounded to six decimal places here. They
are task-specific measurements, not interchangeable capability scores. In
particular, the image task's high mean quality does not erase its five strict
failures. The robotic-video task produced no strict passes.

Read the [campaign report](https://vvdexops.com/reports/fc-ec21239c00aa/) and
[machine-readable summary](https://vvdexops.com/reports/fc-ec21239c00aa/summary.json).

## What the campaign measures

This campaign evaluates AI-generated annotations on fixed tasks. Repeated
attempts at the same task measure performance under the recorded run conditions;
they do not represent a broad sample of videos, images or datasets. The report
identifies the CLI lane, observed model identity and input conditions.

## Inputs and scope

The scope is ten attempts on each of four tasks: robotic video, image
objects, text labeling and structured data. Image inputs use native image
attachments. Video input uses sampled frames rather than a native continuous
video stream. This distinction limits claims about motion and temporal coverage.
Audio is not evaluated in this campaign; its result is N/A, not a failure or zero.
The separate audio fixture certification remains valid evidence about that
fixture, not evidence of this model's audio performance.

## Reading the result

Strict pass and annotation quality are different measurements. Strict pass
requires the complete task's grading conditions to hold. Applicable quality
metrics describe particular aspects of the submitted annotations and do not
turn a failed submission into a pass. All 40 planned attempts are retained, including unsuccessful submissions. Earlier
smoke tests and diagnostic runs are outside this campaign. No successful retry
replaces an earlier failed attempt in its count.

## Evidence boundary

Public projections contain approved outcome summaries and evidence identifiers.
Raw submissions, reference labels, source media and private canonical records
are not included. Public digest agreement can be checked across projections and
receipts; recomputing a private record's digest requires its canonical bytes.
A projection must never be described as those private canonical bytes.

This campaign is separate from the five-task September 1–2 AI evaluation matrix.
Its different tasks do not supersede, extend or alter that historical matrix.
