# Puntify

## Obiettivo
Fidelity card digitale per esercenti: il cliente accumula punti mostrando un QR code, l'esercente scansiona e carica punti. Niente tessere fisiche.

## Prodotto
- **PWA** installabile come app nativa (iOS/Android/web)
- Esercente scansiona QR code cliente → carica punti automaticamente
- Analisi abitudini d'acquisto + promozioni mirate
- Funziona anche senza POS, con integrazioni custom
- Carte visibili offline dal cliente, transazioni richiedono connessione
- Multi-negozio illimitato, clienti/transazioni/premi illimitati

## Prezzi
- Esercente: €9,99/mese o €99,99/anno (-20€)
- Cliente: app gratuita
- Nessun costo attivazione, nessun vincolo, disdetta quando vuoi

## Offerta Lancio (primi 300 esercenti)
- 3 mesi gratis con Codice Amico
- 2 mesi gratis senza codice
- Nessuna carta di credito richiesta

## Programma Referral
- **Esercente → collega**: +1 mese gratis per iscrizione pagata (max 12 mesi cumulabili)
- **Cliente → esercente**: buono Amazon (€10 piano mensile, €20 annuale)

## Competizione (vs altre soluzioni)
| | Altre | Puntify |
|---|---|---|
| Attivazione | €500-2000 | Gratis |
| Abbonamento | €29-99/mese | €9,99/mese |
| Carte fisiche | Costo extra | Non servono |
| App cliente | Spesso no | Inclusa |
| Multi-negozio | Limitato | Illimitato |
| Contratto | 12-24 mesi | Nessun vincolo |

## Società
- **Puntify S.R.L.**, Via Giuseppe Pascaletti, Cosenza
- P.IVA: 12345678912
- Email: info@puntify.it
- GDPR compliant, crittografia end-to-end

## Stato attuale
[2026-04-21] — Early stage. Sito live con Home, Prezzi, FAQ, Privacy, Termini. Alcune funzionalità ancora in sviluppo.

## Stack / Architettura
_(da definire nel dettaglio)_

## Ambiente CAT
Vedi [[wiki/projects/cat-stack|CAT Stack]] per i dettagli infrastrutturali. Riepilogo Puntify:
- **DB**: `puntify_cat` su cluster `ops-postgres` in `/opt/ops/` (pro-open). Schema `puntify` (29 tabelle, match prod, rinominato da `public` il 2026-05-17).
- **Auth**: GoTrue v2.179.0 dedicato (`gotrue-puntify-cat`, 127.0.0.1:18999).
- **REST**: PostgREST v12.2.3 dedicato (`postgrest-puntify-cat`, 127.0.0.1:18998), `PGRST_DB_SCHEMAS=puntify,storage`.
- **Endpoint client**: `SUPABASE_URL=https://api-cat.puntify.it`, anon key in `/opt/ops/.env`. Client devono inviare `Accept-Profile: puntify` (Supabase C# SDK: `options.Schema = "puntify"`).
- **Frontend CAT**: `https://cat.puntify.it` (`GOTRUE_SITE_URL`).
- **DbGate**: `https://db-cat.puntify.it`.
- **Storage**: 5 objects metadata migrati; file fisici restano su MinIO esterno (`files.puntify.it` bucket `*-cat`).
- **OAuth Google**: redirect URI `https://api-cat.puntify.it/auth/v1/callback` aggiunto su client OAuth prod.

## Mercato target
- **Prima zona: ROMA** — bar, caffetterie, parrucchieri, lavanderie (alta frequentazione, basso ticket)
- Prodotto LIVE: sito + app up and running
- Obiettivo: primi 300 esercenti

## Prossimi passi
- [ ] Definire stack tecnico
- [ ] Piano editoriale social

## Assets
- Sito: https://puntify.it
- Google Drive: `OpenClawData/progetti/Puntify`

## Documenti collegati
- [[wiki/projects/puntify-nomi-alternativi|Nomi alternativi]] — lista 35 (top 10 raccomandati) post-diffida Spotify
- [[wiki/projects/puntify-lista-esercenti-trastevere-testaccio|Lista esercenti Trastevere+Testaccio]] — 20 target prima zona
- [[wiki/projects/puntify-template-approccio-esercenti|Template approccio esercenti]] — script vendita

## Link correlati
- [[wiki/people/stefano|Stefano Gitto]]
- [[wiki/projects/cat-stack|CAT Stack]]
