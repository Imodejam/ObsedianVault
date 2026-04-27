# ClawRoom

## Obiettivo
Dashboard operativa per gestire il team AI di OpenClaw: progetti, Kanban, cronjob, modelli, costi, team.

## Stato attuale
[2026-04-21] — Funzionante con UI Apple-like, sidebar responsive, Kanban con 5 colonne.

## Decisioni chiave
- [2026-03] OpenClaw = unica fonte di verità per Agenti, Modelli, Cronjob, Token usage
- [2026-03] Persistenza locale solo per: Utenti, Progetti, Attività Kanban, Metadati UI
- [2026-03] Autenticazione Local JSON + BCrypt, admin/admin con mustChangePassword
- [2026-03] Bug critico fixato: commenti tasks.json devono essere oggetti `{"Text","Author","CreatedAt"}` — MAI stringhe

## Stack / Architettura
- Blazor Server (.NET)
- Servizio systemd: `clawroom.service`
- Porta: 5000
- Path: `/home/progetti/clawroom/`
- Persistenza: JSON locale (`LocalDataService.cs`)

## Sezioni implementate
1. Dashboard — overview
2. Progetti — CRUD con progress bar
3. Attività (Kanban) — 5 colonne: To Do, Pending, Da revisionare, Completato
4. Cronjobs — da OpenClaw API
5. Modelli — da OpenClaw + metadata UI
6. Costi — aggregati per modello
7. Team — gerarchia

## Prossimi passi
- [ ] Integrazione con vault Obsidian
- [ ] Monitoraggio uptime automatico

## Link correlati
- [[wiki/projects/openclaw-setup|OpenClaw Setup]]
- [[wiki/people/stefano|Stefano Gitto]]
