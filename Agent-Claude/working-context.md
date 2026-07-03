## COLLAUDO app-cat: modalita' PROD-LIKE ATTIVA (fix cultura definitivo 2026-07-01 sera)
- app-cat serve la publish Debug+LoadAll (tutte 10 lingue, icudt completo) via serve-app-prod.js su :8002. DevServer FERMO.
- Motivo: il DevServer sharded dava 'culture not supported' per pl/uk/ro/nl/ru. Ora risolto.
- CONSEGUENZA: niente hot-reload sull'app. Dopo modifiche a Puntify.App: ripubblicare (dotnet publish -c Debug -o publish/app-prod -p:BlazorWebAssemblyLoadAllGlobalizationData=true) e riavviare node (kill listener :8002 + setsid node serve-app-prod.js). La Vetrina (:8003) resta in dotnet watch, non impattata.
- Include intera feature operatore (F1 DB, F2 server, F3a/3b app) + indirizzo Places.

# Working context — 2026-07-01 (sera)

## TASK ATTIVI (multi-workstream)
1. OPERATORE Elimina Code (feature grossa, a fasi):
   - Fase 1 DB: FATTA (commit 1893ab9, migration 20260702 applicato a CAT). operator_queues + queue_call_next_across + shop_operators.user_id/email.
   - Design: operatore = utente standard email+password, account.role=4. Esercente crea (email+pw iniziale) da /operators, assegna code. Login standard -> home ridotta -> icona Elimina Code -> scegli coda/tutte -> opera.
   - PROSSIME: Fase 2 server (endpoint crea-operatore via GoTrue admin/users service_role; guard auth operatore su JWT sub->shop_operators.user_id; endpoint code operatore + call_next_across; cambio password). Fase 3 app (routing role 4 -> home operatore; home ridotta; select coda/tutte; operate reuse QueueOperate; scheda operatore in /operators con email+pw+assegnazione code; cambio pw in account). i18n 10 lingue, responsive.
2. INDIRIZZO Google Maps in ShopEdit: chiave in appsettings GoogleMaps:ApiKey. Agente sta facendo Places Autocomplete -> riempie Address + Latitude/Longitude (gia' nel model). DA FARE dopo: tradurre chiavi nuove, commit. NB chiave da restringere per dominio (detto a Stefano).
3. HERO MerchantHome: FATTO (commit 30e6cad).

## COLLAUDO
- Modalita' DEV (DevServer dotnet watch :8002, sharded). Le 5 lingue non-EFIGS ripiegano su IT in dev.
- Per test prod-like (tutte 10 lingue): publish Debug+LoadAll servito da serve-app-prod.js (vedi sotto). Attualmente NON attivo (siamo in dev).

## Riepilogo giornata (i18n + fix) — vedi sotto

# Working context — 2026-07-01

## i18n App Puntify (Fase 3) — COMPLETATA
- 10 lingue: it(neutro) + en/es/fr/de/pl/uk/ro/nl/ru. AppResource[.lang].resx = 2539 chiavi ciascuna (allineate).
- Meccanismo: IStringLocalizer<Puntify.App.AppResource>, @L["key"]; csproj BlazorWebAssemblyLoadAllGlobalizationData=true; cultura da account.language/localStorage in Program.cs.
- Blocchi: CLIENTE 258 (1081495) | ESERCENTE 2141 (b231bad estr + 4157321 trad) | CONDIVISI 140 (6105431 estr + 29fcc0f trad).
- /admin NON tradotto (resta IT, uso interno staff) — scelta Stefano.



## COLLAUDO IN MODALITA' PROD-LIKE (2026-07-01, attivo) — COME TORNARE AL DEV
- Stefano testa la build di PRODUZIONE in collaudo: app-cat serve la publish Release statica.
- Publish (FUNZIONANTE): dotnet publish Puntify.App -c DEBUG -o publish/app-prod -p:BlazorWebAssemblyLoadAllGlobalizationData=true
  (NB: Release senza workload wasm-tools -> runtime WASM rotto: LinkError __assert_fail. Debug usa il runtime precompilato = stabile + LoadAll per tutte le lingue.) Output: publish/app-prod/wwwroot/app (base href / a root).
- Server statico: /home/progetti/puntify/serve-app-prod.js (node, :8002, SPA fallback, MIME wasm). Avviato detached (setsid nohup). Log: serve-app-prod.log. pid via `ss -tlnp | grep :8002`.
- Caddy NON toccato (app-cat -> 127.0.0.1:8002). Backend = api-cat (dati collaudo).
- icudt.dat pieno (1.5MB) servito -> globalizationMode=all -> tutte 10 lingue OK, niente errore cultura.

### TORNARE AL DEV (dotnet watch, hot reload):
1. Killare il node server: `pkill -f serve-app-prod.js`
2. `sudo systemctl start puntify-app.service` (ri-occupa :8002 con dotnet watch, sharded).
NB: non lasciare entrambi su :8002.

## GOTCHA i18n WASM (2026-07-01) — LEGGERE
- BlazorWebAssemblyLoadAllGlobalizationData=true NON va in Debug: il DevServer (dotnet watch)
  serve icudt.dat 404 -> SRI fail -> WASM non parte (loader infinito su OGNI pagina, login incluso).
- Config attuale: flag SOLO in Release (csproj). Collaudo(Debug)=sharded (EFIGS: it/en/es/fr/de switchano live;
  pl/uk/ro/nl/ru ripiegano su IT in collaudo). PROD(Release)=icudt.dat statico servito da Caddy -> tutte 10 lingue.
- Se serve testare TUTTE le 10 lingue in collaudo: servire una build pubblicata (non dotnet watch) o verificare
  se un clean-build fa servire icudt.dat dal DevServer (icudt.dat in bin era stale del 6 mag).

## Fix collaterali oggi (committati)
- manifest.json path relativi (icone PWA 404) d9bf2de
- BlazorWebAssemblyLoadAllGlobalizationData 2c339fd

## PROSSIMI (da valutare con Stefano)
- Deploy prod: replicare resx + csproj + manifest (git). Ricordare hard-refresh WASM.
- "Vedi come cliente": collegare dati reali per-schermata (via API admin service-role). Framework gia' pronto.
- Eventuale QA visivo delle lingue sulle schermate principali.

## PENDING (2026-07-02) — Toggle abilita/disabilita schermi Elimina Code
- Stefano vuole toggle su Totem/Display per abilitarli/disabilitarli.
- Chiesto conferma (msg 4880) su enforcement: blocco reale del link (DB flag kiosk_totem_enabled/kiosk_display_enabled su shop + server rifiuta + Vetrina "schermo disabilitato") vs solo stato visivo.
- Default se non risponde: opzione funzionale completa. Serve MIGRATION DB da replicare in PROD.

## RISOLTO (2026-07-02) — Toggle schermi Elimina Code: enforcement REALE fatto e testato. ⚠️ MIGRATION DA REPLICARE IN PROD: docs/DB Migrations/20260702_kiosk_screen_toggles.sql (2 colonne su shops).

## PENDING (2026-07-02) — TASK GROSSO: Modulo vendita intra-UE (VIES + reverse charge + INTRASTAT)
- Fasi: 0 (mappatura codice) + 0-bis (audit+rinomina campi fiscali IT->neutri) + 4 processi (onboarding VIES / fatturazione subscription / fattura reverse charge / eu_sales_ledger INTRASTAT) + servizi .NET (IViesValidator, IVatRegimeResolver) + config per-paese + UI country-aware + PROCESS.md + test.
- Vincolo: seller VAT = CONFIG (mai hardcode); gira in sandbox anche senza P.IVA seller. Target 1: Spagna. DEV, no retrocompat, rinomina fisica ok.
- ORA: 5 subagent di analisi in corso. Output atteso: FASE 0 mappatura + file da modificare/creare, FASE 0-bis inventario+mappa rinomina. ATTENDERE CONFERMA Stefano prima di implementare. Poi ordine: rinomina->migration->servizi->onboarding+webhook->config->UI->PROCESS.md->test.

## AGG (2026-07-02) Intra-UE: MILESTONE Fase0-bis+Processo1 committato/pushato+collaudo. Resta SOLO fase Subscription Stripe (fatturazione ricorrente) su prompt Stefano. Prod checklist nel log.

## PENDING (2026-07-03) — Fix registrazione negozio -> account vuoto (msg 5041)
- BUG: MerchantRegistration salva un MerchantProfile (BusinessName/ContactFirstName/LastName/Email/Phone) via Supabase.CreateMerchantProfile, ma /merchantAccount legge Account.DisplayName + Account.MobileNumber (Supabase.GetCurrentAccount) -> mai popolati dalla registrazione -> campi vuoti.
- FIX (da applicare DOPO che il subagent phone-validation ha finito di editare MerchantRegistration.razro, per non conflittare): in HandleSubmit, dopo CreateMerchantProfile, chiamare Supabase.UpdateDisplayName($"{_contactFirstName} {_contactLastName}".Trim()) e Supabase.UpdateMobileNumber(_contactPhone.Trim()) cosi' l'account riflette i dati inseriti. (Ragione sociale resta business-level, in ShopEdit anagrafica.)
- Poi republish app + commit + reply 5042 conferma.

## RISOLTO (2026-07-03) — Fix registrazione->account (5041): applicato in HandleSubmit (UpdateDisplayName+UpdateMobileNumber best-effort). + validazione prefisso telefono su tutte le pagine di raccolta.

## DECISIONE (2026-07-03) — Fatturazione abbonamento: USARE STRIPE TAX (msg 5063)
- Il Processo 2 (Subscription Stripe / fatturazione ricorrente intra-UE) userà Stripe Tax: calcola/riscuote/versa IVA (OSS B2C aliquota Paese cliente + reverse charge B2B) senza mantenere a mano 27 aliquote + dichiarazioni OSS. Alternativa scartata: Merchant of Record (Paddle/Lemon Squeezy). Il modulo fiscale attuale (shop_fiscal/VatRegimeResolver/VIES) resta per onboarding/identità/regime.

## IN CORSO (2026-07-03) — Vetrina: nuovo servizio "Elimina Code" (msg 5065/5066)
- STEP 1 (subagent in corso): pagina Pages/EliminaCode.razor (/elimina-code) sullo schema Fidelizzazione/Prenotazioni, prefisso CSS elc-, chiavi i18n Meta_EliminaCode_* + Elc_* + Nav_EliminaCode + Mega_Feat_EliminaCode_Desc + Footer_Link_EliminaCode in 10 lingue SharedResource; registrazione Header mega-menu + Footer + SitemapService.
- HERO IMG: usare service-eliminacode.webp (gia esiste, ottima: totem+monitor+attesa). Close-up opzionali offerti a Stefano.
- STEP 2 (DOPO subagent, per non conflittare su resx): integrare Elimina Code in Home.razor (griglia servizi), FAQ.razor, e altre pagine che elencano i servizi.
- STEP 3: aggiungere il servizio nelle pagine Settore rilevanti (farmacie, ambulatori/medici, uffici/CAF/patronati, poste, agenzie immob/assic/viaggi, salumerie/gastronomie/pescherie/macellerie, banco servito).
- POI: republish Vetrina (dotnet watch, ma verificare), commit, screenshot verifica, report Stefano.

## AGG (2026-07-03) Elimina Code Vetrina — icona + foto (pending build)
- FIX icona mega-menu (5070): mancava .mega-card-icon--queue in app.css -> tile bianca. Aggiunta (gradiente teal). Header case "queue" gia ok.
- 3 FOTO Stefano (5071-5073) convertite webp -> images/photos/eliminacode-biglietto/monitor/cliente.webp; cablate in EliminaCode.razor come showcase (3 col, alt=Elc_Feat1/2/4Title, CSS elc-showcase/elc-shot). NIENTE nuove chiavi resx (riuso Feat title) per non conflittare col subagent 2.
- NON ho buildato/riavviato: subagent 2 (Settori/FAQ) sta editando resx/Settori/SectorCatalog/FAQ. Dopo il suo completamento: 1 build+restart Vetrina, verifica screenshot (pagina+icona+un paio di settori+faq), commit unico, report.
- QUEUE TASK (5074): pannello pagina Prezzi da restylare Apple/Stripe. Foto/illustrazioni: Stefano le genera se gli passo i prompt.

## PENDING (2026-07-03) — Prompt app Xcode webview Puntify (5096)
- Stefano vuole un prompt dettagliato per far creare a Claude un'app Xcode (iPhone/iPad/Mac) webview per Puntify.
- Chieste 4 domande (msg 5097): (1) URL prod-only vs switch collaudo; (2) push native APNs vs web/FCM esistenti; (3) distribuzione App Store vs TestFlight; (4) Mac Catalyst vs macOS nativo.
- DEFAULT dichiarati: SwiftUI+WKWebView, fotocamera abilitata (scan QR)+Info.plist, login persistente (cookie/localStorage via WKWebsiteDataStore), link esterni in Safari, pull-to-refresh/loading/offline/safe-area/rotazioni, icona+splash dal logo, bundle it.puntify.app nome "Puntify".
- Alla risposta (o "default"): produrre il prompt completo pronto da incollare in Claude Code.
- NB anche Google Wallet (Android) resta da avviare come impianto server.

## AGG (2026-07-03) — Prompt app Xcode CONSEGNATO (5098)
- Scelte Stefano: (1) prod app.puntify.it + switch nascosto collaudo (long-press 2s angolo/shake -> action sheet -> UserDefaults + basic auth user/puntify83! solo host app-cat); (2) FCM -> CHIARITO: web push NON funziona in WKWebView (motivo per cui non hanno mai funzionato), prompt usa Firebase NATIVO/APNs + token->webview; offerto debug separato FCM web; (3) App Store (account preso); (4) Mac Catalyst. Prompt salvato: scratchpad/prompt-app-puntify-xcode.md (inviato come file).
- OPEN: eventuale debug FCM web push sul sito (browser) se Stefano lo vuole.

## PENDING (2026-07-03) — Server MCP sul vault (5099)
- Stefano vuole un server MCP connesso al vault Obsidian (/home/progetti/obsidian-vault) esposto verso l'esterno, così un altro agent Claude puo accedervi. DEVE avere una API key (autenticazione). Da progettare/implementare dopo l'app.
