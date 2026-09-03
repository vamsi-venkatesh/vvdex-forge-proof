#!/bin/sh
# Cross-check one sealed record's digest against every place this repository
# states it.
#
#   examples/verify-record.sh reports/fc-d89e429d2781/records/fr-20260902-6616b188.digest.txt
#
# WHAT THIS CHECKS, and what it does not.
#
# It does NOT recompute the digest from the sealed record's canonical bytes.
# Those bytes are not published here, on any record, so no script in this
# repository can do that. It is a real check and it belongs to a holder of the
# canonical record under agreement; see VERIFICATION.md.
#
# What it checks instead is agreement. A record digest is written down in up to
# three places in this package: the .digest.txt file, the sanitized projection's
# sourceRecordDigest, and the campaign summary's records[].recordDigest. If a
# document had been re-pointed at a different record, or a digest retyped, these
# would stop agreeing. They must all be the same 64 hex characters.
#
# For a holder of the sealed record, the scheme to recompute against is:
# canonical JSON, keys sorted, separators "," and ":" with no spaces, non-ASCII
# escaped, and recordDigest.sha256 set to sixty-four "0" characters, hashed with
# SHA-256; or `vvdex-env records verify`.
#
# Exit status: 0 when every stated place agrees, 1 on a disagreement, 2 on a
# usage or file error.

set -eu

if [ $# -ne 1 ]; then
  echo "usage: $0 <path to *.digest.txt>" >&2
  exit 2
fi

digest_file=$1
case $digest_file in
  *.digest.txt) ;;
  *.canonical.json)
    echo "no canonical record body is published in this repository." >&2
    echo "pass the digest file instead: ${digest_file%.canonical.json}.digest.txt" >&2
    exit 2 ;;
  *) echo "not a record digest file: $digest_file" >&2; exit 2 ;;
esac
[ -f "$digest_file" ] || { echo "no such file: $digest_file" >&2; exit 2; }

base=${digest_file%.digest.txt}
eval_id=$(basename "$base")
records_dir=$(dirname "$digest_file")
campaign_dir=$(dirname "$records_dir")

stated=$(tr -d ' \t\r\n' < "$digest_file")
echo "record            $eval_id"
echo "digest.txt        $stated"

rc=0
report_one() {
  label=$1
  value=$2
  [ -n "$value" ] || return 0
  echo "$label $value"
  if [ "$value" != "$stated" ]; then
    rc=1
  fi
}

projection="$base.record.public.json"
if [ -f "$projection" ]; then
  value=$(python3 -c "import json,sys;d=json.load(open(sys.argv[1]));print((d.get('sourceRecordDigest') or {}).get('sha256') or '')" "$projection")
  report_one "projection       " "$value"
else
  echo "projection        not published for this record"
fi

summary="$campaign_dir/summary.json"
if [ -f "$summary" ]; then
  value=$(python3 -c "
import json,sys
d=json.load(open(sys.argv[1]))
print(next((r.get('recordDigest') or '') for r in (d.get('records') or [])
           if r.get('evalId')==sys.argv[2]), end='')
" "$summary" "$eval_id")
  report_one "summary.json     " "$value"
fi

withheld="$base.canonical.WITHHELD.txt"
if [ -f "$withheld" ]; then
  echo "canonical bytes   withheld, see $(basename "$withheld")"
fi

if [ "$rc" -eq 0 ]; then
  echo "AGREE"
  exit 0
fi

echo "DISAGREE" >&2
exit 1
