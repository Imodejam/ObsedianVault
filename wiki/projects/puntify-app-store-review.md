# Puntify — App Store Review (app iOS)

Pagina wiki: gestione della review App Store dell'app iOS Puntify (`it.puntify.app`, contenitore WKWebView su app.puntify.it).

## Stato
App RESPINTA (submission ad547ee3-4a34-4230-b9f0-5b8d99e33f1e, v1.0(6), review 17/07/2026, iPad Air 11" M3) per 4 motivi. Remediation completata lato codice su COLLAUDO il 26/07/2026.

| # | Guideline | Problema | Stato |
|---|---|---|---|
| 1 | 4.8 Login Services | login terzo (Google) senza opzione equivalente conforme | ✅ FATTO — Sign in with Apple (GoTrue configurato, testato); pulsanti Google+Apple affiancati |
| 2 | 5.1.2(i) Privacy/ATT | privacy label dichiarano tracking senza prompt ATT | ⏳ STEFANO — correggere etichette su App Store Connect (nessun SDK tracking → no ATT) |
| 3 | 3.1.1 Promo codes | sconti sbloccati con codici promo | ✅ FATTO — campo referral/promo nascosto in app iOS |
| 4 | 3.1.1 Business registration | registrazione account business in-app | ✅ FATTO — nell'app iOS niente toggle/registrazione: solo login + nota "Registrati su puntify.it" |

Extra fatto: blocco acquisti digitali in app nativa (abbonamento, crediti marketing, minuti Nemi Voce) con modale "acquista da browser"; banner PWA "Installa" nascosto in app; frase legale in app parla solo di accesso.

## Come funziona il gating
Tutto basato su `puntifyNativeAuth.isNative()` (true SOLO in WKWebView nativa, contratto `window.PuntifyNative.oauth` + messageHandler). Fuori dall'app (Safari/PWA/desktop) il comportamento resta invariato: registrazione, promo, banner install.

## Prerequisiti per il RI-INVIO
1. Correggere le etichette privacy su App Store Connect (togliere "Usato per tracciare").
2. **DEPLOY IN PROD** di app+server (l'app punta al sito live: senza deploy Apple rivede la versione vecchia) e configurare il provider Apple anche su **GoTrue di PROD** (su collaudo è fatto).
3. Nuova build Xcode SOLO se cambia il codice nativo (le modifiche sono lato web ⇒ potrebbe non servire).
4. Inserire un account di test nelle Review Notes.

## Testi pronti
Review Notes (EN) e risposta al Resolution Center (EN) inviati a Stefano su Telegram il 26/07/2026 — riassumono i 4 punti e come sono stati risolti.

## Credenziali/config Apple (collaudo)
Team ID XY3S34VXP8 · Services ID it.puntify.signin · Key ID W5Q3DDS9TJ · bundle it.puntify.app. Client secret JWT ES256 in `.secrets/` (SCADE 2027-01-22, da rigenerare). GoTrue: `GOTRUE_EXTERNAL_APPLE_*` in /opt/ops (servizio gotrue-puntify-cat). Callback: https://api-cat.puntify.it/auth/v1/callback (prod: dominio prod).

Collegamenti: [[projects/puntify]] · vedi anche log e daily 2026-07-26.
