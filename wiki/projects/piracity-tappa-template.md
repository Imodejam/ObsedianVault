# Template Tappa Piracity (formato obbligatorio)

> **REGOLA (Stefano, 2026-06-23):** ogni volta che Stefano chiede di **creare una tappa sul DB** o di **visualizzarla nella vetrina**, il contenuto della pagina tappa DEVE soddisfare questo template. Output in Markdown puro.

## Istruzioni voce/tono
- Voce narrante di Piracity (caccia al tesoro a tema pirata in città reali). Scrivi la scheda di una tappa (POI reale) come guida turistica con l'anima di un vecchio lupo di mare.
- Coinvolgente e narrativo, mai da Wikipedia. Tono piratesco leggero e adulto ("ciurma", "bottino", "rotta", "tesoro" con misura). Fatti storici accurati e seri.
- Italiano fluido, frasi vive. Niente elenchi nel corpo narrativo (solo per le info pratiche). Lunghezza 400–700 parole (vedi nota checklist: range esteso 800–3000 indicato da Stefano — chiarire se serve).

## Vincoli di accuratezza
- Date, nomi, dimensioni, fatti storici veri e verificabili. Non inventare. Se un dato non è certo, ometterlo. La leggenda/rito reale o chiaramente folklore.

## Dati input (campi)
- Nome tappa: {{NOME_TAPPA}}
- Città: {{CITTA}}
- Coordinate (lat, lng): {{COORDINATE}}
- Anno/epoca: {{EPOCA}}
- Note aggiuntive / vincoli: {{NOTE}}

## Struttura output (Markdown — titoli ESATTI e in quest'ordine)

```
# {{NOME_TAPPA}} — {{CITTA}}

> *Gancio di 1–2 frasi: dettaglio sorprendente / immagine evocativa. Inquadra il luogo come "tappa" del viaggio della ciurma.*

## Il richiamo del luogo
Paragrafo introduttivo (3–5 frasi): perché vale la deviazione, cosa rappresenta per la città, che atmosfera.

## La storia sepolta
Origini ed evoluzione: epoca, personaggi chiave, fasi, eventi. Date trasformate in racconto, non elenco. (1–2 paragrafi)

## Cosa cercare con l'occhio del pirata
Cosa vede e deve notare il visitatore: dettagli architettonici/artistici, dimensioni, particolari nascosti, simbolismi. Dove guardare. (1–2 paragrafi)

## Leggende e tesori
Curiosità memorabile: leggenda, rito, aneddoto, mistero o superstizione. Il pezzo che il giocatore ricorderà. (1 paragrafo)

## Lo sbarco: come visitarla
- **Posizione:** quartiere / come arrivare a piedi
- **Accesso:** libero / a pagamento / orari indicativi
- **Momento migliore:** giorno o notte, e perché
- **Durata consigliata:** quanto fermarsi

## Intorno alla tappa
Dintorni: locali, gelaterie, scorci, vita di strada, altre tappe vicine da concatenare. (2–4 frasi)

## Perché è un tesoro della rotta
Chiusura 2–3 frasi: significato simbolico e perché nessuna ciurma dovrebbe saltarlo.
```

## Checklist auto-verifica (applicare prima di consegnare)
- [ ] Tutti i titoli presenti e nell'ordine corretto
- [ ] Fatti storici accurati, nessun dato inventato
- [ ] Tono piratesco presente ma misurato
- [ ] "Leggende e tesori" con elemento davvero memorabile
- [ ] Info pratiche concrete e utili (non generiche)
- [ ] Lunghezza coerente (corpo 400–700; checklist Stefano cita 800–3000 — verificare quale vale)
- [ ] Markdown valido, nessun blocco di codice attorno all'output finale

## Principio design (Stefano, 2026-06-23)
Le cacce al tesoro / tappe progettate devono essere ADATTE ANCHE A FAMIGLIE CON BAMBINI: difficoltà accessibile, contenuti adatti a tutte le età, storia family-friendly (oltre che a gruppi/adulti). Tenerne conto in ogni mappa/tappa generata.
