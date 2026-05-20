#!/usr/bin/env python3
"""CSV quick viewer. Displays CSV files as a formatted table."""

import csv
import sys


def view_csv(path, max_rows=50, max_width=30):
    try:
        f = sys.stdin if path == "-" else open(path, newline="", encoding="utf-8")
    except FileNotFoundError:
        print(f"Error: file not found: {path}", file=sys.stderr)
        sys.exit(1)

    reader = csv.reader(f)
    headers = next(reader, None)
    if not headers:
        print("Error: empty CSV", file=sys.stderr)
        sys.exit(1)

    rows = []
    for i, row in enumerate(reader):
        if i >= max_rows:
            break
        rows.append(row)

    if f is not sys.stdin:
        f.close()

    col_count = len(headers)
    widths = [len(h) for h in headers]
    for row in rows:
        for i, cell in enumerate(row):
            if i < col_count:
                widths[i] = max(widths[i], min(len(cell), max_width))

    def fmt(val, w):
        v = val[:max_width - 1] + "~" if len(val) > max_width else val
        return v.ljust(w)

    line = " | ".join(fmt(h, widths[i]) for i, h in enumerate(headers))
    sep = "-+-".join("-" * widths[i] for i in range(col_count))
    print(line)
    print(sep)
    for row in rows:
        print(" | ".join(fmt(row[i] if i < len(row) else "", widths[i]) for i in range(col_count)))

    print(f"\n({len(rows)} rows, {col_count} columns)")


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] in ("-h", "--help"):
        print("Usage: csv_look <file.csv|-> [-n MAX_ROWS] [-w MAX_WIDTH]")
        sys.exit(0)

    path = sys.argv[1]
    max_rows = 50
    max_width = 30
    i = 2
    while i < len(sys.argv):
        if sys.argv[i] in ("-n", "--rows"):
            i += 1
            max_rows = int(sys.argv[i])
        elif sys.argv[i] in ("-w", "--width"):
            i += 1
            max_width = int(sys.argv[i])
        i += 1

    view_csv(path, max_rows, max_width)
