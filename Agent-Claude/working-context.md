# Working context · 2026-05-28

## Stato attuale: Puntify — Menu per tipologia shop (prodotti vs servizi)

**In attesa di OK di Stefano sul piano** (inviato via Telegram 2026-05-28).

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
