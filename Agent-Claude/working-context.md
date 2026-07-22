# Working context

## Stato (2026-07-22 pomeriggio) — sessione POS msg 7106-7130, tutto su CAT
Serie di richieste Stefano via Telegram, delegate a subagent, tutte deployate su CAT (richiedono Ctrl+F5 lato Stefano per WASM):

1. **Gate coperti obbligatori** (Dashboard.razor + MenuController.cs + resx x10):
   dine_in non parte in cucina senza coperti definiti (>=1). Preset NON piu' = capienza tavolo, default 0
   (flag `_cassaCoversSet`, helper `CassaDineInNeedsCovers`). Blocco su CassaSendAsync/CassaPayNowAsync/
   ConfirmCoversSendAsync + guard server CreateOrder master dine_in (covers_required). Asporto/consegna esclusi.
2. **Pannello sx Cassa stile Stripe** (Dashboard.razor .cassa-*): conto = card sollevata (bianco, hairline
   #E3E8EE, ombra) vs prodotti piatti su canvas grigio; meno rosso (qty/+/inset portata -> neutro #1A1F36),
   rosso solo su CTA primaria + badge stato.
3. **Fix clic tab Cassa = pagina vuota** (Dashboard.razor): SwitchTab("cassa") -> StartNewCassaOrder(null)+
   EnsureCassaMenuAsync; guardia in ApplyOrderRefAsync resetta se cassa && OrderRef vuoto && stato focalizzato
   residuo (_cassaTableId/_cassaOrderId != null). Risolve anche "tasto + Nuovo ordine sparito" (era nascosto
   perche' CassaFocused restava true).
4. **Card board Ordini come template Stefano** (booking.css .ord-card* + Dashboard.razor markup + resx x10):
   #A07 rosso, orario+"x min fa" (helper RelativeTimeLabel), riga tavolo icona + "· N coperti"/"Coperti da
   definire" ambra + pill Pagato/Da confermare, righe badge "N×", Totale "€ x,xx", CTA scura full-width +
   Incassa ghost. Poi **compattate** (padding 12/14, font ridotti: codice 21, orario 16, nomi/totale 14-17,
   badge/bottone piu' piccoli). Template salvati in Agent-Claude/assets/ordini-card-template*.jpg.
5. **Nuovo ordine -> Diretto entra in Cassa** (Dashboard.razor NoSelectDirectAsync): aggiunta navigazione
   WriteCassaRefToUrl(null)+_tab="cassa"+StateHasChanged (come NoConfirmAsync). Vendita diretta = dine_in
   senza tavolo. Verificato non clobberato dalla guardia reset.

## In attesa / decisioni aperte
- **MerchantPos (wizard /neworder, POS alternativo)**: stepper coperti parte da default 1 (min 1), non
  "indovina" la capienza ma non e' 0. Chiesto a Stefano (msg 7113/7130) se allinearlo a 0/obbligo come la
  Cassa Dashboard o lasciare 1. IN ATTESA di risposta.
- Prova reale di Stefano su tutte le modifiche (dopo Ctrl+F5) + feedback.
- Estensioni gia' segnalate (pre-sessione): dati pagina Conto (timestamp split, voce Sconto, nome cliente);
  CTA email "Vai alla dashboard"->POS.
- Commit/push blocco Puntify solo su richiesta esplicita (WIP grosso nel working tree).
