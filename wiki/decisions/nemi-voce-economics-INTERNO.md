# Nemi Voce — Economics (INTERNO, NON PUBBLICARE)

> ⚠️ Dati riservati Stefano. NON devono comparire sulla Vetrina né in nessuna pagina pubblica. Solo per decisioni interne/pricing.

## Modello prezzi pubblico (fonte di verità 2026-07-04)
- **Nemi Voce** = assistente telefonico AI, **incluso nell'abbonamento Puntify** (nessun canone aggiuntivo).
- Canone: quello dell'abbonamento Puntify (9,99 €/mese o 99,99 €/anno **per punto vendita**).
- **Attivazione Nemi Voce**: 49 € una tantum **per punto vendita** (no sconti volume; sconti multi-sede −10%/−20% valgono sull'abbonamento).
- **Consumo** a ricariche (IVA esclusa):
  | Ricarica | Minuti | €/min |
  |---|---|---|
  | 25 € | 70 | 0,36 |
  | 50 € | 150 | 0,33 |
  | 100 € | 330 | 0,30 |
  | 200 € | 690 | 0,29 |
- Crediti validi 6 mesi. Dopo 3 mesi senza credito il numero dedicato viene rilasciato (riattivazione gratuita, nuovo numero).
- Tutti i prezzi IVA esclusa.

## Costi vivi (stack: Vapi + Telnyx + ElevenLabs, senza prompt caching)
- Chiamata: ~0,18–0,20 €/min (worst case 0,20)
- Numero Telnyx: ~1–2 €/mese per merchant
- COGS chatbot testuale: ~3 €/mese per merchant
- Con prompt caching + ElevenLabs Flash: ~0,12–0,13 €/min

## Margine per pacchetto (worst case 0,20 €/min)
| Pacchetto | €/min | Margine minimo |
|---|---|---|
| 25 € | 0,36 | 44% |
| 50 € | 0,33 | 40% |
| 100 € | 0,30 | 34% |
| 200 € | 0,29 | 31% |

## Perché non va mai in perdita sul singolo merchant
- Ogni minuto venduto è sopra il costo worst case (pavimento 31%).
- Attivazione 49 € copre ~2 anni di numero Telnyx.
- Merchant annuale a consumo zero: +34 €/anno (canone − fissi).
- Merchant che attiva e sparisce: +49 € − max 6 € di numero (rilascio a 3 mesi).
- Prepagato: incasso sempre anteriore al costo Vapi.
- Crediti scaduti (6 mesi) = margine puro.

## Rischi e guardrail
1. Costo/min variabile → monitorare costo medio reale da dashboard Vapi; se >0,22 €/min per 2 settimane consecutive → intervenire (caching, TTS, prompt più corto).
2. Prompt caching = +16 punti di margine (41% → 57%). **Priorità tecnica n.1**, prima di spingere le vendite.
3. Break-even aziendale: fissi infra ~50–100 €/mese → servono 3–5 merchant attivi per coprirli.
4. Stripe fee (~1,5% + 0,25 €): incide di più sulle ricariche piccole; trascurabile ma da includere nei report margine.
