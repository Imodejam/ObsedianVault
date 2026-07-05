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
