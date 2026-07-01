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

**D1 — Realtime/concorrenza.** ✅ DECISA (Stefano 2026-06-30): **A = polling ~2-3s** per pagina cliente e display + correttezza del "chiama il prossimo" con **operazione ATOMICA server-side** (RPC Postgres SECURITY DEFINER, `SELECT … FOR UPDATE SKIP LOCKED` sul counter). Mitigazioni carico (Stefano ha sollevato il tema "tanti client = tante richieste"): (1) **cache in memoria** dello stato coda → N client = 1 lettura DB ogni 1-2s per coda; (2) **ETag/304** quando nulla è cambiato; (3) **polling adattivo** (lontani 10-15s, vicini 2-3s). Upgrade futuro a SSE/Supabase Realtime senza cambiare l'endpoint.

**D2 — Login operatore.** ✅ DECISA (Stefano 2026-06-30): login **per operatore, PASSWORDLESS**. L'esercente, definendo l'operatore, imposta un'**email**; l'operatore fa login ricevendo un **codice di accesso via email** (OTP/magic-link), poi resta loggato tramite **cookie persistente** (stesso paradigma della login esercente Supabase magic-link). → `shop_operators` acquisisce un campo email + flusso auth passwordless dedicato operatore.

**D3 — Canali avvisi.** ✅ DECISA: **v1 SOLO EMAIL** (Resend, già pronto). **WhatsApp in FASE 2**. (SMS non richiesto per ora.)

**D4 — Multi-coda.** ✅ DECISA: **più code in parallelo native fin dalla v1** (stile ufficio postale/farmacia: "Sportello A", "Cassa", ecc.). Niente v1 mono-coda.

**D5 — Numerazione.** Reset **giornaliero** per coda (`queue_counters` con data) per evitare confusione tra numeri di ieri/oggi (spec §9).

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

## GATE 0 — ✅ COMPLETO (Stefano 2026-06-30)
D1 polling A + mitigazioni · D2 login operatore passwordless email+codice+cookie · D3 v1 solo email (WhatsApp fase2) · D4 multi-coda nativa · D5 numerazione giornaliera.

---

## Fase 1 — disegno tecnico (PROPOSTA, da validare prima di scrivere codice)

### Tabelle (schema `puntify`, RLS sul modello `menu_public_orders`)
- **`queues`** — una riga per coda (multi-coda nativo, D4). Campi: `id, shop_id (FK shops), name ("Sportello A"), is_multi_service, show_estimate, entry_mode (in_loco|remoto|entrambi, default in_loco), avg_service_minutes, avg_service_auto (bool), recall_window_seconds, remote_quota_pct, notify_email (bool), is_open (bool), auto_open_hours (jsonb), qr_token (univoco per QR coda), created_at, updated_at`.
- **`queue_tickets`** — il biglietto. `id, ticket_token (pubblico no-auth, pattern confirmation_token), queue_id (FK), shop_id, number (int, progressivo giornaliero coda), status (waiting|called|recallable|served|no_show|expired), source (qr_loco|remoto|totem), device_session (token device-bound, anti-dup), customer_id (nullable FK account — gancio loyalty latente), contact_email (nullable, per avviso), notify_consent (bool), checked_in (bool, per remoto), called_at, called_by_operator_id (FK shop_operators — tracciabilità), served_at, created_at, updated_at`. Index `(queue_id, status, number)`.
- **`queue_counters`** — contatore atomico per coda+giorno. `id, queue_id, service_date (date), last_number, last_called_number`. **Unique (queue_id, service_date)** → reset giornaliero (D5).
- **Login operatore** (D2): estendere `shop_operators` con `email` (nullable). Nuove: `operator_login_codes (operator_id, code, expires_at, used_at)` + sessione via cookie persistente (token in `operator_sessions` o JWT firmato). Flusso: esercente imposta email operatore → operatore apre pagina login → inserisce email → riceve codice via Resend → inserisce codice → cookie persistente lungo. Operatore disattivato → sessione invalidata subito.

### Operazione atomica "chiama il prossimo" (RPC Postgres SECURITY DEFINER)
`queue_call_next(queue_id, operator_id)`: lock riga `queue_counters` (FOR UPDATE) → prende il ticket `waiting` con `number` minimo (per remoto: solo `checked_in`) con `FOR UPDATE SKIP LOCKED` → setta `status=called, called_at, called_by` → aggiorna `last_called_number` → ritorna il ticket. Garantisce: due operatori/totem insieme → biglietti diversi, nessun numero saltato/doppio.

### Endpoint
- Pubblici (`api/public/queue/*`, no auth, ETag/304 + cache): `POST .../{queueToken}/ticket` (prendi biglietto, device_session, anti-dup); `GET .../ticket/{ticketToken}/status` (polling cliente); `GET .../{queueToken}/display` (display negozio).
- Esercente/operatore (auth): `POST .../call-next | recall | skip | serve` (atomici); CRUD code; assegnazione operatori.
- Login operatore: `POST .../operator/login/request {email}` → invia codice; `POST .../operator/login/verify {email, code}` → cookie sessione.

### Feature flag + UI
- `enabled_features` **bit6 = queue(64)** in `ShopExtensions` + `HasQueue()` + tile in `MerchantHome`/`PuntifyFeaturesTab` + toggle via `ShopFeaturesController`.
- `Pages/Merchant/Queue/`: lista/CRUD code, config coda, vista "opera coda" (chiama), assegnazione operatori.
- Display coda full-screen (`/merchant/{shop}/display/queue`) in `Screens.razor` (copia pattern `CustomerDisplay` + polling).
- Vista operatore ridotta (login + sole code assegnate + tasti chiamata).
- Pagina cliente pubblica del biglietto (polling adattivo).

### Cache/carico (mitigazioni D1)
Stato coda in cache memoria server (invalidata su ogni chiamata) → i poll dei client leggono dalla cache; ETag/304; polling adattivo per posizione.

## Prossimo passo
Presentare a Stefano la sintesi del disegno Fase 1 → su validazione, iniziare: (1) migration tabelle + feature bit6 (DB su CAT → segnalare per prod), (2) login operatore passwordless, (3) config code + biglietto QR in loco + display + chiamata atomica. Gate di conferma a fine Fase 1.

## Cross-link
- [[reference_puntify_db|Puntify DB & API access]] · [[project_puntify_admin|Area Admin]] · operatori/booking come riferimento entità.

## Fase 2 — Operatori (pianificata 2026-07-01)
Richiesta Stefano: integrare Elimina Code per gli OPERATORI. Operatore si logga → home con icona Elimina Code → sceglie una coda o tutte → pagina "opera" (chiama prossimo nella coda X o in ordine di arrivo tra le code).

### Gap analysis (da ricerca codice)
- Login/home/operate OPERATORE: NON esistono (solo tabelle DB predisposte: operator_login_codes, operator_sessions, shop_operators.email). Nessun codice C#.
- Operatori = booking-operator (shop_operators, type='operator'), riusabili (spec §11). Manca campo Email sul model BookingOperator.
- Manca tabella assegnazione operatore↔coda (queue_operators). Spec §12.
- queue_call_next è single-queue (WHERE queue_id, ORDER BY number). Manca RPC FIFO cross-coda (ORDER BY created_at). Spec §15 + richiesta Stefano.
- Feature flag HasQueue (bit 64) OK. MerchantHome tile pattern (L251, EliminaCode.webp) da rispecchiare per home operatore.
- Tutto owner-authed (X-API-Key + RequireOwnerAsync). Serve auth operatore separata (token da operator_sessions).

### Piano fasi
1. DB: queue_operators (assegnazione) + RPC queue_call_next_across (created_at, FOR UPDATE SKIP LOCKED).
2. Login operatore: server (OTP email + session token) + app (pagina login /operatore, auth state, sessione lunga).
3. Scheda operatore /operators: Email + assegnazione code + invia accesso.
4. Home operatore ridotta (solo code assegnate) + select coda/tutte + operate (reuse QueueOperate, single + across). i18n 10 lingue, responsive mobile+tablet (spec §14).

### Conferme in attesa da Stefano
① URL ingresso operatore (/operatore dedicato). ② Login email+codice, sessione lunga. ③ "Tutte" = FIFO per created_at.
