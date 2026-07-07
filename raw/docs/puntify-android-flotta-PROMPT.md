# Prompt — App Android Puntify: flotta gestita (pairing + kiosk remoto) + Chromecast

Questo si aggiunge all'app Android Puntify ESISTENTE (WebView contenitore per app-cat, stampa USB, menu admin 7-tap+PIN, switch ambiente). Vedi la sua `DOCUMENTAZIONE.md`. **Non rompere** il comportamento attuale.

## Obiettivo
Trasformare (opzionalmente) un device Android in un **monitor gestito da remoto** dal pannello web Puntify. Il lato server è GIÀ pronto: qui si implementa solo il CLIENT (Android + un receiver Chromecast).

Modello: **1 device = 1 monitor assegnato**. Il device fa da terminale che apre l'URL del monitor (in kiosk o no). L'esercente lo pilota dal web (assegna monitor, sblocca, ricarica, riavvia). Online/offline dal heartbeat.

## Principio chiave: il pairing è OPZIONALE
- **Device NON collegato (default)** → l'app parte in modalità normale: WebView con l'app Puntify completa (come oggi). Nessun cambiamento per chi usa il tablet come POS/app.
- **Device collegato (pairing fatto dall'admin)** → all'avvio apre il **monitor assegnato** in kiosk. Diventa uno schermo gestito (totem coda / display cucina / display sala / bacheca / URL custom).

## Identità device
- `device_uuid`: stringa STABILE e univoca per terminale. Generala una volta (UUID random) e **persistila** in SharedPreferences (`puntify_prefs`). Non usare identificatori che cambiano a reinstall se vuoi che sopravviva; ok anche rigenerare a reinstall (in tal caso va ri-arruolato).
- `capabilities`: JSON dichiarato dal device, es. `{"touch": true, "printer": true, "screen": true}`.
  - `printer` = true se `UsbPrinterManager` rileva la stampante USB.
  - `touch` = true su tablet/POS; false su box HDMI senza touch.
  - `screen` = true sempre.

## Base URL API (device-facing)
Gli endpoint device stanno sul **server Puntify** (NON sull'host della WebView):
- Collaudo: `https://cat.puntify.it`
- Produzione: base API di produzione (allineala allo switch ambiente esistente).
- **Nessuna autenticazione** sugli endpoint `/api/devices/*` (sono pubblici, l'auth è "leggera" via `device_uuid`; ogni chiamata agisce solo sul proprio device). Content-Type `application/json`.

---

## FLUSSO 1 — Pairing (schermata nell'area admin)

Nell'**area amministrazione** dell'app (quella dei 7-tap + PIN 246810) aggiungi:
- Voce **"Collega a un negozio"** (pairing).
- Sezione **"Stato collegamento"**: mostra se collegato (nome negozio + monitor assegnato) con pulsante **"Scollega"** (locale: torna in modalità app normale; il record server resta finché l'esercente non lo rimuove dal pannello).

### Passi
1. **Start pairing** → `POST /api/devices/pair/start`
   ```json
   { "device_uuid": "<uuid>", "capabilities": { "touch": true, "printer": true, "screen": true } }
   ```
   Risposta: `{ "code": "AB3K7P", "expires_at": "2026-07-07T20:10:00Z" }`
   → Mostra il **codice a 6 caratteri** BEN GRANDE a schermo (alfabeto senza 0/O/1/I). Testo tipo: "Inserisci questo codice nel pannello Puntify → Dispositivi → Aggiungi dispositivo". Mostra anche il conto alla rovescia (scade in 10 min).

2. **Poll stato** → `GET /api/devices/pair/status?device_uuid=<uuid>` ogni ~3–5s.
   Risposta: `{ "status": "pending" | "active" | "unknown", "claimed": false|true }`
   - `claimed: true` (status `active`) → pairing riuscito: passa alla modalità monitor (Flusso 2).
   - Se il codice scade prima del claim → offri "Genera nuovo codice" (richiama pair/start).

3. L'esercente, nel frattempo, dal **web Puntify** (loggato, area esercente → pagina **Dispositivi** → tab **Devices** → **Aggiungi dispositivo**) digita il codice + un nome → il device diventa `active` e legato al negozio.

---

## FLUSSO 2 — Polling / heartbeat / comandi (device collegato)

Quando `active`, avvia un **loop di polling** ogni ~10–15s (anche in background/kiosk):

`GET /api/devices/poll?device_uuid=<uuid>`
Risposta:
```json
{
  "monitor": { "id": "<guid>", "type": "totem", "url": "https://.../coda/totem/slug?k=...&screen=totem", "kiosk": true } ,
  "command": { "type": "reload", "ts": "..." }
}
```
- `monitor` può essere `null` (device collegato ma senza monitor assegnato) → mostra una schermata neutra "In attesa di assegnazione dal pannello".
- `monitor.url` → **caricala nella WebView**. Se `kiosk: true` → entra in **modalità kiosk** (lock-task/screen-pinning + immersive fullscreen + schermo acceso). Se `kiosk: false` → mostra l'URL senza blocco.
  - Se l'URL è la stessa già caricata, NON ricaricare inutilmente (evita flicker); ricarica solo se cambia o su comando `reload`.
- `command` (consegnato **una sola volta**, poi il server lo azzera):
  - `unlock` → esci dal kiosk (sblocco remoto: fondamentale per i device **senza touch**, es. box HDMI, dove non c'è il 10-tap+PIN).
  - `reload` → ricarica la pagina corrente della WebView.
  - `reboot` → riavvia l'app (o il device se sei device owner).
  - `refresh_assignment` → rileggi subito monitor/kiosk (fai un poll immediato e applica).
- Ogni poll aggiorna `last_seen_at` lato server → il pannello mostra **online/offline**. Se il device è offline il badge diventa grigio (soglia server-side).

### Boot / autostart
- Device **collegato** → su `BOOT_COMPLETED` avvia l'app e vai DIRETTO al monitor assegnato in kiosk (signage sempre-acceso). Per il kiosk "blindato" (no uscita) serve **device owner** provisioning; senza, usa lock-task best-effort + sblocco remoto.
- Device **non collegato** → nessun autostart particolare, app normale.

### Uscita kiosk
- Device **touch** → gesto locale (es. 10-tap in un angolo + PIN del device, campo `pin` che l'esercente imposta dal pannello).
- Device **non-touch** → SOLO **sblocco remoto** (`unlock` dal pannello). Prevedi anche un ripiego combo tasti hardware/tastiera USB se possibile.

---

## Tipi di monitor (solo per capire cosa arriva in `url`)
Il server risolve lui l'URL; il device apre e basta. Tipi:
- `totem` → Vetrina `/coda/totem/{slug}?k={kioskToken}&screen=totem`
- `board` → Vetrina `/coda/display/{slug}?k={kioskToken}&screen=display`
- `queue_display` → Vetrina `/coda/{qrToken}/display`
- `kitchen` → App `/merchant/{shopId}/display/kitchen`
- `customer` → App `/merchant/{shopId}/display/customer`
- `url_custom` → URL arbitraria digitata dall'esercente (qualsiasi sito)

Nota: sui monitor `totem`, se il device ha stampante, la pagina totem chiama già il ponte `window.PuntifyNative.printRaw(base64)` per stampare il bigliettino (già gestito lato web). Quindi in kiosk la stampa continua a funzionare tramite il bridge esistente.

---

## FLUSSO 3 — Chromecast (traccia SEPARATA, display-only)

Obiettivo: usare un **Chromecast** come monitor. Il Chromecast NON esegue l'app Android: esegue una **Google Cast Receiver app** (pagina web). Dopo il "cast", il Chromecast mostra il contenuto **in autonomia** anche se il telefono chiude l'app (come YouTube/Netflix).

Componenti da realizzare:
1. **Receiver web** (pagina HTML+JS hostata su dominio Puntify, es. `https://cat.puntify.it/cast/receiver`):
   - Usa il **Google Cast Receiver SDK (CAF)**.
   - Genera/persisti un `device_uuid` in `localStorage` (i receiver Cast hanno localStorage persistente per-app).
   - Fa lo STESSO flusso: `pair/start` (mostra il codice sulla TV) → `pair/status` → una volta `active`, fa `poll` e mostra il `monitor.url` (in iframe o redirect). `capabilities` = `{"touch": false, "printer": false, "screen": true, "cast": true}`.
   - Esegue i comandi utili al contesto Cast: `reload` (ricarica), `refresh_assignment` (rilegge). `unlock`/`reboot` non hanno senso su Cast (ignorali).
2. **Sender**: per avviare, si "casta" il receiver da Chrome (desktop, tab casting) o da un mini-sender. Registrazione del receiver nella **Google Cast Developer Console** (App ID; fee dev una-tantum + registrazione seriale del Chromecast in fase di sviluppo).
3. **Caveat da comunicare all'esercente**: se il Chromecast si **spegne/riavvia** NON rilancia da solo il receiver (torna allo sfondo) → va **ri-castato**. Per signage H24 "accendi e dimentica" resta preferibile un **box Android HDMI** (che riparte solo su BOOT_COMPLETED).

Il Chromecast quindi appare nel pannello come un normale device (display-only) e si assegna un monitor come gli altri, riusando gli stessi endpoint `/api/devices/*`.

---

## Riferimento endpoint (contratto reale già implementato lato server)

### Device-facing (pubblici, base = server Puntify, nessun header auth)
| Metodo | Path | Body / Query | Risposta |
|---|---|---|---|
| POST | `/api/devices/pair/start` | `{device_uuid, capabilities}` | `{code, expires_at}` |
| GET | `/api/devices/pair/status` | `?device_uuid=` | `{status, claimed}` |
| GET | `/api/devices/poll` | `?device_uuid=` | `{monitor: {id,type,url,kiosk}\|null, command: {type,ts}\|null}` — il comando è consegnato once |

Errori: `400 device_uuid_required`, `404 not_registered` sul poll (il device deve rifare `pair/start`).

### Merchant-facing (NON per l'app device; sono la controparte web, elencati per contesto)
Auth: `X-API-Key` + JWT owner. Base `/api/shop/{shopId}`:
- `GET /devices` lista; `PUT /devices/{id}` (name, monitorId, kioskEnabled, pin, clearMonitor); `DELETE /devices/{id}`; `POST /devices/{id}/command {type}`; `POST /devices/claim {code, name}`.
- Monitor: `GET/POST/PUT/DELETE /monitors` (+auto-seed preset Totem/Bacheca/Cucina/Sala).
- Comandi validi: `unlock`, `reload`, `reboot`, `refresh_assignment`.

---

## Cosa consegnare
1. **Android**: schermata pairing nell'area admin (start + codice grande + poll status + stato collegamento + scollega); loop di polling (heartbeat + apertura monitor + kiosk on/off + esecuzione comandi once); autostart BOOT_COMPLETED per device collegato; gestione device touch vs non-touch (sblocco remoto); dichiarazione capabilities (incluso printer da UsbPrinterManager). Mantieni intatto tutto il resto (WebView app, stampa, switch ambiente).
2. **Chromecast** (traccia separata): receiver web CAF che riusa gli stessi endpoint `/api/devices/*` (pair→poll→mostra monitor), registrazione Cast Console, sender per avviare, col caveat del re-cast dopo riavvio.

Parametri device (base URL collaudo/prod) allineati allo switch ambiente esistente. Chiedi pure se qualcosa è ambiguo, ma il contratto server sopra è definitivo e già live in collaudo.
