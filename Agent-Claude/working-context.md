# Working context

Sessione 2026-07-23 (Telegram, canale plugin:telegram).

## Richieste Stefano in corso
1. "Hai capito?" — contesto sessione precedente perso, chiesto chiarimento.
2. "A Dani l'articolo blog" — AMBIGUO: chi e Dani, quale articolo, come inviare. Chiesto.
3. Verifica Google Analytics + Search Console per migliorie SEO/traffico — NO accesso configurato (gog fa solo Gmail/Cal/Drive). Chiesto come accedere (property id/service account).
4. "Fammi leggere il primo blog" — FATTO: inviato testo leggibile "no-show saloni" (id 78a6ad7a). 10 articoli pubblicati in puntify.blog_posts.
5. "Quale budget Ads consiglieresti?" — proposto 20E/gg (~600E/mese) Search intenzionale per verticale, no Display/Pmax fase 1; 2-3 sett raccolta dati poi ottimizzo su CPA.

## Prossimi passi
- Attendo risposte su punti 1,2,3.
- Se GA/GSC accessibili: audit query/pagine, CTR, keyword opportunita blog.

## Update 07:00 — GSC/GA
- GSC: accesso OK via ~/.secrets/gsc-key.json (SA search-console-reader-claude@puntify.iam), scope webmasters.readonly, property sc-domain:puntify.it. venv google-auth+requests in scratchpad/gvenv.
- Dati 20/6-20/7: 52 click, 1248 imp, CTR 4.2%, pos 13.8.
- ISSUE cat.puntify.it indicizzato (51 imp/5 click pos3) ma ora 401 basic-auth -> click sprecati + leak staging. Proposto removal + noindex crawlabile.
- Blog: 100 URL in sitemap, index,follow, title ok. Solo giovane -> ~0 imp. Non bug.
- GA4: NON accessibile. Per abilitare: aggiungere stessa SA come Viewer su proprieta GA4 + Property ID numerico. Measurement id noti: Vetrina G-KFC8WKG9LT, App G-G1EZR6JL2C.
- In attesa scelta Stefano: (a) fix cat noindex/removal, (b) audit completo.

## Update 07:15 — Task 2+3 consegnati
- Task2 cat noindex: FATTO lato Caddy (header X-Robots-Tag noindex su cat.puntify.it, container ops-caddy riavviato, admin off). Manca rimozione GSC via UI (Stefano).
- Task3 audit: FATTO. Report scratchpad + wiki/projects/puntify-seo-audit-20260723.md. Inviato Telegram.
- Aperti in attesa Stefano: (a) conferma noindex negozi demo, (b) rimozione cat in GSC, (c) abilitare GA4 Data API su progetto puntify + property id numerico, (d) fix concilium.puntify.it 403 (Vite allowedHosts) SI/NO.
- Tooling: venv scratchpad/gvenv (google-auth+requests), key ~/.secrets/gsc-key.json scope webmasters.readonly + analytics.readonly (ma API GA disabilitate lato progetto).

- Nota: Stefano dice di NON toccare concilium.puntify.it (403 Vite noto, lasciare stare).

## Update 07:35 — noindex negozi demo (isfake)
- Scoperto: sitemap GIA esclude isfake (SitemapService.cs:45 !s.IsFake). Verificato prod+CAT: demo NON in sitemap. Richiesta Stefano "togli da sitemap" gia soddisfatta.
- Vero gap: pagina negozio fake e' "index" (nessun meta robots). Delegato a subagent: noindex,nofollow su NegozioDetail (ShopData.IsFake) + Book.razor (aggiungere IsFake a MerchantPublicDto + server controller /api/public/merchants + meta condizionale). Build+deploy CAT sequenziale, verifica headless su 3 URL (2 fake devono avere noindex, 1 reale no).
- Subagent id a234fcf30bc83ff31 in background.

---
## [2026-07-23] Ultimo task: noindex negozi demo Vetrina
- FATTO su CAT: negozi isfake=true -> meta robots noindex,nofollow su pagina negozio + /book.
- Fonte unica: Puntify.Vetrina/App.razor (helper ShopIsFakeForPublicRoute -> SupabaseStatsService.GetShopBySlug -> IsFake). App.razor perche Book.razor e prerender:false e il suo HeadContent non raggiunge l'HeadOutlet statico.
- Sitemap non toccata. Nessuna modifica netta a DTO/controller/NegozioDetail (approccio revertato).
- Verificato con Host www.puntify.it (staging=false): fake=noindex, non-fake=index.
- Gotcha: hot-reload watch sporco -> restart pulito puntify-server per togliere MissingMethodException.

## Update 08:05 — noindex isfake DONE su CAT
- Fix centralizzato in Puntify.Vetrina/App.razor (non NegozioDetail/Book: Book ha HeadContent inerte prerender:false). Single source, no doppioni.
- Gotcha verifica: /it/negozi/{slug} fa 302 -> /it/negozi/{city}/{slug} (canonica). Testare la canonica su 127.0.0.1:8003 con Host www.puntify.it (forza prod-behavior, no staging-global-noindex).
- Verificato: fake frutta-fresca/scarpe-stile -> noindex,nofollow; reale lido-del-sole -> index; /book fake -> noindex; prezzi -> index. Nessuna regressione.
- MANCA: deploy PROD (www.puntify.it, manuale) perche' Google recrawli e deindicizzi. Poi opz. rimozione GSC.
