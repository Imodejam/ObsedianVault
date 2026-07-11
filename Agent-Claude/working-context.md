# Working context — 2026-07-11

## Task in corso
Flusso asporto "pagamento in cassa" (richiesta Stefano via Telegram, msg 5836).

Ordini menu pubblico takeaway (menu_public_orders, order_mode=takeaway):
- nuovo stato `awaiting_payment` (iniziale per asporto cliente) → operatore "Segna pagato" in KitchenDisplay → received → flusso normale (received→preparing→ready→delivered).
- mail al cliente alla submission: ordine ricevuto, PAGA ALLA CASSA €X, + link tracking (`{VetrinaUrl}/{lang}/negozi/{slug}/menu?order={id}`).
- mail "pronto" già esistente su status→ready (aggiunto link tracking).
- pagina menu Vetrina: deep-link ?order={id} apre vista tracking live + gestione stato awaiting_payment + "paga alla cassa".
- NESSUNA migration DB (status è text libero, no CHECK). Nessun pagamento online.

## Stato
Implementazione DELEGATA a subagent general-purpose (background). In attesa build.

## File toccati (previsti)
- Puntify.Server/Controllers/MenuController.cs (SubmitOrder status+email, ListOrders/AllowedStatuses, SetStatus link)
- Puntify.App/Pages/Merchant/KitchenDisplay.razor (+ AppResource: kitchendisplay_col_awaiting_payment / _action_mark_paid)
- Puntify.Vetrina/Pages/MerchantMenuPreview.razor (deep-link, UI awaiting_payment, keys status.awaiting_payment/confirm.pay_counter_*/confirm.total tutte le lingue)

## Prossimi passi
- Ricevere report subagent → verificare build → riavviare servizi collaudo SEQUENZIALI (server, vetrina, app) solo dopo OK.
- Debito deploy PROD ancora aperto (migrations Nemi + codice).
