# Working context

## Task corrente (2026-07-19) — COMPLETATO
Piracity backend (/home/progetti/piracity/backend) — sistema possesso mappe + regalo.

### Fatto
- services/entitlement.service.ts: `userOwnsMap(userId, mapId)` — true se mappa gratuita (price NULL o <=0) o esiste user_map_unlocks.
- routes/game.routes.ts: POST /game/sessions ora fa gate paywall -> 403 {error:'map_not_owned'} se non posseduta.
- routes/redeem.routes.ts: POST /redeem (requireAuth, zod token min 10). Idempotente: 404 invalid_token / 200 alreadyOwned (stesso utente) / 409 already_redeemed (altro) / 410 expired (expired|cancelled|expires_at passato, promuove pending scaduto a expired) / 200 unlock+redeemed (pending). Guardia anti doppio-riscatto concorrente su UPDATE ... WHERE status='pending'.
- routes/me.routes.ts: GET /me/map-access -> {mapIds:[]} dagli unlock di req.userId.
- app.ts: registrate redeemRoutes su '/' (POST /redeem con requireAuth per-route, NON router.use, per non intercettare /health) e meRoutes su '/me'.

### Verifica
- tsc: 0 errori nei file toccati (unico errore preesistente in payment.service.ts, versione Stripe, non toccato).
- Self-test curl su :6001 a-e tutti OK; dati di test ripuliti (utenti + gifts + unlocks + sessions).

### Prossimi passi
- La vetrina (altro agent) genera il token gift e crea la riga map_gifts. Contratto rispettato: /redeem {token}, /me/map-access {mapIds:[]}.
