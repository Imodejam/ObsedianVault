# Piracity Web (sito vetrina)

Sito vetrina marketing per Piracity. Repository separato dalla PWA di gioco: `/home/progetti/piracity-web` (vs `/home/progetti/piracity` per la PWA).

## Obiettivo

Production-ready Next.js 14 marketing site: dark-mode pirate aesthetic, 5 lingue, Sanity CMS hybrid, tutte le sezioni home + template città/mappa, target Lighthouse 90+/95+/95+/100. Stefano deploya via Vercel UI; gli agenti consegnano scaffold + build verificata.

## Deployment dev
- **URL pubblico (dal 2026-06-22):** https://cat.piracity.app/ — sostituisce il vecchio duckdns (ora giù). Stessa app systemd su :6010, solo dominio/nginx nuovo. (App di gioco CAT separata: https://app-cat.piracity.app/)
- **URL pubblico (storico, dismesso):** http://piracity-dev-web.duckdns.org/
- **Repo:** `/home/progetti/piracity-web/` (Next.js standalone, no workspaces).
- **Servizio systemd:** `piracity-web.service` (User=`claudebot`, WorkingDirectory=`/home/progetti/piracity-web`).
- **Comando:** `npx next dev -p 6010 -H 0.0.0.0`.
- **Porta:** `127.0.0.1:6010` (dietro Nginx).
- **Nginx:** `/etc/nginx/sites-available/piracity-dev-web.duckdns.org` → proxy a `:6010`, WS upgrade, listen 80.
- **Restart:** `Restart=always`, `RestartSec=10`. Enabled al boot.
- **Log:** `journalctl -u piracity-web -f` (identifier `piracity-web`).
- **Comandi:** `sudo systemctl status|restart piracity-web`.
- **Note:** è un dev server (`next dev`), non build di produzione. Prod futura: `piracity.app` su server dedicato separato.

## Stack

- Next.js 14 App Router (Server Components + streaming SSR)
- TypeScript strict
- Tailwind CSS con design tokens custom (gold/wine/parchment/night, font Cinzel + Inter)
- next-intl per i18n
- Framer Motion (component) + GSAP/ScrollTrigger (scroll-driven hero map trace)
- **Supabase** (`@supabase/supabase-js`, schema `piracity`, anon key) — sorgente dati condivisa con la PWA
- Asset reuse: SVG copiati da `/home/progetti/piracity/frontend/public/assets/`
- GA4 stubbed per il lancio

> **2026-05-09**: Sanity rimosso (deps + studio + lib + sample-data). La vetrina punta direttamente al Supabase della PWA. Vedi sezione "Architettura dati" qui sotto.

## Lingue
it (default), en, es, de, fr — tutte e 5 al lancio. Copy statico in `content/i18n/{locale}.json`. Le descrizioni delle mappe vengono pescate da `piracity.map_descriptions(map_id, lang, text)` con fallback IT.

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
NEXT_PUBLIC_SITE_URL=https://piracity.app
NEXT_PUBLIC_GA4_ID=
```

### Cover images
Oggi servite da `https://piracity-dev-app.duckdns.org/assets/webp/maps/...` (server PWA). `next.config.mjs > images.remotePatterns` whitelist sia `piracity-dev-app.duckdns.org` sia `supabase-cat.duckdns.org` (per le cover servite direttamente dallo storage Supabase). Quando si passerà a S3/CDN, aggiungere il dominio definitivo.

## Redesign homepage — landing luminosa familiare (2026-06-22, in corso)

Stefano richiede un **pivot del posizionamento della homepage**: da estetica dark/pirata a **landing luminosa premium familiare** (stile Apple per pulizia + Disney per calore, non infantile, non fantasy cupo). Target: famiglie, bambini, gruppi di amici, compleanni/eventi, turisti. Messaggio in 3 secondi: cos'è / per chi è / come si gioca / perché provarlo in famiglia.

### Decisioni concordate
1. **Foto**: il design vive di foto realistiche premium; Claude non le genera → le fornisce Stefano man mano. Build con placeholder eleganti (`components/home/Figure.tsx`, aspect ratio rigorosi 16:9 / 1:1 / 3:2) + manifest `docs/image-prompts.md` con tutti i prompt. Slot futuri in `/public/assets/photos/` (hero, step-1..4, family, audience, experience, tech, events, adults, treasure, finale).
2. **Tema**: home + Navbar + Footer luminosi; pagine legali/blog restano dark → secondo giro. Tema chiaro **isolato** (non si tocca `body` di globals.css; wrapper `bg-sand text-ink` sulla home) per non rompere le pagine dark.

### Implementazione
- Nuovi componenti in `components/home/landing/` (i vecchi restano in repo ma `page.tsx` monta solo i nuovi).
- Tailwind: aggiunta palette luminosa `ink`/`coral`/`teal`/`sand` (senza rimuovere gold/night). Font nuovi via next/font: `Fraunces` (display emozionale) + `Plus Jakarta Sans`, esposti come CSS var; Cinzel resta per le pagine dark.
- 14 sezioni: Hero, Cos'è, Come funziona (4 step), Famiglia, Per chi è (5 target), Esperienza (timeline 5 step), Tecnologia, Semplicità/fiducia, Compleanni/Eventi, Adulti, Tesoro, FAQ, CTA finale, Footer riscritto luminoso.
- i18n: namespace `home` in tutte e 5 le lingue (it/en/es/de/fr).
- Build delegato a subagent (memoria: delega sviluppo). Verifica tsc/lint/curl :6010.

> Nota copy/dati reali confermati: Piracity È una PWA (FAQ "no app, dal browser"); città Roma/Cosenza/Shanghai; durata da 1-2h a giornata intera.

## Stato attuale (2026-05-09)

**Sanity rimosso, vetrina collegata al Supabase della PWA.** `npm run build` verde. Le rotte mappa/città sono `ƒ` (server-rendered on demand) con ISR 60s. Smoke test live richiede che la migration 015 sia applicata sul DB prod e che lo script `backfill-marketplace-slugs.ts` sia stato eseguito (i dati con `slug=NULL` non escono nei filtri vetrina).

**MVP precedente: tag git `v0.1.0-mvp`.**

Plan in `docs/superpowers/plans/2026-05-08-piracity-vetrina.md`. Phases 1-9 completate (foundation, design system, layout, tutte le 10 sezioni home, template città/mappa, pagine statiche, blog index empty state, traduzioni i18n, Sanity CMS hybrid, SEO/JSON-LD/sitemap/robots, GA4 stub, cookie banner, newsletter aside, smoke test).

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
piracity-web/
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

- Repo separato (no monorepo). La PWA gira su `piracity-dev-app.duckdns.org` con `npm run dev`; il vetrina deploya su Vercel.
- Stack frontend diverso: Next.js 14 (App Router) qui, Vite + React qui dietro la PWA.
- Asset condivisi via copia (NON symlink) per evitare accoppiamento di build.
- Pricing/contenuti narrativi del vetrina seguono **GDD V1** ([[piracity-pricing-v1-execution]]).

## Link correlati

- [[piracity|Piracity (PWA)]]
- [[piracity-pricing-v1-execution|Pricing V1 — Piano di Esecuzione]]
- Plan attivo: `piracity-web/docs/superpowers/plans/2026-05-08-piracity-vetrina.md`

## Marketplace + Stripe + Admin (2026-06-22, build subagent)
Stato: COSTRUITO, non committato, non attivo (mancano chiavi Stripe + migration da applicare).

### Cosa fa
- `/marketplace` (server, revalidate 60): griglia mappe vendibili (status=published, is_official, price>0) via `fetchSellableMaps()` in `lib/supabase/maps.ts`. Tema luminoso (sand/ink/coral, Fraunces/Jakarta, card rounded-3xl). Empty-state elegante se 0. Banner `?status=success|cancel`. Link in Navbar+Footer (i18n `nav.marketplace`/`footer.marketplace`).
- Acquisto: `components/marketplace/BuyButton.tsx` (client) → modale email guest → POST `/api/checkout` → redirect a Stripe. Anche dalla pagina dettaglio mappa (se price>0).
- Checkout `app/api/checkout/route.ts`: valida mappa vendibile (service-role), crea Stripe Checkout Session (price_data dinamico EUR, unit_amount=price*100), inserisce ordine `pending`. Email: loggato→sessione; guest→modale; fallback Stripe la raccoglie e si recupera dal webhook. Senza chiavi Stripe → **503 graceful**.
- Webhook `app/api/webhooks/stripe/route.ts` (nodejs, raw body, firma `STRIPE_WEBHOOK_SECRET`): completed→paid+payment_intent+paid_at+email; failed/expired; charge.refunded→refunded. Logga OGNI evento in `order_events` (idempotente su `stripe_event_id`).

### DB (FILE, non applicato)
`supabase/migrations/016_marketplace_orders.sql`: tabelle `piracity.orders` + `piracity.order_events`, indici, RLS abilitata (deny anon, policy SELECT solo role=admin; scritture via service-role che bypassa RLS). Applicare con psql/docker exec/Supabase MCP (schema piracity).

### Admin
`app/[locale]/admin/`: login (`/api/admin/login` signInWithPassword via @supabase/ssr cookie + check `piracity.users.role='admin'`), `admin/orders` (lista+filtro stato, tutti i campi pagamento, badge), `admin/orders/[id]` (dettaglio + log `order_events`). Pagine server-side `getAdminUser()` → redirect login se non admin. Solo consultazione v1.

### Lib aggiunte
`lib/supabase/admin.ts` (service-role server-only, schema piracity), `lib/supabase/orders.ts` (fetch map by id + insert + fetch orders/events), `lib/supabase/auth.ts` (ssr cookie client + getSessionUser/isAdminUser/getAdminUser), `lib/stripe/server.ts` (isStripeConfigured + getStripe).

### ENV
`.env.local`: `SUPABASE_SERVICE_ROLE_KEY` copiato da piracity/.env (server-only, NO NEXT_PUBLIC). Placeholder: `STRIPE_SECRET_KEY`, `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`, `STRIPE_WEBHOOK_SECRET`.

### Per attivare
1. Chiavi Stripe da Stefano. 2. Applicare migration 016. 3. Webhook su dashboard Stripe → `https://cat.piracity.app/api/webhooks/stripe` (eventi checkout.session.completed/expired/async_payment_failed, charge.refunded).

## [2026-06-24] Foto vetrina → WebP + caching
- Tutte le foto (`public/assets/photos`, `auto/cities`, `auto/stages`) convertite in WebP: 731 file, −1.3 GB. Script `scripts/convert_to_webp.py` (PIL via `minio_webp.to_webp`, q=82).
- DB `piracity.cities`/`stages`: `photo_url` normalizzato a `.webp` (67 + 600 righe).
- Refs landing components → `.webp`. `teatro-rossini.jpg` corrotta → NULL (riprende il photo-fetcher).
- Caching `next.config.mjs`: `Cache-Control immutable` su `/assets/*` (override `stale-while-revalidate` su `/assets/auto/*`) + `images.minimumCacheTTL=31536000`.

### [2026-06-24] Fix post-conversione foto
- **sharp** installato (dep): senza, l'optimizer next/image (webp/avif) si impallava in dev -> foto non caricavano. Ora istantaneo.
- maps `cover_url` = foto città per le 67 mappe senza cover (38 con cover proprie intatte).
- breadcrumb "città" nell'hero `app/[locale]/citta/[slug]/page.tsx` -> Link `/towns`.
- `priority` sulle prime card immagine (LCP) in TownsClient, CuratedMapsClient, MarketplaceClient.
- 22 tappe vecchio path `/assets/webp/stages/` (404 preesistente) azzerate -> refetch automatico.

### [2026-06-24] Foto città batch + invariante webp tappe
- Caricate 14 foto città custom da Stefano (webp, su città + mappe relative, cache-bust ?v=). Script riutilizzabile in scratchpad.
- Tappe tutte webp: convertiti teatro-rossini (sorgente troncato) e trastevere (era pexels remoto) in webp locale.
- Photo-fetcher indurito: `minio_webp` ora usa `ImageFile.LOAD_TRUNCATED_IMAGES`; rimosso il fallback `.jpg` in `download()` (se to_webp fallisce solleva e ritenta) → non si creano più file non-webp.

### [2026-06-24] Mappa Tropea pubblicata
- Città Tropea (slug tropea) + mappa "La Lanterna d'Argento sullo Scoglio" (slug la-lanterna-d-argento-sullo-scoglio), 1 giornata, 7 tappe, pubblicata, prezzo 11.99, mood Arte&Storia.
- Storia: Elena Greco insegue il diario del nonno pescatore e la leggenda del corsaro Vittorio "Mano d'Onda" Sparano / Lanterna d'Argento "dove il mare bacia la chiesa" (finale al Santuario).
- Contenuti generati con 8 subagent (bibbia narrativa + 7 tappe), assemblati via script (scratchpad/tropea): 6 lingue it/en/es/de/fr/nl per city_descriptions, map_descriptions (title/public/internal), stage_descriptions, stage_content_i18n, quiz_pool (252 quiz, kinds multiple-choice/culture/riddle/logic/anagram, validation approved).
- Coordinate POI approssimate (centro storico, ritoccabili da UI). Foto città/mappa: da impostare quando Stefano la invia.
