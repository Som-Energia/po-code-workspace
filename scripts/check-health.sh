#!/usr/bin/env bash
set -euo pipefail

fail=0

check_file() {
	local f="$1"
	if [[ ! -e "$f" ]]; then
		echo "[MISSING] $f"
		fail=1
	else
		echo "[OK] $f"
	fi
}

echo "Verificant estructura..."
check_file "repos.json"
check_file "scripts/discover-repos.sh"
check_file "scripts/sync-repos.sh"
check_file "scripts/summarize-repos.sh"
check_file "scripts/check-health.sh"
check_file "repos"
check_file "summaries/repos"
check_file "summaries/indexes"
check_file "opencode/commands/grill-me.md"
check_file "docs/architecture.md"
check_file "docs/po-guide.md"
check_file "docs/maintenance.md"

if command -v gh >/dev/null 2>&1; then
	echo "[OK] gh instal·lat"
else
	echo "[WARN] gh no instal·lat"
fi

if command -v jq >/dev/null 2>&1; then
	echo "[OK] jq instal·lat"
else
	echo "[WARN] jq no instal·lat"
fi

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
	echo "[OK] GITHUB_TOKEN definit"
else
	echo "[WARN] GITHUB_TOKEN no definit"
fi

if [[ $fail -eq 1 ]]; then
	echo "Salut: KO"
	exit 1
fi

echo "Salut: OK"
