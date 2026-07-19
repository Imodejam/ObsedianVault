# Puntify — Social Studio (stato + interventi 19/07/2026)

Modulo esercente per recensioni + post social + sentiment. Pagine in `Puntify.App/Pages/Merchant/SocialStudio/` (SocialStudio.razor feed+composer, Settings.razor, Calendar.razor). Server: `Puntify.Server/Services/SocialStudio/*` + `Controllers/SocialStudioController.cs`. Tabelle: social_reviews, social_posts, social_drafts, social_alerts, social_sync_state (schema in Puntify.Server/Database/social_studio_schema.sql + social_drafts_schema.sql).

## Stato attuale (mappa 19/07)
- **Feed/Dashboard**: OK. KPI sentiment/engagement/reputazione, filtri provider+sentiment+periodo, sparkline.
- **Crea post (composer 5 step)**: OK. Brief -> varianti AI -> piattaforme -> preview -> scheduling. Salva in social_drafts (draft/scheduled). POST /api/shop/{id}/social/drafts.
- **Modifica post**: MANCANTE. Nessun PATCH, nessuna UI edit (il composer crea solo bozze nuove).
- **Sentiment**: OK come struttura. AI-driven (prompt in SocialStudioController ~462-489), 7 valori (positivo/neutro/negativo/polemico/aggressivo/ironico/entusiasta) + score 0-1 + summary + topics. Hardened con CHECK (migration 20260719_social_sentiment_check.sql). DA VERIFICARE: che l'enrichment giri in automatico sugli import (le review importate potrebbero restare sentiment NULL).
- **Import**: solo Google Business (GoogleBusinessService.SyncReviewsAsync). SocialSyncBackgroundService gira ogni 6h (Social:SyncIntervalMinutes=360, hardcoded, non da UI). Scarica TUTTE le review (nessun limite profondita'). Salva author_photo/media_url come URL esterno (NON scarica immagini). OAuth altri provider = "in arrivo".
- **Pubblicazione reale IG/FB/TikTok**: STUB (PublisherService). Fuori scope ora (serve OAuth+API provider).

## Interventi in corso (agent, 19/07) — requisiti Stefano
A) **Modifica bozza**: PATCH /drafts/{id} + client UpdateDraftAsync + composer precompilato (stato _editingDraftId) + azione "Modifica" sulle card. Immagini via URL.
B) **Profondita' 1 anno**: cutoff now-12mesi in SyncReviewsAsync.
C) **Cadenza+profondita' configurabili per PV**: tabella puntify.shop_social_settings (sync_interval_hours default 6, import_history_months default 12) + migration 20260721_social_settings.sql. Background service: tick frequente + per-shop "e' due?" su last_synced_at vs intervallo. UI nel tab Social di Settings.razor (3/6/12/24h e 3/6/12/24 mesi) + endpoint GET/PUT /social/settings.
D) **Sentiment sugli import**: verifica/aggiunge enrichment automatico delle righe nuove (batch cap per non bruciare crediti AI).

## Regole fisse
- Immagini SEMPRE via link/URL, mai download (gia' cosi', da mantenere). [[reference_puntify_wasm_secrets]]
- Cadenza default proposta a Stefano: 6h (recensioni locali non a raffica), opzioni 3/6/12/24h. In attesa conferma (procedo coi default, configurabili da UI).
- Non toccare pubblicazione reale/OAuth altri provider.
