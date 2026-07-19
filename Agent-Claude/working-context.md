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

## Batch uncommitted (18/07 sera) - da committare + deploy prod
1. Notifica Telegram prenotazione (PublicBookingController UserId)
2. Orario/2-giorni tavolo (BookingAgenda+ClientDetail+BookingModels IsMultiDay)
3. Popup allargati (config.css)
4. Logo book cerchio (booking.css+Book.razor)
5. Migration 20260717_photo_source_allow_catalog_url.sql
6. Nemi pause fix (NemiChatService+PauseAndAskTool.cs+Program.cs DI+prompt)
7. Menu disponibilita fuso+cavallo-mezzanotte (MenuController.GetActive)
+ CEO Dashboard gia committato (d17bedd)
Prod deploy: workflow_dispatch manuale Stefano + migration (admin_dashboard, photo_source, add_section_description con NOTIFY pgrst) + snippet Caddy no-cache su app.puntify.it

## Audit Nemi (18/07 sera, in corso)
- Fase 1 audit read-only in corso (subagent): mappa funzionalita + falle su NemiChatService/Tools/Voice-Vapi/Telegram/ResumeService/KB/AssistantAi.razor/modelli
- Fase 2: report a Stefano con priorita. Fase 3: fix + test (regole: capire richiesta, 2+ test lateral, ottimizzare, commenti/pattern)
- Contesto falle note: pausa multi-step (fixata oggi, verificare buchi), "nuovo menu" reinterpretato, tz wall-clock bookings, PGRST204 JsonPropertyName

## Nemi audit: fasi 1-3 done (18/07 notte)
- Audit 20 falle -> fix critiche+alte implementate e testate (45/45). Live CAT, UNCOMMITTED (batch grosso ora: kiosk gia in master; da committare: telegram booking fix, tz booking fix, popup, logo book, migration foto, menu tz/cavallo-mezzanotte, Nemi pause fix, Nemi audit fixes F1-F8, UI waiting banner)
- PENDING Stefano: scelta F9 publish menu (A auto-republish se gia pubblicato / B avviso); flusso Nemi drag-drop menu (anteprima vs diretta); checklist deploy prod
- Falle rimandate (non implementate): #2 quota Telegram condivisa, #8 tenant voice webhook (verificare firma Vapi), #6 tz voice (da verificare), #15 log errori tool voce, #17 KB auto-refresh, #19 audit log, #20 rate limit

[2026-07-18] Checkpoint: implementata opzione B menu-publish gap Nemi in Puntify.Server (promemoria salva menu). Testato e deployato su CAT, NON committato.

## BLOCCO: credito Anthropic Puntify esaurito (18/07 notte)
- La chiave Anthropic in Puntify.Server/appsettings.Development.json non ha credito -> OCR menu (nuova feature + scatta cartaceo + traduzioni MenuTranslationService) tutti ko su CAT
- Atteso: Stefano ricarica credito o fornisce nuova chiave -> POI rifare test E2E drag-menu (immagine test in scratchpad test_menu.jpg, script python nel transcript)

## Revisione Prenotazioni+Code (19/07 notte) — COMPLETATA ondate critiche
- CODE: weight priority attiva (migration 20260718_queue_weight_priority.sql su CAT, da eseguire in prod) + confirmed filter operatore
- BOOKING: IDOR operatori, validazione create manuale, anti-race pre-insert, fix min-advance reschedule pubblico
- PENDING Stefano: (a) EXCLUDE constraint anti-overlap su bookings (schema change), (b) ricarica credito Anthropic (blocca OCR/drag-menu/traduzioni), (c) "committa e pusha" del batch GIGANTE, (d) checklist deploy prod
- Batch uncommitted attuale: fix tz booking all-screens, telegram booking notify, popup, logo book, migration foto, menu fasce orarie, Nemi (pausa+audit F1-F8+banner UI+reminder salva+drag-menu feature), booking fixes (IDOR/validazioni/race/min-advance), queue fixes (weight+confirmed), migration 20260718_queue_weight_priority.sql

## Revisione TOTALE app (19/07 mattina, in corso)
- Ondata 1 IN CORSO: audit Cassa/POS+ordini (a6620af) + Loyalty (a41522e)
- Ondata 2 TODO: menu editor + pagina pubblica PV + clienti/CRM + recensioni
- Ondata 3 TODO: Social Studio + Insights + admin + billing + notifiche/email/auth
- Metodo per ondata: audit -> verifica falle (scarto falsi positivi) -> fix test doppio -> report Stefano

## Revisione app - stato ondate (19/07)
- ONDATA 1 (Cassa/POS+Loyalty): COMPLETA, tutti fix testati live, UNCOMMITTED
- ONDATA 2 IN CORSO: audit pagina pubblica+recensioni (aa6659d) + CRM+menu editor (ab453f5)
- ONDATA 3 TODO: Social Studio+Insights+admin+billing+auth/notifiche
- Decisioni Stefano pendenti: Floor vs Round punti, max_redemptions premi, handler refund Stripe, EXCLUDE constraint booking, credito Anthropic, commit batch, checklist prod

## Revisione app - ondate (aggiornamento 19/07)
- ONDATA 1 (POS+Loyalty): COMPLETA
- ONDATA 2 (pagina pubblica+recensioni+CRM+menu): COMPLETA (RLS transactions fix, snapshot formats/vat, review validation)
- ONDATA 3 IN CORSO: audit Billing+Admin (acaf707) + Social Studio+Insights+trasversali (a02aac3)
- Migration accumulate per prod: queue_weight_priority, photo_source_allow_catalog_url, rls_transactions_isolation, add_section_description, add_queue_weight, admin_dashboard (+NOTIFY pgrst dove serve)
