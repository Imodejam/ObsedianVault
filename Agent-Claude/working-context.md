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
INCIDENTE COLLAUDO 22:35: app-cat loading perenne — causa dotnet-watch hot-reload corrotto da edit live del subagent (TypeLoadException tipo anonimo→500). Recovery: restart puntify-server. Registrato in mistakes.md + auto-memoria reference_puntify_collaudo_hotreload. Stefano scelto A (lascia finire i fix, poi restart pulito). CURA proposta: dotnet watch --no-hot-reload o worktree isolato.
GOOGLE AUTH PROD (richiesta Stefano 22:43): vuole abilitare login Google in prod. Chiarito: PUNTIFY_URI_ALLOW_LIST non è il blocco (Google non richiede voce dedicata; app.puntify.it/** già copre; opz. /*→/**). Vera checklist (da config CAT funzionante): (1) provider google nel compose/.env prod (GOTRUE_EXTERNAL_GOOGLE_ENABLED/CLIENT_ID/SECRET/REDIRECT_URI=https://<api-prod>/auth/v1/callback); (2) CAUSA#1 = Google Cloud Console authorized redirect URI deve avere https://<api-prod>/auth/v1/callback (cat usa api-cat.puntify.it/auth/v1/callback); (3) ricreare gotrue prod. Chiesto a Stefano output grep DOMAIN_API_PUNTIFY/GOOGLE su prod per valori esatti. NB sed iOS di prima NON rimasto su prod (stringa pulita).
STEFANO OK (msg 5340): fixare tutto il set, strada A per HIGH-2, + commenti nel codice che spiegano ogni fix.
FIX FATTI (subagent ada3f0641b820ffee): tutti e 5 implementati, build 3 progetti 0 errori, NON committato. Migration nuova `2026-07-05_queue_remote_review_fixes.sql` applicata+verificata su collaudo (funzioni queue_confirm_ticket/queue_normalize_email/queue_take_ticket_remote + colonne contact_email_norm/near_notified). Dettagli: FIX1 dedup email normalizzata(gmail alias/punti)+cap 3/h 3/gg tabella persistente queue_remote_email_sends+rate-limiter per-email+advisory lock; FIX2 endpoint AUTENTICATO /api/queue/{qrToken}/ticket/remote (customer_id da JWT), pubblico non accetta più customer_id, app chiama endpoint auth (no cacct); FIX3 near per-posizione+flag near_notified; FIX4 RPC atomica queue_confirm_ticket (FOR UPDATE+advisory lock, GRANT service_role); FIX5 token nel path+azzerato a confirm+Referrer-Policy no-referrer+prefisso lingua URL. i18n: Coda_RemoteErrRate (10 Vetrina) + 9 chiavi shop_queue_* (10 App).
COLLAUDO STABILIZZATO: restart pulito sequenziale, 3 servizi su (server/vetrina 302, app 200, app-cat pub 200).
VERIFICA adversariale FATTA (a187dfa6dffbccb9e): FIX 1/3/4/5 CHIUSI; FIX2 PARZIALE. Build ok, i18n ok, normalizzazione email verificata live, nessuna regressione in-loco.
BUCO RESIDUO [ALTA, pre-esistente/sistemico]: le RPC coda sono SECURITY DEFINER + eseguibili da anon/authenticated; Caddy espone PostgREST su api-cat.puntify.it/rest/v1/* → /rest/v1/rpc/<fn> raggiungibile dall'esterno con anon key pubblica → si può bypassare il server e spoofare customer_id (riapre FIX2), o chiamare queue_call_next direttamente (grief). Server usa key service_role (verificato claim JWT) → REVOKE FROM anon/authenticated SICURO (app usa direttamente solo search_account_by_*/get_account_photo_by_id, NON le queue). FIX da applicare: REVOKE EXECUTE ON queue_take_ticket_remote/queue_confirm_ticket/queue_take_ticket/queue_call_next/queue_normalize_email FROM PUBLIC,anon,authenticated (GRANT service_role resta). VALE ANCHE PER PROD (stesso schema). Osservazione extra: search_account_by_email eseguibile da anon = enumerazione account (fuori scope, segnalare).
DECISIONI Stefano ricevute: (1) email conferma app = lascia com'è; (2) near → consolidare su near_notified_at (timestamptz) esistente, rimuovere boolean near_notified.
DA APPLICARE prima del commit (una passata): [a] REVOKE grant RPC; [b] consolidazione near su near_notified_at. Poi build + commit (NO deploy prod).

INCIDENTE 2 app-cat (23:02): loading perenne DIVERSO dal primo — errore client "Blazor culture change not supported / BlazorWebAssemblyLoadAllGlobalizationData". Causa: Program.cs app imposta cultura da localStorage puntify_culture tra 10 lingue; in Debug/collaudo ICU completo non caricato (icudt.dat 404 dal DevServer), LoadAll è solo in Release (csproj ha commento esplicito: NON attivare in Debug). Lingue it/en/es/fr/de ok; pl/uk/ro/nl/ru crashano il boot. NON causato dai fix (subagent non ha toccato app/csproj). Sblocco utente: localStorage.removeItem('puntify_culture')+reload. Proposto a Stefano: A) graceful fallback a EN in Debug per lingue non-EFIGS (no crash, quelle 5 lingue in EN solo su collaudo); B) far servire ICU completo/Release su collaudo (più lavoro). Attendo scelta A/B.
DEPLOY PROD (futuro): 2 migration in ordine — queue_remote_pending poi queue_remote_review_fixes — + REVOKE grant (vale anche prod).

## 2026-07-05 (notte, ~23:50) — app culture fix RISOLTO + 2 nuove richieste Stefano
APP-CAT FIX (incidente 2): risolto in Puntify.App/Program.cs con guard `#if DEBUG` attorno al blocco che imposta la cultura da localStorage/browser → in Debug NON cambia cultura (no crash), in Release resta dinamico. csproj ripristinato (LoadAll in Debug NON funziona: icudt.dat 404 dal DevServer, confermato). Verificato con chromium headless (~/.cache/ms-playwright/chromium-1228): l'app boota, pagina Blazor renderizzata, 0 errori cultura. Modifiche in working tree, NON committate. (2 cause distinte di "loading perenne" stanotte: (1) hot-reload TypeLoadException server, (2) culture change Debug.)
NUOVA RICHIESTA A — EMAIL candidati Sales Ambassador/BDR: inviare da info@puntify.it la bozza "Puntify | Fissiamo un primo incontro" a 8 candidati (alessandromaffei1012@virgilio.it, adamsarhan779@gmail.com, brvillaggio@gmail.com, laccettig@virgilio.it, nabihajamal4@gmail.com, gianmarco.dolce2002@gmail.com, aysenazakkaya@yahoo.com, berkaycabuk@outlook.com) + Stefano tutti in Ccn. PRIMA una PROVA a Stefano, invio ai candidati SOLO dopo suo OK. Timing "9 di oggi" già passato → chiesto conferma domani 6/7 09:00. Chiesta coerenza nome ruolo (email dice Sales Ambassador, job descr titolo BDR). Canale invio: Resend (da verificare chiave/path — RESEND non in /opt/ops/.env, cercare). ESTERNO = gate approvazione.
NUOVA RICHIESTA B — pagina "Lavora con noi" stile Apple/Stripe su Vetrina, con annuncio BDR Italia (testo esatto di Stefano). DELEGATO subagent a300c3a5f9dba30bd (bg): route /lavora-con-noi + /{lang}/, lista posizioni (1 IT), CTA candidati→mailto info@, no deploy. Anteprima su collaudo prima di deploy.
ANCORA DA CHIUDERE (queue): applicare REVOKE grant + consolidazione near su near_notified_at, poi commit queue+app-fix. In pausa mentre gestisco A/B.
PROD: Stefano ha eseguito LUI le 2 migration su DB PROD (device-vuoto + queue_remote_pending). Confermato: prod = DB separato che gestisce lui, io da qui NON la raggiungo. Assessment dato: additive/safe (confirmed DEFAULT true protegge in-loco; queue_call_next REPLACE retrocompatibile). ATTENZIONE: DB prod ora AVANTI al codice (Fase A 155a13d non deployata, Fase B non committata) → feature remota inerte finché non deploya il codice; fix QR device-vuoto completo solo dopo deploy app 6fce46c. Chiesto a Stefano se prod-app è già deployata ai commit di oggi.
APERTO: dov'è la PROD vera di Puntify? Da questa box vedo solo collaudo/CAT (cat/app-cat/api-cat.puntify.it, DB puntify_cat). Nessun container/DB prod qui → correzione: la migration in prod da qui NON la posso applicare. Chiesto a Stefano.
DA CONFERMARE con Stefano: applicare le 2 migration coda (device-vuoto + remote) — dove/come sta la prod.
