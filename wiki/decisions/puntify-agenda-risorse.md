# Agenda prenotazioni risorse/operatori — analisi e proposta (2026-06-03)

Richiesta di Stefano (msg 3136): l'agenda non mostra abbastanza info (se/quanto ha pagato il cliente, per quanti giorni, filtro per tipo risorsa, sovrapposizioni). Capire cosa fare prima di agire.

## 1. Stato attuale (Puntify.App/Pages/Merchant/BookingAgenda.razor)
- Vista **Giorno** e **Settimana**, navigazione per periodo, form prenotazione manuale.
- Ogni prenotazione mostra: ora inizio–fine (HH:mm), nome cliente, telefono, note, stato (pending/confirmed/cancelled) con pulsanti conferma/annulla.
- È pensata per **appuntamenti a slot orario** (operatore). Per le **risorse a giornata/periodo** (ombrellone per N giorni) mostra solo HH:mm, che è fuorviante.

### Cosa NON mostra (gap)
1. **Pagamento**: se il cliente ha pagato online, quanto, acconto vs saldo. (Ora il dato esiste: `bookings.payment_status` = paid/pending/null, `total_price`.)
2. **Durata/periodo**: per risorse multi-giorno non si vede "dal–al" né il numero di giorni.
3. **Risorsa/tipo**: non si vede QUALE risorsa (Ombrellone O1) né il tipo; non c'è filtro per tipo risorsa.
4. **Allestimento/accessori**: lettini/sdraio inclusi nella prenotazione non compaiono.
5. **Sovrapposizioni**: nessuna evidenza di conflitti (oggi il reserve blocca gli overlap, ma una doppia prenotazione manuale o casi limite non sono segnalati).
6. **Vista per risorsa**: non esiste una griglia "risorsa × giorni" (tipo planning balneare) per vedere a colpo d'occhio occupazione.

## 2. Dati già disponibili (nessuna/poca modifica DB)
Tabella `bookings` (BookingEntry): `start_at`, `end_at`, `status`, `total_price`, **`payment_status`**, **`stripe_session_id`**, `operator_id` (= risorsa per i resource), `service_id`, `booking_kind` (resource/appointment/takeaway), `customer_*`, `notes`, `participants`.
- La risorsa è `shop_operators` (Name, ResourceKind, Zone). Gli accessori sono in `booking_addons` (Name, Qty, UnitPrice).
- Quindi: pagamento, importo, durata, risorsa+tipo, accessori sono già ricavabili. Manca solo l'UI (e qualche join lato endpoint agenda).

## 3. Proposta (a livelli, dal più utile al più avanzato)

### Livello 1 — Arricchire la card prenotazione (basso sforzo, alto valore)
Per ogni prenotazione mostrare:
- **Tipo+risorsa**: es. "⛱️ Ombrellone O1" (+ zona).
- **Periodo**: "dal 5 al 7 lug · 3 giorni" per le risorse a giornata/periodo; "HH:mm–HH:mm" solo per gli slot orari.
- **Pagamento**: badge "Pagato €42" / "Acconto €12 (saldo €30 in loco)" / "Non pagato" / "Online in attesa".
- **Accessori**: "Lettino ×2, Sdraio ×1".
- Distinzione visiva resource vs appuntamento.

### Livello 2 — Filtri e raggruppamento
- **Filtro per tipo risorsa** (Ombrelloni / Lettini / Tavoli / ...) e per stato pagamento.
- Raggruppamento per risorsa o per tipo.
- Ricerca per nome cliente.

### Livello 3 — Vista planning risorse (tipo gestionale balneare)
- Griglia **risorsa (righe) × giorni (colonne)** con celle occupate/libere, colore per stato pagamento; ideale per i lidi.
- Evidenza **sovrapposizioni**: celle in conflitto evidenziate in rosso.
- Toggle tra "Agenda" (lista temporale, buona per appuntamenti) e "Planning" (griglia, buona per risorse multi-giorno).

### Livello 4 — Operatività
- Azioni rapide: segna come pagato/incassato in loco, sposta/riassegna risorsa, esporta giorno.
- Indicatore arrivi giornalieri, totale incassato/da incassare del giorno.

## 4. Sforzo stimato
- L1: ~mezza giornata (endpoint agenda con join risorsa+addons+payment, card UI).
- L2: ~mezza giornata (filtri).
- L3: 1–2 giorni (componente planning griglia + overlap).
- L4: incrementale.

## 5. Decisioni da prendere con Stefano
1. Priorità: partire da L1+L2 (card ricca + filtri) e valutare L3 dopo? (proposta mia: sì)
2. La "vista planning griglia risorse" (L3) è desiderata fin da subito per i lidi?
3. Pagamento in agenda: serve l'azione "segna incassato in loco" (per i pagamenti non online)?
4. Le sovrapposizioni: solo evidenza visiva o anche alert/blocco attivo?

## Stato
ANALISI inviata a Stefano (Telegram) il 2026-06-03, in attesa di priorità. Nessun codice modificato per questa richiesta.
