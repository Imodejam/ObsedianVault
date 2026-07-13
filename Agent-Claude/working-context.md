# Working context — 2026-07-11

## Task in corso
Flusso asporto "pagamento in cassa" (richiesta Stefano via Telegram, msg 5836).

Ordini menu pubblico takeaway (menu_public_orders, order_mode=takeaway):
- nuovo stato `awaiting_payment` (iniziale per asporto cliente) → operatore "Segna pagato" nella CASSA (MerchantPos, NON KitchenDisplay) → received → flusso normale (received→preparing→ready→delivered).
- mail al cliente alla submission: ordine ricevuto, PAGA ALLA CASSA €X, + link tracking (`{VetrinaUrl}/{lang}/negozi/{slug}/menu?order={id}`).
- mail "pronto" già esistente su status→ready (aggiunto link tracking).
- pagina menu Vetrina: deep-link ?order={id} apre vista tracking live + gestione stato awaiting_payment + "paga alla cassa".
- NESSUNA migration DB (status è text libero, no CHECK). Nessun pagamento online.

## Stato
IMPLEMENTATO (subagent). Build 0 errori. Collaudo riavviato (server/vetrina/app). In attesa test Stefano. NON in prod.

## File toccati (previsti)
- Puntify.Server/Controllers/MenuController.cs (SubmitOrder status+email, ListOrders/AllowedStatuses, SetStatus link)
- Puntify.App/Pages/Merchant/MerchantPos.razor (pannello "Da incassare" + Segna pagato → received). KitchenDisplay INVARIATO (cucina vede solo dopo pagamento).
- Puntify.Vetrina/Pages/MerchantMenuPreview.razor (deep-link, UI awaiting_payment, keys status.awaiting_payment/confirm.pay_counter_*/confirm.total tutte le lingue)

## Prossimi passi
- Ricevere report subagent → verificare build → riavviare servizi collaudo SEQUENZIALI (server, vetrina, app) solo dopo OK.
- Debito deploy PROD ancora aperto (migrations Nemi + codice).


## Piracity (2026-07-12) — CHIUSO su collaudo
- Immagini mappe ripristinate (copia assets/auto da piracity-web).
- Ricerca Marketplace cablata (backend search param + frontend debounce). Verificato.
- APERTO: decisione Stefano su versionare/rigenerare le cover (ora non versionate).

### [2026-07-13] PENDING: auto-archivio ordini food (job background)
- Regole: non evaso >5h → chiudi; consegnato → rimuovi dopo 30min. Solo categorie food (1,2,9,27,35).
- In attesa: (1) stato non-evaso Scaduto/Annullato/Consegnato; (2) "rimuovi" consegnato = nascondi Archivio o delete.
- Pattern: nuovo BackgroundService in Puntify.Server/Services/BackgroundServices/ (come BookingReminderService).

### [2026-07-13] RISOLTO: auto-archivio food + coperto dettaglio — deployati su collaudo (pending prod)

### [2026-07-13] PENDING: "Togli il timer" (msg 6042) — ambiguo. Chiesto A (timer 30min consegnati → sparisce subito da Archivio) vs B (job 5h Scaduto → solo filtro vista attivi, no stato). In attesa.
