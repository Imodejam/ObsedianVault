# Working Context

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
