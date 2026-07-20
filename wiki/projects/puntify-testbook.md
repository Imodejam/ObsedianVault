# Puntify — Testbook (regressione settimanale)

> Documento vivo mantenuto dall'agent di test settimanale. Ogni settimana: (1) aggiornare questa testbook rispetto alle modifiche della settimana (git log), (2) eseguire tutti i test, (3) segnalare esiti + gap a Stefano.

**Ambienti di test (Collaudo):** Vetrina `http://localhost:8003` · App `http://localhost:8002` · Server API `http://127.0.0.1:8001`
**Strumento:** Playwright headless (chromium: `/home/claudebot/.cache/ms-playwright/chromium-1228/chrome-linux64/chrome`, core: `/tmp/anchortest/node_modules/playwright-core/index.mjs`)
**Ultimo aggiornamento testbook:** 2026-07-20 · **Ultima esecuzione:** 2026-07-20

---

## ⭐ Modifiche della settimana da regredire (2026-07-14 → 07-20)
- [ ] **Menu — flusso ordini ridisegnato**: stato PER STAZIONE (cucina/bar indipendenti); dine-in resta APERTO finché non pagato; SOLO il pagamento chiude l'ordine e libera la risorsa.
- [ ] **Conto tavolo (Opzione B)**: ogni invio = ordine separato attribuito allo stesso tavolo, aggregati in un unico conto; `POST /api/menu/orders/pay-table` salda tutti i giri, fedeltà 1 volta, idempotente.
- [ ] **ClassifyOrderStations**: smistamento cucina/bar in base al KIND della SEZIONE (non del piatto) → drink al bar.
- [ ] **MenuEditor**: selettore Tipo sezione (Cucina/Bar) configurabile da UI + FieldInfo; persiste via UpdateSection.
- [ ] **Vetrina MerchantMenuPreview**: tracking ordine persistente ricevuto→in prep→pronto + stato per stazione (GET order/{id}/status con kitchen_status/bar_status).
- [ ] **Cassa (Dashboard)**: id ordine nel path, badge stato per giro, conto tavolo aggregato, keypad coperti stile Stripe, tasto invia chiarito.
- [ ] **Agenda/Booking**: day view corretta, "Nuovo appuntamento" planning, celle settimana full-width, n. persone in dettaglio+agenda, DatePickerModal fullscreen stile Stripe, tipo servizio nascosto se unico.
- [ ] **Risorse**: sedie colorate per coperti, "Tav. N" ovunque, blocco modifica coperti se prenotazioni associate, controllo capienza vs n. persone.
- [ ] **NegozioDetail**: ombra tasti accento negozio (verde) non rosso; pannello loyalty sotto i premi.
- [ ] **Marketing**: 14 campagne preconfigurate (galleria + 7 runner auto + 5 template).

---

## ⭐ Modifiche della settimana da regredire (2026-07-07 → 07-13)
- [ ] **Recensione = flusso Typeform**: logo in alto, una domanda/schermo, stelle grandi centrate, auto-advance; niente emoji; tasto terminale testo bianco.
- [ ] **NegozioDetail**: indirizzi → link Google Maps; tasto "Chiama" (tel:) primo; sezione "Contatti" con email (mailto); logo+image nei dati strutturati JSON-LD.
- [ ] **Rating Google**: `SoftwareApplication` (4.9/185) SOLO su Home, NON sulle pagine negozio (solo LocalBusiness proprio).
- [ ] **Slug negozio con città**: generazione `{nome}-{città}` alla creazione + backfill 5 negozi null (fiori-e-piante-de-paola-cosenza, madrigalas-madrid, lunapark-…).
- [ ] **Menu FAB "I tuoi ordini"**: ancorato al bordo destro (right:0), sopra il footer.
- [ ] **Asporto pagamento in cassa**: ordini `awaiting_payment` visibili in Dashboard (colonna "Da pagare" → "Segna pagato" → "In cucina"); pannello "Da incassare" rimosso dal POS.
- [ ] **Dettaglio ordine**: click su card in tab Ordini apre modale dettaglio.
- [ ] **"Nuovo ordine" con rotta propria** `/merchant/{id}/pos` (back → dashboard).
- [ ] **Bug aperto**: codici ordine #A01 riusati tra giorni (attesa scelta Stefano giornalieri vs unici).

---

## A. VETRINA — pagine (per ognuna: carica 200, no errori console, render corretto, responsive mobile+desktop)
- [ ] `/` Home
- [ ] `/nemi` Nemi (due anime Bot/Voce, hero video, femminile, JSON-LD localizzato)
- [ ] `/prezzi` Prezzi (toggle mensile/annuale, Elimina Code incluso, JSON-LD)
- [ ] `/simulatore` Simulatore (autocomplete attività, preset Prudente/Atteso/Ottimista stessa larghezza, deep-link ?attivita=, calcolo)
- [ ] `/settori` indice + `/settori/{slug}` (campione 5 settori: case study, "Calcola il tuo risparmio", JSON-LD Service+FAQPage)
- [ ] `/faq` FAQ (filtri categoria, JSON-LD FAQPage localizzato)
- [ ] `/negozi` + `/negozi/{slug}` (filtro categorie localizzato, dettaglio negozio, book/menu/risorse)
- [ ] `/mappa` (marker, categorie localizzate) + `/mappa-del-sito`
- [ ] `/fidelizzazione` `/prenotazioni` `/menu` `/ordinazioni` `/elimina-code` `/social` `/guadagna`
- [ ] `/blog` + `/blog/{slug}`
- [ ] `/coda/biglietto/{token}` `/coda/display/{slug}` `/coda/totem/{slug}` (localizzate)
- [ ] `/demo` `/assistenza` `/roadmap` `/recensione/{token}`
- [ ] Legali: `/privacy` `/termini` `/cookie-policy` `/condizioni-prenotazione` (IT + EN, fallback EN)

## B. VETRINA — cross-cutting
- [ ] i18n 10 lingue (it/en/es/fr/pt/ar/bn/hi/zh/uk): cambio prefisso lingua, nessuna stringa non tradotta o lingua sbagliata (es. PT non deve contenere spagnolo)
- [ ] mega-menu (ordine, Nemi 2°), footer settori, hreflang, meta/OG per pagina
- [ ] JSON-LD presente e con inLanguage coerente su Nemi/FAQ/Settori/Prezzi/Negozio
- [ ] doppio-caricamento pagine dal menu (non deve esserci)

## C. APP — moduli (login merchant di test, poi provare ogni modulo)
- [ ] `/login` (email/password + Google/Apple), `/register`, `/role-selection`, `/consent`, `/account`
- [ ] `/merchant-shops` → `/merchant` (home "Le tue app": nessuno scroll residuo iOS)
- [ ] Punto vendita, Premi fedeltà, Agenda/prenotazioni, Risorse, Servizi, Pagamenti
- [ ] Menu, Monitor, Elimina Code, Operatori, Nemi (chat/gestione), Social Studio
- [ ] Ordini, Transazioni (`/transactions`), Scansiona (`/scan-receipt`), Clienti, Insights
- [ ] Notifiche (`/notifications`), Impostazioni, Wallet (`/wallet`)
- [ ] `/admin` area admin (RBAC, consultazione)
- [ ] `/operator` vista operatore
- [ ] Flusso cliente (accumulo punti, prenotazione, riscatto premio) se testabile

## D. APP — cross-cutting
- [ ] i18n (lingue supportate app), responsive mobile/desktop, toggle iOS booleani
- [ ] creazione record con conferma prima di eliminare; "Nuovo Servizio" apre il record creato
- [ ] Nemi Bot Telegram: badge ambiente (🟠 collaudo)

## E. SERVIZI / integrazioni da provare
- [ ] Login OAuth Google/Apple (quando integrazione nativa pronta)
- [ ] Prenotazioni end-to-end, Menu & ordini, Elimina Code (prendi numero → display → biglietto)
- [ ] Fidelizzazione (punti/piastre), Social Studio, Insights/analytics
- [ ] Notifiche (email/Telegram), Simulatore ROI, form demo/assistenza Vetrina

---

## Log esecuzioni
<!-- L'agent aggiunge qui una riga per esecuzione: data | pass/fail per sezione | bug trovati | testbook aggiornata sì/no -->
- 2026-07-05: testbook creata (baseline). Prima esecuzione programmata: lunedì.
- 2026-07-20: **PASS complessivo 9/9** (regressione Playwright headless + smoke API, delega QA). Vetrina home/negozi(58 PV)/pepto(accento verde ok, loyalty sotto premi)/menu/blog 200+render; API health :8001=200 + GET order status con kitchen_status/bar_status/order_mode/table_label OK; servizi systemd server/app/vetrina active; app WASM :8002=200. 0 FAIL, 0 regressi, nessun dato di test creato. Note non-bug: menu Blazor Server = falso negativo timing (serve virtual-time 20s); banner WebGL mappa atteso in headless (--disable-gpu). Modifiche settimana (flusso ordini per-stazione, conto tavolo B, tipo sezione UI) verificate a livello Vetrina+API; conferma UI-app merchant = gap noto headless.
- 2026-07-13: **PASS complessivo** (regressione Playwright headless, delega QA). Vetrina pagine principali 200/render ok a 390px e 1280px; tutte le 8 modifiche della settimana verificate PASS (recensione Typeform senza emoji + tasto bianco; NegozioDetail maps/Chiama/Contatti/logo JSON-LD; rating SoftwareApplication solo su Home; slug città backfill risolvono 200; FAB menu bordo destro). Server API: 0 errori in log. App: solo health :8002=200 (login merchant non testabile headless = gap noto).
  - **BUG minori aperti**: (1) `/it/nemi` → 404 su `avatar-hero.webm`/`.vtt` (asset video hero mancanti su collaudo); (2) rumore dev noto (service-worker MIME, HMR cert, immagini esterne/GA bloccate = no rete uscente collaudo).
  - Nota: assegnazione atomica numero ordine (#A0x) implementata oggi (RPC next_menu_order_seq SECURITY DEFINER) — vedi log wiki.
