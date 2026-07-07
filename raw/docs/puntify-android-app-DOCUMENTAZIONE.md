# Puntify Android — Documentazione completa

> Documento di riferimento: cosa è stato realizzato, configurazioni, accessi, credenziali,
> contratto del bridge nativo, stampa USB e passi successivi.
> Ultimo aggiornamento: **7 luglio 2026**.

---

## 1. Cos'è l'app

App Android nativa (Kotlin) che fa da **contenitore WebView unico** per la web app Puntify:
una sola app per clienti, esercenti, totem e tutti i servizi. Carica la web app a schermo
intero e mette a disposizione del contenuto web:

- la **stampante USB** del terminale (comande cucina, biglietti totem coda) via ESC/POS;
- **funzioni native** (modalità kiosk/totem, schermo sempre acceso);
- gestione **permessi** (camera per QR/foto, geolocalizzazione, upload/download file).

**Caratteristiche tecniche**
- `minSdk 31` → funziona da **Android 12** in su. `targetSdk 34`, `compileSdk 34`.
- Package / applicationId: **`it.puntify.appcat`**. App label: **Puntify**.
- Kotlin 1.9.24, AGP 8.5.2, Gradle 8.7, AndroidX. WebView di sistema (Chromium).
- Distribuzione: **APK sideload** (adb / installazione manuale). Niente Play Store per ora.
- Dispositivo di riferimento: **Olivetti TAO** (POS Android). Testato su **MINT POS**.

---

## 2. Ambiente di sviluppo (installato manualmente)

Sul Mac **non** c'era Homebrew né Android Studio. Toolchain installato scaricando archivi:

| Componente | Percorso |
|---|---|
| **JDK 17** (Temurin arm64) | `~/Library/Java/JavaVirtualMachines/temurin-17.jdk` |
| **Android SDK** | `~/Library/Android/sdk` |
| SDK packages | `platform-tools`, `platforms;android-34`, `build-tools;34.0.0` |

> Java di sistema è solo la 11 (e 8). AGP 8.5 richiede **JDK 17**: esportare `JAVA_HOME` sul 17.

---

## 3. Come compilare, installare, collegare il device

### Build & install (dalla cartella `AppCat/`)
```bash
export JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"

./gradlew assembleDebug     # genera l'APK
# → app/build/outputs/apk/debug/app-debug.apk

./gradlew installDebug      # compila e installa sul device collegato
# oppure installazione manuale:
~/Library/Android/sdk/platform-tools/adb install -r app/build/outputs/apk/debug/app-debug.apk
```

### Collegamento del terminale (debug WIRELESS — usato in questo progetto)
Il POS non veniva visto via USB (cavo solo-ricarica), quindi si usa il **debug Wi-Fi**
(Android 11+). **Telefono/POS e Mac devono essere sulla STESSA rete** (NON la rete guest,
che isola i dispositivi).

1. Sul device: Opzioni sviluppatore → **Debug wireless** → ON.
2. "Associa dispositivo con codice di associazione" → mostra `IP:porta` + codice a 6 cifre.
3. Sul Mac (tenere la schermata di associazione aperta, i valori scadono in fretta):
   ```bash
   adb pair 192.168.1.x:PORTA CODICE
   ```
4. Dopo l'associazione il device si connette da solo (mDNS). Verifica con `adb devices -l`.
5. Dopo un riavvio del device va rifatto `adb connect` / il pairing se cambia rete.

### Comandi utili
```bash
adb devices -l                                  # elenco device
adb -t 1 install -r <apk>                        # installa/aggiorna
adb -t 1 shell am force-stop it.puntify.appcat   # chiudi app
adb -t 1 shell monkey -p it.puntify.appcat -c android.intent.category.LAUNCHER 1  # avvia
adb -t 1 exec-out screencap -p > screen.png      # screenshot
```

---

## 4. URL e ambienti

Definiti in `Prefs.kt` (enum `Environment`). Cambio dal **menu admin**.

| Ambiente | URL | Note |
|---|---|---|
| **Collaudo** (default) | `https://app-cat.puntify.it` | L'APP vera (Blazor WebAssembly): login, POS, cucina, totem |
| Produzione | `https://app.puntify.it/app` | Blazor WebAssembly, base href `/app/` |

**Chiarimento importante sugli host** (scoperto durante il lavoro):
- `app-cat.puntify.it` = **l'app di collaudo** (Blazor WASM). Risponde 200, nessuna auth. ✅ è questo che l'app carica.
- `cat.puntify.it` = **sito marketing** (Blazor Web .NET 8, "Your whole business…"), protetto da
  **HTTP Basic** (`Basic realm="restricted"`). NON è l'app. L'app non lo usa.
- `app.puntify.it/app` = **app di produzione** (Blazor WASM).

L'app resta sempre dentro la WebView per tutti gli URL `http/https` (così login OAuth,
redirect e pagamenti funzionano). Solo schemi non-web (`mailto:`, `tel:`, ecc.) aprono app esterne.

---

## 5. Accesso ADMIN (menu nascosto)

- **Come si apre:** **7 tap rapidi nell'angolo in ALTO a SINISTRA** dello schermo (entro ~3s),
  poi si inserisce il PIN.
- **PIN amministratore predefinito: `246810`** (modificabile via codice in `Prefs.DEFAULT_PIN`;
  il valore salvato sta nelle SharedPreferences `admin_pin`).
- Il gesto è "trasparente": non intercetta i tocchi della web app (usa `dispatchTouchEvent`),
  quindi non disturba l'uso normale.

---

## 6. Impostazioni disponibili (schermata admin)

| Impostazione | Descrizione | Chiave pref |
|---|---|---|
| **Ambiente** | Collaudo (`app-cat`) / Produzione (`app.puntify.it/app`) | `environment` |
| **Accesso collaudo (HTTP Basic)** | User/Password opzionali per host protetti da Basic Auth | `basic_auth_user`, `basic_auth_pass` |
| **Modalità totem (kiosk)** | Lock-task + fullscreen immersivo + schermo acceso | `kiosk` |
| **Schermo sempre acceso** | Tiene il display acceso durante l'uso | `keep_screen_on` |
| **Stampante USB** | Mostra lo stato (assente / rilevata / pronta + nome) | — |
| **Stampa di prova** | Invia una ricevuta di test alla stampante (via `printText`) | — |
| **Salva e ricarica** | Salva e ricarica la web app con le nuove impostazioni | — |

Le preferenze sono in `SharedPreferences` **`puntify_prefs`**
(`/data/data/it.puntify.appcat/shared_prefs/puntify_prefs.xml`).

---

## 7. Credenziali (riservate)

| Cosa | Valore |
|---|---|
| **PIN admin** (default) | `246810` |
| **HTTP Basic collaudo** (host `cat.puntify.it`, NON usato dall'app) | user: `user` — pass: `puntify83!` |

> Nota: `app-cat.puntify.it` (l'app effettiva) **non** richiede Basic Auth. Il login utente
> (email/password, Google) avviene dentro la web app.

---

## 8. Bridge JS ↔ nativo (contratto)

L'app espone alla web app l'oggetto nativo **`window.PuntifyAndroid`** (`@JavascriptInterface`)
e inietta all'avvio uno **shim** che popola **`window.PuntifyNative`**. La web app **formatta**
il contenuto, Android **stampa**.

```javascript
window.PuntifyNative.platform             // "android"
window.PuntifyNative.appVersion           // es. "1.0"
window.PuntifyNative.capabilities         // { print, cashDrawer, keepScreenOn, kiosk }

// Stampa — ritornano un oggetto {ok:true} oppure {ok:false, error:"..."}
window.PuntifyNative.printRaw(base64EscPos)   // byte ESC/POS grezzi (base64) — PREFERITO
window.PuntifyNative.printText(text)          // testo semplice (fallback)
window.PuntifyNative.openCashDrawer()         // kick cassetto ESC/POS

// Stato / capacità
window.PuntifyNative.getPrinterStatus()       // { present, ready, name }
window.PuntifyNative.refreshCapabilities()    // rilegge e ritorna capabilities

// Funzioni native
window.PuntifyNative.keepScreenOn(true|false) // schermo sempre acceso
window.PuntifyNative.setKiosk(true|false)     // modalità totem
```

**Evento**: `window.dispatchEvent(new Event('puntifynativeready'))` viene emesso quando lo shim
è pronto e ad ogni collegamento/scollegamento della stampante (per aggiornare `capabilities`).

**Esempio d'uso lato web:**
```javascript
window.addEventListener('puntifynativeready', () => {
  if (window.PuntifyNative?.capabilities?.print) {
    const escpos = buildComanda(order);          // Uint8Array di byte ESC/POS (lato web)
    const b64 = btoa(String.fromCharCode(...escpos));
    const res = window.PuntifyNative.printRaw(b64);
    if (res.ok) mostraOk(); else mostraErrore(res.error);
  }
});
```

---

## 9. Stampa USB — dettagli tecnici

- **Tecnologia:** Android **USB Host API** (`UsbManager`). Modulo `UsbPrinterManager.kt`.
- **Rilevamento:** cerca un'interfaccia di **classe PRINTER (7)**; se assente, fallback su
  qualunque device con **endpoint BULK OUT** (per stampanti vendor-specific).
- **Permesso USB:** auto-concesso via `res/xml/device_filter.xml` (classe 7) + intent-filter
  `USB_DEVICE_ATTACHED` quando la stampante è collegata; altrimenti richiesta con attesa
  bloccante (max 12s) alla prima stampa. Hot-plug gestito.
- **Scrittura:** `bulkTransfer` a blocchi da 16 KB. `printRaw` invia i byte **tal quali**.
- **`printText`** costruisce ESC/POS minimale: `ESC @` (init) + testo Latin-1 + avanzamento +
  **taglio parziale** `GS V 66 0`.
- **Cassetto:** `ESC p 0 0x19 0xFA` sullo stesso endpoint.

### ✅ Stampa CONFERMATA FUNZIONANTE (7 lug 2026)
Testata sul **MINT POS** con stampante USB:
- Nome: **"A8 USB(PRN) Printer"**
- **VID `045b` / PID `5311`**, interfaccia **classe 7**, nodo `/dev/bus/usb/005/005`
- Rilevata come "Pronta", permesso concesso, ESC/POS scritto → **stampa fisica OK**.

---

## 10. Permessi & configurazione WebView

**Permessi (AndroidManifest):** `INTERNET`, `ACCESS_NETWORK_STATE`, `CAMERA`,
`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`. Feature: `usb.host`, `camera` (opzionali).

**WebView:** JavaScript, DOM storage, database, `mediaPlaybackRequiresUserGesture=false`,
cookie di terze parti, `useWideViewPort`, solo HTTPS (cleartext disabilitato, errori SSL bloccati).
- **Camera** (QR/foto): `onPermissionRequest` → concede `RESOURCE_VIDEO_CAPTURE` dopo il permesso Android.
- **Geolocalizzazione:** `onGeolocationPermissionsShowPrompt`.
- **Upload file** (`<input type=file>`): `onShowFileChooser`.
- **Download** (http/https via DownloadManager, `data:` salvato in Download).
- **User-Agent** marcato **`PuntifyAndroid/1.0`** (la web app riconosce di girare nell'app nativa).
- **Back hardware** = cronologia WebView; `target=_blank`/`window.open` caricati nella stessa WebView.
- **HTTP Basic** gestito (dialog + salvataggio credenziali) per host protetti.

---

## 11. Modalità kiosk / totem

- `setKiosk(true)` (da bridge) o interruttore nelle impostazioni:
  **lock-task** (screen pinning) + **immersive fullscreen** (nasconde status/nav bar) +
  **schermo sempre acceso**. Le barre si riattivano temporaneamente con swipe.
- Utile per il **totem coda** (route web `/coda/totem/{slug}?k={token}`).
- Nota: il lock-task pieno (senza uscita) richiede che l'app sia **device owner** del POS;
  altrimenti è lo screen pinning standard di Android.

---

## 12. Icona & splash

- **Icona app:** "P" bianca su fondo rosso (`#B71A19`), icona adattiva. Origine:
  `Utility/Puntify.2k.jpg`.
- **Splash:** fondo bianco con logo+scritta Puntify centrati. Origine:
  `Utility/Puntify.logocompleto.png`. Splash di sistema (Android 12) + overlay brandizzato
  in-app fino al primo caricamento.
- **Colore brand:** rosso **`#B71A19`** (estratto dai file logo).

---

## 13. Struttura del progetto

```
AppCat/
├─ app/src/main/
│  ├─ AndroidManifest.xml          permessi, USB attach, activity
│  ├─ java/it/puntify/appcat/
│  │   ├─ MainActivity.kt          WebView, permessi, client, kiosk, gesture admin, shim
│  │   ├─ PuntifyBridge.kt         @JavascriptInterface "PuntifyAndroid" (contratto)
│  │   ├─ UsbPrinterManager.kt     USB Host API + ESC/POS
│  │   ├─ SettingsActivity.kt      pannello admin
│  │   └─ Prefs.kt                 ambiente, kiosk, schermo, PIN, credenziali
│  └─ res/
│     ├─ layout/activity_main.xml  WebView + progress + overlay splash
│     ├─ values/                   strings, colors (#B71A19), themes
│     ├─ xml/device_filter.xml     filtro USB stampante (classe 7)
│     ├─ mipmap-*/                 icona adattiva (foreground P)
│     └─ drawable-nodpi/           splash_icon, splash_logo
├─ README.md
├─ DOCUMENTAZIONE.md               (questo file)
└─ gradle / gradlew / build.gradle
```

---

## 14. Cosa è stato testato e confermato ✅

- App compilata e installata sul POS via debug wireless.
- Caricamento di **`app-cat.puntify.it`** con **sessione persistente** (dashboard Puntify
  completa: Point of sale, Menu, Queue Manager, Orders, Scan, ecc.).
- Rebranding: status bar rossa, icona P, splash con logo Puntify.
- Menu admin (7 tap + PIN `246810`) → schermata impostazioni funzionante.
- **Stampa USB ESC/POS end-to-end confermata** (stampa fisica su carta).

---

## 15. TODO / passi successivi (non bloccanti)

1. **Lato web Puntify:** generare i byte ESC/POS di comande cucina (`MenuPublicOrder`:
   `order_code`, `items[]`, `table_label`, `order_mode`, `customer_note`, `total`…) e biglietti
   totem coda, e chiamare `PuntifyNative.printRaw(base64)`. È la parte da fare lato Blazor.
2. **Test sull'Olivetti TAO** con la sua stampante `AB USB(PRN)` (dovrebbe essere identico:
   stessa via USB Host classe 7).
3. **FCM nativo** per notifiche a schermo bloccato (il web push in WebView non è affidabile):
   token FCM nativo passato alla web app via bridge.
4. Eventuale **bridge OAuth nativo** (`window.puntifyNativeAuth`) se Google blocca il login in WebView.
5. **Release firmata** (.aab/.apk con keystore) quando si andrà in distribuzione.
6. Valutare **device owner** sul POS per il kiosk pieno (blocco uscita totem).
