# Working context

## Ora (2026-06-22)
Piracity-web (vetrina): RIPROGETTAZIONE homepage in corso. Stefano vuole pivot da tema dark/pirata a LANDING LUMINOSA familiare (stile Apple pulizia + Disney calore), per famiglie/bambini/amici/compleanni/turisti.

### Decisioni concordate con Stefano
1. FOTO: non posso generarle; le passa lui man mano. Costruisco con placeholder eleganti + manifest prompt (docs/image-prompts.md). Slot in /public/assets/photos/ (hero.jpg, step-1..4.jpg, family, audience, experience, tech, events, adults, treasure, finale).
2. TEMA: home + Navbar + Footer luminosi. Pagine legali/blog restano dark → secondo giro.

### Stato build — COMPLETATO (in attesa review Stefano)
- 14 sezioni nuove in components/home/landing/, design system luminoso (tailwind: ink/coral/teal/sand + font Fraunces+Plus Jakarta), Figure.tsx placeholder foto, Navbar/Footer chiari, i18n 5 lingue. tsc+lint puliti, live su dev.
- Tema chiaro ISOLATO (non tocca body globals.css; wrapper bg-sand text-ink sulla home) → pagine dark intatte.
- GOTCHA screenshot: le animazioni framer whileInView (Reveal/Stagger in primitives.tsx) NON scattano in screenshot headless full-page → pagina appare vuota. Per gli utenti reali funziona. Per screenshot: bypassare temp `if (reduce)`→`if(reduce||true)` poi ripristinare. Screenshot in /tmp/piracity-shots/.
- APP URL collegato: CTA "Inizia l'avventura" (Hero+FinalCta) e "Salpa gratis" (Navbar) → https://app-cat.piracity.app/ (target _blank). CtaPrimary/Secondary in primitives.tsx ora gestiscono href esterni (http→<a>).

### Foto INTEGRATE (2026-06-22)
- Stefano ha inviato 12 foto numerate (1-12 = numerazione dei suoi 12 prompt) + alternative con nomi. Mappate per aspect ratio (16:9/1:1/3:2 confermano la convenzione) e salvate in public/assets/photos/ come: hero, whatis(=Cos'è 3:2), step-1..4, family, tech, audience, events, adults, finale (.png).
- Cablati i src in tutte le sezioni Figure. AGGIUNTA foto a Cos'è (WhatIsIt) e Per chi è (Audience) che prima erano senza. next/image le ottimizza (servite via /_next/image, 200 ok).
- Step "Come si gioca" RINOMINATI digitali in 5 lingue: Segui la bussola digitale / Leggi la pergamena digitale / Completa la missione (+caption allineate a smartphone).
- SENZA foto (placeholder residuo): Experience (timeline "Ogni missione è una storia", 3:2) e Treasure ("Alla fine c'è un tesoro", 16:9). In attesa decisione Stefano (usare alternative o 2 foto dedicate).
- Alternative extra inviate (famiglia/trasformazione/Amici/papà e ragazzi/famiglia colosseo/2 uuid) NON usate, restano nell'inbox telegram.

### Riposizionamento INCLUSIVO — COMPLETATO (2026-06-22)
- Copy di tutte le sezioni riscritto inclusivo (single/coppie/amici/famiglie/turisti/gruppi) in 5 lingue, parità 131 chiavi, tsc+lint ok, grep frasi vietate = 0. Live su cat.piracity.app.
- Struttura: WhatIsIt 4 card (+transform), Audience 6 target (solo/couple/friends/family/travel/events), Events 5 card. Family→"trasformazione", Adults→"Non serve essere bambini…". Step "Leggi la pergamena"/"Completa l'avventura".

### MARKETPLACE + STRIPE (richiesta 2026-06-22, IN ATTESA DECISIONI)
Stefano: marketplace nella vetrina con acquisto mappe via Stripe + tracciamento pagamenti per controllo admin.
Analisi (Explore):
- Mappe schema `piracity` (supabase-cat.duckdns.org) con `price NUMERIC(8,2)` EUR; vetrina legge anon (read-only). Migration in /home/progetti/piracity/supabase/migrations/.
- Stripe ABBOZZATO nel backend PWA (piracity/backend/src/services/payment.service.ts: createCheckoutSession+handleWebhook+PLANS) MA nessuna route in app.ts. STRIPE_SECRET_KEY/WEBHOOK_SECRET = PLACEHOLDER → servono chiavi vere.
- SUPABASE_SERVICE_ROLE_KEY presente (scritture ok). NESSUNA tabella orders/payments. entitlement.store.ts inutilizzato, nessun enforcement ownership.
- Utenti supabase auth + piracity.users (role). Vetrina anonima. NESSUN admin Piracity.
Piano proposto (self-contained vetrina): /marketplace + Stripe Checkout (route handler+service-role) + tabella orders (tracciamento completo) + webhook + /admin/ordini protetto. 4 decisioni inviate: chiavi Stripe test/live; guest-checkout vs login; sblocco entitlement ora/fase2; admin nella vetrina.

## Aperto / prossimi passi
- MARKETPLACE: BUILD COMPLETATA (subagent). /marketplace (fetchSellableMaps, light theme, BuyButton con modale email guest + login) + /api/checkout (503 graceful senza chiavi) + /api/webhooks/stripe (orders+order_events idempotente) + /admin (login user+pwd+role, orders list+detail+event log) + migration FILE supabase/migrations/016_marketplace_orders.sql (NON applicata). tsc/lint OK, curl /marketplace 5 lingue 200, i18n parita 357 chiavi. .env.local: SERVICE_ROLE copiato da piracity/.env + placeholder Stripe. NON committato. DB irraggiungibile dal tooling al momento (fetch failed anche su home) → sellable count non verificato, empty-state 200. ATTESA per ATTIVARE: chiavi Stripe + applicare migration 016 (psql/docker exec/Supabase MCP, schema piracity) + config webhook dashboard Stripe → https://cat.piracity.app/api/webhooks/stripe.
- 🔧 CAUSA "DB GIÙ" TROVATA (2026-06-22): la vetrina (.env.local) E la PWA (piracity/.env + frontend/.env) puntano ancora al Supabase LEGACY supabase-cat.duckdns.org, DISMESSO il 17/05. Nuova infra CAT viva: API Piracity = https://api-cat.piracity.app (PostgREST+GoTrue, testato 200; Accept-Profile piracity). db-cat.puntify.it = DbGate UI (NON l'API, anche se Stefano l'ha indicato). Anon key CAMBIATA (JWT secret nuovo, la vecchia dà "invalid token"). Chiavi in /opt/ops/.env su server remoto pro-open (212.227.21.104) — non accessibile da questo box. CHIESTE a Stefano: conferma URL API + PIRACITY_ANON_KEY + SERVICE_ROLE. Da aggiornare: piracity-web/.env.local (NEXT_PUBLIC_SUPABASE_URL+ANON+SERVICE_ROLE) + next.config.mjs remotePatterns, poi restart. Stessa fix poi sulla PWA.
- ⚠️ (storico) DB supabase-cat.duckdns.org GIÙ (verificato: TLS rc=35, log "fetchSellableMaps failed: fetch failed") → niente mappe su TUTTO il sito (home/città/marketplace empty-state). Infra non codice. Vetrina cat.piracity.app su 200. Chiesto a Stefano se indagare (forse container docker). Sellable maps count non verificabile finché DB giù (ma un curl transitorio aveva mostrato ~8 "Acquista" → mappe vendibili esistono quando il DB è su).
- FOTO carosello "Per ogni tipo di ciurma" CARICATE: audience-{solo,couple,friends,family,travel,events}.png (verificate visivamente). gruppopirati→family.png (sezione trasformazione).
- Stefano rivede live: https://cat.piracity.app/ → applico fix.
- ATTESE foto da Stefano: HERO gruppo misto + FINALE (no famiglia) + timeline + tesoro.
- Da confermare: footer Missioni→#per-chi / Contatti→/partner; CTA "Organizza una missione" + "Vivi la tua prima missione" interne o all'app.
- Possibile ottimizzazione: convertire i PNG (~2MB) in webp per perf.
- NON ancora committato/pubblicato.

## Contesto precedente (Puntify, in pausa)
- Outreach Milano 26 email inviate; decisione CTA demo template-wide pendente.
- Outreach prossime zone: Monza 22, Siena 19, Brescia 13, Verona 12, Torino 10.
