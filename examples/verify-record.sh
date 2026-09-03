#!/bin/sh
# Recompute a sealed evaluation record's digest and compare it with the digest
# the record states about itself.
#
#   examples/verify-record.sh reports/fc-d89e429d2781/records/fr-20260902-6616b188.canonical.json
#
# The canonical file is the exact serialization the digest was computed over:
# canonical JSON, keys sorted, separators "," and ":" with no spaces, non-ASCII
# escaped, and recordDigest.sha256 set to sixty-four "0" characters. So the
# check is a plain SHA-256 over the file as published.
#
# Only one of the five records in this package publishes its canonical bytes:
# the exam whose graded artefact is public upstream source. The other four ship
# <evalId>.digest.txt beside a <evalId>.canonical.WITHHELD.txt, because a sealed
# record carries an excerpt of what each rollout submitted and on those exams
# the submission is the graded answer. This script says so rather than failing
# with a confusing "no such file".
#
# Exit status: 0 on MATCH, 1 on MISMATCH, 2 on a usage or file error.

set -eu

if [ $# -ne 1 ]; then
  echo "usage: $0 <path to *.canonical.json>" >&2
  exit 2
fi

canonical=$1
case $canonical in
  *.canonical.json) ;;
  *) echo "not a canonical record file: $canonical" >&2; exit 2 ;;
esac

stated_file=${canonical%.canonical.json}.digest.txt
if [ ! -f "$canonical" ]; then
  withheld=${canonical%.canonical.json}.canonical.WITHHELD.txt
  if [ -f "$withheld" ]; then
    echo "this record's canonical bytes are not published:" >&2
    cat "$withheld" >&2
    exit 2
  fi
  echo "no such file: $canonical" >&2
  exit 2
fi
[ -f "$stated_file" ] || { echo "no digest file beside it: $stated_file" >&2; exit 2; }

if command -v shasum >/dev/null 2>&1; then
  computed=$(shasum -a 256 "$canonical" | cut -d' ' -f1)
elif command -v sha256sum >/dev/null 2>&1; then
  computed=$(sha256sum "$canonical" | cut -d' ' -f1)
else
  echo "need shasum or sha256sum on PATH" >&2
  exit 2
fi

# The digest file holds the 64 hex characters, possibly with trailing newline
# or surrounding whitespace.
stated=$(tr -d ' \t\r\n' < "$stated_file")

echo "record   $(basename "${canonical%.canonical.json}")"
echo "computed $computed"
echo "stated   $stated"

if [ "$computed" = "$stated" ]; then
  echo "MATCH"
  exit 0
fi

echo "MISMATCH" >&2
exit 1
