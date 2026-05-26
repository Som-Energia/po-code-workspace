# Architecture

## Components

1. **Discovery** (`scripts/discover-repos.sh`)
   - Reads active repos from GitHub org `Som-Energia`.
   - Excludes archived repositories.
   - Writes normalized `repos.json`.

2. **Sync** (`scripts/sync-repos.sh`)
   - Clones missing repos into `repos/`.
   - Pulls updates for existing repos.

3. **Summarization** (`scripts/summarize-repos.sh`)
   - Generates one markdown summary per repo.
   - Builds shared indexes for PO navigation.

4. **Health check** (`scripts/check-health.sh`)
   - Validates expected structure and core dependencies.

## Data flow

GitHub API (`gh` + `GITHUB_TOKEN`) → `repos.json` → local clones (`repos/`, amb token a URL auth temporal) → repo summaries (`summaries/repos/`) → PO indexes (`summaries/indexes/`)

## Design principles

- Simple bash tooling.
- Idempotent scripts.
- Human-readable outputs for non-technical stakeholders.
- Safe defaults (no destructive cleanup).
- Token-based auth via environment variable (`GITHUB_TOKEN`), sense persistir credencials al repo.
