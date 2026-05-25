# Decisione · Telegram-Nemi: multi-PV via Forum Topics

**Data**: 2026-05-25
**Stato**: implementata (codice deployato su CAT, in attesa di token bot e migration applicata)

## Contesto

Stefano vuole ricevere le notifiche merchant Puntify direttamente sul telefono via Telegram, e poter chattare con Nemi (assistente AI Anthropic) da Telegram. La conversazione deve essere contestualizzata sul singolo PV in caso di multi-shop.

## Opzioni considerate

1. **Webhook vs long polling** → Webhook scelto: HTTPS già pronto (Caddy + Let's Encrypt), efficienza, no always-on.
2. **Multi-PV nella chat**:
   - PV "attivo" persistente con /switch
   - Nemi capisce dal testo qual è il PV
   - **Ogni PV = un Forum Topic dedicato** ← scelta
3. **Notifiche su Telegram**: tutte le notifiche merchant (no filtraggio).
4. **Bot**: bot dedicato `@PuntifyNemiBot` (Stefano lo crea via @BotFather), separato dal bot admin di sistema.

## Decisione

**Un gruppo Telegram per account merchant. Dentro al gruppo, un Forum Topic per ogni PV.** Le notifiche del PV finiscono nel suo topic. Quando il merchant scrive nel topic X, Nemi risponde con i dati del PV X (shopId desunto dal `(chat_id, message_thread_id)`).

## Perché Forum Topics e non chat separate

- Un singolo gruppo è più ordinato: un solo "thread di conversazione" sul telefono, navigazione via tab Topics nativa di Telegram.
- Un solo deep link da fornire al merchant (`?startgroup=CODE`).
- Comando `/sync` per allineare automaticamente i topic quando l'account aggiunge nuovi PV.
- Niente confusione tra "quale chat è di quale PV": il topic ha il nome del PV come label.

## Architettura (riassunto)

- Tabelle nuove: `account_telegram_links` (account ↔ gruppo), `shop_telegram_topics` (shop ↔ thread), `telegram_link_codes` (codici usa-e-getta).
- Endpoint pubblico `POST /api/public/telegram/webhook` validato via header `X-Telegram-Bot-Api-Secret-Token`.
- Bot dedicato `@PuntifyNemiBot` (token in `Telegram:NemiBotToken`).
- `INemiChatService` estratto da `ShopAiController.NemiSend` per consentire invocazione lato server senza loopback HTTP.
- `TelegramMerchantNotifier` cablato in `NotificationHelper` per duplicare le notifiche FCM nei topic.

## Risorse correlate

- Plan: `/home/claudebot/.claude/plans/voglio-estendere-le-prenotazioni-enchanted-sunset.md`
- Codice server: `Puntify.Server/Services/Telegram/`
- UI App: `Pages/Merchant/MerchantTelegram.razor`
- Migration: `docs/DB Migrations/20260605_telegram_nemi_link.sql`

## Aperto

- Hardening sicurezza: oggi chiunque scrive nel gruppo linkato è trattato come proprietario. Possibile evoluzione: matching `from.id` ↔ admin del gruppo (`getChatAdministrators`).
- Comando `/mute` per silenziare categorie: rinviato (Stefano vuole tutto attivo MVP).
- Inline keyboard per azioni dirette (approva/rifiuta scontrino da chat): post-MVP.
