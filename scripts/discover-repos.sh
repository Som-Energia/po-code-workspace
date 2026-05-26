#!/usr/bin/env bash
set -euo pipefail

ORG="Som-Energia"
OUT="repos.yaml"

if ! command -v gh >/dev/null 2>&1; then
	echo "ERROR: cal instal·lar GitHub CLI (gh)." >&2
	exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
	echo "ERROR: fes login amb 'gh auth login'." >&2
	exit 1
fi

echo "Descobrint repos actius de $ORG..."

TMP=$(mktemp)
gh repo list "$ORG" --limit 500 --json name,url,isArchived,description,primaryLanguage,pushedAt >"$TMP"

python3 - "$TMP" "$OUT" <<'PY'
import json,sys,datetime
from pathlib import Path

inp=Path(sys.argv[1])
out=Path(sys.argv[2])
repos=json.loads(inp.read_text())
active=[r for r in repos if not r.get("isArchived",False)]
active.sort(key=lambda r:r["name"].lower())

lines=[]
lines.append("organization: Som-Energia")
lines.append(f"generated_at: '{datetime.datetime.utcnow().isoformat()}Z'")
lines.append("repos:")
for r in active:
    lang=(r.get("primaryLanguage") or {}).get("name")
    desc=(r.get("description") or "").replace("\n"," ").replace("\"", "'")
    lines.append(f"  - name: {r['name']}")
    lines.append(f"    url: {r['url']}")
    lines.append(f"    language: {lang if lang else 'null'}")
    lines.append(f"    pushed_at: '{r.get('pushedAt')}'")
    lines.append(f"    description: \"{desc}\"")

out.write_text("\n".join(lines)+"\n")
print(f"Repos actius: {len(active)}")
PY

rm -f "$TMP"
echo "OK: repos.yaml actualitzat."
