#!/usr/bin/env python3
"""Print a campaign's exam matrix, lane totals and record digests.

    python3 examples/inspect-campaign.py reports/fc-d89e429d2781/summary.json

Standard library only. Everything printed is read out of summary.json; nothing
is recomputed and nothing is inferred, so the output is the file's own arithmetic
rather than this script's.
"""

import json
import os.path
import sys


def pct(x):
    return f"{x * 100:.2f}%"


def main(argv):
    if len(argv) != 2:
        print("usage: inspect-campaign.py <path to summary.json>", file=sys.stderr)
        return 2
    path = argv[1]
    if not os.path.isfile(path):
        print(f"no such file: {path}", file=sys.stderr)
        return 2
    with open(path, encoding="utf-8") as fh:
        summary = json.load(fh)

    counts = summary.get("counts") or {}
    print(f"campaign {summary.get('campaignId')}")
    print(
        f"  {counts.get('exams')} exams · {counts.get('lanes')} lanes · "
        f"{counts.get('cells')} cells"
    )
    print(
        f"  {counts.get('attempts')} attempts · {counts.get('graded')} graded · "
        f"{counts.get('certifiedPasses')} certified passes · "
        f"{counts.get('modelFails')} model fails · "
        f"{counts.get('laneErrors')} lane errors · "
        f"{counts.get('withheld')} withheld · {counts.get('invalid')} invalid"
    )

    matrix = summary.get("perExamMatrix") or {}
    exams = matrix.get("exams") or []
    rows = matrix.get("rows") or []

    # Column headers are the short family names the campaign itself assigns.
    heads = [e.get("short") or e.get("envId") for e in exams]
    ids = [e.get("envId") for e in exams]
    lane_w = max([len("model lane")] + [len(r.get("lane", "")) for r in rows])
    widths = [
        max(
            len(h),
            *[len((r.get("cells", {}).get(i) or {}).get("text", "")) for r in rows],
        )
        for h, i in zip(heads, ids)
    ]

    print()
    print("matrix — cells read passes/graded, lane errors stated beside the fraction")
    print()
    header = "  " + "model lane".ljust(lane_w)
    for h, w in zip(heads, widths):
        header += "  " + h.ljust(w)
    header += "  passes"
    print(header)
    print("  " + "-" * (len(header) - 2))
    for row in rows:
        line = "  " + str(row.get("lane", "")).ljust(lane_w)
        for i, w in zip(ids, widths):
            line += "  " + str((row.get("cells", {}).get(i) or {}).get("text", "")).ljust(w)
        line += f"  {row.get('certifiedPasses')}"
        print(line)

    print()
    print("  columns:")
    for e in exams:
        print(f"    {e.get('short')} = {e.get('envId')}")

    print()
    print("lane totals — 95% Wilson intervals, lane errors outside the denominator")
    print()
    for lane in summary.get("lanes") or []:
        c = lane.get("counts") or {}
        lo, hi = (lane.get("rateInterval95") or [None, None])[:2]
        interval = f" (95% CI {pct(lo)}–{pct(hi)})" if lo is not None else ""
        print(
            f"  {str(lane.get('lane')).ljust(lane_w)}  "
            f"{lane.get('certifiedPasses')}/{lane.get('countable')} countable  "
            f"{pct(lane.get('rate', 0.0))}{interval}"
        )
        print(
            f"  {' ' * lane_w}  certified_pass {c.get('certified_pass')} · "
            f"model_fail {c.get('model_fail')} · lane_error {c.get('lane_error')} · "
            f"withheld {c.get('withheld')} · invalid {c.get('invalid')}"
        )

    print()
    print("records — the campaign id is a digest over these digests, sorted")
    print()
    for rec in summary.get("records") or []:
        print(f"  {rec.get('evalId')}  {rec.get('recordDigest')}")
        print(f"  {' ' * len(str(rec.get('evalId')))}  {rec.get('environmentId')}")

    withheld = summary.get("withheldByHarness")
    suspect = summary.get("suspectRecords") or []
    print()
    print(
        f"harness: {len(suspect)} suspect record(s), {withheld} cell(s) withheld by harness review"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
