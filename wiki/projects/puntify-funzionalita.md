# Puntify — Resoconto funzionalità (interno)

> Stato: 2026-06-06. Fonte: codice (App Blazor WASM, Server .NET, Vetrina Blazor Server) + copy vetrina.
> Scopo: mappa completa di cosa offre Puntify, per comunicazione interna ed esterna.

## In una riga
Puntify è una **piattaforma all-in-one per negozi e PMI italiane**: fidelizzazione a punti, prenotazioni online, menu & ordini, pagamenti e assistente AI (Nemi) — in un unico abbonamento. Lato cliente è un **wallet digitale** gratuito con tutte le carte fedeltà.

## Posizionamento ufficiale (dalla vetrina)
- Hero: "Più clienti, più prenotazioni, meno tempo perso."
- Desc: "piattaforma all-in-one per esercenti italiani: fidelizzazione a punti, prenotazioni online e assistente AI Nemi. Tutto in un solo abbonamento."
- Footer tagline: "Il sistema di fidelizzazione digitale per tutte le PMI italiane."
- Prezzi: abbonamento unico **da 7,99€/mese per punto vendita** (sconti volume), **3 mesi gratis** (primi 300). Nemi a consumo **da 23€/mese**.

## Funzionalità per ESERCENTE
- **Fidelizzazione a punti**: QR cliente, scansione scontrino con AI, accredito punti (ratio configurabile), premi personalizzati, riscatto, notifiche automatiche (offerte, compleanno).
- **Prenotazioni online**: pagina dedicata per PV; appuntamenti (servizi + operatori, slot con durata/buffer, multi-servizio in cascata, cross-sell automatico); risorse (tavoli, ombrelloni/lettini, campi, sale…) con **editor mappa/planimetria**; unità flessibili (slot / giornata / mezza giornata / periodo / evento); agenda Giorno/Settimana/Planning; conferme e promemoria automatici; disponibilità, blocchi manuali, stagioni, addon/allestimenti.
- **Menu digitale & ordini**: menu prodotti e/o servizi, sezioni, allergeni/tag, abbinamenti; ordini al tavolo, alla postazione (lidi/stabilimenti) e per il ritiro.
- **Pagamenti online (Stripe Connect Express)**: incasso prenotazioni con acconto/saldo, fondi diretti al merchant, una sola trattenuta; application fee Puntify a scaglioni dinamici (0,8% / 0,65% / 0,5% per volume mensile, pavimento 0,05€).
- **Nemi (assistente AI)**: risponde al **telefono h24**, gestisce prenotazioni, FAQ, filtra spam, raccoglie contatti — **privacy-first, zero registrazioni audio**; assistente operativo anche dentro l'app.
- **Social Studio**: gestione social, recensioni, competitor, KPI.
- **Schermi** (digital signage), **notifiche** push/email.
- **Multi-PV e multi-utente**, ruoli; **recensioni**; **analytics/insights**.
- **Integrazione Telegram** (Nemi, gruppi, sync PV).
- **Programma affiliazione** (presenta negozi → mesi gratis o buoni Amazon).
- **Multilingua** (vetrina/menu in più lingue).

## Funzionalità per CLIENTE
- **Wallet digitale** con tutte le carte fedeltà: un solo QR per ogni negozio, **gratis per sempre**, niente tessere né app diverse.
- Accumulo punti e riscatto premi; prenotazioni presso i negozi; notifiche offerte/compleanno.
- **Mappa e directory** dei negozi Puntify; programma referral.

## VETRINA pubblica
- Sito marketing: Home, Esercenti, Clienti, Prezzi, FAQ, Blog, Nemi, Prenotazioni, Menu, Fidelizzazione, Guadagna.
- Pagine pubbliche negozio `/m/{slug}` (vetrina, menu, prenotazione, risorse), recensioni, mappa, directory negozi.
- SEO: meta tag per pagina + JSON-LD.

## AREA ADMIN di sistema (nuova, 2026-06)
- Console `/admin` (sola consultazione v1): Clienti, Esercenti (+ PV), Pagamenti (ricavi/volume/erogato + grafici), Configurazione (scaglioni fee, feature flag). RBAC Super/Support/Finance, audit log di ogni accesso.
- Nota: flag `isapproved` esercente = etichetta interna di verifica, **senza effetti** (nessun gate) — scelta confermata da Stefano 2026-06-06.

## Architettura (sintesi)
- **App** Blazor WebAssembly (:8002) — esercenti e clienti.
- **Server** .NET 8 API (:8001) — logica, Stripe, PostgREST/Supabase.
- **Vetrina** Blazor Server (:6010/CAT) — sito pubblico + pagine negozio.
- DB Postgres (Supabase self-hosted), schema `puntify`.

## 10 claim "cos'è Puntify" (per esterni / meta tag)
1. Puntify è la piattaforma all-in-one per negozi e PMI italiane: fidelizzazione a punti, prenotazioni online, menu e pagamenti in un solo abbonamento.
2. Più clienti, più prenotazioni, meno tempo perso: Puntify unisce carta fedeltà digitale, agenda online e assistente AI per la tua attività.
3. Tutta la tua attività in un'app: punti fedeltà, prenotazioni, menu e ordini, pagamenti e un assistente AI che risponde al telefono per te.
4. Puntify trasforma i clienti occasionali in clienti abituali: raccolta punti digitale, premi e prenotazioni online, senza tessere né app multiple.
5. Il sistema di fidelizzazione e prenotazioni pensato per le PMI italiane: semplice, completo, da 7,99€ al mese.
6. Una sola piattaforma per fidelizzare, far prenotare e incassare online — con Nemi, l'assistente AI che gestisce le chiamate h24.
7. Puntify: la fidelity card digitale dei tuoi clienti e l'agenda online della tua attività, nello stesso posto.
8. Dalla carta fedeltà alla prenotazione al pagamento: Puntify digitalizza il rapporto tra negozi e clienti, in modo semplice.
9. Per i clienti, un solo QR per tutte le carte fedeltà. Per i negozi, punti, prenotazioni e AI in un'unica piattaforma.
10. Puntify è il modo più semplice per far tornare i clienti: programma a punti, prenotazioni online e assistente AI, tutto incluso.
