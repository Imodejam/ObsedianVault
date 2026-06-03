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

## Integrazione Google Calendar (pianificata 2026-05-18)

Sincronizzazione **bidirezionale** appuntamenti ↔ Google Calendar. Piano dettagliato: `puntify/docs/Requests/20260518.1.md`.

### Scelte chiave
- **Granularità**: per **shop** (1 calendar Google per shop), non per operator.
- **Token**: riuso OAuth Google esistente (`SupabaseService.GetGoogleSignInUrl`) estendendo scope con `calendar.events` + `calendar.readonly` + `access_type=offline&prompt=consent`.
- **Outbound** Puntify → Google: ogni create/update/cancel di `bookings` o `booking_manual_blocks` push evento via `Google.Apis.Calendar.v3`.
- **Inbound** Google → Puntify: `events.watch` + webhook `POST /api/google/calendar/webhook` → eventi esterni diventano `booking_manual_blocks` con `origin='google'` (bloccano disponibilità, non creano `bookings`).
- **Attendees**: `customer_email` aggiunto come attendee Google → invito + reminder automatici, condizionato a `gdpr_consent=true` della prenotazione.
- **Fallback calendar**: `primary` dell'account Google connesso.
- **Timezone**: nuova colonna `shops.timezone` default `Europe/Rome`.

### Modello dati nuovo
- `puntify.shop_google_tokens` (PK `shop_id`, refresh+access cifrati AES-GCM).
- `puntify.google_calendar_watches` (canale push, sync_token, scadenza).
- `puntify.shops` + colonne `timezone`, `google_calendar_id`, `google_sync_enabled`, `google_send_invites`.
- `puntify.bookings` + `puntify.booking_manual_blocks` + colonne `google_event_id`, `google_calendar_id`, `google_etag`, `google_synced_at` (`+ origin` su manual_blocks).

### GDPR
- Privacy Policy aggiornata: nuovo **art. 4-bis** in `Puntify.Vetrina/Pages/Privacy.razor` (sub-responsabile Google LLC esteso, basi giuridiche, diritti del Cliente, disattivazione).
- Pagina vetrina `Pages/Prenotazioni.razor` aggiornata: sezione dedicata "Sincronizzazione Google Calendar bidirezionale" con link a Privacy art. 4-bis.
- Trasferimento extra-UE: SCC + DPF UE-USA (Google LLC sub-responsabile ex art. 28).

## Mercato target
- **Prima zona: ROMA** — bar, caffetterie, parrucchieri, lavanderie (alta frequentazione, basso ticket)
- Prodotto LIVE: sito + app up and running
- Obiettivo: primi 300 esercenti

## Sessione 2026-05-26/27 — Feature principali aggiunte

### Menu pubblico (/m/{slug}/menu)
- Hero 280px con proporzioni da mockup, card categorie lista su mobile / griglia su desktop
- Badge piatti consigliati delicati, filtri applicati anche su evidenza
- Sezioni vuote nascoste, zoom bloccato, auto-retry riconnessione Blazor
- Dettaglio piatto con tasto + rapido, X visibile su mobile
- Tavoli: fix deserializzazione JSON, label "Tavolo N" tradotto 20 lingue

### Pagina shop (/m/{slug})
- Rifatta con stile menu-public.css: hero, info locale, wifi con copia password, CTA menu/prenotazioni
- Vista ?v=locale rimossa dal menu, brand name nel menu linka alla pagina shop
- Sitemap dinamica con pagine shop e menu generate da DB

### Menu editor (merchant)
- Drag-and-drop sezioni e piatti con SortableJS
- Sezioni collassabili (default chiuse)
- Sistema bozza/pubblica: snapshot JSON al publish, modifiche non visibili finché non pubblicate

### Ordini e POS
- Flusso ordini completo: menu pubblico → menu_public_orders → dashboard merchant
- Tavoli occupati automaticamente da ordini attivi
- POS esercente: overlay con 3 modalità (tavolo/asporto/delivery), browse menu, codice ordine sequenziale (#A01)
- Notifica ordini dedicata (non più "scontrino")
- Campo ricerca ordini/tavoli nella dashboard (tab bar)

### Display sala e cucina
- Display sala clienti (stile McDonald's): sfondo scuro, codici ordine grandi, auto-refresh 10s
- Display cucina: 3 colonne kanban, dettaglio piatti, bottone avanza stato
- Pagina hub "Monitor" nella home merchant, icona dedicata
- FAB Nemi nascosto nelle pagine display

### Nemi (AI assistant)
- Feedback obbligatorio nel system prompt: ACK + report finale
- Rate limit: max 5 richieste/giorno per shop
- Max 3 retry task, max 30min età, max 10 step
- Badge notifica (pallino rosso) su FAB e icona home

### Servizi e feature toggle
- Nuova sezione "Ordinazioni" nei servizi: menu digitale, asporto, tavoli, schermi
- Feature flags persistenti (bitmask enabled_features: menu=16, screens=32)
- Icone home nascoste quando servizio disattivato
- Fix serializzazione Postgrest: proprietà computed → extension methods
- WiFi spostato dopo Prenotazioni con toggle switch

### Icone
- Nuova icona Transazioni.webp
- Nuova icona Monitor.webp (rinominata da Schermi)

## Sessione 2026-05-27 — Redesign prenotazione tavolo

### Pagina prenotazione tavolo (QuickTableBooking)
- Redesign completo da form piatto a esperienza guidata premium
- Layout desktop: sidebar (brand, riepilogo scuro, stepper verticale, info card) + card principale con 3 sezioni form
- Layout mobile: header compatto sticky, stepper orizzontale, summary compatto 4-cell, card per sezione, CTA sticky bottom
- Palette neutra calda (#FAF7F0 bg, #2E3A18 primary, #A9823A accent) personalizzabile per merchant via --accent
- Guest stepper +/- al posto della select, chip orari al posto di datetime-local, date e time separati
- CSS :has() per nascondere book-header/book-footer del parent quando table booking è attivo
- Componente estratto fuori da .book-body in PublicBookingFlow per avere layout autonomo
- File modificati: QuickTableBooking.razor (riscrittura), PublicBookingFlow.razor (estrazione), booking.css (Vetrina, +400 righe)

## Pagamenti booking — Stripe Connect (Fase 4, in definizione 2026-06-03)
Incasso reale delle prenotazioni postazioni/ombrelloni. I soldi vanno al **lido** (esercente), Puntify è la piattaforma → **Stripe Connect (marketplace)**, NON l'abbonamento esercente.

- **Stato pre-pagamento (Fase 3 carrello DONE)**: `Puntify.Vetrina/Components/Booking/CartCheckout.razor` registra le prenotazioni via `BookingPublicService.ReserveResourceAsync` (`POST /api/public/booking/table/resource/reserve`). Item a pagamento (`CartItem.PaymentMode` = free|full|deposit, `DueNow`=acconto/saldo) mostrano nota "pagamento Stripe in arrivo"; nessun incasso effettivo.
- **Chiavi**: test (pk/sk) in `Puntify.Server/appsettings.Development.json` → sezione `Stripe` {PublishableKey, SecretKey, WebhookSecret}. File gitignored (riga 348), chmod 600. Mai committare la SecretKey.
- **Decisioni confermate da Stefano (2026-06-03)**:
  - Account Connect lidi = **Express** (KYC/onboarding ospitati da Stripe, registrazione mobile).
  - ⚠️ AGGIORNATO (2026-06-03, msg 3025): Commissione Puntify sulle prenotazioni = **6% + 0,30€** a prenotazione (application_fee, configurabile; default nel codice). Sostituisce il precedente "0 commissione". Fee Stripe (≈1,5%+0,25€/transazione, 2€/mese account Express, payout) restano **a carico del lido** sull'incasso (addebito diretto). I fondi vanno al lido; ricavo Puntify = abbonamento + commissione.
  - Modello di addebito Connect = **"Stripe gestisce le tariffe"** (Stripe addebita le fee direttamente all'account del lido → Puntify paga 0, nessun conteggio da gestire). Costi Express IT: 2€/mese per lido attivo + 0,25%+0,10€/payout + 1,5%+0,25€/transazione — tutti a carico del lido in questo modello.
  - Onboarding lido = **nuova pagina "Pagamenti"** in `Puntify.App`, accessibile dal menu home. Responsive (mobile+desktop).
  - Flusso = carrello → Stripe Checkout sull'account del lido → conferma su **webhook** → prenotazione confermata/pagata. Acconto: paga acconto ora, saldo in loco (PaymentMode deposit/full/free).
- **Fatto 2026-06-03**: FAQ vetrina aggiornata (Boo8 pagamento/acconto ora "supportato via Stripe" + nuova Boo9 "chi paga le commissioni") in tutte le lingue + JSON-LD; doc `docs/puntify-product-overview.md` sezione "Pagamenti online prenotazioni". Build+restart vetrina OK, live IT/EN.
- **Da implementare**: sezione `Stripe` SDK lato Server (create Express account + AccountLink onboarding, Checkout Session su account connesso, webhook handler), colonne DB (`shops.stripe_account_id`/stato onboarding, stato pagamento su prenotazione), pagina Pagamenti App, redirect Checkout + pagine success/cancel nel CartCheckout, webhook secret (whsec_) da generare.

## Prossimi passi
- [ ] Stripe Connect Fase 4: onboarding lido + Checkout + webhook conferma prenotazione
- [ ] Display ordini pubblico per TV (completare UX)
- [ ] POS: importi manuali (da decidere)
- [ ] Piano editoriale social

## Assets
- Sito: https://puntify.it
- Google Drive: `OpenClawData/progetti/Puntify`

## Documenti collegati
- [[wiki/projects/puntify-design-system|Design System (cfg-*)]] — palette/tipografia/componenti per Puntify.App, obbligatorio per nuove pagine
- [[wiki/projects/puntify-nomi-alternativi|Nomi alternativi]] — lista 35 (top 10 raccomandati) post-diffida Spotify
- [[wiki/projects/puntify-lista-esercenti-trastevere-testaccio|Lista esercenti Trastevere+Testaccio]] — 20 target prima zona
- [[wiki/projects/puntify-template-approccio-esercenti|Template approccio esercenti]] — script vendita

## Link correlati
- [[wiki/people/stefano|Stefano Gitto]]
- [[wiki/projects/cat-stack|CAT Stack]]
