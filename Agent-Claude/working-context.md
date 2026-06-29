## Sessione 2026-06-28 — Puntify Vetrina: traduzioni mancanti (IN CORSO)

### Richiesta Stefano
"Entrando come spagnolo vedo sezioni non tradotte. Ricontrolla tutte le pagine e ogni minima scritta. Tutto tradotto in tutte le lingue." + (msg 4521) aggiornami man mano + ogni giorno alle 9:00 dimmi cosa manca.

### CAUSA PRINCIPALE (RISOLTA)
- Resources/SharedResource.<lang>.resx: es/fr/zh/ar/hi/bn/pt avevano 3489 chiavi vs master 4989 → 1500 mancanti IDENTICHE per tutte e 7 → fallback a SharedResource.resx (italiano).
- Master = union(SharedResource.resx neutrale, SharedResource.en.resx).
- FATTO: tradotte 1500×7 via subagent (IT sorgente, EN aiuto). + 12 chiavi GCal mancanti in EN tradotte a mano. Tutte le 9 lingue ora complete (0 untranslated effettivo). Build+restart puntify-vetrina (:8003). Verificato live ES (/es/prenotazioni) e ZH.
- Artefatti: scratchpad/puntify-i18n/ (src_missing.json, out/<lang>.json, merge.py).

### RESIDUO SECONDARIO (DA DECIDERE CON STEFANO)
Testi hardcoded fuori dal resx (appaiono uguali in tutte le lingue):
1. PAGINE LEGALI — Privacy.razor, Termini.razor, CookiePolicy.razor = testo IT hardcoded per TUTTE le lingue (no @if lingua). CondizioniPrenotazione.razor = IT+EN (var `en = Lang!=it`, non-italiano vede INGLESE). Tradurre legali in 9 lingue = scelta legale → CHIEDERE.
2. ETICHETTE MARKETING piccole: Footer "Condizioni di Prenotazione" (label hardcoded, anche MappaDelSito), accent word nei titoli (es. <span>Blog/Policy/Condizioni</span>), BlogPost "Articolo non trovato". → sistemabili (estrarre in resx).
3. PAGINE APP-LIKE: Recensione.razor (recensione cliente via token), Risorse.razor (risorse negozio) = 0 L[], nessuna traduzione. Non sono vetrina marketing → CHIEDERE se in scope.

### TODO
- [ ] Risposta Stefano su scope legali/app.
- [ ] Fix etichette marketing hardcoded (cat. 2).
- [ ] Impostare report giornaliero 9:00 (cosa manca).

### Report giornaliero — FATTO (aggiornamento)
- CronCreate job `917cdd01`: ogni giorno 07:03 UTC (=09:03 Italia, macchina TZ=UTC) → report "cosa manca" a Stefano (chat_id 505161324) via telegram reply. Session-only + auto-expire 7gg (re-impostare). Gate: TODO legali/app + fix etichette marketing hardcoded restano aperti.

### 2026-06-28 sera — Avanzamento + scope app pages scoperto
FATTO e ONLINE:
- 1500×7 traduzioni resx + 12 EN (GCal) → 9 lingue complete (4989).
- Legali Privacy/Termini/CookiePolicy convertite IT→IT/EN (pattern @if(en), en=Lang!=it). Condizioni già ok. Verificato /en e /it. (Gotcha: build incrementale saltò Termini → touch+rebuild.)
- Cron report giornaliero 917cdd01 (09:03 Italia).

DECISIONI STEFANO (msg 4527): 1) legali solo IT/EN (no altre 7). 2) pagine app SE fanno parte della vetrina → sì in 9 lingue.

SCOPE APP PAGES (più grande del previsto, 0 L[] ovunque) — in attesa conferma Stefano (msg 4530) per il flusso booking completo:
- Pages/Recensione.razor (206) — MenuLayout, recensione cliente via token
- Pages/Risorse.razor (322) — MenuLayout
- Pages/BlogPost.razor (106) — solo fallback "Articolo non trovato" (resto da DB)
- Pages/BookingManage.razor (489) — BookLayout
- Components/Booking/*.razor (10+: ModeStep, DateTimeStep, CartCheckout, ConfirmationStep, ServiceStep, OperatorStep, SlotList, QuickTableBooking, QuickTakeawayBooking, ResourceBooking, PublicBookingFlow, ResourceMapView, CustomerFormStep, MiniCalendar)
PIANO: estrarre stringhe → chiavi SharedResource → L["..."] → tradurre 9 lingue (subagent per lingua, come per le 1500) → build/verify. Ondate: prima pagine singole, poi flusso booking.

PICCOLE ETICHETTE MARKETING hardcoded (ancora da fare): Footer + MappaDelSito "Condizioni di Prenotazione"; accent word titoli (<span>Blog/Policy/Condizioni</span> in Blog/CookiePolicy/Termini hero); BlogPost "Articolo non trovato".

## 2026-06-29 sera — Coda richieste Stefano (Puntify)
FATTO oggi:
- Privacy Policy sez. 4.3 "Visibilità dati identificativi ai Commercianti" (IT+EN) online.
- Fix fuso slot prenotazione TAVOLO (QuickTableBooking → MerchantNow Europe/Rome). Online.
- Analisi modello dati clienti (wiki: puntify-clienti-data-model).

IN ATTESA DECISIONE STEFANO:
- Fuso: A) applicare ora-Italia anche a ASPORTO (TakeawayBookingController:95 DateTime.Now) + APPUNTAMENTI (slot server start_at UTC, PublicBookingController/BookingServiceImpl) per coerenza; B) colonna timezone per-negozio (multi-paese). Consigliato A ora + B dopo.
- Settori medici: confermare taglio "no fidelizzazione, sì prenotazioni/agenda/promemoria".
- Conferma ordine: fuso → settori → geolocalizzazione.

TODO APERTI (coda):
1. [GROSSO] Nuovi settori vetrina (data-driven _sectors in Settori.razor + chiavi resx per prefisso in 9 lingue + hero img + Footer.SectorLinks + MappaDelSito.Sectors + SitemapService.SectorSlugs):
   pizzerie, medici-famiglia/medicina-generale, studi-medici, oculista, ginecologo, neurologo, radiologo/diagnostica-immagini, dermatologo, ortopedico, cardiologo, endocrinologo, otorinolaringoiatra, pneumologo. (studi-dentistici GIÀ esiste). Medici senza loyalty. Poi ricontrollare + aggiornare sitemap dinamico.
2. [MEDIO] /negozi: richiesta posizione + filtro località + ordinamento per vicinanza (geoloc browser).
3. [i18n GROSSO non confermato] flusso app vetrina (recensione/risorse/booking ~15 file) in 9 lingue — in attesa "vai".
4. [MINORE] etichette hardcoded marketing (footer "Condizioni di Prenotazione", accent word titoli, "Articolo non trovato").
5. [BUG MINORE] encoding "Ã¨" in PublicBookingController:721 (msg errore slot).
6. [VALUTARE] search_account_by_email espone nome+telefono per email arbitraria.

### Aggiornamenti 2026-06-29 (msg 4548/4549)
- FUSO: Stefano sceglie B (soluzione pulita, fuso per-negozio) — distribuiranno in Spagna. Implementare colonna timezone su shops + selettore UI + uso in tutti i calcoli slot (tavolo/asporto/appuntamenti, vetrina+server).
- SETTORI MEDICI: ok niente fidelizzazione; MA NON dire "gestione dei pazienti". Usare prenotazioni/agenda appuntamenti/promemoria.

### 2026-06-29 notte — FUSO ORARIO: FATTO (soluzione B pulita)
Colonna shops.timezone + TimeZoneHelper + SlotEngine(nowLocal) + server (BookingServiceImpl/PublicBookingController/TakeawayBookingController) + vetrina QuickTableBooking + selettore UI ShopEdit. Tutti i servizi ricompilati e riavviati, API ritorna timezone. Spagna: basterà impostare Europe/Madrid da UI.
Residuo minore: date-level "today" in QuickTakeawayBooking + appointment flow (_today) ancora DateTime.Today server (edge notte 00-02).

### CODA RESIDUA (ordine Stefano: settori → geoloc)
1. [GROSSO, PROSSIMO] Nuovi settori vetrina (pizzerie + studi medici: medici-famiglia/medicina-generale, oculista, ginecologo, neurologo, radiologo, dermatologo, ortopedico, cardiologo, endocrinologo, otorino, pneumologo). studi-dentistici ESISTE. Medici: NO fidelizzazione, NO "gestione pazienti"; sì prenotazioni/agenda/promemoria. Contenuti IT→9 lingue + hero img + Footer/MappaDelSito/SitemapService. Poi ricontrollare + sitemap dinamico.
2. [MEDIO] /negozi geolocalizzazione + filtro località + ordina per vicinanza.
3. [minori] takeaway/appointment date-level tz; etichette hardcoded marketing; encoding "Ã¨" PublicBookingController:721; valutare search_account_by_email; app-pages i18n (in attesa "vai").

### 2026-06-29 notte tardi — SETTORI: FATTO (12 nuovi, 9 lingue) + fix PGRST204 save
12 settori online (pizzeria + 11 medici no-loyalty), 254 chiavi/settore ×9 lingue, wiring completo, sitemap dinamico ok, ricontrollo 12/12 200. Hero img riusate (da sostituire con dedicate). Fix urgente: NOTIFY pgrst reload schema (colonna timezone).
PROSSIMO: geolocalizzazione /negozi (richiesta posizione + filtro località + ordina per vicinanza). shops hanno latitude/longitude.

### 2026-06-29 fine sessione — TUTTA LA CODA FATTA (su CAT)
✅ Fuso per-negozio (DB+server+vetrina+selettore UI completo IANA) | ✅ fix PGRST204 save (NOTIFY pgrst) | ✅ Privacy 4.3 | ✅ 12 settori (pizzeria+11 medici) 9 lingue + foto hero (9/11, mancano oculisti+ortopedici) | ✅ geolocalizzazione /negozi (geo.js + sort vicinanza + distanza km, Vetr_SortNear 9 lingue).
APERTI:
- DEPLOY PRODUZIONE www.puntify.it (deploy-prod.sh) — in attesa OK Stefano. TUTTO è solo su CAT.
- Foto hero OCULISTI + ORTOPEDICI (Stefano deve inviarle).
- Geolocalizzazione: test browser lato Stefano (prompt permesso).
- (minori già tracciati: takeaway/appointment date-level tz edge notte, etichette hardcoded marketing, encoding Ã¨ PublicBookingController:721, search_account_by_email, app-pages i18n, sitemap statico senza settori se lo vuole).

### 2026-06-30 ~00:25 — Batch case study + footer + SEO + foto: FATTO (CAT)
✅ Case study 12 settori ×9 lingue (432 chiavi IT + 8 trad, merge resx 5676). ✅ Footer 5 sezioni (colonna Settori). ✅ JSON-LD Service su settori. ✅ tutte 11 specialità mediche con foto dedicata (oculisti+ortopedici aggiunte).
GEO: Stefano = "b" (generative engine optimization). PROPOSTO piano (FAQPage JSON-LD + /llms.txt + contenuti AI-citabili) → in attesa conferma quali.
APERTI: deploy PRODUZIONE www (in attesa ok) | GEO (in attesa scelta) | geoloc test browser | takeaway/appointment date-level tz edge | etichette hardcoded marketing | encoding Ã¨ PublicBookingController:721.

### 2026-06-30 ~00:35 — GEO FATTO → tutta la lista di stasera CHIUSA (su CAT)
✅ GEO: FAQPage JSON-LD (3 Q&A da pain, 9 lingue) + /llms.txt arricchito (settori medici, recensioni) + contenuti AI-citabili.
TUTTO il lavoro di stasera è su CAT (cat.puntify.it). 
RESTANO SOLO:
- DEPLOY PRODUZIONE www.puntify.it (deploy-prod.sh) — in attesa OK Stefano.
- Geolocalizzazione: test browser (prompt permesso) lato Stefano.
- Minori già tracciati: takeaway/appointment date-level tz edge notte; etichette hardcoded marketing; encoding "Ã¨" PublicBookingController:721; search_account_by_email; app-pages i18n; sitemap statico senza settori (se lo vuole).

### 2026-06-30 ~01:00 — Discussione ORDINI (Stefano) — analisi + proposta in attesa
STATO ATTUALE flusso "ordine pronto":
- Email al cliente quando pronto: NO (nessuna).
- Takeaway (bookings booking_kind=takeaway, TakeawayBoardController): a status='ready' → PUSH FCM NotifyOrderReadyAsync ("Il tuo ordine è pronto") solo se booking.CustomerId valorizzato + token push. Flow: received→in_preparation→ready→picked_up.
- Menu/tavolo (menu_public_orders, MenuController flow received→preparing→ready→delivered): NESSUNA notifica al cliente su ready. Post-ordine (CartCheckout) solo conferma "Torna al locale", niente pagina stato.
- Canale notifiche = Firebase FCM (web/mobile push), no email. NotificationQueueService→FirebaseNotificationService.
- NON esiste pagina cliente di tracking ordine live.
PROPOSTA (in attesa OK Stefano):
1) [PRINCIPALE] Pagina "stato ordine" cliente (tavolo+asporto) con CODICE ordine, aggiornamento realtime (Supabase realtime su menu_public_orders/booking o polling), e quando status→ready: SUONA (audio) + vibra + visual "PRONTO" — come i pager dei ristoranti. Non richiede push/app, basta tenere la pagina aperta.
2) [OPZIONALE] Email "ordine pronto" come fallback per asporto/delivery.
Stefano deve scegliere 1 e/o 2. Da fare domani.

### 2026-06-30 ~01:05 — ORDINI: Stefano conferma "fai entrambi" (cicalino + email) + "valuta tutti i casi" + aggiorna FAQ/doc/vault a fine
PIANO LOCKED (da costruire+testare su browser/telefono domattina):
1) PAGINA STATO ORDINE (cicalino) tavolo+asporto: codice ordine + stato realtime (Supabase realtime su menu_public_orders / takeaway booking, o polling). Su status→ready: audio loop breve + vibrate + visual "PRONTO".
   CASI: (a) autoplay bloccato → armare audio con gesture al momento ordine; (b) pagina chiusa/minimizzata → re-fetch stato su focus/visibilitychange, suona se già ready; (c) telefono spento/pagina chiusa → fallback mail+push, e re-check al riavvio; (d) realtime drop → reconnect+refetch; (e) ordine annullato → mostra stato.
2) EMAIL "ordine pronto" via ResendEmailService.SendAsync:
   - Takeaway: bookings ha customer_email/phone → mail OK (anche TakeawayBoardController già fa push su ready).
   - Menu/tavolo: menu_public_orders NON ha email (solo customer_note, created_by). Anonimo → solo cicalino. Loggato → email da account(created_by). OPZIONALE: campo email facoltativo al checkout tavolo (in attesa risposta Stefano sì/no).
   Canale notifiche esistente = FCM push (FirebaseNotificationService); email separata via Resend.
3) Dopo build: aggiornare FAQ (FAQ.razor / chiavi), documentazione vetrina, vault.
DOMANDA APERTA a Stefano: campo email opzionale al checkout tavolo sì/no.
NB: build+TEST reale (audio/realtime su telefono) prima di consegnare (Stefano ha ribadito "test a valle").
