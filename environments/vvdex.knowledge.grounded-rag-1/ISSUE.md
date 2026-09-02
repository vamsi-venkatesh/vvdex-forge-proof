# Grounded question answering over a document collection

`corpus/` holds eight source documents about a company called Meridian Labs.
Some are current, some are older versions that have been superseded, and some
are on unrelated topics. `questions.json` lists eight questions. Answer them
using ONLY the corpus, and write your answers to `answers/answers.json`.

## What to write

`answers/answers.json` is one JSON object keyed by question id. Each value is an
object with exactly these keys:

- `answer` — a short string. The shortest phrase that answers the question (a
  name, a number with its unit, a short noun phrase). Empty string when the
  corpus does not contain the answer.
- `citations` — a list of the source ids (like `"S1"`) that DIRECTLY support your
  answer, and no others. A source id is the `id:` header at the top of each file
  and is also its filename stem's document. List every supporting source and
  nothing that does not support the answer. Empty list when the answer is not in
  the corpus.
- `insufficient` — `true` when the corpus does not contain enough to answer, and
  `false` otherwise. When `true`, `answer` must be `""` and `citations` must be
  `[]`.

## Rules the grader enforces

1. The answer must be correct (compared case-insensitively, ignoring surrounding
   whitespace and a trailing period).
2. The citations must be EXACTLY the sources that support the answer. Citing a
   superseded/older document, or an unrelated document, is wrong even if your
   answer happens to be right.
3. When a document has been superseded by a newer one, the newer document is
   authoritative. Do not answer from, or cite, the superseded version.
4. When the answer is not in the corpus, say so: set `insufficient` to `true`
   rather than guessing. Inventing an answer for a question the corpus does not
   cover is the worst failure this exam has.

Writes are limited to `answers/**`. You have `python3` and no network.
