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
3. `./scripts/summarize-repos.sh` (genera els resums, els índexs i `repos/AGENTS.md` amb orientació i regles de privacitat).
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

## Consultes sobre dades de l'ERP

Demana «utilitza @erp-sql-evidence per preparar una consulta que compti…» i explica què vols comptar i quin període representa. L'agent ha de buscar els models, camps i relacions al codi abans de proposar SQL, separar allò verificat de les hipòtesis i explicar si compta registres o entitats úniques.

Sense esquema confirmat pot haver-hi comprovacions pendents, i amb identificadors no verificats només s'ha de donar pseudocodi. La skill no connecta a la base de dades ni executa consultes per defecte. Els exemples són sintètics, no dades reals de l'ERP.

## Passar de l'anàlisi a una issue

Demana «utilitza @safe-github-issue per preparar una issue sobre aquesta proposta». No cal aportar dades personals ni exemples reals: descriu el flux i el resultat esperat.

L'agent ha de confirmar el repositori, comprovar-ne la visibilitat i preparar un text amb dades sintètiques. Revisa el destí, el títol i el cos exactes abans d'aprovar-ne la publicació. Qualsevol canvi posterior requereix una nova aprovació; no es copien logs ni adjunts de producció. Es pregunta un únic nom o àlies de la persona sol·licitant, que també és el contacte de seguiment. Si n'autoritzes la publicació, ha de constar al cos final encara que la issue la creï un compte tècnic compartit; pots optar per no publicar aquesta referència.

Amb `po-griller`, el resultat és un esborrany: l'agent no té permisos de shell per publicar amb `gh`. La skill no amplia aquests permisos. Pots publicar manualment el text revisat o continuar en una sessió autoritzada respectant la mateixa aprovació.

## Recomanació

Actualitza el workspace mínim 1 cop per setmana o abans d’una estimació important.
