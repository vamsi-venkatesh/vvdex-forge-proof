#!/usr/bin/env python3
"""Rebuild the README's matrix from the campaign artifacts and diff it.

    python3 examples/check-readme-matrix.py

The table is generated from `reports/fc-d89e429d2781/summary.json`, every cell is
checked against the independent per-cell counts in `campaign.json`, and the
result is compared line by line with the table printed in README.md. Any
difference is printed as a unified diff and the exit status is 1.

Standard library only.
"""

import difflib
import json
import os.path
import re
import sys

CAMPAIGN = "fc-d89e429d2781"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def cell_text(cell):
    """The cell's own wording, rebuilt from its counts rather than copied."""
    text = f"{cell['passes']}/{cell['graded']}"
    if cell["laneErrors"]:
        n = cell["laneErrors"]
        text += f" + {n} lane error" + ("s" if n != 1 else "")
    return text


def build(summary, campaign):
    matrix = summary["perExamMatrix"]
    exams = matrix["exams"]
    ids = [e["envId"] for e in exams]
    heads = [e["short"] for e in exams]

    lines = ["| Model lane | " + " | ".join(heads) + " | Certified passes |",
             "| --- | " + " | ".join(["---"] * len(heads)) + " | --- |"]
    problems = []
    for row in matrix["rows"]:
        lane = row["lane"]
        cells = []
        for env_id in ids:
            cell = row["cells"][env_id]
            counts = campaign["cells"][f"{lane}|{env_id}"]["certifiedCounts"]
            graded = counts["certified_pass"] + counts["model_fail"]
            if (counts["certified_pass"], graded, counts["lane_error"]) != (
                    cell["passes"], cell["graded"], cell["laneErrors"]):
                problems.append(
                    f"{lane} x {env_id}: summary says "
                    f"{cell['passes']}/{cell['graded']} + {cell['laneErrors']} lane error(s), "
                    f"campaign.json says {counts['certified_pass']}/{graded} + "
                    f"{counts['lane_error']} lane error(s)")
            if cell_text(cell) != cell["text"]:
                problems.append(f"{lane} x {env_id}: cell text {cell['text']!r} "
                                f"is not what its counts say ({cell_text(cell)!r})")
            cells.append(cell_text(cell))
        countable = sum(row["cells"][i]["graded"] for i in ids)
        lane_total = campaign["counts"]["lanes"][lane]["certified_pass"]
        if lane_total != row["certifiedPasses"]:
            problems.append(f"{lane}: lane total {row['certifiedPasses']} in summary.json, "
                            f"{lane_total} in campaign.json")
        lines.append(f"| `{lane}` | " + " | ".join(cells) +
                     f" | {row['certifiedPasses']} of {countable} countable |")
    return lines, problems


def readme_table(text):
    """The first markdown table in README.md whose header names a model lane."""
    rows = []
    for line in text.splitlines():
        if line.startswith("| Model lane |"):
            rows = [line]
        elif rows and line.startswith("|"):
            rows.append(line)
        elif rows:
            break
    return rows


def main():
    base = os.path.join(ROOT, "reports", CAMPAIGN)
    with open(os.path.join(base, "summary.json"), encoding="utf-8") as fh:
        summary = json.load(fh)
    with open(os.path.join(base, "campaign.json"), encoding="utf-8") as fh:
        campaign = json.load(fh)

    built, problems = build(summary, campaign)
    for problem in problems:
        print("CELL MISMATCH:", problem)

    with open(os.path.join(ROOT, "README.md"), encoding="utf-8") as fh:
        readme = fh.read()
    published = readme_table(readme)

    if not published:
        print("README carries no matrix table")
        return 1

    diff = list(difflib.unified_diff(published, built,
                                     "README.md", f"{CAMPAIGN}/summary.json", lineterm=""))
    if diff or problems:
        print("\n".join(diff))
        return 1

    for line in built:
        print(line)
    print()
    counts = summary["counts"]
    headline = (f"{counts['exams']} certified evaluation environments · "
                f"{len(summary['families'])} families · {counts['attempts']} attempts · "
                f"{counts['graded']} graded rollouts · "
                f"{counts['certifiedPasses']} certified passes")
    if headline not in readme:
        print("README headline does not match the summary:", headline)
        return 1
    print("headline matches summary.json:", headline)
    print(f"matrix: {len(built) - 2} lanes x {len(summary['perExamMatrix']['exams'])} exams, "
          "identical to README.md, every cell agreeing with campaign.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
