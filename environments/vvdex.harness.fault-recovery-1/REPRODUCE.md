# Reproduce this exam's published result

This directory carries what the model received and what the exam's own
certification recorded. It does not carry the reference solution, the hidden
tests or the control cases; publishing those would end the exam.

## What is here

| File | What it is |
| --- | --- |
| `TASK.md` | the task statement, byte for byte as the model received it |
| `provenance.public.json` | what the exam is, where it came from, its license |
| `contract.public.json` | identity, the tools/limits/writable paths the model had, and the freeze policy it ran under |
| `certification-receipt.json` | the exam's promotion chain, as recorded |

## Check the published result

The evaluation this exam appears in is `fr-20260902-a6f12b64`, in campaign report
`reports/fc-d89e429d2781/`. Its canonical bytes and the digest it states about
itself are published beside the report, under `records/`:

```
shasum -a 256 records/fr-20260902-a6f12b64.canonical.json
cat records/fr-20260902-a6f12b64.digest.txt
```

The two must be equal. The same bytes are served from the exam's public page at
`https://vvdexops.com/featured/fault-recovery-1/`, which states the same digest and the
same exam fingerprint as `certification-receipt.json`:

```
4a206fbfe8fb70fb3e37943705065a8599fab492e495dca326279781ee960b1e
```

Any copy of this directory whose receipt states a different fingerprint is a
receipt for a different exam revision, and the published numbers do not apply
to it.
