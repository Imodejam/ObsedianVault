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
| `puntify-server.service` | `127.0.0.1:7001` | `Puntify.Server/` | `dotnet watch run --non-interactive` | API ASP.NET. Swagger su `/swagger`. |
| `puntify-app.service` | `127.0.0.1:7002` | `Puntify.App/` | `dotnet watch run --non-interactive` | Blazor WASM client, servito via DevServer. `StaticWebAssetBasePath=app`. |
| `puntify-vetrina.service` | `127.0.0.1:7003` | `Puntify.Vetrina/` | `dotnet watch run --non-interactive` | Blazor Server interattivo, 10 lingue. |

Env vars chiave (in unit file):
- `ASPNETCORE_ENVIRONMENT=Development` → carica `appsettings.Development.json`.
- `ASPNETCORE_URLS=http://127.0.0.1:700x` → bind locale.
- `DOTNET_USE_POLLING_FILE_WATCHER=true` → file watcher polling (evita inotify limits).
- `DOTNET_WATCH_RESTART_ON_RUDE_EDIT=true` → rebuild su edit hot non applicabile.
- `User=claudebot`, `Restart=always`.

### Config dev (in `/home/progetti/puntify/...`, chmod 600, NON committate)
- `Puntify.Server/appsettings.Development.json` → `Supabase.Url=https://api-cat.puntify.it`, `Supabase.AnonKey=$PUNTIFY_ANON_KEY`, `Supabase.ServiceRoleKey=$PUNTIFY_SERVICE_ROLE_KEY`, `Firebase.CredentialPath` → JSON service account già in repo (`Config/puntify-firebase-adminsdk.json`).
- `Puntify.App/wwwroot/appsettings.json` (chmod 644, client WASM lo legge in chiaro) → Supabase URL/AnonKey + `ServerUrl=http://127.0.0.1:7001` + Security.ApiKey vuota (da popolare quando il flusso API key viene definito).
- `Puntify.Vetrina/appsettings.Development.json` → Supabase URL/AnonKey.

### Bug aperti post-standup (2026-05-18)
- **Vetrina · PGRST106**: client Supabase C# SDK invia richiesta a PostgREST senza `Accept-Profile: puntify` → errore `"The schema must be one of the following: puntify, storage"`. Fix lato codice: nel `SupabaseOptions` aggiungere `Schema = "puntify"` (verificato richiesto dopo rename schema `public` → `puntify` su CAT). Da applicare anche a Server e App se chiamano REST diretto su tabelle.

### Comandi utili
```bash
sudo systemctl restart puntify-server
sudo journalctl -u puntify-app -f
ss -tlnp | grep -E ':700[1-3]'
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
