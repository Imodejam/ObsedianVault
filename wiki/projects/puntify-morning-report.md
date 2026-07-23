# Report mattutino Puntify (@PuntifyNemiBot)
Richiesta Stefano 2026-07-23: report giornaliero alle 9:00 IT (=07:00 UTC) via @PuntifyNemiBot, 5 sezioni.

## Sezioni richieste
1. KPI utenti in prod, servizi ecc.
2. Ticket aperti su Jira
3. Andamento analytics generale (crescita)
4. Prossime azioni
5. Punti aperti

## Esistente
- Cron: `4 6 * * * /home/claudebot/scripts/puntify-morning-report.sh` (8:04 IT). Usa GIA @puntifynemibot (token da appsettings.Development.json BotToken) -> chat 505161324. Contenuto attuale: stato servizi + errori 24h + disco/mem/load.

## Readiness sezioni
1. Servizi/infra PRONTO. KPI utenti PROD = BLOCCO: DB prod NON su questo server (qui solo puntify_cat/piracity_cat). Serve accesso dati prod (creds/endpoint) -> chiesto a Stefano (opz: a-creds prod, b-proxy CAT, c-solo servizi).
2. Jira PRONTO: config in appsettings (BaseUrl movenapp.atlassian.net, ProjectKey PNT, ApiToken presente). NB endpoint vecchio /rest/api/3/search RIMOSSO -> usare POST /rest/api/3/search/jql. Testato: PNT ha issue aperte.
3. GSC PRONTO. GA4 property 57764779 ancora 403 (service account non sulla property) -> Stefano da risistemare.
4-5. Dal vault (working-context/project pages) -> richiede agente Claude (non bash).

## Architettura decisa
Sostituire il cron bash con un AGENTE CLAUDE schedulato (cron locale `claude -p ...`) alle 07:00 UTC: raccoglie servizi+KPI+Jira(PNT)+GSC/GA4, legge vault per sez.4-5, compone e invia via @puntifynemibot. Tutto locale (vault/keys/DB/Jira su questo box) -> cron locale, non routine cloud.

## Stato: IMPLEMENTATO e TESTATO (2026-07-23)
- Script: `/home/claudebot/scripts/daily-report/puntify-daily-report.sh` (orchestratore bash).
- Helper: `jira.py` (POST /rest/api/3/search/jql, basic auth email:apitoken, JQL project=PNT statusCategory!=Done), `analytics.py` (GSC trend 7gg/7gg/28gg + GA4 con degrade su 403). venv persistente `daily-report/venv` (google-auth+requests).
- Flusso: raccoglie blob deterministico (servizi/infra/errori24h + Jira + GSC/GA4) + contesto vault (working-context, log.md, 2 project page recenti) -> `claude -p` compone 5 sezioni IT plain per Telegram -> invio via Bot API sendMessage (token BotToken da appsettings, mai loggato). Fallback: se `claude -p` fallisce/timeout 120s invia blob grezzo. Non esce mai senza inviare (salvo token mancante).
- Sez.1 KPI utenti prod = placeholder "in attesa accesso dati produzione" (DB prod non su questo box). Fornisce comunque stato servizi + infra.
- GA4 property 57764779: ancora 403 -> degrada "GA4: accesso non ancora attivo". Da sistemare (SA come Visualizzatore su property).
- Cron: `0 7 * * *` (09:00 IT). Vecchio `4 6 ... puntify-morning-report.sh` DISABILITATO (commentato nel crontab).
- Test reale: eseguito con prefisso `[TEST report mattutino]` -> INVIO OK a chat 505161324. Report ~1.3k char, 5 sezioni sensate.
