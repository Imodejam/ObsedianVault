# Working context

## 2026-07-26/27 (notte) — Puntify: sicurezza, App Store, Play Store

### PRIORITA' ASSOLUTA PER STEFANO (in attesa)
**Eseguire in PROD `docs/DB Migrations/2026-07-27_public_data_hardening.sql` + deploy server.**
Finche' non lo fa, in produzione: nome/telefono/email di TUTTE le prenotazioni leggibili con la anon
key (pubblica per definizione), DELETE su shop_resources permesso, INSERT di ordini falsi permesso.
Verificato live in prod prima del fix. La migration rileva da sola lo schema (puntify/public), e'
idempotente, non modifica dati; lo STEP 10 puo' dare solo un WARNING se ci sono overbooking pregressi.
Consigliata anche la rotazione della anon key (richiede redeploy app+vetrina).

### FATTO E GIA' IN PROD
- Sign in with Apple: GoTrue configurato su CAT e PROD, pulsanti Google+Apple affiancati su iOS,
  conformita' Apple (no registrazione/promo/acquisti in-app, legale solo-accesso, banner PWA off).
  Bug risolto: `it.puntify.app://auth-callback` non era in URI_ALLOW_LIST -> GoTrue faceva fallback
  silenzioso al SITE_URL. App iOS ri-sottomessa da Stefano.
- Mail prod con mittente "Puntify CAT": risolto da Stefano (era nell'appsettings di prod).

### FATTO, COMMITTATO, DA DEPLOYARE IN PROD
- Sicurezza prenotazioni+ordini (vedi sopra) - codice gia' su master.
- Sicurezza menu (e8ab461): PublicShopDto (34 campi vs 56: chiusi kiosk_token, stripe_account_id,
  wifi_password, knowledge_base), stop scritture cross-tenant, upload foto whitelist+magic bytes,
  cap limit/offset catalogo.
- Prezzo mostrato = addebitato (auto-ripubblicazione snapshot +14ms + guardia che addebita il minore).
- Portate: quelle aggiunte dopo la creazione ora arrivano in cucina; held solo per dine-in.
- IVA-esclusa coerente in Vetrina, arrotondamento per riga.
- Duplicate menu completo; overlap fasce a cavallo mezzanotte (+ migration trigger su CAT).
- Vetrina: pagina /elimina-account in 10 lingue (80da0ad) + PV dell'account demo@demo.it esclusi da
  footer e sitemap (3d85be2, filtro in GetRealShops).
- Rate-limit per IP su public_api; PublicTableBooking con rate-limit e cap slot.

### GOOGLE PLAY - app it.puntify.app INVIATA IN REVISIONE
- Toolchain installata QUI: JDK17 + Android SDK in /home/claudebot/android-sdk. AAB firmato compilato
  sul server (gotcha: 599 desktop.ini Windows in res/ bloccavano aapt).
- Sorgenti in repo Puntify sotto APP/Android/AppCat (+ APP/iOS segnaposto). Keystore, password e
  certificato in ~/.secrets/android/ (600), fuori dal repo.
- Accesso Play via API con ~/.secrets/gsc-key.json; script scratchpad/play_upload.py.
- Scheda in 12 lingue (ASO trasversale professionisti+negozi), icona, feature graphic localizzato x12,
  2 screenshot. Contatti/lingua impostati via API.
- DA FARE STEFANO: credenziali demo in "Accesso all'app" (motivo di rifiuto piu' comune) e URL
  /it/elimina-account dopo il deploy Vetrina. Screenshot da migliorare (uno mostra Impostazioni
  interne con switch Collaudo/Produzione, l'altro e' il login in inglese).
- L'app TWA it.puntify.www.twa va eliminata a mano (l'API non lo permette).

### ALTRI THREAD APERTI
- Meta insights: token salvato, pagina FB ok; manca IG collegato+assegnato e token con read_insights.
- Massimo autonomo (#26): 2 conferme (frequenza, gate invii esterni).
- Audit: restano i punti MEDIA/BASSA (report nei daily 2026-07-26/27): coperto dedotto per differenza,
  PayTable non atomico, ora scontrino UTC, archivio scaricato per intero ogni 30s, indici mancanti,
  SlotCapacity mai applicato, promemoria duplicati, PII nei log, by-id pubblico espone bozze.
- Backup prod: esiste (restic->S3 Contabo, 03:00 UTC). Gap: config/segreti non inclusi, nessun alert,
  restore mai testato. Prompt gia' consegnato a Stefano per il Claude di prod.
- iOS: sorgenti da aggiungere in APP/iOS.

### Riferimenti memoria
[[project_puntify_ios_appreview]] - [[reference_puntify_android_repo]] - [[reference_puntify_gsc_access]]
- [[reference_puntify_prod_backup]] - [[reference_puntify_shop_seo_indexing]] - [[project_puntify_meta_insights]]
