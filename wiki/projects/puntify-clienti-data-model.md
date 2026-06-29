# Puntify — Modello dati Clienti: cosa è condiviso tra esercenti

> Analisi 2026-06-29 (domanda Stefano: se E1 ed E2 censiscono lo stesso cliente C1, quali dati vedono in comune / chi può modificarli). Schema DB `puntify` su `ops-postgres`/`puntify_cat`. App = Blazor WASM con **AnonKey** (role `anon`) → tutto filtrato da RLS lato Postgres/PostgREST.

## Tabelle chiave
- **`account`** = UN solo record globale per persona. Chiavi UNIQUE: `email` E `mobile_number` (unici a livello di sistema). Campi: id, email, displayname, photo, mobile_number, birth_day, birth_month, role, referralcode, referredby, userid.
- **`account_profiles`** = consensi marketing (globale, 1:1 con account). RLS: solo proprietario.
- **`account_shops`** = legame (accountid, shopid) UNIQUE. RLS SELECT `accountid = auth.uid()` (usato per owner→shop).
- **`transactions`** = per-shop (shopid + accountid): punti, importi, + snapshot `customer_name`/`customer_email`. RLS SELECT: owner del negozio vede tutte le transazioni del proprio shop.
- **`bookings`**, **`account_reward`** = per-shop.

## CONDIVISO tra tutti gli esercenti (stesso record `account` globale)
nome (`displayname`), telefono (`mobile_number`), email, foto, referralcode.
Gli esercenti li leggono via RPC SECURITY DEFINER **`search_account_by_id(id)`** / **`search_account_by_email(email)`** che ritornano sottoinsieme fisso: id, userid, email, role, displayname, photo, referralcode, referredby, mobile_number, insertdate. **NON** espone `birth_day`/`birth_month` (compleanno non visibile agli esercenti).

## ISOLATO per esercente (E2 NON vede i dati di E1)
- Punti / saldo (calcolati da `transactions` filtrate per shopid)
- Storico transazioni (per shopid)
- Appuntamenti/prenotazioni (`bookings`, per shop)
- Premi riscattati (`account_reward`, per shop)
- Snapshot `customer_name`/`customer_email` scritti sulle transazioni (per shop)
- Consensi marketing (`account_profiles`, solo il cliente)

## Chi può MODIFICARE i dati condivisi
**Nessun esercente.** 
- RLS su `account`: SELECT e UPDATE solo `id = auth.uid()` → un utente legge/scrive SOLO il proprio account. Un esercente non può modificare (né leggere direttamente fuori dalle RPC) l'account di un cliente.
- Scheda cliente lato esercente (Merchant/ClientDetail.razor): anagrafica in **sola lettura** (nessun input/save su nome/telefono).
- Metodi app `UpdateDisplayName/UpdateMobileNumber/UpdateBirthday/UpdateProfilePhoto` operano su `GetCurrentAccount()` = SOLO sé stessi (self-service del cliente).
- Trigger `protect_account_columns`: per ruoli authenticated/anon blocca modifiche a id/email/userid/referredby anche sul proprio record.
- Censimento merchant (Scan.razor): cerca clienti ESISTENTI per email/QR; se non esiste → "Cliente non trovato" (il merchant NON crea account con nome custom). I clienti si auto-registrano.

## Risposta allo scenario
E2 che registra punti su C1: lo vede nei contatti; vede nome/telefono/email/foto **globali** (gli stessi che vede E1, perché è lo stesso record account). NON vede punti, prenotazioni, storico, premi di E1. I dati anagrafici condivisi li gestisce SOLO il cliente C1: quando C1 li aggiorna, entrambi gli esercenti vedono il nuovo valore. Nessun esercente "inserisce" anagrafica che l'altro poi vede.

## Nota sicurezza / esposizione
- WASM usa solo AnonKey (anon) → nessuna chiave service esposta; tutto via RLS. OK.
- `search_account_by_id` / `search_account_by_email` (SECURITY DEFINER) espongono email+telefono di QUALSIASI account a un utente autenticato che ne conosca id/email. È funzionale al sistema fedeltà (il merchant identifica/contatta il cliente che ha transato da lui), ma `search_account_by_email` consente lookup per email arbitraria (max 20) → da valutare se è esposizione accettabile.
