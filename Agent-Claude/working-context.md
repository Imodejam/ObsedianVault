## Sessione 2026-06-28 — Puntify Vetrina: traduzioni mancanti (IN CORSO)

### Richiesta Stefano
"Entrando come spagnolo vedo sezioni non tradotte. Ricontrolla tutte le pagine e ogni minima scritta. Tutto tradotto in tutte le lingue." + (msg 4521) aggiornami man mano + ogni giorno alle 9:00 dimmi cosa manca.

### CAUSA PRINCIPALE (RISOLTA)
- Resources/SharedResource.<lang>.resx: es/fr/zh/ar/hi/bn/pt avevano 3489 chiavi vs master 4989 → 1500 mancanti IDENTICHE per tutte e 7 → fallback a SharedResource.resx (italiano).
- Master = union(SharedResource.resx neutrale, SharedResource.en.resx).
- FATTO: tradotte 1500×7 via subagent (IT sorgente, EN aiuto). + 12 chiavi GCal mancanti in EN tradotte a mano. Tutte le 9 lingue ora complete (0 untranslated effettivo). Build+restart puntify-vetrina (:8003). Verificato live ES (/es/prenotazioni) e ZH.
- Artefatti: scratchpad/puntify-i18n/ (src_missing.json, out/<lang>.json, merge.py).

### RESIDUO SECONDARIO (DA DECIDERE CON STEFANO)
Testi hardcoded fuori dal resx (appaiono uguali in tutte le lingue):
1. PAGINE LEGALI — Privacy.razor, Termini.razor, CookiePolicy.razor = testo IT hardcoded per TUTTE le lingue (no @if lingua). CondizioniPrenotazione.razor = IT+EN (var `en = Lang!=it`, non-italiano vede INGLESE). Tradurre legali in 9 lingue = scelta legale → CHIEDERE.
2. ETICHETTE MARKETING piccole: Footer "Condizioni di Prenotazione" (label hardcoded, anche MappaDelSito), accent word nei titoli (es. <span>Blog/Policy/Condizioni</span>), BlogPost "Articolo non trovato". → sistemabili (estrarre in resx).
3. PAGINE APP-LIKE: Recensione.razor (recensione cliente via token), Risorse.razor (risorse negozio) = 0 L[], nessuna traduzione. Non sono vetrina marketing → CHIEDERE se in scope.

### TODO
- [ ] Risposta Stefano su scope legali/app.
- [ ] Fix etichette marketing hardcoded (cat. 2).
- [ ] Impostare report giornaliero 9:00 (cosa manca).

### Report giornaliero — FATTO (aggiornamento)
- CronCreate job `917cdd01`: ogni giorno 07:03 UTC (=09:03 Italia, macchina TZ=UTC) → report "cosa manca" a Stefano (chat_id 505161324) via telegram reply. Session-only + auto-expire 7gg (re-impostare). Gate: TODO legali/app + fix etichette marketing hardcoded restano aperti.
