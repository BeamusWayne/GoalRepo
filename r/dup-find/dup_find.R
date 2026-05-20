#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1 || args[1] %in% c("-h", "--help")) {
  cat("Usage: dup_find <file>\n")
  cat("  Find and report duplicate lines in a file.\n")
  cat("  Reads from stdin if file is '-'.\n")
  quit(status = if (length(args) < 1) 1 else 0)
}

path <- args[1]
con <- if (path == "-") stdin() else file(path, "r")
lines <- readLines(con)
if (path != "-") close(con)

counts <- table(lines)
dupes <- counts[counts > 1]

if (length(dupes) == 0) {
  cat("No duplicates found.\n")
} else {
  cat(sprintf("Found %d duplicate line(s):\n\n", length(dupes)))
  for (name in names(dupes)) {
    cat(sprintf("  %dx  %s\n", dupes[name], name))
  }
}
