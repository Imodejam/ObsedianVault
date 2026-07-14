# Vault Index

## Progetti
- [[wiki/projects/concilium|Concilium]] — Piattaforma di deliberazione multi-LLM con Synthesizer (Praeses Concilii). Repo: github.com/Imodejam/Concilium. _Priorità attuale, MVP live._
- [[wiki/projects/puntify|Puntify]] — Fidelity card digitale per esercenti (primo target Roma). Ambiente CAT live 2026-05-16.
  - [[wiki/projects/puntify-design-system|Puntify · Design System (cfg-*)]] — sistema visivo SaaS condiviso (Stripe/Linear/Notion-style), obbligatorio per nuove pagine
  - [[wiki/projects/puntify-nomi-alternativi|Puntify · Nomi alternativi]] — lista 35 nomi (top 10 raccomandati) dopo diffida Spotify
  - [[wiki/projects/puntify-lista-esercenti-trastevere-testaccio|Puntify · Lista esercenti Trastevere+Testaccio]] — 20 target prima zona Roma
  - [[wiki/projects/puntify-template-approccio-esercenti|Puntify · Template approccio esercenti]] — script vendita iniziale
  - [[wiki/projects/puntify-costi-srls|Puntify · Costi SRLS e Break-even]] — costi annui SRLS (~6,7–8,3k€/anno, dominati da INPS) e break-even ~56–70 esercenti/mese
  - [[wiki/projects/puntify-dashboard-esercente|Puntify · Dashboard Esercente (Panoramica)]] — dashboard analitica full-screen stile Stripe su dati veri (incassi/ordini/prenotazioni/coda/recensioni/fedeltà); estende Insights.razor; decisioni aperte
  - [[wiki/projects/puntify-nemi-voce-vapi|Puntify · Nemi Voce via Vapi]] — integrazione webhook Vapi (end-of-call-report) per tracciare chiamate + scalare minuti dal negozio (shop_nemi_credits); proposta architettura inviata, attende ok Stefano
  - [[wiki/projects/puntify-clienti-architettura|Puntify · Architettura Clienti (identità+profilo segregato)]] — APPROVATA: identità condivisa (telefono, dedup) + profilo cliente SEGREGATO per esercente/PV (no contaminazione cross-esercente, GDPR); scope shop-vs-account configurabile
  - [[wiki/projects/elimina-code|Puntify · Modulo Elimina Code]] — gestione code/ticketing (QR loco+remoto+totem+operatori+display). PIANIFICAZIONE: analisi integrazione + piano a fasi/gate, in attesa GATE 0 (Stefano 2026-06-30)
  - [[wiki/projects/puntify-android-app|Puntify · App Android (WebView + stampante USB)]] — app nativa contenitore per app-cat, ponte `window.PuntifyNative` (printRaw ESC/POS base64), stampa USB confermata. Pezzo lato web da fare: generare ESC/POS comande+biglietti totem
- [[wiki/projects/piracity|Piracity]] — AI-powered urban treasure hunt PWA. _Rinominato da Piratopoly il 2026-05-14. Ambiente CAT live 2026-05-17. Lavoro attivo (binocolo AR, pricing V1, restyle vetrina)._
  - [[wiki/projects/piracity-pricing-strategy|Piracity · Strategia prezzi V1]] — posizionamento, 4 SKU mappa + 2 piani Pass, Piastre, decisioni e gap codice/vetrina
  - [[wiki/projects/piracity-pricing-v1-execution|Piracity · Pricing V1 — Piano di Esecuzione]] — gap analysis vs GDD 2026-05-08 e fasi (Catalogo / Pass / EL / Voucher / Stagionalità)
  - [[wiki/projects/piracity-web|Piracity Web]] — sito vetrina marketing Next.js 14 (5 lingue). Sanity rimosso 2026-05-09: ora legge dal Supabase della PWA (mappe `is_official` published).
- [[wiki/projects/openclaw-setup|OpenClaw Setup]] — Ottimizzazione configurazione OpenClaw, agenti, monitoraggio
- [[wiki/projects/clawroom|ClawRoom]] — Dashboard operativa Blazor per team AI (Kanban, costi, modelli)

## Infrastruttura
- [[wiki/projects/cat-stack|CAT Stack]] — Ambiente collaudo condiviso su pro-open `/opt/ops/`: ops-postgres multi-DB (puntify_cat + piracity_cat), GoTrue+PostgREST per app, Caddy reverse-proxy 10 domini. Supabase OSS legacy dismesso 2026-05-17.

## Persone
- [[wiki/people/stefano|Stefano Gitto]] — Owner, Software Architect
- [[wiki/people/team|Team AI]] — Struttura team: Alfred, Carlo, Luca, Massimo, Lidia

## Decisioni
- [[wiki/decisions/standard-operating-procedures|SOP Agenti]] — Standard obbligatori per documentazione, Kanban e Vault
- [[wiki/decisions/agent-writing-standards|Agent Writing Standards]] — (Redirect a SOP)
- [[wiki/decisions/telegram-nemi-multi-pv-topics|Puntify Telegram-Nemi multi-PV via Forum Topics]] — 2026-05-25, un gruppo per account, un topic per PV
- [[wiki/decisions/puntify-agenda-risorse|Puntify Agenda risorse/operatori — analisi]] — 2026-06-03, gap agenda (pagamento, durata, filtro tipo, planning, overlap) + proposta a livelli


## Concetti
_(nessun concetto ancora)_
- [[projects/puntify-admin]] — Area Admin di sistema Puntify (pianificazione, F1)

- [[projects/puntify-funzionalita|Puntify — Resoconto funzionalità]] — mappa completa funzioni (esercente/cliente/vetrina/admin) + 10 claim esterni
- [[piracity-tappa-template]] — formato obbligatorio per creare/visualizzare una tappa Piracity (tono pirata, struttura a sezioni fisse)
- [[piracity-map-story-prompt]] — system prompt per le storie delle mappe Piracity (Vetrina + Apertura mappa, stile Disney, nomi realistici, luoghi reali). Da applicare a mappe esistenti e future
- [[puntify-clienti-data-model]] — modello dati clienti Puntify: cosa è condiviso tra esercenti (account globale) vs isolato per-shop; RLS + RPC
- [Nemi Voce economics (INTERNO)](decisions/nemi-voce-economics-INTERNO.md) — modello prezzi + margini/COGS, NON pubblicare
- [Puntify — Catalogo servizi](projects/puntify-servizi.md) — elenco completo servizi erogati (da feature flag reali), base per sales/comunicazione
- [[puntify-cassa-fiscale]] — roadmap fiscalizzazione Puntify (cassa/corrispettivi telematici/RT) da benchmark Ubify + AdE; gap P0/P1/P2
- [[puntify-social-meta-setup]] — guida creazione app Meta (Instagram+Facebook) per SocialStudio: passi, redirect URI, credenziali da fornire
