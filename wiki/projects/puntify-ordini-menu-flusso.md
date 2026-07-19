# Puntify — Flusso ordini da menu (dine-in) — analisi 19/07/2026

Analisi completa del flusso ordini da menu, focus dine-in (al tavolo). File chiave: `Puntify.Server/Controllers/MenuController.cs` (contiene ANCHE MenuOrdersController, righe 1560-2404: creazione, /items, /pay, /transfer, station-status, /status). `Puntify.App/Pages/Merchant/Dashboard.razor` (Cassa/Ordini/Risorse). KitchenDisplay/DrinksDisplay.razor. Vetrina MerchantMenuPreview.razor. Test: Puntify.Tests/MenuStationStatusTests.cs.

## Modello attuale
- menu_public_orders: status, kitchen_status, bar_status (per-stazione, NEW), paid (chiusura/pagamento), order_mode (dine_in|takeaway), table_operator_id/table_label, items(JSON).
- Overall = stazione meno avanzata; delivered solo se tutte delivered. Il pagamento (/pay, paid=true) chiude e libera il tavolo. Occupazione tavolo = DERIVATA (ordine non pagato e non cancelled), nessuna scrittura su shop_resources.

## Coperto (funziona)
Creazione dine_in/takeaway, occupazione tavolo, notifiche+email, stato per-stazione (unit test ComputeOverall), dine-in aperto fino al pagamento, tavolo liberato dal pagamento, takeaway->archivio, deep-link email (GetOrderStatus ritorna status/mode/table_label), edit ordine a livello lista (PATCH /items, bloccato solo da paid/terminale, 409 optimistic).

## GAP principali
1. **Nessun conto unico per tavolo** (il nodo): il pubblico fa sempre INSERT nuovo ordine; la Cassa gestisce UN solo ordine per tavolo (FirstOrDefault). 2 ordini sullo stesso tavolo -> il 2o invisibile al pagamento finche' non riapri. `/pay` accetta UN solo orderId.
2. Nessun pagamento cumulativo piu' ordini del tavolo.
3. Nessun refund/storno su ordine pagato.
4. Nessuna operazione per-ITEM: annullo singola riga, stato consegnato per-item (serve stato per-item, oggi assente), split/transfer-dish disabilitati (cassa_soon).
5. Avanzamento per-stazione solo dai display cucina/bar; la bacheca Ordini usa /status globale (allinea entrambe).
6. Test quasi assenti: solo unit su ComputeOverall. Zero test HTTP su create/pay/items/transfer/occupazione.

## Domande di design (in attesa Stefano)
- **Secondo ordine stesso tavolo -> conto unico?** A) ordine unico accodato (2o invio AGGIUNGE item all'ordine aperto; 1 conto/1 pagamento; veloce ma perde i "round" in cucina). B) piu' ordini + CONTO TAVOLO che li somma e salda insieme (nuovo endpoint pay-table; modello ristorante corretto; piu' lavoro; riusa il merge di /transfer). RACCOMANDATO B, A come ripiego. **Inviata a Stefano (msg 6852), attendo scelta.**
- Modifica ordine: mantenere consentita fino al pagamento; lock per-item in cucina richiede stato per-item.
- Pagamento cumulativo: con B serve POST /orders/pay-table (salda tutti gli ordini aperti del tavolo, fedelta' una volta, chiude tutti).

## Richieste UI Stefano collegate (in coda)
- 6844 Cassa: id ordine nel path (fattibile, pattern tab-in-path), badge stato nella pagina Cassa (piccolo), item consegnati/no (serve stato per-item = non banale), chiarire tasto "invia" (oggi sovraccarico: crea/edit item/avanza awaiting_payment; ridisegno UI: separare "Invia in cucina" da "Salva conto").
- 6848 Risorse: colorare sedie per coperti/occupazione; "Tav. N" in TUTTE le pagine (fatto su cucina/bar; estendere).

## Gia' fatto stasera (batch ordini menu, su CAT non committato)
Stato per-stazione + email pronto per tavolo + Tav.N schermi + dine-in fino al pagamento + colonna "Servito da incassare" + sedie planimetria centrate + vetrina "Al tavolo N". Migration 20260720_menu_order_station_status applicata su CAT.
