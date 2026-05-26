# po-code-workspace

Workspace per Product Owners de Som Energia per explorar i analitzar funcionalitats sobre tots els repos actius de l’organització.

## Què fa

- Descobreix repositoris actius de `Som-Energia` (exclou `archived=true`).
- Clona o actualitza repos locals a `repos/`.
- Genera resums en Markdown per repo a `summaries/repos/`.
- Genera índexs útils per domini, llenguatge i producte.
- Inclou checks de salut per detectar errors ràpid.

## Requisits

- `bash`
- `git`
- `gh` (GitHub CLI) autenticat (`gh auth login`)
- `yq` (opcional però recomanat)

## Ús ràpid

```bash
# 1) Descobrir repos actius
a./scripts/discover-repos.sh

# 2) Clonar o fer pull dels repos
a./scripts/sync-repos.sh

# 3) Generar resums
./scripts/summarize-repos.sh

# 4) Validar salut del workspace
./scripts/check-health.sh
```

## Flux recomanat per PO

1. Executar `discover-repos.sh`
2. Executar `sync-repos.sh`
3. Executar `summarize-repos.sh`
4. Consultar `summaries/indexes/active-repos.md` i `summaries/repos/*.md`

## Notes

- Aquest repo no elimina cap carpeta local automàticament.
- Si un repo passa a archived, deixarà d’entrar a la llista activa a la següent descoberta.
- `opencode/commands/grill-me.md` inclou prompt base per estimar impacte/cost de features.
