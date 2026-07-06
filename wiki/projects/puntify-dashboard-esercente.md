# Puntify — Dashboard Esercente ("Panoramica") stile Stripe

Data: 2026-07-06 · Richiesta di Stefano (Telegram msg 5391 + mockup)
Obiettivo: dashboard globale del punto vendita, full-screen, stile Stripe, con riepiloghi giorno/settimana/mese, tutto sotto controllo dell'esercente.

## Riferimento
Mockup Puntify "Panoramica": sidebar (Home/Panoramica/Prenotazioni/Ordini/Elimina Code/Fidelity/CRM/Menu Digitale/News AI/Impostazioni), selettore multi-punto-vendita, selettore periodo, 4 KPI con delta, grafico Andamento Ricavi, feed Attività recenti, card Nemi AI.

## Dati REALI disponibili (fonte: mappatura codebase)
- **Incassi**: `transactions` (source manual|stripe; `gross_paid_cents`, `net_merchant_cents`, `commission_cents`, `stripe_fee_cents`, `service_fee_cents`; `reason` 1=accredito/2=addebito; `insertdate`, `shopid`, `accountid`, `categoryserviceid`). → fatturato lordo/netto, ticket medio, fee, online vs in-loco, revenue per servizio.
- **Ordini** (asporto/tavolo): `bookings` (kind=takeaway/table; `total_price`, `status`, `preparation_status`, `payment_status`, `start_at`) + `menu_public_orders` (`total`, `status`, `order_mode`, `items` JSONB). + righe `booking_order_items`.
- **Prenotazioni**: `bookings` (`participants`=coperti, `status`, `channel`, `service_id`, `operator_id`, no-show). Fetch range: `BookingApiService.GetAgendaAsync(slug, from, to)`.
- **Coda**: `queue_tickets` (`status`, `source`, timestamp `created_at`/`called_at`/`served_at`/`no_show_at`). → biglietti/gg, serviti vs no-show, tempo medio attesa (called-created) e servizio (served-called), remoto vs in-loco.
- **Recensioni**: `reviews` (`rating_shop`/`operator`/`ambiente`/`pulizia`/`staff`, `comment`, `created_at`). → media, conteggio, distribuzione stelle, trend, per-operatore.
- **Fedeltà**: `transactions.points` + `rewards` + `account_reward` (riscatti) + `receipt_point_requests` (scontrini). → punti emessi/spesi, premi riscattati, livelli VIP/Regular/Occasional, clienti attivi/nuovi/inattivi.
- **Menu**: piatti più venduti da `booking_order_items`/`menu_public_orders.items`.
- **Multi-shop**: `shops` ↔ `account_shops`; selettore in `Shops.razor`. Ogni pagina scoped `{ShopId:guid}`. Vista aggregata multi-shop NON esiste ancora.

## Base già esistente da RIUSARE
- `Puntify.App/Pages/Merchant/Insights.razor` — dashboard analitica MA solo su `transactions`. Classi modello (Metrics/Alert/ChartPoint/ServiceStats/TimeSlotStats/DayStats/CustomerState/LoyaltyLevels/Comparison), logica `FilterByPeriod` (today vs ieri / week vs 7gg prima / month vs 30gg prima con diff), alert automatici.
- CSS componenti Stripe-like già presenti (`config.css`/`app.css`): `.cfg-stat-card/.cfg-stat-value/.cfg-stat-diff.positive|negative` (numero grande + delta), `.cfg-chip` (period selector), `.cfg-card`, `.simple-chart` (barre CSS).
- Layout `.cfg-page/.cfg-header/.cfg-main`.

## Struttura proposta (full-screen)
1. **Topbar**: titolo "Panoramica" + sottotitolo, **selettore punto vendita** (singolo shop o "Tutti i punti vendita"), **selettore periodo** (Oggi / Settimana / Mese / range custom), export.
2. **Riga KPI** (numero grande + delta vs periodo precedente): Fatturato (netto esercente, con toggle lordo), Ordini, Prenotazioni, Coperti, Clienti fidelizzati, Recensioni (media). Config: l'esercente sceglie quali KPI mostrare.
3. **Andamento Ricavi** (grafico principale, area/line): per fascia oraria (Oggi) o per giorno (Settimana/Mese), split online vs in-loco.
4. **Breakdown a griglia** (card per feature, ognuna gated sulle feature attive del negozio):
   - Ordini: numero+valore per stato, per fascia oraria; ticket medio.
   - Prenotazioni: numero, coperti, no-show %, per canale/servizio/operatore.
   - Coda: biglietti, serviti/no-show, tempo medio attesa e servizio.
   - Recensioni: media + distribuzione stelle + ultime.
   - Fedeltà: punti emessi/spesi, premi riscattati, livelli VIP/Regular/Occasional, clienti attivi/nuovi/inattivi.
   - Top piatti/servizi.
5. **Attività recenti** (feed eventi: nuovo ordine, prenotazione, recensione, riscatto premio, cliente VIP).
6. **Card Nemi AI** (assistente + insight automatici/alert già in Insights).

## Controllo esercente
- Filtri periodo + shop; scelta KPI/card visibili; export CSV/PDF; drill-down da ogni card alla pagina dedicata; rispetto `Shop.Timezone` per i bucket.

## Decisioni tecniche da validare con Stefano
1. **Grafici**: oggi nessuna libreria (solo barre CSS). Per qualità "Stripe" servono line/area con tooltip/sparkline → (A) SVG custom senza dipendenze (consigliato: zero peso, controllo totale) vs (B) libreria JS (ApexCharts, resa più ricca ma dipendenza + service worker WASM). 
2. **Aggregazione**: oggi client-side (scarica tutto + in-memory). Per scalare → endpoint/RPC server con GROUP BY/sum (non esistono). MVP: client-side riusando Insights; poi RPC.
3. **Multi-shop aggregato**: la vista "Tutti i punti vendita" non esiste → più lavoro. Partire single-shop e aggiungere aggregato dopo, o farlo subito?
4. **Fatturato**: mostrare netto esercente (`net_merchant_cents`) come default, con toggle lordo.
5. **Timezone**: correggere i bucket orari/giornalieri su `Shop.Timezone` (oggi UTC).

## Calcolo "Andamento Ricavi" (spiegato a Stefano 2026-07-06, msg 5403)
- Fonte: `transactions` con reason=1 (incassi); importo = `net_merchant_cents ?? amount` (÷100 €).
- Bucket nel FUSO del negozio: Oggi=12 barre da 2h (ora_locale/2), Settimana=7 gg, Mese=30 gg; InsertDate UTC→locale prima del bucket.
- Aggregato multi-PV: ogni negozio bucketizza nel proprio fuso, somma per indice (allineati per ora-del-giorno e giorni-fa); etichette asse = fuso negozio d'ingresso.
- ⚠️ LIMITE/scelta aperta: i ricavi sommano SOLO le `transactions` registrate (Stripe/manuali). Ordini menu online o bookings con total_price che NON generano una transaction NON entrano nei ricavi (compaiono in Ordini/Prenotazioni ma non nel grafico). Se Stefano vuole ricavi = valore ordini/prenotazioni, è una decisione da prendere.

## Richieste 2026-07-06 (13:00) — filtro multi-PV + sezione Chiamate/Richieste AI
- **Filtro PV multi-selezione con ricerca** FATTO (subagent a3ebef9424307e252): token input (chip+ricerca typeahead su GetShopperShops), _selectedShopIds pilota ScopeShops→ActiveBundles (0=tutti,1=singolo,≥2=confronto); confronto ≥2 = card "Per punto vendita" con barre ApexCharts + righe; _multiScope; loader+cache SemaphoreSlim(3). 2 chiavi i18n ×10. Build ok, app riavviata su collaudo.
- **Sezione "Chiamate e richieste AI"** — dati (da esplorazione a7b0cf2e):
  - RICHIESTE AI: dati VERI in `nemi_chat_history` (shop_id, role, content, created_at) via GET /api/shop/{shopId}/ai/nemi/history. Conta role='user' per periodo/shop. LIMITE: nessuna colonna `channel` → chat web e Telegram indistinguibili (serve aggiungere channel + taggare al write in NemiChatService/TelegramNemiRouter).
  - CHIAMATE NEMI VOCE: ❌ NESSUN DATO. Nemi Voce = solo marketing vetrina (Nemi.razor/FAQ), nessuna integrazione telefonia né call_logs. enabled_features bit2=nemi copre solo l'assistente conversazionale. Non costruibile su dati veri finché non si fa il tracciamento chiamate.
  - Token/costi AI: non tracciati.
  - FATTO (subagent a3ebef9424307e252, 2026-07-06): sezione "Chiamate e richieste AI" (griglia cfg-grid-2 dopo breakdown). Box Chiamate = placeholder "In arrivo" (no dati finti). Box Richieste AI = conteggio role='user' in nemi_chat_history nel periodo (via SocialStudioApiService.NemiHistoryAsync→ShopAiController /ai/nemi/history), sommato su ActiveBundles, KPI+delta+mini-trend barre, nota "(chat+Telegram)", gating HasNemi, integrato in ShopBundle+cache. 7 chiavi ×10 lingue. Build ok, app riavviata. LIMITE: history scaricata intera+filtro client (TODO conteggio server-side). Split chat/Telegram = TODO (serve campo channel).

## Decisioni Stefano (2026-07-06)
1. Grafici: **libreria esterna gratuita** → ApexCharts (belli/dinamici).
2. Multi-punto vendita aggregato: **DOPO** (Stefano: "facciamolo dopo ma ricordatelo di farlo"). ⟶ **TODO DA RICORDARE**.
3. MVP riusando Insights: **sì**.

## ⚠️ TODO
- ~~Vista aggregata "Tutti i punti vendita"~~ → **FATTA** (2026-07-06): selettore cfg-select (compare se >1 negozio), scope client-side `all` con ShopBundle per-negozio + SemaphoreSlim(3) + cache; KPI sommati (clienti fidelizzati distinct cross-shop), grafico con timezone per-negozio, card gating OR, feed con nome negozio, card "Per punto vendita" per fatturato. Negozio singolo → NavigateToRoute forceLoad.
- **Full-screen FATTO** (2026-07-06): `.panoramica-fullscreen` scoped, override max-width cfg-header/main → width 100% + padding clamp; breakdown 3 col ≥1400px; mobile stack.
- **RESTA**: aggregazioni server-side (RPC/GROUP BY) per volumi grandi (ora tutto client-side, N negozi × query nel browser).

## Stato
- MVP FATTA (subagent a3ebef9424307e252, 2026-07-06). File: `Puntify.App/Pages/Merchant/Panoramica.razor` (route `/merchant/{ShopId:guid}/panoramica`), `wwwroot/js/apexcharts.min.js` (self-host v5.16.0, 621KB) + `wwwroot/js/charts.js` (interop puntifyCharts.renderArea/renderBar/renderDonut), index.html (2 script), SupabaseService.GetShopReviews, MerchantHome icona "Panoramica", +45 chiavi pan_* × 10 lingue. Riusa Insights (FilterByPeriod, livelli, alert) + cfg-*. Timezone via TimeZoneHelper. Build 0 errori. NON committato/deployato.
- Base href app = `/` → gli asset js si servono da `/js/...` (apexcharts 200). Panoramica dietro login esercente → niente screenshot headless, la apre Stefano (Ctrl+F5).
- Fonti: Fatturato=net_merchant_cents transactions reason1; Ordini=menu_public_orders; Prenotazioni/Coperti/no-show=bookings GetAgendaAsync; Coda=GetTicketsAsync tempi; Recensioni=reviews.rating_shop; Fedeltà=transactions+account_reward.
- VALIDAZIONE Stefano APPLICATA (2026-07-06): ① Ordini = online+asporto sommati MA distinti (KPI "Online X · Asporto Y", card 2 righe; takeaway rimosso da Prenotazioni); ② livelli fedeltà sempre ultimi 30gg (label "(ultimi 30 giorni)"), punti/premi restano sul periodo; ③ icona invariata. Build ok, app riavviata su collaudo. 4 chiavi pan_* nuove ×10 lingue.
- Come aprire: app esercente → Ctrl+F5 → Home → icona Panoramica, o /merchant/{id}/panoramica con negozio che ha dati reali.
