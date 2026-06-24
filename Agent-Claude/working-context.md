# Working context

## Sessione 2026-06-24 — Piracity-web foto WebP + caching
Richiesta Stefano (Telegram): "le foto in tutta la vetrina tutte webp e cacheate" → vetrina = **piracity-web** (Next.js :6010).

### Fatto
- **Conversione file**: nuovo `scripts/convert_to_webp.py` (usa `minio_webp.to_webp`, PIL, q=82). Convertiti 731 file in `public/assets/{photos,auto/cities,auto/stages}` → `.webp`, originali rimossi. Risparmio ~1.3 GB. 1 sola fallita: `teatro-rossini.jpg` (download troncato/corrotto) → rimossa + `photo_url=NULL` nel DB così il photo-fetcher la riprende.
- **DB** (piracity_cat, schema piracity): `UPDATE` photo_url estensioni `.jpg/.jpeg/.png` → `.webp` su `cities` (67) e `stages` (600). Residui non-webp = 0.
- **Refs landing**: componenti `components/home/landing/*` (Hero, WhatIsIt, Adults, Events, Family, Technology, FinalCta, HowToPlay, AudienceCarousel) → `/assets/photos/*.webp`.
- **Caching** (`next.config.mjs`): `headers()` → `/assets/:path*` `Cache-Control: public, max-age=31536000, immutable`; override `/assets/auto/:path*` `max-age=86400, stale-while-revalidate=604800` (foto auto-fetch riscaricabili). `images.minimumCacheTTL=31536000` per la cache dell'optimizer next/image.
- Restart `piracity-web.service`. Verificato: header corretti, next/image serve AVIF/WebP ai browser (negoziazione Accept).

### Note
- next/image già ottimizzava i PNG in webp/avif on-the-fly; ora anche i sorgenti sono webp (più leggeri, optimizer più veloce) e gli static asset hanno cache lunga.
- photo-fetcher.py già converte in webp i nuovi download (fallback .jpg solo se PIL fallisce); la massa di .jpg residui era di run vecchi senza PIL.

### Prossimi passi
- Verificare lato Stefano (hard refresh) che le foto si vedano su home/città/mappe.
- Photo-fetcher ripopolerà teatro-rossini.

---
## Storico (2026-06-22)
Piracity-web (vetrina): riprogettazione homepage — pivot da tema dark/pirata a LANDING LUMINOSA familiare (stile Apple pulizia + Disney calore), per famiglie/bambini/amici/compleanni/turisti.

---
## Task in attesa: creare città+mappa TROPEA (2026-06-24)
Stefano vuole città Tropea + mappa relativa con 7 tappe (Tier1: Santuario S.Maria dell'Isola, Belvedere Piazza del Cannone, Affaccio del Corso, Spiaggia della Rotonda; Tier2: Cattedrale Maria SS. di Romania, Museo Civico Diocesano, Largo Galluppi). Foto città in arrivo.
Chiesto scope (msg 4440): (1) IT-first poi traduzioni vs subito 6 lingue; (2) bozza+prezzo+mood. ATTENDO risposta.

### Schema DB piracity (per build Tropea) — replicare struttura Cosenza
- cities: name, country, country_code='IT', lat, lng, slug, active, maps_count, photo_url
- city_descriptions: (city_id, lang, text, source_lang) — 6 lingue it/en/es/de/fr/nl
- maps: title, city_id, creator_id(=890d2531-5575-4f21-852f-be3b18042ad7 official come Cosenza), type='permanent', status='published'(o draft), is_official=true, price=11.99, days_count, stages_count, slug, season_tag
- map_descriptions: (map_id, lang, text, kind, is_ai_generated, source_lang) — kind in (public, internal, title) × 6 lingue = 18 righe. public=vetrina teaser, internal=apertura mappa, title=titolo localizzato
- map_days: (map_id, day_number, mood_id). mood Arte&Storia=6a41a5fc-55a0-416e-8b84-2b70820eb5fb
- stages: city_id, name, description(NOT NULL), lat, lng, slug, address, duration_min, access, type, paid_amount, photo_url
- map_day_stages: (map_day_id, stage_id, order_index, ai_hint)
- stage_descriptions: (stage_id, lang, intro, body, source_lang) — scheda tappa template, 6 lingue
- stage_content_i18n: (stage_id, lang, subtitle, narrative, curiosities jsonb, next_hint, briefing_teaser, location_label) — contenuto in-game, 6 lingue
- quiz_pool: (stage_id, question, options jsonb, correct_index, explanation, lang, difficulty, kind, validation_status) — indovinelli per lingua
- Prompt narrativa: wiki/projects/piracity-map-story-prompt.md ; scheda tappa: piracity-tappa-template.md ; 6 lingue obbligatorie
