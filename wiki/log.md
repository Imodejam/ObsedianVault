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
