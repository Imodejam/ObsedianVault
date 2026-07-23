# Monitoring Dashboard interno (multi-progetto)
Richiesta Stefano 2026-07-23: cruscotto interno SEPARATO da Puntify che monitori piu progetti (Puntify, Piracity...) e mostri, per progetto, cosa fanno gli agent (es. direttore marketing).

## Valutazione: usare Clawroom? -> SI
Clawroom (/home/progetti/clawroom, .NET8 Blazor Server, :5000, clawroom.service, JSON file-based, auth cookie single-user, design Apple-like) e' GIA un dashboard di monitoraggio/coordinamento di agent AI su progetti. Separato da Puntify (soddisfa il requisito).

### Gia presente (riusabile)
- Progetti (CRUD), Task/Kanban con stato+assignee+commenti, Team/Agent org-chart (con "direttore" in cima), LLM logs (costi/token per modello/agent), pagina Cronjobs, Memory browser. Componenti UI (metric card, project card, kanban, org chart, log table) copy-pastabili.

### Gap principali (= il cuore della richiesta)
- Manca concetto di "Run"/timeline attivita: "agent X ha fatto Y dalle HH alle HH con esito Z".
- Legge dati OpenClaw statici + team.json, NON la macchina marketing reale.

## Dati reali del "direttore marketing" (da collegare)
Macchina in /home/progetti/puntify-social (NON in Clawroom):
- cron daily_propose.py (16:17) -> proposta social giornaliera -> daily_propose.log
- cron director_review.sh (lun 05:23) = review settimanale del DIRETTORE -> director_review.log
- artefatti: posts/, calendar.json, topic-history.json, planning/*.md
Altri job: puntify-morning-report.sh (6:04), piracity-newsletter-dispatch.sh (mensile).

## Piano proposto (2 fasi)
- F1 (rapida): pagina aggregata per-progetto + timeline attivita, leggendo log/artefatti/cron esistenti (read-only). Costi/ultimo run/stato/agenti coinvolti/approvazioni in attesa.
- F2: gli agent PUSHano eventi strutturati (webhook/append JSONL) -> real-time + gestione approvazioni dal dashboard.

## Domande aperte a Stefano (inviate 2026-07-23)
1. Parto da Puntify (ha la marketing machine) e poi Piracity?
2. F1 read-only degli artefatti (veloce) o subito eventi strutturati pushati (robusto)?
3. Approvazioni (es. post social) gestibili dal dashboard stesso?
4. Tenere JSON file o passare a Postgres?

## Stato: in attesa risposte Stefano prima di sviluppare (delega a subagent).
