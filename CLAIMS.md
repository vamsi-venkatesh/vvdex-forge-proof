# The claims map

Every number stated in this repository's documents, and the artifact and field it
is read from. A number that is not on this list is not in those documents. Paths
are relative to the repository root; `<current>` is
`reports/fc-d89e429d2781/`.

`python3 examples/check-readme-matrix.py` recomputes the README headline and the
whole matrix from `<current>summary.json` and `<current>campaign.json` and fails
on any difference.

## The campaign headline and totals

| Number | Where it is stated | Source |
| --- | --- | --- |
| 5 certified evaluation environments | README §2, §3, §4 | `<current>summary.json` `counts.exams` |
| 5 families | README §2, §4 | `<current>summary.json` `families` (5 entries, 5 distinct `family` values) |
| 150 attempts | README §2, METHODOLOGY | `<current>summary.json` `counts.attempts` |
| 148 graded rollouts | README §2, METHODOLOGY | `counts.graded` |
| 93 certified passes | README §2, §3, METHODOLOGY | `counts.certifiedPasses` |
| 55 model failures | README §2, METHODOLOGY | `counts.modelFails` |
| 2 lane errors | README §2, §3, METHODOLOGY | `counts.laneErrors` |
| 0 withheld, 0 invalid | README §2, METHODOLOGY | `counts.withheld`, `counts.invalid` |
| 3 lanes, 15 cells | README §3 (three rows), METHODOLOGY | `counts.lanes`, `counts.cells` |
| 10 rollouts per cell | README §3, §12, METHODOLOGY | every cell in `summary.json` `perExamMatrix.rows[].cells` has `graded + laneErrors = 10` |
| 2026-09-01, 2026-09-02 | README §2, §7, METHODOLOGY, SECURITY | the `evalId` dates in `summary.json` `records[].evalId` (`fr-20260901-…`, `fr-20260902-…`) |

## The matrix cells and lane totals

Every cell below is `summary.json` `perExamMatrix.rows[<lane>].cells[<envId>]`,
cross-checked against `campaign.json` `cells["<lane>|<envId>"].certifiedCounts`.

| Lane | Cells as published | Source fields |
| --- | --- | --- |
| `cli/codex` | 10/10 on all five exams, 50 of 50 countable | `passes`, `graded`, `laneErrors` per cell; `campaign.json` `counts.lanes["cli/codex"].certified_pass` = 50 |
| `cli/claude-sonnet` | 9/10 SWE, 1/10 RAG, 10/10 Memory, 10/10 Harness, 10/10 Browser, 40 of 50 | same fields; lane total 40 |
| `codestral-latest` | 0/10 SWE, 0/9 + 1 lane error RAG, 2/10 Memory, 0/10 Harness, 1/9 + 1 lane error Browser, 3 of 48 | same fields; lane total 3, `lane_error` 2 |

| Lane rate | Value | Source |
| --- | --- | --- |
| `cli/codex` | 100.00%, 95% CI 92.87% to 100.00% | `summary.json` `lanes[].rate` = 1.0, `rateInterval95` = [0.9287, 1.0] |
| `cli/claude-sonnet` | 80.00%, 95% CI 66.96% to 88.76% | `rate` = 0.8, `rateInterval95` = [0.6696, 0.8876] |
| `codestral-latest` | 6.25%, 95% CI 2.15% to 16.84% | `rate` = 0.0625, `rateInterval95` = [0.0215, 0.1684] |

## The historical campaigns

| Number | Source |
| --- | --- |
| `fc-3194f803055c`, 52 certified passes | `reports/fc-3194f803055c/summary.json` `counts.certifiedPasses` |
| `fc-72fe6f91c29e`, 41 certified passes | `reports/fc-72fe6f91c29e/summary.json` `counts.certifiedPasses` |
| `fc-8626f712e26f`, 8 certified passes | `reports/fc-8626f712e26f/summary.json` `counts.certifiedPasses` |
| `fc-8626f712e26f` carries no lane intervals | that file's `lanes[].rateInterval95` is `null` on all four lanes |

## The certification receipts

All fields below are in `exams/<examId>/certification-receipt.json`, and each
receipt's own `sources` block names the evidence field it was copied from.

| Number | Value | Field |
| --- | --- | --- |
| Reference pass | rate 1.0, expected 1.0, n=2, on all five exams | `referencePass` |
| Baseline fail | rate 0.0, expected 0.0, n=2, on all five exams | `baselineFail` |
| Grader controls | 7 cases on `public.swe.martinblech-xmltodict-issue-257`, `vvdex.knowledge.grounded-rag-1`, `vvdex.knowledge.memory-fact-update-1`; 9 on `vvdex.browser.order-desk-1`; 12 on `vvdex.harness.fault-recovery-1`; `distinguished: true` on all five | `graderControls.cases`, `graderControls.distinguished` |
| Attack probes | 10 probes, 10 blocked, 0 trivial exploits, on all five exams | `attackProbes.probes`, `.blocked`, `.trivialExploits` |
| Runtime limits | `cpus: "1"`, `memory: 512m`, `pids: 128`, `network: none`, `readOnlyRoot: true`, `timeoutS: 120` | `runtime.resourceLimits` |
| Unavailable fields | `certificationEvidenceDigest` on all five; `certificationVersion` and `certifiedAt` on `vvdex.browser.order-desk-1` and `vvdex.harness.fault-recovery-1` | those keys, whose value is the string `"unavailable"` |

## The records and the joins

| Number | Source |
| --- | --- |
| 5 sealed records | `<current>summary.json` `recordCount`, and `records` (5 entries) |
| 0 records with published canonical bytes, 5 withheld | `records[].canonicalBytesPublished` (`false` on every record); on disk, five `*.canonical.WITHHELD.txt` and no `*.canonical.json` in `<current>records/` |
| 5 records with a published projection, 0 without | `records[].recordProjectionPublished` (`true` on every record); on disk, five `*.record.public.json` in `<current>records/` |
| The five record digests in VERIFICATION.md §1 | `<current>records/<evalId>.digest.txt`, and `records[].recordDigest` |
| The five exam fingerprints in VERIFICATION.md §3 | `exams/<examId>/exam.public.json` `examFingerprint`, `certification-receipt.json` `examFingerprint`, `<current>summary.json` `records[].examFingerprint` |
| The receipt SHA-256 values | `<current>campaign.json` `certificationReceipts`, and `summary.json` `records[].certificationReceiptSha256`; recomputable with `shasum -a 256` on the receipt file |
| Sixty-four `0` characters in the zeroed digest slot | METHODOLOGY, VERIFICATION; the serialization convention a holder of the sealed record hashes against. It is not exercised in this repository, which publishes no canonical body |
| `lowN: false` per lane | `results.byModel[].lowN` in each of the five `<current>records/*.record.public.json`. `lowNThreshold: 10` is a sealed-record field, readable by a holder, not published here |
| The browser exam's ten advertised tools | `<current>fc-d89e429d2781.html` and the campaign PDF, the record's `limits.advertisedTools` as rendered |
| 154 files with a SHA-256 | `MANIFEST.json` `files`, checked by `./verify.sh`, which prints the same count |

## The statistics

| Number | Source |
| --- | --- |
| 95% Wilson interval, z = 1.959963984540054 | METHODOLOGY; the constant of the two-sided 95% normal quantile, stated so the intervals can be recomputed from `rate` and `countable` |
| 72.3% to 100% for a 10 of 10 cell | README §12, METHODOLOGY; the Wilson interval at c=10, n=10, recomputable from the same constant |
| `pass@k` as `1 - C(n-c, k) / C(n, k)` | METHODOLOGY; the formula, not a measurement |

## The integrity disclosure

| Number | Source |
| --- | --- |
| 2026-09-01, 232 historical rollouts, 104 verified, 115 unverified, 13 invalid | README §7 and SECURITY; the published blast-radius record at <https://vvdexops.com/integrity/>, which states the same four numbers. The rollouts themselves are not in this repository, and no result in this package is one of them |

## The scan findings

| Number | Source |
| --- | --- |
| 120 withholding notices in the full campaign report | SECURITY; countable in `<current>fc-d89e429d2781.html`, and equal to 4 proprietary exams × 3 lanes × 10 rollouts |
| 8 answer values, and the private-content strings | SECURITY; rebuilt at scan time from each exam's own host-only tree by the engine's scanners. The values are not written down anywhere, here or in the engine |
| 10 private-name patterns | SECURITY; the count of patterns in the engine's exporter. The patterns themselves are deliberately not restated |

## The xmltodict exam

| Number | Source |
| --- | --- |
| Issue #257 | `exams/public.swe.martinblech-xmltodict-issue-257/provenance.public.json` `source`, and `THIRD_PARTY_NOTICES.md` |
| Pull request 421 | the same `provenance.public.json` `source` block |
| Parent commit `404175512ced7ee915264485f757713df4f2c797` | `provenance.public.json`, and `examples/reproduce-xmltodict.md` |
| MIT | `provenance.public.json` `license`, and the upstream `LICENSE` copied into the exam directory |

`TERMS.md` and `OWNERSHIP.md` state no measurements. Their only counts are the
row counts of the ownership table itself, which is generated from the file tree.
