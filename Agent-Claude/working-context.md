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

- Update 08:07: flag isfake inaffidabile. Lido del Sole marcato isfake=true (CAT). Restano 3 dubbi (Lunapark, Madrigalas/Madrid, Puntify demo) -> chiesto a Stefano quali fake. Ricordare: replicare su DB prod al deploy.

- Update 08:10: GA4 property id = 57764779, Data API abilitata da Stefano. Manca: aggiungere service account search-console-reader-claude@puntify.iam come Visualizzatore sulla property (403 permission). Chiesto a Stefano.

## Update 08:25 — isfake done + report build
- isfake=true anche Lunapark + Madrigalas(Madrid). Reale solo "Puntify". Tutti demo coperti.
- Report mattutino: 9:00 IT confermato. Build delegato a subagent (a2558171a95da9c26, background). Architettura: script bash raccoglie dati (servizi/infra + Jira PNT via /search/jql + GSC trend + GA4 se accessibile) + vault, poi claude -p compone 5 sez, invio via @puntifynemibot (token appsettings BotToken). Fallback: se claude fallisce invia blob grezzo. Cron 0 7 * * *, disabilita vecchio 4 6.
- MCP Telegram DISCONNESSO -> uso fallback Bot API curl con token interattivo ~/.claude/channels/telegram/.env (bot @claude4imodejam_bot) per rispondere a Stefano in chat.
- ANCORA IN ATTESA da Stefano: (1) accesso dati utenti PROD per sez.1 report; (2) fix permesso GA4 property 57764779; (3) se vuole dettaglio dashboard Clawroom ora; (4) via libera deploy prod Vetrina; (5) rimozione cat in GSC.

- Update 08:32: report v2 pronto/schedulato/testato (DRY_RUN, header). Vecchio cron disabilitato. Pending Stefano: accesso dati prod + GA4 permesso.

## Update 09:50 — Richiesta KPI API prod
- Stefano vuole un'API (protetta API key) che io possa consultare con tutti i dati KPI di PROD.
- Foto ricevute: GA4 property Puntify ID=524577455; service account search-console-reader-claude@puntify.iam GIA Viewer sulla proprieta GA4 (quindi GA4 Data API ora accessibile via SA).
- Piano proposto a Stefano: GET /api/kpi su puntify-server, X-API-Key (chiave /opt/ops/.env), read-only, JSON aggregato. Sorgenti: Postgres prod (PV attivi, prenotazioni, ordini, incassi, punti, billing) + GA4 (visite/sessioni pag. pubblica via SA).
- Chiesto: (1) conferma set KPI, (2) build+test su CAT poi deploy prod con suo ok.
- STATO: attendo conferma scope, nessun codice ancora.
