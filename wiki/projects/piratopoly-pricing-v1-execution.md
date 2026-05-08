# Piratopoly · Pricing V1 — Piano di Esecuzione

**Documento sorgente:** [[../../raw/docs/piratopoly/pricing-v1-2026-05-08.md|GDD Modello Commerciale e Pricing V1 (2026-05-08)]]
**Stato implementazione:** non avviato — piano in attesa di OK
**Owner:** Stefano + Claude

## Stato attuale (gap analysis)

Confronto del repo `piratopoly` (branch `feat/v1-autonomous-build`) col GDD.

| Area | Stato attuale | GDD V1 | Delta |
|---|---|---|---|
| SKU mappa | "Mappa singola 7,99 €" + Pack3 18,99 € + Season Pass 14,99 €/3mesi | Demo / Mini 5,99 / Classica 11,99 / Estesa 14,99 / Pack 24,99 / Pass 11,99-79 | Catalogo da rifondare |
| Validità mappa | Non strutturata, solo `status: completed` | 24h Mini, 48h Classica, 72h Estesa **dal primo avvio** | Schema sessione + countdown |
| Pirate Pass | Non esiste (Season Pass è altro concetto) | Subscription mensile/annuale + benefici | Stripe Subscription + entitlements |
| Esplorazione Libera | "ComingSoon" | Carte AI + serendipity + tier free/Pass | Tutta da fare |
| Classifica | Una sola (utenti, mappa) | Capitani vs Esploratori, separate | Schema + UI |
| Voucher | Sistema base (sblocco a tappa) | + premium / leggero / completamento / EL gated | Espansione |
| Referral | Pagina ComingSoon | Codice + link + premio Mini per entrambi | Da fare |
| Gift mappe | Non esiste | Mappa o Pass annuale regalabile | Da fare |
| City Champion | Non esiste | Mensile + soglia 15 utenti + badge | Da fare |
| Mappe stagionali | Non esiste flag | `valid_from/valid_to` + early access Pass + blocco vendita 72h | Da fare |
| Replay | Già fuori classifica (idempotenza /complete + multiplier) | Confermato | Allineato ✓ |
| Demo Città | Concetto presente nelle mappe gratis | 1 sola demo per città, 1-2 tappe | Tag + filtro |

## Piano di esecuzione (fasi)

### Fase 0 — Allineamento documenti ✅ in corso
Senza codice. Solo:
- Doc archiviato in `vault/raw/docs/piratopoly/`.
- Wiki di progetto Piratopoly aggiornato con link a questa pagina.
- Log vault.

### Fase 1 — Catalogo prodotti (Mini / Classica / Estesa / Pack)
**Obiettivo:** allineare il catalogo agli SKU del GDD prima di toccare subscriptions.

1. Migration DB: aggiungere `maps.tier ENUM('demo','mini','classic','extended')` + `maps.duration_hours` (24/48/72).
2. Backend `/maps/:id` ritorna `tier`, `priceCents`, `validityHours`.
3. Stripe: nuovi `price_id` per 5,99 / 11,99 / 14,99 / 24,99 (€ EUR, one-time per le mappe, recurring per il Pass).
4. UI `MapDetailPage`: mostra tier badge + validità + nuovo prezzo.
5. UI `MarketplacePage`: filtri opzionali per tier.
6. Pack Esploratore: schema `user_credits` (3 slots, scadenza 12 mesi). Checkout Pack genera record. Acquisto mappa Mini/Classica può scalare un credito.
7. Validità sessione: `game_sessions.expires_at = started_at + maps.duration_hours`. Countdown UI sulla pagina mappa.
8. Migration prezzi vecchi → nuovi (Stefano sceglie se sconto continuità per chi ha già acquistato prima).

**Stima:** 1.5–2 settimane.

### Fase 2 — Pirate Pass
1. Schema `subscriptions` (Stripe Subscription mirror): `user_id, status, tier ('monthly'|'yearly'), current_period_end, cancelled_at`.
2. Stripe Subscription flow: webhook `customer.subscription.*` → upsert.
3. Entitlement service: `user.hasPiratePass()` → bool + scadenza.
4. UI Pricing page (mensile / annuale).
5. Sconto -40% sulle Mappe Estese se `hasPiratePass()`.
6. Sconto annuale "ho appena comprato": calcolo automatico se ultima mappa singola ≤ 7 giorni → applica detrazione max(prezzo mappe acquistate).
7. Politica disdetta + rimborso pro-rata 14 giorni (cron job verifica).

**Stima:** 2–3 settimane.

### Fase 3 — Esplorazione Libera
1. Endpoint `POST /explore/draw` → AI propone 5–6 carte da `(city, mood, hour, user_tier)`.
2. Carta serendipity: prob 30%, payload con campi nascosti finché non selezionata.
3. UI: ContextPicker mood → CardDeck con drag & drop sequencing → Avvio.
4. Limiti tier: free 1/settimana max 3 tappe, Pass illimitato max 5 tappe.
5. Reset settimanale (cron lunedì 00:00 fuso utente).
6. Voucher attivi solo per Pass; per free locked + CTA upgrade.
7. Classifica Esploratori (tabella separata, mensile, accesso Pass-only).

**Stima:** 2–3 settimane.

### Fase 4 — Voucher avanzato + Gift + Referral
1. Voucher premium tag + filter UI.
2. Voucher di completamento (sblocco al `/complete`).
3. Gift checkout flag + email/QR + tabella `gift_redemptions`.
4. Referral: codice univoco per utente, deep link, anti-abuso (IP+device fingerprint), 10/mese cap, premio Mini per entrambi.

**Stima:** 1.5–2 settimane.

### Fase 5 — Stagionalità + City Champion + Badge
1. `maps.valid_from`, `maps.valid_to`, `maps.season_tag`. Blocco vendita 72h prima di `valid_to`.
2. Early access Pass: campo `pass_early_access_at`.
3. Cron mensile City Champion: per ogni città con ≥15 active users, prima posizione → +30gg Pass + badge permanente.
4. Badge collection (table `user_badges`) + UI profilo.

**Stima:** 1–1.5 settimane.

### Fase 1.5 / Fase 2 (rimandate)
- Bundle Coppia Pirata (post-Fase 5 / 1.5).
- Grande Mappa, Team Pass, B2B, multiplayer real-time, UGC editor: rimandati come da GDD.

## Dipendenze critiche
- **Stripe Subscriptions** prima di tutto il resto Pirate Pass (Fase 2 dipende da Stripe sandbox configurato).
- **Migration DB** per ogni Fase richiede SQL review (Stefano).
- **AI generation** per Esplorazione Libera (Fase 3): non runtime, va via offline pipeline (regola architetturale 2026-05-05).

## Decisioni aperte (da chiedere a Stefano prima di partire)
1. Migrazione utenti che hanno già acquistato a 7,99 €: sconto continuità o nessuna azione?
2. Stripe live già configurato per Mappa Singola? Riusare o creare nuovo prezzo?
3. Localizzazione: i prezzi sono in € fissi o multi-currency dal lancio?
4. Cap tappe Estesa: 8–10 fisso o range editoriale?
5. Trigger referral: "completa Demo o primo acquisto" — Demo basta da sola o serve acquisto reale?
6. Gift Pass annuale: chi paga il rinnovo dopo i 12 mesi (utente regalato o annullamento)?

## Prossimo step
Attesa OK Stefano per partire dalla **Fase 1 (Catalogo prodotti)**. Confermato il go, prima task tecnica:
migration DB + backfill `tier` sulle mappe esistenti.
