# Audit SEO Puntify — Search Console
Periodo: 20/06–20/07/2026 (28 gg) · property `sc-domain:puntify.it` · generato 23/07/2026

## 1. Quadro generale
| Metrica | Periodo attuale | Periodo prec. (21/05–19/06) | Δ |
|---|---|---|---|
| Click | 52 | 13 | **+300%** |
| Impression | 1.248 | 124 | **+906%** |
| CTR | 4,2% | 10,5% | −6,3 pt |
| Posizione media | 13,8 | 15,0 | +1,2 (migliora) |

**Lettura:** crescita forte (impression x10, click x4) e posizione media in miglioramento. Il calo di CTR è fisiologico: più impression arrivano da posizioni basse (pagina 2), che diluiscono il tasso di click. Sito giovane in fase di espansione: bene.

- **Device:** Desktop 780 imp / Mobile 459 imp. CTR mobile (5,2%) > desktop (3,6%).
- **Paesi:** Italia domina (577 imp, 40 click). Estero con impression ma **0 click**: USA 199, Australia 51, Olanda 34, UK 30 — pagine multilingua/demo che si posizionano fuori target senza convertire (bassa priorità).

## 2. Il dato chiave: branded vs non-branded
| | Click | Impression | CTR |
|---|---|---|---|
| **Branded** ("puntify") | 27 | 94 | 29% |
| **Non-branded** | 3 | 313 | <1% |

Il non-branded genera già 313 impression ma quasi zero click: **c'è visibilità, ma le pagine rankano troppo in basso (pag. 2) per raccogliere click.** Far salire i contenuti non-branded è la leva #1 di crescita.

## 3. Problemi trovati
### 🔴 A) Staging cat.puntify.it indicizzato — RISOLTO (parziale)
`cat.puntify.it` (collaudo) era in indice e intercettava **5 click su 52 (~10%)** in posizione 3, mandando gli utenti su un login 401.
- **Fatto:** aggiunto `X-Robots-Tag: noindex, nofollow` nel Caddy di collaudo (attivo, verificato live). Config: `/opt/ops/caddy/Caddyfile`, backup `.bak.pre-catnoindex-20260723`.
- **Da fare (solo UI, serve Stefano):** Search Console → *Rimozioni* → "Nuova richiesta" → prefisso `https://cat.puntify.it/` → rimozione temporanea. Effetto immediato (nasconde per 6 mesi); nel frattempo il basic-auth + noindex fanno la deindicizzazione definitiva.

### 🟠 B) Pagine demo pesano il 24% delle impression, quasi nessun click
I negozi demo (barbiere-testaccio, frutta-fresca-ostiense, scarpe-stile-eur, officina-portuense…) valgono **419/1.734 impression (24%) ma solo 7 click**. Si posizionano su query locali reali ("barbiere testaccio", "ferramenta tiburtina", "meccanico via portuense") ma sono negozi finti → traffico sprecato e diluizione tematica.
- **Proposta:** valutare `noindex` sulle pagine dei negozi demo (restano visibili in app come esempio, ma fuori da Google). Da decidere con Stefano.

### 🟢 C) Blog: tecnicamente a posto, solo giovane
10 articoli (pubblicati 12/06), 100 URL in sitemap, `index,follow`, title buoni. Ancora ~0 impression: normale a 6 settimane. Leve: link interni dagli articoli alle pagine settore/prezzi, promozione (social, newsletter), backlink.

## 4. Falsi allarmi (verificati, NON sono problemi)
- `/it/prezzi` (pos 1,6), `/it/termini`, `/it/faq` risultano a "0% CTR": rankano tutti per la query **branded "puntify"** dove il click se lo prende la home. È normale occupazione di SERP branded, non un problema di title/meta.

## 5. Opportunità concrete (query già a pag. 2 da aggredire con contenuti)
Keyword commerciali reali dove siamo già visibili ma troppo in basso:
| Query | Pos | Imp | Azione |
|---|---|---|---|
| fidelity card calzature | 14,6 | 13 | Pagina settore calzature/abbigliamento + articolo "carte fedeltà per negozi di scarpe" |
| elimina code personalizzati | 13,2 | 12 | Rafforzare pagina /elimina-code |
| solution gestion parfumerie (FR) | 11,0 | 3 | Ottimizzare /fr/settori/profumerie |
| logiciel pneumologue (FR) | 13,5 | 8 | Pagina settore studi medici in FR |
| bedding store software (EN) | ~28 | 6 | Settore in EN |

## 6. Prossimi passi consigliati
1. **[Stefano, 2 min]** Rimozione `cat.puntify.it/` in Search Console (immediato).
2. **[decidere]** `noindex` sui negozi demo.
3. **[contenuti]** Link interni blog→settori/prezzi; ottimizzare title/meta pagine settore per le keyword sopra.
4. **[GA4]** Sbloccare accesso dati (vedi sotto) per unire comportamento on-site (bounce, conversioni, sorgenti) all'audit di ranking.

## 7. Google Analytics 4 — stato
Service account aggiunta da Stefano, ma il progetto Cloud `puntify` ha le **API Analytics disattivate** (Admin + Data API). Il SA non ha i permessi per abilitarle.
- **Serve Stefano (una tantum):** Google Cloud Console → progetto *puntify* (654939480438) → abilitare **"Google Analytics Data API"** (e opz. "Google Analytics Admin API").
- **+ ID proprietà numerico:** GA4 → Amministrazione → colonna *Proprietà* → *Impostazioni proprietà* → "ID proprietà" (numero tipo 123456789, **non** G-KFC8WKG9LT che è il measurement id).
- Con questi due passi tiro i dati GA4 in autonomia.
