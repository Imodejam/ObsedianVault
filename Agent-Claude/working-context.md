# Working context — 2026-07-16 ~17:10 Roma

## In attesa di Stefano (2 thread)
1. PROD FIX: 3 fix pronti su CAT (hot-reload OK), da portare in prod (commit+push+deploy). Chiesto a Stefano se committare/pushare io.
   - Nemi/MiniMax 502 -> retry backoff 3x (ShopAiClient.CallMiniMaxChatAsync)
   - Upload foto sezione connection-reset -> retry transitori (S3StorageService.UploadAsync); causa primaria: PROD gira build STALE senza WHEN_REQUIRED (gia in codice) -> DEPLOY. Se persiste: nginx client_max_body_size davanti a MinIO.
   - admin_activity_log FK admin_id=0 -> guard skip (AdminService.LogAsync)
   - + verbosita: MenuController ritorna detail; MenuApiService logga status+body in console.
2. SOCIAL: inviata bozza 17/07 (raccolta_punti) per approvazione. Canali IG+LI+FB tutti connessi. Su OK -> publish.py Buffer best-time 17/07.

## Skin social — stato
- Script in /home/progetti/puntify-social/skin/ (build+test OK).
- Cron giornaliero 1430aba3: 13:37 UTC = 15:37 Roma -> bozza del giorno dopo. (One-shot 17:00 di oggi cancellato: inviato a mano.)
- Buffer: IG 69e0a49f031bfa423c0c9bb5, LI 69b986107be9f8b17166990a, FB 69b9bf437be9f8b17167d13f. Cron scade 7gg -> RI-ARMARE.

## Fatto oggi (altri)
- Popup conferma eliminazione prodotto/sezione: chiude subito (MenuEditor.razor).
- Analisi Taffo (12) + KiRweb (25) -> motore creativo integrato.

## Prossimi passi
- Ricevere: OK commit/push prod; approvazione bozza social.
- Su approvazione social: publish.py + aggiorna topic-history.
