# Puntify

## Obiettivo
Fidelity card digitale per esercenti: il cliente accumula punti mostrando un QR code, l'esercente scansiona e carica punti. Niente tessere fisiche.

## Prodotto
- **PWA** installabile come app nativa (iOS/Android/web)
- Esercente scansiona QR code cliente → carica punti automaticamente
- Analisi abitudini d'acquisto + promozioni mirate
- Funziona anche senza POS, con integrazioni custom
- Carte visibili offline dal cliente, transazioni richiedono connessione
- Multi-negozio illimitato, clienti/transazioni/premi illimitati

## Prezzi
- Esercente: €9,99/mese o €99,99/anno (-20€)
- Cliente: app gratuita
- Nessun costo attivazione, nessun vincolo, disdetta quando vuoi

## Offerta Lancio (primi 300 esercenti)
- 3 mesi gratis con Codice Amico
- 2 mesi gratis senza codice
- Nessuna carta di credito richiesta

## Programma Referral
- **Esercente → collega**: +1 mese gratis per iscrizione pagata (max 12 mesi cumulabili)
- **Cliente → esercente**: buono Amazon (€10 piano mensile, €20 annuale)

## Competizione (vs altre soluzioni)
| | Altre | Puntify |
|---|---|---|
| Attivazione | €500-2000 | Gratis |
| Abbonamento | €29-99/mese | €9,99/mese |
| Carte fisiche | Costo extra | Non servono |
| App cliente | Spesso no | Inclusa |
| Multi-negozio | Limitato | Illimitato |
| Contratto | 12-24 mesi | Nessun vincolo |

## Società
- **Puntify S.R.L.**, Via Giuseppe Pascaletti, Cosenza
- P.IVA: 12345678912
- Email: info@puntify.it
- GDPR compliant, crittografia end-to-end

## Stato attuale
[2026-04-21] — Early stage. Sito live con Home, Prezzi, FAQ, Privacy, Termini. Alcune funzionalità ancora in sviluppo.

## Stack / Architettura
Monorepo `.NET` su `github.com/Imodejam/puntify` (branch `master`):
- **Puntify.Server** — API .NET (Controllers, Services, Models, Middleware, Templates, EF migrations sotto `Database/`). `Puntify.Server.csproj`.
- **Puntify.App** — Blazor app (PWA cliente/esercente: `App.razor`, Components, Pages, wwwroot). `Puntify.App.csproj`.
- **Puntify.Vetrina** — Blazor sito marketing (`Pages`, `Resources` i18n, `Routes.razor`). `Puntify.Vetrina.csproj`.
- **Punto.Shared** — libs condivise (DTOs, Models, Services). `Puntify.Shared.csproj`.
- Solution: `Puntify.sln` (+ `Punto.slnx`).
- Build helper: `clean-build.sh` / `.bat`.
- Docs: `docs/README_PROGETTO.md`, `docs/puntify-product-overview.md`, `docs/Tracciamento Modifiche Database.sql`.

### Clone dev/CAT su pro-open (2026-05-18)
- Path: `/home/progetti/puntify/` (clone monorepo intero, owner `claudebot`, ~150M).
- Branch checkout: `master`.
- Remote: `git@github.com:Imodejam/puntify.git` (clonato come `root` con SSH-key host di Imodejam → chiave deploy claudebot specifica `github_piracity` non ha accesso a questo repo; per push futuri lato claudebot serve aggiungere chiave dedicata o usare workflow root).
- **.NET SDK 8.0.126** installato system-wide via `apt install dotnet-sdk-8.0` (`/usr/bin/dotnet`).
- Fix locale (committabile): `Puntify.Vetrina/Directory.Build.props` aveva path Windows hardcoded (`C:\Builds\...`) per `BaseOutputPath`/`BaseIntermediateOutputPath`. Avvolti in `Condition="'$(OS)' == 'Windows_NT'"` → build cross-platform funzionante.

### Systemd services dev/CAT (2026-05-18)
Pattern identico a Piracity dev. Tutti su `127.0.0.1` (loopback), Caddy reverse-proxy futuro davanti.

| Service | Porta | Workdir | Comando | Note |
|---|---|---|---|---|
| `puntify-server.service` | `127.0.0.1:8001` | `Puntify.Server/` | `dotnet watch run --non-interactive` | API ASP.NET. Swagger su `/swagger`. |
| `puntify-app.service` | `127.0.0.1:8002` | `Puntify.App/` | `dotnet watch run --non-interactive` | Blazor WASM client, servito via DevServer. `StaticWebAssetBasePath=app`. |
| `puntify-vetrina.service` | `127.0.0.1:8003` | `Puntify.Vetrina/` | `dotnet watch run --non-interactive` | Blazor Server interattivo, 10 lingue. |

Serie porte 8001/8002/8003 (non 7001/7002 per evitare conflitto con `concilium.service` enabled — bind API/web Concilium su quelle porte; salta al boot se occupate).

Env vars chiave (in unit file):
- `ASPNETCORE_ENVIRONMENT=Development` → carica `appsettings.Development.json`.
- `ASPNETCORE_URLS=http://127.0.0.1:700x` → bind locale.
- `DOTNET_USE_POLLING_FILE_WATCHER=true` → file watcher polling (evita inotify limits).
- `DOTNET_WATCH_RESTART_ON_RUDE_EDIT=true` → rebuild su edit hot non applicabile.
- `User=claudebot`, `Restart=always`.

### Config dev (in `/home/progetti/puntify/...`, gitignored)
Tutti e 3 i file sono coperti da `.gitignore` (`appsettings.Development.json` riga 348, `**/wwwroot/appsettings.json` riga 350).

**`Puntify.Server/appsettings.Development.json`** (chmod 600):
- `Supabase.{Url=https://api-cat.puntify.it, AnonKey=$PUNTIFY_ANON_KEY, ServiceRoleKey=$PUNTIFY_SERVICE_ROLE_KEY, Schema=puntify}`
- `Firebase.CredentialPath` → JSON service account già committato in repo (`Config/puntify-firebase-adminsdk.json`)
- `Resend.ApiKey=re_…` + `Resend.FromAddress="Puntify CAT <noreply@puntify.it>"`
- `Storage.{Endpoint, PublicBaseUrl}=https://files.puntify.it`, `Storage.{AccessKey=puntify-api, SecretKey, Region=us-east-1, ForcePathStyle=true, PresignedUrlExpiryMinutes=60}`
- `Storage.Buckets`: `Shops=shopimages-cat`, `Accounts=accountimages-cat`, `Receipts=receiptimages-cat` (pattern `*-cat` per separare CAT da prod su MinIO esterno condiviso `files.puntify.it`)

**`Puntify.App/wwwroot/appsettings.json`** (chmod 644, client WASM lo legge in chiaro):
- `Supabase.{Url, AnonKey, Schema=puntify}`
- `ServerUrl=http://127.0.0.1:8001`
- `Security.ApiKey=""` (da popolare quando flusso API key definito)
- `StorageClient.PublicBaseUrl=https://files.puntify.it` + `StorageClient.Buckets` (`*-cat`)

**`Puntify.Vetrina/appsettings.Development.json`** (chmod 600):
- `Supabase.{Url, AnonKey, Schema=puntify}`
- **`AppUrl=https://app-cat.puntify.it`** (override default `https://www.puntify.it` di `AppConfiguration.cs`: `LoginUrl => $"{AppUrl}/login"`)

### Fix Supabase Schema (2026-05-18)
PGRST106 risolto: Supabase C# SDK 0.16.2 invia `Accept-Profile: public` di default. PostgREST con `PGRST_DB_SCHEMAS=puntify,storage` rifiuta. **Fix codice committabile** (cross-platform CAT/prod): in tutti e 3 i `Program.cs` (App, Server, Vetrina) lettura schema da config:
```csharp
var supabaseSchema = builder.Configuration["Supabase:Schema"];
// ...
if (!string.IsNullOrEmpty(supabaseSchema)) options.Schema = supabaseSchema;
```
CAT setta `"Supabase:Schema": "puntify"` negli `appsettings.Development.json`/`wwwroot/appsettings.json`. Prod lascia chiave assente → default SDK (`public`) → compat con prod attuale.

### Caddy reverse-proxy (cat.puntify.it + app-cat.puntify.it)
Pattern multi-domain (DevServer Blazor WASM ignora `StaticWebAssetBasePath=app` — vedi commento `Puntify.App/wwwroot/index.html:17` di Stefano; assets `/_framework/*`, `/js/*` puntano sempre alla root del DevServer, quindi se servita sotto path `/app/*` su single-domain → 404 a cascata).

Caddyfile in `/opt/ops/caddy/Caddyfile`:

**`cat.puntify.it`** (Vetrina + Server):
- `https://cat.puntify.it/` → :8003 (Vetrina Blazor Server)
- `https://cat.puntify.it/api/*` → :8001 (Server API, Controllers `[Route("api/...")]`)
- `https://cat.puntify.it/swagger*` → :8001 (Swagger UI per debug)

**`app-cat.puntify.it`** (App Blazor WASM su sub-domain dedicato):
- `https://app-cat.puntify.it/` → :8002 (App index)
- `LoginUrl` Vetrina = `https://app-cat.puntify.it/login` (via `AppUrl` in `appsettings.Development.json`)

Cert ACME ECDSA Let's Encrypt automatico per entrambi i domini. WebSocket SignalR (`/_blazor/negotiate`) supportato di default. DNS:
- `cat.puntify.it` → 212.227.21.104 ✓ attivo
- `app-cat.puntify.it` → **DA CREARE** (record A → 212.227.21.104 lato Hetzner/registrar Puntify). Caddy emette cert al primo accesso.

### Comandi utili
```bash
sudo systemctl restart puntify-server
sudo journalctl -u puntify-app -f
ss -tlnp | grep -E ':800[1-3]'
sudo docker compose -f /opt/ops/docker-compose.yml restart ops-caddy
```

## Ambiente CAT
Vedi [[wiki/projects/cat-stack|CAT Stack]] per i dettagli infrastrutturali. Riepilogo Puntify:
- **DB**: `puntify_cat` su cluster `ops-postgres` in `/opt/ops/` (pro-open). Schema `puntify` (29 tabelle, match prod, rinominato da `public` il 2026-05-17).
- **Auth**: GoTrue v2.179.0 dedicato (`gotrue-puntify-cat`, 127.0.0.1:18999).
- **REST**: PostgREST v12.2.3 dedicato (`postgrest-puntify-cat`, 127.0.0.1:18998), `PGRST_DB_SCHEMAS=puntify,storage`.
- **Endpoint client**: `SUPABASE_URL=https://api-cat.puntify.it`, anon key in `/opt/ops/.env`. Client devono inviare `Accept-Profile: puntify` (Supabase C# SDK: `options.Schema = "puntify"`).
- **Frontend CAT**: `https://cat.puntify.it` (`GOTRUE_SITE_URL`).
- **DbGate**: `https://db-cat.puntify.it`.
- **Storage**: 5 objects metadata migrati; file fisici restano su MinIO esterno (`files.puntify.it` bucket `*-cat`).
- **OAuth Google**: redirect URI `https://api-cat.puntify.it/auth/v1/callback` aggiunto su client OAuth prod.

## Mercato target
- **Prima zona: ROMA** — bar, caffetterie, parrucchieri, lavanderie (alta frequentazione, basso ticket)
- Prodotto LIVE: sito + app up and running
- Obiettivo: primi 300 esercenti

## Prossimi passi
- [ ] Definire stack tecnico
- [ ] Piano editoriale social

## Assets
- Sito: https://puntify.it
- Google Drive: `OpenClawData/progetti/Puntify`

## Documenti collegati
- [[wiki/projects/puntify-nomi-alternativi|Nomi alternativi]] — lista 35 (top 10 raccomandati) post-diffida Spotify
- [[wiki/projects/puntify-lista-esercenti-trastevere-testaccio|Lista esercenti Trastevere+Testaccio]] — 20 target prima zona
- [[wiki/projects/puntify-template-approccio-esercenti|Template approccio esercenti]] — script vendita

## Link correlati
- [[wiki/people/stefano|Stefano Gitto]]
- [[wiki/projects/cat-stack|CAT Stack]]
