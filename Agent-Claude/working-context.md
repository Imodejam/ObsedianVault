# Working context

## Task corrente (2026-07-23) — DONE
Fix fiscale COPERTO Puntify (CAT only, no deploy): il coperto seguiva l'aliquota DEFAULT del negozio
(22% IT) ma deve seguire la SOMMINISTRAZIONE (ristorazione dine-in, IT 10%), essendo accessorio.

### Cosa fatto
- Sorgente aliquota country-aware in `Punto.Shared/Models/Menu/VatRates.cs`:
  - `Catering(country)` = aliquota ristorazione ridotta per Paese (IT 10, ES 10, FR 10, DE 7, PT 13, NL 9, ...).
  - `CoverRate(itemAmountsByRate, country)` = aliquota del coperto: (1) catering del Paese se tra gli item,
    (2) aliquota positiva dominante per importo tra gli item, (3) catering ridotta del Paese. Mai il default.
- `Puntify.Server/Services/Fiscal/CountryTaxConfig.GetCateringVatRate(country)` delega a VatRates.Catering.
- 3 punti di bucketing aggiornati:
  - `Puntify.App/Pages/Merchant/Dashboard.razor` -> CassaVatBreakdown (conto Cassa live) + DetailVatBreakdown (archivio).
  - `Punto.Shared/Receipts/Mapping/BillReceiptMapper.cs` -> Map() (scontrino email server + stampa/preview App + BillDetailPage).
- Esempio: 30,50 food@10% + coperto 8,00 -> tutto 38,50@10% -> di cui IVA 10% = 3,50, no riga 22%, totale invariato.

### Stato
Build App + Server verdi (0 error). Receipt test 84/84 passati. Nessun deploy.

### Prossimi passi possibili
- Verificare aliquote catering per Paesi non-mappati (euristica: ridotta alta del set).
- Eventuale campo UI per aliquota coperto esplicita (oggi derivata).
