# Piratopoly

## Obiettivo
PWA AI-powered urban treasure hunt: i giocatori pianificano da remoto itinerari personalizzati, poi li eseguono fisicamente esplorando la città.

## Concept
- **Due fasi**: Pianificazione (remoto) → Esecuzione (sul posto con GPS)
- **AI-first**: genera percorsi ottimizzati, quiz contestuali, immagini copertina
- **UGC**: i giocatori creano mappe → marketplace community
- **Esplorazione con purpose**: tappe reali (monumenti, festival, trattorie)

## Regola architetturale: tutto pre-creato (Stefano, msg 1129, 2026-05-05)
Le mappe, le tappe, i contenuti narrativi e i quiz **non** vengono generati a runtime dal backend. Tutto deve essere creato e validato **prima** che la mappa venga pubblicata. Il flusso:
1. Stefano chiede "crea mappa X" → Claude Code (CLI, fuori runtime) genera mappa+tappe+narrative+quiz.
2. I quiz passano per Concilium (validazione multi-LLM) → solo gli `approved` finiscono in `quiz_pool`.
3. Stefano riceve l'OK → la mappa viene pubblicata.
4. Backend runtime serve solo dati già in DB. Nessuna chiamata `client.messages.create` su path utente.

L'`ANTHROPIC_API_KEY` è riservata a Concilium. Trigger storico del bug: `/resume-quiz` chiamava `ensureStagePool` → `generateChallengePool` → API HTTP → 400 "API usage limits". Fix 2026-05-05: `ensureStagePool` e `ensureStageContent` ora sono read-only.

## Target
- Turisti internazionali (25-45 anni, visita 2-5 giorni)
- Residenti locali (25-50 anni, riscoprire la propria città)
- Famiglie con bambini (6-14 anni, attività educative)
- Creatori di mappe (power users)

## Mood (selettore esperienza)
- 🛍️ Acquisti & Souvenir
- 🍕 Enogastronomia
- 🏛️ Arte & Storia
- 🌳 Natura & Outdoor
- 💃 Vita Notturna & Eventi
- 👨👩👧👦 Attività per Famiglie

## Struttura gioco
**Tappa**: luogo fisico con mood, descrizione, quiz, coordinate GPS. Fissa (permanente) o temporanea (evento).

**Mappa**: aggregato di tappe su 1-N giorni, con mood per giornata, copertina AI generata.

**Marketplace**: mappe editoriali (ufficiali) + community, tutte gratuite, esecuzione a pagamento.

## Sistema punteggi (Piastre)
- Localizzazione corretta: 100
- Quiz corretto: 50 (sblocca voucher)
- Pianificatore: 100% esecuzione propria + 50% esecuzione terzi
- Esecutore mappa altrui: 50% punti
- Moltiplicatore recensioni: ±20% per valutazione >3/≤3 stelle

## Voucher
- Sconti reali presso esercenti locali, sbloccabili con quiz corretti
- Partnership commerciali per inserire voucher
- Value prop: mappa 7,99€ + voucher 15-20€ = ROI positivo

## Pricing

> ⚠️ **2026-05-08 — superato dal GDD V1.** Vedi [[piratopoly-pricing-v1-execution|Pricing V1 — Piano di Esecuzione]] e [[../../raw/docs/piratopoly/pricing-v1-2026-05-08.md|documento sorgente]].

### V1 (target MVP, in attesa implementazione)
| SKU | Tappe | Validità | Prezzo |
|---|---|---|---|
| Demo Città | 1–2 | Illimitata | Gratis |
| Mini Mappa | 3–4 | 24h | 5,99 € |
| Mappa Classica | 5–7 | 48h | 11,99 € |
| Mappa Estesa | 8–10 | 72h | 14,99 € (8,99 € con Pass) |
| Pack Esploratore | 3 mappe | 12 mesi | 24,99 € |
| Pirate Pass mensile | Catalogo + EL illimitata | 30gg | 11,99 €/mese |
| Pirate Pass annuale | Catalogo + EL illimitata | 12 mesi | 79 €/anno |

### V0 (pricing legacy attualmente nel codice)
| Piano | Prezzo |
|-------|--------|
| Trial Gratuito | 0€ (1 mappa ridotta, 1 giorno, 3 tappe, no voucher) |
| Mappa Singola | 7,99€ |
| Explorer Pack (3 mappe) | 18,99€ |
| Season Pass (3 mesi) | 14,99€ (5€/mese) |
| Annual Pass | 39,99€ (3,33€/mese) |

## Stack tecnico (overview)
- Frontend: PWA (responsive, installabile, offline parziale)
- Backend: API REST / GraphQL
- Database: PostgreSQL + PostGIS (geolocalizzazione)
- AI LLM: Claude API (quiz, percorsi, traduzioni)
- AI Immagini: Nano Banana 2 / Google
- Eventi: Eventbrite API + Google Events + scraping
- Geolocalizzazione: Geolocation API + Google Maps/Mapbox
- Pagamenti: Stripe
- Autenticazione: OAuth 2.0

## Multilingua
Lingue al lancio: italiano, inglese, spagnolo, tedesco, francese
- Interfaccia utente tradotta
- Quiz generati nativamente in lingua
- Desrizioni tappe tradotte AI
- Voucher bilingue

## Roadmap indicativa
- **Alpha (M1-M3)**: PWA base, 1 città pilota (Roma), pianificazione AI, marketplace MVP
- **Beta chiusa (M4-M5)**: GPS, punteggi, leaderboard, voucher MVP (10-20 partner)
- **Beta pubblica (M6-M7)**: 3 città, eventi, recensioni, multilingua IT+EN
- **Lancio v1.0 (M8-M9)**: 5+ città, 5 lingue, pricing completo
- **Crescita (M10+)**: espansione UE, badge avanzati, mappe premium

## Stato attuale
[2026-04-21] — GDD v2.0 completato. In fase di sviluppo.
[2026-04-27] — Setup ambiente delegato a Carlo: dipendenze installate (shared, backend, frontend), Nginx config su `piratopoly-dev.duckdns.org`.
[2026-04-29] — Frontend: implementato layout "telefono al centro" (mobile-first usabile su desktop/tablet).
[2026-05-01] — Definito sistema gradi giocatore (10 rank, 5 tier, soglie Piastre lifetime, decay -1 grado/6 mesi dopo 12 mesi inattività). Annual Pass = mappe illimitate. Piastre solo da gioco (no streak/eventi al lancio). Definito sistema gradi creator separato (Cartografo, 3 livelli, valuta "Carte"). Vantaggi per grado da definire.
[2026-05-01] — Pagina bussola: aggiunto loader full-screen che resta finché GPS non acquisito, con retry continui (vedi sezione Decisioni di sviluppo).

## Deployment dev
- **URL pubblico:** http://piratopoly-dev.duckdns.org/
- **Repo:** `/home/progetti/piratopoly/` (npm workspaces: `shared`, `backend`, `frontend`).
- **Servizio systemd:** `piratopoly.service` (User=`claudebot`, WorkingDirectory=`/home/progetti/piratopoly`).
- **Comando:** `npm run dev` → `concurrently "npm run dev --workspace=backend" "npm run dev --workspace=frontend"`.
- **Porte:** `127.0.0.1:6002` (frontend Vite, dietro Nginx) / `*:6001` (backend Express, `npx tsx watch`).
- **Nginx:** `/etc/nginx/sites-available/piratopoly-dev.duckdns.org` → proxy a `:6002`.
- **Node:** nvm `v20.20.2` (`/home/claudebot/.nvm/versions/node/v20.20.2/bin/`).
- **Restart:** `Restart=always`, `RestartSec=10`. Enabled al boot.
- **Log:** `journalctl -u piratopoly -f` (identifier: `piratopoly`).
- **Comandi:** `sudo systemctl status|restart piratopoly`.
- **Note:** è un dev server (vite + tsx watch), non build di produzione.

## Flusso di gioco di riferimento (msg Stefano 897, 2026-05-04)

```
Acquisto mappa
  → [Briefing itinerario?  ← da decidere]
  → Mappa del percorso
  → [Briefing tappa?       ← da decidere]
  → Bussola → camminata reale
  → Arrivo fisico (GPS verifica)
  → Pagina Tappa (Diario del Capitano con audio + curiosità)
  → Quiz / Prova
  → Ricompensa Piastre
  → Tappa successiva (loop)
```

**How to apply:** ogni nuova feature relativa al gameplay deve incastrarsi in questa pipeline. I due "briefing" (itinerario + tappa) sono punti di domanda: Stefano non ha ancora deciso se aggiungerli, quindi *non implementare nulla in quei due slot finché non c'è una decisione esplicita*. Il resto del flusso è già tutto in piedi (Marketplace acquisto → MapDetailPage → GameMapPage → GameCompassPage → checkin → GameStopPage [diario+curiosità+prova+ricompensa] → loop).

## Decisioni di sviluppo
### [2026-05-04] Tappe → catalogo prove multi-tipo + 3 tentativi + speed score (idea, non ancora implementata)

Stefano (msg Telegram 811) ha proposto un'evoluzione importante del gameplay alla tappa:

**Tipi di prova supportati (catalogo)**
- Quiz a risposta multipla (l'attuale)
- Quiz logico
- Quiz culturale
- Rompicapo
- Indovinello
- Anagramma
- **AR** — usare la fotocamera del telefono per cercare un oggetto specifico in piazza, o "trovare" una nave dei pirati AR sovrapposta alla scena reale

**Modello dati proposto (da confermare con Stefano)**
- Ogni `Stage` (tappa) ha un pool di N prove censite (N ≥ 3 per coprire i 3 tentativi).
- Le prove sono entità separate (`Challenge`?) con `kind` + payload type-specifico (per i multipla: opzioni; per l'AR: marker / coordinate / immagine target; ecc.).
- Pesca a runtime: 1ª prova random dal pool, e se sbagliata altre 2 random non già viste.

**Flusso tentativi**
- Tentativo 1: utente prova → se corretto, punteggio normale + bonus velocità.
- Tentativo 2: nuova prova random dal pool → se corretto, punti ridotti.
- Tentativo 3: ultima prova → se corretto, punti ridotti ulteriormente; se sbagliato, **penalità** in punti.
- Più veloce è la risposta, maggiori i punti (formula da decidere — es. lineare entro un timer o curva esponenziale decrescente).

**Aperto, da chiarire con Stefano**
1. Pool minimo per tappa: 3 prove (uguale ai tentativi) o di più per dare varietà fra giocatori?
2. Penalità tentativo 3 sbagliato: perdita assoluta (es. -50 piastre), niente piastre, o impossibilità di proseguire?
3. Scala punti speed-bonus: cap massimo per la 1ª risposta corretta? Curva su quale finestra (10s, 30s, 60s)?
4. Tutte le prove pesano uguali nel punteggio o alcuni tipi (AR, rompicapo) valgono di più?
5. AR: stack tecnico — WebXR Device API (browser-based, dispositivi compatibili), MindAR (marker-based via JS), oppure soluzione plain camera + AI vision (es. una foto inviata al backend che chiede a un LLM "questa foto contiene un X?"). Quest'ultima è la più semplice ma richiede chiave LLM e ha latenza.
6. Editor lato creator: dovrà permettere di aggiungere N prove di tipo diverso a ciascuna tappa. Stessa UI per tutti i tipi o tab separati per tipo?
7. Generazione AI: il sistema attuale già genera quiz multipla via LLM. Vogliamo estenderlo a generare anche indovinelli, anagrammi, ecc., o lasciarli al creator?

**Decisioni di Stefano (msg 813, 2026-05-04)**
1. Pool per tappa: **min 6, target 10** (dipende dalle info disponibili sul luogo).
2. Penalità al 3° fallimento: **-10% del punteggio normale della tappa**, fisso e proporzionale (es. tappa da 150 → -15 piastre).
3. Speed bonus: confermato **10s = max bonus, 60s = zero**. Curva lineare entro la finestra.
4. Pesi per tipo: tutti uguali, niente bonus per AR/rompicapo.
5. AR: stack **MindAR / AR.js** (image-target via JS, funziona su quasi tutti i mobile).
6. Editor creator: **form dinamico** che cambia in base al `kind` selezionato.
7. Generazione: **tutto via LLM** — anche indovinelli, anagrammi, rompicapo, oltre ai multipla esistenti.

**Vincoli di pescaggio dal pool (msg 815, 2026-05-04)**
- `logic` — **riservato al 3° tentativo**. Mai pescato in tentativo 1 o 2.
- `culture` — il quiz culturale **deve essere contestuale alla tappa o alla mappa** (es. su Bund a Shanghai, deve riguardare il Bund / la storia di Shanghai, non cultura generica).
- `anagram` — anch'esso **legato a parole/frasi della tappa o della mappa** (es. anagramma del nome di un monumento, di un personaggio storico locale).
- Multilingua: gli anagrammi dipendono dalla lingua di gioco. L'LLM li genera per ogni lingua supportata della mappa (come già avviene per i quiz multipla).

**Algoritmo di pesca**
- Pool tappa = 6-10 challenges, di cui ≥ 1-2 di tipo `logic` e il resto distribuito fra `multiple-choice / culture / riddle / anagram`.
- Tentativo 1 e 2: random da `{multiple-choice, culture, riddle, anagram}` (no `logic`), garantendo "non già viste".
- Tentativo 3: random da `{logic}` (no overlap coi tipi visti prima).

**Contestualità (msg 817, 2026-05-04)**
Le challenge contestuali alla tappa/mappa sono: `culture`, `riddle`, `anagram` (+ `ar-find` in Fase 2). Solo `multiple-choice` e `logic` possono essere generiche. L'LLM genera tutto contestualizzato.

**UX (msg 817, 2026-05-04)**
Stefano vuole che rispondere sia facile, niente testo libero. Tutti i tipi testuali rendono come **scelta multipla a 4 opzioni**:
- `multiple-choice` — domanda + 4 risposte (come oggi).
- `culture` — fatto/affermazione sulla tappa + 4 risposte.
- `logic` — enigma + 4 risposte numeriche/testuali.
- `riddle` — indovinello + 4 possibili soluzioni.
- `anagram` — lettere mescolate visualizzate + 4 parole tra cui scegliere la corretta.

Vantaggi: tap-to-answer, niente parsing testo libero, validazione deterministica, aspetto coerente fra i tipi, performance veloce su mobile.

### Regole qualità contenuto quiz (Stefano, msg 1153, 2026-05-06)

Queste 4 regole valgono per **tutti i quiz** (esistenti e nuovi). Sono nel system/user prompt del generator (`generateChallengePool` in `claude.service.ts`) e devono essere aggiornate insieme alla pagina wiki ogni volta che cambiano.

1. **Non-banalità.** Una domanda è banale quando la risposta è il soggetto stesso della tappa, deriva dal NOME della tappa, o è banalmente deducibile dal contesto della pagina. Se la tappa si chiama "X di Y", la risposta corretta NON può essere "X", "Y", una loro parafrasi/sinonimo/contenitore, né un dettaglio leggibile direttamente nel nome. Anche la domanda non deve rendere ovvia l'opzione corretta. *Esempi banali rifiutati:* (a) tappa "Castello Svevo di Cosenza" → "Che tipo di edificio è?" → "castello"; (b) tappa "Teatro Rendano di Cosenza" → "A quale figura musicale è intitolato?" → "Alfonso Rendano" (msg 1206, 2026-05-07: il cognome è già nel nome della tappa). *Esempio corretto:* dettaglio verificabile (data, iscrizione, materiale, episodio, dimensione, evento storico) tratto dalle fonti, NON ricavabile da una rilettura del nome.
2. **Distribuzione `correctIndex`.** Su un pool di 8 quiz, `correctIndex` distribuito ~uniformemente fra 0/1/2/3 (target 2 per ciascuno, tolleranza ±1). Mai più di 3 occorrenze sullo stesso indice. Niente default a 0.
3. **Sourcing & incontestabilità.** Per `multiple-choice`, `culture`, `riddle`, `anagram` ogni risposta corretta deve essere un fatto verificabile via Wikipedia (estratto fornito al prompt) o materiale di riferimento ampiamente accettato. Niente leggende presentate come fatto, niente attribuzioni contestate. La `explanation` deve citare il fatto specifico. `logic` è esente (puzzle puro di ragionamento).
4. **Livello sfidante.** Almeno 3 quiz su 8 devono essere "challenging": dettaglio specifico non ovvio (data, nome, numero, dimensione, iscrizione) o piccola inferenza, tale che un visitatore casuale che ha solo dato un'occhiata NON indovinerebbe. La `explanation` chiarisce *perché* non è banalmente deducibile. Gli altri possono essere medi. Evitare trivia da manuale ("in che anno morì X") salvo date iconiche e centrali nelle fonti.

**Where it's enforced:**
- `backend/src/services/claude.service.ts` → `generateChallengePool` riceve `sources?: string | null` (estratto Wikipedia) e include le 4 regole nel prompt.
- `backend/scripts/regenerate-banal-riddles.ts` (e qualunque altro caller offline) deve passare `wiki?.extract ?? null` da `fetchStageWikipedia`.
- Validazione finale via Concilium (multi-LLM) prima dell'`approved` in `quiz_pool`.

### Regole "descrizione" e "curiosità" della tappa (Stefano, msg 1171, 2026-05-06)

La pagina Tappa (GameStopPage) mostra due campi distinti, generati da `generateStageContent` in `claude.service.ts` e salvati in `stage_content_i18n`.

**`narrative` (la "descrizione"):**
- Deve **incuriosire**: aggancio iniziale che apra una domanda o presenti un'immagine forte; mantenere viva la curiosità in tutto il testo.
- Deve essere **chiara**: frasi pulite, niente giri di parole, una sola lettura basta a capire cos'è il luogo.
- Deve riportare **tutte le notizie importanti** (chi/cosa/quando + significato storico/culturale/architettonico). Il giocatore non deve dover andare su Wikipedia.
- 100-180 parole, mai oltre 220, testo unico narrativo (no bullet/titoli).
- Niente aneddoti curiosi/sorprendenti/secondari qui — quelli vivono in `curiosities`.

**`curiosities`:**
- Esattamente 3 frasi, ognuna < 110 caratteri.
- Sono **informazioni curiose da sapere** — fatti laterali, sorprendenti, gustosi: "lo sapevi che…", record, primati, dettagli invisibili a colpo d'occhio, aneddoti, leggende minori.
- **Mai sovrapposte alla narrative**: se un fatto è già nel narrative, scartarlo e scegliere un altro angolo.
- Memorabili, sorprendenti, verificabili.

**Architettura: tutto pre-creato, niente runtime LLM** (msg 1129):
- `ensureStageContent` è read-only. Se manca → throw 500 esplicito ("stage_content missing for stage=…").
- I content vanno generati offline via Claude Code CLI o inseriti inline (no API HTTP — riservata a Concilium).
- Prima di pubblicare una mappa, ogni tappa DEVE avere un record `stage_content_i18n` con `narrative.length > 0` per ogni lingua supportata. Audit script: `backend/scripts/audit-stage-content.ts`.

**Status**: decisioni prese. Implementazione in 2 fasi (vedi sotto).

### [2026-05-07] Stage-complete deep-link riapribile (msg 1208)
Stefano (msg 1208): la pagina `/game/:sessionId/stage-complete` mostrava il riepilogo della tappa solo subito dopo aver risposto al quiz, perché leggeva da uno store volatile (`lastStageOutcome`). Adesso deve poter essere aperta più volte.
- Route: aggiunta `/game/:sessionId/stage-complete/:stageId` (path nuovo). Vecchio path senza stageId mantenuto per fallback ma reindirizza alla mappa se store vuoto.
- `LastStageOutcome` ora porta `stageId` per disambiguare.
- `StageCompletePage` se store match → render con count-up come prima; altrimenti `GET /sessions/:id/stages/:stageId/result` ricostruisce il payload (senza animazione) e mostra la stessa UI.
- Backend `/sessions/:id/stages/:stageId/result` ora ritorna anche `stageName` (join `stages(name)`).
- `PlayedMapDetailPage`: ogni tappa nella lista è cliccabile e apre il deep-link.

### [2026-05-07] Counter "Mappe" nel profilo = sessioni completate (msg 1198)
Stefano (msg 1196 → 1198): nel profilo vedeva 2 mentre in `MyMapsPage` chip "completate" diceva 6 → discrepanza. La regola di ieri (msg 1190/1192, 2026-05-06) imponeva DISTINCT map.id per evitare di gonfiare con i replay; oggi Stefano ribalta: vuole **sessioni di gioco** (replay incluso, allineato col chip di MyMapsPage).
- `ProfilePage.tsx` (`reloadCompletedCount`): `items.filter(m => m.playStatus === 'completed').length`, niente più `Set`.
- Tooltip "Mappe terminate" resta (generico, OK per entrambe le semantiche).
- Backend `/game/sessions/my-maps` immutato: ritorna ogni sessione (decisione msg 1053, no dedup per mappa).

### Piano di rilascio (proposto a Stefano, in attesa OK)
**Fase 1 — Modello dati + tipi testuali + scoring**
- Migration `challenges` (1:N con stages); backfill dei quiz esistenti come challenge `multiple-choice`.
- Tipi testuali: multiple-choice, logic, culture, riddle, anagram (5 tipi).
- LLM generator esteso: produce 6-10 challenges di tipi misti per ogni stage; backfill richiamabile sulle mappe esistenti.
- Backend: flusso tentativi (max 3, pesca random non-vista), speed bonus lineare 10s→60s, penalità -10%.
- Frontend GameStagePage: timer visibile, transizione fra tentativi, mostra punti rimanenti dopo ogni fallimento.
- Editor creator: form dinamico per challenge in CreatorMapStagePage.

**Fase 2 — AR**
- Integrazione MindAR (image-target via JS).
- Editor creator: upload immagine target + descrizione "trova questa nave/oggetto".
- LLM suggerisce cosa cercare in base al luogo (testo "cerca la statua del leone" → poi creator carica la foto).
- Challenge type `ar-find` con timer condiviso.

### [2026-04-29] Frontend layout "telefono al centro"
App mobile-first ma usabile anche su desktop/tablet centrata.
- Wrapper globale in `App.tsx`: `<div class="mx-auto w-full max-w-md min-h-screen bg-bg shadow-2xl ...">` racchiude le Routes.
- Body in `index.html` cambiato da `bg-bg` a `bg-black` per il "letterbox" ai lati su desktop.
- `BottomNav`, `GameBottomNav`, MapDetailPage CTA footer fixed: pattern `fixed left-1/2 -translate-x-1/2 w-full max-w-md` (NON `left-0 right-0`).
- Larghezza scelta: `max-w-md` (28rem = 448px). Coincide con il token `--content-max-w` in `frontend/src/styles/tokens.css` (esistono anche `--content-tablet-w: 42rem` e `--content-desktop-w: 64rem` per eventuale layout responsive multi-breakpoint).
- **Quando aggiungere un nuovo elemento `fixed`:** evita `left-0 right-0`. Usa `left-1/2 -translate-x-1/2 w-full max-w-md`. Eccezione: modali/loading screen veramente fullscreen (`LoadingScreen.tsx`, alcuni overlay) → `fixed inset-0` ok.

### [2026-05-02] Piastre come moneta interna (1 mappa free = 8.000)
Decisione di design (Stefano 2026-05-02): le Piastre accumulate giocando possono essere usate per acquistare nuove mappe.

**Schema dati:** introduzione di un counter spendibile separato sul profilo utente.
- `users.total_score` (esistente) — lifetime, **mai decrementato**, determina il rank.
- `users.available_piastre` (nuovo) — Piastre attualmente spendibili.
- `users.spent_piastre` (nuovo) — totale speso lifetime.
- Invariante: `total_score = available_piastre + spent_piastre`.
- Quando una sessione completa accredita N Piastre (awarded): `total_score += N` AND `available_piastre += N`. Quando l'utente spende M: `available_piastre -= M`, `spent_piastre += M`. Il rank non cambia mai per effetto della spesa.

**Tasso di conversione:**
- **1 mappa singola = 8.000 Piastre.** Equivale a circa 5-6 nuove mappe standard giocate alla 1ª run (≈6 settimane per il giocatore mediano da 5 mappe/mese). Match implicito con la soglia di Predone (rank 5 = 8.000 Piastre lifetime): il giorno che ottieni Predone hai tipicamente abbastanza available per la prima mappa free.
- **Pack3 = 21.000 Piastre** (giusto sotto al 3× per dare valore al pacchetto).
- Il replay multiplier (1×/0,5×/0×) impedisce il farming sulle stesse mappe.

**UX prevista (TODO, con il flusso pagamenti):**
- Marketplace: card mappa con due bottoni — "Acquista 7,99€" e "🪙 8.000 Piastre" (greyed-out se `available_piastre` insufficienti).
- Profilo: badge "🪙 X Piastre disponibili" cliccabile → modale storia transazioni (acquisti + accrediti da partite).
- Migration TODO: ALTER TABLE users ADD COLUMN available_piastre INTEGER NOT NULL DEFAULT 0; spent_piastre IDEM; backfill `available_piastre = total_score`, `spent_piastre = 0`.

### [2026-05-02] Creator gioca la propria mappa in "modalità test"
Decisione di design (Stefano 2026-05-02): un creator può giocare gratuitamente le mappe di cui è creator, ma la sessione è marcata come **test** e non genera ricompense.

Regole della modalità test:
- ✅ Gratis (no entitlement richiesto): serve a validare la mappa fisicamente.
- ❌ Niente Piastre per il rank (multiplier 0× sempre, indipendente dal numero di run).
- ❌ Niente Carte per il track creator (sarebbe auto-fertilizzazione).
- ❌ Non incrementa `users.maps_completed`.
- ❌ Non incrementa `maps.plays_count`.
- ❌ Non sblocca voucher.
- ❌ Non entra nelle leaderboard di mappa.
- ✅ Sessione visibile in "Mappe giocate" del creator, etichettata "Test run".
- ✅ Tutto il flow restante funziona (check-in GPS, quiz, recap) per consentire un vero test sul campo.

**Implementazione (TODO, quando si introduce il flusso pagamenti):**
- Aggiungere colonna `mode TEXT NOT NULL DEFAULT 'play' CHECK (mode IN ('play','test'))` a `piratopoly.game_sessions`.
- `POST /game/sessions`: se `req.userId === map.creator_id`, marcare la sessione come `mode='test'`.
- `POST /sessions/:id/complete`: se `mode='test'`, saltare `update_user_score` e `maps.plays_count++`. Salvare comunque le `game_stage_results` per il recap.
- Frontend: badge "🧪 Modalità test" su `GameMapPage`, `GameCompassPage`, `GameCompletePage`, `PlayedMapDetailPage` quando `session.mode === 'test'`.

### [2026-05-02] Pack3 = picker al checkout
Decisione di design (Stefano 2026-05-02): il "Pack 3 mappe" del GDD funziona così — il cliente sceglie **lui** dal marketplace 3 mappe a sua scelta e paga 18,99€ una volta sola; riceve l'entitlement sulle 3 mappe specifiche (rigiocabili infinite con il replay multiplier 1×/0,5×/0× standard). Costo unitario 6,33€/mappa (sconto ~21% sul singolo). Da implementare quando il flusso di pagamento sarà attivato — TODO non urgente.

### [2026-05-02] Replay multiplier sulle Piastre
Decisione di game design Stefano 2026-05-02: una mappa acquistata si può rigiocare infinite volte, ma le Piastre accreditate al `users.total_score` decrescono per replay:
- 1ª completion: 100% del punteggio sessione
- 2ª completion: 50%
- 3ª e successive: 0% (rigiocabile ma senza Piastre)

**Implementazione:**
- Migration `008_session_score_multiplier.sql`: aggiunge `score_multiplier NUMERIC(3,2) NOT NULL DEFAULT 1` e `awarded_score INTEGER NOT NULL DEFAULT 0` a `game_sessions`. Backfill: sessioni completed esistenti = first run, multiplier 1, awarded = total_score.
- `POST /game/sessions/:id/complete`: ora **idempotente** (se la sessione è già `completed`, ritorna i dati senza ricreditare le Piastre — fix di un bug latente per cui la GameCompletePage che ri-monta accreditava più volte). Calcola `prev = count(completed sessions per (player, map) escluso questa)`, applica `multiplier = prev===0 ? 1 : prev===1 ? 0.5 : 0`, salva `score_multiplier` + `awarded_score` sulla riga, chiama `update_user_score` con l'awarded.
- `GET /game/sessions/:id/recap`: espone `awardedScore` e `scoreMultiplier` accanto a `totalScore` (raw).
- Backfill aggiuntivo dei totali `users.total_score` e `maps_completed` con `SUM(awarded_score)` / `COUNT(*)` su sessioni completed (prima erano disallineati per via del bug double-credit pre-idempotenza).
- **Frontend:**
  - `GameCompletePage`: il numero grande mostra `awardedScore`. Se `scoreMultiplier < 1`, riga sotto "Run #X · Piastre al N% (raw: Y)" o "niente Piastre dalla 3ª partita in poi".
  - `PlayedMapDetailPage`: stat card mostra `awardedScore`, riga sotto col raw se multiplier < 1.

### [2026-05-02] Recensioni mappe (eligibility = aver completato)
Implementato sistema review per le mappe.
- **Tabella `piratopoly.reviews`** già esistente (id, map_id, reviewer_id, stars 1-5, body, created_at, UNIQUE(map_id, reviewer_id)).
- **Backend (in `maps.routes.ts`):** `GET /maps/:mapId/review/me` ritorna `{ canReview, review }` (canReview = ha ≥1 sessione completed su quella mappa). `PUT /maps/:mapId/review` upserta su (map_id, reviewer_id), bocca con 403 se l'utente non ha mai completato. Dopo upsert ricalcola `maps.avg_rating` (NUMERIC(3,2)) e `maps.reviews_count`.
- **Frontend componente riusabile `<MapReviewBlock mapId hideWhenIneligible? />`** in `components/maps/MapReviewBlock.tsx`: gestisce loading, eligibility, fetch della review esistente, form (stelle clickable + textarea body 0-1000 char), bottone Pubblica/Aggiorna, modalità readonly con CTA Modifica.
- **Inserito in 3 punti:**
  - `GameCompletePage`: blocco review subito sotto Riepilogo, prima dei CTA. Il backend `/sessions/:id/complete` ora ritorna `mapId` per consentirlo.
  - `PlayedMapDetailPage`: blocco review dopo la lista tappe.
  - `MapDetailPage` (marketplace): blocco con `hideWhenIneligible` → invisibile a chi non ha mai completato; chi ha giocato vede la propria review esistente o il form per pubblicarla, e può modificarla in qualsiasi momento.
- Chi non ha giocato e arriva via marketplace non vede né il form né messaggi spiazzanti.

### [2026-05-02] globalRank vivo lato client
La colonna `users.global_rank` non viene mai aggiornata (manca un trigger / job). UI mostrava `—` nel profilo. Soluzione: in `auth.store` il fetch del profile chiama `fetchLiveGlobalRank(totalScore)` che fa un `count('users where total_score > self') + 1` via Supabase JS. Cheap query, sempre allineato. Il valore di DB resta NULL ma viene ignorato dal frontend, che usa il calcolo live. _Da rivedere quando ci saranno migliaia di utenti: a quel punto persistere su DB con trigger / view materializzata._

### [2026-05-02] Mappe giocate dentro "Le mie mappe"
Refactor di una sezione introdotta poco prima (vedi entry sotto "Pagina Mappe giocate"). Stefano ha chiesto di **non** avere una pagina dedicata: le mappe giocate devono apparire dentro `MyMapsPage` filtrabili come prima, e cliccando una mappa completata si arriva al recap della sessione.
- Backend: rimosso `/sessions/played` (lista non più usata). Aggiunto `lastSessionId` alla risposta di `/sessions/my-maps`.
- Frontend: `OwnedMap.lastSessionId` esposto. `MyMapsPage` cambia il CTA per le mappe `completed` da "Rigioca" a "Vedi dettagli" → naviga a `/profile/played/:sessionId`. Rimossa voce menu profilo "Mappe giocate" e file `PlayedMapsPage.tsx`. La detail page `PlayedMapDetailPage.tsx` resta sotto `/profile/played/:sessionId`.

### [2026-05-02] Pagina "Mappe giocate" + recap sessione
Implementata sezione profilo per rivedere le mappe già completate.
- **Backend:** due nuovi endpoint in `game.routes.ts`:
  - `GET /game/sessions/played` → lista delle sessioni `completed` del player (una entry per sessione, non per mappa, così repliche sono distinguibili).
  - `GET /game/sessions/:id/recap` → recap dettagliato joinato (session + map + game_stage_results + stages) per la pagina detail. Niente round-trip extra dal client.
- **Frontend:**
  - `services/playedMaps.ts` (`fetchPlayedMaps`, `fetchPlayedRecap`) + tipi.
  - `PlayedMapsPage.tsx` (route `/profile/played`): lista card con cover, titolo, data, tappe, Piastre guadagnate. Empty state con CTA "Inizia una nuova avventura".
  - `PlayedMapDetailPage.tsx` (route `/profile/played/:sessionId`): hero con cover + titolo + data, stats card (Piastre / Tappe / Durata), lista ordinata delle tappe completate con badge `📍 corretta/mancata`, `✓/✗ quiz`, `⚡ speed bonus`, score per tappa. CTA in fondo per riaprire la mappa nel marketplace.
  - Voce nel menu Profilo: `🏴‍☠️ Mappe giocate → /profile/played`.

### [2026-05-02] Bug critico: total_score utente sempre 0 — fixato
**Sintomo:** Stefano dopo aver finito una mappa (715 punti su `game_sessions`, status `completed`) vedeva ancora `total_score = 0` nel profilo. **Causa:** `game.routes.ts` chiamava `supabase.rpc('update_user_score', …)` ma la funzione **non esisteva** nel database (mai migrata) — `.maybeSingle()` swallow-ava l'errore. **Fix:**
- Creata migration `supabase/migrations/006_update_user_score_function.sql`: definisce `piratopoly.update_user_score(p_user_id uuid, p_score integer)` che incrementa cumulativamente `total_score` e `maps_completed`. Eseguita sul DB come `supabase_admin` (lo schema `piratopoly` è di sua proprietà, `postgres` non ha grant).
- Backfillato `users.total_score` e `maps_completed` ricomputando dalle sessioni `completed` esistenti (Stefano: 0 → 715, 0 → 1).
- `game.routes.ts` ora estrae `error` dall'RPC e logga con `console.error` se fallisce (no più silent failure).
- `auth.store.ts` aggiunto metodo `refreshUser()` (rifatch profile da Supabase).
- `GameCompletePage.tsx` chiama `refreshUser()` dopo `/sessions/:id/complete` così il `totalScore` UI si aggiorna senza bisogno di logout/login.

### [2026-05-02] Implementato sistema gradi (giocatore)
Realizzato il sistema di rank giocatore definito 2026-05-01.
- **Costanti shared:** `shared/src/types/rank.ts` esporta `PLAYER_RANKS`, `CREATOR_RANKS`, `getPlayerRank(piastre)`, `getNextPlayerRank(piastre)`, `getCreatorRank(carte)`, `getNextCreatorRank(carte)`. Le soglie giocatore (0/500/2k/5k/8k/18k/35k/65k/110k/200k) e i tier sono allineati alle decisioni del 1 maggio.
- **Pagina dettaglio rank:** `frontend/src/pages/profile/RankPage.tsx`, route `/profile/rank`. Hero con icona del grado attuale + numero (X/10) + Piastre lifetime; barra progresso "X% — N Piastre mancanti per [next]"; lista completa dei 10 gradi con stato (raggiunto / corrente "Tu" / locked greyscale); footer con regola decay. Gradi senza icona dedicata fallback su 🏴‍☠️. Endgame mostra schermata "vetta raggiunta" senza progress bar.
- **Punti d'ingresso cliccabili:**
  - `ExplorePage` header: l'etichetta "Livello X" sostituita col nome del rank, ora bottone che naviga a `/profile/rank`.
  - `ProfilePage` hero: stessa cosa, badge "⚔️ {rank.name} ›" cliccabile.
- **Vecchio `userLevel(score)/100+1` rimosso** da entrambe le pagine.
- **Creator track:** definito in `shared` ma NON ancora esposto in UI. Manca backend per le Carte: TODO quando il modello è pronto.

### [2026-05-02] Performance: bypass DNS su Supabase via /etc/hosts
Stefano segnalava che ogni pagina caricava lentamente (sospettava DB). **Diagnosi vera:** il resolver di sistema (systemd-resolved → upstream 1&1 DNS) impiegava 3,12s a risolvere `supabase-cat.duckdns.org` (vs 0,005s via IP diretto, 600× più lento) e falliva ~40 volte/ora con `EAI_AGAIN`. Le pagine come Esplora — che fanno 7 chiamate API parallele — pagavano ~3s di overhead DNS ciascuna; alcune andavano in timeout completo.

**Fix applicato:** aggiunta riga `212.227.21.104   supabase-cat.duckdns.org` a `/etc/hosts` + `systemctl restart piratopoly`.

**Misurazioni post-fix:**
| Endpoint | Prima | Dopo |
|----------|-------|------|
| `/api/maps` | timeout HTTP 000 dopo 14,7s | 0,194s ✅ |
| `/healthz` | timeout HTTP 000 dopo 4,7s | 0,026s ✅ |
| Risoluzione DNS Supabase | 3,120s | 0,005s |
| Errori `EAI_AGAIN` in 2 min | 6 | 0 |

**Caveat:** se l'IP di duckdns cambia (raro se DuckDNS è configurato con IP fisso), va aggiornata la riga. Soluzione strutturale futura: cambiare DNS upstream del server (es. Cloudflare 1.1.1.1) o spostare Supabase su dominio diretto.

### [2026-05-01] Mappa di gioco: retry automatico al caricamento
Stefano segnalava che `GameMapPage` (la mappa durante una sessione) a volte mostrava il loader senza mai terminare. La pagina ora fa **retry automatico** delle chiamate `/game/sessions/:id` e `/maps/:mapId` con backoff lineare (1s, 2s, 3s, max 5s) finché il caricamento non riesce. Il loader resta visibile durante i retry e mostra il contatore tentativi dopo il primo fallimento. **Hard error** (sessione senza `map_id`, mappa senza tappe per la giornata) interrompono il retry e mostrano il bottone manuale "Riprova" — sono errori di dati, non di rete. File: `GameMapPage.tsx`.

### [2026-05-01] Bussola: loader GPS con retry continui
Stefano segnalava che entrando nella pagina bussola spesso non veniva acquisita la posizione e l'utente restava bloccato. Modifiche:
- **Overlay full-screen** (`fixed inset-0 z-50`) in `GameCompassPage.tsx` mostrato finché `!position && !permissionDenied`. Riusa lo stile di `LoadingScreen` (icona 🧭 + spin gold) ma con messaggio specifico. Pulsante "Annulla" per tornare alla session.
- **`usePositionPoller` rivisto:** rimosso il messaggio di errore generico dopo 3 fallimenti — gli errori soft (timeout, position unavailable) non interrompono più il polling, retry continui finché non si ottiene un fix. Solo `PERMISSION_DENIED` è errore hard. Aggiunto fallback `CACHED_FALLBACK` (low-accuracy, maxAge 120s) richiamato quando un poll high-accuracy fallisce e ancora non c'è alcuna posizione: serve a sbloccare la UI con qualcosa anche su dispositivi lenti. Esposti `permissionDenied` (bool) e `attempts` (counter, mostrato in UI se >3 con suggerimento "esci all'aperto").
- L'admin override `simulatedPosition` continua a bypassare il loader (non si attiva se `position` è valorizzato).

## Sistema gradi giocatore (rank)

Definito 2026-05-01. Sistema di progressione **single-track lifetime**, basato sull'accumulo di Piastre, con **decay solo per inattività** (1 anno).

### Tabella gradi

| # | Grado | Tier | Soglia Piastre | Ruolo descrittivo |
|---|-------|------|---------------:|-------------------|
| 1 | Mozzo | Inizio | 0 | Apprendista |
| 2 | Marinaio | Inizio | 500 | Base operativo |
| 3 | Corsaro | Attivo | 2.000 | Competitore base |
| 4 | Razziatore | Attivo | 5.000 | Operativo avanzato |
| 5 | Predone | Esperto | 8.000 | Attaccante |
| 6 | Capobanda | Esperto | 18.000 | Leader locale |
| 7 | Ufficiale | Elite | 35.000 | Stratega |
| 8 | Comandante | Elite | 65.000 | Leader avanzato |
| 9 | Capitano | Endgame | 110.000 | Leader principale |
| 10 | Signore dei Mari | Endgame | 200.000 | Leggenda |

### Regole

- **Curva:** quasi-quadratica → primi gradi rapidi (onboarding), endgame lungo.
- **Calibrazione:** giocatore mediano (≈5 mappe/mese) raggiunge **Predone (5)** in ~1,5 mesi, **Capitano (9)** in ~22-24 mesi. **Signore dei Mari (10)** richiede ritmo 2-3× il mediano → solo top **<3%**.
- **No demotion per gioco:** il rank non scende perché perdi una partita o ricevi recensioni negative.
- **Decay per inattività** _(definito 2026-05-01)_:
  - Trigger: 12 mesi consecutivi senza guadagnare Piastre.
  - Effetto: dopo i 12 mesi, scende **1 grado ogni 6 mesi** di ulteriore inattività. Es. Capitano inattivo → al mese 18 diventa Comandante, al 24 Ufficiale, ecc., fino a Mozzo.
  - Reset timer: una qualsiasi attività che genera Piastre azzera il contatore.
- **Definizione di "attività"** _(confermato 2026-05-01)_: almeno 1 evento Piastre nei 12 mesi (mappa eseguita / quiz risolto). Il solo login NON conta.
- **No pay-to-rank:** Season Pass dà cosmetica (badge dorato), non scorciatoie sulle soglie.
- **Piastre solo da gioco** _(decisione 2026-05-01)_: per la prima versione, le Piastre si guadagnano **esclusivamente giocando** (eseguendo mappe, risolvendo quiz). NESSUNO streak, daily challenge, eventi stagionali, modalità allenamento. Decisione esplicita: tenere il sistema semplice all'avvio, valutare integrazioni dopo.
- **Storage suggerito:** tabella `piastre_events (user_id, value, created_at)` con index `(user_id, created_at)`. Il grado è **derivato** via SUM, non persistito → cambiare soglie = ricalcolo automatico, no migrazioni. Stesso schema necessario per supportare il decay temporale (l'ultimo `created_at` indica l'ultima attività).
- **Creator track separato** _(decisione 2026-05-01, confermato da Stefano)_: i creatori NON guadagnano Piastre dalle mappe altrui che eseguono la loro creazione. Hanno un track e una valuta dedicati (vedi sezione "Sistema gradi creator" più sotto). Modifica alla regola GDD originale "Pianificatore prende 100% propri + 50% terzi": **il 50% dei terzi va come Carte (valuta creator), non come Piastre**. Stessa meccanica di redistribuzione, valuta diversa.

### Vincolo economico (aggiornato 2026-05-01)

⚠️ Le soglie sopra erano provvisorie nella stima per "numero di mappe completate". Modello economico definito:

- **Annual Pass = mappe illimitate** _(decisione 2026-05-01)_. Prezzo da GDD: 39,99€/anno.
  - Mediano (5 mappe/mese × 24 mesi = 120 mappe) → ~120k Piastre → arriva a **Capitano (9)** col solo Annual Pass (~80€ in 2 anni).
  - Top giocatore (15 mappe/mese × 24 mesi = 360 mappe) → ~360k Piastre → arriva a **Signore dei Mari (200k)** col solo Annual Pass.
  - Costo per top 3% per arrivare a Signore dei Mari: ~80€/2 anni → sostenibile, non pay-to-rank.
- **Mappe singole / Pack3 / Season Pass** restano per chi non vuole impegno annuale → progressione lenta ma raggiungibile.

**Implicazione operativa:** rivedere il pricing GDD per esplicitare "Annual Pass = mappe illimitate".

### Da decidere (TODO)
- **Vantaggi/perk per ogni grado** (cosmetica, sblocchi, accessi marketplace, voucher migliori, leaderboard tier-specifica). Stefano: "un giorno dovremo decidere".
- **Naming convention nel codice:** distinguere `Tier` (5), `Rank` (10), `RankRoleLabel` (es. "Stratega") per evitare confusione con eventuali futuri ruoli social.
- **Colonna funzioni/abilità della tabella sorgente** (Stefano l'ha lasciata stare per ora).

## Sistema gradi creator (Cartografo)

Definito 2026-05-01. Track separato dai giocatori. Punteggio dedicato: **Carte** (carte nautiche). Stefano ha richiesto 3 gradi e mi ha delegato la scelta dei nomi e dei punti.

### Tabella gradi creator

| # | Grado | Soglia Carte | Note |
|---|-------|-------------:|------|
| 1 | Tracciatore di Rotte | 0 | Default alla pubblicazione della prima mappa |
| 2 | Cartografo | 15.000 | Creator attivo, mappe con seguito modesto |
| 3 | Maestro Cartografo | 250.000 | Top creator, mappe virali e/o catalogo ampio (target <3% dei creator) |

### Come si guadagnano Carte

Solo da attività di creazione/curatela mappe (NON dal gioco delle proprie mappe).

| Evento | Carte |
|--------|------:|
| Mappa pubblicata e approvata | +500 |
| **50% delle Piastre guadagnate dai giocatori sulla tua mappa** | variabile (sostituisce il 50% terzi del GDD) |
| Recensione 4-5★ ricevuta | +100 |
| Recensione 1-2★ ricevuta | -50 |
| Mappa selezionata "in evidenza" | +1.000 (one-shot per mappa) |
| Mappa promossa a marketplace editoriale | +5.000 (one-shot per mappa) |

**Nota sulla regola "50% Piastre giocatori":** una mappa media da 7 tappe genera ~1.000 Piastre per esecutore (loc + quiz). Il 50% = ~500 Carte per ogni esecutore della tua mappa. Questa è la fonte dominante di Carte; gli altri eventi sono cornice.

### Esempi di percorso
- **Da Tracciatore di Rotte a Cartografo (15k Carte):** ~1 mappa pubblicata (500) + ~30 esecutori (~15.000 Carte dal 50% Piastre) + qualche recensione 4-5★. Fattibile in 1-3 mesi con una mappa decente.
- **Da Cartografo a Maestro Cartografo (250k Carte):** ~5 mappe pubblicate (2.500) + ~500 esecutori totali (~250.000 dal 50% Piastre) + recensioni 4-5★ + eventuale mappa "in evidenza". Equivale a top creator con catalogo o 1 mappa virale.

### Regole creator

- **Track parallelo** ai gradi giocatore. Un utente può essere contemporaneamente "Comandante" come giocatore e "Maestro Cartografo" come creator. Sui profili pubblici si mostrano entrambi i badge.
- **Decay creator:** **NESSUN decay** _(decisione 2026-05-01)_. I gradi creator sono permanenti, non scendono per inattività. Stefano: il lavoro di un creator è una creazione di valore duraturo (le sue mappe restano nel marketplace), non va penalizzato col tempo.
- **Storage:** tabella `carte_events (user_id, value, source_map_id, created_at)` analoga a `piastre_events`.
- **Vantaggi creator (TODO):** verosimilmente sblocchi sul marketplace (visibilità, possibilità di pubblicare mappe a pagamento custom?, % sui voucher dei propri esercenti partner). Da decidere insieme ai vantaggi giocatore.

## Prossimi passi
- Definire dettaglio architettura tecnica
- Sviluppo Alpha PWA
- Partnership voucher Roma
- Definire vantaggi per ogni grado del sistema rank

## Assets
- GDD v2.0: Google Drive (2026 - Piratopoly_GDD_v2.docx)
- Regolamenti storici (2019, 2022)

## Link correlati
- [[wiki/people/stefano|Stefano Gitto]]
- [[wiki/projects/puntify|Puntify]]
