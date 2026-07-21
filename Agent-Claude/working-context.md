# Working context

## Task corrente (2026-07-21, msg 7014) - Fix tab bar centrata + rename sezione dashboard -> POS
Richiesta Stefano: (1) tab bar finita al centro su tutte le pagine /merchant/{id}/dashboard/* — regressione;
(2) la sezione ordini/cassa va chiamata POS: URL /merchant/{id}/POS/*.

### Diagnosi (fatta)
- Causa tab bar: nuovo blocco in booking.css (filtri archivio 7010)
  `.bk-tabs-wrapper { display:flex; ... }` — da flex container, la regola desktop preesistente
  `@media(min-width:768px) .bk-tabs { margin-left:auto; margin-right:auto; max-width:500px }`
  centra la tab bar come flex item (margin auto assorbe lo spazio). Fix: azzerare i margin
  di `.bk-tabs-wrapper .bk-tabs`.

### Delegato a 1 subagent (in corso)
- Fix CSS booking.css + rename POS: @page alias legacy dashboard + redirect replace verso /POS/,
  link generati (Dashboard, MerchantHome, MerchantPos, Order/BillDetail, ReceiptApproval,
  Notifications, MerchantBottomNav, BottomNav IsActive, AiAssistantFab map, NotificationHelper server),
  resx tutte le 10 lingue: merchanthome_icon_ordini=POS, dashboard_page_title=Puntify - POS.
  NON toccare /admin/dashboard ne' api social/dashboard. Build App+Server come verifica.

## Prossimi passi
- Verificare output subagent, deploy-cat-app.sh (WASM) + restart puntify-server (uno alla volta), test reale.
- Report a Stefano (chat_id 505161324) via reply. Vault + vault-sync.sh.
- In coda: commit/push blocco Puntify (solo su "committa"; working tree con WIP grosso: receipts engine,
  catalogo tipologie, gate coperti, filtri archivio), deploy prod.

## Task precedente (2026-07-21) - Catalogo tipologie + doc commerciale
Vedi daily 2026-07-21. WIP non committato nel repo puntify (receipts engine 3 fasi, Menu->Catalogo,
catalog_type migration applicata a CAT).
