# Puntify — Modulo "Elimina Code"
## Prompt di processo completo per implementazione via LLM

> **Istruzioni per l'implementatore (LLM o sviluppatore)**
> Questo documento descrive **il processo funzionale e l'esperienza** del modulo "Elimina Code" di Puntify. **Non contiene scelte tecniche**: stack, schema dati, librerie, protocolli e architettura sono lasciati a te. Implementa rispettando tutti i requisiti funzionali, i controlli e i "punti di attenzione" elencati. Dove vedi un punto di attenzione, trattalo come un requisito vincolante, non come un suggerimento.
>
> **Regola di lavoro obbligatoria:** procedi per passi. Al termine di ogni sezione/modulo implementato, **fermati e chiedi conferma** prima di procedere al successivo. Non implementare più sezioni in autonomia senza gate di conferma intermedi. Esponi le decisioni tecniche che prendi e attendi validazione.

---

## 0. Inquadramento

Costruisci un modulo **elimina code indipendente**, attivabile da qualsiasi esercente Puntify a prescindere dalla categoria merceologica (bar, ristoranti, parrucchieri, barbieri, retail, ambulatori, uffici, CAF e oltre 60 altre categorie). Il modulo non dipende da prenotazioni né da loyalty, ma deve restare **predisposto** a integrarsi con la loyalty in futuro: un biglietto deve poter essere collegato facoltativamente a un cliente Puntify, senza che questo sia obbligatorio nella v1.

L'obiettivo del modulo è eliminare l'attesa in piedi e l'incertezza: il cliente sa sempre quanti ce ne sono davanti e quanto manca, l'esercente (e i suoi operatori) gestisce la fila con un tocco, e il negozio mostra su uno schermo il numero servito.

Tre concetti reggono tutto e vanno tenuti nettamente distinti in tutta l'esperienza:
- **Coda** — il contenitore configurato dall'esercente.
- **Biglietto** — il posto occupato da un cliente.
- **Chiamata** — l'atto con cui esercente o operatore fa avanzare la fila.

---

## 1. Configurazione lato esercente

L'esercente, dal suo gestionale, deve poter creare e gestire una o più code per ciascun punto vendita.

Per ogni coda deve poter impostare:
- **Nome** della coda (es. "Taglio", "Cassa", "Sportello A").
- **Tipo di coda**: numerica semplice, multi-servizio (più code distinte in parallelo), con stima di attesa. Le opzioni devono poter coesistere (una coda può essere multi-servizio e mostrare anche la stima).
- **Modalità di ingresso**: solo in loco (QR in negozio), anche da remoto, oppure entrambe. Il valore predefinito alla creazione deve essere **solo in loco** (modalità a prova di abuso); il remoto va attivato consapevolmente dall'esercente.
- **Tempo medio di servizio per cliente** (es. 12 minuti), usato per calcolare la stima. Deve **auto-aggiustarsi** nel tempo sulla media reale dei tempi di servizio osservati, con possibilità per l'esercente di forzare un valore manuale.
- **Canali di avviso** abilitati: push, SMS, WhatsApp, in qualsiasi combinazione.
- **Tempo di richiamabilità**: per quanti minuti un cliente chiamato resta recuperabile prima di decadere (no-show).
- **Quota massima di posti da remoto** (se il remoto è attivo): percentuale o numero massimo di biglietti da remoto, per non penalizzare chi è fisicamente presente.
- **Assegnazione operatori** alla coda (vedi §12).
- **Registrazione totem** per coda/PV (vedi §17) e, in v2, associazione di una stampante a un totem (vedi §18).

**Punti di attenzione:**
- L'esercente deve poter **aprire e chiudere** la coda manualmente (es. fine giornata) e impostare eventuali orari di apertura automatica.
- Alla chiusura di una coda, i biglietti ancora in attesa **vanno avvisati**, non lasciati appesi.
- Le modifiche alla configurazione **non devono mai stravolgere i biglietti già in fila**: cambiando il tempo medio mentre c'è gente in coda, ricalcola le stime ma non alterare l'ordine.

---

## 2. Ingresso del cliente in coda

### 2.1 In loco (QR) — flusso principale
Il cliente inquadra un QR esposto in negozio e ottiene immediatamente un biglietto, **senza login e senza app** (frizione zero). Vede subito: il proprio numero, quante persone ha davanti, la stima di attesa se attiva.

Subito dopo, proposta non invadente: "Vuoi essere avvisato quando è quasi il tuo turno? Lascia un numero." Se accetta, lascia il numero e sceglie implicitamente il canale disponibile (SMS/WhatsApp). Se rifiuta, resta **anonimo puro** e si regola guardando lo schermo in negozio o la pagina che si aggiorna da sola sul suo telefono.

**Punti di attenzione:**
- Il biglietto anonimo deve essere legato al **dispositivo/sessione**: se il cliente chiude e riapre la pagina, ritrova il suo numero e non ne prende un altro.
- **Controllo anti-duplicazione**: lo stesso dispositivo non deve poter prendere più biglietti contemporaneamente sulla stessa coda, salvo che l'esercente consenta esplicitamente "prendo il numero per più persone".
- Il QR deve identificare coda e punto vendita in modo univoco; un QR fotografato e riusato da casa **non deve poter generare un biglietto in loco** se la coda è "solo in loco" (vedi controllo presenza §4 e §15).

### 2.2 Da remoto (se abilitato)
Il cliente entra in coda da link/app prima di arrivare. Vede le stesse informazioni (numero, persone davanti, stima). Il posto remoto è una **prenotazione del posto**, non la presenza in fila.

**Regole obbligatorie quando il remoto è attivo:**
- **Check-in all'arrivo**: arrivato in negozio, il cliente conferma la presenza riscansionando il QR. Solo dopo il check-in entra nella fila reale e può essere servito.
- **Rispetto della quota remota**: a quota esaurita, i nuovi ingressi remoti vengono rifiutati con messaggio chiaro ("posti da remoto esauriti, vieni in negozio").
- **Equità verso i presenti**: definisci e documenta come si fondono fila remota e fila in loco; un remoto non ancora arrivato non deve scavalcare sistematicamente chi è fisicamente presente.
- Un remoto che **non fa mai check-in** decade come un no-show, liberando il posto.

### 2.3 Da totem (modalità chiosco)
Terza via d'ingresso in loco, accanto al QR su parete e al remoto. Segue le stesse regole anti-abuso e di presenza. Dettagli in §17–18.

---

## 3. Visibilità: pagina cliente e display in negozio

### 3.1 Pagina cliente
Ogni biglietto ha una vista che si **aggiorna in tempo reale** e mostra: numero del biglietto, posizione attuale, persone davanti, stima aggiornata, stato (in attesa / sta per essere chiamato / chiamato / servito / scaduto). Linguaggio rassicurante e concreto, mai ambiguo.

**Punti di attenzione:**
- La stima va presentata come **approssimativa** ("circa 20 minuti"), mai come promessa precisa.
- Se la stima peggiora (rallentamenti), comunicalo con onestà invece di lasciare un numero fermo che insospettisce.
- Alla chiamata, lo stato deve cambiare in modo evidente e, se il cliente ha lasciato un numero, deve partire l'avviso.

### 3.2 Display in negozio
Schermo pubblico (tablet/monitor) col numero attualmente chiamato ed eventualmente i prossimi. Leggibile a distanza, aggiornamento istantaneo alla chiamata, gestione del multi-servizio con code distinte.

**Punti di attenzione:**
- Il display **non deve mai mostrare dati personali** (nessun nome, nessun numero di telefono): solo i numeri dei biglietti.
- Deve gestire con grazia la perdita di connessione momentanea: mostra l'ultimo stato noto e si riallinea al ritorno della rete, senza schermate d'errore al pubblico.
- Deve riflettere le chiamate di **qualunque** operatore o totem sulla coda.

---

## 4. Chiamata e avanzamento della fila

L'avanzamento avviene premendo "chiama il prossimo". Deve essere possibile **sia dal telefono (app gestionale) sia dal tablet/monitor in cassa**, con sincronizzazione perfetta tra le fonti: una chiamata dal telefono si riflette all'istante sul tablet e viceversa.

**Funzioni richieste:**
- **Chiama il prossimo** (avanza al biglietto successivo valido).
- **Richiama** l'ultimo numero (cliente non presentatosi subito).
- **Salta / segna assente** (applica la regola no-show).
- **Segna servito** (alimenta il ricalcolo del tempo medio).
- In multi-servizio: scegliere **da quale coda** chiamare.

**Punti di attenzione:**
- Protezione contro la **doppia chiamata accidentale** (due operatori, o telefono+tablet, che premono insieme): un solo avanzamento va a buon fine, gli altri vengono ignorati senza creare buchi nella numerazione.
- **Controllo presenza/check-in**: in coda "solo in loco" chi ha preso il biglietto sul posto è dato per presente; in coda remota il cliente deve risultare "arrivato" (check-in) per essere servito quando chiamato.
- Ogni azione deve essere **reversibile o correggibile** nei limiti del ragionevole (es. "segnato servito per errore"), perché in negozio si lavora di fretta.

---

## 5. Gestione no-show (cuore della robustezza)

Quando un biglietto viene chiamato e il cliente non si presenta:
- Il biglietto entra in stato **richiamabile** per il tempo configurato (es. 2 minuti); la fila prosegue senza bloccarsi.
- Trascorso il tempo, il biglietto **decade** e si passa al successivo.
- Un cliente decaduto può **rientrare in coda**, ma in fondo (nuovo biglietto), mai recuperando la vecchia posizione.

**Punti di attenzione:**
- Questa regola rende sostenibili sia l'anonimo sia il remoto: documentala e rendila visibile al cliente ("se non ti presenti entro X minuti dalla chiamata, perdi il turno").
- Se il cliente ha lasciato un numero, un secondo avviso "ti stiamo aspettando" durante la finestra di richiamabilità è utile.

---

## 6. Avvisi al cliente

Gli avvisi partono solo verso chi ha lasciato un recapito o ha l'app. Canali: push (chi ha l'app), SMS e WhatsApp (chi ha lasciato il numero).

**Logica minima:**
- Avviso **"manca poco"** quando restano N posti davanti (N configurabile, default ragionevole 2–3).
- Avviso **"tocca a te"** alla chiamata.
- Eventuale avviso **"ti stiamo aspettando"** durante la finestra di richiamabilità.

**Punti di attenzione:**
- **Non spammare**: un avviso per evento, niente raffiche.
- **Costi**: SMS e WhatsApp hanno un costo per messaggio; traccia i messaggi inviati per coda/esercente (determinerà il modello di addebito a consumo). La push è gratuita e va privilegiata quando il cliente ha l'app.
- **Consenso**: lasciare il numero per l'avviso è consenso esplicito a quell'uso e solo a quello; il numero non va riutilizzato per marketing senza consenso separato (vedi §8).
- Gestire i **fallimenti di invio** (numero errato, WhatsApp non attivo) senza bloccare la fila; fare fallback dove possibile; non dare per scontato che l'avviso sia arrivato.

---

## 7. Predisposizione loyalty (non costruire ora)

Il biglietto deve poter essere **facoltativamente collegato a un cliente Puntify**. In v1 non si fa nulla, ma il modello deve permettere in futuro: priorità o fast-track per clienti fedeli, accredito di punti per chi usa la coda, riconoscimento del cliente ricorrente. Gancio latente, come la fast-track del booking.

---

## 8. Privacy e conformità (in pratica)

Il modulo tratta numeri di telefono, quindi:
- Raccogli il numero **solo per avvisare** quella persona di quel turno, dichiarandolo al momento della raccolta.
- **Non mostrare mai** numeri di telefono o nomi sul display pubblico né sul biglietto cartaceo.
- **Cancella o anonimizza** i recapiti poco dopo la fine del servizio: finestra di conservazione breve e automatica.
- Il numero raccolto per la coda **non diventa** automaticamente un contatto marketing: serve consenso separato e dichiarato.
- L'esercente è titolare del trattamento dei dati dei suoi clienti; Puntify è lo strumento. Riflettilo nella documentazione e nei testi mostrati.

---

## 9. Casi limite da gestire esplicitamente

- Coda **vuota**: "chiama prossimo" non deve generare errori.
- Cliente che **scansiona due volte** o riapre la pagina: ritrova il suo biglietto, non ne crea un altro.
- **Più operatori** sulla stessa coda contemporaneamente.
- **Connessione assente** lato cliente o display: degrada con eleganza, riallinea al ritorno.
- **Chiusura coda** con gente in attesa: avvisare, non abbandonare.
- Coda **multi-servizio** con tempi molto diversi: stima calcolata per coda, non globalmente.
- Remoto che **non fa mai check-in**: decade come no-show.
- **Numerazione**: definisci quando si azzera (es. ogni giorno) e come evitare confusione tra numeri di ieri e di oggi.

---

## 10. Principi guida sull'esperienza

- **Frizione zero per il cliente in loco**: prendere il numero deve costare un solo gesto.
- **Onestà nelle stime**: meglio prudente e onesta che precisa e smentita.
- **Un tocco per l'esercente/operatore**: la gestione non deve rubare attenzione al lavoro reale.
- **Il display è marketing**: uno schermo ordinato col logo Puntify è prova sociale in vetrina; curane l'estetica.

---

## 11. Il ruolo Operatore

Terzo attore accanto a esercente e cliente: l'**operatore**, chi materialmente fa avanzare la fila (il barbiere alla poltrona, l'addetto allo sportello), con permessi ridotti rispetto all'esercente. Puntify ha già il concetto di operatore: **riusa quell'entità, non crearne una nuova**.

Principio di fondo: l'operatore **opera** la coda, non la **configura**. Tutta la configurazione resta esclusiva dell'esercente.

---

## 12. Assegnazione operatore ↔ coda

L'assegnazione è **interamente decisa dall'esercente** e deve supportare tutti gli scenari:
- un operatore su **una sola** coda;
- un operatore su **più code** contemporaneamente;
- **più operatori sulla stessa** coda, in parallelo.

**Punti di attenzione:**
- L'esercente deve poter **assegnare e revocare** un operatore da una coda in qualsiasi momento, anche a coda attiva, senza rompere la fila in corso.
- Più operatori sulla stessa coda → fila **unica e condivisa**: chiunque chiami preleva dallo stesso flusso, senza che due operatori prendano lo stesso biglietto (vedi §15).
- Revoca di tutte le code a un operatore loggato → sessione degrada con grazia ("nessuna coda assegnata", non un errore).
- L'assegnazione vale per punto vendita: un operatore non vede code di un PV a cui non appartiene.

---

## 13. Accesso dell'operatore

L'operatore accede con **credenziali proprie e separate** (non condivide il login dell'esercente), per tracciabilità e perimetro ridotto.

**Punti di attenzione:**
- Le credenziali operatore sono **create/gestite dall'esercente**, coerentemente con come Puntify già gestisce gli operatori.
- La sessione operatore deve poter restare **aperta a lungo** sul dispositivo di lavoro senza login continui durante il turno, bilanciando comodità e sicurezza.
- Un operatore disattivato dall'esercente perde l'accesso **immediatamente**.

---

## 14. Cosa vede l'operatore (vista ridotta della home merchant)

All'ingresso, l'operatore **non** vede la home completa del merchant, ma un perimetro ridotto e mirato:
- **Solo le code a lui assegnate** — niente fatturato, analytics loyalty, configurazioni o altri moduli.
- Per ogni coda assegnata, un **quadro d'insieme** immediato: numero attualmente servito, persone in attesa, prossimo numero, stima/tempi se attivi.
- I **tasti per movimentare la coda** ben in evidenza (vedi §15).
- Con più code assegnate, passaggio semplice dall'una all'altra e indicazione chiara di su quale sta operando.

**Punti di attenzione:**
- Mostrare i **numeri dei biglietti**, non dati personali superflui; eventuali recapiti restano fuori dalla vista operatore salvo reale necessità operativa.
- Quadro d'insieme aggiornato in **tempo reale**: la chiamata di un altro operatore sulla stessa coda è visibile subito.
- Vista **leggibile e usabile da telefono e da tablet** indifferentemente.

---

## 15. Cosa può fare l'operatore (azioni consentite)

L'operatore può **gestire l'avanzamento** dal proprio telefono o dal tablet:
- **Chiama il prossimo**
- **Richiama** l'ultimo numero
- **Salta / segna assente** (regola no-show)
- **Segna servito** (alimenta il ricalcolo del tempo medio)
- In multi-servizio / più code assegnate: **scegliere da quale coda** chiamare

**Ciò che l'operatore NON può fare (solo esercente):**
- creare/eliminare code;
- cambiare tempo medio, canali di avviso, modalità di ingresso, quota remota;
- aprire/chiudere la coda;
- assegnare altri operatori;
- vedere dati economici o analytics del merchant.

**Punti di attenzione sulla concorrenza (critico con più operatori sulla stessa coda):**
- Due operatori che premono "chiama il prossimo" quasi insieme devono ricevere **biglietti diversi**: assegnazione atomica, mai lo stesso numero a due operatori, mai un numero saltato.
- L'azione di un operatore si **propaga all'istante** agli altri operatori, al display pubblico e alle pagine cliente.
- Ogni azione è **attribuita all'operatore** che l'ha compiuta (tracciabilità).
- Le azioni restano **correggibili** (es. "segnato servito per errore") nei limiti del ragionevole.

---

## 16. Impatti delle sezioni operatore sulle precedenti

- **§1 Configurazione**: aggiungi l'assegnazione operatori come parte della configurazione della coda (lato esercente).
- **§4 Chiamata**: le funzioni di chiamata sono ora esercitate sia dall'esercente sia dagli operatori assegnati; i controlli anti-doppia-chiamata diventano ancora più importanti.
- **§3.2 Display**: invariato, ma riflette le chiamate di qualunque operatore sulla coda.
- **Tracciabilità**: introduci ovunque il "chi ha fatto l'azione".

---

## 17. Il Totem (modalità chiosco)

Introduci una **modalità chiosco**: un dispositivo fisso all'ingresso, dedicato esclusivamente a far prendere il numero. Non è un nuovo attore, è una *modalità d'uso* del modulo coda per il self-service all'arrivo.

In v1 il totem è un **tablet o smartphone in modalità chiosco** — anche un dispositivo dismesso dell'esercente — montato all'ingresso, che mostra a schermo intero il QR della coda e un grande tasto "Prendi il numero". **Nessuna carta in v1.**

**Comportamento del totem in v1:**
- Schermo dedicato e bloccato sulla sola funzione "prendi numero" (non deve poter uscire su altre schermate o moduli).
- Due modi compresenti: il cliente **tocca il tasto** e il numero appare a schermo, oppure **inquadra il QR** mostrato e porta il biglietto sul proprio telefono (dove può lasciare il recapito).
- Dopo l'erogazione, il totem **torna da solo** alla schermata iniziale dopo pochi secondi.
- Più totem sulla stessa coda → valgono le regole di concorrenza di §15: numerazione unica, nessun numero doppio o saltato.

**Punti di attenzione v1:**
- Un totem è legato a **una coda e un punto vendita**; in multi-servizio l'esercente sceglie se il totem eroga per una singola coda o presenta la scelta del servizio.
- Il totem **degrada con eleganza** se perde la rete: messaggio neutro, ripristino automatico, mai errori tecnici esposti al pubblico.
- Modalità chiosco **protetta** (dispositivo non sorvegliato): nessun accesso a dati del merchant, nessuna uscita dalla schermata-numero.

---

## 18. Stampa fisica del biglietto (v2, predisposta in v1)

La stampa su carta **non si costruisce in v1**, ma il sistema va **predisposto** ora. Caso d'uso reale: clientela poco digitale — CAF, ambulatori, uffici, sportelli — dove molti clienti non hanno o non vogliono usare lo smartphone.

**Predisposizione richiesta già in v1:**
- La generazione di un biglietto deve poter emettere, **opzionalmente**, un "comando di stampa" verso un dispositivo associato al totem. In v1 il comando non fa nulla; in v2 verrà collegato alla stampante.
- **Contenuto del biglietto** stampabile già pensato: numero (grande, leggibile), nome coda/servizio, stima di attesa al momento dell'emissione, ora di emissione, e un **QR sul bigliettino** che il cliente inquadra per seguire l'avanzamento sul proprio telefono e — se vuole — lasciare il recapito per l'avviso. Questo QR è il ponte che riporta l'utente "analogico" dentro l'esperienza digitale.
- Nessun dato personale sul biglietto cartaceo: solo numero, servizio, orario, QR.

**Comportamento previsto in v2:**
- Toccando "Prendi il numero" su un totem con stampante, oltre al numero a schermo **esce il bigliettino di carta**.
- Gestione guasti: **carta esaurita** o stampante offline **non bloccano la coda** — il numero viene comunque assegnato e mostrato a schermo, e l'esercente riceve un avviso "totem senza carta / stampante non raggiungibile".

---

## 19. Modello hardware e commerciale (v2)

La stampa fisica è un'**opzione a pagamento**, non inclusa nel canone base: l'esercente sostiene un costo hardware una tantum più il consumabile.

**Impostazione da prevedere:**
- **Hardware**: stampante termica per scontrini (standard di settore, larghezza tipica 80mm), costo una tantum a carico dell'esercente; la carta termica è un consumabile ricorrente a suo carico.
- **Posizionamento commerciale**: stampa fisica come upgrade mirato alle categorie "poco digitali" (CAF, ambulatori, uffici, sportelli), non a tutti. Per bar, parrucchieri e simili la modalità chiosco senza carta basta.
- **Confine di responsabilità**: chiarisci da subito chi assiste l'hardware (modello certificato fornito da Puntify, lista di modelli compatibili, o partner dedicato).

**Punti di attenzione:**
- Indica un **elenco ristretto di stampanti certificate/compatibili** invece di "qualsiasi stampante": ridurre la varietà riduce i problemi di supporto.
- Tieni la stampa **disaccoppiata** dal resto: una stampante guasta degrada a "totem senza carta" senza mai fermare la fila digitale, che resta la fonte di verità.
- Usa la stampa come **leva di vendita verticale** (convince CAF e ambulatori a scegliere Puntify invece di un concorrente solo-app), senza che il peso dell'hardware rallenti la vendita del modulo base a chi non ne ha bisogno.

---

## 20. Impatti delle sezioni totem/stampa sulle precedenti

- **§1 Configurazione**: l'esercente registra uno o più totem per coda/PV e, in v2, associa a un totem una stampante.
- **§2 Ingresso cliente**: il totem è una terza via d'ingresso in loco accanto a QR su parete e remoto; stesse regole anti-abuso e di presenza.
- **§5 No-show / §6 Avvisi**: invariati; il biglietto da totem si comporta come gli altri, e il QR sul bigliettino attiva l'avviso anche per il cliente "analogico".
- **§15 Concorrenza**: i totem rientrano tra le sorgenti che assegnano numeri; valgono atomicità e propagazione realtime.

---

## Brand

Colore brand Puntify: **#B80000** (rosso scuro). Usalo in tutti gli elementi visivi (display, totem, pagina cliente, biglietto). Nome del progetto sempre **Puntify**.

---

## Promemoria finale per l'implementatore

1. Procedi **per passi**, con **gate di conferma** tra una sezione e l'altra.
2. Tratta ogni "punto di attenzione" come **requisito vincolante**.
3. Le scelte tecniche (stack, dati, protocolli realtime, atomicità) sono tue: **esplicitale** e attendi validazione.
4. La **fila digitale è sempre la fonte di verità**: nessun componente fisico (display, totem, stampante) deve poterla bloccare.
5. v1 = QR loco + remoto opzionale + totem software + operatori + display, **senza** stampa fisica (solo predisposta).
