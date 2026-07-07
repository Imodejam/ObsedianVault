# Puntify — Architettura Clienti (identità condivisa + profilo segregato)

Data: 2026-07-07 · Decisione con Stefano (Telegram) nel contesto di Nemi Voce/Vapi + riconoscimento chiamante. Vedi [[puntify-nemi-voce-vapi]].
Stato: **APPROVATA** (Stefano msg 5489 "perfetto"). Da implementare.

## Problema
Riconoscere il chiamante (e associare le prenotazioni) usando un profilo cliente GLOBALE e condiviso tra esercenti causa: (1) contaminazione dati (un PV che corregge nome/email impatta gli altri esercenti); (2) problema privacy/GDPR — ogni esercente è **titolare del trattamento distinto**, non può condividere/editare un profilo comune.

## Decisione: DUE LIVELLI
### 1) IDENTITÀ (Puntify, condivisa, NON editabile dagli esercenti)
- Chiave = **numero di telefono normalizzato** (unico, dedup). Ancorata all'`account` Puntify esistente (`account.mobile_number` UNIQUE) per chi usa app/fedeltà.
- Serve SOLO a: riconoscere "questo numero = questa persona" ed evitare duplicati. Gli esercenti NON scrivono qui.

### 2) PROFILO CLIENTE (proprietà dell'esercente, SEGREGATO) — NUOVO
- **Nuova tabella** (es. `customer_profiles`): una scheda cliente per (owner, telefono) con nome, email, note, preferenze, storico rilevante — **editabile SOLO dal proprietario**.
- Modifica di un PV → cambia SOLO la sua scheda. Gli altri esercenti hanno la LORO scheda indipendente per lo stesso numero.
- Campi minimi: id, owner_type ('shop'|'account'), owner_id (shop_id o account_esercente), phone_norm, account_id (nullable, link identità globale), display_name, email, notes, created_at, updated_at. Unique (owner_type, owner_id, phone_norm).

## SCOPE (configurabile dal PV in /merchant/shop/{id}/edit)
Nuovo flag shop `customer_recognition_scope`:
- **"shop"** (default): il proprietario della scheda è il singolo PV → clienti isolati anche tra i PV dello stesso esercente.
- **"account"**: il proprietario è l'ESERCENTE (owner account) → scheda condivisa tra tutti i suoi PV (es. 5 PV), **mai** con altri esercenti.

## Riconoscimento (voce e non)
1. Arriva il numero (chiamata Vapi / prenotazione).
2. Normalizza telefono → cerca la scheda `customer_profiles` del proprietario secondo lo scope del PV (shop o account esercente).
3. Se esiste → riconosciuto: nome/dati dalla SUA scheda (Nemi saluta per nome, precompila).
4. Se non esiste → nuovo per questo esercente: si crea la propria scheda segregata (anche se il numero è cliente di ALTRI esercenti — quelli non si vedono).

## Privacy / GDPR
- Dati anagrafici segregati per esercente (nessun leak cross-esercente).
- Consenso GDPR prenotazioni VOCE: **consenso verbale registrato** nella trascrizione/registrazione della chiamata (NIENTE SMS, scelta Stefano). Email di conferma solo se il cliente fornisce l'email.
- Dedup garantito dal telefono (identità), senza condividere i profili.

## Mapping sull'esistente (riuso)
- Identità globale = `account` (mobile_number UNIQUE) — già c'è. Ricerca per telefono già in BookingServiceImpl. NON far editare i campi account dagli esercenti tramite il flusso merchant/voce.
- Legame storico `account_shops` + `bookings.customer_id` restano; il nuovo `customer_profiles` è il layer editabile/segregato per l'esercente.
- Config: nuovo campo su `shops` + toggle in ShopEdit.

## Da costruire
1. Migration `customer_profiles` (owner-scoped, unique per telefono) + campo `shops.customer_recognition_scope`.
2. Servizio riconoscimento scope-aware (cerca profilo per owner secondo scope).
3. UI toggle "Riconoscimento clienti" in ShopEdit (solo-questo-negozio / tutti-i-miei-negozi).
4. Aggancio nel flusso prenotazione (associa/crea profilo segregato) e nel riconoscimento voce Vapi.
5. Voce: nome+telefono obbligatori, email opzionale, GDPR verbale.

## FASE 1 — IMPLEMENTATA (2026-07-07, applicata su CAT/collaudo, NON prod, NON committato)
**Owner esercente (scope 'account'):** `account_shops` NON ha ruolo owner/cliente e accumula anche i clienti (il booking crea link role=1 via service_role) → nessun owner "pulito". Aggiunto **`shops.owner_account_id`** (FK account, ON DELETE SET NULL) materializzato dal legame `account_shops` più vecchio con account di ruolo esercente (2/3). Backfill migration: 58/58 shop CAT popolati (tutti role 3, 1 link/shop → owner netto). Fallback runtime nel service + degrado sicuro a scope 'shop' se non risolvibile.
- **Migration** `docs/DB Migrations/2026-07-07_customer_profiles.sql`: tabella `customer_profiles` (id, owner_type shop|account, owner_id, phone_norm, account_id FK null, display_name, email, notes, created_at, updated_at; UNIQUE(owner_type,owner_id,phone_norm); indici owner+phone e account). `shops.customer_recognition_scope text NOT NULL DEFAULT 'shop'` (check shop|account) + `shops.owner_account_id`. RLS ON su customer_profiles SENZA policy anon (PII) → solo service_role (BYPASSRLS) in FASE 1. Verificato: service_role R/W ok, anon read=0 e write DENIED, unique dedup DENIED.
- **Modelli C#:** `Punto.Shared/Models/CustomerProfile.cs`; su `Shop.cs` aggiunti `CustomerRecognitionScope` + `OwnerAccountId`.
- **Service:** `Puntify.Server/Services/Customers/CustomerProfileService.cs` (+ interface, DI in Program.cs). `ResolveOwnerAsync`, `FindByPhoneAsync` (riconoscimento, riusa NormalizePhone del booking), `UpsertAsync` idempotente (arricchisce solo campi vuoti, no clobber).
- **Aggancio prenotazione:** dentro `BookingServiceImpl.UpsertCustomerAccountAsync` (chokepoint di CreateBooking + EnsureCustomerForBooking), dopo il link account_shops, best-effort. `account` = identità globale; `customer_profiles` = layer editabile segregato.
- **UI:** ShopEdit.razor tab Anagrafica (sotto "Prenotazioni pubbliche"): select "Riconoscimento clienti" bindato a `_shop.CustomerRecognitionScope`, salvato con lo shop. i18n: 4 chiavi `shopedit_customer_scope*` in tutte le 10 resx.
- **Build:** Server + App = 0 errori. Server riavviato su :8001 (boot pulito).

## FASE 2 / follow-up (NON fatti)
- Refactor `Clients.razor`/`ShopCustomersController` su `customer_profiles` (+ policy RLS owner-scoped per anon quando servirà).
- Migrazione dati storici → customer_profiles. Tool voce Vapi (FindByPhone + Upsert).
- **DA APPLICARE IN PROD:** migration `2026-07-07_customer_profiles.sql` (identica; backfill owner_account_id gira in prod).

## B — GDPR prenotazioni a voce (spiegato a Stefano msg 5492)
Base giuridica = CONTRATTO/richiesta del cliente (Art. 6.1.b): per una prenotazione che il cliente chiede al telefono, nome+telefono sono leciti SENZA consenso esplicito (il consenso serve solo per extra tipo marketing).
Serve solo il DOVERE DI INFORMATIVA: Nemi pronuncia una mini-informativa ("dati usati solo per la prenotazione, informativa su puntify.it/privacy"). Prova = registrazione/trascrizione chiamata. NIENTE SMS, niente spunta.
Tecnicamente: booking a voce salvato con source=voce + gdpr "informativa a voce" + transcript; email conferma solo se il cliente la fornisce.
Testo esatto della frase informativa: da definire con Stefano (può sceglierlo lui). Applicato in FASE 2 (voce). (Nota: non validazione legale, approccio standard, Stefano può far validare al consulente.)

## FASE 1 FATTA (subagent a872f27432c35c569, 2026-07-07)
Migration 2026-07-07_customer_profiles.sql (customer_profiles: owner_type shop|account, owner_id, phone_norm, account_id, display_name/email/notes, UNIQUE(owner_type,owner_id,phone_norm); RLS ON no-anon=solo server; + shops.customer_recognition_scope default 'shop' + shops.owner_account_id backfillato 58/58 shop dal legame account_shops più vecchio role 2/3). Modello CustomerProfile + Shop.CustomerRecognitionScope/OwnerAccountId. CustomerProfileService (ResolveOwnerAsync/FindByPhoneAsync riconoscimento/UpsertAsync arricchisce solo campi vuoti). Aggancio in BookingServiceImpl.UpsertCustomerAccountAsync. UI toggle "Riconoscimento clienti" in ShopEdit anagrafica (4 chiavi ×10 lingue). Build ok, server :8001 riavviato. DA APPLICARE PROD: 2026-07-07_customer_profiles.sql.
FASE 2 IN CORSO (subagent ac58cade9ca028f58): 4+ tool voce (elenca_servizi/verifica_disponibilita/crea_prenotazione/trova_mie_prenotazioni/sposta/cancella) sull'assistant + handler tool-calls webhook + riconoscimento chiamante (FindByPhoneAsync, saluto per nome) + prenotazione voce (nome+telefono, email opz, source=voice, mini-informativa GDPR, profilo segregato). Riusa BookingServiceImpl.
PROD MIGRATIONS totali al deploy = 6: queue_remote_review_fixes, nemi_credits, nemi_context_reset, vapi_calls, webhook_events, customer_profiles.
