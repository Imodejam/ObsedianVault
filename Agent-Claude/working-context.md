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
