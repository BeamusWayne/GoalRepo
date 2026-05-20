#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: emoji-filter [emoji] [file]"
    echo "       echo 'hello 🔥 world' | emoji-filter"
    echo "       emoji-filter --list"
    exit 0
fi

if [[ "${1:-}" == "--list" ]]; then
    echo "Common emoji: 🔥 🎉 ❤️ 👍 🚀 ⭐ 💡 🎯 🏆 🐛 📝 ✅ ❌"
    exit 0
fi

PATTERN="${1:-}"
INPUT="${2:-}"

if [[ -n "$PATTERN" ]]; then
    if [[ -n "$INPUT" ]]; then
        grep -- "$PATTERN" "$INPUT"
    else
        grep -- "$PATTERN"
    fi
else
    grep -P '[\x{1F300}-\x{1F9FF}\x{2600}-\x{26FF}\x{2700}-\x{27BF}]'
fi
