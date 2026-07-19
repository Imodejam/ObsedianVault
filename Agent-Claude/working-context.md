# Working Context

## Obiettivo sessione (2026-07-19)
Build FASE-1 (EMAIL-only) backend modulo MARKETING per Puntify (/home/progetti/puntify). No commit/push.

## Fatti verificati (CAT puntify_cat, schema puntify)
- Consent: tabella `account_profiles` (PK `accountid` -> account.id), flag `consent_email_promo`/`consent_sms_promo`. NIENTE tabella marketing_consent.
- Orphan marketing tables DROPPED (confermato). RPC grant_marketing_credits/consume_marketing_credit ESISTONO ancora (partial run) -> CREATE OR REPLACE idempotente. Loro schema: marketing_credits(shop_id, email_purchased, email_consumed, sms_purchased, sms_consumed, updated_at); marketing_credit_ledger(shop_id, channel, delta, reason, stripe_ref, campaign_send_id).
- rewards ha gia reward_kind, discount_percent, max_redemptions (stock cap); account_reward ha gia expires_at, source_campaign_id (partial). DDL idempotente.
- redeem_reward attuale = versione con stock-cap (max_redemptions). Estendere per expiry SENZA rimuovere stock cap.
- Email rail: EmailQueueService.EnqueueAsync(email,name,subject,html,emailType,priority=3,scheduledAt). EmailStrings.T(lang,key,args). lang da account.language.
- Audience: transactions.accountid UNION bookings.customer_id -> account.id (ShopCustomersController).
- ShopExtensions bit7=128 libero -> HasMarketing. Shop.EnabledFeatures.
- Scheduler pattern: WeeklyRecapSchedulerService (BackgroundService, TimeZoneInfo IANA, gate config). Registrare in Program.cs riga ~209.
- Auth: [RequireShopOwner] su api/shop/{shopId:guid}/... ; _auth.GetUserId(HttpContext)=JWT sub. ISupabaseClient: Get/GetSingle/Insert/Upsert/Update/InvokeRpcAsync<T>.
- API-key middleware bypassa /api/public -> unsubscribe su api/public/marketing/unsubscribe.
- customer_profiles: RLS ON no-policy (pattern server-only).

## Stato
In costruzione: migrazioni + modelli + servizi + controller + scheduler.
