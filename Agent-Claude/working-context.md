# Working context

## Task 2026-07-22 — Guard coperti pagamenti dine_in (Puntify CAT)
Regola Stefano: un dine_in pagato DEVE avere coperti definiti. Guard server aggiunto in
Puntify.Server/Controllers/MenuController.cs:
- /{orderId}/pay: dine_in && covers NULL → covers_required, ECCETTO giro-successivo di tavolo
  con master (covers not null) già confermato (query covers=not.is.null sul table_resource_id).
- /pay-table: se conto dine_in e NESSUN giro del tavolo ha covers not null → covers_required.
Build 0 errori, restart puntify-server ok (:8001 200, log puliti). Verificato su A07
(e1e804a7-... dine_in covers NULL, tavolo senza master): guard scatta.

Stato: COMPLETATO. Solo CAT, nessun commit/push.

## Task 2026-07-22 — POS Cassa: pannello coperti inline + stato vuoto (Puntify.App CAT)
File: Puntify.App/Pages/Merchant/Dashboard.razor
MOD1: rimosso div .cassa-confirm-covers dal footer conto. Conferma coperti dell'ordine in attesa
ora passa dal pulsante "Coperti" (nuovo helper OpenGuestsClick: se CassaAwaitingCoversOrder!=null ->
OpenGuestsForConfirm, altrimenti OpenGuests). GuestsConfirm reso async: in modalita' confirm, dopo
aver settato _confirmCovers, chiama ConfirmCoversSendAsync (invia in cucina). Popup auto ingresso
(MaybePromptCoversOnEntry) invariato. Gate server/CassaDineInNeedsCovers invariati.
MOD2: flag _cassaOrderStarted. Pannelli .cassa-wrap visibili solo se (CassaFocused||_cassaOrderStarted);
altrimenti stato vuoto (.cfg-empty + "Crea un ordine per iniziare" + bottone NewOrder). true in
LoadTableConto/LoadOrderIntoCassa/NoConfirmAsync/NoSelectDirectAsync/ApplyOrderRef(via load); false in
SwitchTab(cassa)/OnInitialized(cassa senza ref)/guardia reset ApplyOrderRefAsync.
Resx: cassa_empty_state aggiunta in 10 lingue (it/en/es/fr/de/nl/pl/ro/ru/uk). Bottone riusa dashboard_new_order.
Build Release 0 errori. deploy-cat-app.sh :8002 -> HTTP 200. WASM: hard-refresh lato Stefano.
Stato: COMPLETATO. Solo CAT, nessun commit/push.
