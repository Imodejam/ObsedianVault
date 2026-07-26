# Working context

## 2026-07-26 — Puntify: molti thread aperti (sessione lunga con Stefano via Telegram)

### FATTO in questa sessione
- SOCIAL: 7 post schedulati su Buffer (25-31/07, 1/giorno, IG+LI+FB, hashtag per-canale), stile serie codificato in `puntify-social/planning/style-guide.md`; director_review.sh aggiornato. Parodie pop (museo/chef/panchina/salone/Matrix/Pulp Fiction/Padrino), scritte MAIUSCOLO+punchline rossa, 1:1 no bande, outpaint/crop.
- SEO: diagnosticato che le pagine /negozi prod NON sono indicizzate (dominio indicizza solo home/settori). Footer "Negozi su Puntify" (internal-linking, dinamico, esclude isfake) fatto su COLLAUDO — da deployare in prod.
- iOS APP (collaudo): pulsante "Accedi con Apple" (solo iOS) + blocco acquisti digitali (abbonamento/crediti/Nemi Voce) in app nativa iOS con modale stile ChatGPT. Provider Apple GoTrue ancora da configurare.
- META: token System User ricevuto+salvato (.secrets/meta_token). Pagina FB "Puntify" (id 1094288750415913) ok; IG non collegato; manca read_insights/ads_read.

### IN ATTESA DI STEFANO (checklist inviata su Telegram)
1. Login Apple: 4 dati (Team ID, Services ID, Key ID, .p8) + file verifica dominio + conferma bundle it.puntify.app + se bloccare "cancella abbonamento".
2. Meta: rendere IG professionale+collegarlo alla pagina+assegnarlo; rigenerare token con read_insights(+ads_read); cadenza recap; se fa ads.
3. SEO: ok deploy footer prod (+metodo); accesso GSC o clic "Richiedi indicizzazione"; ok ridurre negozi demo.
4. Massimo autonomo (#26): frequenza + gate invii-solo-dopo-approvazione + report crescita lunedì.
5. IVA: quando rilascio prod (migrazione schema public + deploy); coperti default A/B.
6. Reels (opzionale): 2-3 dai post approvati.

### Riferimenti memoria
- [[project_puntify_social_skin]], [[reference_puntify_shop_seo_indexing]], [[project_puntify_meta_insights]], [[reference_puntify_cat_vs_prod]]
