# Puntify — Catalogo servizi erogati (2026-07-11)

Estratto dai feature flag reali (`ShopExtensions`: EnabledFeatures/BookingModes) + moduli del codice. Base per comunicazione/sales.

## 1. Fedeltà & clienti (feature Loyalty)
- Programma fedeltà a punti: il cliente scansiona lo scontrino → accumula punti → li spende in premi.
- Catalogo premi con richiesta/riscatto.
- Schede cliente (CRM dell'esercente): editabili, rinominabili lato esercente, con storico transazioni/prenotazioni/premi.
- App cliente: wallet, punti, premi, transazioni, notifiche, pagina negozio.

## 2. Prenotazioni & agenda (BookingModes: appuntamenti/tavoli/asporto)
- Appuntamenti (servizi con durata/prezzo, operatori).
- Tavoli (ristorazione).
- Asporto / takeaway (finestre orarie).
- Risorse (es. ombrelloni/postazioni).
- Agenda merchant (vista giorno/settimana), gestione servizi/operatori/risorse.
- Prenotazione pubblica online 24/7 (Vetrina) + gestione autonoma cliente (sposta/annulla via link email o pagina "Appuntamenti" nell'app).
- Conferme/promemoria via email.

## 3. Menu digitale & ordini (feature Menu)
- Menu digitale: sezioni, piatti, foto, allergeni, ingredienti, prezzi.
- AI: generazione foto/descrizioni piatti, libreria foto condivisa, prompt per-menu.
- Menu pubblico via QR, multilingua con traduzione in tempo reale.
- Ordini dal menu.

## 4. Coda & attesa (feature Queue)
- Gestione code / "prendi il numero".
- Totem e display coda; stampa biglietto (ESC/POS); "segui il turno" da smartphone (QR).

## 5. Nemi — assistente AI (feature Nemi)
- Nemi Chat: assistente AI per l'esercente (web + Telegram), agentica.
- Nemi Voce: assistente telefonica 24/7 — risponde a nome del negozio, dà info (orari, servizi), prende/sposta/annulla prenotazioni, riconosce i clienti abituali, multilingua. Fatturazione a minuti (al secondo) + riconciliazione automatica delle chiamate.

## 6. Social Studio (feature SocialStudio)
- Analisi sentiment di recensioni/commenti, feed social, insight, generazione post/caption, alert reputazione.

## 7. Presenza online
- Vetrina pubblica (pagina negozio: orari, menu, prenotazioni, recensioni, blog).
- Multilingua (10 lingue).
- Pagina cliente del negozio dentro l'app.

## 8. Notifiche (feature Notifications)
- Notifiche push e storico ai clienti.

## 9. Dispositivi Android (feature Screens/Devices)
- App Android contenitore + gestione dispositivi; stampa USB (comande/biglietti ESC/POS); supporto Chromecast/TV.

## 10. Pagamenti & fatturazione
- Pagamenti online delle prenotazioni (Stripe) + commissioni/application fee.
- Fatturazione abbonamento (Stripe Tax / IVA UE — in completamento).

## 11. Amministrazione & analytics
- Area Admin multi-tenant (RBAC), monitoring (webhook, chiamate Nemi con KPI/costi/ricavi, filtro periodo).
- Dashboard/panoramica esercente con KPI.
