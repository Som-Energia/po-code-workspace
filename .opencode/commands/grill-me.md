---
description: Analitza la viabilitat i el cost d'una funcionalitat entre repositoris.
agent: po-griller
---

Analyze feature cost across Som-Energia repos for this functional request:

$ARGUMENTS

If no request was provided, ask the Product Owner for it before analyzing.

Given the functional request:

1. Locate the workspace root (the parent of `repos/` when running inside it). Identify impacted repositories from `<workspace>/summaries/indexes/active-repos.md` and `<workspace>/summaries/repos/*.md`, then inspect their actual code under `<workspace>/repos/`. If summaries are missing, explain that they must be generated and investigate the available repositories directly.
2. For each impacted repo, explain:
   - probable modules/files to touch,
   - uncertainty level,
   - test impact,
   - deployment and integration risks.
3. Provide effort range per repo (S/M/L or ideal days).
4. Provide global implementation strategy in phased slices.
5. List assumptions and follow-up questions for Product Owner.

Output must be concise, actionable, and explicit about unknowns.
