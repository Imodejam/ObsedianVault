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
