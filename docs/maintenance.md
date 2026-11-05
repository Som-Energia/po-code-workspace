# Maintenance

## Freqüència recomanada

- **Setmanal**: descoberta + sync + resum.
- **Abans de sessions de discovery**: sync + resum.

## Runbook

```bash
export GITHUB_TOKEN=ghp_xxx
./scripts/check-health.sh
./scripts/discover-repos.sh
./scripts/sync-repos.sh
./scripts/summarize-repos.sh
```

## Instruccions dels agents

`scripts/summarize-repos.sh` també desplega `templates/repos-AGENTS.md` a `repos/AGENTS.md`. La plantilla versionada orienta la cerca entre repositoris i estableix les regles bàsiques de privacitat. El catàleg detallat continua als índexs i resums generats; no es copien instruccions des dels clons.

- La primera execució crea el fitxer. Les següents poden actualitzar-lo si coincideix amb la darrera versió desplegada, guardada a `summaries/.repos-AGENTS.last`.
- Si el fitxer existent és idèntic a la plantilla, s'adopta com a versió gestionada sense reescriure'l.
- Si hi ha canvis locals o no se'n coneix l'origen, s'emet un avís i es conserva. Els resums i índexs es generen igualment.
- Si és un enllaç simbòlic o un directori, no es modifica. No es toquen els `AGENTS.md` dels repositoris clonats.
- Executa la preparació amb l'usuari de sincronització, amb permisos d'escriptura a `repos/` i `summaries/`, no amb els processos OpenCode de només lectura. No cal regenerar les instruccions en arrencar OpenCode.

Per canviar les regles compartides, edita la plantilla i torna a executar `./scripts/summarize-repos.sh`. Si apareix un avís, revisa `diff -u templates/repos-AGENTS.md repos/AGENTS.md` i integra els canvis manualment; si decideixes substituir una personalització, guarda'n una còpia abans. Si falta el registre de l'últim desplegament i els continguts difereixen, el script també conserva el fitxer per seguretat.

## Troubleshooting

- `GITHUB_TOKEN` no definit:
  - Executa `export GITHUB_TOKEN=ghp_xxx`
- Error de clonat/pull:
  - Revisa permisos sobre el repo origen
  - Reintenta `./scripts/sync-repos.sh`
- Resums incomplets:
  - Verifica que els repos tenen `README.md`

## Millores futures

- Afegir classificació automàtica per domini/producte.
- Integrar mètriques de churn i activity score.
- Exportar un informe global de risc/complexitat.
