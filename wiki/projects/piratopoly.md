# Piratopoly

## Obiettivo
PWA AI-powered urban treasure hunt: i giocatori pianificano da remoto itinerari personalizzati, poi li eseguono fisicamente esplorando la città.

## Concept
- **Due fasi**: Pianificazione (remoto) → Esecuzione (sul posto con GPS)
- **AI-first**: genera percorsi ottimizzati, quiz contestuali, immagini copertina
- **UGC**: i giocatori creano mappe → marketplace community
- **Esplorazione con purpose**: tappe reali (monumenti, festival, trattorie)

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

## Decisioni di sviluppo
### [2026-04-29] Frontend layout "telefono al centro"
App mobile-first ma usabile anche su desktop/tablet centrata.
- Wrapper globale in `App.tsx`: `<div class="mx-auto w-full max-w-md min-h-screen bg-bg shadow-2xl ...">` racchiude le Routes.
- Body in `index.html` cambiato da `bg-bg` a `bg-black` per il "letterbox" ai lati su desktop.
- `BottomNav`, `GameBottomNav`, MapDetailPage CTA footer fixed: pattern `fixed left-1/2 -translate-x-1/2 w-full max-w-md` (NON `left-0 right-0`).
- Larghezza scelta: `max-w-md` (28rem = 448px). Coincide con il token `--content-max-w` in `frontend/src/styles/tokens.css` (esistono anche `--content-tablet-w: 42rem` e `--content-desktop-w: 64rem` per eventuale layout responsive multi-breakpoint).
- **Quando aggiungere un nuovo elemento `fixed`:** evita `left-0 right-0`. Usa `left-1/2 -translate-x-1/2 w-full max-w-md`. Eccezione: modali/loading screen veramente fullscreen (`LoadingScreen.tsx`, alcuni overlay) → `fixed inset-0` ok.

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
