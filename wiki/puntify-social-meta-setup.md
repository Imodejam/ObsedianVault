# Puntify SocialStudio — setup app Meta (Instagram + Facebook)

> Guida per collegare Instagram + Facebook a Puntify SocialStudio. Una sola app Meta copre entrambi (e Threads). Serve un account Meta developer + Meta Business.

## Prerequisiti
- Account su https://developers.facebook.com (login con Facebook).
- Un **Meta Business** (business.facebook.com).
- L'account **Instagram** deve essere **Business o Creator** e **collegato a una Pagina Facebook** (Instagram → Impostazioni → Account → Passa a professionale, poi collega alla Pagina).

## Passi
1. developers.facebook.com → **Le mie app** → **Crea app** → tipo **Business**.
2. Nome app (es. "Puntify Social"), email, seleziona il Business.
3. Nella dashboard dell'app aggiungi i prodotti:
   - **Accesso Facebook** (Facebook Login) → per l'OAuth.
   - **Instagram Graph API** (o "Instagram") → per pubblicare su IG.
4. **Accesso Facebook → Impostazioni → URI di reindirizzamento OAuth validi**: incolla ENTRAMBI:
   - `https://cat.puntify.it/api/oauth/callback/facebook`
   - `https://cat.puntify.it/api/oauth/callback/instagram`
5. **Impostazioni → Di base**: copia **ID app** (= Client ID) e **Chiave segreta** (= Client Secret). Imposta anche dominio dell'app e URL privacy/termini (Puntify).
6. Permessi (scopes) da richiedere:
   - Facebook Pagine: `pages_show_list`, `pages_read_engagement`, `pages_manage_posts`, `business_management`.
   - Instagram: `instagram_basic`, `instagram_content_publish`.
7. **Modalità sviluppo vs Live**: in **Sviluppo** funziona subito per te e per gli utenti aggiunti come **Ruoli → Tester/Admin** (usa il tuo IG/FB per testare senza revisione). Per usarlo con esercenti terzi serve **Revisione dell'app** (App Review) + **Verifica Business** dei permessi sopra (processo di giorni/settimane).

## Cosa mandare a Claude (per attivare la connessione)
- **ID app** (Client ID)
- **Chiave segreta** (Client Secret)
- Conferma che l'IG è Business/Creator collegato a una Pagina FB.

Claude imposta nel server (`/opt/ops/.env` o appsettings):
```
Facebook:ClientId, Facebook:ClientSecret, Facebook:RedirectUri = https://cat.puntify.it/api/oauth/callback/facebook
Instagram:ClientId, Instagram:ClientSecret, Instagram:RedirectUri = https://cat.puntify.it/api/oauth/callback/instagram
```
(stesso ID/secret dell'app Meta per entrambi; cambia solo il RedirectUri). Poi riavvio il server e in SocialStudio i pulsanti "Collega" di Instagram/Facebook diventano attivi.

## Altri provider (dopo Meta)
- TikTok → app su TikTok for Developers (config `TikTok:*`, redirect `/api/oauth/callback/tiktok`).
- YouTube → Google Cloud, YouTube Data API v3 (config `YouTube:*`, redirect `/api/oauth/callback/youtube`).
- Pinterest → Pinterest Developers (config `Pinterest:*`, redirect `/api/oauth/callback/pinterest`).
- Threads → coperto dalla stessa app Meta (config `Threads:*`, redirect `/api/oauth/callback/threads`).

## Note
- Verificare l'host esatto del server (cat.puntify.it/api vs api-cat.puntify.it) prima di registrare gli URI in Meta.
- I redirect registrati in Meta devono combaciare ESATTAMENTE con i RedirectUri in config.
