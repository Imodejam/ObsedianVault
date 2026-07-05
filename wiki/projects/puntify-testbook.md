# Puntify — Testbook (regressione settimanale)

> Documento vivo mantenuto dall'agent di test settimanale. Ogni settimana: (1) aggiornare questa testbook rispetto alle modifiche della settimana (git log), (2) eseguire tutti i test, (3) segnalare esiti + gap a Stefano.

**Ambienti di test (Collaudo):** Vetrina `http://localhost:8003` · App `http://localhost:8002` · Server API `http://127.0.0.1:8001`
**Strumento:** Playwright headless (chromium: `/home/claudebot/.cache/ms-playwright/chromium-1228/chrome-linux64/chrome`, core: `/tmp/anchortest/node_modules/playwright-core/index.mjs`)
**Ultimo aggiornamento testbook:** 2026-07-05 (creazione) · **Ultima esecuzione:** —

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
