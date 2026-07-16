# Working context

## Ora — Puntify Social Skin operativa
Skin giornaliera COSTRUITA e testata. Script in /home/progetti/puntify-social/skin/
(config.json, lib/{appconfig,topics,image,storage,buffer}.py, run_draft.py, publish.py).
Standard immagine approvato (gpt-image-2 scena + headline + logo reale composited).

## Stato canali Buffer
- LinkedIn "Puntify" 69b986107be9f8b17166990a — CONNESSO
- Facebook "Puntify" 69b9bf437be9f8b17167d13f — CONNESSO
- Instagram puntify.it 69e0a49f031bfa423c0c9bb5 — DISCONNESSO (Stefano deve riconnettere)
Buffer endpoint: https://api.buffer.com/graphql ; createPost per singolo canale (loop), addToQueue+automatic best-time.

## Scheduling
- Cron giornaliero 1430aba3: 13:37 UTC = 15:37 Roma -> genera bozza del giorno DOPO, invia a Stefano (505161324), su OK publish.py su Buffer best-time. Scade 7gg -> RI-ARMARE.
- One-shot 250ecb5b: oggi 15:00 UTC = 17:00 Roma -> invia la prima bozza (17/07 raccolta_punti) gia' pronta.

## Prossimi passi
- 17:00: parte l'invio della bozza 17/07 (raccolta_punti). Attendere approvazione Stefano -> publish.py.
- Stefano deve dire se spostare il cron giornaliero alle 17 (ora 15:37).
- Stefano deve riconnettere Instagram su Buffer.
- Ri-armare i cron ogni <7 giorni.

## Post pronti
- posts/2026-07-17_raccolta_punti/ (pending_approval) — bar penombra, sgabello vuoto rosso, "IL CLIENTE MIGLIORE / È QUELLO CHE NON TORNA."
