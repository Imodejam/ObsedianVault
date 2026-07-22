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
