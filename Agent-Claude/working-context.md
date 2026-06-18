# Working Context — Claude

## Sessione 2026-06-17/18 — Puntify Vetrina + Sales machine

### Stato (mattina 2026-06-18)
Macchina marketing/sales avviata + redesign Vetrina in corso. Tutto su cat/dev, NON committato in prod (ultimo commit prod: ac9eebc del 17/6).

### FATTO
- LEAD: +120 nuovi lead automotive stanotte → CRM (CRM.xlsx Drive alfredopenbotti, id 10kEIoAT...) da 45 a **165 contatti** (65 con email, 45 Alta prio). Copertura Roma+hinterland+litorale+periferie. Riepilogo: /home/claudebot/marketing/leads_added_summary.md. Backup in /home/claudebot/marketing/backup/.
- Bozze email: 32 in /home/claudebot/marketing/outreach_drafts.{md,json}. Firma "Stefano Gitto", catalogo servizi+prezzi, no "2 mesi"/"app gratis". Bozze 1-3 approvate; alla 4. GATE: avvisare Stefano prima di OGNI invio; orario Mar-Gio 9:30-11:00; invio via Resend (sales@puntify.it).
- Case study autofficine: redesign dark editorial (Settori.razor, classi cs-*). Hero settori: chiaro premium (sec-*).
- Logo header: bianco solo su /negozi/{slug} (IsShopPage).
- Bug mobile overflow-x: risolto (html/body overflow-x hidden + footer flex-wrap + app.css ?v=20260618a).
- Font: Fraunces -> Hanken Grotesk (Stefano non gradiva serif).
- Pagina Prezzi: redesign agent (scoped pz-, una fascia scura su Nemi) — usa ancora Fraunces, da allineare al font scelto.
- Plugin Claude Code installati: frontend-design, ui-ux-pro-max.

### IN CORSO (2026-06-18 mattina)
- **Case study scale-out**: Stefano ha dato OK formato ("la 1"). Genero case study per i 62 settori rimanenti (4 già fatti: autofficine, parrucchieri, ristoranti, centri-estetici). 36 chiavi × 9 lingue (base IT `SharedResource.resx` + en,es,pt,fr,ar,hi,bn,zh; it.resx NON usato per queste chiavi → fallback su base). Workspace: /tmp/casegen/ (BRIEF.md, template.json, prefixmap.json, batches.json, merge.py). 21 agent batch da 3 settori, ognuno scrive /tmp/casegen/<Prefix>.json; poi merge.py inietta in resx + aggiorna dict CaseStudyKeyPrefix in Settori.razor. Prefisso = suffisso Settore_X + "_Case".
- **Email bozza 4**: Stefano ha approvato ("la bozza email 4 va bene"). DA GESTIRE invio (gate orario Mar-Gio 9:30-11:00, via Resend sales@puntify.it) — confermare con Stefano se inviare il batch ora.

### IN ATTESA DI STEFANO
1. Scelta font (Hanken vs Schibsted Grotesk vs Sora).
2. Review redesign Prezzi.
3. Case study dettagliati su TUTTI i settori (come officine) — da impostare, deleghe ad agent.
4. Review email (alla 4/32).
5. Commit + deploy prod di tutte le modifiche dev.

### NOTE
- gog: GOG_KEYRING_PASSWORD in ~/.bashrc; account alfredopenbotti@gmail.com.
- Test grafici: Playwright headless in /tmp/anchortest/ (chromium in ~/.cache/ms-playwright).
- Vedi memoria: project_puntify_sales_machine, feedback_delegate_dev_to_agents.
