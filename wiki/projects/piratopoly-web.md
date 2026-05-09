# Piratopoly Web (sito vetrina)

Sito vetrina marketing per Piratopoly. Repository separato dalla PWA di gioco: `/home/progetti/piratopoly-web` (vs `/home/progetti/piratopoly` per la PWA).

## Obiettivo

Production-ready Next.js 14 marketing site: dark-mode pirate aesthetic, 5 lingue, Sanity CMS hybrid, tutte le sezioni home + template città/mappa, target Lighthouse 90+/95+/95+/100. Stefano deploya via Vercel UI; gli agenti consegnano scaffold + build verificata.

## Deployment dev
- **URL pubblico:** http://piratopoly-dev-web.duckdns.org/
- **Repo:** `/home/progetti/piratopoly-web/` (Next.js standalone, no workspaces).
- **Servizio systemd:** `piratopoly-web.service` (User=`claudebot`, WorkingDirectory=`/home/progetti/piratopoly-web`).
- **Comando:** `npx next dev -p 6010 -H 0.0.0.0`.
- **Porta:** `127.0.0.1:6010` (dietro Nginx).
- **Nginx:** `/etc/nginx/sites-available/piratopoly-dev-web.duckdns.org` → proxy a `:6010`, WS upgrade, listen 80.
- **Restart:** `Restart=always`, `RestartSec=10`. Enabled al boot.
- **Log:** `journalctl -u piratopoly-web -f` (identifier `piratopoly-web`).
- **Comandi:** `sudo systemctl status|restart piratopoly-web`.
- **Note:** è un dev server (`next dev`), non build di produzione. Prod futura: `piratopoly.com` su server dedicato separato.

## Stack

- Next.js 14 App Router (Server Components + streaming SSR)
- TypeScript strict
- Tailwind CSS con design tokens custom (gold/wine/parchment/night, font Cinzel + Inter)
- next-intl per i18n
- Framer Motion (component) + GSAP/ScrollTrigger (scroll-driven hero map trace)
- **Supabase** (`@supabase/supabase-js`, schema `piratopoly`, anon key) — sorgente dati condivisa con la PWA
- Asset reuse: SVG copiati da `/home/progetti/piratopoly/frontend/public/assets/`
- GA4 stubbed per il lancio

> **2026-05-09**: Sanity rimosso (deps + studio + lib + sample-data). La vetrina punta direttamente al Supabase della PWA. Vedi sezione "Architettura dati" qui sotto.

## Lingue
it (default), en, es, de, fr — tutte e 5 al lancio. Copy statico in `content/i18n/{locale}.json`. Le descrizioni delle mappe vengono pescate da `piratopoly.map_descriptions(map_id, lang, text)` con fallback IT.

## Architettura dati (Supabase)

La vetrina **legge** dallo stesso Supabase della PWA, senza scrivere nulla. Filtri standard:
- `maps.status = 'published'`
- `maps.is_official = true` (solo mappe editoriali — niente UGC)
- `cities.active = true`

Anon key (JWT pubblico) sufficiente, RLS già concede SELECT su questi sottoinsiemi. Niente service role lato vetrina.

### Routing slug-first
URL puliti SEO/share:
- `/citta/<city-slug>` (es. `/citta/roma`)
- `/mappe/<city-slug>/<map-slug>` (es. `/mappe/roma/forziere-perduto`)

Slug prodotti dalla migration **015** della PWA: aggiunge `cities.slug` UNIQUE e `maps.slug` UNIQUE per `(city_id, slug)`. Backfill via `backend/scripts/backfill-marketplace-slugs.ts` (slugify NFKD da `name`/`title`).

### `season_tag`
Migration 015 aggiunge `maps.season_tag TEXT NULL`. Stringa (es. `halloween`, `natale`, `harry-potter`) che marca una mappa come stagionale anche quando le tappe sono permanenti. La sezione `SeasonalMaps` filtra `season_tag IS NOT NULL`. Da non confondere con `maps.type='temporary'` (eventi puri).

### Library
- `lib/supabase/client.ts` — singleton anon key
- `lib/supabase/maps.ts` — `fetchOfficialMaps`, `fetchOfficialMapsByCitySlug`, `fetchOfficialSeasonalMaps`, `fetchOfficialMap`
- `lib/supabase/cities.ts` — `fetchActiveCities`, `fetchCityBySlug`
- `lib/supabase/format.ts` — `formatPrice` (Intl, EUR), `formatDurationFromStages` (1-2→Demo, 3-4→24h, 5-7→48h, 8-10→72h)
- `lib/supabase/types.ts` — `ShowcaseMap`, `ShowcaseCity`

### Caching
- `revalidate = 60` su home, `/citta/[slug]`, `/mappe/[citySlug]/[mapSlug]` → ISR 60s.
- Sitemap dinamica (no static export): legge cities+maps da Supabase a request time.

### ENV richiesti
```
NEXT_PUBLIC_SUPABASE_URL=https://supabase-cat.duckdns.org
NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon JWT>
NEXT_PUBLIC_SITE_URL=https://piratopoly.com
NEXT_PUBLIC_GA4_ID=
```

### Cover images
Oggi servite da `https://piratopoly-dev.duckdns.org/assets/webp/maps/...` (server PWA). `next.config.mjs > images.remotePatterns` whitelist sia `piratopoly-dev.duckdns.org` sia `supabase-cat.duckdns.org` (per le cover servite direttamente dallo storage Supabase). Quando si passerà a S3/CDN, aggiungere il dominio definitivo.

## Stato attuale (2026-05-09)

**Sanity rimosso, vetrina collegata al Supabase della PWA.** `npm run build` verde. Le rotte mappa/città sono `ƒ` (server-rendered on demand) con ISR 60s. Smoke test live richiede che la migration 015 sia applicata sul DB prod e che lo script `backfill-marketplace-slugs.ts` sia stato eseguito (i dati con `slug=NULL` non escono nei filtri vetrina).

**MVP precedente: tag git `v0.1.0-mvp`.**

Plan in `docs/superpowers/plans/2026-05-08-piratopoly-vetrina.md`. Phases 1-9 completate (foundation, design system, layout, tutte le 10 sezioni home, template città/mappa, pagine statiche, blog index empty state, traduzioni i18n, Sanity CMS hybrid, SEO/JSON-LD/sitemap/robots, GA4 stub, cookie banner, newsletter aside, smoke test).

### Storia commit

- Task 34 — Sanity Studio scaffold (commit `1019c19`)
- Task 35 — `lib/sanity/{client,queries,types}.ts` (`cf2b5b4`)
- Task 36 — `fetchOrFallback` + wire consumer (`e67e349`)
- Task 37 — README con Sanity onboarding (`d4cdccb`)
- Task 38 — `lib/seo.ts buildMetadata` + `[locale]/layout` generateMetadata (`8c59400`)
- Task 39 — JSON-LD: LocalBusiness/TouristAttraction/BreadcrumbList/FAQPage (`e471b9a`)
- Task 40 — `app/sitemap.ts` (75 URL) + `app/robots.ts` + fix next-intl locale return (`82c6dfb`)
- Task 41 — GA4 stub, no-op senza env (`b918231`)
- Task 42 — image audit, no change necessaria
- Task 45 — Cookie banner minimal (`ebea21d`)
- Task 46 — Newsletter aside + i18n `newsletter` ×5 locales (`2ff76aa`)
- Task 48 — Smoke test: build, lint, 17 URL prod 200
- Task 49 — Tag `v0.1.0-mvp`

### Numeri build MVP

- Sitemap: 75 URL (5 locali × 15 path: 8 statiche + 3 città + 4 mappe)
- JSON-LD verificato in HTML SSR: home (LocalBusiness + FAQPage), map (TouristAttraction + BreadcrumbList)
- Studio embedded `/studio/[[...index]]`: dynamic, 1.48 MB chunk isolato

## TODO post-MVP (handoff Stefano)

- **[bloccante]** Applicare migration `015_marketplace_slugs_seasons.sql` sul DB Supabase (via `supabase_admin`).
- **[bloccante]** Eseguire `backend/scripts/backfill-marketplace-slugs.ts` per popolare `cities.slug` e `maps.slug`.
- Wire GA4 production ID (`NEXT_PUBLIC_GA4_ID` su Vercel).
- Wire endpoint newsletter (oggi posta a `/api/newsletter` placeholder — collegare a Brevo/Mailchimp/altro).
- Pass nativi traduttori sulle 5 i18n (oggi machine + style guide).
- Foto reali per città / mappe (oggi placeholder SVG decos finché Supabase è vuoto).
- Contenuti reali blog (oggi empty state + 404 stub).
- Pagina partner: dati reali esercenti.
- A11y deep pass con axe DevTools + screen reader (Hero/PiratePass/Pricing) + Lighthouse production.
- Eventuale Phase 2: integrazione 3D map / parallax avanzata, Pricing → Stripe.
- Quando Stefano valorizza `season_tag` su mappe Halloween/Natale/Harry Potter, la sezione `SeasonalMaps` si popola automaticamente (no rebuild richiesto, ISR 60s).

## Layout repo

```
piratopoly-web/
├── app/[locale]/        # routes localizzate (home, città, mappe, blog, statiche)
│   ├── citta/[slug]/page.tsx                  # pagina città (Supabase)
│   └── mappe/[citySlug]/[mapSlug]/page.tsx    # dettaglio mappa (Supabase)
├── components/
│   ├── design-system/   # Button, Card, Section, Typography, Icon
│   ├── layout/          # Navbar, Footer, LanguageSwitcher, ScrollProgress
│   ├── home/            # 10 sezioni home + Client wrappers per le animate
│   └── animations/      # HeroMapTrace, CardFan, ItalyMap
├── content/i18n/        # 5 file json (it/en/es/de/fr)
├── lib/
│   ├── supabase/        # client.ts, maps.ts, cities.ts, format.ts, types.ts
│   ├── animations.ts    # GSAP/Framer presets
│   └── cn.ts
└── public/assets/       # SVG/texture copiati dalla PWA
```

## Differenze chiave con la PWA

- Repo separato (no monorepo). La PWA gira su `piratopoly-dev.duckdns.org` con `npm run dev`; il vetrina deploya su Vercel.
- Stack frontend diverso: Next.js 14 (App Router) qui, Vite + React qui dietro la PWA.
- Asset condivisi via copia (NON symlink) per evitare accoppiamento di build.
- Pricing/contenuti narrativi del vetrina seguono **GDD V1** ([[piratopoly-pricing-v1-execution]]).

## Link correlati

- [[piratopoly|Piratopoly (PWA)]]
- [[piratopoly-pricing-v1-execution|Pricing V1 — Piano di Esecuzione]]
- Plan attivo: `piratopoly-web/docs/superpowers/plans/2026-05-08-piratopoly-vetrina.md`
