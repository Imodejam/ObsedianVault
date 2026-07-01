# Working context — 2026-07-01

## Task corrente: i18n App Puntify (Fase 3 traduzioni UI)
- Lingue: it(base) + en/es/fr/de/pl/uk/ro/nl/ru.
- Meccanismo: IStringLocalizer<Puntify.App.AppResource>, Resources/AppResource[.lang].resx, @L["key"].
  csproj: BlazorWebAssemblyLoadAllGlobalizationData=true.

## Stato
- Area CLIENTE: FATTA (258 chiavi x 9 lingue). Commit 1081495.
- Area ESERCENTE: estrazione FATTA (64 file, 2141 nuove chiavi IT in AppResource.resx). Commit b231bad. Build verde.
  - Traduzioni 9 lingue delle 2141 chiavi: DA COMPLETARE (interrotte da limite sessione).

## RIPRESA traduzioni esercente (quando torna capacità)
1. Chunk chiavi nuove: /tmp/.../scratchpad/puntify-settori/chunks/chunk1..4.json (536/536/536/533).
   Sorgente completa: puntify-settori/merch_new_keys.json (2141).
2. Parziali gia' scritti: puntify-settori/merch_tr/{en,es,fr,de}_c1.json (536 ognuno). Mancano gli altri 32 file (c2-c4 di en/es/fr/de + tutti pl/uk/ro/nl/ru c1-c4).
3. Rilanciare agenti-lingua per i chunk mancanti -> merch_tr/{lang}_c{N}.json.
4. Merge per lingua + append a Resources/AppResource.{lang}.resx (usare gen script analogo a gen_resx.py; ATTENZIONE: le lang resx contengono gia' le 258 chiavi cliente -> APPEND, non sovrascrivere).
5. Build + commit. Poi COMPONENTI/Shared come blocco 3.

## Altri fix oggi (fatti, commit)
- manifest.json path relativi (icone PWA 404) d9bf2de
- BlazorWebAssemblyLoadAllGlobalizationData 2c339fd
