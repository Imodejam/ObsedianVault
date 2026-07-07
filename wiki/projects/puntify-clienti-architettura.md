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

## B — GDPR prenotazioni a voce (spiegato a Stefano msg 5492)
Base giuridica = CONTRATTO/richiesta del cliente (Art. 6.1.b): per una prenotazione che il cliente chiede al telefono, nome+telefono sono leciti SENZA consenso esplicito (il consenso serve solo per extra tipo marketing).
Serve solo il DOVERE DI INFORMATIVA: Nemi pronuncia una mini-informativa ("dati usati solo per la prenotazione, informativa su puntify.it/privacy"). Prova = registrazione/trascrizione chiamata. NIENTE SMS, niente spunta.
Tecnicamente: booking a voce salvato con source=voce + gdpr "informativa a voce" + transcript; email conferma solo se il cliente la fornisce.
Testo esatto della frase informativa: da definire con Stefano (può sceglierlo lui). Applicato in FASE 2 (voce). (Nota: non validazione legale, approccio standard, Stefano può far validare al consulente.)
