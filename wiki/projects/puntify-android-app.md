# Puntify · App Android (WebView + ponte stampante USB)

> App Android nativa (Kotlin) = **contenitore WebView unico** per la web app Puntify. Una sola app
> per clienti, esercenti, totem, tutti i servizi. Espone al web la **stampante USB** (ESC/POS) e
> funzioni native (kiosk/totem, schermo acceso). Costruita da Stefano (lato Mac) — doc consegnata 2026-07-07.

## Stato
- **App: PRONTA e testata.** Compila, si installa su POS (debug wireless), carica `app-cat.puntify.it`
  con sessione persistente. **Stampa USB ESC/POS confermata funzionante** (fisica su carta).
- **Pezzo mancante = lato web Puntify (Blazor), tocca a noi:** generare i byte ESC/POS di
  **comande cucina** e **biglietti totem coda** e chiamare `PuntifyNative.printRaw(base64)`. → TODO #1.

## Identità app
- Package/applicationId: `it.puntify.appcat` — label **Puntify** — brand rosso `#B71A19`.
- `minSdk 31` (Android 12+), `targetSdk 34`. Kotlin. WebView di sistema (Chromium).
- Distribuzione: **APK sideload** (adb), no Play Store per ora.
- Device riferimento: **Olivetti TAO** (POS Android). Testato su **MINT POS**.

## URL / ambienti (menu admin)
| Ambiente | URL |
|---|---|
| Collaudo (default) | `https://app-cat.puntify.it` |
| Produzione | `https://app.puntify.it/app` |
- Chiarimento host: `app-cat.puntify.it` = **l'app** (Blazor WASM, 200, no auth). `cat.puntify.it` =
  sito marketing protetto Basic Auth (NON usato dall'app). `app.puntify.it/app` = app prod.

## Accesso admin app
- **7 tap rapidi angolo ALTO-SINISTRA** (entro ~3s) → PIN. **PIN default `246810`** (`Prefs.DEFAULT_PIN`).
- Gesto trasparente (dispatchTouchEvent, non disturba la web app).
- Impostazioni: ambiente, Basic Auth user/pass, kiosk, schermo acceso, stato stampante, stampa di prova.

## Bridge JS ↔ nativo (CONTRATTO — il web formatta, Android stampa)
Espone `window.PuntifyAndroid` (@JavascriptInterface) + shim che popola **`window.PuntifyNative`**:
```javascript
window.PuntifyNative.platform            // "android"
window.PuntifyNative.appVersion          // "1.0"
window.PuntifyNative.capabilities        // { print, cashDrawer, keepScreenOn, kiosk }
window.PuntifyNative.printRaw(base64EscPos)  // byte ESC/POS grezzi base64 — PREFERITO → {ok:true}|{ok:false,error}
window.PuntifyNative.printText(text)         // testo semplice (fallback)
window.PuntifyNative.openCashDrawer()        // kick cassetto
window.PuntifyNative.getPrinterStatus()      // { present, ready, name }
window.PuntifyNative.refreshCapabilities()   // rilegge capabilities
window.PuntifyNative.keepScreenOn(bool)
window.PuntifyNative.setKiosk(bool)
```
- **Evento** `puntifynativeready` su `window` quando lo shim è pronto e a ogni collega/scollega stampante.
- **User-Agent** marcato `PuntifyAndroid/1.0` (il web riconosce di girare nell'app nativa).
- Esempio: costruisci `Uint8Array` ESC/POS lato web → `btoa(String.fromCharCode(...bytes))` → `printRaw(b64)`.

## Stampa USB (dettagli)
- Android USB Host API (`UsbManager`), modulo `UsbPrinterManager.kt`. Cerca interfaccia classe PRINTER(7),
  fallback su qualunque device con endpoint BULK OUT. Auto-permesso via `device_filter.xml` + intent
  `USB_DEVICE_ATTACHED`. Scrittura `bulkTransfer` blocchi 16KB, byte tal quali.
- `printText` = `ESC @` + Latin-1 + taglio parziale `GS V 66 0`. Cassetto `ESC p 0 0x19 0xFA`.
- **Confermato (7 lug):** MINT POS, "A8 USB(PRN) Printer", VID `045b`/PID `5311`, classe 7, stampa fisica OK.

## Kiosk / totem
- `setKiosk(true)`: lock-task (screen pinning) + immersive fullscreen + schermo acceso. Utile per
  totem coda `/coda/totem/{slug}?k={token}`. Lock-task pieno (no uscita) richiede **device owner** sul POS.

## TODO lato web Puntify (nostri)
1. **[PRIORITÀ] ESC/POS comande cucina** (`MenuPublicOrder`: order_code, items[], table_label, order_mode,
   customer_note, total…) e **biglietti totem coda** → `PuntifyNative.printRaw(base64)`. Rilevare
   `capabilities.print`, ascoltare `puntifynativeready`.
2. FCM nativo (token passato via bridge) per push a schermo bloccato.
3. Eventuale bridge OAuth nativo se Google blocca login in WebView.
4. Release firmata (keystore) alla distribuzione. Device owner sul POS per kiosk pieno.

## Flotta gestita (pairing device + kiosk remoto) — contratto server LIVE collaudo
Modello: 1 device = 1 monitor assegnato. Pairing OPZIONALE (default = app normale; collegato = apre monitor in kiosk).
- **Device-facing (pubblici, base server = collaudo https://cat.puntify.it, NESSUNA auth):**
  - `POST /api/devices/pair/start` `{device_uuid, capabilities}` → `{code(6ch), expires_at}` (TTL 10min, alfabeto no 0/O/1/I)
  - `GET /api/devices/pair/status?device_uuid=` → `{status: pending|active|unknown, claimed}`
  - `GET /api/devices/poll?device_uuid=` → `{monitor:{id,type,url,kiosk}|null, command:{type,ts}|null}` (comando consegnato ONCE, azzerato; aggiorna last_seen)
- **Merchant-facing** (X-API-Key + JWT owner, RequireShopOwner) `/api/shop/{shopId}`: `GET/PUT/DELETE devices`, `POST devices/{id}/command {type}`, `POST devices/claim {code,name}`; `GET/POST/PUT/DELETE monitors` (auto-seed preset Totem/Bacheca/Cucina/Sala).
- **Comandi validi:** unlock (esci kiosk, per non-touch), reload, reboot, refresh_assignment.
- **Monitor types** (URL risolta da FleetService): totem→Vetrina /coda/totem/{slug}?k={kioskToken}&screen=totem; board→/coda/display/{slug}?k=&screen=display; queue_display→/coda/{qrToken}/display; kitchen→App /merchant/{shopId}/display/kitchen; customer→/display/customer; url_custom→url libera.
- Controller: DevicesController.cs (device-facing), ShopDevicesController.cs + ShopMonitorsController.cs (merchant); modelli Punto.Shared/Models/Fleet/Device.cs+Monitor.cs; ApiKeyAuthMiddleware bypassa /api/devices.

DA FARE LATO ANDROID (prompt consegnato a Stefano 2026-07-07, `raw/docs/puntify-android-flotta-PROMPT.md`): schermata pairing nell'area admin (7-tap+PIN) + polling (heartbeat/apri monitor/kiosk/comandi once) + autostart BOOT_COMPLETED per device collegato + sblocco remoto per non-touch. **Chromecast** = traccia separata: receiver Google Cast (CAF) che riusa gli stessi endpoint /api/devices/* (pair→poll→mostra monitor); caveat: no auto-relaunch al riavvio Chromecast → per H24 meglio box Android HDMI. Tipi device: tablet/POS touch, box HDMI non-touch, Chromecast display-only via Cast.

## Sorgente
- Documento originale completo di Stefano: `raw/docs/puntify-android-app-DOCUMENTAZIONE.md` (7 lug 2026) — include anche ambiente di sviluppo (JDK17/Android SDK), comandi build/install/adb wireless, credenziali (PIN admin `246810`, Basic Auth collaudo), struttura progetto AppCat.

Cross-link: [[puntify]] · [[elimina-code]] (totem/coda) · [[puntify-nemi-voce-vapi]]
