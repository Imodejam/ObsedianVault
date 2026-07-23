# Puntify — Analisi GA4 (2026-07-23)

Property GA4 524577455 (Vetrina+App). Finestra: ultimi 28gg. Fonte: Data API via SA search-console-reader-claude.

## Numeri chiave
- 314 sessioni, 52 utenti attivi, 47 nuovi (~90% nuovi, poca retention)
- Engagement 70%, bounce 30%. Trend in crescita (sett 26->29: 24->64->64->92)
- Durata media reportata ~43min = FALSATA da pagine kiosk /coda/totem + /coda/display (aperte per ore) -> escludere da GA4

## Acquisizione (canali)
- Organic Search 192 (61%), engagement 77% = canale migliore e dominante
- Direct 89 (28%)
- Organic Social 12, 32s medi = bassa qualita
- Paid Search 1 = Ads praticamente assenti

## Contenuti
- Top landing: /it (100), /negozi/ItalianFriends/menu (47, eng 83%), /negozi/roma/pepto/menu (13), /en (11)
- Top pagine viste: ItalianFriends/menu 530, /it 294, coda/totem 138, ItalianFriends/book 111, pepto/menu 106, /it/prezzi 54, /negozi 50
- I menu dei negozi attivi sono magneti di traffico: ogni negozio = asset SEO

## Geo/device
- 95% Italia; Roma 240, Milano 31, Guidonia 13 (Roma-centrico coi negozi attivi)
- Desktop 192 > Mobile 126 (40% mobile)

## Gap critico
- keyEvents=0, nessun evento e-commerce: GA4 NON traccia conversioni -> impossibile attribuire vendite ai canali. Vendite reali = Postgres (transactions/bookings/orders, gia in /api/kpi).

## Raccomandazioni (proposte a Stefano)
- A) SEO/contenuti: landing per settore + blog sui pain verticali (leva #1, l'organico dimostra domanda)
- B) Convertire pagine menu in acquisizione esercenti (CTA "powered by Puntify")
- C) Social: collegare post a landing forte (oggi 32s)
- D) Local SEO Roma
- E) [PRIORITA] Abilitare conversion tracking GA4 (key events prenotazione/iscrizione + evento dall'app) per chiudere loop traffico->vendite e ottimizzare Ads su CPA
