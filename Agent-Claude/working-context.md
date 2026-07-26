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

## 2026-07-26 — Puntify.App Login App Review fix (CAT)
- Task 3: campo referral/promo nascosto quando _isNativeApp (gate `_signUp && !_isNativeApp`)
- Task 4: in app iOS nativa il tab "Registrati" diventa "Registrati sul sito" → puntifyPlatform.openExternal(origin+"/register") in Safari; pagina resta in Accedi; signin in-app invariato
- JS: aggiunti puntifyPlatform.origin() e openExternal() (native handler action "openExternal" se PuntifyNative.openExternal===true, altrimenti window.open _blank, fallback location.href)
- _isNativeApp letto in OnAfterRenderAsync da puntifyNativeAuth.isNative; nuova resx login_tab_signup_web x10 lingue
- build 0 errori, restart puntify-app OK; verificato live via CDP (isNative true → referral off, openExternal fired, no signup in-app)
- DA CONFERMARE sull'app iOS vera: che il nativo intercetti l'action "openExternal" (o window.open _blank) e apra Safari

## 2026-07-26 (notte) — RICHIESTA APERTA: audit completo menu/ordini/prenotazioni
Stefano: "rifai un giro complessivo delle funzionalita del menu, ordini e prenotazioni e verifica che il
codice sia ottimizzato, testato e senza bug, compresi test di sicurezza".
Da fare DOPO i fix in corso (IVA-esclusa vetrina, course_status, portate takeaway) cosi l'audit vede il
codice corretto. Piano: workflow multi-agent (1 area per agent: menu / ordini+cassa / prenotazioni) con
dimensioni bug-logici, sicurezza (authz, IDOR multi-tenant, endpoint pubblici, rate-limit, injection/XSS),
performance (N+1, indici, render), copertura test; poi verifica avversariale dei finding (kill dei falsi
positivi) e sintesi. Riportare a Stefano: bloccanti / warning / ottimizzazioni / cosa gia' sistemato.
