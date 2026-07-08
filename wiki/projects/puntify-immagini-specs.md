# Puntify · Specifiche immagini (cover, logo)

> Dimensioni ideali immagini per le pagine Puntify. Derivate dal render reale (Tailwind + object-fit).
> Upload: max **2 MB**, formati **jpeg/png/webp/heic** (NO svg, bloccato per XSS). Compilato 2026-07-08.

## Cover pagina pubblica negozio (`/negozi/{slug}`, NegozioDetail.razor)
- Render: banner a tutta larghezza, `h-64 md:h-80` = **256px mobile / 320px desktop**, `object-cover` (riempie e RITAGLIA, tiene il centro). Larghezza = viewport (fino a ~1920px+), quindi rapporto effettivo varia molto (≈1.5:1 mobile → 6:1 desktop wide).
- **Ideale: 1920 × 640 px (3:1), orizzontale.** Minimo 1600 × 500.
- Soggetto/testo IMPORTANTE al CENTRO con margini di sicurezza (si taglia sopra/sotto su schermi larghi, ai lati su mobile).
- Peso consigliato 300–800 KB (< 2MB limite). JPG/WebP.
- OG social (condivisione link) usa CoverPhoto: standard OG = 1200×630; per la pagina resta meglio 1920×640.

## Logo negozio (stessa pagina + app)
- Render: `w-24 h-24 md:w-32 md:h-32 rounded-2xl object-cover` = **96px mobile / 128px desktop**, QUADRATO ritagliato.
- **Ideale: quadrato 512 × 512 px** (retina), soggetto centrato. PNG con trasparenza o JPG/WebP.

## Note tecniche
- Upload immagini: `SupabaseService.Upload*ImageAsync` → cap 2MB, content-type immagini. Storage env-agnostic (client manda chiave logica, server risolve bucket + URL pubblico) dal commit ae4c9b6.

Cross-link: [[puntify]] · [[puntify-vetrina-headcontent-meta]]
