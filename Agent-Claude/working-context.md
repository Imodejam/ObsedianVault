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
4) TRONCATO ("nel servizio il merchant deve scegliere se l'ute...") → richiesto reinvio (msg 2947). ATTENDERE punto 4 prima di iniziare il lavoro grosso.

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
