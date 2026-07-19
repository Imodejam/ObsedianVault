# Piracity — Go-live: pagamento + regalo mappa (review 19/07/2026)

Richiesta Stefano (2026-07-19): review completo Piracity (vetrina+app) + test + sicurezza + implementare cio che manca per andare live, in particolare il PAGAMENTO lato vetrina come pacchetto/REGALO -> mail con QR+link -> chi apre si registra -> mappa associata all'account -> gioca. Stripe confermato.

## Stato attuale (mappa fattuale)
- App: monorepo TS (backend Express :6001 + frontend React/Vite :6002 PWA). Vetrina: Next.js 14 :6010. **Vetrina e app condividono lo stesso Supabase** (schema piracity, supabase-cat).
- Auth: Supabase GoTrue + JWT; `piracity.users` (role/total_score/piastre). Register/login OK.
- Game loop COMPLETO e prod-ready: game_sessions, GPS check-in server-authoritative, quiz, scoring, completamento, replay multiplier, voucher partner, recensioni, badge.
- **Stripe GIA' funzionante sulla VETRINA**: `/app/api/checkout` crea session (richiede mapId ufficiale+published+price>0, email opzionale), `/app/api/webhooks/stripe` gestisce completed/expired/refunded, tabelle `orders`+`order_events` con RLS. Admin `/admin/orders` read-only.
- `backend/src/services/payment.service.ts`: PLANS (single_map/explorer_pack/season_pass/annual_pass) definiti ma NON usati.

## Buchi / cosa manca (per go-live + regalo)
1. **SICUREZZA — paywall aperto**: `POST /game/sessions` (game.routes.ts ~31-40) controlla solo `status='published'`, NON price/ownership -> chiunque con l'UUID gioca gratis una mappa a pagamento. Da chiudere.
2. **Nessun modello ownership**: manca tabella `user_map_unlocks` (utente<->mappa posseduta). `entitlement.store` frontend ha ownedMapIds solo locale.
3. **Nessun sync ordine->account**: order.status='paid' non concede la mappa a nessun account nell'app.
4. **Nessuna infra email** (serve per QR+link regalo) -> usare Resend (come Puntify).
5. **Nessun QR/deep-link/redeem** per acquisti (il QR esiste solo per i voucher partner in-game).
6. Store piastre: UI c'e', logica di spesa assente (fuori scope core).

## Flusso regalo proposto (design)
1. Vetrina map detail: "Acquista" / "Regala". Checkout esteso con opzione regalo (email destinatario + messaggio).
2. Stripe Checkout (one-time). Al `checkout.session.completed` (webhook vetrina, gia' esiste): oltre a marcare l'ordine paid, crea record gift/redemption con **token monouso (UUID + HMAC)** legato a map_id+order_id, genera QR (encoda il link di riscatto) e invia email (Resend) al destinatario (o all'acquirente) con QR + link + messaggio.
3. Link riscatto -> app (`app-cat.piracity.app/redeem/<token>`): destinatario si registra/logga -> `POST /redeem` valida token -> crea `user_map_unlocks(user_id,map_id,source=gift,order_id)` -> mappa posseduta -> gioca.
4. Enforcement: `POST /game/sessions` richiede price IS NULL OR esiste user_map_unlocks -> altrimenti 403 (chiude il buco #1). Acquisto self da utente loggato -> unlock diretto nel webhook.

Vetrina e app condividono il DB: il webhook vetrina puo' scrivere direttamente unlock/gift; il redeem endpoint sta nel backend app.

## Decisioni business (in attesa OK Stefano, msg 6771) — con default proposti
1. Vendo/regalo per singola mappa al prezzo attuale `maps.price` (catalogo V1 4-fasce allineato dopo, separato).
2. Checkout con opzione "e un regalo?": si -> email destinatario+messaggio; no + loggato -> unlock diretto.
3. Email via Resend.

## Contesto
Piracity era in pausa (priorita Concilium). Pricing V1 approvato ma pagamenti mai avviati (codice prezzi V0). Gift mappe = "da fare" (Fase 4 [[piracity-pricing-v1-execution]]). Anthropic API riservata a Concilium: per generazione Piracity usare Claude Code CLI/inline, NON l'API HTTP. Vedi [[piracity]] [[piracity-web]] [[piracity-pricing-strategy]].
