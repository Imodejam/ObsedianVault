# Working context — 2026-07-01

## i18n App Puntify (Fase 3) — COMPLETATA
- 10 lingue: it(neutro) + en/es/fr/de/pl/uk/ro/nl/ru. AppResource[.lang].resx = 2539 chiavi ciascuna (allineate).
- Meccanismo: IStringLocalizer<Puntify.App.AppResource>, @L["key"]; csproj BlazorWebAssemblyLoadAllGlobalizationData=true; cultura da account.language/localStorage in Program.cs.
- Blocchi: CLIENTE 258 (1081495) | ESERCENTE 2141 (b231bad estr + 4157321 trad) | CONDIVISI 140 (6105431 estr + 29fcc0f trad).
- /admin NON tradotto (resta IT, uso interno staff) — scelta Stefano.


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
