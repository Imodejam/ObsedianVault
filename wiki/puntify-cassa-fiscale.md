# Puntify — Cassa fiscale / Corrispettivi / Stampante fiscale (roadmap da benchmark Ubify)

> Ricerca 2026-07-14 (richiesta Stefano): crawl guida/supporto Ubify + fonti Agenzia Entrate, per capire cosa integrare in Puntify e essere in linea col mercato IT su cassa, corrispettivi telematici e stampante fiscale. Fonti marcate **[Ubify]** o **[Fiscale-IT]**.

Stato Puntify oggi: menu, ordini, conto Cassa con coperto, formati, IVA per prodotto (in arrivo), loyalty. **Manca tutto lo strato fiscale.**

---

## 1. Gestione Cassa / POS
- Gestionale integrato prodotti/prezzi/reparti dentro la cassa. **[Ubify]**
- Lettore barcode (anche multipli), cassetto contanti, switch Ethernet nel kit. **[Ubify]**
- Integrazione POS "scambio importo": totale inviato al terminale, esito rientra in cassa in automatico (no errori). **[Ubify]**
- Forme di pagamento (carte/wallet) con tracciabilità automatica. **[Ubify]**
- Scontrino parlante (CF cliente, es. detrazioni). **[Ubify]**
- Chiusura di cassa gestionale (quadratura incassi, resi/storni, discrepanze cassa/POS/fiscale). **[Ubify]**
- Report incassi giornalieri/settimanali/mensili anche da remoto. **[Ubify]**
- Magazzino: conta inventariale + export venduto. **[Ubify]**
- Tracciamento operatore per chiusura. **[Ubify]**
- **Non letti su Ubify (ma standard ristorazione, da presidiare in Puntify):** conti/tavoli, portate/comande, split conto, sconti riga/totale, turni operatore, prima nota, stampa comande cucina. (Ubify è più retail/tabaccherie che ristorazione.)

## 2. Corrispettivi telematici
- Memorizzazione elettronica + trasmissione telematica dei corrispettivi giornalieri all'AdE; ha sostituito registro corrispettivi e scontrino/ricevuta (con il documento commerciale). Obbligo generalizzato. **[Fiscale-IT]**
- L'RT registra vendite, memorizza in memoria inalterabile, sigilla e trasmette. **[Fiscale-IT/Ubify]**
- Invio automatico all'AdE dopo chiusura (portale Fatture e Corrispettivi). **[Ubify]**
- Chiusura giornaliera / totale Z: azzera contatori RT, genera file XML di chiusura, lo trasmette. Ubify: "Chiusura ECR" → XML → invio in <30s; archivia ora/importo/operatore/stato. **[Ubify+Fiscale-IT]**
- Documento commerciale (ex scontrino), dal 2020; con CF/P.IVA diventa valido ai fini fiscali e convertibile in fattura. **[Ubify+Fiscale-IT]**
- Gestione IVA/aliquote per categoria/reparto. **[Ubify]**
- Ventilazione IVA (IVA ventilata) per dettaglianti con aliquote miste. **[Ubify+Fiscale-IT]**
- Esenzione IVA / natura operazioni esenti. **[Ubify]**
- Reso e annullo: documento commerciale "per reso merce" e "per annullo". **[Fiscale-IT; Ubify solo generico]**
- Lotteria degli scontrini: codice lotteria cliente, accodamento e trasmissione via RT (ordinaria + istantanea). **Non feature esplicita Ubify.** **[Fiscale-IT]**
- Conservazione/inalterabilità garantita dall'RT. **[Fiscale-IT/Ubify]**

## 3. Stampante fiscale / Registratore Telematico (RT)
- RT = hardware+software omologato AdE che registra/memorizza/trasmette. **[Ubify+Fiscale-IT]**
- Hardware Ubify: cassa + barcode + cassetto + switch; opzionali POS PAX e stampante fiscale **Epson FP-81 II RT**. **[Ubify]**
- Modelli citati: **Epson FP-81 II RT**, **PAX**. **[Ubify]**
- Tipologie: RT stand-alone, stampante fiscale RT collegata a gestionale (modello Ubify), Server-RT (multi-cassa). **[Fiscale-IT]**
- Censimento/attivazione presso AdE: stati censito→attivato→in servizio→fuori servizio; verifiche/taratura periodiche. **[Fiscale-IT]**
- Aggiornamento normativo automatico. **[Ubify]**
- Integrazione via driver/comandi fiscali (ESC/POS fiscale o API/XML produttore): il gestionale invia, l'RT sigilla e trasmette. **[Fiscale-IT]**

## 4. Altro
- Fatturazione elettronica integrata; documento commerciale → fattura. **[Ubify]**
- Posizionamento "conformità chiavi in mano" + supporto. **[Ubify]**
- Report fiscali/gestionali da remoto, storico chiusure con stato invio. **[Ubify]**
- Verticalizzazioni (es. tabaccherie). **[Ubify]**
- Obbligo collegamento POS–RT (2025/2026): Ubify generico, approfondire su AdE. **[Ubify/Fiscale-IT]**

---

## Gap Puntify → cosa integrare (checklist prioritizzata)

**P0 — Fiscalizzazione (blocca il go-to-market IT)**
1. Integrazione RT / stampante fiscale (Epson FP-81 II / RCH / Custom via ESC/POS fiscale o XML): l'app formatta, l'RT sigilla e trasmette. Analogo al bridge Android già usato (`PuntifyNative.printRaw`) ma con comandi fiscali RT.
2. Emissione **documento commerciale** (non scontrino generico) con righe, aliquote IVA per prodotto, totali; stampa via RT.
3. **Chiusura giornaliera / Z**: azzera contatori RT, genera XML corrispettivi, registra invio/stato; storico chiusure (ora/importo/operatore/esito).
4. **Trasmissione corrispettivi AdE** (delegata all'RT), con tracciamento stato/errori.
5. **Mappatura IVA/aliquote per reparto + natura esenti** — collegare l'IVA-per-prodotto (in arrivo) alle aliquote fiscali/reparti RT.

**P1 — Operatività fiscale**
6. Reso e annullo fiscali (documento "per reso"/"per annullo" collegati all'originale).
7. Riconciliazione pagamenti / scambio importo POS + quadratura cassa/POS/corrispettivi in chiusura.
8. Split conto / sconti riga e totale a livello di documento commerciale.
9. Ventilazione IVA (se Puntify va oltre la ristorazione).

**P2 — Allineamento mercato**
10. Lotteria degli scontrini (codice lotteria + accodamento/trasmissione via RT).
11. Documento commerciale "parlante" (CF/P.IVA) + conversione → fattura elettronica.
12. Report fiscali (registro chiusure, incassi per aliquota, export) UI-editable.
13. Gestione censimento/attivazione RT sul portale AdE.

---

## Fonti
Ubify: /supporto#guida, /registratore-di-cassa, /cassa-fiscale, /articoli/ottimizzare-chiusura-cassa-giornaliera, /glossario (chiusura-giornaliera-cassa, documento-commerciale, registratore-telematico, iva-ventilata), /articoli/integrazione-pos-registratore-cassa, /registratore-di-cassa-per-tabaccherie, /normativa-fiscale, /legge-di-bilancio-2025 (solo marketing).
Fiscali (AdE): guida memorizzazione/trasmissione corrispettivi; lotteria degli scontrini (esercenti); specifiche tecniche RT V11.1.

---

## Internazionale / altri Paesi UE (2026-07-14)

**Regola chiave:** i CONCETTI generali di cassa sono universali; lo STRATO FISCALE è nazionale e non trasferibile.

- **Riusabile ovunque (universale):** menu, ordini, conto/tavoli, coperto, formati, IVA per prodotto, forme di pagamento, resto, sconti, chiusura gestionale, report incassi, loyalty. Cambia solo l'aliquota IVA per Paese.
- **NON riusabile (solo Italia):** Registratore Telematico (RT), corrispettivi telematici verso Agenzia Entrate, documento commerciale, lotteria degli scontrini. Sono meccanismi italiani.

**Ogni Paese ha il suo regime di fiscalizzazione (molto diversi tra loro):**
- Germania: KassenSichV + TSE (Technische Sicherheitseinrichtung) — modulo di sicurezza che firma ogni transazione.
- Austria: RKSV — firma fiscale su catena di scontrini.
- Francia: legge anti-frode IVA, software di cassa certificato (NF525 / attestazione editore).
- Portogallo: software certificato + SAF-T + ATCUD/QR code sui documenti.
- Spagna: TicketBAI (Paesi Baschi/Navarra) + Veri*Factu (nuovo sistema nazionale).
- Polonia (registratori + JPK), Croazia (fiscalizzazione real-time), Ungheria (online cash register), Grecia (myDATA), Romania (e-Factura/SAF-T).
- "Soft" / senza fiscalizzazione hardware obbligatoria: UK, Paesi Bassi, Irlanda (per ora).

**Implicazione architetturale per Puntify internazionale:**
- Costruire un'astrazione **"fiscal provider" pluggable per Paese** (interfaccia comune: emetti documento, chiusura, trasmissione), con implementazioni per Paese.
- In alternativa/complemento: integrare una **fiscalization-as-a-service** (es. Fiskaly, che copre DE/AT/ES/FR e altri; o provider locali) per non reimplementare ogni normativa e restare aggiornati sui cambiamenti.
- Il layer "cassa/menu/IVA" resta condiviso; cambia solo il provider fiscale attivo in base al Paese del negozio (già abbiamo `shops.categoryid` e i dati fiscali/Paese).

> Le date/dettagli (es. rollout Veri*Factu ES, riforma FR) vanno verificati Paese per Paese prima di ogni implementazione: la normativa evolve.

### Aliquote IVA per Paese (non universali)
- **Italia:** 22 (ordinaria), 10, 5, 4 (ridotte) + esente/natura. → selettore piatto Puntify: 0/4/5/10/22 + default.
- **Spagna:** 21 (general), 10 (reducido), 4 (superreducido) + speciali/temporanei 5 e 0 su alimenti base; Canarie usano IGIC (~7%), Ceuta/Melilla IPSI. (Verificare stato misure temporanee.)
- Implicazione: il set di aliquote del selettore deve essere **per-Paese** (dipende da `shops` Paese/categoria), non hardcoded IT. Vedi sezione Internazionale.
