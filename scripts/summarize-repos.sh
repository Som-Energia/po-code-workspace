#!/usr/bin/env bash
set -euo pipefail

REPOS_DIR="repos"
OUT_DIR="summaries/repos"
IDX_DIR="summaries/indexes"

mkdir -p "$OUT_DIR" "$IDX_DIR"

active_index="$IDX_DIR/active-repos.md"
lang_index="$IDX_DIR/by-language.md"
domain_index="$IDX_DIR/by-domain.md"
product_index="$IDX_DIR/by-product.md"

echo "# Active repos" >"$active_index"
echo "" >>"$active_index"

echo "# Repos by language" >"$lang_index"
echo "" >>"$lang_index"

echo "# Repos by domain" >"$domain_index"
echo "" >>"$domain_index"
echo "_Classificació inicial pendent de refinament manual del PO._" >>"$domain_index"

echo "# Repos by product" >"$product_index"
echo "" >>"$product_index"
echo "_Classificació inicial pendent de refinament manual del PO._" >>"$product_index"

declare -A by_lang

for d in "$REPOS_DIR"/*; do
	[[ -d "$d/.git" ]] || continue
	name=$(basename "$d")

	branch=$(git -C "$d" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
	last_commit=$(git -C "$d" log -1 --pretty=format:'%h %ad %s' --date=short 2>/dev/null || echo "n/a")
	rem=$(git -C "$d" remote get-url origin 2>/dev/null || echo "n/a")

	lang="unknown"
	if [[ -f "$d/package.json" ]]; then lang="JavaScript/TypeScript"; fi
	if [[ -f "$d/pyproject.toml" || -f "$d/requirements.txt" ]]; then lang="Python"; fi
	if [[ -f "$d/go.mod" ]]; then lang="Go"; fi
	if [[ -f "$d/pom.xml" || -f "$d/build.gradle" ]]; then lang="Java"; fi

	by_lang["$lang"]+="- $name\n"

	summary="$OUT_DIR/$name.md"
	{
		echo "# $name"
		echo ""
		echo "- **Remote**: $rem"
		echo "- **Main branch (actual)**: $branch"
		echo "- **Last commit**: $last_commit"
		echo "- **Estimated stack**: $lang"
		echo ""
		if [[ -f "$d/README.md" ]]; then
			echo "## README excerpt"
			echo ""
			head -n 40 "$d/README.md"
		else
			echo "## README excerpt"
			echo ""
			echo "No README.md found."
		fi
	} >"$summary"

	echo "- [$name](../repos/$name.md)" >>"$active_index"
done

echo "" >>"$lang_index"
for k in "${!by_lang[@]}"; do
	echo "## $k" >>"$lang_index"
	echo "" >>"$lang_index"
	printf "%b\n" "${by_lang[$k]}" >>"$lang_index"
done

echo "OK: resums i índexs generats."
