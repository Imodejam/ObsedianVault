# Puntify · Scheda Google Play (it.puntify.app)

> Scheda store multilingua caricata via **Google Play Developer API v3**. Stato: **BOZZA** —
> nessuna pubblicazione, nessuna promozione di release. Ultimo aggiornamento: 2026-07-27.

## Coordinate tecniche
- Package Play: **`it.puntify.app`** (NB: l'APK sideload storico usa `it.puntify.appcat` — vedi [[puntify-android-app]])
- `defaultLanguage` della app: **it-IT**
- Service account: `/home/claudebot/.secrets/gsc-key.json` (scope `androidpublisher`)
- Traccia `internal`: release **draft, versionCode 1** — NON toccata (production/beta/alpha vuote)

## Endpoint usati (gotcha inclusi)
```
POST   /androidpublisher/v3/applications/{pkg}/edits            -> editId
PUT    /edits/{editId}/listings/{language}                      {language,title,shortDescription,fullDescription}
POST   /upload/androidpublisher/v3/applications/{pkg}/edits/{editId}/listings/{language}/{imageType}?uploadType=media
GET    /edits/{editId}/listings/{language}/{imageType}          <- lista immagini
DELETE /edits/{editId}/listings/{language}/{imageType}          <- deleteall (idempotenza screenshot)
POST   /edits/{editId}:validate   poi   :commit
```
- **GOTCHA immagini**: il path corretto è `/listings/{lang}/{imageType}`, **non** `/images/{lang}/{imageType}`
  (quello risponde 404 HTML). Vale per upload, list e deleteall.
- **GOTCHA locale**: Play **rifiuta `ro-RO` e `uk-UA`** ("The requested language is not currently
  supported") — i codici accettati sono **`ro`** e **`uk`**. Le altre 10 vogliono il codice pieno.
- `imageType` usati: `icon`, `featureGraphic`, `phoneScreenshots`.
- Un `:commit` invalida gli edit concorrenti: fare un edit per volta.
- Ogni locale costa ~4 upload -> il giro completo dura ~10 minuti: lanciare in background.

## Lingue attive (12)
`it-IT` (principale) · `en-US` · `en-GB` · `es-ES` · `de-DE` · `fr-FR` · `nl-NL` · `pl-PL` · `ro` · `ru-RU` · `uk` · `pt-PT`

Ognuna ha: title + shortDescription + fullDescription, 1 icona, 1 feature graphic **localizzato**, 2 screenshot.

## Linea ASO (decisa 2026-07-27)
Posizionamento **trasversale**, non food-only: la scheda deve funzionare anche per **studi e liberi
professionisti** (avvocati, medici/dentisti, fisioterapisti, psicologi, nutrizionisti, veterinari,
commercialisti, notai, architetti/ingegneri, agenzie).
- `title` (max 30): brand + keyword principale della lingua, senza superlativi/emoji/"gratis".
- `shortDescription` (max 80): un verbo + le keyword trasversali (appuntamenti/prenotazioni/clienti/fedeltà/cassa).
- `fullDescription` (max 4000, usate ~2,3-2,7k): hook trasversale -> **PER STUDI E PROFESSIONISTI** ->
  **PER NEGOZI, BAR E RISTORANTI** -> FEDELTÀ DIGITALE -> STATISTICHE -> **PER CHI È** (long tail di
  categorie) -> COME INIZIARE (account su puntify.it) -> nota cloud/multilingua -> "non traccia gli
  utenti per finalità pubblicitarie".
- Stesso ordine delle funzioni in tutte le lingue; keyword **adattate**, non tradotte alla lettera
  (de `Kundenkarte/Treuepunkte/Kasse`, es `fidelización/TPV/citas`, pl `program lojalnościowy`,
  nl `klantenkaart/kassa`, pt-PT `marcações/fidelização/caixa`, ru `запись на приём/бонусы/касса`).
- `Puntify` e `Nemi` restano invariati; **Nemi è femminile** in tutte le lingue.
- Play **non** ha un campo keyword (a differenza di Apple): le keyword vivono dentro i testi.

## Grafica
- `icon-512.png` (512x512), `screen-01/02.png` (1080x2400) uguali per tutte le lingue.
- **Feature graphic localizzato**: generato per lingua da `play_store/gen_feature.py` riusando il logo
  dell'originale (ripulisce la banda di testo e ridisegna la tagline tradotta con DejaVu Sans Bold,
  autoscaling 34->18px). DejaVu copre cirillico, diacritici polacchi e le virgole sotto romene (ș/ț).

## Punti aperti / da sistemare
- `screen-02.png` è la schermata **Impostazioni** dell'app con lo switch **Collaudo/Produzione** e
  "Accesso collaudo HTTP Basic": è materiale interno, poco vendibile in vetrina store. Da sostituire
  con screenshot di agenda/prenotazioni, cassa e fedeltà (idealmente localizzati).
- `screen-01.png` (login) è in inglese anche sulle locale non inglesi.
- Consigliato aggiungere `tabletScreenshots` (l'app gira su tablet/POS) e `video`.

Cross-link: [[puntify]] · [[puntify-android-app]] · [[puntify-app-store-review]] · [[puntify-funzionalita]]
