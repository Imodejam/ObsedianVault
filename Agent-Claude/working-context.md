# Working Context

## Sessione 2026-07-19 — Puntify: Nemi proposte marketing autonome (low-traffic)
Obiettivo: Nemi propone (mai invia senza approvazione) una campagna flash quando prevede
poco traffico domani vs baseline transazioni.

### Verificato (file:line)
- ICampaignService.CreateAsync/ApproveAsync — Puntify.Server/Services/Marketing/ICampaignService.cs
- Anti-auto-send: CampaignSendService.IsApproved (created_by=nemi richiede approved_at) — ICampaignSendService.cs:83,117
- Pattern OCR waiting_user: NemiChatService.cs:57-106 (resume) + 773 (HandleOcrImportConfirmAsync); marker MenuOcrImportPayload.cs:17
- Dati analyzer: transactions(shopid,insertdate,amount) / bookings(shop_id,start_at,status,customer_id); Shop.Timezone (IANA) + HasMarketing() bit 128; owner = OwnerAccountId
- Template daily hosted: WeeklyRecapSchedulerService.cs (gate config default false, owner_account_id)

### Da costruire
1. LowTrafficAnalyzer (+interface) — expectedTomorrow (bookings) vs avgBaseline (avg tx same weekday ~6-8 sett)
2. NemiMarketingProposalService : BackgroundService (gate Marketing:NemiProposalsEnabled=false)
3. Marker MarketingProposalPayload + branch in NemiChatService (HandleMarketingProposalConfirm) — riusa OCR pattern
4. Registrazione Program.cs

### Regole owner
Non toccare frontend/MenuController/StripeController/BookingServiceImpl/CampaignSchedulerService.
Verify, commentato, ASCII-safe, no commit. Build 0 errori, restart, 401 /api/menu, test live su CAT + cleanup.
