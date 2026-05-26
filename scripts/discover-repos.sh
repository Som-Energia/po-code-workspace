#!/usr/bin/env bash
set -euo pipefail

ORG="Som-Energia"
OUT="repos.json"

if ! command -v gh >/dev/null 2>&1; then
	echo "ERROR: cal instal·lar GitHub CLI (gh)." >&2
	exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
	echo "ERROR: cal instal·lar jq." >&2
	exit 1
fi

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
	echo "ERROR: cal definir GITHUB_TOKEN." >&2
	echo "Exemple: export GITHUB_TOKEN=ghp_xxx" >&2
	exit 1
fi

export GH_TOKEN="$GITHUB_TOKEN"

echo "Descobrint repos actius de $ORG..."

repos_json=$(gh repo list "$ORG" --limit 500 --json name,url,isArchived,description,primaryLanguage,pushedAt)

jq -n \
	--arg org "$ORG" \
	--arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
	--argjson repos "$repos_json" \
	'{
	  organization: $org,
	  generated_at: $generated_at,
	  repos: (
	    $repos
	    | map(select(.isArchived == false))
	    | sort_by(.name)
	    | map({
	        name,
	        url,
	        language: (.primaryLanguage.name // null),
	        pushed_at: .pushedAt,
	        description: (.description // "")
	      })
	  )
	}' >"$OUT"

count=$(jq '.repos | length' "$OUT")
echo "Repos actius: $count"
echo "OK: $OUT actualitzat."
