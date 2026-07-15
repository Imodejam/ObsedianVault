# Working context — 2026-07-11

## Task in corso
Flusso asporto "pagamento in cassa" (richiesta Stefano via Telegram, msg 5836).

Ordini menu pubblico takeaway (menu_public_orders, order_mode=takeaway):
- nuovo stato `awaiting_payment` (iniziale per asporto cliente) → operatore "Segna pagato" nella CASSA (MerchantPos, NON KitchenDisplay) → received → flusso normale (received→preparing→ready→delivered).
- mail al cliente alla submission: ordine ricevuto, PAGA ALLA CASSA €X, + link tracking (`{VetrinaUrl}/{lang}/negozi/{slug}/menu?order={id}`).
- mail "pronto" già esistente su status→ready (aggiunto link tracking).
- pagina menu Vetrina: deep-link ?order={id} apre vista tracking live + gestione stato awaiting_payment + "paga alla cassa".
- NESSUNA migration DB (status è text libero, no CHECK). Nessun pagamento online.

## Stato
IMPLEMENTATO (subagent). Build 0 errori. Collaudo riavviato (server/vetrina/app). In attesa test Stefano. NON in prod.

## File toccati (previsti)
- Puntify.Server/Controllers/MenuController.cs (SubmitOrder status+email, ListOrders/AllowedStatuses, SetStatus link)
- Puntify.App/Pages/Merchant/MerchantPos.razor (pannello "Da incassare" + Segna pagato → received). KitchenDisplay INVARIATO (cucina vede solo dopo pagamento).
- Puntify.Vetrina/Pages/MerchantMenuPreview.razor (deep-link, UI awaiting_payment, keys status.awaiting_payment/confirm.pay_counter_*/confirm.total tutte le lingue)

## Prossimi passi
- Ricevere report subagent → verificare build → riavviare servizi collaudo SEQUENZIALI (server, vetrina, app) solo dopo OK.
- Debito deploy PROD ancora aperto (migrations Nemi + codice).


## Piracity (2026-07-12) — CHIUSO su collaudo
- Immagini mappe ripristinate (copia assets/auto da piracity-web).
- Ricerca Marketplace cablata (backend search param + frontend debounce). Verificato.
- APERTO: decisione Stefano su versionare/rigenerare le cover (ora non versionate).

### [2026-07-13] PENDING: auto-archivio ordini food (job background)
- Regole: non evaso >5h → chiudi; consegnato → rimuovi dopo 30min. Solo categorie food (1,2,9,27,35).
- In attesa: (1) stato non-evaso Scaduto/Annullato/Consegnato; (2) "rimuovi" consegnato = nascondi Archivio o delete.
- Pattern: nuovo BackgroundService in Puntify.Server/Services/BackgroundServices/ (come BookingReminderService).

### [2026-07-13] RISOLTO: auto-archivio food + coperto dettaglio — deployati su collaudo (pending prod)

### [2026-07-13] PENDING: "Togli il timer" (msg 6042) — ambiguo. Chiesto A (timer 30min consegnati → sparisce subito da Archivio) vs B (job 5h Scaduto → solo filtro vista attivi, no stato). In attesa.

### [2026-07-13] RISOLTO 6044: auto-expire tolto, solo filtri di vista (food cat). Build ok, deploy collaudo. Pending prod invariato.

### [2026-07-13] PENDING coperto self-order: ordine pubblico a tavolo (dine_in) NON applica coperto (SubmitOrder total=solo piatti, no Covers) e menu pubblico non chiede n. persone. Chiesto a Stefano come gestire (persone×coperto / 1 per ordine / solo cassa)

### [2026-07-13] RISOLTO coperto self-order: cameriere conferma i coperti in Cassa; persistenza garantita a pagamento. Cliente resta senza coperto.

### [2026-07-14] PENDING (6077): imposte nel conto Cassa prima del totale. Nessun campo IVA POS esistente (fiscale ShopEdit = billing Puntify→esercente). Chiesto: (1) IVA inclusa/scorporo (std IT, totale invariato) vs aggiunta; (2) aliquota unica per negozio vs per categoria (cibo 10
### [2026-07-14] PENDING (6077): imposte nel conto Cassa prima del totale.
- Nessun campo IVA POS esistente (fiscale ShopEdit = billing Puntify verso esercente).
- Chiesto: (1) IVA inclusa/scorporo (std IT, totale invariato) vs aggiunta; (2) aliquota unica per negozio vs per categoria (cibo 10 pct / alcolici 22 pct).
- Impl prevista: campo vat_rate su shops + scorporo nel conto Cassa (CassaGrandTotal invariato). In attesa.

### [2026-07-14] PENDING (6106) Admin esercenti azioni: elimina PV (conferma a codice), elimina esercente se 0 PV, blocco (servizi+vetrina). 'In attesa'=isapproved false su MerchantProfile. Admin oggi sola-consultazione, nessun campo blocco. Chiesto: (1) delete PV hard vs soft; (2) elimina account esercente sì/no; (3) blocco scope a(login+servizi+vetrina)/b(servizi+vetrina) + reversibile. Azioni riservate Super admin. Impl prevista: endpoint admin write + RBAC + campo accounts.blocked + gating server auth + filtro Vetrina + modale conferma-nome. In attesa risposta.

## [2026-07-14] note | Stefano OK a includere il fix campo indirizzo (6118) nel prossimo deploy prod. PENDING 6122 (verifica email reale): trovato blocco = GoTrue senza SMTP + autoconfirm=true; solo gotrue-puntify-cat (no prod separato visibile). Chieste 3 conferme (Resend per SMTP / un-confirm+resend ai 9 / app.puntify.it stesso server?). In attesa.

### [2026-07-14] PENDING (6156) God mode: impersonazione in SCRITTURA con password fissa. Arch: impersonazione via header X-Impersonate-Account (JWT admin), oggi READ-ONLY (RequireOwnerAsync nega scritture; RLS blocca scritture dirette Supabase). Piano: password validata server-side (config) + Super admin only + audit; autorizzare scritture God in RequireOwnerAsync; ri-instradare scritture dirette Supabase (ShopEdit/MerchantAccount/Rewards/MenuEditor) via server. Chiesto a Stefano: password (lui/io) + conferma Super-only+audit.

### [2026-07-14] PENDING (6163) URL slug con città: /it/negozi/{cittaSlug}/{nomeSlug}, esercente edita solo nome. Città da indirizzo (auto). Cambia: rotte Vetrina a 2 segmenti, risoluzione shop per città+nome, tutti i generatori URL (anteprima/sitemap/email/tracking/QR), redirect vecchi link 1-segmento. Da fare DOPO God mode (evita conflitto ShopEdit). SlugHelper ha già BuildShopSlug(businessName,city).

### [2026-07-14] RISOLTO God mode (fase 1) — server-routed writes + ShopEdit OK; fase 2 = pagine direct-write.

### [2026-07-14] 6163 URL-città: scope grande (56 occorrenze /negozi/ in ~20 file, no campo city su Shop, molte risoluzioni slug=eq). Chiesto a Stefano il bivio: nome unico globale (a) vs per-città (b, consigliato) + conferma redirect vecchi link. Build dopo risposta. ShopEdit ora libero (God mode fatta).

### [2026-07-14] TODO (6175) Dopo la sezione Supporto: inserire i link degli articoli Supporto nelle MAIL DI BENVENUTO dell'esercente (guidarlo da subito). Ricordare quando il subagent Supporto finisce.

### [2026-07-14] 6180 REQUISITO articoli Supporto: scrivere per chi legge la PRIMA volta — spiegare ogni termine/concetto, anticipare le domande, niente per scontato. Es: totem = tablet che l'esercente ha già, in kiosk con l'app Puntify (idem display cucina/bevande/sala). Applicare a TUTTI gli articoli con passaggio rifinitura DOPO la riscrittura precisa (subagent ad4ea636 in corso). NB Stefano intendeva 'app Puntify' non 'Spotify' (autocorrect).

## [2026-07-14] Batch 2 articoli supporto Puntify
Obiettivo: scrivere 2° batch (10 articoli) support_articles per Vetrina, grounded sul codice reale.
Pagine target: MerchantOperators, MerchantTelegram, MerchantBilling/Payments, Panoramica/Insights, Clients/ClientDetail, Transactions, SocialStudio, ReceiptApproval, Scan, Credentials.
Stato: lanciati 5 Explore agent per estrarre route/label resx/flussi. In attesa. Poi INSERT idempotente su puntify.support_articles (published, it).

### [2026-07-15] 6189: reminder PV — (2) a TUTTI = già così (nessun filtro isapproved), nessuna modifica. (1) criterio 'configurato' non chiaro a Stefano: rispiegato + proposto criterio più stretto = fermare i reminder solo quando ha attivato almeno un servizio (menù pubblicato / raccolta punti / prenotazioni) invece del solo indirizzo. In attesa scelta; se sì, modifica in IsPvConfiguredAsync.

## [2026-07-15] Email base template unification (Telegram 6195/6196)
- 6195: footer comune su TUTTE le email = promo Nemi + link FAQ/Supporto/Assistenza (localizzato 15 lingue), nel layout Base.
- 6196: uniformare TUTTE le email allo stesso template Base (grafica/header/footer coerenti); riallineare eventuali email HTML-inline fuori da EmailTemplates.
- Stato: inoltrate al subagent a9151 (feature-discovery fase 2, in esecuzione, sta editando EmailTemplates.cs). In attesa report subagent → verifica build + report a Stefano (mail esempio a imodejam@gmail.com, lista altri casi email).

## [2026-07-15] 6199 support@ → pagina assistenza (FATTO)
- Rimosso mailto support@puntify.it da: Supporto.razor, SupportoArticle.razor, Footer.razor, Assistenza.razor.
- Contatto ora → /assistenza (form già esistente → SupportTicketController → JiraService, progetto PNT). Nuova chiave Support_Contact_Cta ("Apri una richiesta di assistenza") in SharedResource.resx (default IT; sezione Support i18n è IT-only pre-esistente). info@ mantenuto.
- Build Vetrina ok, servizio riavviato. Nessun residuo support@ nel repo.

## [2026-07-15] Email: feature-discovery + footer + template unico (FATTO)
- 6191: MerchantFeatureDiscoveryService (fase 2), ~10gg, salta se non configurato o se tutto attivo; template FeatureDiscovery con card grafiche 2 colonne + deep-link; EmailStrings 15 lingue; migration feature_reminder_sent_at applicata. Mail esempio inviata a imodejam@gmail.com (consegnata via Resend).
- 6195: footer comune nel Base = promo Nemi (/it/nemi) + link FAQ/Supporto/Assistenza. Vale per tutte le email che usano Base.
- 6196: uniformato. Tutti i template EmailTemplates già usano Base; avvolte nel Base anche le 4 email HTML-custom (ShopPageActive, MenuController ordine ricevuto/pronto/ricevuta) con nuovo EmailTemplates.Wrap(preheader, content, lang). Mantenuto contenuto (tabelle IVA/articoli).
- Fase 1 config-reminder allineata: "configurato = >=1 servizio attivo" via MerchantFeatureService.GetStatusAsync (IsConfigured). 
- Proposti 10 nuovi casi email (recap mensile, menu pubblicato, re-engagement, billing/trial, punti in scadenza, primo ordine, low-activity, win-back, digest settimanale, recap Nemi).
- Build server ok, riavviato; servizi fase1 (🏪) e fase2 (✨) loggati all'avvio.

## [2026-07-15] Analytics PV + recap settimanale (6202/6203) — IN CORSO
- Approvati i 10 casi email; recap → SETTIMANALE lunedì mattina (settimana lun-dom precedente).
- Cattura analytics pagine pubbliche (cookieless, no PII): subagent in esecuzione costruisce pv_events + endpoint /api/public/pv-event + pv-analytics.js (data-pv-event su CTA reali di NegozioDetail e affini) + PvAnalyticsService.GetWeeklySummaryAsync.
- Recap conterrà: visite, visitatori unici, top pulsanti, provenienza, device + dati business. Stile Apple/Stripe (no foto per il recap; chiederò prompt se un'email specifica servisse immagini).
- DOMANDA APERTA a Stefano: pagina Insight fusa subito in Dashboard/Panoramica o separata per ora?
- Punti NON scadono oggi: proposta regola di scadenza configurabile prima dell'email "punti in scadenza" — in attesa risposta.
- PROSSIMI: 1) attendere subagent cattura → verificare, 2) costruire recap settimanale (scheduler lunedì) su PvAnalyticsService + dati business, 3) Insights UI dopo risposta merge.

## [2026-07-15] Nuovi filoni aperti (in attesa risposte Stefano)
- BILLING (6206): trial 3m(2+1) fino 30/9/2026, poi 1m; mail avviso (copia info@) → Stripe ricorrente → blocco morosi; canone 9,99€/mese. Domande: trial da data reg vs fissa? canone? blocco=sospensione vs totale?
- SCADENZA PUNTI (6207): per-PV 1a/3a/mai, UI-editable. Domande: default Mai? semantica (a) FIFO da maturazione o (b) da inattività? Poi email "punti in scadenza".
- Nessun build partito su questi due: attendo conferme (regole "ask before big work" + no azioni prod/pagamenti senza ok).

## [2026-07-15] Coda lavori (sequenziale per evitare race Program.cs/server/vetrina)
- IN CORSO (subagent bg): analytics PV capture; billing fase-1 (stato trial + email avviso).
- ACCODATO 1: scadenza punti (default Mai, semantica A/FIFO) — build dopo che billing libera Program.cs/server.
- ACCODATO 2: FAQ vetrina + Prezzi/Fidelizzazione con info trial/abbonamento/sospensione/scadenza-punti (tutte lingue) — dopo che analytics libera la vetrina.
- APERTO: Insights fuso in Dashboard o separato? (domanda a Stefano, non ancora risposto)

## [2026-07-15] Aggiornamento coda
- FATTO: analytics PV capture (verificato). Gap noti: pulsanti share/social/loyalty/coda non tracciati (da aggiungere).
- IN CORSO (bg): billing fase-1 (server); FAQ vetrina + Prezzi/Fidelizzazione (vetrina, appena lanciato).
- ACCODATO: scadenza punti (build, dopo che billing libera server/Program.cs).
- APERTO: Insights fuso in Dashboard o separato? (Stefano non ha ancora risposto).

## [2026-07-15] Billing fase-1 fatto + gate invii OFF
- account_subscription + SubscriptionService + 4 email + lifecycle service. Esempi a imodejam@.
- GATE Billing:LifecycleSendEnabled default OFF (nessun invio automatico su collaudo). Riattivare solo in prod/fase 3.
- Effetto collaterale gestito: 5 email sospensione partite a collaudo prima del gate — segnalato a Stefano.
- DOMANDE a Stefano: trial_start in prod = registrazione o go-live? (consiglio go-live configurabile).
- FASE 2 = pagina /billing + Stripe ricorrente; FASE 3 = enforcement sospensione.
- PROSSIMO: scadenza punti (dopo FAQ subagent, per non riavviare 3 servizi insieme).

## [2026-07-15] Correzione billing accodata (6218)
- trial_start = data creazione PRIMO punto vendita (non account.insertdate). Finestra 3m/1m su quella data. Account senza PV → trial non parte.
- Fix su SubscriptionService.ComputeTrial: da account.insertdate a MIN(shops.created_at non-deleted). Applicare quando il subagent scadenza-punti libera il server. Invii già OFF → nessun impatto immediato.
