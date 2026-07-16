# Working context — 2026-07-16 ~17:47 Roma

## Commit oggi su master (Imodejam/Puntify) — Stefano deploya prod
- 0f06086: retry MiniMax, retry S3, guard admin_activity_log, verbosita upload, popup elimina prodotto/sezione
- 6ca82ee: Expect:100-Continue=false (upload storage)
- 3315641: menu pubblico sotto-sezioni scroll continuo + header sticky ricorsivo + kiosk 1080x1920 + fix bug sticky (overflow-x body)
Su CAT tutto attivo (hot-reload).

## Thread aperti con Stefano
1. UPLOAD foto sezione prod: root cause = reset connessione verso storage prod (bucket dishimages-prod). Stack mostra Expect:100-Continue. Fix Expect-100 pushato (6ca82ee). Ma prod e Caddy come CAT -> sospetto vero = request_body max_size Caddy prod troppo basso. Stefano sta verificando Caddy. Dato checklist. In attesa dimensione foto / site block.
2. MENU KIOSK - PROPOSTA Stefano (2026-07-16): layout stile McDonald's = rail verticale a SINISTRA con le sezioni top, prodotti a destra con header sticky. SOLO kiosk verticale; mobile/desktop invariati. Chiesto a Stefano: (1) foto sezione nei tile del rail? (2) prodotti a griglia 2 col su kiosk? -> IN ATTESA conferma prima di costruire.
3. MENU desktop/kiosk: colonna sinistra vuota -> la proposta kiosk (rail sinistra) la risolve; su desktop resta da decidere se centrare.
4. SOCIAL 17/07 (raccolta_punti): schedulato Buffer IG+LI+FB per 2026-07-17 12:30 Roma. Cron giornaliero 1430aba3 (13:37 UTC=15:37 Roma) genera la bozza del giorno dopo. Cron scade 7gg -> RI-ARMARE.

## Prossimi passi
- Ricevere conferma Stefano su kiosk McDonald's (2 domande) -> costruire (subagent) + screenshot.
- Ricevere esito Caddy prod upload.
- Deploy prod (Server + Vetrina) lato Stefano.
