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

## Sessione 2026-07-22 msg 7106-7139 — altri task COMPLETATI (CAT, oltre ai due sopra)
Gate coperti obbligatori prima cucina (default 0, no preset capienza); pannello sx Cassa stile Stripe
(meno rosso); clic tab Cassa = pagina vuota + ritorno "+ Nuovo ordine"; card board Ordini come template
Stefano (rosso #A07, "x min fa", "· N coperti"/"Coperti da definire", pill, badge N×, CTA scura) poi
compattate (booking.css .ord-card*); Nuovo ordine->Diretto entra in Cassa vendita diretta; correzione dato
A07 paid true->false ("da pagare"). Template card in Agent-Claude/assets/ordini-card-template*.jpg.
GOTCHA confermato: colonna tavolo reale = table_resource_id (non table_operator_id legacy).

## IN ATTESA / decisione aperta
- **MerchantPos (wizard /neworder, POS alternativo)**: stepper coperti default 1 (min 1). Chiesto piu' volte
  a Stefano (msg 7113/7130/7139) se allinearlo a 0/obbligo come la Cassa Dashboard o lasciare 1. Nessuna
  risposta ancora.
- Prova reale di Stefano su tutte le modifiche (dopo Ctrl+F5) + feedback.
- Commit/push blocco Puntify solo su richiesta esplicita (WIP grosso nel working tree).
