# PO Guide

## Objectiu

Respondre preguntes com:

- Quins repos afecta una demanda funcional?
- Quins equips o tecnologies toca?
- Quin cost/risc aproximat tindria implementar-ho?

## Pas a pas

0. `export GITHUB_TOKEN=ghp_xxx`
1. `./scripts/discover-repos.sh`
2. `./scripts/sync-repos.sh`
3. `./scripts/summarize-repos.sh`
4. Revisar:
   - `summaries/indexes/active-repos.md`
   - `summaries/indexes/by-language.md`
   - `summaries/repos/*.md`

## Com usar-ho amb OpenCode

- Dona el context funcional de la feature.
- Demana impacte per repos:
  - mòduls potencials,
  - riscs,
  - estimació de cost,
  - preguntes obertes.
- Pots partir de `opencode/commands/grill-me.md`.

## Recomanació

Actualitza el workspace mínim 1 cop per setmana o abans d’una estimació important.
