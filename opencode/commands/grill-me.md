# grill-me

Use this command to analyze feature cost across Som-Energia repos.

## Prompt template

Given a functional request:

1. Identify impacted repositories from `summaries/indexes/active-repos.md` and `summaries/repos/*.md`.
2. For each impacted repo, explain:
   - probable modules/files to touch,
   - uncertainty level,
   - test impact,
   - deployment and integration risks.
3. Provide effort range per repo (S/M/L or ideal days).
4. Provide global implementation strategy in phased slices.
5. List assumptions and follow-up questions for Product Owner.

Output must be concise, actionable, and explicit about unknowns.
