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
