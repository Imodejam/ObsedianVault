# Working context — 2026-07-01

## i18n App Puntify (Fase 3) — COMPLETATA
- 10 lingue: it(neutro) + en/es/fr/de/pl/uk/ro/nl/ru. AppResource[.lang].resx = 2539 chiavi ciascuna (allineate).
- Meccanismo: IStringLocalizer<Puntify.App.AppResource>, @L["key"]; csproj BlazorWebAssemblyLoadAllGlobalizationData=true; cultura da account.language/localStorage in Program.cs.
- Blocchi: CLIENTE 258 (1081495) | ESERCENTE 2141 (b231bad estr + 4157321 trad) | CONDIVISI 140 (6105431 estr + 29fcc0f trad).
- /admin NON tradotto (resta IT, uso interno staff) — scelta Stefano.

## Fix collaterali oggi (committati)
- manifest.json path relativi (icone PWA 404) d9bf2de
- BlazorWebAssemblyLoadAllGlobalizationData 2c339fd

## PROSSIMI (da valutare con Stefano)
- Deploy prod: replicare resx + csproj + manifest (git). Ricordare hard-refresh WASM.
- "Vedi come cliente": collegare dati reali per-schermata (via API admin service-role). Framework gia' pronto.
- Eventuale QA visivo delle lingue sulle schermate principali.
