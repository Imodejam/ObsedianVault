# Working context · 2026-05-28

## Stato attuale: Puntify — Menu per tipologia shop (prodotti vs servizi)

**FASI 1-2 fatte e verificate. Restano: edit campi servizio (foto/video/tag), FASE 3 cascata, FASE 4 cross-sell.**

### Contesto / decisioni raccolte da Stefano
- Tipo shop dedotto AUTOMATICAMENTE dalla categoria (`shop.categoryid` → tabella `puntify.category`).
- Categorie "a servizi" (3 Parrucchiere, 4 Centro Estetico, 5 Barbiere, e simili: estetica, tatuatore, fisio, ecc.) → menu MISTO: servizi + prodotti (es. barbiere: taglio/piega + shampoo).
- Ristorante/Bar/retail → menu solo prodotti (comportamento attuale).
- Fonte unica servizi = `shop_services` (durata, prezzo) già usata per le prenotazioni. Il menu li RIFLETTE/RIUSA, NON li duplica. Servizio lato prenotazione = tempo+costo stimato; lato menu = vetrina prezzi pubblica.

### Architettura attuale rilevata
- Menu: `shop_menus` → `shop_menu_sections` → `shop_menu_dishes` (allergeni, ingredienti, dietary_tags, feature_tags, opzioni, abbinamenti `shop_menu_dish_pairings`, carrello via `menu_public_orders`).
- Servizi prenotazione: `shop_services` (BookingService: name, description, duration_minutes, price, price_display, buffer_before/after, service_kind). Operatori: `shop_operator_services`.
- Classificazione categoria esistente da riusare: `Puntify.Server/Services/Booking/BookingModesDefaults.FromCategoryId` (bit appointments/tables/takeaway).
- Editor: `Puntify.App/Pages/Merchant/Menu/MenuEditor.razor`. Pubblico: `Puntify.Vetrina/Pages/MerchantMenuPreview.razor` + `Components/Menu/MenuView.razor`.

### Piano proposto (4 fasi)
1. Classificazione categoria→tipo + menu pubblico misto (servizi nome/durata/costo, no carrello; prodotti con carrello). Terminologia + niente allergeni sui servizi.
2. Editor: "Aggiungi servizio" pesca da shop_services nelle sezioni (link table sezione↔servizio); durata/prezzo editati solo nel modulo Prenotazioni.
3. Prenotazione servizi in cascata: selezione multipla → durata = somma (+buffer), slot ricalcolati.
4. Cross-selling in prenotazione: proporre servizio aggiuntivo (estendere il meccanismo abbinamenti dei piatti).

### Da decidere con Stefano
- Info specifiche servizio oltre durata+prezzo (le fornirà lui).
- Tutto in sequenza vs partire solo da Fase 1 (menu) e rimandare 3-4 (prenotazione).

### Prossimi passi
- Attendere OK/correzioni → poi creare pagina decisione in `wiki/decisions/` e iniziare Fase 1.

---

## STATO 2026-05-28 fine sessione

FATTE e VERIFICATE (build+restart+test live), COMMITTATE (55081be, push su master 2026-05-28):
- FASE 1 (servizi nel menu pubblico) — vedi daily.
- FASE 2 (editor: servizi nelle sezioni) — vedi daily, E2E verificato.
- Point A: campi servizio foto/video/etichette in `ShopServices.razor`.

Decisioni Stefano per FASE 3-4 (raccolte 2026-05-28):
- Cascata: operatore OPZIONALE (uno o nessuno, sceglie il cliente). Slot calcolati sulla durata TOTALE. Se sceglie un operatore, dev'essere uno che offre i servizi scelti; se nessuno → assegna il negozio.
- Cross-sell (FASE 4): AUTOMATICO (servizi più abbinati), nessuna config merchant.

### PIANO FASE 3 (additivo, retro-compatibile — singolo servizio resta identico)
Chiave: `SlotEngine.GetAvailableSlots` (Punto.Shared/Services/SlotEngine.cs) usa `service.BufferBefore + DurationMinutes + BufferAfter` (riga 32). → passare un BookingService SINTETICO con durata sommata.
1. DB: tabella `booking_services (id, booking_id FK ON DELETE CASCADE, service_id FK, sort_order)`. Modello `BookingServiceLink`.
2. `IBookingService`/`BookingServiceImpl`: overload `GetSlotsAsync(shopId, List<Guid> serviceIds, date, operatorId?)` → costruisce servizio sintetico (Duration=Σdurate; BufferBefore=primo.BufferBefore; BufferAfter=ultimo.BufferAfter) e riusa l'engine. Il metodo singolo delega a quello a lista.
3. `PublicBookingController`: `GetSlots` accetta `serviceIds` (csv) oltre a `serviceId`; `GetOperators` (riga ~168) filtra operatori che offrono TUTTI i serviceIds; `CreateBooking` accetta `ServiceIds` (fallback singolo), EndAt=start+durata totale, salva righe in booking_services, `bookings.service_id`=primo (compat), prezzo=Σ.
4. UI `Components/Booking/ServiceStep.razor` + `PublicBookingFlow.razor`: multi-selezione servizi (checkbox/aggiungi), mostra durata e prezzo totali; passa serviceIds. `ConfirmationStep` + notifiche/email elencano i servizi (join booking_services). Reschedule (PublicBookingController ~539) usa durata totale.
5. Verifica E2E come Fase 2: creare servizi+operatore+availability di test, controllare slot con durata combinata, poi pulire.

### PIANO FASE 4 (cross-sell automatico)
- In `PublicBookingFlow` dopo la scelta servizio, proporre 1-2 servizi aggiuntivi "più abbinati": calcolo da co-occorrenza in `booking_services` (quali servizi vengono prenotati insieme) con fallback ai più prenotati del PV. Endpoint pubblico `GET /api/public/booking/{slug}/service-suggestions?serviceIds=...`. Aggiungere al carrello servizi → confluisce in Fase 3.

### Backlog
- Comprimere foto prima di upload MinIO (strategia da concordare).
- (Sicurezza minore) valutare RLS su shop_menu_section_services / booking_services (ora accesso solo via server service_role).
- Auth JWT FASE A committata (32dad34). FASE B (enforcement per-shop) da fare con test coordinato. JwtSecret recuperato dai container.

## 2026-06-02 — Puntify: prenotazione unificata risorse+operatori (IN ATTESA risposte Stefano)
Richiesta: su /m/{slug}/book mostrare TUTTE le prenotazioni attive del locale (es. lido: tavolo + ombrellone + lettino) da un solo tasto "Prenota". Sulla pagina merchant /services ogni servizio deve indicare: unità di prenotazione (giornata / slot orario con durata min / periodo) e se riguarda una RISORSA (es. campo) o un OPERATORE (consulente). Se risorsa: associare una mappa risorse + flag "mostra in prenotazione coi posti liberi"; nel pubblico, dopo la scelta del periodo, mostrare la mappa con le risorse libere.

ARCHITETTURA ESISTENTE rilevata (gran parte già c'è):
- shop_services (BookingModels.cs ~143): ServiceKind appointment|takeaway_window, DurationMinutes, Price, PriceDisplay, SlotCapacity. NESSUN campo tipo(risorsa/operatore) né booking_unit → da aggiungere.
- shop_operators (~249): Type operator|resource|table (OperatorTypes), ResourceKind, **BookingUnit slot|day|period**, Price, Capacity/Zone, campi planimetria (RoomId,Shape,PosX/Y,W/H,Rotation), QrToken.
- ResourceKinds.cs: catalogo (table,umbrella,lettino,sdraio,gazebo,cabina,court_soccer/tennis,room,posto_auto…) con DefaultBookingUnit e DefaultShape.
- Mappe: shop_floors (IsPublic, Scenario beach/cinema/…), shop_rooms, shop_floor_decorations. Editor Puntify.App/Pages/Merchant/Tables/TablesPlanimetry.razor.
- Modalità pubbliche: bitmask BookingModes (1 appointments,2 tables,4 takeaway) — NO bit "resources". ModeStep + QuickTableBooking + QuickTakeawayBooking + flusso appuntamenti (ServiceStep→Operator→DateTime→…). Endpoint GET /merchants/{slug}/resources già ritorna risorse con bookingUnit, mapScenario, aree, prezzo stagionale, disponibilità, addons.
- Editor servizi: Puntify.App/Pages/Merchant/Booking/ShopServices.razor (oggi solo nome/descr/durata/prezzo/buffer/foto/video/tag).

DOMANDE INVIATE a Stefano (msg 2945), proposte default mie:
1) /services elenco unico tipizzato (operatore/risorsa); mappa+risorse restano nell'editor Risorse → DEFAULT sì.
2) unità = Giornata/Slot(min)/Periodo, guida il selettore pubblico → DEFAULT sì.
3) servizio-risorsa mostra auto tutte le risorse di quel tipo sulla mappa, libero/occupato per periodo → DEFAULT automatico per tipo.
4) tavolo/asporto restano modalità ma confluiscono nello stesso "Prenota" → DEFAULT sì.
RISPOSTE STEFANO (msg 2946):
1) CONFERMATO: /services elenco unico tipizzato; mappa+risorse restano nell'editor Risorse.
2) Unità: decido io, allargare per coprire più situazioni (oltre giornata/slot/periodo: es. fascia intera, evento a data, ecc.).
3) Se servizio ha MAPPA associata → mostra mappa, cliente seleziona 1+ entità (max selezionabili configurabile nel servizio). Se NO mappa → mostra le risorse come lista, seleziona fino al max. → servizio ha campo "max entità selezionabili per prenotazione".
4) (msg 2949) Flag per-servizio: il cliente può SCEGLIERE la risorsa o no. Sì→mostra tavoli/risorse (mappa o lista). No→assegna il sistema per caratteristiche (es. tavolo 3 posti per 3 persone).

DESIGN PROPOSTO (msg 2950, in attesa OK finale):
Nuovi campi shop_services:
- booking_target: operator|resource
- booking_unit (set scelto da me): slot(durata min) | day(giornata) | half_day(mezza giornata mattina/pomeriggio) | period(multi-giorno) | event(ingresso a data, capienza, no orario)
- se resource: resource_kind + resource_map_id(floor, opz) + show_map_in_booking(bool)
- max_selectable (max entità per prenotazione)
- customer_can_choose_resource (bool; false→auto-assegna per caratteristiche)
Flusso pubblico unico "Prenota": lista voci attive → servizio → periodo (selettore per unità) → se risorsa & può scegliere: mappa(se assoc.) o lista, fino a max → dati → conferma. Tavolo/asporto confluiscono.
FASI: A) DB+editor /services unificato; B) flusso pubblico+mappa/lista+auto-assegna. Verifica live ad ogni fase.
Stefano: OK (msg 2951) → procedere.

### FASE A — FATTA + verificata (2026-06-02)
- DB: ALTER shop_services + colonne booking_target, booking_unit, resource_kind, resource_map_id (FK shop_floors ON DELETE SET NULL), show_map_in_booking, max_selectable, customer_can_choose_resource, event_capacity. NOTIFY pgrst reload.
- Modello `BookingService` (BookingModels.cs) esteso con i campi; nuove costanti `BookingTargets` (operator|resource) e `BookingUnits` (slot|day|half_day|period|event, con .All e .Label).
- Editor `Puntify.App/Pages/Merchant/Booking/ShopServices.razor`: nuovi campi — Tipo (Operatore/Risorsa, segmented), Unità (select), Durata slot (solo unit=slot), Capienza (solo unit=event), Prezzo con help dinamico, Buffer (solo operatore), e blocco risorsa: tipo risorsa (ResourceKinds per ambito), max selezionabili, "cliente può scegliere", mappa associata (shop_floors dello shop), "mostra mappa in prenotazione". RowMeta in lista riflette tipo/unità. Salvataggio via Supabase client su tutti i campi.
- Build App OK (0 err). Restart app+server+vetrina. Verifiche live: round-trip DB su colonne risorsa OK; server GetServices lido 200 (modello deserializza); PostgREST /rest/v1 espone le nuove colonne (200) → path scrittura editor OK.
- NON committato.
### FASE B — in corso (incrementi verificati)
B.1 FATTO+verificato (2026-06-02): ServicePublicDto esteso con bookingTarget/bookingUnit/resourceKind/resourceMapId/showMapInBooking/maxSelectable/customerCanChooseResource/eventCapacity; helper `ToServiceDto` in PublicBookingController usato da GetServices e service-suggestions. Build Server+Vetrina OK, restart server, curl GetServices lido mostra i nuovi campi (default operator/slot). Il client Vetrina (GetPublicServicesAsync→ServicePublicDto) li riceve già.
B.2 TODO (la parte grossa, UI pubblica): flusso unico "Prenota":
- ServiceStep già lista TUTTI i servizi attivi (no filtro kind) → ok come elenco unico.
- Routing per servizio selezionato: se target=operator→flusso attuale (slot/operatore). Se target=resource→nuovo step risorsa.
- Selettore periodo per unità: slot→data+orari; day→data; half_day→data+mattina/pomeriggio; period→intervallo date; event→data (+capienza).
- Se resource & customerCanChoose: mappa (se resourceMapId & showMapInBooking) con liberi/occupati, oppure lista risorse del resource_kind; selezione fino a maxSelectable. Se !customerCanChoose: auto-assegna per caratteristiche (riusa fn_find_best_table per tavoli; per risorse a giornata assegna prima libera).
- Backend riuso: GET /merchants/{slug}/resources (già ritorna risorse+mappa+disponibilità per data) — da estendere per accettare il service_id e derivare resource_kind/map/periodo; reservation via TableBookingController ReserveResourceAsync.
- Tavolo/asporto confluiscono nello stesso "Prenota".
NON committato (tutta la feature).

### Test data lido + regola UI-editable (2026-06-02)
Stefano (msg 2955): tutto ciò che configuro deve essere fruibile/modificabile da lui dall'interfaccia → salvata memory feedback_ui_editable. I dati di test li metto solo con campi già editabili nell'editor.
Lido ha già: floor "Spiaggia" (beach, pubblico) + "Cinema"; rooms Area Spiaggia/Area 1; risorse type=table con resource_kind umbrella×10, lettino×4, sdraio×6, table×6, court_*, cabina, gazebo, ecc.
Convertiti i 2 servizi lido (campi editabili):
- "Prenotazione Tavolo" → resource/table/slot, customer_can_choose=false (auto per posti), max 1.
- "Ombrellone e Lettino" → resource/umbrella/day, mappa=Spiaggia(40a8d224), show_map=true, customer_can_choose=true, max 2.
Verificato: GET /merchants/lido.../resources?kind=umbrella&date= ritorna mapScenario=beach, aree, 6 ombrelloni con pos/prezzo(stagione Media ×1.2)/disponibilità + addon Lettino/Sdraio. Data-path B.2 (ombrellone) pronto.
### FASE B.2 — flusso pubblico risorsa (incremento fatto 2026-06-02)
- Nuovo componente `Puntify.Vetrina/Components/Booking/ResourceBooking.razor` (autonomo, stile QuickTableBooking): per servizi resource a data (day/half_day/period/event). Scelta data (MiniCalendar; +data fine per period; +mattina/pomeriggio per half_day) → carica GetResourcesAsync(slug, resourceKind, data) → vista LISTA o MAPPA (toggle, mappa con marker posizionati per pos/shape, verde libero/grigio occupato/accent selezionato) → selezione fino a MaxSelectable (o auto-assegna prime disponibili se !CustomerCanChooseResource) → dati cliente → submit = loop ReserveResourceAsync per risorsa. Conferma + totale (prezzo×giorni per period).
- `PublicBookingFlow`: campo `_resourceService`; in cima render `<ResourceBooking>` quando settato; `ToggleService` → se target=resource: unit=slot→`_selectedMode="table"` (riusa QuickTableBooking per tavoli/campi a slot), altrimenti `_resourceService=svc`. Auto-select singolo servizio e Reset gestiti.
- CSS rb-* in booking.css. Build Vetrina OK (0 err), restart.
- VERIFICA: GetResources lido ok; reserve E2E reale (POST /booking/table/resource/reserve su ombrellone A1) → success, disponibilità→occupata, poi cleanup. UI compila e chiama esattamente questi endpoint. NB: click-through visivo non verificabile via curl (Blazor Server interattivo) → da provare in browser.
### FASE B.3 — entry unico "Prenota" (FATTO + verificato prerender 2026-06-02)
Confermato da Stefano (msg 2961). Rimosso il bivio ModeStep: il tasto "Prenota" porta direttamente all'elenco unico (ServiceStep) con TUTTI i servizi + voci sintetiche tavolo/asporto quando il PV ha quelle modalità ma nessun servizio le copre (così nessuna modalità si perde, vale per tutti i merchant).
- PublicBookingFlow: rimosso branch ModeStep; carica sempre servizi+gruppi+`BuildModeEntries()`. Helper `AllEntries()`, `BuildModeEntries()` (sentinel ServiceKind __mode_table__/__mode_takeaway__), `IsModeEntry()`, `RouteEntry(svc, autoSingle)`. `ToggleService`: voci non-operatore (mode/takeaway_window/resource) → RouteEntry; operatore → multi-select cart. Auto-route se un'unica voce. Reset rifà l'elenco.
- ServiceStep: nuovo param `ModeEntries` (rese come card con icona+descrizione+freccia, RenderModeCard); messaggio "nessun servizio" solo se servizi E mode entries vuoti; `CardMeta()` unit-aware (es. "Ombrellone · Giornata intera", "Asporto", "30 min"). Subtitle "Scegli cosa prenotare".
- Build Vetrina OK, restart. Verifica prerender /it/m/lido.../book: elenca direttamente "Ombrellone e Lettino" + "Prenotazione Tavolo", prompt "Scegli cosa prenotare", NESSUNa card ModeStep. Casi merchant analizzati (solo-tavolo, tavolo+asporto senza servizi, takeaway-service+tavoli) → nessuna modalità persa.
- Click-through interattivo (tap → ResourceBooking/QuickTableBooking) ancora da provare in browser.
### Rifiniture calendario (2026-06-02, msg 2963) — FATTO
- MiniCalendar esteso (retro-compatibile): `WeekView` (una settimana per volta, nav settimanale, header "2 – 8 giu"), `RangeMode` (dal/al con giorni evidenziati: in-range/range-start/range-end, callback RangeChanged), `ShowQuickButtons` (Oggi/Domani/Questo weekend sotto il calendario; weekend = sabato, in range sab→dom).
- QuickTableBooking: MiniCalendar ora WeekView+ShowQuickButtons.
- ResourceBooking: periodo → un solo calendario RangeMode+quick (sostituite le 2 mini); giorno/mezza/evento → WeekView+quick. OnRangeChanged aggiorna start/end (ricarica risorse sulla data inizio). CSS .in-range/.range-*/.mini-cal-quick in booking.css.
- Build Vetrina OK, restart, /book 200.

### Skip scelta servizio se unico (msg 2964) — GIÀ implementato in B.3
- Auto-route: `entries.Count == 1` → RouteEntry diretto (resource→ResourceBooking, operatore→datetime, mode→tavolo/asporto), salta la lista.
- NB: "entries" = servizi + voci sintetiche tavolo/asporto. Test col lido a 1 servizio: lista comparsa lo stesso perché il lido HasTables senza service-tavolo → +voce sintetica Tavolo = 2 voci (corretto). Col lido normale (2 servizi) lista corretta. Per shop davvero a 1 voce → salta.
- Da chiarire con Stefano se intende: shop con 1 SERVIZIO ma con tavoli/operatori configurati deve comunque saltare al servizio (regola diversa).

### ResourceBooking a STEP (mobile-first) — FATTO (msg "wizard")
Stefano: la prenotazione deve essere a step (data → risorse → dati), una schermata per volta, ottima su smartphone.
- ResourceBooking riscritto come WIZARD: enum Step {Period, Resource, Customer}; _steps dinamico (Resource solo se CustomerCanChooseResource); stepper in alto, una card per step, barra azioni sticky in basso (Indietro/Annulla + Continua/Prenota). Validazione per step. Conferma finale.
- Layout single-column max 560px, sticky actionbar (statica ≥640px). Nuove classi rb-wizard/rb-head/rb-steps/rb-step/rb-card/rb-field/rb-actionbar/rb-rescard in booking.css. Resta MiniCalendar week/range/quick dentro lo step Data.
- Build Vetrina OK, restart, /book 200. Click-through da verificare in browser.
NB: QuickTableBooking e il flusso appuntamenti sono già a step/mobile. Per ora ho reso a step il flusso RISORSA (descrizione esplicita di Stefano data→risorse→dati).
### Weekend = sab+dom (msg 2967)
Regola già nel codice: il tasto "Questo weekend" in MiniCalendar RangeMode seleziona sab→dom (RangeChanged(Sat, Sat+1)); in modalità singola (risorse a giornata) seleziona un solo giorno. = "se la risorsa la consente" (consente = unit period/multi-giorno).
Per dimostrarlo sul lido ho cambiato ombrellone day→period (campo editabile). Ora ResourceBooking usa RangeMode → weekend = sab+dom. Period copre sia giorno singolo (click 1 giorno) sia weekend/più giorni.
TODO: verifica browser (wizard step + calendario week/range + weekend + skip); addons (lettino/sdraio); half_day/event raffinati; risorse-slot non-tavolo; valutare step anche per QuickTableBooking. NON committato.

## 2026-05-30 — Vetrina Puntify: funzionalità "Menu & Ordini" (FATTO + verificato live)
Richiesta Stefano: esporre nella vetrina che Puntify gestisce anche menu digitali e ordinazioni al tavolo/postazione (es. lidi) + ordini ritiro/asporto, tutto nel pacchetto standard; rivedere e integrare tutte le pagine.
FATTO:
- Nuova pagina `Puntify.Vetrina/Pages/Menu.razor` (route `/menu` + `/{Lang}/menu`), stile pagina Prenotazioni, riusa `css/prenotazioni.css` (classi bkg-*). Sezioni: hero, 6 feature (menu digitale, ordine tavolo, ordine postazione/lidi, ritiro/asporto, servizi+prodotti, tutto incluso), how-it-works 4 step, sectors 8 pill, CTA.
- Header.razor: voce mega-menu "Menu & Ordini" (/menu) + icona `menu`.
- Home.razor: 4ª card prodotto "Menu & Ordini" (griglia ora `sm:grid-cols-2 lg:grid-cols-4`), voce Home_Pricing_Incl6, rewording Home_ProductsTitle/Desc (non più "tre strumenti").
- Prezzi.razor: Prz_Feat8 + riga confronto Prz_Cmp8.
- FAQ.razor: categoria "Menu & Ordini" + 5 Q&A (Faq_Men1-5).
- i18n: 71 chiavi nuove tradotte in TUTTE e 10 le lingue (default,it,en,es,fr,pt,ar,bn,hi,zh) — XML valido tutti.
- Build OK, restart `puntify-vetrina.service` (porta interna 127.0.0.1:8003). Verificato live: /it/menu e /en/menu 200, zero chiavi non risolte; Home/Prezzi/FAQ integrati.
NOTA: pagine feature precedenti (Prenotazioni/Nemi) erano tradotte solo IT+EN+default; questa Menu è tradotta in tutte le lingue (regola Stefano).

### FASE 4 cross-sell servizi nell'APP — FATTO + verificato live (2026-05-30)
Richiesta Stefano: "includi nell'app anche la fase di cross sell se manca".
- Server `IBookingService`/`BookingServiceImpl.GetServiceSuggestionsAsync(shopId, selectedIds, max=2)`: co-occorrenza su `booking_service_items` (servizi prenotati insieme), fallback ai più prenotati del negozio, fallback finale per sort_order; esclude i selezionati; solo servizi attivi; try/catch → lista vuota.
- Endpoint pubblico `GET /api/public/merchants/{slug}/service-suggestions?serviceIds=csv&serviceId=&max=` (PublicBookingController), mappa a ServicePublicDto, max clamp 1-4.
- Client Vetrina `BookingPublicService.GetServiceSuggestionsAsync`.
- UI: `ServiceStep.razor` nuova sezione "Spesso aggiunti insieme" (param Suggestions, mostra max 2 non selezionati, riusa RenderServiceCard → tap = OnToggleService). `PublicBookingFlow.razor`: campo `_suggestions`, `ToggleService` ora async chiama `RefreshSuggestions()` (fetch endpoint sui selezionati). CSS `.service-suggestions*` in booking.css.
- NOTA tabella: il link booking↔servizio è `booking_service_items` (NON booking_services). Definizioni servizi in `shop_services`.
- Build Server+Vetrina OK (0 errori). Restart puntify-server + puntify-vetrina (server 127.0.0.1:8001, vetrina 8003).
- VERIFICA LIVE su shop reale `barbiere-classico-testaccio-roma`: "Piega seta"→[Piega cosmetica, Taglio donna]; "Taglio donna"→[Piega seta, Piega cosmetica]; combo 2 servizi→[Piega cosmetica + popolare], esclude i selezionati; nessuna selezione→3 più prenotati. Ranking co-occorrenza+fallback corretto.
- NON committato (Stefano non l'ha chiesto). Modifiche in working tree.

## 2026-05-30 — VERIFICA STATO (codice reale, note sotto erano stale)
Controllato il repo /home/progetti/puntify (master):
- Fase 1, Fase 2 ✅ committate.
- Fase 3 cascata ✅ FATTA: `BookingServiceImpl.GetSlotsAsync(shopId, IReadOnlyList<Guid> serviceIds, ...)` costruisce servizio sintetico (Duration=Σ, buffer primo/ultimo); serviceIds in PublicBookingFlow/BookingDtos/PublicBookingController.
- Recensioni ✅ FATTE ed estese: `Punto.Shared/Models/Review.cs` (rating_shop, rating_operator, rating_ambiente, rating_pulizia, commento, foto), pagina `Puntify.Vetrina/Pages/Recensione.razor`, sezione in Merchant.razor.
- Lavoro nuovo non tracciato qui: Risorse / Planimetria / Mappa risorse (molti commit recenti su master).
- Fase 4 cross-sell servizi: NON presente (nessun endpoint service-suggestions). → resta backlog, in attesa conferma scope da Stefano.

## 2026-05-29 — Treatwell-style home + recensioni (FATTO — vedi verifica 2026-05-30 sopra)
Ordine sezioni Treatwell (salone): Hero(nome+Prenota+rating+nrecensioni+foto) → Info/orari → Servizi evidenziati → Lista servizi → Recensioni(media,totale,filtri,singole con autore/data+operatore) → Team(operatori) → Amenità → Orari completi.
PIANO HOME (Merchant.razor): Hero con rating → Info/orari → Servizi(anteprima+link menu) → Recensioni → Staff → Fedeltà.
RECENSIONI: legate a prenotazione Puntify completata, voto LOCALE + OPERATORE + commento. Domande a Stefano: (1) solo chi ha prenotazione completata via link email post-appuntamento? (2) stelle 1-5 locale+operatore+commento? (3) pubblicazione immediata o approvazione merchant?
PIANO DB previsto: tabella reviews (id, shop_id, booking_id, operator_id, customer_name/id, rating_shop, rating_operator, comment, status, created_at) + token recensione su booking; endpoint pubblici submit/get; aggregati (media+count) per hero e sezione; sezione Recensioni in Merchant.razor + anchor #recensioni (nav menu già linka lì).
