# Working context

## Ultimo task (2026-07-20)
Puntify - Conto tavolo Opzione B (ordini separati aggregati) su CAT (non committato).
- REVERT append-come-portata (MenuController): ogni invio = nuovo ordine.
- Nuovo endpoint POST /api/menu/orders/pay-table: salda tutti i giri del tavolo,
  fedelta' 1 volta sul totale, idempotente. /pay singolo invariato (asporto).
- Cassa (Dashboard.razor): apre il tavolo con TUTTI gli ordini aperti aggregati
  (_cassaTableOrders) + draft nuovo giro; pagamento -> PayTableAsync.
- 3 resx nuove (cassa_order/cassa_sent_round/cassa_new_round) x10 lingue.
Build server+app 0 err, riavviati (8001/8002=200). Self-test reale OK, dati puliti.

## Prossimi passi possibili
- UI: mostrare "Nuovo giro" / codici giro anche su mobile conto; ricevuta cumulativa
  tavolo (oggi SendReceipt e' per singolo _cassaOrderId; su conto tavolo skippa).
- Coda Stefano: 6844 (id ordine nel path Cassa, badge stato), 6848 (sedie-colore + Tav.N ovunque).
