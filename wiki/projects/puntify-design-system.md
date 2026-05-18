# Puntify · Design System (cfg-*)

Sistema visivo condiviso per tutte le pagine `Puntify.App` (Blazor WASM). Ispirato a Stripe Dashboard, Linear, Notion, Vercel, Apple settings. Obiettivo: SaaS moderno, minimale, premium. Niente "enterprise legacy".

## Asset
- **CSS**: `Puntify.App/wwwroot/css/config.css` (importato da `index.html` insieme a `app.css`/`booking.css`).
- **Prefisso classi**: `cfg-*`.
- **Pagina di riferimento (gold standard)**: `Pages/Merchant/ShopEdit.razor` (route `/merchant/shop/{id}/edit`).
- **Pagine già migrate** (2026-05-18): ShopEdit, AddShop, BookingSettings, BookingOptions, ShopServices, OperatorDetail, MerchantAccount, ClientAccount, MerchantRegistration, BookingClosures.

## Linee guida generali
- Pulizia estrema, niente rumore visivo, gerarchia chiara.
- Mobile-first ma ottimizzato desktop (max-width container ~1160px).
- Mantenere struttura logica della pagina; redesign è solo visivo + UX.
- **NO** gradienti forti, ombre pesanti, bordi marcati, uppercase aggressivo, input alti legacy.

## Palette (CSS vars in `.cfg-page`)
| Var | Valore | Uso |
|---|---|---|
| `--cfg-bg` | `#F5F5F7` | sfondo pagina |
| `--cfg-surface` | `#FFFFFF` | card |
| `--cfg-text` | `#111111` | testo principale |
| `--cfg-text-muted` | `#6B7280` | testo secondario |
| `--cfg-border` | `rgba(0,0,0,0.06)` | bordi standard |
| `--cfg-border-strong` | `rgba(0,0,0,0.12)` | bordi hover |
| `--cfg-focus` | `#111111` | focus ring (graphite) |
| `--cfg-primary` | `#B80000` | brand Puntify red — CTA principale |
| `--cfg-primary-hover` | `#9A0000` | hover CTA |
| `--cfg-danger` | `#B5453F` | errori non saturi |
| `--cfg-success` | `#1F7A4D` | successi |
| `--cfg-input-bg` | `#FAFAFA` | sfondo input |

## Tipografia
| Elemento | Size | Weight | Note |
|---|---|---|---|
| Titolo pagina (`.cfg-title`) | 32px (26px mobile) | 600 | letter-spacing -0.02em |
| Titolo card (`.cfg-card-title`) | 18px | 600 | letter-spacing -0.01em |
| Sottotitolo card (`.cfg-card-sub`) | 13px | 400 | colore muted |
| Label campo (`.cfg-label`) | 12px | 500 | letter-spacing 0.02em, muted |
| Helper (`.cfg-help`) | 12px | 400 | muted, line-height 1.5 |
| Input | 14px | 400 | |

## Spacing
- Micro 8px · standard 16px · tra gruppi 24/32px · tra macro-sezioni 32-48px.
- Container centrale `max-width: 1160px`, padding orizzontale `24px` (desktop) / `16px` (mobile).
- `padding-bottom: 96px` su `.cfg-page` per non coprire contenuto con sticky bar.

## Radius
- Card: `16px` (`--cfg-radius-card`).
- Input/CTA/segmented item: `12px` (`--cfg-radius-input`).
- Pill/badge: `999px`.

## Shadow
- Card: `0 1px 2px rgba(0,0,0,.04)` (`--cfg-shadow-card`).
- Sticky bar: `0 -1px 2px rgba(0,0,0,.04)`.
- Focus ring: `0 0 0 3px rgba(0,0,0,.08)` su input/composite.
- Selection card selected: `0 0 0 3px rgba(0,0,0,.05), 0 1px 2px rgba(0,0,0,.04)`.

## Componenti principali
### Pagina
```html
<div class="cfg-page">
  <header class="cfg-header">
    <button class="cfg-back" @onclick="GoBack">…</button>
    <h1 class="cfg-title">Titolo</h1>
    <!-- opzionale CTA destra: .cfg-preview / .cfg-btn-outline -->
  </header>
  <main class="cfg-main">
    <section class="cfg-card">…</section>
  </main>
  <div class="cfg-actionbar">…sticky CTA…</div>
</div>
```

### Card
```html
<section class="cfg-card">
  <div class="cfg-card-header">
    <h2 class="cfg-card-title">Titolo</h2>
    <p class="cfg-card-sub">Descrizione opzionale</p>
  </div>
  <div class="cfg-card-body">
    <!-- campi -->
  </div>
</section>
```

### Campo / Input
```html
<div class="cfg-field">
  <label class="cfg-label">Etichetta</label>
  <input class="cfg-input" placeholder="…" />
  <span class="cfg-help">Helper opzionale</span>
</div>
```
Varianti: `.cfg-textarea`, `.cfg-select` (icona chevron in `background-image`). Composite con prefix/suffix: vedi `.cfg-ratio*`.

### Grid 2 / 3 colonne
`.cfg-grid-2` (1fr 1fr) o `.cfg-grid-3`. Mobile (<760px) → 1 colonna.

### Selection cards (radio "premium")
```html
<div class="cfg-mode-grid">
  <button class="cfg-mode-card @(selected ? "is-selected" : "")">
    <span class="cfg-mode-icon">…svg…</span>
    <span class="cfg-mode-body">
      <span class="cfg-mode-title">…</span>
      <span class="cfg-mode-desc">…</span>
      <span class="cfg-mode-example">Es. …</span>
    </span>
    <span class="cfg-mode-check">…svg check…</span>
  </button>
</div>
```
Selected state: bordo nero soft + ring `rgba(0,0,0,.05)` + sfondo `#FAFAFA`. **Non deve sembrare un errore validation**.

### Segmented control (toggle URL/file ecc.)
```html
<div class="cfg-segmented">
  <button class="is-active">URL</button>
  <button>Carica file</button>
</div>
```

### Pulsanti
| Classe | Stile | Uso |
|---|---|---|
| `.cfg-btn .cfg-btn-primary` | red Puntify (#B80000) bianco | salva/conferma |
| `.cfg-btn .cfg-btn-ghost` | trasparente | annulla |
| `.cfg-btn .cfg-btn-outline` | superficie + bordo soft | secondario neutro |
| `.cfg-btn .cfg-btn-danger` | rosso non saturo outline | delete |
| `.cfg-btn-small` | h 34px, font 12.5px | inline azioni |

Altezza standard 42px, radius 12px, font 600.

### Sticky action bar
```html
<div class="cfg-actionbar">
  <div class="cfg-actionbar-inner">
    <button class="cfg-btn cfg-btn-ghost">Annulla</button>
    <button class="cfg-btn cfg-btn-primary">Salva modifiche</button>
  </div>
</div>
```
`position: fixed; bottom: 0`, `backdrop-filter: blur(14px) saturate(180%)`. Su mobile i btn diventano `flex: 1` (stretch).

### Alert
```html
<div class="cfg-alert cfg-alert-error">…</div>
<div class="cfg-alert cfg-alert-success">…</div>
```

### Row list (lista compatta)
```html
<div class="cfg-row-list">
  <div class="cfg-row">
    <div class="cfg-row-main">
      <div class="cfg-row-title">…</div>
      <div class="cfg-row-meta">…</div>
    </div>
    <div class="cfg-row-actions">…btn small…</div>
  </div>
</div>
```

### Badges
`.cfg-badge .cfg-badge-on` (verde), `.cfg-badge-off` (grigio), `.cfg-badge-primary` (red tint).

### Media preview
`.cfg-media-preview` con `.cfg-media-logo` / `.cfg-media-cover` per anteprime immagini.

### Loading / Empty
- `.cfg-loading` con `.spinner` (definito in `app.css`).
- `.cfg-empty` + `.cfg-empty-icon` + `.cfg-empty-title` + `.cfg-empty-desc`.

## Micro-interazioni
- Transition standard `160ms ease` su border/background/box-shadow/transform.
- Focus-visible: outline 2px graphite + offset 2px.
- Hover card/btn: bordo `--cfg-border-strong` + sfondo `#FBFBFB`.

## Responsive (`@media (max-width: 760px)`)
- Header: titolo full-row, back + preview sopra.
- `.cfg-main` padding 12/16px, gap 20px.
- Grid 2/3 → 1 colonna.
- Selection grid → stack.
- Action bar btn → flex 1 (stretch).

## Regole obbligatorie per nuove pagine / refactor
1. **Wrappare pagina in `<div class="cfg-page">`**. Niente sfondo custom.
2. **Header sempre `<header class="cfg-header">`** con back + titolo + (opz.) CTA destra.
3. **Contenuto in `<main class="cfg-main">`** con sezioni `<section class="cfg-card">`.
4. **Form**: usare `.cfg-field`/`.cfg-label`/`.cfg-input`. Mai `<input>` raw o stili inline.
5. **CTA salva/annulla in sticky `.cfg-actionbar`**. Niente bottoni inline sparsi.
6. **Selezioni multiple/booleane** rilevanti → `.cfg-mode-grid` (selection cards), non checkbox custom.
7. **Niente nuove regole CSS in `<style>` inline o `*.razor.css`** se replicano pattern cfg-*. Estendere `config.css` solo se manca un primitive condiviso.
8. **Su modifica `config.css`** dopo rebuild: hash WASM cambia → service worker cacha vecchi asset. Smoke test post-edit obbligatorio (vedi [[smoke-test-after-edits]]).

## Quando NON si applica
- Pagine pubbliche/marketing → vivono in `Puntify.Vetrina`, hanno design proprio.
- Wizard/flow auth (Login, Register, RoleSelection, AuthCallback, Consent) → da valutare: redesign sì, ma potrebbero meritare layout dedicato (no header back, no actionbar sticky).
- `Index.razor` (loader/redirect) → niente UI, lasciare.

## Riferimenti visuali esterni
- Stripe Dashboard
- Linear
- Notion
- Vercel Dashboard
- Apple Settings (iOS/macOS moderno)

## Link correlati
- [[wiki/projects/puntify|Puntify]]
- [[wiki/projects/cat-stack|CAT Stack]]
- [[smoke-test-after-edits]] (memoria) — verifica HTTP dopo modifiche
