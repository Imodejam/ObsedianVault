# CAT Stack — Ambiente Collaudo Condiviso

Infrastruttura collaudo su **pro-open** (212.227.21.104) in `/opt/ops/`. Replica controllata della produzione per Puntify e Piracity, con cluster Postgres condiviso multi-DB e reverse-proxy Caddy unico.

## Razionale
Ambiente CAT separato dalla produzione per smoke test, migrazioni, OAuth callback verificati prima del rilascio. Stesso pattern per ogni app: GoTrue + PostgREST dedicati (JWT secret separati), DB dedicato dentro lo stesso cluster `ops-postgres`, schema dedicato (`puntify`, `piracity`). Niente più Kong/Studio/Realtime/Storage/Edge/Functions: rimossi col legacy Supabase OSS.

## Stack `/opt/ops/`

### Container (docker compose)
| Servizio | Immagine | Bind | Note |
|---|---|---|---|
| `ops-postgres` | `postgis/postgis:16-3.5-alpine` | internal :5432 | multi-DB (`puntify_cat`, `piracity_cat`, …). Switch da `postgres:16-alpine` il 2026-05-17 per PostGIS richiesto da Piracity (2 geography cols + `nearby_vouchers` RPC). pg 16.14 stessa minor, data files compat. |
| `gotrue-puntify-cat` | `supabase/auth:v2.179.0` | 127.0.0.1:18999 | JWT Puntify |
| `postgrest-puntify-cat` | `postgrest/postgrest:v12.2.3` | 127.0.0.1:18998 | `PGRST_DB_SCHEMAS=puntify,storage` |
| `gotrue-piracity-cat` | `supabase/auth:v2.179.0` | 127.0.0.1:18995 | JWT Piracity (distinto) |
| `postgrest-piracity-cat` | `postgrest/postgrest:v12.2.3` | 127.0.0.1:18994 | `PGRST_DB_SCHEMAS=piracity,storage` |
| `ops-dbgate` | dbgate | 127.0.0.1:18997 | UI DB, connessioni Puntify + Piracity in sidebar |
| `ops-caddy` | `caddy:2-alpine` (network_mode host) | 80/443 | Reverse-proxy + CORS + ACME ECDSA |

### File chiave
- `/opt/ops/.env` (chmod 600) — credenziali, JWT secrets, OAuth, domini
- `/opt/ops/docker-compose.yml` — definizione 6 servizi
- `/opt/ops/caddy/Caddyfile` — 10 domini con cert ECDSA Let's Encrypt
- `/opt/ops/backups/local/` — pg_dump giornaliero cron 03:30 UTC, retention 7gg, script `backup.sh`

## DB

### `puntify_cat`
- Schemi: **puntify** (29 tabelle app, match prod — rinominato da `public` il 2026-05-17 dopo errore PGRST106 con `Accept-Profile: puntify`), `storage` (10 tab metadata), `auth` (17 tab GoTrue), `public` (helper functions + sequence `shops_ivr_code_seq`), `extensions` (pgcrypto + uuid-ossp).
- Ruoli LOGIN: `puntify_authenticator` (PostgREST role-switch), `puntify_supabase_auth_admin` (owner schema auth, BYPASSRLS).
- Helper functions in `public`: `update_updated_at_column`, `log_consent_changes`, `set_account_id` (trigger su `puntify.*`). Auth helpers (uid/role/jwt/email) in schema `auth`.
- Sequences: `public.shops_ivr_code_seq` (shared, 1-9999); `puntify.category_id_seq`, `puntify.category_services_id_seq` (IDENTITY).

### `piracity_cat`
- Schemi: **piracity** (19 tabelle, 589 rows migrate da supabase OSS), `storage` (vuoto), `auth` (17 tab GoTrue, 17 users + 18 identities riusati da puntify auth), `public` (PostGIS 3.5.6), `extensions`.
- Ruoli LOGIN: `piracity_authenticator`, `piracity_supabase_auth_admin`.
- JWT secret distinto da Puntify (utenti UUID condivisi, JWT non interscambiabili).

### Ruoli condivisi cluster-wide
NOLOGIN: `anon`, `authenticated`, `service_role` (BYPASSRLS).

## Caddy
11 domini gestiti, cert ACME ECDSA auto in volume `ops_caddy_data`:
- `api-cat.puntify.it` → GoTrue+PostgREST Puntify (CORS via Caddy: senza Kong davanti i container raw non emettono header CORS. Aggiunti con prefix `>` (replace, evita duplicati con `*` di PostgREST). Origin reflesso da `{header.origin}`, Allow-Credentials true, preflight OPTIONS gestito separato con `respond 204`)
- `db-cat.puntify.it` → DbGate
- `cat.puntify.it` → Puntify dev/CAT: `/` → :8003 (Vetrina Blazor Server), `/api/*` + `/swagger*` → :8001 (Server API .NET)
- `app-cat.puntify.it` → :8002 (Puntify.App Blazor WASM). Sub-domain dedicato perché DevServer ignora `StaticWebAssetBasePath` → asset `/_framework/*`, `/js/*` 404 se servito sotto path `/app/*`. DNS da creare (record A → 212.227.21.104 lato registrar Puntify).
- `api-cat.piracity.app` → GoTrue+PostgREST Piracity (CORS identico)
- `cat.piracity.app` → :6010 (Next.js web Piracity)
- `app-cat.piracity.app` → :6002 (app server Piracity)
- `imodejam.duckdns.org`, `paperclip.puntify.it`, `piracity-dev-app.duckdns.org`, `piracity-dev-web.duckdns.org`, `supabase-cat.duckdns.org` (legacy), `concilium.puntify.it`
- **Dismessi:** `concilium-cat.duckdns.org`, `piratopoly-dev{,-web}.duckdns.org`

### Reload
`admin off` nel Caddyfile → `caddy reload` fallisce. Per applicare modifiche: `docker compose restart ops-caddy` (downtime ~3-5s). Zero-downtime futuro: abilitare admin (default bind localhost:2019).

## Endpoint client

### Puntify
- `SUPABASE_URL=https://api-cat.puntify.it`
- `SUPABASE_ANON_KEY=$PUNTIFY_ANON_KEY`
- Auth: `/auth/v1/*` · REST: `/rest/v1/*`
- Client deve inviare `Accept-Profile: puntify` (Supabase C# SDK: `options.Schema = "puntify"`)
- Frontend: `https://cat.puntify.it` (impostato come `GOTRUE_SITE_URL` dopo standup)
- URI_ALLOW_LIST: `cat.puntify.it/*, api-cat.puntify.it/*, www.puntify.it/app, puntify.it/app`
- Google OAuth redirect URI: `https://api-cat.puntify.it/auth/v1/callback` (aggiunto su client OAuth prod 2026-05-16)

### Piracity
- `SUPABASE_URL=https://api-cat.piracity.app`
- `SUPABASE_ANON_KEY=$PIRACITY_ANON_KEY`
- `Accept-Profile: piracity`
- Google OAuth: stesso client di Puntify riusato a livello Google Project; aggiungere redirect URI `https://api-cat.piracity.app/auth/v1/callback` (TODO).

## Storage
File fisici restano su MinIO esterno (`files.puntify.it` bucket `*-cat`). In `puntify_cat.storage`: 5 objects metadata migrati ma file fisici **non** spostati.

## Bug fix portati in CAT (non ancora in prod)
- `piracity.nearby_vouchers` RPC: source citava `piratopoly.vouchers` (relation inesistente). CAT corregge a `piracity.vouchers`. Per portarlo in prod: stesso `CREATE OR REPLACE FUNCTION`.

## Supabase OSS legacy — dismesso 2026-05-17
Stack `/root/supabase/docker/` aveva 12 container (gotrue v2.186.0, postgrest v14.8, kong, studio, realtime, storage, edge-functions, pooler, analytics, vector, meta, imgproxy, db). Esposto da `supabase-cat.duckdns.org` (rimosso da Caddy il 2026-05-17). Tutti container stopped via `docker compose -f /root/supabase/docker/docker-compose.yml stop`. Volumes `supabase_db-config`, `supabase_deno-cache` intatti per rollback rapido (no `down -v`).

### Backup safety finali
- `/opt/ops/backups/local/supabase-db-final-cluster-20260517-013015.sql.gz` (5.3M, pg_dumpall completo)
- `/opt/ops/backups/local/supabase-db-final-postgres-20260517-013015.dump` (935K)
- `/opt/ops/backups/local/supabase-db-final-supadb-20260517-013015.dump` (5.1M)
- `/opt/ops/backups/local/supabase-piracity-schema-20260517-011543.dump` (pre-migration)
- `/opt/ops/backups/local/supabase-puntify-schema-20260517-011032.dump` (pre-migration)

### Rollback / cleanup definitivo
- **Rollback emergenza:** `docker compose -f /root/supabase/docker/docker-compose.yml start`
- **Destructive cleanup (dopo 7-14gg quarantena):** `docker compose ... down -v` + `rm -rf /root/supabase/docker/volumes`. Backup `.sql.gz`/`.dump` fanno fede.
- **Restore:** `gunzip supabase-db-final-cluster-*.sql.gz | psql -U postgres` in nuovo Postgres.

## TODO aperti
1. App Puntify CAT config con `SUPABASE_URL=https://api-cat.puntify.it` + `PUNTIFY_ANON_KEY` (in `/opt/ops/.env`).
2. DNS `cat.puntify.it` da propagare/creare (utente in corso 2026-05-16).
3. Google Cloud Console: aggiungere redirect URI `api-cat.piracity.app/auth/v1/callback`.
4. Audit users tagging per separare puntify-only vs piracity-only.
5. Sessions/refresh_tokens NON migrate: utenti CAT rilogano alla prima richiesta.
6. DNS `supabase-cat.duckdns.org` ancora attivo su www.duckdns.org ma Caddy non gestisce più: rimuoverlo se non serve.
7. Decommission definitivo Supabase OSS legacy dopo periodo quarantena.

## Link correlati
- [[wiki/projects/puntify|Puntify]]
- [[wiki/projects/piracity|Piracity]]
- [[wiki/people/stefano|Stefano Gitto]]

## Gotcha piratopoly leftover #2 (2026-06-22)
UPDATE su `piracity.maps` rifiutato: `relation "piratopoly.cities" does not exist`. Un trigger/funzione sul DB CAT riferisce ancora il vecchio schema `piratopoly` (stessa famiglia di `nearby_vouchers`→piratopoly.vouchers). Blocca QUALSIASI write su maps (anche prezzi, anche da DbGate). Fix: trovare la funzione (`SELECT ... FROM pg_proc WHERE pg_get_functiondef(oid) ILIKE '%piratopoly%'`) e CREATE OR REPLACE con `piracity`. Richiede accesso SQL al cluster (DbGate o psql su pro-open) — non disponibile da claudebot box (5432 interno, no SSH pro-open).
