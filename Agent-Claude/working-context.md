# Working context — 2026-07-16 ~23:01 Roma (fine giornata)

## Commit oggi su master (Imodejam/Puntify) — DA DEPLOYARE IN PROD
Server: 0f06086 (retry MiniMax+S3, guard admin_activity_log, verbosita upload, popup elimina), 6ca82ee (Expect:100-Continue off upload), 662fa7c (Nemi formati/tipo food-drink)
Vetrina: 3315641 (menu sotto-sezioni scroll+sticky), 6a06f91 (kiosk McDonald + terminologia proposte)
Su CAT tutto attivo (hot-reload).

## Aperti
1. UPLOAD foto sezione PROD: reset connessione verso storage (bucket dishimages-prod). Fix Expect-100 pushato (6ca82ee) ma prod e Caddy come CAT -> sospetto request_body max_size Caddy prod. Stefano stava verificando Caddy. Da confermare dopo deploy: se persiste, alzare max_size (~30MB) sul site storage prod.
2. Deploy prod (Server+Vetrina) lato Stefano.
3. Kiosk: colonna sinistra su DESKTOP (non kiosk) ancora un po' vuota - non sollevato di nuovo, eventuale follow-up.

## Automazione attiva
- Cron social 1430aba3: 13:37 UTC = 15:37 Roma -> genera bozza del giorno dopo, invia a Stefano (505161324), su OK publish.py Buffer. SCADE 7gg (2026-07-23) -> RI-ARMARE.
- Post 17/07 (raccolta_punti) gia schedulato Buffer IG+LI+FB per 2026-07-17 12:30 Roma.

## Note skin social
/home/progetti/puntify-social/skin/ (topics, image, storage files.puntify.it, buffer). create_post: customScheduled+dueAt per data specifica; metadata per-servizio (IG type+shouldShareToFeed, FB type). Buffer channels: IG 69e0a49f031bfa423c0c9bb5, LI 69b986107be9f8b17166990a, FB 69b9bf437be9f8b17167d13f.
