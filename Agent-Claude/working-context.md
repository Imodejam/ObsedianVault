# Working context

## Stato (2026-07-21 notte)
Sessione lunga POS (msg 7014-7070), tutto deployato su CAT:
- Rename dashboard->POS (alias+redirect, wizard su /neworder), fix tab bar, filtri pill, risorse grigie.
- pos-lock su tutti i tab (viewport-lock, margini 6-8px, footer solo mobile, +Nuovo ordine in tab bar).
- Cassa: full-height, no-scroll, badge quantita su card+chip (inclusi giri registrati, cache ReferenceEquals),
  Asporto/Consegna senza "Tav." (FormatOrderPlaceLabel), font righe conto 15px.
- Pagina Conto /bill/{id} ridisegnata stile Stripe/Apple (hero+breakdown quadrato+2 colonne).
- Vetrina: modal piatto orizzontale desktop landscape (verificato CDP), live.
- Configurazione POS: tab /POS/Configurazione (Subito/Dopo x4 modalita, FieldInfo, resx x10, upsert
  immediato RLS) + Cassa adattiva pay-first; degrado noto: tavolo con giri esistenti resta flusso storico.
  Tabella puntify.shop_pos_settings su CAT (migration 20260721_pos_settings.sql).
- Social 22/07 schedulato su Buffer (ig/li/fb, 11:00Z, "I conti, senza l'oste").

## Fix 2026-07-22 (Cassa tab vuota)
- Bug: cliccando il tab Cassa dopo aver aperto un conto restava la vista focalizzata sull'ultimo conto
  e spariva "+ Nuovo ordine" (CassaFocused non ricalcolava perche _cassaTableId/_cassaOrderId residui).
- Fix in Dashboard.razor: SwitchTab reso async; su tab=="cassa" chiama StartNewCassaOrder(null)+EnsureCassaMenuAsync
  -> cassa vuota. Guardia in ApplyOrderRefAsync: OrderRef vuoto E stato focalizzato residuo -> reset (draft valido
  non azzerato, no loop). Aperture reali (tavolo/ordine/deep-link) restano focalizzate. Build 0 err, deploy :8002 200.

## In attesa
- Prova di Stefano su Configurazione POS + feedback su pagina Conto e layout POS.
- Estensioni possibili gia segnalate: badge anche... (no, fatto); dati pagina Conto (timestamp split,
  voce Sconto, nome cliente); CTA email "Vai alla dashboard"->POS.
- Commit/push blocco Puntify solo su richiesta esplicita (WIP grosso nel working tree).
