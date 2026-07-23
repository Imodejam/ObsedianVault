# Working Context

## Sessione 2026-07-23 — Puntify CAT (3 richieste Telegram Stefano)

Obiettivo: 3 modifiche Puntify.App (collaudo/CAT), delegate a subagent, io orchestro.

### 1. POS/Configurazione — abilitazione servizi ordinazione + tab asporto  [IN CORSO]
- Toggle ON/OFF (`.cfg-toggle`) per vendita diretta / sul posto / asporto / delivery in Dashboard.razor (area POS config). Timing Subito/Dopo visibile solo se ON.
- DB: nuove col `enable_*` su `shop_pos_settings` (migration 2026-07-23_pos_service_enable.sql, applicata CAT).
- Decisione Stefano = opzione A: asporto sorgente unica sotto POS → toggle asporto sincronizza `booking_modes` (bit takeaway).
- Sposta tab `finestre-asporto` (TakeawayWindows) da BookingHub → tab dell'area POS, visibile se asporto ON. Rimosso da BookingHub.
- Subagent: aecc334e410f5abfc.

### 2. Scan.razor — design pagine servizi  [FATTO]
- Migrata a `cfg-page` design system. Build 0 errori. Nessun Scan.razor.css.

### 3. PhotoPickerModal — libreria cataloghi con tag+filtro  [IN CORSO]
- Tab Suggerite mostra tutta la libreria `product_catalog` con chip tag per filtrare.
- DB: col `tags text[]` + backfill categorie (migration 2026-07-23_catalog_photo_tags.sql, CAT). RPC match+browse restituiscono tags.
- Backend: endpoint browse `/api/menu/catalog/photos`. Client: CatalogPhotoDto.Tags + CatalogPhotosBrowseAsync. UI: chip filtro + load-more.
- Subagent: a841310f217023177.

### Domanda aperta a Stefano
- Watchdog: i run avviati dalla sessione muoiono al restart del servizio. Proposto (1) job fuori processo via systemd-run + (2) ledger di ripresa. In attesa OK per implementare.

### Prossimi passi
- Ricevere report subagent POS + foto; verificare build; NON deployare (solo CAT). Hard-refresh WASM lato Stefano per vedere.
- Aggiornare docs/Requests con esito finale.
