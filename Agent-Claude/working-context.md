# Working context

## Stato (2026-07-21 sera)
Batch POS completo e deployato su CAT (msg 7014-7039): rename dashboard->POS (route alias+redirect,
wizard nuovo-ordine spostato su /neworder per collisione case-insensitive), fix tab bar centrata,
filtri archivio a pill una riga, risorse libere grigie, Cassa viewport-locked (cassa-lock) senza scroll,
Asporto/Consegna senza "Tav.", badge occorrenze prodotto in Cassa (CassaDishQty, solo conto corrente).
Server riavviato per deep-link POS nelle notifiche.

Social 22/07: post "I conti, senza l'oste" (cassa, luminoso KiRweb) approvato e schedulato su Buffer
ig/li/fb per 2026-07-22T11:00:00Z (dueAt Buffer VUOLE i secondi). Topic-history aggiornata.

## In attesa
- Feedback Stefano su spazi Cassa e badge; opzione: badge che conti anche i giri gia' inviati.
- Commit/push blocco Puntify solo su richiesta esplicita (working tree con WIP: receipts engine,
  catalogo tipologie, batch POS odierno).
- Fuori scope segnalato: CTA email "Vai alla dashboard" (EmailStrings.cs) da uniformare a POS se richiesto.
