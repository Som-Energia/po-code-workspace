#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v opencode >/dev/null 2>&1; then
	echo "Cal instal·lar OpenCode v2 abans d'obrir el workspace." >&2
	exit 1
fi

mkdir -p "$ROOT_DIR/repos"
cd "$ROOT_DIR/repos"
exec opencode "$@"
