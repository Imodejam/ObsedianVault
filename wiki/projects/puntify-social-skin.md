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
