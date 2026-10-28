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
- `opencode` v2 (CLI)

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

# Instal·lar OpenCode v2 TUI (terminal)
curl -fsSL https://opencode.ai/v2/install | bash
opencode --version

# Instal·lar OpenCode v2 Desktop (entorn gràfic, Linux x64)
(
  cd /tmp
  curl -fL https://opencode.ai/update/api/latest/desktop/opencode/opencode-desktop-linux-amd64.deb -o opencode-desktop.deb
  sudo apt install ./opencode-desktop.deb
)

# Instal·lar Ghostty
sudo snap install ghostty --classic
```

Si ja tens OpenCode v1 instal·lat amb un gestor de paquets, desinstal·la'l amb el mateix gestor abans d'instal·lar v2. L'instal·lador curl de v2 substitueix el binari v1; tots dos fan servir la comanda `opencode`. Consulta la [guia oficial de migració](https://opencode.ai/v2/docs/migrate-v1/).

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

# 5) Obrir OpenCode dins repos/
./scripts/opencode.sh
```

## Models i directori inicial d'OpenCode

Executa `./scripts/opencode.sh` (o `/opt/po-code-workspace/scripts/opencode.sh` des de qualsevol directori). El llançador crea `repos/` si cal i hi inicia OpenCode. No clona repositoris: per omplir-lo, executa abans els passos de descoberta i sincronització.

OpenCode v2 carrega la configuració `opencode.json` i les definicions `.opencode/` del directori pare. Executar simplement `opencode` no canvia automàticament el directori: per començar sempre a `repos/`, fes servir el llançador.

Models permesos:

- `openai/gpt-6.1-sol`
- `openai/gpt-6.1-terra`
- `openai/gpt-6-luna` (**predeterminat per a sessions noves**)

El plugin local `plugins/model-allowlist/` aplica una llista tancada sobre el catàleg v2, incloent els models descoberts posteriorment i els d'altres proveïdors. La llista és a `plugins[].options.allowedModels` d'`opencode.json`; el valor `model` ha de pertànyer a aquesta llista. El plugin no inventa ni activa models: cal tenir OpenAI connectat i els models disponibles al compte. Una sessió existent conserva el model seleccionat si continua permès.

És una restricció d'aquest workspace, no una política de seguretat administrada: un usuari que modifiqui la configuració o desactivi el plugin pot canviar-la. Consulta les APIs de [models dels plugins v2](https://opencode.ai/v2/docs/build/plugins/server/#models).

## Agent d'OpenCode: PO-Griller

S'ha definit l'agent a:

- `.opencode/agents/po-griller.md`

És un agent primari de només lectura amb permisos natius de v2: pot llegir i cercar codi, però no modificar fitxers, executar shell ni delegar a altres agents.

Ús orientatiu:

1. Obre OpenCode amb `./scripts/opencode.sh`.
2. Selecciona l'agent `po-griller` (l'identificador ve del nom del fitxer).
3. Fes-li una demanda funcional (ex: "volem afegir X al procés Y").
4. L'agent farà preguntes de "grilling" i acabarà amb un veredicte:
   - `[JA ESTÀ FET]`
   - `[FÀCIL]`
   - `[COMPLICAT]`
   - `[IMPOSSIBLE / NO RECOMANAT]`

També pots executar `/grill-me volem afegir X al procés Y`: la comanda selecciona `po-griller` i analitza la demanda. Sense arguments, et demanarà el context funcional.

Les definicions es carreguen automàticament des de `.opencode/`; no cal copiar-les a la configuració global.

## Flux recomanat per PO

1. Executar `discover-repos.sh`
2. Executar `sync-repos.sh`
3. Executar `summarize-repos.sh`
4. Consultar `summaries/indexes/active-repos.md` i `summaries/repos/*.md`

## Notes

- Aquest repo no elimina cap carpeta local automàticament.
- Si un repo passa a archived, deixarà d’entrar a la llista activa a la següent descoberta.
- Els scripts fan servir `GITHUB_TOKEN` per consultar GitHub i per clone/pull.
- Descoberta, sincronització i resums en bash + `jq` (sense dependència de Python). El filtre de models és un plugin JavaScript d'OpenCode v2.
- Tests locals del filtre i el llançador: `node --test tests/opencode.test.mjs` (Node.js 18 o superior; només necessari per executar aquests tests).
- `.opencode/commands/grill-me.md` defineix `/grill-me` per estimar impacte/cost de features.
