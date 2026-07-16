# Puntify Social Skin (post giornaliero brand)

## Obiettivo
Skin/skill che ogni giorno genera un post su Puntify per i social (Instagram, LinkedIn, Facebook):
sceglie l'argomento, genera testo + immagine (OpenAI gpt-image-2, stile agenzia marketing), invia in
approvazione su @PuntifyNemiBot, e dopo l'OK pubblica su Buffer scegliendo l'ora migliore.

## Stato (2026-07-16)
- Richiesto da Stefano. Inviate 8 domande di scoping (Telegram msg 6412) — IN ATTESA risposte.
- Ricognizione fatta:
  - OpenAI immagini: gpt-image-2 GIA' configurato (appsettings OpenAi:ImageModel).
  - Buffer: NON integrato (va aggiunto; API pubblica Buffer limitata per nuove app -> valutare fallback API native, LinkedIn richiede app dedicata).
  - Social Studio OAuth = account dei MERCHANT, non del brand Puntify -> per i post Puntify serve Buffer con account brand.

## Domande aperte (scoping)
1. Architettura: skill schedulata (io orchestro) vs servizio backend Puntify.
2. Buffer: account + token API disponibili? (canali IG/LinkedIn/FB collegati)
3. Approvazione Telegram: pulsanti inline / reazione / reply.
4. Immagine: con logo/brand vs visual pulito; asset brand di riferimento.
5. Contenuti: lingua (IT / IT+EN), 1 post uguale vs varianti per canale, CTA+hashtag.
6. Argomenti: rotazione servizi + tips/settori; calendario tematico vs autonomo.
7. Orario: best-time Buffer vs orario fisso; uno o per-canale.
8. Testi/risorse per servizio: li preparo io da vetrina/knowledge e faccio approvare.

## Prossimi passi
- Ricevere risposte -> definire architettura -> preparare knowledge testi servizi -> pipeline (topic -> testo -> immagine gpt-image-2 -> approvazione @PuntifyNemiBot -> Buffer).

## Aggiornamento 2026-07-16 13:20 — risposte + prototipo
Risposte Stefano: 1=A (skill schedulata che orchestro io), 2=Sì (ha Buffer), 3=A (pulsanti inline),
4=logo/palette dal sito (scelgo io), 5=IT + CTA + hashtag, 6=ruota argomenti, 7=best time Buffer, 8=preparo io i testi.
- Knowledge base creato: wiki/projects/puntify-social-skin-knowledge.md (brand, 10 servizi con angoli, hashtag, CTA, regole immagine).
- gpt-image-2 VERIFICATO funzionante (OpenAi:ImageApiKey in appsettings; endpoint /v1/images/generations, b64_json).
- PROTOTIPO generato e inviato (msg 6414): argomento Elimina code, immagine agenzia + testo IT + hashtag. In attesa feedback.
- BLOCCO: serve il TOKEN API Buffer per la pubblicazione (verificare che il piano dia accesso API; fallback API native social, LinkedIn app dedicata).
- Pulsanti Approva/Rigenera/Modifica: da implementare via @PuntifyNemiBot nella skin finale.

## Prossimi passi
1. Ricevere token Buffer -> integrare pubblicazione (best time) su IG/LinkedIn/FB.
2. Costruire la skill/cron giornaliera: topic-rotation (storico ultimi 5gg) -> testo -> gpt-image-2 -> invio approvazione con pulsanti inline -> on Approva pubblica su Buffer.
3. Stato/storico argomenti (per evitare ripetizioni).

## Aggiornamento 2026-07-16 13:40 — pipeline VALIDATA
- Immagine: OpenAI /v1/images/edits con gpt-image-2 + logo reale in input (puntify.red.png) -> scena
  REALISTICA con UI app sullo schermo (numero coda) e logo molto fedele. Meglio del compositing per il realismo.
  (Compositing resta opzione per logo pixel-perfect garantito.)
- BUFFER: token (Public API) funziona su api.buffer.com (GraphQL). Account imodejam@hotmail.it,
  org 62626715e1ac600e8b5da016. Canali collegati: Facebook "Puntify", Instagram "puntify.it", LinkedIn "puntify".
  Mutation createPost disponibile. Input: channelId + text + assets:[{image:{url}}] + schedulingType(notification/automatic)/dueAt.
  Immagine via URL PUBBLICO (Buffer la scarica) -> hostare su MinIO/S3 pubblico Puntify.
  Token in /home/progetti/puntify-social/.secrets/buffer_token (600, fuori repo).
- Pipeline completa validata: topic -> testo (Taffo) -> gpt-image-2 edits+logo -> upload URL pubblico ->
  approvazione inline @PuntifyNemiBot -> createPost sui 3 canali (dueAt=best time).

## TODO build
- Skill/cron giornaliera; hosting immagine (bucket pubblico); approvazione inline via NemiBot token (Telegram Bot API sendPhoto+inline_keyboard, callback via webhook Puntify o polling); rotazione+newsjacking; best-time scheduling.
