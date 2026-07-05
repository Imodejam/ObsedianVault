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
IN CORSO: FASE B coda remoto (UI) delegata a subagent — pulsante "Mettiti in coda" (vetrina+app), pagina gestione link email conferma, campo "quanti numeri da remoto" in impostazioni coda, notifica in-app.
DA CONFERMARE con Stefano: applicare in PROD le 2 migration coda (device-vuoto + remote).
