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
