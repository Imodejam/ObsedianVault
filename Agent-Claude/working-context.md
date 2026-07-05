# Working context

## Sessione: traduzioni Vetrina 10 lingue + check giornaliero
Data: 2026-07-05

### COMPLETATO: ri-traduzione settori (ondata 2) fr/en/zh — 10 lingue complete
Contesto: le 78 case study settori erano state ricalcolate col modello Nemi Voce.
I _Case_ keys in es/pt/ar/bn/hi/uk erano già rifatti; fr/en/zh avevano valori STALE
(versione vecchia, non allineata al ricalcolo).

Stato:
- fr: MERGE FATTO (2808 case keys sostituiti in SharedResource.fr.resx)
- en: MERGE FATTO (via build_en.py, 654 uniq → 2808 keys) 
- zh: MERGE FATTO. Build OK, service riavviato, verifica live OK. Commit 2feaa78.
- Script merge: scratchpad/trad/merge_resx.py (caseKey→it→id→uniq_lang), idempotente

### Prossimi passi
1. Attendere zh subagent → python3 merge_resx.py zh
2. stop/build/start puntify-vetrina.service (neutro embedded serve restart processo)
3. Verificare 1 settore in fr/en/zh via browser
4. Commit "traduzioni settori ondata 2 (fr/en/zh) allineate a Nemi Voce" (NO attribuzione Claude)
5. Report Telegram a Stefano: sito completo nelle 10 lingue
6. Deploy PROD: SOLO dopo OK esplicito Stefano

### Check errori 8:00 (FATTO)
0 bug nuovi (tutti [CLIENT/vetrina] circuito, amplificati dai restart). JIRA PNT aperti=0.
Report Telegram inviati (id 5241 errori, 5242 jira).

## 2026-07-05 batch richieste — COMPLETO
- home 'italiane' rimosso, claim mercato IT solo-IT, categorie 65 localizzate, pagine coda localizzate, legali già IT/EN.
- Commits: 354971a, 24fd22e, bca4cc1, fff10f7 (+ 2feaa78 settori). NON pushati prod (attende OK).

## 2026-07-05 Nemi femminile + due anime (in corso)
- Nemi = femminile (una Lei, assistente digitale). Memoria: feedback_nemi_female.
- IT corretto: assistente telefonica, Nemi sempre pronta, Nemi è la tua assistente, +extra (Un'assistente completa, falla, lei esegue, risponde da sola, raccoglie lei). Commit 2b049e3 (batch1) + extra da committare con lingue.
- Altre lingue: 2 subagent genere in corso (17 keys + 7 keys) → applicare da nemi_vals_fixed.json / nemi_vals2_fixed.json.
- TODO "due anime": pagina Nemi framare esplicito Bot (gestione chat/Telegram, incluso) vs Voce (telefonate, a consumo). FAQ Nemi_Voce_Faq_Digital già ok. Reframe Nemi_Areas_Title/Desc + HeroDesc, poi tradurre 10 lingue.

## 2026-07-05 Nemi COMPLETO
- Femminile: a87cfd0. Due anime: 3590c77. Verificato it/en/es/fr/ar/uk.
- Da valutare (segnalati a Stefano): (1) stringhe Nemi PT/ES con testo spagnolo errato (ritradurre), (2) JSON-LD pagina Nemi hardcoded IT (localizzare).
- Commit oggi non pushati prod: 354971a,24fd22e,bca4cc1,fff10f7,2feaa78,2b049e3,a87cfd0,3590c77.

## Routine ricorrenti attive (cron di sessione)
- Giornaliera 8:00 IT: controllo errori (cron 9ec6a90b, 6:03 UTC)
- Giornaliera 9:00 IT: report traduzioni Vetrina (cron 917cdd01, 7:03 UTC)
- SETTIMANALE lun ~9:07 IT: TEST PLAN (cron b3792de9, 7:07 UTC) — agent QA aggiorna testbook (wiki/projects/puntify-testbook.md) + regressione Playwright su tutte le pagine Vetrina/App + servizi + report Telegram. Auto-riarmo incluso (cron sessione scade a 7gg).

## 2026-07-05 PUSH per deploy
- Pushati 36 commit su origin/master (fino a 261885e). Stefano fa il deploy prod.
- Note prod: badge Nemi Bot diventa 🔴 automatico (IsProduction); login Google nativa iOS inerte finché non c'è app nativa + scheme nell'allow-list GoTrue PROD (da fare con OK quando serve); app WASM prod = pipeline LoadAll, utenti potrebbero dover ricaricare (service worker).

## 2026-07-05 (sera) — stato richieste coda + shop
FATTO oggi (commit su master, pushati): FAQ Nemi(4091c27), biglietto+lastissued coda(213d4bb), totem numero inline 'Gastronomia 8'(30e31d3), BUG QR sempre-1 device-vuoto fix RPC+app(6fce46c, migration in docs/DB Migrations DA APPLICARE PROD), esercente gestisce coda(b77a6b7, deploy CAT), selettore lingua totem(9f846db).
IN CORSO: 5298 popup embed pagina cliente /shop → Fase 1 subagent a353eeb71f66800e3 (embed mode + framing + prefill dati + postMessage sulle pagine pubbliche Vetrina, build no-deploy). Poi Fase 2 lato app (ShopDetail popup).
DA VALUTARE con Stefano: campo lingua-default esercente (oggi si usa la lingua del link totem); applicare migration coda in PROD.

## 2026-07-05 (tardo) — coda remoto 5307 in corso
Commit/deploy fatti oggi (pushati master): footer board #B80000(af15163), popup embed Fase1 vetrina(4e37c42)+fix XFO(2a6184a), popup Fase2 app(3d307af, deploy CAT), biglietto squillo+attesa(d915694, server+vetrina IssuedAt).
IN CORSO: 5307 coda remoto FASE A (server+DB) subagent a0e7ab7fa48ab4bc4 — schema remote_limit+confirmed+confirm_token+confirm_expires_at, RPC remoto-pending, endpoint conferma via token email, dedup 1-per-email, limite per coda/giorno, email link, regola turno-perso. Applica migration SOLO CAT, no commit. DA RIVEDERE io (sicurezza: dedup/limite/confirm-token/one-per-email) prima di commit/deploy. Poi FASE B: UI pubblica "Mettiti in coda" (vetrina+app) + notifica in-app.
PENDING PROD: migration coda device-vuoto(2026-07-05_queue_take_ticket_empty_device_fix) + eventuale remote (dopo review). Validazione cacct embed (fase server). 

## 2026-07-05 (notte) — ripresa: diagnosi server + Fase B coda remoto
DIAGNOSI SOFFERENZA SERVER (Stefano chiede perché): 2 cose distinte.
1) Reboot 21:16→21:18 = aggiornamento kernel 6.8.0-124→6.8.0-134 (unattended/host), NON crash. No OOM, no panic.
2) Sofferenza vera: puntify-server dalle 14:50 alle 21:16 ha sparato 2140 errori EAGAIN "Resource temporarily unavailable (api-cat:443)" = saturazione socket/risorse su VPS 8GB carica (build .NET ripetute, VBCSCompiler, molti subagent traduzioni, N dotnet-watch, next, openclaw, concilium, piracity). NON leak codice (SupabaseClient usa IHttpClientFactory ok). NotificationQueueService polling continuo = primo a franare. Ora sano (load 0.2, 3.7GB liberi).
Proposto a Stefano hardening opzionale: backlog/limiti socket + retry/backoff su polling notifiche + swap/limiti memoria servizi.
FASE A coda remoto = CHIUSA: HEAD 155a13d, già pushato origin/master. Migration solo su collaudo, PROD in attesa OK esplicito.
FASE B coda remoto (UI) = FATTA (subagent, in working tree, NON committato/deployato, build OK Server+Vetrina+App). Include: sezione "Mettiti in coda da remoto" Vetrina(CodaTicket.razor)+pagina conferma link email(CodaBiglietto.razor), pill app ShopDetail→embed popup con account, campo remote_limit in QueueEdit, notifiche in-app (Sei in coda/Manca poco/Tocca a te via NotificationHelper+QueueController call-next), nuovo endpoint pubblico read-only shop/{id}/remote, 25 stringhe Vetrina+6 App in 10 lingue.
TRADUZIONE notifiche = FATTA (subagent): meccanismo = EmailStrings.T (stesso dell'email Fase A, NON resx server). Aggiunto ResolveLangByUserIdAsync in NotificationHelper (account?userid→language, fallback it). 7 chiavi × 15 lingue in EmailStrings.cs (it,en,es,fr,pt,zh,ar,hi,bn,de,pl,uk,ro,nl,ru). Build Server OK. Completate anche le chiavi email Fase A che erano solo in 7 lingue.
REVIEW pre-commit COMPLETA (2 subagent). NON COMMITTATO — attende decisioni Stefano sui fix.
FINDINGS security: [HIGH-1] email bombing (endpoint pubblico manda mail a email arbitraria senza auth; dedup 1-per-email aggirabile con gmail +alias/punti; no rate-limit per-email, solo 60/min per IP). [HIGH-2] customer_id (cacct query string) spoofabile → notifiche in-app harassment verso account vittima + ticket iniettato in account altrui; fix = derivare account da JWT, non fidarsi client (impatta approccio embed). [MED] race TOCTOU su remote_limit in confirm (non atomico); confirm_token in query string ?ct= (Referer leak, non azzerato a confirm); no unique constraint dedup + inflazione numerazione. Difese OK: RLS deny-by-default (confirm_token non leakabile anon), token UUIDv4 random, entry_mode server-side, no SQLi, postMessage origin-checked.
FINDINGS correttezza: [MAJOR] notifica "manca poco"/near inaffidabile — near cercato per match esatto number=called+near, ma i pending non confermati creano buchi permanenti nella numerazione → near spesso non scatta (è il senso della coda remota). Fix: trigger per POSIZIONE relativa + flag near_notified. [MINOR] off-by-one testo "mancano N"; URL conferma non localizzato (manca prefisso lingua → pagina IT); near perso per chi entra già sotto soglia. Build tutti OK, i18n completo (7×15 notif, 25 Vetrina, 6 App), flusso in-loco NON rotto (confirmed DEFAULT true), "tocca a te" affidabile.
PROD SAFE nel frattempo: feature inerte finché codice non deployato → nessun abuso possibile ora, c'è tempo per fixare bene.
STEFANO OK (msg 5340): fixare tutto il set, strada A per HIGH-2, + commenti nel codice che spiegano ogni fix. DELEGATO a subagent ada3f0641b820ffee (bg): FIX1 dedup email normalizzato+cap+rate-limit per-email; FIX2 endpoint autenticato customer_id da JWT (app non passa più cacct); FIX3 near per-posizione+colonna near_notified; FIX4 confirm in RPC atomica queue_confirm_ticket; FIX5 confirm_token nel path+azzera a confirm+Referrer-Policy+prefisso lingua URL. Migration solo collaudo, no commit/deploy. Poi RI-REVIEW veloce prima di committare.
PROD: Stefano ha eseguito LUI le 2 migration su DB PROD (device-vuoto + queue_remote_pending). Confermato: prod = DB separato che gestisce lui, io da qui NON la raggiungo. Assessment dato: additive/safe (confirmed DEFAULT true protegge in-loco; queue_call_next REPLACE retrocompatibile). ATTENZIONE: DB prod ora AVANTI al codice (Fase A 155a13d non deployata, Fase B non committata) → feature remota inerte finché non deploya il codice; fix QR device-vuoto completo solo dopo deploy app 6fce46c. Chiesto a Stefano se prod-app è già deployata ai commit di oggi.
APERTO: dov'è la PROD vera di Puntify? Da questa box vedo solo collaudo/CAT (cat/app-cat/api-cat.puntify.it, DB puntify_cat). Nessun container/DB prod qui → correzione: la migration in prod da qui NON la posso applicare. Chiesto a Stefano.
DA CONFERMARE con Stefano: applicare le 2 migration coda (device-vuoto + remote) — dove/come sta la prod.
