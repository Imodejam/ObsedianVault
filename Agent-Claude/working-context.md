# Working context

## 2026-07-19 — Piracity go-live: pagamento + regalo mappa (COMPLETATO su CAT, non committato)
Costruito + testato + audit su collaudo. Orchestrato con 5 subagent (esplorazione, backend, vetrina, frontend, audit, remediation).

### Fatto (tutto su CAT, testato e2e reale)
- Migration 017 (user_map_unlocks + map_gifts) + 018 (game_stage_checkins) applicate su piracity_cat.
- Backend app: chiuso buco paywall (/game/sessions richiede possesso o mappa gratis) + POST /redeem + GET /me/map-access.
- Vetrina: checkout opzione regalo + webhook fulfillment idempotente (sblocco self da orders.user_id, o buono regalo) + QR + email Resend.
- Frontend: /redeem deep-link (non-loggato->registrazione->riscatto auto), ownedMapIds dal server, gating play, i18n 6 lingue.
- Sicurezza (audit): C1 CRITICAL RCE /api/upload-photo (vetrina) CHIUSA (execFile array, UUID, auth admin); H2 score location ora server-authoritative (game_stage_checkins); M1 webhook usa orders.user_id; M2 rate-limit 10/15min su login+redeem.
- E2E verificato: register->paywall 403->gift->redeem 200->gioco 201->map-access; C1 401 no-auth; M2 429; H2 client-inflated ignorato. 0 residui test.

### PENDENTI
- Commit+push (al "committa" di Stefano). Migration da portare in prod: 017, 018 (+ le altre gia' in checklist se non fatte). NIENTE Co-Authored-By Claude.
- PROD prerequisiti: chiave Resend + dominio email Piracity (assenti->email non partono); price_id Stripe prod; PHOTO_UPLOAD_ENABLED=0 in prod.
- Catalogo pricing V1 4-fasce (Mini/Classica/Estesa/Pack) resta da allineare (separato, non richiesto ora).

## Contesto Puntify (sessione precedente, gia' committato/pushato fd04b46)
14 campagne marketing + Social Studio + fix audit-log admin. Deploy prod Puntify ancora da fare (checklist [[puntify-deploy-checklist-20260719]]).
