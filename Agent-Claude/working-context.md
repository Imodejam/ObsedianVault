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

## 2026-05-29 — Treatwell-style home + recensioni (IN ATTESA scelte Stefano)
Ordine sezioni Treatwell (salone): Hero(nome+Prenota+rating+nrecensioni+foto) → Info/orari → Servizi evidenziati → Lista servizi → Recensioni(media,totale,filtri,singole con autore/data+operatore) → Team(operatori) → Amenità → Orari completi.
PIANO HOME (Merchant.razor): Hero con rating → Info/orari → Servizi(anteprima+link menu) → Recensioni → Staff → Fedeltà.
RECENSIONI: legate a prenotazione Puntify completata, voto LOCALE + OPERATORE + commento. Domande a Stefano: (1) solo chi ha prenotazione completata via link email post-appuntamento? (2) stelle 1-5 locale+operatore+commento? (3) pubblicazione immediata o approvazione merchant?
PIANO DB previsto: tabella reviews (id, shop_id, booking_id, operator_id, customer_name/id, rating_shop, rating_operator, comment, status, created_at) + token recensione su booking; endpoint pubblici submit/get; aggregati (media+count) per hero e sezione; sezione Recensioni in Merchant.razor + anchor #recensioni (nav menu già linka lì).
