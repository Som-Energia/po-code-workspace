#!/usr/bin/env bash
set -euo pipefail

REPOS_FILE="repos.yaml"
TARGET_DIR="repos"

if [[ ! -f "$REPOS_FILE" ]]; then
	echo "ERROR: falta $REPOS_FILE. Executa scripts/discover-repos.sh primer." >&2
	exit 1
fi

mkdir -p "$TARGET_DIR"

python3 - "$REPOS_FILE" <<'PY' | while IFS='|' read -r name url; do
import sys,re
from pathlib import Path
text=Path(sys.argv[1]).read_text().splitlines()
name=None
for line in text:
    if re.match(r"^\s*- name:\s+", line):
        name=line.split(":",1)[1].strip()
    if re.match(r"^\s*url:\s+", line) and name:
        url=line.split(":",1)[1].strip()
        print(f"{name}|{url}")
        name=None
PY
	repo_path="$TARGET_DIR/$name"
	if [[ -d "$repo_path/.git" ]]; then
		echo "[PULL] $name"
		git -C "$repo_path" fetch --all --prune
		git -C "$repo_path" pull --ff-only || true
	else
		echo "[CLONE] $name"
		git clone "$url" "$repo_path"
	fi
done

echo "OK: sincronització completada."
