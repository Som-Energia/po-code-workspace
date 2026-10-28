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

## Com usar-ho amb OpenCode v2

- Executa `./scripts/opencode.sh` des de l'arrel del workspace; OpenCode s'obrirà dins de `repos/`.
- El model predeterminat per a sessions noves és `openai/gpt-6-luna`. També es permeten `openai/gpt-6.1-sol` i `openai/gpt-6.1-terra`; els altres es filtren del catàleg del workspace.
- Executa `/grill-me <demanda funcional>` per seleccionar l'agent `po-griller` i iniciar l'anàlisi.
- Alternativament, selecciona `po-griller` manualment i dona el context funcional de la feature.
- L'agent és de només lectura: no modifica fitxers ni executa shell.
- Demana impacte per repos:
  - mòduls potencials,
  - riscs,
  - estimació de cost,
  - preguntes obertes.
- El prompt és a `.opencode/commands/grill-me.md` i l'agent a `.opencode/agents/po-griller.md`; OpenCode els descobreix automàticament.

## Recomanació

Actualitza el workspace mínim 1 cop per setmana o abans d’una estimació important.
