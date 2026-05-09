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

**MVP chiuso, tag git `v0.1.0-mvp`.**

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

- Wire Sanity progetto reale: creare project su sanity.io, settare `NEXT_PUBLIC_SANITY_PROJECT_ID/DATASET` su Vercel, popolare città+mappe via Studio.
- Wire GA4 production ID (`NEXT_PUBLIC_GA4_ID` su Vercel).
- Wire endpoint newsletter (oggi posta a `/api/newsletter` placeholder — collegare a Brevo/Mailchimp/altro).
- Pass nativi traduttori sulle 5 i18n (oggi machine + style guide).
- Foto reali per città / mappe (oggi placeholder SVG decos).
- Contenuti reali blog (oggi empty state + 404 stub).
- Pagina partner: dati reali esercenti.
- A11y deep pass con axe DevTools + screen reader (Hero/PiratePass/Pricing) + Lighthouse production.
- Eventuale Phase 2: integrazione 3D map / parallax avanzata, Pricing → Stripe.

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
