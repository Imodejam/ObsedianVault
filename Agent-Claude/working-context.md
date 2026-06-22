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

### Foto INTEGRATE (2026-06-22)
- Stefano ha inviato 12 foto numerate (1-12 = numerazione dei suoi 12 prompt) + alternative con nomi. Mappate per aspect ratio (16:9/1:1/3:2 confermano la convenzione) e salvate in public/assets/photos/ come: hero, whatis(=Cos'è 3:2), step-1..4, family, tech, audience, events, adults, finale (.png).
- Cablati i src in tutte le sezioni Figure. AGGIUNTA foto a Cos'è (WhatIsIt) e Per chi è (Audience) che prima erano senza. next/image le ottimizza (servite via /_next/image, 200 ok).
- Step "Come si gioca" RINOMINATI digitali in 5 lingue: Segui la bussola digitale / Leggi la pergamena digitale / Completa la missione (+caption allineate a smartphone).
- SENZA foto (placeholder residuo): Experience (timeline "Ogni missione è una storia", 3:2) e Treasure ("Alla fine c'è un tesoro", 16:9). In attesa decisione Stefano (usare alternative o 2 foto dedicate).
- Alternative extra inviate (famiglia/trasformazione/Amici/papà e ragazzi/famiglia colosseo/2 uuid) NON usate, restano nell'inbox telegram.

### Riposizionamento INCLUSIVO — COMPLETATO (2026-06-22)
- Copy di tutte le sezioni riscritto inclusivo (single/coppie/amici/famiglie/turisti/gruppi) in 5 lingue, parità 131 chiavi, tsc+lint ok, grep frasi vietate = 0. Live su cat.piracity.app.
- Struttura: WhatIsIt 4 card (+transform), Audience 6 target (solo/couple/friends/family/travel/events), Events 5 card. Family→"trasformazione", Adults→"Non serve essere bambini…". Step "Leggi la pergamena"/"Completa l'avventura".

## Aperto / prossimi passi
- Stefano rivede live: https://cat.piracity.app/ → applico fix.
- ATTESE foto da Stefano: HERO gruppo misto + "trasformazione" ciurma epica + 6 foto carosello "Per ogni tipo di ciurma" (audience-solo/couple/friends/family/travel/events) + FINALE (no famiglia) + timeline + tesoro.
- Da confermare: footer Missioni→#per-chi / Contatti→/partner; CTA "Organizza una missione" + "Vivi la tua prima missione" interne o all'app.
- Possibile ottimizzazione: convertire i PNG (~2MB) in webp per perf.
- NON ancora committato/pubblicato.

## Contesto precedente (Puntify, in pausa)
- Outreach Milano 26 email inviate; decisione CTA demo template-wide pendente.
- Outreach prossime zone: Monza 22, Siena 19, Brescia 13, Verona 12, Torino 10.
