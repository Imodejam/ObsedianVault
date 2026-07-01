# Working context — 2026-07-01

## i18n App Puntify (Fase 3) — COMPLETATA
- 10 lingue: it(neutro) + en/es/fr/de/pl/uk/ro/nl/ru. AppResource[.lang].resx = 2539 chiavi ciascuna (allineate).
- Meccanismo: IStringLocalizer<Puntify.App.AppResource>, @L["key"]; csproj BlazorWebAssemblyLoadAllGlobalizationData=true; cultura da account.language/localStorage in Program.cs.
- Blocchi: CLIENTE 258 (1081495) | ESERCENTE 2141 (b231bad estr + 4157321 trad) | CONDIVISI 140 (6105431 estr + 29fcc0f trad).
- /admin NON tradotto (resta IT, uso interno staff) — scelta Stefano.



## COLLAUDO IN MODALITA' PROD-LIKE (2026-07-01, attivo) — COME TORNARE AL DEV
- Stefano testa la build di PRODUZIONE in collaudo: app-cat serve la publish Release statica.
- Publish: dotnet publish Puntify.App -c Release -o publish/app-prod -p:WasmEnableSIMD=true -p:WasmEnableExceptionHandling=true -p:RunAOTCompilation=false
  (override per evitare workload wasm-tools non installato). Output servito: publish/app-prod/wwwroot/app (base href / gia' a root).
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
