# Progetto — Modulo "Elimina Code" (Puntify)

> Fonte immutabile: [[raw/docs/puntify-elimina-code-spec|spec funzionale completa]] (inviata da Stefano 2026-06-30).
> Stato: **PIANIFICAZIONE** — nessuna implementazione avviata. La spec impone gate di conferma a ogni sezione.
> Brand: #B80000. Progetto: Puntify.

## Obiettivo
Modulo **elimina code indipendente** attivabile da qualsiasi esercente (>60 categorie), non legato a prenotazioni né loyalty ma **predisposto** a integrarsi con loyalty. Tre concetti distinti: **Coda** (contenitore), **Biglietto** (posto del cliente), **Chiamata** (avanzamento fila). Principio cardine: la **fila digitale è sempre la fonte di verità**; nessun componente fisico (display/totem/stampante) può bloccarla.

Scope v1 = QR in loco + remoto opzionale + totem software + operatori + display. **Senza** stampa fisica (solo predisposta).

---

## Analisi integrazione col sistema attuale (mappatura codebase 2026-06-30)

### ✅ Riusabile così com'è
- **Operatori**: `BookingOperator` → tabella `shop_operators` (Punto.Shared/Models/Booking/BookingModels.cs). UI esercente: `MerchantOperators.razor`, `ShopOperators.razor`. La spec impone di riusare questa entità.
- **Shop = punto vendita** + multi-PV: tabella `shops`; relazione N:N account↔shop via `account_shops`; ownership via `ShopAuthorizationService.RequireOwnerAsync`.
- **Push FCM**: `FirebaseNotificationService` + `NotificationHelper.NotifyOrderReadyAsync` (esatto pattern "tocca a te"); token in `notification_tokens` per `user_id`. Riferimento status→push: `TakeawayBoardController.cs`.
- **QR**: `TablesController` `GET …/qr.png` con QRCoder; pattern `qr_token` su `shop_operators`.
- **Email (Resend)** + **Telegram merchant notifier**: canali extra disponibili.
- **Linkage cliente**: `bookings.customer_id` → `account` → `userid` → push (precedente per il gancio loyalty latente, customer_id nullable = ospite).
- **Pattern DB**: schema `puntify`; template diretto = `menu_public_orders` (tabella standalone cliente anonimo, `shop_id` FK, status-machine, RLS anon-insert + merchant via join account_shops). Token pubblico no-auth = pattern `confirmation_token`.
- **Display + polling**: `CustomerDisplay.razor` / `KitchenDisplay.razor` / `Screens.razor` (Timer poll). Pattern pronto per il display coda.
- **Feature-flag**: bitfield `shops.enabled_features` (`ShopExtensions`, `ShopFeaturesController` PATCH).

### 🔧 Da estendere
- `enabled_features`: aggiungere **bit6 = queue (64)** + helper `HasQueue()` + tile in `MerchantHome.razor`/`PuntifyFeaturesTab.razor`.
- Nuova area `Pages/Merchant/Queue/` + tabella `queue_settings` (sul modello `booking_settings`).
- Display coda pubblico in `Screens.razor` (copia route+poll di `CustomerDisplay.razor`).
- Riuso logica "status→push" del takeaway per "biglietto chiamato→push".

### 🆕 Da costruire da zero (nodi principali)
1. **Tabelle ticket**: `queue_tickets`, `queue_counters` (+ `queues`/`queue_settings`), grants/RLS sul modello `menu_public_orders`.
2. **Realtime**: NON esiste (Supabase Realtime globalmente disattivato, niente SignalR). Oggi tutto **polling con Timer**. → vedi Decisione D1.
3. **Login operatore**: gli operatori OGGI NON hanno autenticazione (`shop_operators` non ha email/PIN/password: sono record passivi). La spec §13 richiede credenziali proprie + tracciabilità. → vedi Decisione D2. **Gap principale.**
4. **SMS e WhatsApp**: NON esistono (solo riferimenti in copy/consensi). Vanno integrati con un provider. → vedi Decisione D3.

---

## Decisioni tecniche da validare (GATE 0, prima di costruire)

**D1 — Realtime/concorrenza.** Proposta: mantenere **polling** (coerente con l'esistente) per pagina cliente e display; garantire la correttezza del "chiama il prossimo" con **operazione ATOMICA server-side** (RPC Postgres SECURITY DEFINER con `SELECT … FOR UPDATE SKIP LOCKED` o lock di riga sul counter). Così atomicità/no-doppia-chiamata/no-numero-saltato (spec §4,§15,§17) NON dipendono dal realtime. Supabase Realtime resta upgrade futuro per display più reattivi. → confermare.

**D2 — Login operatore.** Non esiste oggi. Opzioni:
- (a) **PIN per operatore** + sessione operatore leggera su dispositivo condiviso (tracciabilità + perimetro ridotto) — coerente con spec §13. *(consigliata)*
- (b) riuso sessione esercente (più semplice, meno tracciabilità).
→ scegliere a/b.

**D3 — SMS/WhatsApp.** Non esistono. Decisione di prodotto + costi:
- Proposta: **v1 con PUSH (gratis, già pronto) + Email**; SMS/WhatsApp come fase successiva una volta scelto il provider (es. Twilio per entrambi, o provider SMS IT + WhatsApp Business). Tracciamento messaggi per coda/esercente (modello a consumo, spec §6).
→ confermare v1 push+email; scegliere provider/budget per SMS/WhatsApp.

**D4 — Numerazione.** Reset **giornaliero** per coda (`queue_counters` con data) per evitare confusione tra numeri di ieri/oggi (spec §9).

---

## Piano a fasi (con gate di conferma tra una e l'altra)

- **GATE 0 — Fondamenta & decisioni**: validare D1–D4; definire schema tabelle (`queues`/`queue_settings`/`queue_tickets`/`queue_counters`), feature bit6, RLS. *(no codice prima dell'ok)*
- **Fase 1 — Coda base in loco**: config esercente (crea/gestisci code, apri/chiudi), biglietto via QR anonimo (device/session bound, anti-duplicazione), pagina cliente self-updating (polling), display in negozio, azioni chiamata ATOMICHE (chiama/richiama/salta/servito).
- **Fase 2 — Operatori**: login operatore (D2), assegnazione operatore↔coda (1:1, 1:N, N:1), vista ridotta operatore, concorrenza multi-operatore (atomicità + propagazione), tracciabilità "chi ha fatto cosa".
- **Fase 3 — No-show & avvisi**: stato richiamabile + decadenza + rientro in fondo; avvisi "manca poco"/"tocca a te"/"ti aspettiamo" via push (riuso FCM) + email; *(SMS/WhatsApp gated su D3)*.
- **Fase 4 — Remoto**: ingresso da remoto (se abilitato), quota massima remota, check-in via riscansione QR, equità remoto vs in-loco, decadenza no-check-in.
- **Fase 5 — Totem (chiosco)**: modalità chiosco bloccata (tasto "Prendi il numero" + QR), auto-reset, multi-totem (concorrenza), degrado offline elegante.
- **Fase 6 — Stima attesa**: tempo medio servizio **auto-aggiustante** sulla media reale + override manuale; stima per coda (non globale), presentata come approssimativa.
- **Fase 7 — Stampa fisica (v2, solo PREDISPOSTA in v1)**: hook "comando di stampa" no-op in v1; in v2 stampante termica 80mm, gestione guasti che non bloccano la fila, modello hardware/commerciale a pagamento per categorie poco digitali (CAF/ambulatori/uffici).

### Predisposizioni latenti (v1)
- **Loyalty hook**: `queue_tickets.customer_id` nullable (FK `account`), dormiente fino a popolamento (fast-track/punti futuri).
- **Stampa**: campo/evento "print command" emesso opzionalmente, no-op in v1.

### Cross-cutting (requisiti vincolanti)
- **Privacy** (spec §8): telefono raccolto solo per quell'avviso; MAI nome/telefono su display o biglietto cartaceo; cancellazione/anonimizzazione recapiti poco dopo il servizio (retention breve automatica); niente riuso marketing senza consenso separato; esercente = titolare.
- **Tracciabilità**: "chi ha fatto l'azione" ovunque (esercente/operatore/totem).
- **Robustezza**: degrado offline elegante (display/totem/cliente), riallineamento al ritorno rete, niente schermate d'errore al pubblico.
- **Brand**: #B80000 su display/totem/pagina cliente/biglietto.

---

## Domande aperte per Stefano (gate)
1. OK al piano a fasi + gate?
2. D2 login operatore: **PIN dedicato** (consigliato) o riuso sessione esercente?
3. D3 avvisi: OK **v1 push+email**, SMS/WhatsApp dopo scelta provider? Quale provider/budget?
4. D1 realtime: OK **polling + RPC atomico**, o vuoi Supabase Realtime subito?
5. Una sola coda per PV in v1 o subito multi-servizio?

## Prossimo passo
Attendo validazione GATE 0 (D1–D4 + domande). Solo dopo: schema tabelle + feature flag → Fase 1.

## Cross-link
- [[reference_puntify_db|Puntify DB & API access]] · [[project_puntify_admin|Area Admin]] · operatori/booking come riferimento entità.
