# Working context

## Ora (2026-06-22)
Piracity-web (vetrina): RIPROGETTAZIONE homepage in corso. Stefano vuole pivot da tema dark/pirata a LANDING LUMINOSA familiare (stile Apple pulizia + Disney calore), per famiglie/bambini/amici/compleanni/turisti.

### Decisioni concordate con Stefano
1. FOTO: non posso generarle; le passa lui man mano. Costruisco con placeholder eleganti + manifest prompt (docs/image-prompts.md). Slot in /public/assets/photos/ (hero.jpg, step-1..4.jpg, family, audience, experience, tech, events, adults, treasure, finale).
2. TEMA: home + Navbar + Footer luminosi. Pagine legali/blog restano dark → secondo giro.

### Stato build
- Subagent in background (agentId a4913af6...) costruisce: 14 sezioni nuove (components/home/landing/), design system luminoso (tailwind: ink/coral/teal/sand + font Fraunces+Plus Jakarta), Figure.tsx placeholder, navbar/footer chiari, i18n 5 lingue, verifica tsc/lint/curl :6010.
- Tema chiaro ISOLATO (non tocca body globals.css; wrapper bg-sand text-ink sulla home) per non rompere le pagine dark.

## Aperto / prossimi passi
- Attendere subagent → review output + screenshot :6010 → report a Stefano da rivedere prima di pubblicare.
- Consegnare a Stefano lista slot foto + cartella per caricamento progressivo.

## Contesto precedente (Puntify, in pausa)
- Outreach Milano 26 email inviate; decisione CTA demo template-wide pendente.
- Outreach prossime zone: Monza 22, Siena 19, Brescia 13, Verona 12, Torino 10.
