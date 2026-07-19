# Puntify — Checklist deploy prod (batch 17-19/07/2026)

Stato: TUTTO su CAT, testato. Prod NON aggiornata. Deploy prod = `deploy-prod.yml` (workflow_dispatch manuale di Stefano). Il push su master NON deploya.

## 1. Commit + push (repo, 73 file)
Attendere l'OK "committa e pusha" di Stefano. Consigliati commit tematici (o unico):
- Kiosk menu (gia' su master: b058510) + photo picker (d6b569d) + Dashboard admin (d17bedd) — GIA' COMMITTATI
- Da committare: fix tz prenotazioni (all screens) · notifica Telegram prenotazione · popup allargati · logo book · menu fasce orarie (fuso+cavallo mezzanotte) · Nemi (pausa+audit F1-F8+banner UI+reminder salva+drag-menu OCR) · booking (IDOR operatori, validazioni create, anti-race, min-advance reschedule, toast errori) · POS (optimistic locking conto, codice ordine atomico, rate-limit OCR, guard ordine pagato/doppio-pay, dish cross-shop, badge prezzo) · loyalty (endpoint decide server-authoritative, formula LoyaltyPoints, age-check fuso, saldo approvazione) · queue (weight priority, confirmed filter) · pagina pubblica/recensioni (snapshot formats+vat, validazioni review) · sicurezza (RLS transactions, log token Google, validazione events email, nonce OAuth, magic-bytes upload, NaN AI, sentiment check)

## 2. Migration DB da eseguire in PROD (in ordine)
Eseguire sul Postgres di PROD (NON puntify_cat). Ognuna e' idempotente.
1. `add_section_description.sql`  (colonna descrizione sezioni + NOTIFY pgrst)
2. `add_queue_weight.sql`  (colonna queues.weight)
3. `20260717_admin_dashboard.sql`  (RPC admin_dashboard — per /admin/dashboard)
4. `20260717_photo_source_allow_catalog_url.sql`  (CHECK photo_source catalog/url)
5. `20260718_queue_weight_priority.sql`  (RPC queue_call_next_across con peso — DOPO add_queue_weight)
6. `20260719_rls_transactions_isolation.sql`  (RLS transactions cross-shop leak)
7. `20260719_social_sentiment_check.sql`  (CHECK sentiment)
8. `20260720_*` (marketing FASE-1: suppression, credits, campaigns, voucher_columns, app_settings) — batch marketing base
9. `20260721_campaign_presets.sql`  (catalogo campagne: colonne preset_key+trigger_config, unique index, ED ESTENDE il CHECK campaigns_kind_check con 'auto'+'manual_template' — SENZA questo l'enable preset fallisce 23514)
10. `20260721_social_settings.sql`  (tabella shop_social_settings: cadenza+profondita import per PV)

Dopo OGNI migration con ADD COLUMN/RPC: verificare `NOTIFY pgrst, 'reload schema';` (incluso negli script) o restart PostgREST prod, altrimenti PGRST204 / RPC non vista.

NB batch 21/07 (catalogo marketing + Social) GIA' applicato su CAT e testato end-to-end (enable/disable/patch/use-template preset OK dopo fix constraint; social settings GET/PUT OK). Il fix constraint campaigns_kind_check e' incluso nella stessa 20260721_campaign_presets.sql (idempotente).

## 3. Config PROD
- Caddy prod (app.puntify.it / puntify.it): aggiungere header no-cache su index.html/build-info.js/_framework/blazor.boot.json/service-worker (snippet gia' dato) per il bug "nuova versione in loop".
- Credito Anthropic esaurito: ricaricare (blocca OCR menu/scatta-cartaceo/traduzioni/drag-menu).
- Stripe:WebhookSecret impostato in prod (/opt/ops/.env) — verificato serve per abbonamenti FASE 2.

## 4. Dopo deploy
- Hard-refresh WASM (Ctrl+F5) lato utenti.
- Verificare: prenotazione tavolo mostra orario (non "2 giorni"); menu serale 20:00-02:00 disponibile; descrizioni sezioni; kiosk.

## Decisioni Stefano pendenti (business)
- Floor vs Round punti · max_redemptions premi · handler refund Stripe (storno punti) · EXCLUDE constraint anti-overlap bookings · quando fare FASE 3 blocco morosi / FASE 2 IVA abbonamento.
