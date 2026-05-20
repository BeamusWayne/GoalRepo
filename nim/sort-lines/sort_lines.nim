import std/algorithm
import std/sequtils
import std/strutils
import std/system

proc showHelp() =
  echo "Usage: sort_lines [options] [file]"
  echo "  -r    Reverse sort"
  echo "  -u    Unique lines only"
  echo "  -n    Numeric sort"
  echo "  -h    Show help"

when isMainModule:
  var
    reverse = false
    unique = false
    numeric = false
    filePath = ""

  for arg in commandLineParams():
    case arg
    of "-h", "--help": showHelp(); quit(0)
    of "-r": reverse = true
    of "-u": unique = true
    of "-n": numeric = true
    else: filePath = arg

  var lines: seq[string]
  if filePath.len > 0:
    for line in filePath.lines:
      lines.add(line)
  else:
    for line in stdin.lines:
      lines.add(line)

  if numeric:
    lines.sort(proc(a, b: string): int = cmp(parseFloat(a), parseFloat(b)))
  else:
    lines.sort()

  if reverse:
    lines.reverse()

  if unique:
    lines = lines.deduplicate()

  for line in lines:
    echo line
