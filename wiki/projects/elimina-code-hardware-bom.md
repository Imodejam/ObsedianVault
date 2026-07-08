# Elimina Code · Distinta hardware "leggera" (senza totem)

> Esempio di pezzi + costi per attivare l'Elimina Code Puntify in 1 punto vendita SENZA totem/colonnina.
> Software = Puntify (app Android + pannello operatore da browser): niente server, operatore usa PC/telefono suo, cliente usa il proprio telefono. Prezzi indicativi Amazon.it (variano). Compilato 2026-07-08 su richiesta di Stefano.

## Fasce

### FASE 0 — Solo digitale (~0€)
Cartello/adesivo con QR al banco → il cliente si mette in coda dal proprio telefono e segue turno + squillo. Operatore chiama dal suo telefono/PC. Zero hardware. Limite: serve lo smartphone del cliente.

### FASE 1 — Punto "prendi il numero" (~120–150€)
- Tablet Android 10" (Android 12+, 4GB/64GB) come schermo prendi-numero al banco → ~90–120€ (es. YESTEL Android 13, ASIN B0DG3V86T5)
- Supporto tablet da banco antifurto bloccabile → ~30€ (es. AboveTEK B0B51GFN98)

### FASE 2 — + Stampa biglietto cartaceo (+~80–100€)
- Stampante termica **USB ESC/POS** 80mm con taglio (NON Bluetooth: il ponte stampa Puntify è USB) → ~80–100€ (es. Bisofice POS-8370 USB, B0CHJPGH99). Alternativa 58mm ~50–60€.

### OPZIONE — Display "numeri chiamati" su TV esistente (+~40€)
- Box Android HDMI (Android 12+) dietro la TV, esegue l'app in modalità display → ~40€ (es. X13 Android, B0D67318HK). Più affidabile: Xiaomi Mi TV Box S ~55€ (B0CB8LHS3L). La TV da sola NON basta: serve il box Android.

## Esempio tipico
prendi-numero + display + stampa = ~270€ una tantum (tablet ~110 + supporto ~30 + stampante ~90 + box TV ~40). Senza stampa ~180€. Minimal digitale ~0€.

## Vincoli hardware (dal nostro software)
- Stampante: **USB + ESC/POS** (classe stampante), non Bluetooth — la stampa passa dal ponte USB dell'app Android (printRaw). Confermata funzionante: generica "A8/AB USB(PRN)".
- Tablet/box: **Android 12+** (minSdk 31 dell'app it.puntify.appcat).
- Display su TV = box Android HDMI (non-touch → controllo/kiosk da remoto dal pannello); vedi [[puntify-android-app]] flotta.

Cross-link: [[elimina-code]] · [[puntify-android-app]]
