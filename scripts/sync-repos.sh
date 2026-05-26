#!/usr/bin/env bash
set -euo pipefail

REPOS_FILE="repos.json"
TARGET_DIR="repos"

if [[ ! -f "$REPOS_FILE" ]]; then
	echo "ERROR: falta $REPOS_FILE. Executa scripts/discover-repos.sh primer." >&2
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

export GIT_TERMINAL_PROMPT=0

build_auth_url() {
	local url="$1"
	if [[ "$url" =~ ^https://github.com/(.+)$ ]]; then
		echo "https://x-access-token:${GITHUB_TOKEN}@github.com/${BASH_REMATCH[1]}"
		return
	fi
	if [[ "$url" =~ ^git@github.com:(.+)$ ]]; then
		echo "https://x-access-token:${GITHUB_TOKEN}@github.com/${BASH_REMATCH[1]}"
		return
	fi
	echo "$url"
}

mkdir -p "$TARGET_DIR"

jq -r '.repos[] | [.name, .url] | @tsv' "$REPOS_FILE" | while IFS=$'\t' read -r name url; do
	repo_path="$TARGET_DIR/$name"
	if [[ -d "$repo_path/.git" ]]; then
		echo "[PULL] $name"
		origin_url=$(git -C "$repo_path" remote get-url origin)
		auth_origin_url=$(build_auth_url "$origin_url")
		git -C "$repo_path" fetch --prune "$auth_origin_url" '+refs/heads/*:refs/remotes/origin/*'
		if git -C "$repo_path" rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
			git -C "$repo_path" merge --ff-only '@{u}' || true
		else
			echo "[WARN] $name sense upstream configurat; fetch fet, merge omès"
		fi
	else
		echo "[CLONE] $name"
		auth_url=$(build_auth_url "$url")
		git clone "$auth_url" "$repo_path"
	fi
done

echo "OK: sincronització completada."
