# Hardening RLS/GRANT area prenotazioni + ordini (2026-07-27)

Chiusura delle falle trovate dall'audit del 2026-07-27 (verificate live anche in prod).
Lavoro svolto **solo su CAT**; per la prod esiste una migration pronta.

## Principio adottato

La chiave `anon` di PostgREST **è pubblica per definizione** (sta nell'appsettings del client
WASM e nel bundle della Vetrina). Quindi non può essere la base di nessun controllo di accesso.

Modello applicato:

| Ruolo | Cosa può fare |
|---|---|
| `anon` | SOLO lettura del minimo per la vetrina pubblica (servizi attivi, staff pubblico, orari). **Zero** accesso a `bookings` e `menu_public_orders`. **Zero scritture su tutto lo schema.** |
| `authenticated` | Lettura pubblica come anon + gestione completa **dei soli propri negozi** (via `fn_current_user_shop_ids()`). Su `bookings`/ordini: sola lettura. |
| `service_role` | Invariato: ha `BYPASSRLS`, quindi tutti i flussi server continuano a funzionare. |

Tutti i flussi pubblici passano dal **server .NET** (service-role), non da PostgREST.

## Mappa consumatori verificata PRIMA di revocare

Questo è il punto che ha evitato di rompere la produzione:

- **Puntify.App (WASM)**: inietta sempre il JWT utente (`client.Postgrest.GetHeaders`) → ruolo
  `authenticated`, mai `anon`. Tutte le pagine che toccano queste tabelle sono sotto
  `Pages/Merchant/`. Nessuna pagina Client/Operator/Admin le tocca.
- **App area ordini (KDS/Cassa/Dashboard)**: passa da `MenuOrdersApiService` → HTTP `/api/*`,
  **non** PostgREST. Le revoche non la toccano.
- **Puntify.Vetrina**: usa la chiave anon **davvero**, ma solo via `SupabaseStatsService` per
  3 letture: servizi attivi, staff pubblico, orari settimanali. Per questo `anon` **mantiene la
  SELECT ristretta** su `shop_services`, `shop_operators`, `booking_availability`.
  Prenotazione e ordinazione pubbliche passano da `/api/public/*`.
- **Puntify.Server**: service_role → non impattato.

> Gotcha scoperto: `account.id` **non** coincide con `account.userid` per tutti gli account
> (su CAT 16 su 20). Le policy preesistenti scritte come `account_shops.accountid = auth.uid()`
> erano quindi **sempre false** per quei 4 account. La funzione helper accetta entrambe le forme.

## Cosa è stato cambiato

### DB (migration unica)
`docs/DB Migrations/2026-07-27_public_data_hardening.sql` — **rileva da sola lo schema**
(`puntify` su CAT, `public` in prod): non va convertita a mano. Idempotente, ASCII puro,
con `NOTIFY pgrst`.

1. `fn_current_user_shop_ids()` (SECURITY DEFINER) — base delle policy multi-tenant.
2. `bookings`: revocato tutto ad `anon`; `authenticated` solo SELECT dei propri negozi.
   Droppate `anon_all_bookings` e `bookings_public_insert` (`WITH CHECK true`, che permetteva a
   *qualsiasi* utente loggato di creare prenotazioni in qualsiasi negozio).
3. `shop_services` / `shop_operators`: anon solo SELECT ristretta (attivi / staff pubblico);
   rimossa `auth_all_shop_services USING true` (leggeva i servizi di tutti i PV).
4. `shop_resources`: anon **nessun accesso** (aveva INSERT/UPDATE/DELETE!).
5. `booking_availability` / `_exceptions` / `_manual_blocks` / `_settings`: anon solo SELECT.
6. `menu_public_orders`: anon nessun accesso (droppata `..._anon_insert WITH CHECK true`);
   `authenticated` sola lettura dei propri negozi (perde UPDATE/DELETE → R5 "ordine pagato
   immutabile" non più aggirabile dal device merchant).
7. `menu_order_events`: revocati i grant inutili. NB: prima l'INSERT anon di un ordine falliva
   solo come **effetto collaterale** del trigger `fn_menu_order_events` — difesa accidentale.
8. `confirmation_token`: garantito NOT NULL + unico + backfill.
9. `btree_gist` + EXCLUDE `bookings_no_operator_overlap` e `bookings_no_resource_overlap`.

### Codice
- `BookingController.CancelByToken`: cerca per `confirmation_token`, **non** per id.
  Nessun fallback sull'id (il token è NOT NULL su tutte le righe → un fallback non sarebbe mai
  sicuro). I vecchi link via id non funzionano più: voluto.
- `EmailTemplates.BookingConfirmation` / `EmailHelper` / `BookingServiceImpl`: il link di
  annullamento porta il token; `CreateBookingAsync` genera il token in memoria.
- `BookingController.Book`: aggiunto `RequireOwnerAsync` (era l'unico endpoint merchant senza).
- `TableBookingController.ReserveInternal`: validazioni via nuovo `PublicBookingGuard`
  (PV esistente/non bloccato/non cancellato, prenotazioni abilitate, niente passato, anticipo
  min/max, orari di apertura, chiusure, blocchi manuali, GDPR, formati e lunghezze).
  Insert via `InsertThrowOnExclusionAsync` → 409 invece di 500.
- `Program.cs`: policy `public_api` **partizionata per IP** (era un bucket globale 60/min:
  un solo client mandava in 429 le vetrine di tutti).
- Nuovo `Puntify.Server/Services/Booking/PublicBookingGuard.cs`.
- Nuovi test `Puntify.Tests/BookingSecurityTests.cs` (39 test).

## Convenzione oraria (attenzione)

Gli istanti di prenotazione viaggiano e si salvano come **wall-clock locale del negozio con
offset 0** (`...T20:00:00Z` = le 20:00 *del negozio*). Deriva dal fatto che la Vetrina fa
`DateOnly.ToDateTime(ora).ToUniversalTime()` su host con **TZ=UTC**: la conversione è un no-op.
Confermato dai dati (PV aperto 19:00-23:00 → `start_at = 20:30+00`) e dal resto del codice, che
confronta con `TimeZoneHelper.NowInZone(shop.Timezone)`.

→ Nel guard si usa `AsWallClock` + `NowInZone`. **Non** convertire con `ConvertTimeFromUtc`:
sposterebbe di 1-2 ore e farebbe rifiutare prenotazioni valide a inizio/fine servizio.

## Prove eseguite su CAT

Prima → dopo, con la anon key reale:
- `bookings` PII: 37 righe con nome/telefono/email → `permission denied` (401).
- `DELETE`/`PATCH` su `shop_resources`: 204 (permesso) → 401; riga reale **non** cancellata.
- INSERT ordine falso `paid=true`: → `permission denied`.
- `anon` non ha **più nessun grant di scrittura in tutto lo schema** (0 righe).
- Letture legittime vetrina OK e ristrette: vede 3 servizi attivi e 0 dei 3 inattivi;
  2 operatori pubblici su 20 righe totali.
- Merchant (JWT reale): legge/gestisce i propri negozi; utente loggato qualunque vede
  0 prenotazioni / 0 ordini e non può scrivere.
- Flussi end-to-end OK: prenotazione tavolo pubblica, appuntamento pubblico, slot/disponibilità,
  schedule, agenda merchant, ordine pubblico dal menu (totale ricalcolato 17,00, `paid=false`,
  trigger di audit scritto), KDS/Cassa.
- Cancellazione: id prenotazione → 404 e resta `confirmed`; token corretto → 200 `cancelled`.
- IDOR `/api/booking/pepto/book` con sola API key → 403 (0 prenotazioni create).
- Overbooking: 8 reserve concorrenti sullo stesso tavolo → **1 sola** passa (7×409).
  EXCLUDE verificato anche via SQL; back-to-back consentito.
- Rate limit: IP A 60×200 poi 429, altri IP 200.
- `dotnet test`: 219 passed, 33 failed (tutti `SocialStudioTests`, baseline pre-esistente).

## Residui segnalati a Stefano (fuori mandato)

- `booking_service_items` / `booking_order_items`: `anon` ha SELECT → permette di **enumerare
  gli id** delle prenotazioni. Non è più critico (la cancellazione usa il token) ma va chiuso.
- `shop_operator_services`: policy `ALL true` per anon, innocua solo perché il GRANT è SELECT.
- `shop_operators.email` leggibile da anon per gli operatori pubblici (oggi 0 righe con email).
  Restringere per colonna richiede cambiare la query della Vetrina (fa `SELECT *`).
- L'audit sistemico va ripetuto sulle **altre** aree (l'anon key è pubblica: vale per tutto).
