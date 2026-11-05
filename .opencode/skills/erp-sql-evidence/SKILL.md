---
name: erp-sql-evidence
description: Prepara consultes SQL de lectura sobre l'ERP a partir d'una pregunta funcional, verificant primer models ORM, taules, camps i relacions al codi. Utilitza-la per comptar factures, devolucions o altres registres, explicar JOIN i COUNT DISTINCT, delimitar períodes i evitar SQL amb esquema inventat. No executa consultes per defecte.
---

# SQL de l'ERP basat en evidències

## Regles

- Primer investiga, després proposa SQL. No inventis noms de models, taules, columnes, estats ni relacions a partir del llenguatge funcional.
- El codi d'una branca no prova l'esquema ni les dades d'una instal·lació. Distingeix sempre «verificat al codi», «verificat a l'esquema», «executat en un entorn identificat» i «pendent de confirmar».
- Per defecte prepara i explica la consulta, sense executar-la. No demanis credencials ni dades de producció, no canviïs permisos ni facis servir un altre compte per esquivar-los. Si no tens shell, investiga amb lectura i cerca sense intentar habilitar-lo.
- Només lectura: no proposis DDL/DML, correccions de dades, `SELECT FOR UPDATE`, funcions amb efectes laterals ni `EXPLAIN ANALYZE` com a part d'aquest flux. Un text que comença per `SELECT` no garanteix que sigui segur.
- Aplica les regles de privacitat del workspace. Prefereix agregats i exemples completament sintètics; no exposis dades personals, secrets, logs originals, codis de client o contracte, CUPS ni esquemes/codi privats fora del públic autoritzat.

## 1. Concretar què s'ha de comptar

Pregunta només allò que canviï el resultat:

- Quin objecte o esdeveniment representa la mètrica: factures, línies d'arxiu, intents de devolució, fitxers, registres o persones? Es volen registres totals o identificadors únics?
- Quina data defineix el període: factura, emissió del fitxer, importació, devolució o una altra? Quins límits exactes, tipus `date`/`timestamp` i zona horària s'apliquen?
- Quins estats, empreses, tipus documentals i exclusions són rellevants? Una factura amb diverses devolucions compta una vegada o diverses?
- Es vol l'estat actual o el que tenia en una data passada? Una columna d'estat actual no reconstrueix la història; busca esdeveniments o històrics si cal.

No cal preguntar tot si la demanda ja ho resol. Explicita qualsevol decisió pendent abans de donar una xifra o una consulta que sembli definitiva.

## 2. Localitzar els models correctes

1. Consulta `repos/AGENTS.md`, el catàleg i els resums del workspace pare, segons el directori actual. Selecciona candidats pel domini, no només pel nom: `openerp_som_addons`, `erp` i altres mòduls només són punts de partida si estan disponibles.
2. Llegeix les instruccions dels repositoris i identifica la família/versió d'OpenERP/Odoo i el motor de base de dades amb evidències. No barregis esquemes de l'ERP comercial amb els d'Odoo de recursos humans.
3. Cerca el vocabulari funcional als models, vistes, imports, parsers, tests i migracions. Segueix `_name`, `_inherit`, `_inherits`, `_table` i els mòduls que amplien la definició; el fitxer on es declara el model pot no contenir tots els camps.
4. Identifica com la lògica de negoci registra l'esdeveniment: no dedueixis que un estat vol dir «retornada» només pel seu nom. Comprova seleccions, constants, transicions i tests.
5. Registra repositori, branca/revisió disponible i ruta/línies de les definicions. Si falta un mòdul o hi ha diverses implementacions, declara-ho i demana context en comptes de triar-ne una arbitràriament.

## 3. Fer el mapa ORM → SQL

Abans d'escriure SQL, presenta una taula breu amb:

| Concepte | Model ORM | Taula/columna SQL | Relació o tipus | Evidència | Estat de verificació |
| --- | --- | --- | --- | --- | --- |
| <concepte funcional> | <model trobat> | <identificador comprovat o pendent> | <cardinalitat/tipus> | <repo:ruta:línia> | <codi/esquema/pendent> |

Comprova específicament:

- El punt d'un `_name` sovint es converteix en guió baix, però és només una convenció: revisa `_table`, herència delegada, vistes SQL (`_auto = False`), inicialització i migracions. No presentis una conversió assumida com a taula verificada.
- Un `many2one` pot representar la clau forana; un `one2many` normalment és la relació inversa, no una columna al model pare. Confirma el camp invers i on es desa realment.
- Per a `many2many`, confirma taula intermèdia i columnes a la declaració o a l'esquema. No en derivis noms de memòria.
- Camps calculats, `function`, `related`, propietats i camps no emmagatzemats poden no tenir columna directa o no tenir el mateix nom; comprova `store`, tipus i implementació segons la versió. El SQL directe no reprodueix automàticament el càlcul ORM.
- Confirma claus de JOIN, nul·labilitat, valors d'estat i tipus de dates. No assumeixis que `id`, `state`, `date` o `invoice_id` existeixen al model rellevant.
- El SQL pot ignorar permisos ORM, regles de registre, context multiempresa o filtres d'actius. Identifica l'abast autoritzat i els filtres necessaris sense proposar esquivar controls d'accés.

Si no tens accés a l'esquema, indica-ho. Una verificació de catàleg amb `information_schema` o `pg_catalog` només és aplicable si PostgreSQL està confirmat i existeix un canal de lectura autoritzat; no executis introspecció per defecte.

## 4. Construir la consulta i explicar la semàntica

- Quan els identificadors i relacions estiguin justificats, proposa SQL del dialecte confirmat, amb paràmetres per a dates i altres valors. No interpol·lis text d'usuari, no incloguis credencials i no inventis límits predeterminats.
- Si encara hi ha noms o relacions no verificats, ofereix només un esquema conceptual/pseudocodi clarament marcat com a no executable i una llista de comprovacions pendents. No donis una consulta «llesta per executar» amb camps suposats.
- Explica la unitat de cada fila abans i després dels JOIN. `COUNT(*)` compta files del resultat; `COUNT(camp)` exclou `NULL`; `COUNT(DISTINCT clau)` compta valors únics no nuls d'aquella clau, no qualsevol concepte de negoci.
- Els JOIN un-a-molts poden multiplicar files. Si només cal provar existència, considera `EXISTS`; si cal agregar, fes-ho al nivell correcte. No posis `DISTINCT` només per amagar un JOIN incorrecte.
- Prefereix intervals semioberts `>= inici AND < fi_exclusiva`, amb tipus de paràmetres i zona horària explícits. No usis `BETWEEN` sobre timestamps per representar un mes ni fixis un últim instant artificial. Explica què passa amb dates nul·les.
- Per timestamps, confirma si es desen en UTC i si tenen zona horària. No assumeixis mesos de durada fixa ni converteixis dies a 24 hores quan hi pugui haver canvis d'horari.
- Indica exclusions, tractament de duplicats, `NULL`, cancel·lacions i casos límit. Evita `SELECT *` i resultats individuals si l'objectiu només demana recomptes.

Llegeix `references/synthetic-example.md` per veure el format esperat i la diferència entre comptar esdeveniments i entitats. És una fixture inventada, no documentació de l'esquema real de Som Energia.

## 5. Validació sense confondre proposta i execució

Revisa el raonament amb casos sintètics: zero resultats, una entitat amb diversos esdeveniments, límits de dates, camps nuls i relacions opcionals. Explica els resultats esperats; no afirmis que s'han executat tests si només s'han raonat.

Si l'usuari demana executar la consulta, abans cal confirmar entorn, abast, consulta i paràmetres exactes, i tenir un canal i permisos autoritzats. Utilitza un rol realment de només lectura; segons el motor confirmat, afegeix transacció de només lectura, timeout i límits de resultats apropiats. No obris una connexió ni facis servir producció automàticament. Una transacció de lectura és una defensa addicional, no un substitut dels permisos. `EXPLAIN` sense `ANALYZE` pot servir per revisar el pla quan s'autoritzi; no executis funcions desconegudes ni consultes costoses per comprovar una hipòtesi.

Format de resposta:

1. Interpretació de la pregunta i mètrica exacta.
2. Evidències i mapa ORM → SQL, amb nivell de verificació.
3. Consulta proposada o pseudocodi, paràmetres, període i zona horària.
4. Què compta, què exclou i per què no multiplica indegudament els resultats.
5. Casos sintètics, limitacions, comprovacions pendents i estat real d'execució.

Si després es demana obrir una issue, carrega `safe-github-issue`: confirma el repositori propietari i la seva visibilitat abans d'atribuir un `404` al token, saneja l'esborrany, demana la referència única de sol·licitant/contacte i obtén aprovació del text exacte. No copiïs SQL ni esquema privat en una issue pública sense autorització per compartir-los.
