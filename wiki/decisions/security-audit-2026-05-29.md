# Security & bug audit — Puntify (2026-05-29)

Audit completo App + Vetrina + Server richiesto da Stefano. 5 agenti paralleli per area. Finding verificati con evidenza.

## CRITICAL (azione immediata / decisione di Stefano)

1. **Chiave privata Firebase committata in git** — `Puntify.Server/Config/puntify-firebase-adminsdk.json` è tracciato (`git ls-files` conferma). Il `.gitignore` riga 360 copre `Config/firebase-adminsdk.json` (nome diverso) → NON lo esclude. Contiene `private_key` RSA del service account `firebase-adminsdk-fbsvc@puntify-63841`.
   → **Ruotare/revocare la chiave su GCP**, `git rm --cached`, riscrivere history se repo condiviso, correggere .gitignore.

2. **`Security:ApiKey` servita al client WASM** — `Puntify.App` è Blazor WebAssembly; `wwwroot/appsettings.json` contiene `Security.ApiKey`, scaricata da ogni browser. È l'UNICO gate degli endpoint non-`/api/public` del server. Quindi tutti quegli endpoint sono di fatto pubblici. (AnonKey nello stesso file è OK, pubblica per design.)
   → Non può essere un segreto in WASM. Spostare l'auth client→server sul JWT Supabase dell'utente, validato lato server. Ruotare la chiave.

3. **Nessuna autorizzazione per-utente sui controller → IDOR sistemico** — 0 `[Authorize]`/claims nei Controller; unico gate = API key condivisa (pubblica, vedi #2). L'appartenenza shop/booking è decisa dall'id nell'URL scelto dal client. Esempi: `ShopCustomersController` espone nome/email/telefono clienti di QUALSIASI shop; cancel/confirm/restore booking by-Guid cross-merchant (`BookingController:135-173`); `MenuOrdersController.SetStatus` cambia stato ordini di altri shop.
   → Ricavare account/shop dal token e verificare appartenenza (account_shops) su ogni lettura/mutazione.

4. **Token JWT (access+refresh) in cookie NON-HttpOnly + localStorage** — `SessionCookieService.cs` + `auth-helper.js:17-19,36`: cookie scritto da JS senza HttpOnly/Secure, token anche in localStorage; refresh TTL ~400 giorni. Qualsiasi XSS ruba la sessione persistente.
   → Almeno `Secure`; non tenere il refresh in storage JS; valutare BFF con cookie HttpOnly server-side.

## HIGH

5. **PostgREST filter injection via `slug`** (anon, service_role) — `PublicBookingController.cs:59,567`, `BookingController.cs:268`, `ReceiptsController` hash: `$"slug=eq.{slug}"` SENZA `Uri.EscapeDataString`. `ISupabaseClient` concatena il filtro grezzo nell'URL (SupabaseClient.cs:62-64,120,140). MenuController lo fa già correttamente (con escape) → incoerenza. Fix: escape + whitelist `^[a-z0-9-]+$`.
6. **Loyalty/punti — frode**: doppio accredito su approvazione scontrino senza idempotenza (`ReceiptApproval.razor:381-399`); punti calcolati lato client e fidati lato server (`ScanReceipt.razor:834-880`); riscatto premio non atomico + check saldo solo client (`RewardDetail.razor:298-339`). Fix: RPC/transazione server-side che riverifica saldo/ratio e scrive atomicamente; RLS che vieti insert di transazioni credito dal client.
7. **XSS**: `Scan.razor:350` MarkupString con DisplayName cliente (XSS verso il merchant); `MerchantMenuPreview.razor:1037` `href="@VideoUrl"` → `javascript:` (XSS verso clienti); `PrimaryColor` iniettato in `<style>` (`PublicBookingFlow.razor:45`, `Merchant.razor:61`) → CSS injection. Fix: niente MarkupString su input utente; validare schema http/https; validare PrimaryColor hex.
8. **~19 scritture senza guard sessione** (JWT scaduto → anon → 42501): BookingAvailability, BookingSettings, BookingExceptions, BookingOptions, OperatorServices, TablesManager, BookingManualBlocks, ShopServices, BookingClosures, TakeawayWindows. Aggiungere `IsAuthenticatedAsync()` come già fatto in OperatorAvailability/ShopOperators.
9. **Segreti server in `appsettings.Development.json`** (NON committato, ma tutti insieme su disco): service_role JWT valido fino al 2036, Anthropic/OpenAI/Resend keys, `Credentials:MasterKey` (AES delle credenziali shop), Telegram token/secret. → user-secrets/env/secret manager.

## MEDIUM
- `confirmation_token` (capability per cancellare/spostare booking) loggato in chiaro (`PublicBookingController:488,507,554`, `BookingController:233-236`).
- FCM device token loggato intero sul path d'errore (`FirebaseNotificationService.cs:260`).
- API key accettata anche in query string `?key=` (`ApiKeyAuthMiddleware.cs:52`) → finisce nei log.
- Letture anon di `accounts`/`transactions`/`shops` dipendono solo da RLS; `Negozi.razor` mostra anche shop fake; `Shop` espone WifiPassword/VatCode/KnowledgeBase. Verificare RLS + proiettare DTO.
- `Qty` non validata (>0) negli ordini menu pubblici (`MenuController` SubmitOrder/CreateOrder).
- Eccezioni inghiottite (`catch { return new(); }`) nei metodi loyalty → stato incoerente mascherato.

## LOW
- Webhook Telegram: confronto secret non constant-time + no anti-replay (`TelegramWebhookController.cs:41`).
- `BlogPost.razor:92` rende HTML grezzo (contenuto admin/AI).
- URL server hardcoded di fallback nei service.

## Note OK (no falso positivo)
- CORS con whitelist esplicita (no AllowAnyOrigin). API key server-side confrontata timing-safe (SHA-256+FixedTimeEquals) — il problema è che il segreto è pubblico. Booking by-token usa Guid non enumerabile (capability) — corretto. Filtri con Guid/int/date = safe. `.Filter(col,op,value)` del client PostgREST encoda il valore — non injectable.

## Priorità d'azione
1. Ruotare SUBITO: Firebase private key (#1), service_role + tutti i segreti Development.json (#9), Security:ApiKey (#2). Sono potenzialmente già compromessi.
2. Decisione architetturale: modello auth client→server (JWT utente) + authz per-shop (#2,#3) + storage token (#4).
3. Fix contenuti applicabili subito: slug escaping (#5), XSS schema/MarkupString (#7), guard sessione (#8), Qty>0, niente token nei log. ← candidati a fix immediato.
