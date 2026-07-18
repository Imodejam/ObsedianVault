# Working context — 2026-07-16 ~23:01 Roma (fine giornata)

## Commit oggi su master (Imodejam/Puntify) — DA DEPLOYARE IN PROD
Server: 0f06086 (retry MiniMax+S3, guard admin_activity_log, verbosita upload, popup elimina), 6ca82ee (Expect:100-Continue off upload), 662fa7c (Nemi formati/tipo food-drink), 87a1f50 (Nemi allergeni obbligatori), 3506757 (Nemi no dati tecnici), 85f6458 (Nemi autonomia multi-step), 5cb423f (Nemi grounding+onesta risultati)
Vetrina: 3315641 (menu sotto-sezioni scroll+sticky), 6a06f91 (kiosk McDonald + terminologia proposte)
Su CAT tutto attivo (hot-reload).

## Aperti
1. UPLOAD foto sezione PROD: reset connessione verso storage (bucket dishimages-prod). Fix Expect-100 pushato (6ca82ee) ma prod e Caddy come CAT -> sospetto request_body max_size Caddy prod. Stefano stava verificando Caddy. Da confermare dopo deploy: se persiste, alzare max_size (~30MB) sul site storage prod.
2. Deploy prod (Server+Vetrina) lato Stefano.
3. Kiosk: colonna sinistra su DESKTOP (non kiosk) ancora un po' vuota - non sollevato di nuovo, eventuale follow-up.

## Automazione attiva
- Cron social 1430aba3: 13:37 UTC = 15:37 Roma -> genera bozza del giorno dopo, invia a Stefano (505161324), su OK publish.py Buffer. SCADE 7gg (2026-07-23) -> RI-ARMARE.
- Post 17/07 (raccolta_punti) gia schedulato Buffer IG+LI+FB per 2026-07-17 12:30 Roma.

## Note skin social
/home/progetti/puntify-social/skin/ (topics, image, storage files.puntify.it, buffer). create_post: customScheduled+dueAt per data specifica; metadata per-servizio (IG type+shouldShareToFeed, FB type). Buffer channels: IG 69e0a49f031bfa423c0c9bb5, LI 69b986107be9f8b17166990a, FB 69b9bf437be9f8b17167d13f.

## [Aggiornamento 2026-07-17 mattina]
### Da committare (CAT, non ancora committato) — attendo "commit" di Stefano
- Descrizione SEZIONE (ieri sera): migrazione add_section_description.sql + modello + tool Nemi + editor + display cliente.
- 5 fix UI stamattina: (1) MenuEditor tab default Prodotti se menu impostato; (2) DishEditor tasto formato piccolo+contrasto; (3) DishEditor foto->lightbox; (4) MenuEditor search bar distanziata; (5) TablesPlanimetry popup risorsa piu largo tablet/desktop.
### In discussione (design, non iniziato)
- Priorita code: attendo scelta Stefano (% globale peso vs % per coda). Poi: migrazione priority + QueueEdit campo + CallNext "Tutte" pesato anti-fame + descrizioni vetrina tutte lingue.
### Ancora aperto
- Upload foto prod: esito Caddy (request_body max_size).
- Deploy prod: Server (7 commit) + Vetrina (2 commit) gia pushati; + tutto il non-committato sopra quando Stefano dice.


## [2026-07-17 15:37] Social skin
- Bozza 18/07 (menu_digitale) inviata a Stefano per approvazione. Su OK: publish.py Buffer (IG/LI/FB) best-time 18/07 + append topic-history. Post 17/07 (raccolta_punti) gia schedulato.
---

## Checkpoint kiosk cards
- Richiesta Stefano: nel kiosk mostrare i prodotti come CARD (foto grande, nome, prezzo, +) stile McDonald's con animazioni. Solo kiosk; mobile/desktop invariati.
- Delegato a subagent: modifica Puntify.Vetrina/Pages/MerchantMenuPreview.razor + wwwroot/css/menu-public.css nella media query kiosk (min-width:1000px & min-height:1400px). Verifica headless 1080x1920 su Pepto.
- NON committare finché non approvato da Stefano.
- Pendenti: CEO Dashboard /admin/dashboard uncommitted (attende review Stefano); conferma prod NOTIFY pgrst reload descrizione sezioni; OK Haiku 4.5 su Nemi.

## Checkpoint kiosk (17/07)
- FATTO (uncommitted, live su CAT hot-reload, atteso OK Stefano):
  - Card prodotti animate stile McDonald's (kiosk-only)
  - ?kiosk=1 forza la vista kiosk su qualsiasi schermo (gate class .mp-kioskon in MenuLayout.razor server-side + JS matchMedia; media query rimossa, single-source). CSS ?v=20260717d
  - Primo tile rail = logo negozio (_shop.Logo) invece di "Tutto"; fallback "Tutto" se no logo
- File: Puntify.Vetrina/Pages/MerchantMenuPreview.razor, Shared/MenuLayout.razor, wwwroot/css/menu-public.css
- Screenshot in /home/progetti/puntify-social/scratch/kiosk_force/ e /kiosk_cards/

## Checkpoint 17/07 (sera) — batch kiosk+picker DONE (uncommitted, atteso OK)
- Kiosk: ?kiosk=1 force + persist sessionStorage (fix "alcune pagine desktop navigando"); logo negozio nel primo tile (no ombra); card larghezza uniforme (grid width:100% su .mp-dishes-list-rows). CSS ?v=20260717e. File: MerchantMenuPreview.razor, Shared/MenuLayout.razor, wwwroot/css/menu-public.css
- Photo picker "Scegli foto": nuovo gruppo "Dal tuo menu" (foto sezioni+piatti del negozio, attinenti-first) sopra il catalogo condiviso. File: PhotoPickerModal.razor (+param RecentPhotos/PhotoSuggestion), MenuEditor.razor (BuildMenuPhotos), DishEditor.razor (+MenuPhotos), config.css (.pp-group-title), 2 resx keys x10 lingue. Build App pulita.
- Prossimo: al via libera di Stefano, commit di TUTTO (kiosk+picker) in Puntify. NIENTE attribution Claude nei commit.

## Social skin 19/07 (SCHEDULATO - fatto)
- Bozza: posts/2026-07-19_ordini_online/ (image.jpg + meta.json status=pending_approval)
- Topic ordini_online; copy "telefono senza fili"; hashtag 6
- Inviata a Stefano (Telegram 6670/6671). ATTESA: Approva -> publish.py --folder posts/2026-07-19_ordini_online (Buffer IG/LI/FB best time) + aggiorna topic-history.json + meta status. NON pubblicare senza OK.

- FATTO: approvato Stefano + schedulato Buffer 19/07 18:30 Roma (IG/LI/FB). status=scheduled.
