# Working context

## Ora (2026-06-22)
Piracity-web (vetrina): RIPROGETTAZIONE homepage in corso. Stefano vuole pivot da tema dark/pirata a LANDING LUMINOSA familiare (stile Apple pulizia + Disney calore), per famiglie/bambini/amici/compleanni/turisti.

### Decisioni concordate con Stefano
1. FOTO: non posso generarle; le passa lui man mano. Costruisco con placeholder eleganti + manifest prompt (docs/image-prompts.md). Slot in /public/assets/photos/ (hero.jpg, step-1..4.jpg, family, audience, experience, tech, events, adults, treasure, finale).
2. TEMA: home + Navbar + Footer luminosi. Pagine legali/blog restano dark → secondo giro.

### Stato build — COMPLETATO (in attesa review Stefano)
- 14 sezioni nuove in components/home/landing/, design system luminoso (tailwind: ink/coral/teal/sand + font Fraunces+Plus Jakarta), Figure.tsx placeholder foto, Navbar/Footer chiari, i18n 5 lingue. tsc+lint puliti, live su dev.
- Tema chiaro ISOLATO (non tocca body globals.css; wrapper bg-sand text-ink sulla home) → pagine dark intatte.
- GOTCHA screenshot: le animazioni framer whileInView (Reveal/Stagger in primitives.tsx) NON scattano in screenshot headless full-page → pagina appare vuota. Per gli utenti reali funziona. Per screenshot: bypassare temp `if (reduce)`→`if(reduce||true)` poi ripristinare. Screenshot in /tmp/piracity-shots/.
- APP URL collegato: CTA "Inizia l'avventura" (Hero+FinalCta) e "Salpa gratis" (Navbar) → https://app-cat.piracity.app/ (target _blank). CtaPrimary/Secondary in primitives.tsx ora gestiscono href esterni (http→<a>).

## Aperto / prossimi passi
- Stefano rivede live: http://piracity-dev-web.duckdns.org/ → applico fix.
- Foto: Stefano le carica in /public/assets/photos/ (hero, step-1..4, family, experience, tech, events, adults, treasure, finale).jpg. Prompt in docs/image-prompts.md.
- Da confermare: footer Missioni→#per-chi / Contatti→/partner; CTA "Organizza una missione" + "Vivi la tua prima missione" interne o all'app.
- NON ancora committato/pubblicato.

## Contesto precedente (Puntify, in pausa)
- Outreach Milano 26 email inviate; decisione CTA demo template-wide pendente.
- Outreach prossime zone: Monza 22, Siena 19, Brescia 13, Verona 12, Torino 10.
