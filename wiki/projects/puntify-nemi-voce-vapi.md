# Puntify — Nemi Voce via Vapi (tracciamento chiamate + scalo minuti)

Data: 2026-07-07 · Richiesta Stefano (Telegram msg 5434): funzione chiamata da Vapi a fine chiamata per tracciare tutto (inclusi minuti) e scalare sul negozio; chiave per riconoscere il PV + api key. Ha chiesto di valutare un modo migliore prima di sviluppare.

## Contesto
Nemi Voce (telefonia) finora è solo marketing (no backend). Vapi = piattaforma voice AI che gestirebbe le telefonate. Serve integrare Vapi → Puntify per tracciare chiamate e consumare minuti dal saldo del negozio (riusa `shop_nemi_credits` creata il 2026-07-06). Fa diventare REALI: "Consumato" del tab Utilizzo AssistantAI + box "Chiamate Nemi Voce" della dashboard Panoramica (oggi placeholder).

## Architettura PROPOSTA (migliore della visione letterale)
1. **Webhook Server URL** (non "funzione che Vapi chiama"): Vapi a fine chiamata invia `end-of-call-report` al nostro endpoint (POST /api/vapi/webhook). Pattern nativo, con retry, contiene durata/minuti, costo, endedReason, transcript, recording. (Vapi manda anche status-update, tool-calls, assistant-request, transcript, ecc.)
2. **Auth = unico segreto condiviso Vapi↔Puntify** (header `X-Vapi-Secret` / Bearer, configurato nel Server URL di Vapi), verificato server-side. NON api key per-negozio.
3. **Identificazione PV via metadata/mapping**: shop_id nei `metadata` della chiamata/assistant Vapi, oppure mapping assistantId/phoneNumberId → shop nel DB (tabella `shop_vapi_config`). Il webhook lo restituisce → shop noto lato server, non spoofabile. Il negozio non maneggia chiavi.
4. **A fine chiamata**: idempotente per id chiamata Vapi (retry non scalano 2 volte) → log in tabella `nemi_calls` (shop_id, vapi_call_id, direction, duration, ended_reason, cost, started/ended, transcript ref) + decremento minuti atomico su `shop_nemi_credits.consumed_minutes` (RPC).
5. **Depletion**: quando il negozio esaurisce i minuti, bloccare le chiamate successive (pre-call check via assistant-request, o disattivare il numero).

## Perché è meglio della visione letterale di Stefano
- Webhook > funzione custom: nativo, affidabile, retry, payload completo.
- 1 segreto condiviso > api key + chiave per-PV: meno segreti, più sicuro, nessun attrito lato negozio.
- metadata/mapping > chiave fornita dal negozio: server-side, non spoofabile.
- Riusa shop_nemi_credits + riempie i placeholder Consumo/Chiamate con dati REALI.

## Decisioni/serve da Stefano (build-phase)
- Account Vapi.
- Provisioning: un assistant/numero Vapi PER negozio (consigliato, shop_id nei metadata, serve anche per routing inbound) vs uno condiviso con metadata per-chiamata.
- Arrotondamento minuti (per chiamata al minuto superiore? consigliato) e tariffa (coerente coi pacchetti Nemi: R1 0,36 → R4 0,29 €/min).
- Cosa loggare per chiamata (durata, inbound/outbound, esito, ora, costo, transcript).

## Decisioni CONFERMATE Stefano (2026-07-07 msg 5436)
- 1 numero per negozio (shop_id nei metadata + mapping numero→negozio).
- Minuti arrotondati al minuto SUPERIORE (ceil).
- Salvare TUTTO della chiamata (durata, esito, ora, costo, registrazione) + TRASCRIZIONE in nemi_calls.
- BLOCCO guidato dal credito PUNTIFY (non Vapi): via evento `assistant-request` (Vapi chiede prima di rispondere quale assistant usare) → il nostro server trova il negozio dal numero, legge saldo shop_nemi_credits:
  · saldo>0 → ritorna config Nemi Voce + `maxDurationSeconds = minuti_residui×60` (la chiamata non sfora il credito, Vapi chiude da sola).
  · saldo≤0 → non serve: messaggio breve "credito esaurito, ricarica" + hangup (o reject).
  · Rete di sicurezza: a fine chiamata se saldo=0, staccare assistant dal numero via API Vapi; riattaccarlo alla ricarica.

## Cosa costruisco (lato Puntify)
Endpoint webhook: `assistant-request` (gating saldo + maxDuration) + `end-of-call-report` (traccia+scala minuti idempotente per vapi_call_id). Tabelle `nemi_calls` + `shop_vapi_config` (numero/assistant→shop). Verifica saldo, scalo consumed_minutes (ceil), auth X-Vapi-Secret.
## Cosa serve lato Vapi (Stefano/insieme)
Account Vapi, numeri per negozio, Server URL + segreto condiviso sugli assistant, shop_id nei metadata.

## Stato
- Meccanismo blocco spiegato + design confermato (msg 5437). Attendo "parti" di Stefano per costruire la parte Puntify; per il collegamento reale servirà accesso/segreto Vapi.
- Fonti Vapi: docs.vapi.ai/server-url/events, /server-url/server-authentication.

## 2026-07-07 (10:47) — APPROVATO, build parte Puntify in corso
Stefano "sì mi torna" + requisito: nella assistant-request fornire all'assistant Vapi la KB + info negozio (orari apertura/chiusura, indirizzo, telefono, servizi) nel system prompt.
IN COSTRUZIONE (subagent a22a659b9e01cc507): migration 2026-07-07_vapi_calls (shop_vapi_config numero/assistant→shop, nemi_calls con transcript+raw jsonb, RPC atomica nemi_consume_minutes) + modelli C# + VapiWebhookController POST /api/vapi/webhook (auth X-Vapi-Secret da config, dispatch assistant-request[gating saldo+maxDuration+config dinamica con BuildVoiceContext KB+orari+info]/end-of-call-report[idempotente per vapi_call_id, scala ceil minuti]). Placeholder segreto Vapi in appsettings. Endpoint PUBBLICO → esposizione Caddy in deploy (prod, con Stefano). Follow-up: Chiamate dashboard + Consumo tab da nemi_calls/consumed reali.
DA STEFANO (collegamento reale): account Vapi, numeri per negozio, Server URL+segreto sugli assistant, shop_id nei metadata.

## 2026-07-07 — BACKEND PUNTIFY FATTO (subagent a22a659b9e01cc507)
File: migration 2026-07-07_vapi_calls.sql (shop_vapi_config con unique su vapi_phone_number_id/phone_number; nemi_calls vapi_call_id UNIQUE + raw jsonb + transcript; RPC nemi_consume_minutes SECURITY DEFINER upsert atomico, grant service_role; RLS come shop_nemi_credits) APPLICATA collaudo+RPC testata. Modelli ShopVapiConfig/NemiCall. VapiWebhookController POST /api/vapi/webhook (X-Vapi-Secret time-constant, 503 se non config/401 se errato; ApiKeyAuthMiddleware bypassa /api/vapi). assistant-request: shop da phoneNumber.id/number, saldo purchased-consumed → serve {assistant transient model/voice + maxDurationSeconds=residuo×60 + server.url+secret + metadata.shopId + system prompt BuildVoiceContextAsync} o blocca {error parlato}. end-of-call-report: idempotente call.id, salva nemi_calls raw+transcript, nemi_consume_minutes(ceil sec/60). BuildVoiceContextAsync = KB(_kb.GetAsync)+info shops(businessname/address/phone/email/website/description/opening_hours)+shop_services attivi; persona Nemi femminile telefonica.
GOTCHA: shops.opening_hours = TESTO LIBERO non per-giorno (proposto a Stefano campo strutturato se serve). appsettings Vapi:WebhookSecret=PLACEHOLDER (da riempire), ServerUrl=https://cat.puntify.it/api/vapi/webhook, model openai/gpt-4o-mini, voice azure/it-IT-ElsaNeural.
DA FARE: segreto Vapi reale + popolare shop_vapi_config + esporre endpoint via Caddy (prod). Build 0 errori. NON committato. PROD migration +1: 2026-07-07_vapi_calls.sql.

## 2026-07-07 (11:00) — orari STRUTTURATI per Nemi Voce (Stefano)
Correzione: gli orari NON sono solo shops.opening_hours testo libero. Fonti strutturate reali (pagina /merchant/shop/{id}/edit/orari|chiusure|blocchi, componente BookingSchedule):
- `booking_availability` (BookingAvailability): shop_id, service_id null=shop-level, day_of_week 0=Dom..6=Sab, start_time, end_time → orari settimanali.
- `booking_exceptions` (BookingException): chiusure/ferie/aperture straordinarie.
- `booking_manual_blocks` (BookingManualBlock): shop_id, start_at, end_at, reason → blocchi.
TODO (dopo subagent webhook admin, per non sovrappormi sul server): aggiornare NemiChatService.BuildVoiceContextAsync per includere orari settimanali per giorno + chiusure future + blocchi futuri (livello shop, service_id null), al posto/oltre opening_hours testo libero. Così Nemi Voce risponde a "siete aperti?/a che ora chiudete?/aperti sabato?/chiusi per ferie?".

## 2026-07-07 (11:04) — chiavi mancanti + numero Nemi in sezione PV
CHIAVI/CONFIG MANCANTI (risposta a Stefano): (1) Vapi:WebhookSecret reale (ora placeholder); (2) shop_vapi_config per negozio: numero Nemi + vapi_phone_number_id + vapi_assistant_id; (3) esporre /api/vapi/webhook via Caddy (deploy). Lato Vapi: (4) account+numeri; (5) su assistant/numero Server URL+Secret+metadata shopId; (6) chiavi LLM/voce le gestisce Vapi. Unici segreti veri da procurare = Stefano (segreto webhook + account Vapi).
TODO IN CODA (dopo subagent webhook admin a141bd78365fcf8af, bundle unico per serializzare edit server):
1. NemiChatService.BuildVoiceContextAsync → usare orari STRUTTURATI (booking_availability shop-level per giorno) + chiusure future (booking_exceptions) + blocchi futuri (booking_manual_blocks), non solo opening_hours testo.
2. Campo "Numero Nemi Voce" DEDICATO nella sezione punto vendita (ShopEdit.razor), distinto da Shop.Phone, salvato in shop_vapi_config (+ endpoint load/save). Configurabile lì.

## 2026-07-07 (13:52) — chiavi Vapi richieste a Stefano
Serve da Stefano: (1) VAPI PRIVATE API KEY (dashboard Vapi→API Keys→Private) per chiamate server→Vapi (provisioning numeri/assistant, attach/detach a saldo 0, dettagli chiamata) → SOLO config server, mai app WASM; (3) per ogni negozio phoneNumberId+assistantId+numero (recuperabili via API key). (2) Segreto webhook condiviso GENERATO da me (valore inviato a Stefano in DM Telegram msg 5457, NON salvato nel vault per sicurezza) → va su Vapi come Server URL Secret (X-Vapi-Secret) + in Vapi:WebhookSecret server. Server URL: https://cat.puntify.it/api/vapi/webhook. Attendo API key per accendere Nemi Voce su negozio test.

## 2026-07-07 (14:33) — segreto impostato + test setup + telegram fine chiamata
Vapi:WebhookSecret impostato in Puntify.Server/appsettings.Development.json (GITIGNORED, ok) = pe_akg... (valore in DM Telegram; in PROD va messo nell'env/appsettings prod). Verificato: webhook 200 col secret vero, 401 senza. Seed 60 min test su shop_nemi_credits per shop a88d9724 (negozio orari). Opzione 1 saldo-0 (chiusura silenziosa error vuoto) + guard wasRejected (no scalo minuti sui rifiuti) applicati in VapiWebhookController.
CONFIG VAPI data a Stefano (msg 5476): numero senza assistant fisso + Server URL https://cat.puntify.it/api/vapi/webhook + Secret + mettere il numero Vapi in anagrafica shop (campo Numero Nemi Voce). metadata shopId lo impostiamo noi.
TELEGRAM fine chiamata (Stefano 5471/5474/5475): IN COSTRUZIONE (subagent ac9546db9b19ceaf4). A fine end-of-call-report → NemiTelegramBot.SendMessageAsync alle Telegram:ChatIds (chat super-admin Stefano 505161324), messaggio sintetico (negozio/esito/durata/minuti/motivo). Pallino ambiente su TUTTI i messaggi bot: WithEnvBadge → 🟠 collaudo / 🔴 prod. Fail-safe. TODO: invio anche all'esercente in futuro. Config Telegram:NemiBotToken (bot @puntifynemibot).

## 2026-07-07 (14:40) — notifica Telegram fine chiamata FATTA + testata
Subagent ac9546db9b19ceaf4: VapiWebhookController inietta INemiTelegramBot; a fine end-of-call-report (dopo insert+scalo) NotifyAdminEndOfCallSafe invia via NemiTelegramBot.SendMessageAsync a ogni Telegram:ChatIds (chat super-admin), msg "📞 Chiamata Nemi Voce" (negozio/esito servita-vs-rifiutata/durata/minuti/motivo/transcript 200char), fail-safe try/catch. Pallino ambiente GIÀ ok in NemiTelegramBot.WithEnvBadge (🔴 prod / 🟠 non-prod) su tutti i messaggi. Build ok. Server riavviato.
TEST DAL VIVO: POST finto end-of-call-report (shop a88d9724, 45s) → 200, nemi_calls inserita (1 min), consumed 60→1, telegram inviato senza errori. Cleanup fatto (nemi_calls test rimossa, consumed→0, shop di nuovo 60 min pieni). Chiesto a Stefano conferma ricezione.
Server URL Secret spiegato (msg 5478): NON bearer, è X-Vapi-Secret header; il webhook accetta sia X-Vapi-Secret sia Authorization Bearer.
DEPLOY PROD nota: Vapi:WebhookSecret va messo anche in env/appsettings prod. Telegram bot token stesso per gli ambienti (badge cambia da IsProduction).

## 2026-07-07 (14:46) — Nemi Voce gestisce prenotazioni (Vapi tool-calls)
Stefano: l'assistant Vapi deve poter invocare webhook per gestire una prenotazione presso lo shop. Meccanismo: tool/function sull'assistant (nella risposta assistant-request) → LLM li invoca → Vapi manda evento tool-calls al nostro webhook → eseguiamo booking sullo shop → rispondiamo. Oggi il webhook fa no-op su tool-calls (da implementare handler).
Explore aa7297d30e76fc1fc in corso: creazione prenotazione server (endpoint/RPC, campi, guest nome+telefono), disponibilità slot, servizi (shop_services), modifica/cancella, flusso pubblico vetrina da riusare.
SCOPE proposto a Stefano: MVP tool 1) elenca_servizi 2) verifica_disponibilità 3) crea_prenotazione (guest nome+telefono); poi 4) sposta/cancella. Chiesto conferma scope + ok guest. Attendo.

## Mappatura prenotazioni (Explore aa7297d30e76fc1fc) — ENDPOINT PUBBLICI RIUSABILI
Tutto già esposto in PublicBookingController (rate-limited public_api), usa merchantSlug (da shopId risolvere slug o chiamare BookingServiceImpl diretto):
- GET /api/public/merchants/{slug} (info shop, timezone, minAdvance/maxFuture)
- GET /api/public/merchants/{slug}/services (shop_services attivi: nome/durata/prezzo)
- GET /api/public/merchants/{slug}/availability?serviceId&from&to (SlotEngine: booking_availability+exceptions+manual_blocks+bookings+booking_settings)
- POST /api/public/bookings (guest: merchantSlug/serviceId/startAt/customerName/customerPhone/customerEmail/gdprConsent; ritorna confirmation_token)
- DELETE /api/public/bookings/{token} (cancella, entro cancel_before_hours)
- PATCH /api/public/bookings/{token} {newStartAt} (sposta)
GOTCHA VOCE: POST richiede email+gdprConsent obbligatori → scomodo a voce. Proposto a Stefano: voce = nome+telefono obbligatori, email opzionale, GDPR via consenso verbale in transcript + SMS/link conferma. Attendo ok approccio + scope tool (1-2-3 poi 4).
BUILD (dopo ok): tool sull'assistant (assistant-request response, campo tools/functions Vapi) + handler evento tool-calls in VapiWebhookController (oggi no-op) che esegue via BookingServiceImpl/endpoint e risponde a Vapi. Risolve shop da metadata.shopId.

## 2026-07-07 (14:53) — scope tool CONFERMATO (1-2-3-4) + visione riconoscimento clienti
Stefano conferma tutti e 4 i tool. + Visione clienti: (a) riconoscere chiamante per telefono dalla assistant-request; (b) registro CLIENTI GLOBALE Puntify (cross-shop, per telefono) + cliente per-shop/account; (c) scope configurabile dal PV: "livello Account" (riconosciuto su tutti i PV dello stesso esercente, es. 5 PV) vs "solo questo PV"; (d) alla prenotazione associare al cliente o creare utenza dedicata allo shop.
Config scope: pagina /merchant/shop/{id}/edit.
Explore modello clienti a88e7cc135ed60c00 in corso (account globale, account_shops, ricerca per telefono, bookings.customer_id, owner vs cliente, config shop). Poi PROPONGO design clienti+scope PRIMA di toccare schema (privacy cross-shop).
Email/GDPR voce ancora da confermare (proposto: nome+telefono obbligatori, email opzionale, GDPR verbale+SMS/link).
PIANO: (1) design clienti+scope+email/GDPR da validare; (2) build 4 tool voce; (3) innesto riconoscimento. Evito rework: costruisco dopo l'ok sul design.

## Modello clienti (Explore a88e7cc135ed60c00) + DESIGN proposto
ESISTE: account (mobile_number UNIQUE=no dupes telefono, role 1=client/2=shopper/3=both), account_shops (account↔shop join, no owner/customer role), BookingServiceImpl.UpsertCustomerAccountAsync/EnsureCustomerForBookingAsync (cerca email→phone→crea guest role=1→link account_shops, idempotente), ricerca phone server-side (BookingServiceImpl:568 mobile_number=eq role in 1,3), ShopCustomersController search per-shop, NormalizePhone. MANCA: campo customer_recognition_scope su shop, logica condizionale shop-vs-account, UI toggle ShopEdit.
DESIGN proposto a Stefano (msg 5486): global=account, per-shop=account_shops, nuovo flag shop customer_recognition_scope ("shop" default | "account"=cross-PV dello stesso esercente); riconoscimento voce per telefono nello scope; privacy=cliente di altri esercenti non riconosciuto qui; dedup via telefono unico; l'"utenza dedicata shop"=guest account+account_shops già gestito. Chiesto ok design + ok email/GDPR voce (nome+tel obbligatori, email opz, consenso verbale+SMS). Poi build: schema+scope+UI + 4 tool voce + riconoscimento.

## 2026-07-07 (15:19) — Stefano OK design ma SEGREGAZIONE clienti (privacy)
Stefano (A): giusto rilievo — profilo globale condiviso = un PV che modifica anagrafica impatterebbe altri esercenti (contaminazione + GDPR: ogni esercente = titolare distinto). Vuole SEGREGARE.
DESIGN RIVISTO proposto (msg 5488): due livelli.
- IDENTITÀ (Puntify, condivisa, NON editabile da esercenti): solo TELEFONO come chiave dedup/riconoscimento (legata ad account per app/fedeltà).
- PROFILO CLIENTE (proprietà esercente, SEGREGATO): NUOVA tabella scheda-cliente-per-esercente/PV (nome/email/note/storico), editabile solo da quell'esercente. Modifica di un PV NON impatta altri.
- SCOPE decide proprietario scheda: "solo questo negozio"=owner shop; "tutti i miei negozi"=owner account esercente (condivisa tra i suoi PV, mai con altri esercenti).
- Dedup via telefono; cliente di altri esercenti = "nuovo" qui (si crea la propria scheda).
Serve NUOVA tabella profilo cliente segregato. Chiesto conferma modello segregato.
(B) riformulato: prenotazioni VOCE = nome+telefono obbligatori, email facoltativa, GDPR verbale(transcript)+SMS/link. Chiesto ok.
ATTENDO conferma A(segregato) + B prima di build.
