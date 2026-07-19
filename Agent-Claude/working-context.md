# Working Context

## COMPLETATO 2026-07-19 - 14 campagne marketing + revisione Social Studio (tutto CAT, testato)
- Marketing catalogo: 7 runner auto + 5 modelli manuali + registry + email 10 lingue + galleria UI CampaignCatalog.razor (toggle/config/usa-modello) + 5 endpoint. Migration 20260721_campaign_presets (colonne + unique + FIX CHECK kind 'auto'/'manual_template'). Testato end-to-end (enable/disable/patch/use-template, validazioni). AUTO nascono paused, gate globale OFF.
- Social Studio: modifica bozza (PATCH+UI), cutoff import 12 mesi, shop_social_settings (cadenza+profondita per PV, migration 20260721_social_settings), background service cadenza per-PV, enrichment sentiment su import (era MANCANTE). Immagini solo-URL. Testato (settings GET/PUT).
- Delegato a 3 subagent (backend mkt / social / frontend mkt), orchestrato + testato + fixato io.
### PENDENTI
- Commit+push del blocco (attendo OK Stefano): fix audit-log + roadmap fixes + Marketing FASE-1 + admin gates + catalogo 14 campagne + Social. NIENTE Co-Authored-By Claude.
- Deploy prod guidato (checklist puntify-deploy-checklist-20260719.md, ora 10 migration).
- Pubblicazione reale IG/FB/TikTok resta stub (fuori scope, serve OAuth+API provider).

## COMPLETATO 2026-07-19 - FIX bug audit-log admin (fermo dal 14/07)
Causa: `AdminUser` senza `[JsonPropertyName]` + `_readJsonOptions` STJ case-sensitive -> `admin.Id=Guid.Empty` -> `LogAsync` esce alla guardia. Anche `Profile` restava default "super" (RBAC latente). FIX: `[JsonPropertyName]` su tutti i campi AdminUser. Verificato 2x (241->243 righe, admin_id reale). Build 0 errori. NON committato (attendo OK).
### Pendenti da Stefano
- Approvazione catalogo 14 campagne marketing precon​figurate (presentate msg 6732)
- OK "committa e pusha" per il blocco uncommitted (roadmap fixes + Marketing Fase-1 + admin gates + roadmap.razor + fix audit-log)
- Deploy prod guidato (checklist in wiki/projects/puntify-deploy-checklist-20260719.md)

## COMPLETATO 2026-07-19 - Puntify Nemi proposte marketing autonome (low-traffic)
Consegnato server-side (no commit). Dettaglio in Agent-Claude/daily/2026-07-19.md.
File: LowTrafficAnalyzer.cs, MarketingProposalPayload.cs, NemiMarketingProposalService.cs (nuovi);
Program.cs + NemiChatService.cs (modificati, branch [MKT_PROPOSAL] mirror OCR).
Gate Marketing:NemiProposalsEnabled default FALSE. Anti-auto-send invariato/verificato. Trace su CAT + cleanup.

### Prossimi passi possibili
- UI merchant per vedere/gestire le proposte flash pending_approval (regola UI-editable)
- Attivare il gate su un negozio pilota quando Stefano vuole test reale
