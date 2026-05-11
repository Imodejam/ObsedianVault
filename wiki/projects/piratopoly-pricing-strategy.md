# Piratopoly · Strategia prezzi V1

**Status:** strategia approvata da Stefano sul GDD 2026-05-08. Copy finali allineati su [[piratopoly-web|vetrina]] e [[piratopoly|app PWA]] in 5 lingue. Implementazione SKU/Stripe da fare (vedi [[piratopoly-pricing-v1-execution]]).

**Documento sorgente:** [[../../raw/docs/piratopoly/pricing-v1-2026-05-08.md|GDD Modello Commerciale e Pricing V1]].

## Posizionamento

Piratopoly è venduta come **esperienza esperienziale urbana** (non gioco gratis con micro-transazioni). Il prezzo deve far percepire:
- la mappa come **prodotto editoriale curato** (paragonabile a un audio-tour premium tipo Wandar/Voicemap a 5–15 €);
- il Pirate Pass come **abbonamento da turista frequente / local explorer** (paragonabile a Headspace o Calm in fascia 8–12 €/mese);
- ROI tangibile: prezzo mappa + voucher partner ≥ valore percepito.

Tono nel copy: "trasparenza piena, nessuna sorpresa nello scrigno" — niente trial subdoli, niente paywall opachi.

## Catalogo prezzi V1

### Mappe à la carte

| SKU | Tappe | Validità | Prezzo | Descrizione (it) | CTA (it) |
|---|---|---|---|---|---|
| **Mini Mappa** | 3–4 | 24h | **5,99 €** | Ideale per una passeggiata breve o una prima prova. | Scegli Mini |
| **Mappa Classica** ⭐ | 5–7 | 48h | **11,99 €** | La rotta perfetta per scoprire una città con calma. | Scegli Classica |
| **Mappa Estesa** | 8–10 | 72h | **14,99 €** (8,99 € con Pass) | Per chi vuole vivere una giornata intera da esploratore. | Scegli Estesa |
| **Pack Esploratore** | 3 mappe (scelta libera) | 12 mesi | **24,99 €** | Perfetto per chi vuole giocare in più città o regalare una rotta. | Acquista Pack |

⭐ "Mappa Classica" è il tier **featured** con badge "La più scelta" — è lo SKU che vogliamo spingere come default (sweet-spot durata/prezzo/valore).

### Subscription "Pirate Pass"

| Piano | Prezzo | Tag commerciale | CTA |
|---|---|---|---|
| **Mensile** | 11,99 €/mese | "Più flessibile" | Scegli mensile |
| **Annuale** | 79 €/anno | "Più conveniente · Risparmi il 45%" | Salpa per un anno |

Confronto Free vs Pirate Pass (7 feature):
1. Mappe catalogo (Mini + Classica): Free `A pagamento` · Pass `Tutte incluse`
2. Esplorazione Libera: Free `1 a settimana, max 3 tappe` · Pass `Illimitata, max 5 tappe`
3. Voucher partner in EL: Free `No` · Pass `Sì`
4. Punti classifica esploratori: Free `No` · Pass `Sì`
5. Mappa Estesa: Free `€14,99` · Pass `€8,99 (-40%)`
6. Mappe stagionali (early access): Free `No` · Pass `Sì, 3 giorni prima`
7. Badge Capitano + cornice profilo: Free `No` · Pass `Sì`

### Captain's tip (cross-sell ricorrente)
> "Se prevedi più di 6 mappe l'anno, conviene il Pirate Pass annuale a 79 €."

Math: 6 × 11,99 € (Classica) = 71,94 €. A 7 mappe → 83,93 €, oltre i 79 € Pass. Il break-even reale è ~6,6 mappe/anno: punto sotto-il-quale conviene à la carte, sopra-il-quale conviene Pass.

## Tassonomia decisioni di prezzo (chi ha deciso cosa)

| Decisione | Data | Owner | Note |
|---|---|---|---|
| 4 SKU mappa + 2 piani Pass | 2026-05-08 | Stefano (GDD V1) | Soppianta il pricing V0 ancora nel codice |
| €5,99 / €11,99 / €14,99 / €24,99 | 2026-05-08 | Stefano | Conformi a soglie psicologiche standard, scala lineare ×2 fra tier |
| Sconto -40% Estesa con Pass | 2026-05-08 | Stefano | Incentivo upgrade Pass per chi gioca rotte lunghe |
| Pass annuale = "Risparmi 45%" | 2026-05-08 | Stefano | 12 × 11,99 = 143,88 € → 79 € = -45.1% effettivo |
| Pack 3 mappe = picker checkout | 2026-05-02 | Stefano | Cliente sceglie 3 mappe specifiche al checkout, entitlement perpetuo |
| Replay multiplier 1×/0,5×/0× | 2026-05-02 | Stefano | Una mappa acquistata si rigioca infinite volte, le Piastre decrescono |
| Annual Pass = mappe illimitate | 2026-05-01 | Stefano | Annual Pass non ha cap mappe (mensile sì) |
| 1 mappa free = 8.000 Piastre | 2026-05-02 | Stefano | Conversione punti→sconto, allineata alla soglia "Predone" |

## Strategia Piastre (moneta interna)

| Counter utente | Cosa fa | Decremento |
|---|---|---|
| `users.total_score` | Lifetime, determina il rank | **Mai decrementato** |
| `users.available_piastre` | Spendibili nel marketplace per scontare mappe | Decrementa al checkout |
| `users.spent_piastre` | Lifetime speso | Cumulativo |

**Invariante:** `total_score = available_piastre + spent_piastre`.

**Tassi di conversione** (Stefano 2026-05-02):
- 1 mappa singola = 8.000 Piastre (≈ 5–6 mappe completate a 1ª run)
- Pack 3 mappe = 21.000 Piastre (giusto sotto il 3× per dare valore al pacchetto)

Il replay multiplier (1×/0,5×/0×) impedisce farming sulle stesse mappe.

UX prevista (TODO con flusso pagamenti):
- Marketplace card mappa: 2 bottoni → "Acquista 7,99 €" e "🪙 8.000 Piastre"
- Profilo: badge "🪙 X Piastre disponibili" cliccabile → modale transazioni
- Migration TODO: ALTER `users` ADD `available_piastre`, `spent_piastre` (backfill `available = total_score`, `spent = 0`)

## Modalità "test" (creator)

Decisione 2026-05-02: un creator può giocare gratuitamente le proprie mappe in `mode='test'`. La sessione **non genera** Piastre / Carte / `plays_count` / voucher / `maps_completed`. Lo scopo è validare la mappa sul campo prima della pubblicazione.

## Decisioni aperte (da chiedere a Stefano prima dell'implementazione SKU)

1. **Migrazione utenti già acquirenti a 7,99 €**: sconto continuità o nessuna azione?
2. **Stripe live già configurato per Mappa Singola V0**: riuso `price_id` o ne creo uno nuovo per V1?
3. **Localizzazione prezzi**: € fissi o multi-currency dal lancio?
4. **Cap tappe Estesa**: 8–10 fisso o range editoriale?
5. **Trigger referral**: basta Demo o serve acquisto reale?
6. **Gift Pass annuale**: chi paga il rinnovo dopo 12 mesi (utente regalato o annullamento)?

## Vetrina vs realtà del codice

| Cosa | Vetrina (oggi) | App PWA (oggi) |
|---|---|---|
| Catalogo mostrato | 4 tier V1 + Pass mensile/annuale | Solo Mappa Singola 7,99 € + Pack3 18,99 € + Season Pass 14,99 € (V0 legacy) |
| Pirate Pass | Card commerciale completa | Non esiste come subscription Stripe |
| Sconto Estesa con Pass | Mostrato nei prezzi (€8,99) | Non implementato |
| Piastre come moneta | Non mostrato in vetrina | `users.available_piastre` ancora da introdurre via migration |

**Gap implementativo**: la vetrina **comunica** il pricing V1 ma il codice PWA fattura ancora V0. La transizione è descritta in [[piratopoly-pricing-v1-execution|Pricing V1 — Piano di Esecuzione]] (5 fasi, in attesa OK Stefano per partire dalla Fase 1: Catalogo).

## Copy multilingua

I micro-copy finali per ognuno dei 4 tier e 2 piani Pass sono nei file `content/i18n/{it,en,es,de,fr}.json` della vetrina (chiavi `pricing.tiers.*` e `piratePass.*`). Tradotti nativamente per ogni lingua con lessico pirata coerente (Set sail / Zarpa / In See stechen / Lever l'ancre).

## Link correlati
- [[piratopoly|Piratopoly (PWA)]]
- [[piratopoly-web|Piratopoly Web (vetrina)]]
- [[piratopoly-pricing-v1-execution|Pricing V1 — Piano di Esecuzione]]
- Doc sorgente: `raw/docs/piratopoly/pricing-v1-2026-05-08.md`
