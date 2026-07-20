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

## [2026-07-20] Puntify — 3 richieste UI Stefano (in corso)
Obiettivo: 3 tweak UI su collaudo, delegati a 2 subagent.
- A) Cassa (Dashboard.razor): id ordine/tavolo nel path route, badge stato dentro Cassa (per giro), chiarire tasto "invia" (Invia in cucina vs incasso). per-item = follow-up.
- B) "Tav. N" ovunque (Dashboard/Planimetry/TablesHome/BookingAgenda) + sedie colorate per coperti in TablesPlanimetry.
- C) Vetrina (MerchantMenuPreview): tracking ordine persistente ricevuto->in prep->pronto + stato per stazione; esteso endpoint GET order/{id}/status con kitchen_status/bar_status (record PublicOrderStatusResponse).
Regole: SOLO collaudo, no commit/push, riavvio servizi uno alla volta (server:8001 poi app:8002; vetrina:8003), resx tutte le lingue (App 10, Vetrina 10).
Stato: 2 subagent in esecuzione (A+B su app, C su server+vetrina).
