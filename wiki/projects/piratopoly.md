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

## Prossimi passi
- Definire dettaglio architettura tecnica
- Sviluppo Alpha PWA
- Partnership voucher Roma

## Assets
- GDD v2.0: Google Drive (2026 - Piratopoly_GDD_v2.docx)
- Regolamenti storici (2019, 2022)

## Link correlati
- [[wiki/people/stefano|Stefano Gitto]]
- [[wiki/projects/puntify|Puntify]]
