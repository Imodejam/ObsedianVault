# Puntify — Nemi Voce via Vapi (tracciamento chiamate + scalo minuti)

Data: 2026-07-07 · Richiesta Stefano (Telegram msg 5434): funzione chiamata da Vapi a fine chiamata per tracciare tutto (inclusi minuti) e scalare sul negozio; chiave per riconoscere il PV + api key. Ha chiesto di valutare un modo migliore prima di sviluppare.

## Contesto
Nemi Voce (telefonia) finora è solo marketing (no backend). Vapi = piattaforma voice AI che gestirebbe le telefonate. Serve integrare Vapi → Puntify per tracciare chiamate e consumare minuti dal saldo del negozio (riusa `shop_nemi_credits` creata il 2026-07-06). Fa diventare REALI: "Consumato" del tab Utilizzo AssistantAI + box "Chiamate Nemi Voce" della dashboard Panoramica (oggi placeholder).

## Architettura PROPOSTA (migliore della visione letterale)
1. **Webhook Server URL** (non "funzione che Vapi chiama"): Vapi a fine chiamata invia `end-of-call-report` al nostro endpoint (POST /api/vapi/webhook). Pattern nativo, con retry, contiene durata/minuti, costo, endedReason, transcript, recording. (Vapi manda anche status-update, tool-calls, assistant-request, transcript, ecc.)
2. **Auth = unico segreto condiviso Vapi↔Puntify** (header `X-Vapi-Secret` / Bearer, configurato nel Server URL di Vapi), verificato server-side. NON api key per-negozio.
3. **Identificazione PV via metadata/mapping**: shop_id nei `metadata` della chiamata/assistant Vapi, oppure mapping assistantId/phoneNumberId → shop nel DB (tabella `shop_vapi_config`). Il webhook lo restituisce → shop noto lato server, non spoofabile. Il negozio non maneggia chiavi.
4. **A fine chiamata**: idempotente per id chiamata Vapi (retry non scalano 2 volte) → log in tabella `nemi_calls` (shop_id, vapi_call_id, direction, duration, ended_reason, cost, started/ended, transcript ref) + decremento minuti atomico su `shop_nemi_credits.consumed_minutes` (RPC).
5. **Depletion**: quando il negozio esaurisce i minuti, bloccare le chiamate successive (pre-call check via assistant-request, o disattivare il numero).

## Perché è meglio della visione letterale di Stefano
- Webhook > funzione custom: nativo, affidabile, retry, payload completo.
- 1 segreto condiviso > api key + chiave per-PV: meno segreti, più sicuro, nessun attrito lato negozio.
- metadata/mapping > chiave fornita dal negozio: server-side, non spoofabile.
- Riusa shop_nemi_credits + riempie i placeholder Consumo/Chiamate con dati REALI.

## Decisioni/serve da Stefano (build-phase)
- Account Vapi.
- Provisioning: un assistant/numero Vapi PER negozio (consigliato, shop_id nei metadata, serve anche per routing inbound) vs uno condiviso con metadata per-chiamata.
- Arrotondamento minuti (per chiamata al minuto superiore? consigliato) e tariffa (coerente coi pacchetti Nemi: R1 0,36 → R4 0,29 €/min).
- Cosa loggare per chiamata (durata, inbound/outbound, esito, ora, costo, transcript).

## Decisioni CONFERMATE Stefano (2026-07-07 msg 5436)
- 1 numero per negozio (shop_id nei metadata + mapping numero→negozio).
- Minuti arrotondati al minuto SUPERIORE (ceil).
- Salvare TUTTO della chiamata (durata, esito, ora, costo, registrazione) + TRASCRIZIONE in nemi_calls.
- BLOCCO guidato dal credito PUNTIFY (non Vapi): via evento `assistant-request` (Vapi chiede prima di rispondere quale assistant usare) → il nostro server trova il negozio dal numero, legge saldo shop_nemi_credits:
  · saldo>0 → ritorna config Nemi Voce + `maxDurationSeconds = minuti_residui×60` (la chiamata non sfora il credito, Vapi chiude da sola).
  · saldo≤0 → non serve: messaggio breve "credito esaurito, ricarica" + hangup (o reject).
  · Rete di sicurezza: a fine chiamata se saldo=0, staccare assistant dal numero via API Vapi; riattaccarlo alla ricarica.

## Cosa costruisco (lato Puntify)
Endpoint webhook: `assistant-request` (gating saldo + maxDuration) + `end-of-call-report` (traccia+scala minuti idempotente per vapi_call_id). Tabelle `nemi_calls` + `shop_vapi_config` (numero/assistant→shop). Verifica saldo, scalo consumed_minutes (ceil), auth X-Vapi-Secret.
## Cosa serve lato Vapi (Stefano/insieme)
Account Vapi, numeri per negozio, Server URL + segreto condiviso sugli assistant, shop_id nei metadata.

## Stato
- Meccanismo blocco spiegato + design confermato (msg 5437). Attendo "parti" di Stefano per costruire la parte Puntify; per il collegamento reale servirà accesso/segreto Vapi.
- Fonti Vapi: docs.vapi.ai/server-url/events, /server-url/server-authentication.
