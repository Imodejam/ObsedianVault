# Puntify — Social Intelligence (piano implementativo)

[2026-05-20] Analisi del prompt + screenshot di Stefano per nuova area "Social Intelligence" in Puntify.App merchant.

## Obiettivo
Centro operativo AI-first per reputazione, engagement, recensioni e pubblicazione multi-social. UX coerente con la pagina Clienti redesignata (cfg-page, ariosa, Apple/Linear-like).

## Cosa mostra lo screenshot
Layout merchant pattern (back + titolo "Social Intelligence" + sottotitolo) con 2 CTA in alto a destra: **AI Assistant** (button outline) + **Pubblica contenuto** (button dark).

- **4 KPI cards** orizzontali con icona soft-color + valore grande + variazione vs ieri + sparkline:
  - Sentiment generale (92% Positivo, viola)
  - Engagement totale (18.4K Interazioni, viola)
  - Reputazione Google (4.6 stelle, logo Google)
  - AI Score (85/100, verde)
- **Chip filtri social** con contatori: Tutti(128), Instagram(42), TikTok(21), Facebook(28), Google Maps(18), "…"
- **Filtra** + dropdown range "Ultimi 7 giorni" a destra dei chip
- **Feed centrale** con card contenuto: thumbnail sinistra + social-icon overlay + autore/data + caption + metriche (like/commenti/share) + badge sentiment colorato (positivo verde / neutro grigio) + "Vedi dettagli" + kebab menu
- **Barra AI inline** sotto ogni card, 3 toni:
  - "Insight AI" verde (osservazione positiva)
  - "Attenzione AI" ambra + bottone "Analizza commenti" (criticità)
  - "Suggerimento AI" viola + bottone "Crea Reel" (azione)
- **Sidebar destra**:
  - "Alert e criticità" con 3 alert + badge priorità (Alta/Media/Bassa)
  - "Azioni rapide" (Genera contenuto AI, Rispondi ai commenti, Calendario editoriale, Report performance)

## Funzionalità richieste — verifica fattibilità

### Già nello stack
- Pattern UI: cfg-page + cfg-actionbar + chips filtro (rispecchio Clients)
- Caddy reverse-proxy, systemd, dotnet watch dev
- Supabase per storage entità

### Richiedono integrazioni esterne
| Piattaforma | API ufficiale | Auth | Approval | Limiti |
|---|---|---|---|---|
| Instagram Business | Meta Graph API | OAuth Facebook | App review obbligatoria | rate limits, no DM ricerca |
| Facebook Page | Meta Graph API | OAuth | App review | idem |
| TikTok Business | TikTok for Business | OAuth | Whitelist | post + insights limitati |
| LinkedIn | Marketing Dev Platform | OAuth | Partner review | scoping ristretto |
| Threads | Threads API | OAuth (in beta) | Limitato | ingest limitato |
| X (Twitter) | X API v2 | OAuth | A pagamento (Basic 100$/mese+) | quote stringenti |
| YouTube | YouTube Data API v3 | OAuth | Quota gratis | OK lettura |
| Pinterest | Pinterest API v5 | OAuth | OK | OK |
| Google Business Profile | Google Business Profile API | OAuth Google | OK, già usato per Calendar | review + insights |
| TripAdvisor | Content API limitata | API key | Approval | accesso difficile |
| Trustpilot | Business API | OAuth | OK | piano business |
| WhatsApp Business | Cloud API Meta | Token | OK | costo per conversazione |
| Messenger | Meta Graph API | OAuth | App review | OK |
| Instagram DM | Graph API | OAuth | App review | scope dedicato |

**Implicazione**: il "collega tutti i social" richiede una OAuth-broker page che gestisca i 14 provider, ognuno con flow proprio. Lavoro non triviale, soprattutto per Meta App review (settimane).

### Richiedono LLM
- Sentiment classification (positivo/neutro/negativo/polemico/aggressivo/ironico/entusiasta)
- Topic detection (servizio lento, prezzo, cibo freddo, ecc.)
- Criticità detection (trend negativi)
- AI insight generation per card (testo personalizzato)
- AI Assistant conversazionale
- Risposta AI a recensioni (diplomatica/empatica/ironica/professionale)
- Generazione contenuti (post, caption, hashtag)
- Grammar/branding check su post
- AI Score (composito)

**Vincolo memoria progetto**: Anthropic API HTTP è riservata a Concilium per Puntify.

**Raccomandazione LLM (2026-05-20)**: split a 2 livelli su **OpenAI**:
- **Tier 1 batch** — sentiment, topic detection, classificazione: `gpt-4o-mini` ($0.15/M input, $0.60/M output). Strutturato JSON, throughput alto.
- **Tier 2 qualità** — insight generation, risposte AI a recensioni, AI Assistant, content gen: `gpt-4o` ($2.5/M input, $10/M output). Italiano top, function calling per Assistant.

Stima MVP (1000 contenuti/giorno + 50 insight + 20 risposte + 100 chat): ~75 USD/mese.

Alternative valutate e scartate:
- Gemini 2.0 Flash (Google): piano B per tier batch se ottimizzazione costi. Italiano leggermente sotto su tone.
- Mistral (EU/GDPR): solo se priorità data residency
- Llama locale: scartato, pro-open è KVM senza GPU dedicata
- Anthropic: bloccata (Concilium)

### Richiedono backend nuovo (lato Puntify.Server)
- Tabelle: `social_connections` (provider, account_id, token cifrato, scope, expiry), `social_posts` (provider, post_id, type, text, media, metrics, sentiment, topics, fetched_at), `social_comments`, `social_reviews`, `social_alerts`, `social_drafts`, `social_schedules`, `ai_insights`
- Job scheduler: cron 24h per sync provider; webhook near-real-time per recensioni negative
- AI pipeline: queue worker che processa nuovi contenuti (sentiment + topic + insight)
- Publishing API: composer multi-target, schedule, ricorrente

## Piano implementativo per fasi

### Fase 0 — Decisioni preliminari (Stefano)
1. **LLM provider** per Puntify (non Anthropic)
2. **Budget** per API a pagamento (X, Meta review, WhatsApp conversation, LLM tokens)
3. **Priorità piattaforme** per MVP — propongo: Google Business + Instagram + Facebook (coperture immediate, già OAuth Google esistente per Calendar)
4. **AI Score** — formula proprietaria: pesi su reputazione/engagement/costanza/qualità/risposta/sentiment
5. **AI Assistant**: chat in panel laterale o pagina dedicata?
6. **Account model**: una connessione per shop o per merchant globale?

### Fase 1 — Skeleton UI + dati Google (2 settimane)
- Route `/merchant/shop/{ShopId}/social` con layout cfg-page coerente con Clients
- Componenti: header CTA, KPI cards, filtri pills, feed, sidebar alert+azioni
- File CSS dedicato `social.css` (palette uguale a clients.css)
- Integrazione Google Business Profile API (riuso OAuth esistente, scope ampliato `business.manage`)
- Sync recensioni Google nel feed con sentiment via LLM
- KPI calcolati: Reputazione Google reale, altri placeholder
- CTA "Pubblica contenuto" e "AI Assistant" come placeholder visivi (modali vuoti)

### Fase 2 — Meta (Instagram + Facebook) (2-3 settimane)
- OAuth Facebook + selezione pagina + Instagram Business connesso
- Sync post + commenti + insights
- Card feed estese (immagini, video preview)
- Avvio app review Meta in parallelo (è il blocking time più lungo)

### Fase 3 — AI pipeline (2 settimane)
- Worker server-side per sentiment + topic + insight generation
- Tabella `ai_insights` per card
- Alert detection (trend negativi, picco commenti negativi)
- Sidebar alert popolata
- AI Score calcolato con formula concordata

### Fase 4 — Publishing multi-social (3 settimane)
- Composer Step 1-5 (testo+media → AI enhance → select social → preview live → publish/schedule)
- Scheduling con cron
- Calendario editoriale view
- AI generation di post (CTA, hashtag, caption)

### Fase 5 — Restanti piattaforme (2-3 settimane)
- TikTok, LinkedIn, Threads, X, YouTube, Pinterest, TripAdvisor, Trustpilot
- WhatsApp/Messenger/IG DM (richiede WhatsApp Cloud API)

### Fase 6 — Advanced (2 settimane)
- Competitor analysis (input manuale dei competitor → scrape/API)
- Trend analysis
- AI Assistant conversazionale completo
- Notifiche push native

**Stima totale: 13-17 settimane di sviluppo full-time**, escluso il tempo di app review Meta/TikTok (parallelo, 2-6 settimane di attesa).

## MVP minimale consigliato (4-5 settimane)
Per validare la value proposition senza investire 4 mesi:
- Solo Google Business + Instagram + Facebook
- UI completa secondo screenshot
- Sentiment + insight inline (LLM scelto)
- Alert sidebar basico
- Publishing solo IG+FB
- AI Score con formula iniziale
- Nessuna competitor analysis, nessun DM, nessun TikTok in MVP

## Decisioni grafiche da rispettare (dallo screenshot)
- Sfondo `#F5F5F7` (uguale a Clients)
- Card bianche radius 20px, ombre soft
- KPI icon soft (viola/verde) come Clients
- Sparkline mini chart sulla destra del KPI numero
- Chip filtri con badge contatore tra parentesi
- Insight AI inline: 3 varianti soft (verde/ambra/viola) con icona sparkle e CTA
- Badge sentiment "Positivo"/"Neutro" come pill verde/grigio dentro la card
- Sidebar destra fissa solo se layout XL; sotto threshold passa sotto

## Rischi
- App review Meta può bocciarsi più volte → buffer di settimane
- Costi LLM possono lievitare con sync 24h su tutti i contenuti
- TripAdvisor/Threads API ancora deboli
- WhatsApp Business API ha costi per conversazione

## Documenti collegati
- [[wiki/projects/puntify|Puntify]] — pagina progetto principale
- [[wiki/projects/puntify-design-system|Design System]]

