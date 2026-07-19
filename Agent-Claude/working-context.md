# Working Context

## COMPLETATO 2026-07-19 - Puntify Nemi proposte marketing autonome (low-traffic)
Consegnato server-side (no commit). Dettaglio in Agent-Claude/daily/2026-07-19.md.
File: LowTrafficAnalyzer.cs, MarketingProposalPayload.cs, NemiMarketingProposalService.cs (nuovi);
Program.cs + NemiChatService.cs (modificati, branch [MKT_PROPOSAL] mirror OCR).
Gate Marketing:NemiProposalsEnabled default FALSE. Anti-auto-send invariato/verificato. Trace su CAT + cleanup.

### Prossimi passi possibili
- UI merchant per vedere/gestire le proposte flash pending_approval (regola UI-editable)
- Attivare il gate su un negozio pilota quando Stefano vuole test reale
