# Working Context

## Sessione 2026-07-19 — Puntify ROADMAP follow-up (batch R1-R6)
Owner: Stefano. Su master 0038970 (tree pulito). NO commit/push.

### Task
- R1: rewards.max_redemptions cap + enforce in redeem_reward RPC + UI merchant + resx 10 lingue
- R2: EXCLUDE constraint anti-overlap su puntify.bookings (btree_gist) + mapping 409 server
- R3: Stripe charge.refunded handler -> transazione loyalty negativa idempotente
- R4: MenuController UpdateDish/UpdateSection validazione server-side (name, price) su UPDATE
- R5: MenuController.Publish re-sequence sort_order deterministico
- R6: ClientDetail.razor tab in URL + NegozioDetail.razor canonical env-aware (CAT)

### Fatti schema verificati (live puntify_cat)
- transactions.reason: 1=credit(+), 2=debit(-). Balance=SUM(reason=1?+points:-points). Ha booking_id, stripe_payment_id, source, description.
- rewards: id, shopid, title, minpoints, description, image, same_genre. Manca max_redemptions.
- account_reward: accountid, rewardid, used, insertdate.
- bookings: operator_id nullable, status in (confirmed,pending,cancelled), start_at/end_at tstzrange.
- redeem_reward(p_account,p_reward) RETURNS jsonb, SECURITY DEFINER, advisory lock su account+shop.

### Stato: subagent lanciati in parallelo. Build/restart/apply migrazioni centralizzati a fine.

## [2026-07-19] FASE-1 Marketing module Puntify (subagent build)
- Obiettivo: fondamenta modulo marketing email-only (no frontend, no SMS reale, no Stripe purchase)
- Build: 4 migrazioni CAT + 6 modelli Marketing + servizi + controller + scheduler compleanni
- Bit feature 128 = marketing (ShopExtensions.HasMarketing)
- Riuso: EmailQueueService, rewards/account_reward/redeem_reward, pattern WeeklyRecapScheduler, RLS customer_profiles
- DB CAT: sudo docker exec -i ops-postgres psql -U postgres -d puntify_cat

## Stato 19/07 ~09:45 (dopo reset limite sessione)
- ROADMAP fixes: nel working tree, compilano. max_redemptions applicata CAT. EXCLUDE booking migration pronta ma non applicata (overlap demo). R3-R6 da testare/verificare.
- MARKETING: rilanciata build FASE1 backend pulita (agent a9cb62e). Poi: frontend (integra Consent.razor esistente) + Nemi tools.
- DA COMMITTARE quando pronto: roadmap fixes (30 file circa) + marketing FASE1.
- Migration accumulate per prod: aggiungere reward_max_redemptions, bookings_exclude_overlap (dopo cleanup overlap), + marketing FASE1.
