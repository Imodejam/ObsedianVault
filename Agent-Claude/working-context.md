# Working context

## Stato (2026-07-21 sera)
Batch POS completo e deployato su CAT (msg 7014-7032): rename dashboard->POS (route alias+redirect,
wizard nuovo-ordine spostato su /neworder per collisione case-insensitive), fix tab bar centrata,
filtri archivio a pill una riga, risorse libere grigie, Cassa viewport-locked (cassa-lock) senza scroll,
Asporto/Consegna senza "Tav.". Server riavviato per deep-link POS nelle notifiche. Attendo feedback
Stefano sugli spazi Cassa.

## In attesa
- Social Skin 22/07 (cassa, "era questo", versione LUMINOSA KiRweb): bozza inviata (7030), attendo
  Approva/Modifica -> publish.py --channels ig,li,fb --due-at 2026-07-22T11:00Z + topic-history.
- Commit/push blocco Puntify solo su richiesta esplicita (working tree con WIP: receipts engine,
  catalogo tipologie, batch POS odierno).
- Fuori scope segnalato: CTA email "Vai alla dashboard" (EmailStrings.cs) da uniformare a POS se richiesto.
