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

## Stato: in attesa da Stefano: accesso dati PROD (sez.1) + conferma 9:00 IT + fix GA4. Poi implemento (delega a subagent).
