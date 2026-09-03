#!/bin/sh
# Every https://vvdexops.com/ URL this repository names, checked for HTTP 200.
# The only step here that needs a network. Text files are read directly; PDFs
# are read through pdftotext when it is installed and skipped when it is not.
set -eu
cd "$(dirname "$0")/.."

urls=$(
  {
    git ls-files | while read -r f; do
      case "$f" in
        *.pdf) command -v pdftotext >/dev/null 2>&1 && pdftotext -q "$f" - || true ;;
        *) cat "$f" ;;
      esac
    done
  } | grep -o 'https://vvdexops\.com/[A-Za-z0-9._/-]*' | sed 's/[.,)]*$//' | sort -u
)

fail=0
n=0
for url in $urls; do
  n=$((n + 1))
  code=$(curl -s -o /dev/null -w '%{http_code}' -A vvdex-audit -L --max-time 30 "$url" || echo 000)
  printf '%s  %s\n' "$code" "$url"
  [ "$code" = 200 ] || fail=$((fail + 1))
done
printf '\n%d URL(s) checked, %d not 200\n' "$n" "$fail"
[ "$fail" -eq 0 ]
