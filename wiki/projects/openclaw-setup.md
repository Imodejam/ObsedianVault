# OpenClaw Setup

## Obiettivo
Ottimizzazione configurazione OpenClaw: modelli, heartbeat, regole operative, agenti, monitoraggio.

## Stato attuale
[2026-04-21] — Sistema operativo con team di 5 agenti, ClawRoom dashboard attiva, vault Obsidian inizializzato.

## Decisioni chiave
- [2026-03] Team structure: Alfred (Chief of Staff), Carlo (Senior Engineer), Luca (Social Media), Massimo (Sales), Lidia (Design)
- [2026-03] Alfred coordina e delega — non fa lavoro operativo diretto
- [2026-03] ClawRoom come Kanban board e dashboard operativa
- [2026-03] Workflow: Stefano → Alfred → Kanban → Agente esegue
- [2026-04] Vault Obsidian come sistema memoria persistente three-layer
- [2026-04-27] LLM Standard: Tutti gli agenti devono usare Claude. Vietato l'uso di altri LLM.

## Stack / Architettura
- OpenClaw gateway su Ubuntu (tailnet)
- Claude Code CLI (v2.1.92) per agenti tecnici
- Agenti con workspace separati in `/home/openclaw/.openclaw/agents/`
- ClawRoom: Blazor app su `http://127.0.0.1:5000`
- Vault Obsidian: `/home/openclaw/obsidian-vault/` → GitHub `Imodejam/ObsedianVault`
- Google Drive: account alfredopenbotti@gmail.com, root `OpenClawData`

## Prossimi passi
- [ ] Configurare autenticazione GitHub per vault-sync
- [ ] Validare provider credentials
- [ ] Hardening e monitoraggio

## Link correlati
- [[wiki/projects/clawroom|ClawRoom]]
- [[wiki/people/stefano|Stefano Gitto]]
