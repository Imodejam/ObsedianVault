# Working context · 2026-05-25

## Stato attuale: Puntify Telegram-Nemi

**Obiettivo sessione**: collegare Nemi a Telegram per ricevere notifiche merchant + chattare con l'AI dal telefono. Multi-PV via Forum Topics.

### Implementato (code-complete, live su CAT)
- Migration `docs/DB Migrations/20260605_telegram_nemi_link.sql` (3 tabelle + RLS + grants) — pronta, **NON ancora applicata**
- Modelli C# `AccountTelegramLink`, `ShopTelegramTopic`, `TelegramLinkCode` in `Punto.Shared/Models/`
- `Puntify.Server/Services/Telegram/`: `NemiTelegramBot`, `TelegramDtos`, `TelegramNemiRouter`, `TelegramMerchantNotifier`, `TelegramWebhookSetupHostedService`
- `INemiChatService` estratto da `ShopAiController.NemiSend` (no loopback HTTP)
- Controller `TelegramWebhookController` (webhook pubblico validato via secret) + `AccountTelegramLinkController` (start/get/sync/delete)
- `NotificationHelper.NotifyReceiptRequestAsync` e `NotifyNewPublicBookingForMerchantAsync` cablati → Telegram
- UI App `Pages/Merchant/MerchantTelegram.razor` + voce in `MerchantAccount.razor` + `TelegramLinkApiService`
- DI registrazioni in `Program.cs`
- Config in `appsettings.Development.json` (token placeholder, secret generato, WebhookPublicUrl=`https://cat.puntify.it/api/public/telegram/webhook`)

### Verificato in CAT
- Build server OK (0 errori)
- Build App OK (0 errori)
- Endpoint `GET /api/account/telegram-link?accountId=...` raggiungibile via `cat.puntify.it` → ritorna 400 con accountId vuoto (validazione attiva)

### In attesa di Stefano (bloccanti per E2E)
1. **Applicare migration** su Supabase + `docker restart postgrest-puntify-cat`
2. **Creare bot @BotFather** → fornire NemiBotToken (set anche `/setjoingroups=ON` e `/setprivacy=DISABLE`)

### Quando entrambi pronti
1. Aggiornare `appsettings.Development.json` con vero `Telegram:NemiBotToken`
2. Restart `puntify-server` → `TelegramWebhookSetupHostedService` registra webhook
3. E2E: app → "Collega Telegram" → codice → crea gruppo TG con Topics → invia `/start CODE` → server crea N topic per PV → notifica scontrino di test → chat Nemi nel topic

### Decisione architetturale
Vedi `wiki/decisions/telegram-nemi-multi-pv-topics.md`: un gruppo Telegram per account, un Forum Topic per ogni PV. Routing notifiche e chat Nemi via `(chat_id, message_thread_id)` → `shopId`.
