# Exemple completament sintètic: esdeveniments i entitats

**No és l'esquema real de l'ERP.** Els noms següents són una fixture didàctica inventada. No els reutilitzis per consultar Som Energia; substitueix-los només després d'investigar els models i l'esquema reals. Aquest exemple no s'ha executat contra cap base de dades.

## Pregunta i abast

«Quants esdeveniments de devolució s'han registrat durant l'abril de 2026, i quantes factures diferents afecten?».

En aquesta fixture s'ha acordat comptar per dia de l'esdeveniment, no per data de factura ni d'importació, sense filtres addicionals d'estat o empresa. En un entorn real, aquests filtres s'han d'acordar i verificar.

## Evidències disponibles en la fixture

Extracte fictici de definicions ORM d'estil OpenERP antic:

```python
class DemoInvoice(osv.osv):
    _name = 'demo.invoice'
    _table = 'demo_invoice_fixture'

class DemoReturnEvent(osv.osv):
    _name = 'demo.return.event'
    _table = 'demo_return_event_fixture'
    _columns = {
        'invoice_ref': fields.many2one('demo.invoice', 'Invoice', required=True),
        'event_day': fields.date('Event day'),
    }
```

Per a l'exemple, també es proporciona aquest esquema sintètic de PostgreSQL, amb claus comprovades dins de la fixture:

| Taula | Columnes i relacions |
| --- | --- |
| `demo_invoice_fixture` | `id integer PRIMARY KEY` |
| `demo_return_event_fixture` | `id integer PRIMARY KEY`, `invoice_ref integer NOT NULL` amb FK a `demo_invoice_fixture.id`, `event_day date` nullable |

Aquí els noms de taula són explícits, no una conversió suposada del model ORM. La relació és diversos esdeveniments per factura; no cal fer JOIN per comptar les referències úniques, ja que la fixture confirma la FK i que no és nul·la. En una instal·lació real, sense esquema confirmat, aquesta garantia seria pendent.

## Consulta proposada, no executada

```sql
SELECT
    COUNT(*) AS return_events,
    COUNT(DISTINCT event.invoice_ref) AS distinct_invoices
FROM demo_return_event_fixture AS event
WHERE event.event_day >= $1::date
  AND event.event_day < $2::date;
```

Paràmetres: `$1 = 2026-04-01`, `$2 = 2026-05-01` (fi exclusiva), tots dos de tipus `date`. La sintaxi `$1`/`$2` és de paràmetres posicionals PostgreSQL; cal adaptar-la a l'API del client, sense interpolar valors. No és una ordre per enganxar directament a qualsevol client.

- `return_events` compta files d'esdeveniments dins del període.
- `distinct_invoices` compta factures diferents referenciades per aquests esdeveniments, no el total de factures emeses durant l'abril.
- Les dates nul·les no compleixen el filtre i queden excloses.
- Com que és un `date`, no es transforma cap zona horària. Si el camp real fos un timestamp, caldria definir la zona horària de negoci i els instants de tall, no reutilitzar el filtre sense revisar-lo.

Si la pregunta només demana factures, una alternativa amb la mateixa semàntica dins de la fixture és:

```sql
SELECT COUNT(*) AS distinct_invoices
FROM demo_invoice_fixture AS invoice
WHERE EXISTS (
    SELECT 1
    FROM demo_return_event_fixture AS event
    WHERE event.invoice_ref = invoice.id
      AND event.event_day >= $1::date
      AND event.event_day < $2::date
);
```

`EXISTS` evita multiplicar les files de factura. Un JOIN directe donaria una fila per esdeveniment coincident; `COUNT(*)` sobre aquell JOIN no seria un recompte de factures úniques.

## Casos sintètics raonats, no executats

Les factures `101`, `102` i `103` existeixen a la fixture i són identificadors inventats:

| Esdeveniment | Referència de factura | Dia |
| --- | --- | --- |
| 1 | 101 | 2026-04-01 |
| 2 | 101 | 2026-04-30 |
| 3 | 102 | 2026-05-01 |
| 4 | 103 | NULL |

Resultat esperat: **2 esdeveniments i 1 factura única**. La factura 102 queda fora pel límit superior exclusiu; la 103 no aporta esdeveniments datats al període. Sense esdeveniments al període, els dos recomptes serien zero.

Si el requeriment fos «factures que continuen retornades avui», la consulta anterior no ho respondria: caldria investigar l'estat actual i la seva semàntica. Si fos «retornades a final de mes», caldria informació històrica suficient. No s'ha d'afegir un filtre `state` inventat.
