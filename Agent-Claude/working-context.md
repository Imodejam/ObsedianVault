# Working context

## 2026-07-24 — Puntify: prezzi IVA-esclusa per catalogo (COMPLETATO)
Task: toggle per-catalogo "I prezzi includono l'IVA" (default ON). OFF = prezzi netti, il totale cliente aggiunge l'IVA.

### Fatto
- Migration `docs/DB Migrations/2026-07-24_menu_prices_vat_inclusive.sql` (shop_menus.prices_vat_inclusive bool NOT NULL default true) applicata a puntify_cat LOCALE (docker ops-postgres). PROD (public) NON eseguita.
- Model: ShopMenu.PricesVatInclusive; MenuPublicOrderItem trailing `bool VatIncl = true` + `GrossAmount(defRate)`.
- MenuEditor Dati: toggle .cfg-toggle + FieldInfo, persiste via SaveMenu.
- Server: ResolveDishVatInclusiveAsync (dish->section->menu), storicizza VatIncl su create pubblico/POS/update-items/merge; totale = Σ GrossAmount + coperto; confirm-covers idem.
- Scorpori: BillReceiptMapper, Dashboard CassaVatBreakdown/DetailVatBreakdown/CassaItemsTotal/CassaLine.Gross + fix detailCover/coverPart.
- Localizzazione: 3 chiavi (label/desc/tip) in tutte 10 lingue.
- Build shared/server/app OK; 84 test ricevuta verdi.
- Esempio esclusivo: net 10,00 @10% -> gross 11,00, IVA 1,00, imponibile 10,00.

### Prossimi passi (per Stefano)
- Deploy CAT e verifica UI del toggle + battuta ordine su catalogo IVA-esclusa.
- Eseguire la migration su PROD (schema public) prima del rilascio in produzione.
