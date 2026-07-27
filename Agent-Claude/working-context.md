# Working context

## 2026-07-27 — FATTO: hardening sicurezza/GDPR prenotazioni + ordini (Puntify CAT)
Dettaglio: [[decisions/puntify-rls-hardening-20260727]] · Diario: `Agent-Claude/daily/2026-07-27.md`

Chiuse su **CAT** tutte le falle dell'audit (RLS/GRANT anon, link di annullamento via id, IDOR su
`/api/booking/{slug}/book`, validazioni mancanti sulla reserve tavolo, rate-limit globale non
partizionato, EXCLUDE anti-overbooking mai applicato) + estensione sugli ordini
(`menu_public_orders`, `menu_order_events`).
NB: chiude anche il punto **(5) rate-limit/cap su PublicTableBooking** che era rimasto aperto sotto.

Risultato chiave: **`anon` non ha più alcun grant di scrittura in tutto lo schema** (verificato
schema-wide, 0 righe) e i dati personali delle prenotazioni non sono più leggibili con la chiave
pubblica (prima: 37 righe con nome/telefono/email).

### Consegna per la prod
`docs/DB Migrations/2026-07-27_public_data_hardening.sql` — **un solo file**, rileva da solo lo
schema (`puntify` su CAT, `public` in prod), idempotente, ASCII puro, con `NOTIFY pgrst`.
Va eseguito in **una sola sessione psql** (lo STEP 0 imposta la variabile usata dagli altri step).

### Da fare (Stefano)
1. Migration in prod + deploy codice (vanno insieme).
2. I link "annulla" nelle email **già inviate** non funzionano più (deliberato: con il token
   NOT NULL nessun fallback sull'id sarebbe sicuro).
3. Se lo STEP 10 dà WARNING → sovrapposizioni pregresse in prod da sanare (query diagnostica in
   fondo al file), poi si rilancia solo quello step.
4. **Nessun commit fatto**: committa Stefano.

### Residui aperti (fuori mandato)
- `booking_service_items` / `booking_order_items`: `anon` ha SELECT → enumerazione degli id delle
  prenotazioni (non più critico, ma da chiudere).
- `shop_operator_services`: policy `ALL true` per anon (innocua solo perché il GRANT è SELECT).
- `shop_operators.email` leggibile da anon per gli operatori pubblici (oggi 0 righe con email):
  restringere per colonna richiede cambiare la query della Vetrina, che fa `SELECT *`.
- L'audit RLS va **ripetuto sulle altre aree**: la anon key è pubblica per definizione.

### Gotcha da non ridimenticare
- `account.id` **non** coincide con `account.userid` per 4 account su 20 → le policy scritte
  `account_shops.accountid = auth.uid()` erano **sempre false** per quegli account.
- Gli istanti di prenotazione sono **wall-clock del negozio con offset 0**, non veri UTC (la
  Vetrina fa `ToUniversalTime()` su host TZ=UTC → no-op): confrontare con `NowInZone`, mai
  convertire con `ConvertTimeFromUtc`.
- `service_role` ha `BYPASSRLS`: i flussi server non sono impattati dalle policy.

## 2026-07-26 — Puntify: molti thread aperti (sessione lunga con Stefano via Telegram)

### FATTO in questa sessione
- SOCIAL: 7 post schedulati su Buffer (25-31/07, 1/giorno, IG+LI+FB, hashtag per-canale), stile serie codificato in `puntify-social/planning/style-guide.md`; director_review.sh aggiornato. Parodie pop (museo/chef/panchina/salone/Matrix/Pulp Fiction/Padrino), scritte MAIUSCOLO+punchline rossa, 1:1 no bande, outpaint/crop.
- SEO: diagnosticato che le pagine /negozi prod NON sono indicizzate (dominio indicizza solo home/settori). Footer "Negozi su Puntify" (internal-linking, dinamico, esclude isfake) fatto su COLLAUDO — da deployare in prod.
- iOS APP (collaudo): pulsante "Accedi con Apple" (solo iOS) + blocco acquisti digitali (abbonamento/crediti/Nemi Voce) in app nativa iOS con modale stile ChatGPT. Provider Apple GoTrue ancora da configurare.
- META: token System User ricevuto+salvato (.secrets/meta_token). Pagina FB "Puntify" (id 1094288750415913) ok; IG non collegato; manca read_insights/ads_read.

### IN ATTESA DI STEFANO (checklist inviata su Telegram)
1. Login Apple: 4 dati (Team ID, Services ID, Key ID, .p8) + file verifica dominio + conferma bundle it.puntify.app + se bloccare "cancella abbonamento".
2. Meta: rendere IG professionale+collegarlo alla pagina+assegnarlo; rigenerare token con read_insights(+ads_read); cadenza recap; se fa ads.
3. SEO: ok deploy footer prod (+metodo); accesso GSC o clic "Richiedi indicizzazione"; ok ridurre negozi demo.
4. Massimo autonomo (#26): frequenza + gate invii-solo-dopo-approvazione + report crescita lunedì.
5. IVA: quando rilascio prod (migrazione schema public + deploy); coperti default A/B.
6. Reels (opzionale): 2-3 dai post approvati.

### Riferimenti memoria
- [[project_puntify_social_skin]], [[reference_puntify_shop_seo_indexing]], [[project_puntify_meta_insights]], [[reference_puntify_cat_vs_prod]]

## 2026-07-26 — Puntify.App Login App Review fix (CAT)
- Task 3: campo referral/promo nascosto quando _isNativeApp (gate `_signUp && !_isNativeApp`)
- Task 4: in app iOS nativa il tab "Registrati" diventa "Registrati sul sito" → puntifyPlatform.openExternal(origin+"/register") in Safari; pagina resta in Accedi; signin in-app invariato
- JS: aggiunti puntifyPlatform.origin() e openExternal() (native handler action "openExternal" se PuntifyNative.openExternal===true, altrimenti window.open _blank, fallback location.href)
- _isNativeApp letto in OnAfterRenderAsync da puntifyNativeAuth.isNative; nuova resx login_tab_signup_web x10 lingue
- build 0 errori, restart puntify-app OK; verificato live via CDP (isNative true → referral off, openExternal fired, no signup in-app)
- DA CONFERMARE sull'app iOS vera: che il nativo intercetti l'action "openExternal" (o window.open _blank) e apra Safari

## 2026-07-26 (notte) — RICHIESTA APERTA: audit completo menu/ordini/prenotazioni
Stefano: "rifai un giro complessivo delle funzionalita del menu, ordini e prenotazioni e verifica che il
codice sia ottimizzato, testato e senza bug, compresi test di sicurezza".
Da fare DOPO i fix in corso (IVA-esclusa vetrina, course_status, portate takeaway) cosi l'audit vede il
codice corretto. Piano: workflow multi-agent (1 area per agent: menu / ordini+cassa / prenotazioni) con
dimensioni bug-logici, sicurezza (authz, IDOR multi-tenant, endpoint pubblici, rate-limit, injection/XSS),
performance (N+1, indici, render), copertura test; poi verifica avversariale dei finding (kill dei falsi
positivi) e sintesi. Riportare a Stefano: bloccanti / warning / ottimizzazioni / cosa gia' sistemato.

## 2026-07-26 (notte) — FATTO: fix bug A/B/C di review (Puntify CAT)
- A (totale IVA-esclusa), B (course_status nel PATCH items + fire-course tollerante), C (portate >=2 solo dine_in
  + pulsante Portata gated) FIXATI e verificati end-to-end su puntify_cat. Build 0 errori, servizi riavviati
  uno alla volta, dati di test rimossi, DB ripristinato. NESSUN commit (committa Stefano).
- Restano dei 5 bug di review: (3) migration catalog_photo_tags (gia' gestita a parte) e (5) rate-limit/cap slot
  su PublicTableBookingController -> ANCORA DA FARE.
- Prossimo passo previsto: audit multi-agent menu/ordini/prenotazioni (richiesta aperta di Stefano), ora che
  il codice dei 3 bug e' corretto.
