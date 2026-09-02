# Third-party material and attribution

Every environment directory in this repository, its licence, and where its
material came from. No third-party file is carried here without attribution.

## `environments/public.swe.martinblech-xmltodict-issue-257`

The one exam in this repository built from public open-source software.

| | |
| --- | --- |
| Upstream project | `martinblech/xmltodict` — <https://github.com/martinblech/xmltodict> |
| Upstream licence | MIT |
| Issue the exam is built from | <https://github.com/martinblech/xmltodict/issues/257> |
| Upstream pull request | <https://github.com/martinblech/xmltodict/pull/421> |
| Parent commit the tree was frozen at | `404175512ced7ee915264485f757713df4f2c797` |
| Frozen agent tree SHA-256 | `2112c07dcd40e88c7e7100a48c277fc4fab06374ec0d85c419447a451b146797` |
| Exam fingerprint | `aa41977120e6ecdddb5c4fc603e8ab23cb272726a86750119969ff4dfc90e297` |
| Classification | `public-oss` |
| Credit, as recorded | authored by the upstream project |

Third-party files under this directory:

- `LICENSE` — the xmltodict MIT licence, copied byte for byte from the frozen
  tree. SHA-256 `d66d5eb8f83a0ba21d3dd04318b8817588e8764daabea852d1035e3f07ffda55`.
  Copyright (C) 2012 Martin Blech and individual contributors. This file governs
  the upstream code the exam is built from; it is not superseded by the
  repository licence.

`ISSUE.md` is the task statement as the model received it. It describes the
upstream defect and links the upstream issue; the upstream code itself is not
reproduced in it.

No other file in this repository reproduces upstream xmltodict source. The full
campaign PDF, which embeds per-rollout submission diffs against `xmltodict.py`,
is not published here; see [VERIFICATION.md](VERIFICATION.md) §2 for why.

## The four VVDex-authored environments

| Environment | Family | Classification | Credit | `provenance.public.json` licence field |
| --- | --- | --- | --- | --- |
| `vvdex.knowledge.grounded-rag-1` | `rag_grounding` | `prime-publishable` | VVDex | `MIT` |
| `vvdex.knowledge.memory-fact-update-1` | `long_term_memory` | `prime-publishable` | VVDex | `MIT` |
| `vvdex.harness.fault-recovery-1` | `harness_eval` | `prime-publishable` | VVDex | `MIT` |
| `vvdex.browser.order-desk-1` | `browser` | `prime-publishable` | VVDex | `MIT` |

Each of these four records `upstream: null`, `repository: null`, `issueUrl:
null` and `pullRequestUrl: null` in its provenance: no third-party source, no
upstream project, nothing to attribute to anyone else. Their parent commits are
internal authoring markers (`vvdex-authored-<family>-1-parent`), not commits in
any public repository.

**Note on the licence field.** These four exams' `provenance.public.json` states
`"license": "MIT"`. That is the value recorded at authoring time for the exam
material itself, and it is reproduced here unchanged rather than edited to match
this repository. The files published in this repository — the exports under
`environments/`, the records and the reports — are released under CC BY 4.0, per
[LICENSE](LICENSE). Where the two differ, the exported files carry both
permissions: MIT as recorded on the exam, CC BY 4.0 as published here. Neither is
more restrictive than the other in a way that affects a reader who attributes.

## Everything else

- The records, campaign documents, PDFs, `campaign.json`, `summary.json` and the
  Markdown documents in this repository are VVDex-authored and are covered by
  [LICENSE](LICENSE) (CC BY 4.0).
- `examples/verify-record.sh` and `examples/inspect-campaign.py` are
  VVDex-authored. The Python example uses the standard library only and pulls in
  no third-party dependency.
- No vendored code, no bundled fonts, no third-party images.

Attribute this repository as: **VVDex Forge, <https://vvdexops.com>**.
