# Vault Index

## Progetti
- [[wiki/projects/concilium|Concilium]] — Piattaforma di deliberazione multi-LLM con Synthesizer (Praeses Concilii). Repo: github.com/Imodejam/Concilium. _Priorità attuale, MVP live._
- [[wiki/projects/puntify|Puntify]] — Fidelity card digitale per esercenti (primo target Roma). Ambiente CAT live 2026-05-16.
  - [[wiki/projects/puntify-design-system|Puntify · Design System (cfg-*)]] — sistema visivo SaaS condiviso (Stripe/Linear/Notion-style), obbligatorio per nuove pagine
  - [[wiki/projects/puntify-nomi-alternativi|Puntify · Nomi alternativi]] — lista 35 nomi (top 10 raccomandati) dopo diffida Spotify
  - [[wiki/projects/puntify-lista-esercenti-trastevere-testaccio|Puntify · Lista esercenti Trastevere+Testaccio]] — 20 target prima zona Roma
  - [[wiki/projects/puntify-template-approccio-esercenti|Puntify · Template approccio esercenti]] — script vendita iniziale
  - [[wiki/projects/puntify-costi-srls|Puntify · Costi SRLS e Break-even]] — costi annui SRLS (~6,7–8,3k€/anno, dominati da INPS) e break-even ~56–70 esercenti/mese
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
