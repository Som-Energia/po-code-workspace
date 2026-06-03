# po-code-workspace

Workspace per Product Owners de Som Energia per explorar i analitzar funcionalitats sobre tots els repos actius de l’organització.

## Què fa

- Descobreix repositoris actius de `Som-Energia` (exclou `archived=true`) i genera `repos.json`.
- Clona o actualitza repos locals a `repos/`.
- Genera resums en Markdown per repo a `summaries/repos/`.
- Genera índexs útils per domini, llenguatge i producte.
- Inclou checks de salut per detectar errors ràpid.

## Requisits

- `bash`
- `git`
- `gh` (GitHub CLI)
- `GITHUB_TOKEN` amb permisos de lectura als repos de `Som-Energia`
- `jq`
- `opencode` (CLI)

## Instal·lació de requisits (Ubuntu)

```bash
sudo apt update
sudo apt install -y git jq curl

# Instal·lar GitHub CLI (gh)
(type -p wget >/dev/null || sudo apt install -y wget) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null \
  && sudo apt update \
  && sudo apt install -y gh

# Instal·lar OpenCode TUI (terminal)
curl -fsSL https://opencode.ai/install | bash

# Instal·lar OpenCode Desktop (entorn gràfic)
cd /tmp
wget https://opencode.ai/download/stable/linux-x64-deb
sudo dpkg -i linux-x64-deb

# Instal·lar Ghostty
sudo snap install ghostty --classic
```

## Ús ràpid

```bash
# 0) Definir token de GitHub
export GITHUB_TOKEN=ghp_xxx

# 1) Descobrir repos actius
./scripts/discover-repos.sh

# 2) Clonar o fer pull dels repos
./scripts/sync-repos.sh

# 3) Generar resums
./scripts/summarize-repos.sh

# 4) Validar salut del workspace
./scripts/check-health.sh
```

## Agent d'OpenCode: PO-Griller

S'ha definit l'agent a:

- `opencode/agents/po-griller.md`

Ús orientatiu:

1. Obre OpenCode dins aquest workspace.
2. Selecciona l'agent **PO-Griller**.
3. Fes-li una demanda funcional (ex: "volem afegir X al procés Y").
4. L'agent farà preguntes de "grilling" i acabarà amb un veredicte:
   - `[JA ESTÀ FET]`
   - `[FÀCIL]`
   - `[COMPLICAT]`
   - `[IMPOSSIBLE / NO RECOMANAT]`

## Flux recomanat per PO

1. Executar `discover-repos.sh`
2. Executar `sync-repos.sh`
3. Executar `summarize-repos.sh`
4. Consultar `summaries/indexes/active-repos.md` i `summaries/repos/*.md`

## Notes

- Aquest repo no elimina cap carpeta local automàticament.
- Si un repo passa a archived, deixarà d’entrar a la llista activa a la següent descoberta.
- Els scripts fan servir `GITHUB_TOKEN` per consultar GitHub i per clone/pull.
- Flux 100% bash + `jq` (sense dependència de Python).
- `opencode/commands/grill-me.md` inclou prompt base per estimar impacte/cost de features.
