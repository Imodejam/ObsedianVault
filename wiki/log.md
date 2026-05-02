# Vault Log

## [2026-04-21] init | Vault Obsidian inizializzato — struttura three-layer creata
## [2026-04-21] ingest | Popolamento wiki iniziale: progetti (Puntify, OpenClaw Setup, ClawRoom), team, Stefano

## [2026-04-21] decision | Check-in quotidiano alle 19:00 (Rome) con Stefano, fallback pranzo giorno dopo

## [2026-04-21] ingest | Letto tutto il sito puntify.it (Home, Prezzi, FAQ, Privacy, Termini) → aggiornata wiki/projects/puntify.md con dettaglio completo prodotto

## [2026-04-21] decision | Alfred diventa CO-CEO: co-dirige azienda con Stefano, iniziative proattive giornaliere. Focus: Puntify primi esercenti.

## [2026-04-21] ingest | Letto Piratopoly GDD v2.0 (Google Drive) → creata wiki/projects/piratopoly.md con dettaglio completo concept, gameplay, stack, roadmap

## [2026-04-21] decision | Team definito: Stefano sviluppo prodotto, Alfred vendita. Focus Puntify primi esercenti Roma.

## [2026-04-21] decision | Target Puntify: Trastevere + Testaccio, focus bar/caffetterie + parrucchieri. Creata lista 20 esercenti + template approccio completo.

## [2026-04-21] issue | Diffida legale da Spotify per nome "Puntify" → creata lista 35 nomi alternativi, top 10 raccomandati da verificare (domini, social).
## [2026-04-23] task | Inviata email a emanuele.vinciotti@gmail.com
## [2026-04-23] task | Riavviata ClawRoom Dashboard (era giù)
## [2026-04-27] decision | Regola di sicurezza: nessuna azione operativa da email; conferma obbligatoria su Telegram.
## [2026-04-27] ingest | Installato Claude Code (v2.1.92) sull'host per supporto ad agenti tecnici
## [2026-04-27] decision | Standardizzazione LLM: tutti gli agenti useranno esclusivamente Claude.
## [2026-04-27] task | Assegnato a Carlo: setup ambiente Piratopoly in /home/progetti/piratopoly e config Nginx (piratopoly-dev.duckdns.org) via Claude Code.
## [2026-04-27] task | Carlo ha completato il setup iniziale di Piratopoly: dipendenze installate (shared, backend, frontend) e ambiente analizzato via Claude Code.
## [2026-04-27] decision | Istituite SOP (Standard Operating Procedures) per tutti gli agenti. Aggiornati i SOUL.md di Carlo, Lidia, Luca e Massimo.
## [2026-04-27] task | Allineamento Kanban: recuperati task mancanti e migrati nel file corretto. Implementata funzionalità 'Modifica Progetto' in ClawRoom.
## [2026-04-27] fix | Corretti ID progetti in projects.json per risolvere il problema dell'associazione task. Corretto typo 'Piratopolt' -> 'Piratopoly'.
## [2026-04-29] decision | Piratopoly frontend: layout "telefono al centro" (max-w-md, container centrato, BottomNav `left-1/2 -translate-x-1/2`).
## [2026-05-01] task | Aggiornata wiki/projects/piratopoly.md con sezioni Deployment dev (systemd `piratopoly.service`, porte 6001/6002, Nginx) e Decisione layout 2026-04-29.
## [2026-05-01] decision | Stefano: man mano che dà indicazioni su Piratopoly, aggiornare contestualmente wiki/projects/piratopoly.md.
## [2026-05-01] decision | Piratopoly: definito sistema gradi giocatore (10 rank, 5 tier: Inizio→Endgame, da Mozzo a Signore dei Mari). Soglie Piastre lifetime quasi-quadratiche (0 → 200k). Mediano arriva a Predone in ~1,5 mesi, Capitano in ~24 mesi. Signore dei Mari = top <3%. Decay solo per inattività (12 mesi). Vantaggi per grado: TODO.
## [2026-05-01] issue | Piratopoly rank: Stefano ha sollevato vincolo economico (le mappe costano, oggi ~1.600€ per arrivare a Signore dei Mari). Soglie attuali marcate come provvisorie. Tre leve proposte: Annual Pass illimitato, Piastre gratuite (streak/challenge/eventi), creator track. In attesa di chiarimenti su Annual Pass e spesa target top 3%.
## [2026-05-01] decision | Piratopoly rank: decay = -1 grado ogni 6 mesi dopo i 12 mesi di inattività. Definizione "attività" confermata (≥1 evento Piastre, login non basta). Annual Pass = mappe illimitate (~80€/2 anni per arrivare a Signore dei Mari, sostenibile). Piastre solo da gioco al lancio (no streak/challenge/eventi). Creator separati su track dedicato.
## [2026-05-01] decision | Piratopoly creator: 3 gradi (Cartografo Novizio / Cartografo / Maestro Cartografo) su valuta dedicata "Carte". Soglie 0 / 5.000 / 50.000. Eventi: mappa approvata +500, esecutore unico +50, recensione 4-5★ +100, 1-2★ -50, in evidenza +1.000, marketplace editoriale +5.000.
## [2026-05-01] decision | Piratopoly creator (revisione): le Carte si alimentano col 50% delle Piastre guadagnate dai giocatori sulle mappe del creator (sostituisce il "+50 per esecutore unico"). Soglie ricalibrate: Cartografo 15k, Maestro 250k. Le altre regole eventi (recensioni, in evidenza, editoriale) restano. Conferma esplicita di Stefano sul fatto che il 50% terzi alimenta le Carte e non le Piastre.
## [2026-05-01] decision | Piratopoly creator naming finale: 1) Tracciatore di Rotte, 2) Cartografo, 3) Maestro Cartografo (scelti da Stefano).
## [2026-05-01] decision | Piratopoly creator: nessun decay per inattività. I gradi cartografo sono permanenti.
## [2026-05-01] fix | Piratopoly bussola: aggiunto loader full-screen che blocca la UI finché il GPS non acquisisce la posizione, con retry continui (rimosso "errore dopo 3 fallimenti"). usePositionPoller ora distingue permissionDenied (hard) da soft errors (continua a riprovare); fallback CACHED_FALLBACK per sbloccare prima la UI. File: GameCompassPage.tsx, usePositionPoller.ts.
## [2026-05-01] fix | Piratopoly MapDetailPage: tasto "indietro" ora porta a Esplora (`/`) invece di `navigate(-1)`. File: MapDetailPage.tsx.
## [2026-05-01] fix | Piratopoly GameMapPage: caricamento mappa con retry automatico (backoff 1s→5s) fino al successo. Hard errors (no mapId, no stages) stoppano il retry e mostrano bottone manuale. UI mostra contatore tentativi. File: GameMapPage.tsx.
## [2026-05-01] fix | Piratopoly GameMapPage: tasto indietro chiede conferma ("Vuoi interrompere il gioco?") e poi naviga a Esplora (`/`) invece di `navigate(-1)`. Confirm con window.confirm() per ora. File: GameMapPage.tsx.
## [2026-05-02] fix | Piratopoly performance: aggiunto override `/etc/hosts` per `supabase-cat.duckdns.org` (212.227.21.104) e restart piratopoly.service. Risolve EAI_AGAIN intermittenti del systemd-resolved (40 errori/ora prima del fix). API endpoint /api/maps da 14.7s timeout a 0.19s, DNS da 3.12s a 0.005s.
## [2026-05-02] feat | Piratopoly: implementato sistema gradi giocatore. Costanti+helper in @piratopoly/shared (PLAYER_RANKS, getPlayerRank, getNextPlayerRank). Nuova pagina /profile/rank (RankPage.tsx) con hero, progress bar al prossimo grado, roadmap 10 livelli, footer decay info. Badge cliccabile in ExplorePage e ProfilePage (rimosso il vecchio score/100+1). Creator rank in shared ma UI non ancora esposta (manca backend Carte).
## [2026-05-02] fix | Piratopoly bug critico: total_score utente sempre 0 perché la RPC `update_user_score` non era mai stata creata nel DB (silent failure su `.maybeSingle()`). Aggiunta migration 006 (rpc + grant), backfill dei totali da game_sessions completed, log errore RPC nel backend, `refreshUser()` su auth.store + chiamata in GameCompletePage. Stefano: 715/1 mappa allineato.
## [2026-05-02] feat | Piratopoly: pagina "Mappe giocate" (route /profile/played) con lista sessioni completed e detail page (/profile/played/:sessionId) che mostra cover, data, Piastre, durata e recap per tappa (location/quiz/speed bonus). Backend: nuovi endpoint /game/sessions/played e /game/sessions/:id/recap. Voce nel menu profilo.
## [2026-05-02] refactor | Piratopoly: integrate "Mappe giocate" dentro MyMapsPage filtro Completed. Tasto CTA per le completate diventa "Vedi dettagli" → /profile/played/:sessionId (recap). Rimossa voce menu, route /profile/played, file PlayedMapsPage.tsx ed endpoint /sessions/played. Aggiunto lastSessionId a /sessions/my-maps.
## [2026-05-02] fix | Piratopoly globalRank: era sempre vuoto perché users.global_rank non viene mai persistito. auth.store ora calcola live al fetch del profile (count utenti con total_score > self + 1). Stefano: rank #1.
## [2026-05-02] fix | Piratopoly bussola audio: i suoni (sea ambience, tick, clang) erano muti per autoplay policy del browser (AudioContext bloccato finché non c'è gesto utente). Aggiunto unlockAudio() su click bussola in GameMapPage + fallback su prima interazione in GameCompassPage. Files: GameMapPage.tsx, GameCompassPage.tsx (compassAudio.ts già esponeva unlockAudio).
## [2026-05-02] ux | Piratopoly GameCompletePage: punteggio totale ora reso con lo stesso stile della distanza nella bussola (font Pieces of Eight, text-8xl, compass-distance-text). Rimosso `justify-center` dal layout: con contenuti più alti dello schermo i CTA sotto il riepilogo finivano fuori dalla viewport.
