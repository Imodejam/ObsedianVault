# Piratopoly Web (sito vetrina)

Sito vetrina marketing per Piratopoly. Repository separato dalla PWA di gioco: `/home/progetti/piratopoly-web` (vs `/home/progetti/piratopoly` per la PWA).

## Obiettivo

Production-ready Next.js 14 marketing site: dark-mode pirate aesthetic, 5 lingue, Sanity CMS hybrid, tutte le sezioni home + template città/mappa, target Lighthouse 90+/95+/95+/100. Stefano deploya via Vercel UI; gli agenti consegnano scaffold + build verificata.

## Stack

- Next.js 14 App Router (Server Components + streaming SSR)
- TypeScript strict
- Tailwind CSS con design tokens custom (gold/wine/parchment/night, font Cinzel + Inter)
- next-intl per i18n
- Framer Motion (component) + GSAP/ScrollTrigger (scroll-driven hero map trace)
- Sanity v3 embedded studio (montato su `/studio`) — schemas: city, map, testimonial, blogPost, seasonalMap
- next-sanity client (GROQ + ISR/CDN)
- Asset reuse: SVG copiati da `/home/progetti/piratopoly/frontend/public/assets/`
- GA4 stubbed per il lancio

## Lingue
it (default), en, es, de, fr — tutte e 5 al lancio. Copy statico in `content/i18n/{locale}.json`. Contenuti dinamici (città, mappe, blog, testimonial) via Sanity con fallback a sample data quando il client non è configurato.

## Architettura CMS hybrid

`lib/sanity/fetch.ts` espone `fetchOrFallback<T>(query, params, fallback)`:

- Se `NEXT_PUBLIC_SANITY_PROJECT_ID` non è valorizzato → usa direttamente il fallback (sample data) — il sito gira anche senza Sanity wired up.
- Se è configurato ma il fetch fallisce → log warning + fallback (zero downtime).
- Altrimenti → ritorna il payload Sanity.

Consumer wired (Task 36): template `/citta/[slug]`, `/mappe/[slug]`, sezione home `CuratedMaps` (split in server component + client child per animazioni framer), sezione `SeasonalMaps` (rende `null` finché non c'è una stagionale live).

Studio embedded a `/studio/[[...index]]` (NextStudio). Middleware i18n esclude `/studio` dal locale matcher.

## Stato attuale (2026-05-09)

Plan in `docs/superpowers/plans/2026-05-08-piratopoly-vetrina.md`. Phases 1-6 completate (foundation, design system, layout, tutte le 10 sezioni home, template città/mappa, pagine statiche, blog index empty state, traduzioni i18n). Phase 7 (Sanity CMS) avanzata:

- ✅ Task 34 — Studio scaffold: `studio/sanity.config.ts`, schemas city/map/testimonial/blogPost/seasonalMap, mount `/studio` route, `styled-components` aggiunto come peer dep di NextStudio (commit `1019c19`).
- ✅ Task 35 — `lib/sanity/{client,queries,types}.ts`: GROQ per cities/maps/seasonal/blog/testimonials, types TS manuali (commit `cf2b5b4`).
- ✅ Task 36 — `lib/sanity/fetch.ts` + wire consumer: city/map templates con loadCity/loadMap, CuratedMaps split server+client, SeasonalMaps async (commit `e67e349`).

Type-check + production build passano puliti. Build size: home + 10 sezioni e template generano correttamente; `/studio/[[...index]]` reso dinamico (1.48 MB chunk Sanity, isolato).

## Prossimi step (plan)

- Task 37 — Stub README per onboarding Sanity (creare project, env vars, primo deploy studio).
- Phase 8 — SEO (meta, JSON-LD, sitemap, robots), GA4 stub, image optimization, a11y axe pass, Lighthouse run.
- Phase 9 — README finale, smoke test produzione, tag MVP.

## Layout repo

```
piratopoly-web/
├── app/[locale]/        # routes localizzate (home, città, mappe, blog, statiche)
├── app/studio/          # Sanity embedded (escluso da i18n middleware)
├── components/
│   ├── design-system/   # Button, Card, Section, Typography, Icon
│   ├── layout/          # Navbar, Footer, LanguageSwitcher, ScrollProgress
│   ├── home/            # 10 sezioni home + Client wrappers per le animate
│   └── animations/      # HeroMapTrace, CardFan, ItalyMap
├── content/i18n/        # 5 file json (it/en/es/de/fr)
├── lib/
│   ├── sanity/          # client.ts, queries.ts, types.ts, fetch.ts
│   ├── sample-data.ts   # SAMPLE_MAPS + SAMPLE_CITIES (fallback)
│   ├── animations.ts    # GSAP/Framer presets
│   └── cn.ts
├── studio/              # Sanity v3 config + schemas
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
