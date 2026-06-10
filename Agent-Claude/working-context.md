# Working context · 2026-06-05 (aggiornato)

## 2026-06-05 — Puntify Area Admin /admin · FASE 1 (Fondamenta) FATTO+DEPLOY
Stefano (msg 3344) chiedeva "Fatto?" sulla F1 del piano Area Admin.
- DB già applicato sul CAT (20260605_admin_area.sql): `admin_users` + `admin_activity_log` (audit), seed `stefano.gitto@hotmail.com` = super. Verificato via docker exec.
- Server (già compilato 06:18): `AdminController` GET /api/admin/me → `AdminService.ResolveAdminAsync` valida JWT HS256 Supabase (firma+exp), risolve admin attivo, aggiorna last_login_at, logga via `LogAsync`. `AdminProfiles.CanSee` (super/support/finance → sezioni clients/merchants/payments/config). Modelli in Punto.Shared/Models/Admin/AdminModels.cs.
- App (FATTO ora): `AdminApiService` (GetMeAsync cache sessione, IsAdmin/CanSee) già in DI. NUOVO: `Pages/Admin/AdminHome.razor` (@page "/admin") = HOME sobria stile Stripe/Apple, top bar (email+pill profilo+esci), 4 card sezioni filtrate per permesso, tap → toast "in arrivo" (F2-F5 non ancora costruite), logout. NUOVO css `wwwroot/css/admin.css` (namespace .admin-*, accento indaco #635BFF, responsive) aggiunto al loader index.html.
- Tasto "Amministrazione" (solo se admin) aggiunto in Shops.razor (header) e Wallet.razor (page-header): l'email di Stefano ha ANCHE account normale → AuthStateProvider NON auto-redirige a /admin (redirige solo se account==null), quindi serviva l'ingresso manuale. _isAdmin = AdminApi.GetMeAsync()!=null in OnInitialized.
- Build App 0 err, puntify-app riavviato (WASM, serve Ctrl+F5). build-info bumpato.
- ACCESSO per Stefano: login con stefano.gitto@hotmail.com → tasto Amministrazione → /admin.
- STOP CHECKPOINT come da piano: attendo OK grafica HOME prima di F2 (Clienti) … F5 (Config).
- Memoria: [[project-puntify-admin]].

---

# Working context · 2026-06-03 (aggiornato)

## Task completati in questa sessione (post-compaction)

### Fix UI pagina prenotazione (2026-06-03 pomeriggio)
Messaggi Telegram 3085-3089:

1. **Altezze bottoni uguali nel stacked actionbar** (msg 3085)
   - CSS: `.rb-actionbar--stack > button` → aggiunti `padding-top:0; padding-bottom:0; box-sizing:border-box;`
   - Causa: `.tb-btn-outline` aveva `padding:.8rem 1rem` che espandeva l'altezza oltre i 50px.

2. **Accordion breakdown prezzi nel riepilogo** (msg 3086)
   - `ResourceBooking.razor`: aggiunto `_showBreakdown` bool; nuovi computed `ResourcesBasePrice`, `AddonLineCost()`, `EffectiveTargets`. La sezione `rb-breakdown` sostituita da `rb-breakdown-acc` (accordion toggle con chevron). Espanso mostra: base × giorni + ogni addon (icon+nome+qty+costo) + fee + totale.
   - CSS: nuovi `.rb-breakdown-acc`, `.rb-breakdown-head`, `.rb-breakdown-head-left/right`, `.rb-breakdown-body`.

3. **"Torna al locale" naviga alla pagina PV** (msg 3087)
   - `PublicBookingFlow.razor`: `OnCartDone` ora naviga a `/{lang}/m/{slug}` invece di resettare il flow.

4. **MaxAdvanceDays ombrelloni** (msg 3089)
   - Default server alzato da 30 a 90 giorni (`BookingServiceImpl.GetSettingsOrDefaultAsync`).
   - DB migration: `docs/DB Migrations/20260603_lido_booking_settings.sql` (INSERT booking_settings con max_future_days=180 per il lido). Da applicare via dbgate.
   - `booking.css?v=20260603j`, server+vetrina riavviati, live.

### Pending (2026-06-03 sera)
- **Punti fedeltà pending-24h** (msg 3185/3189): core 'account trovato→accredito' FATTO (StripeController.CreditLoyaltyOnPaidAsync). DA FARE: account non trovato → tabella pending_loyalty_points 24h + email invito + claim alla registrazione.
- **MODELLO B incassi unificati — FATTO+DEPLOY (2026-06-03 sera)**: Stefano (msg "direi il B") = transazioni = incassi (manuali o Stripe), i punti sono una conseguenza. DB: `transactions.accountid` reso NULLABLE + colonne `source`(default manual), `booking_id`, `customer_name`, `customer_email`, `description`. Transaction.cs aggiornato (AccountId nullable + campi incasso). StripeController.CreditLoyaltyOnPaidAsync ora inserisce SEMPRE una riga incasso (source=stripe, booking_id, nome/email cliente, description="Ombrellone O1 · 3 giorni · Lettino ×2" via BookingDescriptionAsync), con AccountId+punti solo se trovato account per email (loyalty link creato se manca). App: Transactions.razor con TxClientName/TxSourceLabel, badge sorgente Stripe/Manuale, descrizione, punti solo se >0, "Cliente non registrato" se AccountId null. Fix null-guard: ListCustomersTool, ShopCustomersController, Clients.razor (filtra AccountId.HasValue), config.css badge .cfg-tx-source. Server+App ricompilati 200. ⚠️ Insights.razor raggruppa per AccountId nullable → un gruppo "null" possibile (incassi anonimi); compila ma metrica clienti può contare +1 fantasma — da rifinire se serve.
- **msg 3202 "Prenotato il" — FATTO+DEPLOY**: BookingAgenda detail mostra data+ora richiesta cliente (b.CreatedAt); righe Data/Orario nascoste per le risorse.
- **msg 3203 "togliere l'orario dalla lista"** — ambiguo, chiesto a Stefano quale orario (colonna sx / solo appuntamenti / riga periodo). In attesa.
- **msg 3205 "Periodo dopo Prenotato il"** — FATTO+DEPLOY: spostato nel dettaglio agenda.
- **msg 3206 "settimana non mostra nulla"** — FATTO+DEPLOY. Causa: vista settimana = grid 7 colonne `minmax(110px,1fr)`=770px; su contenitore stretto sforava col `overflow-x:visible` (override desktop ≥768) nascondendo i giorni con prenotazioni (gio/sab). Fix CSS booking.css: base mobile = `grid-template-columns:1fr` (giorni impilati verticali); desktop ≥768 = `repeat(7, minmax(0,1fr))` (si adatta, niente overflow). Estratto anche helper WeekMiniTime (rimossa espressione inline `is var dd` fragile).
- **msg 3207 "cella giorno: inizio→fine + n.giorni"** — FATTO+DEPLOY: card lista risorsa mostra data inizio → data fine + "N giorni" (solo inizio+1 giorno se singolo). CSS .bk-card-time-sep.
- **msg 3209 commissione 3%+0,75€ min 1€** — FATTO+DEPLOY (ex 4%+0,30€). StripeService: percent 3, fixed 75c, +nuovo MinCents=100 (Math.Max). FAQ Boo9 + docs product-overview + 9 resx (it/es/fr/pt/ar/en/hi/zh/bn, numerali localizzati incl. bengalese ৩%+€০.৭৫). Tutte config da Stripe:CommissionPercent/FixedCents/MinCents.
- **msg 3210 "risorsa non è operatore"** — FATTO+DEPLOY. Risorse = righe shop_operators type='table'/'resource'; comparivano nella pagina Operatori (ShopOperators.razor caricava tutti senza filtro type) e nei dropdown "Operatore" dell'agenda. Fix: ShopOperators.Load filtra type=operator + Save stampa type=operator sui nuovi; BookingAgenda nuovo helper StaffOperators (filtra type=operator) usato nei 2 dropdown (form manuale + dettaglio). _operators resta completo per ResOf/lookup risorsa. DB pulito: 20 operator + 55 table, nessun null. Nessuna doppia-creazione reale (era solo leak di visualizzazione).
- **msg 3212 "risorsa vuota negli appuntamenti risorsa"** — FATTO+DEPLOY. Causa: le risorse del lido erano is_active=false (soft-deleted) e 11 erano MISCLASSIFICATE type='operator'+resource_kind='table' (default del modello: Type="operator", ResourceKind="table" → un flusso di creazione risorsa che NON setta Type le crea come operator). LoadOperators filtrava is_active=true → ResOf null → etichetta vuota. Fix: LoadOperators carica TUTTI gli operatori (anche disattivati) per il lookup; StaffOperators (dropdown) filtra type=operator AND is_active. bookings.operator_id ha FK → shop_operators (verificato). Esiste anche tabella legacy booking_operators (minimale, inutilizzata).
- **msg 3213 "risorse in tabella dedicata"** — IN ATTESA DECISIONE. Oggi risorse = shop_operators type=table; bookings.operator_id → shop_operators. Proposta a Stefano (msg 3214): nuova tabella shop_resources mantenendo STESSI id, +bookings.resource_id, migrazione ~55 record, refactor letture (editor mappa, agenda, vetrina, stagioni, addon). Chiesto: procedo ora o domani + conferma approccio. LAVORO GROSSO, tocca integrità prenotazioni → confermare prima.
- **Agenda L3/L4** (msg 3201): L1+L2 FATTI. L3 = vista planning griglia risorsa×giorni + overlap; L4 = azioni (segna incassato in loco, sposta risorsa, totali del giorno). DA FARE (in coda; probabilmente dopo migrazione 3213 che cambia il modello risorse).
- **msg 3203 "togliere orario dalla lista"** — chiesto chiarimento (3204/3208), in attesa: togliere HH:mm anche dagli appuntamenti o solo risorse (già senza orario).

### Pending (precedenti)
- msg 3090: estendere allestimenti/addon (AddonsTab.razor esiste, gestisce per resource_kind) con FOTO (upload o AI) + link a una o più risorse/tipi. DB shop_resource_addons NON ha photo_url né link multi-kind. FEATURE GRANDE — chiesto a Stefano scoping (multi-kind vs istanze specifiche; AI sì/no) prima di costruire.

### FATTO (chiusura pending 2026-06-03 pomeriggio)
- Migration lido booking_settings max_future_days=180 APPLICATA (riga creata via docker exec).
- Icone flow prenotazione (msg 3084) — fatto: sweep completo SVG + icone custom rosse (lettino/sdraio/sedia/cabina) sorgente unica Punto.Shared/BookingIconSvg.
- msg 3124: regolamento/condizioni in markdown completo (Markdig in Vetrina).

---

# Working context · 2026-06-03

## 2026-06-04 — IN CORSO: Migrazione 3213 risorse → tabella dedicata shop_resources
Stefano (msg 3219) ha confermato: SI, procedo. Agenda L3/L4 DOPO questa.
Approccio confermato: nuova tabella `shop_resources` con STESSI id delle righe shop_operators type=table/resource, + `bookings.resource_id`, migrazione ~55 record, refactor letture (editor mappa, agenda, vetrina, stagioni, addon).
Step: mappare touchpoint → DB → modello → server → editor/agenda/vetrina, verifica a ogni passo. LAVORO GROSSO, tocca integrità prenotazioni.

### SCOPERTA 2026-06-04: FASE 1 (DB) GIÀ FATTA da sessione precedente di oggi
File `docs/DB Migrations/20260604_shop_resources.sql` (untracked) già APPLICATO sul CAT. Verificato consistente:
- `shop_resources` 59 righe con STESSI id di shop_operators type table/resource (0 divergenze).
- `bookings.resource_id` (FK→shop_resources) backfillato: 10 righe, tutte = operator_id, 0 mismatch.
- `resource_id` aggiunto anche a booking_availability/booking_manual_blocks; `table_resource_id` su menu_public_orders. Tutti backfillati. RLS+grant+indici mirror.
- Colonne legacy *operator_id RITENUTE → migrazione NON distruttiva, vecchio codice ancora funziona.
- `fn_find_best_table` NON ancora aggiornata (legge ancora shop_operators type=table + bookings.operator_id).
CODICE: 0 riferimenti a shop_resources in .cs/.razor → refactor (FASE 2) tutto da fare.
NB working tree puntify ha GIÀ tantissime modifiche uncommitted (Stripe/cart/booking giorni scorsi) — non committare senza ok Stefano.

### BATCH 2026-06-04 (msg 3237/3239/3240) FATTO+DEPLOY
- msg 3237 PAGINA RISORSE: nuovo componente `RisorseTab.razor` (in Pages/Merchant/Risorse/) = lista di tutte le risorse (Api.ListTablesAsync, raggruppate per resource_kind; nome/tipo/area/prezzo/posti; Modifica/Elimina; + Nuova risorsa con default pos 100,100/60x60 così appare anche sulla Mappa). Aggiunto tab "Risorse" in TablesHome (Livelli, Aree, **Risorse**, Mappa, Accessori, Stagioni); "Mappa risorse"→"Mappa"; tab DEFAULT ora "risorse". Stessa tabella shop_resources, due viste (lista + mappa).
- msg 3239 TOOLBAR: .agenda-view-switcher margin-left:auto→margin:0 auto (centrato); mobile: date-nav/switcher/plan-range width:100%, view-btn flex:1. (App booking.css)
- msg 3240 "planning sempre vuoto": NON è un bug — è CACHE. App = Blazor WebAssembly; su CAT il service-worker.js si auto-unregister+pulisce cache ma serve UN hard-refresh manuale (Ctrl+F5). Dati verificati via PostgREST: Lido ha 51 risorse + 5 prenotazioni-risorsa in finestra con resource_id. Detto a Stefano di fare Ctrl+F5. ⚠️ MEMO: ogni deploy App su CAT richiede hard-refresh lato Stefano per vedere le modifiche WASM.
- VERIFICATO a basso livello (reflection /tmp/reflcheck): typeof(ShopResource).GetCustomAttribute<TableAttribute>().Name == "shop_resources" → il subclass [Table] override funziona, le letture App vanno sulla tabella giusta.
- Build 0 err, app riavviata, serve 200. (Tutto da vedere dopo hard-refresh di Stefano.)

### msg 3296 FATTO+DEPLOY: condizioni prenotazione non in grassetto — i titoli erano salvati come "#Titolo#" (no spazio, non markdown valido). Fix in BookingMarkdown.ToHtml: regex `(?m)^[ \t]*#(?!\s)(.+?)#[ \t]*$` → `**$1**`. Vale per cart popup + recap (entrambi usano BookingMarkdown/SimpleMarkdown). Vetrina rebuild.

### msg 3290-3293 FATTO+DEPLOY: accordion chiusi all'ingresso (_openKinds vuoto); icone risorse negli header (BookingIconSvg.KindSvg); scheda risorsa tasti ordine Elimina·spacer·Annulla/Salva; carrello vetrina meno linee divisione (rimossi border cart-row-detail/-total/rb-breakdown-total) + bump booking.css?v=20260604a.

### msg 3288 FATTO+DEPLOY: RisorseTab gruppi per tipo ora in accordion (cfg-accordion + _collapsedKinds→_openKinds/ToggleKind).

### msg 3286 FATTO+DEPLOY: Planning a tutto schermo (.agenda-card--planning full-viewport width via margin calc(50%-50vw) + bk-plan-wrap max-height calc(100vh-200px)).

### msg 3283/3284 FATTO+DEPLOY
- 3283 forma non si aggiornava dopo edit popup: SaveDecoEdit ora applica all'oggetto VIVO (re-find by id in _decorations) + StateHasChanged. (Se persiste: verificare bind color/render.)
- 3284 selettore Area: .pl-area-input ora height 34/radius 12/font 12.5 = come cfg-btn-small, affiancato ai tasti Aggiungi.

### BATCH 6 mappa 2026-06-04 FATTO+DEPLOY
- 3278 barra comandi sempre sopra: estratti pill+maniglie+rotate dai loop, render in overlay DOPO tutti gli oggetti (z-order) per il singolo selezionato (tavolo o deco).
- 3279 popup padding-bottom: regola `.cfg-modal-backdrop .cfg-modal .cfg-modal-body{padding-bottom:24px}` (config.css azzerava il bottom).
- 3280 area = SELECT tra aree esistenti (OnAreaSelect→OnRoomChanged), no input manuale, tolta icona 📍. (sostituisce OnAreaRename di 3271).
- 3281 footer mappa full-width: .pl-footer-bar margin:12px -14px 0 (annulla padding overlay), niente border-radius.

### BATCH 5 mappa/risorse 2026-06-04 FATTO+DEPLOY
- 3269 spostamento ovunque: rimossi i clamp residui nel drag SINGOLO (OnPointerMove DragMode.Move tavolo 0..Canvas-mw + deco 0..Canvas). Ora trascini ovunque.
- 3270 riuso numero: NextAvailableResourceName (mappa) usa _allResourceNames; ora DeleteSelected/DeleteSelectedAll rimuovono il nome dal set → O2 eliminato torna disponibile.
- 3271 Area inline+editable: rimosso hint area dalla toolbar-left; aggiunto input area editabile nella riga comandi (pl-area-field/input) + OnAreaRename (UpdateRoomAsync immediato).
- 3273 RisorseTab: mostra mappa associata (🗺️ nome floor via _roomToMap) o "nessuna mappa".
- 3274 deep-link modifica: route /risorse/{guid} → TablesHome ActiveTab=risorse + FocusResourceId; RisorseTab OnParametersSet apre la scheda; EditAndNav naviga a .../risorse/{id}; Cancel/Save/Delete tornano a .../risorse/risorse.
- 3275 modifica forma/deco: action "Modifica" apre pannello _editDeco (nome + colore per shape_*), SaveDecoEdit bufferizzato (_dirty).
- 3276 copia/incolla: OnKeyDown Ctrl+C/V (+Meta); CopySelection→_clipTables/_clipDecos (Clone), PasteClipboard incolla +50px Y, nuovi Guid+nomi (NextAvailableResourceName), lascia selezionate.
- Build 0 err, app riavviata. (Ctrl+F5.)

### msg 3267 FATTO+DEPLOY: tasto "Centra mappa" (⊙) ora primo e sempre visibile (rimossa condizione zoom!=1), prima di +/−.

### msg 3264/3265 scenari mappa FATTO+DEPLOY
- 3264 giardino: solo verde con erbetta (pattern pl-grass), tolte strisce di taglio + vialetto.
- 3265 generico: carta quadrettata, nuovo pattern pl-grid (cella 100u, linea 0.5 #E2E5EA). Entrambi infiniti.

### msg 3262 FIX BUG auth cold-load (403 su F5) FATTO+DEPLOY
Sintomo: F5 a freddo sulla mappa → "Nessun utente autenticato all'avvio" + /api/tables/.../floors 403 → nessun record; cambiando pagina e tornando funziona. Causa: corsa — le chiamate server partono prima del ripristino sessione → AuthHeaderHandler legge CurrentAccessToken=null → niente Bearer → 403. FIX: AuthHeaderHandler.SendAsync ora fa `await supa.IsAuthenticatedAsync()` (ripristina sessione da cookie/localStorage) PRIMA di leggere il token. Vale per TUTTE le chiamate al server. Build 0 err, app riavviata. (NB letture dirette Supabase usano anon in fallback → meno colpite.)

### BATCH 4 2026-06-04 (Risorse form + mappa mare) FATTO+DEPLOY
- msg 3257: righe non attive uguali alle attive (tolto opacity .55/is-inactive; resta badge "Non attiva"); eliminazione OTTIMISTICA (rimuovo subito da _resources + StateHasChanged, poi HardDeleteTableAsync; se fallisce ripristino la riga).
- msg 3258: form Risorsa = TIPO prima, poi Nome prevalorizzato per tipo (NextResourceName: ShortPrefix+nn es. T01/O01, primo libero), univoco per shop (NameExists validato in Save). OnKindChanged riprevalorizza se nome non toccato (_nameAuto); OnNameInput azzera _nameAuto.
- msg 3259: checkbox "Attiva" → toggle iOS `.cfg-toggle` (come ShopServices). MEMORIA salvata feedback_ios_toggle_default (usarlo di default).
- msg 3260: mappa BEACH, il mare era limitato (ShoreTop/SeaFill su -1×..2×). Esteso a -12×..13× canvas (come bg) → mare infinito come la sabbia.
- Build 0 err, app riavviata 200. (Ctrl+F5.)

### BATCH 3 mappa 2026-06-04
- msg 3251 SFONDO INFINITO + POSIZIONE LIBERA (FATTO+DEPLOY): TablesPlanimetry SVG ora ha `style="background:ScenarioBaseColor"` (copre letterbox/void ovunque) + rettangoli base/texture enormi (±12 schermate, bgX/bgY/bgW/bgH = ±12×/25× canvas) per ogni scenario (beach sand via CSS+rect, sport doghe loop esteso, garden grass pattern+stripe esteso, parking asfalto, generic/cinema base). Tolto il clamp ai bordi in ApplyGroupMove → oggetti posizionabili ovunque. Build 0 err, app riavviata.
- msg 3253 DATI NON PUBBLICI FINO A SALVA — FATTO+DEPLOY: bufferizzazione completa in TablesPlanimetry. Campi `_newTableIds/_newDecoIds/_deletedTableIds/_deletedDecoIds` + ClearPending(). Tutte le mutazioni (AddTable/SaveEdit/Rotate90/DuplicateSelected/DeleteSelected/DeleteSelectedAll/AddDeco/DeleteDeco/AddShape/RenameDeco/DuplicateDeco + drag/resize) ora SOLO locali (id client-side Guid.NewGuid). Save() flush ordinato: delete(esistenti)→create(nuovi, cattura QrToken/CreatedAt dal ritorno per non azzerarlo dopo)→update(esistenti). LoadCurrentFloorContent/Reload fanno ClearPending (scartano). Persistenza API SOLO dentro Save(). ⚠️ NON testabile via curl (merchant loggato) → Stefano deve provare flusso create/move/delete→pubblico→Salva + Abbandona.
- msg 3254 COMANDI DECORAZIONI = RISORSE — FATTO+DEPLOY: sostituita la action text deco con la stessa pillola risorse "Modifica · Duplica · Elimina" (pl-action-pill) sopra l'oggetto; Modifica→RenameDeco, Duplica→DuplicateDeco, Elimina→DeleteDeco.
- Build 0 err, app riavviata 200. (Ctrl+F5 lato Stefano.)

### BATCH 2 2026-06-04 (auth + Risorse azioni + calendario) FATTO+DEPLOY
- msg 3246 SESSIONE auto-rinnovo (FIX BUG auth): `refresh_token_already_used`→403 causato da chiamate concorrenti al load che facevano RefreshSession in parallelo con lo stesso token + double-refresh in TryRestoreFromCookie. Fix in SupabaseService.cs: SemaphoreSlim `_initLock` (single-flight su EnsureInitialized) + TryRestoreFromCookieAsync NON forza il 2° refresh se la sessione è già valida + catch EnsureInitialized: se sessione già valida (refresh in background) non fa signout. NB la sessione GIÀ rotta di Stefano richiede 1 login una-tantum, poi stabile.
- msg 3247/3248 PAGINA RISORSE: riga cliccabile→apre modifica; tasto "Elimina" su riga + nella scheda; spunta "Attiva" nella scheda (riattiva/disattiva); Elimina = hard-delete con guard server (rifiuta se prenotazioni non-cancellate → "has_bookings"). Nuovo endpoint server DELETE /api/tables/tables/{id}/permanent + TablesApiService.HardDeleteTableAsync. CSS cfg-row-clickable/cfg-badge-muted/cfg-group-title in config.css.
- msg 3245 CALENDARIO PUBBLICO: giorni senza risorse libere → niente pallino + non selezionabili. Nuovo endpoint `GET /api/public/merchants/{slug}/resource-availability?kind&kinds&from&to` (per-giorno ≥1 libera, cap 180gg). BookingPublicService.GetResourceAvailableDatesAsync (ritorna null su errore = nessun vincolo, set vuoto = tutti disabilitati). ResourceBooking carica _availableDates (today→_maxDate) e lo passa a MiniCalendar (AvailableDates). NB Lido: ombrelloni tutti is_active=false → availability vuota → calendario tutto grigio finché Stefano non riattiva dalla pagina Risorse.
- Build 0 err (server+app+vetrina), tutti riavviati. Vetrina = Blazor Server (no hard-refresh); App = WASM (serve Ctrl+F5).

### msg 3242/3243 "non vedo risorse" → causa = SESSIONE scaduta (non bug risorse)
Console di Stefano: POST /auth/v1/token 400 `refresh_token_already_used` → JWT non valido → /api/tables/... 403 Forbidden → liste vuote. Soluzione: logout+login (sessione fresca) + Ctrl+F5. Probabile concausa: i miei restart ripetuti dell'app + più tab che rinnovano il token insieme. SE RICORRE spesso → valutare single-flight refresh token nel client (per ora re-login basta).
Inoltre migliorato RisorseTab: ora carica TUTTE le risorse via SupabaseClient.From<ShopResource>() (no filtro is_active, usa policy anon in lettura → funziona anche con sessione debole), badge "Non attiva" + tasto Riattiva/Disattiva (Api.UpdateTableAsync con is_active). NB Lido: tutte le risorse is_active=false → da riattivare dalla lista. Build 0 err, app riavviata 200.

### RINOMINA Tables→Risorse 2026-06-04 (msg 3231) FATTO+DEPLOY
- Cartella `Puntify.App/Pages/Merchant/Tables/` → `Risorse/` (git mv, 6 componenti; nessun ref esterno ai tag → namespace interno ok).
- Route `/merchant/shop/{id}/tables[/{tab}]` → `/risorse[/{tab}]` (TablesHome @page, SetTab, MerchantHome tile route, AiAssistantFab path.Contains). Tile Id "tavoli" lasciato invariato (persistenza ordine icone).
- Tab "tavoli" → "mappa" (default + button + case) → URL .../risorse/mappa. Build 0 err, app riavviata, serve 200.

### msg 3235 (planning vuota) FIX 2026-06-04: causa = PlanningResources filtrava is_active, ma le risorse del Lido sono soft-deleted (is_active=false) pur avendo prenotazioni → righe nascoste. Fix: PlanningResources = attive OR con prenotazioni nel periodo (_bookings.resource_id). Default range _planningDays 14→30 (Mese). Empty message chiarito (planning=risorse; appuntamenti in Giorno/Settimana). NB: lo shop dello screenshot non aveva prenotazioni-risorsa nel periodo (solo Lido del Sole=5 e Caffè=1 hanno booking in finestra). Build 0 err, app riavviata. DA CHIEDERE: planning anche per appuntamenti(operatore)?

### msg 3233 (mese + barre multi-giorno + griglia hotel): GIÀ COPERTO dal tab Planning (L3) appena fatto. Stefano probabilmente non l'ha ancora visto. Indicato dove (Agenda→Planning, preset Mese/2 mesi). Eventuale polish: barra continua (rimuovere bordo tra celle contigue stessa prenotazione).

### AGENDA L3/L4 COSTRUITA + DEPLOY 2026-06-04 (Stefano: range fino a 2 mesi, msg 3228)
- L3 vista PLANNING (BookingAgenda): 3° toggle, selettore intervallo 7/14/30/60 gg + frecce, griglia risorse×giorni (colonna risorse sticky sx, giorni sticky top, scroll orizzontale), celle libero/occupato, period multi-day = celle contigue colorate, badge numero se >1 prenotazione/giorno, tap→dettaglio, riga totali (n · incassato · da incassare). CSS bk-plan-* in App booking.css.
- L4 azioni nel dettaglio: "Segna incassato in loco" (PUT /api/booking/{id}/mark-paid → payment_status=paid + transazione source=manual Modello B, idempotente) e "Sposta su altra risorsa" (PUT /api/booking/{id}/resource → check stesso kind + disponibilità periodo → cambia resource_id). Metodi in IBookingService/BookingServiceImpl + BookingApiService.
- Build 0 err (server+app), deploy: server :8001, app :8002 (gira sotto `dotnet watch run` → restart ~30s, lento a SIGTERM). Migrazione risorse: E2E già verificata. L3/L4 runtime NON curl-abile (auth API-key+JWT su /api/booking + Blazor merchant) → VERIFICA BROWSER da parte di Stefano in sospeso.
- Inviato a Stefano per test browser (msg dopo 3229).

### MIGRAZIONE 3213 COMPLETATA 2026-06-04 ✅ (fasi 1+2+3, deploy + E2E verificato sul CAT)
- FASE 1 (DB additivo): era già stata fatta da sessione precedente (20260604_shop_resources.sql).
- FASE 2 (codice): spostate tutte le letture/scritture risorse shop_operators→shop_resources; prenotazioni tavolo/risorsa usano bookings.resource_id. File: TablesController, MenuController, TableBookingController, PublicBookingController, BookingServiceImpl (operatori type=operator), StripeController (desc resource-aware), modello ShopResource [Table shop_resources] + BookingEntry.ResourceId + MenuPublicOrder→table_resource_id, App TablesManager→ShopResource, BookingAgenda (_resources + ResOf/IsResource via resource_id). fn_find_best_table→shop_resources+resource_id (20260604_shop_resources_phase2.sql). Build 0 err tutti i progetti, 3 servizi riavviati uno alla volta.
- FASE 3 (cleanup): 20260604_shop_resources_phase3.sql (transazione+guard). shop_operators ora SOLO 16 operatori-persona; 59 righe risorsa rimosse; 10 prenotazioni risorsa con resource_id e operator_id azzerato. Colonne legacy *operator_id tenute per rollback.
- VERIFICA E2E: reserve tavolo via API → resource_id valorizzato, operator_id null, slot occupato, cleanup ok; pre e post Phase3.
- NB: lido umbrellas sono is_active=false (soft-deleted da prima) → endpoint resources umbrella non torna dati attivi, normale.
- PROSSIMO: Agenda L3/L4 (Stefano msg 3219: dopo 3213). NB working tree puntify resta con TANTE modifiche uncommitted (Stripe/cart + questa migrazione) — non committato, attendere ok Stefano (msg 3226: chiarito che non committo finché non dice cosa includere).
- AGENDA L3/L4: piano inviato (msg 3227), IN ATTESA OK Stefano + risposta su planning settimana vs range scegliibile. Piano: L3 = nuova vista "planning" (3° toggle) griglia risorse×7gg con celle libero/occupato/badge-numero + riga totali giorno; L4 = azioni nel dettaglio: "segna incassato in loco" (payment_status=paid + transazione source=manual, nuovo endpoint) e "sposta su altra risorsa" (cambia resource_id con check disponibilità, nuovo endpoint). _resources già caricato in BookingAgenda dalla migrazione. CSS booking.css (App) cache-bust via build-info.js automatico. NON ancora iniziato.

### FASE 2 (refactor codice) — IN CORSO 2026-06-04
Approccio cutover su CAT: spostare TUTTE le letture/scritture risorse da shop_operators→shop_resources e bookings operator_id→resource_id, aggiornare fn_find_best_table nello stesso deploy. Legacy columns restano come fallback/rollback. Verifica E2E poi FASE 3 cleanup.

## Stato attuale: Puntify — Pagamenti booking (Stripe Connect)

Sessione nuova (post-compaction). Stefano ha passato chiavi Stripe TEST (pk/sk) e ricordato il lavoro di ieri:
- **Fase 3 carrello DONE** (vetrina): tap risorsa → Riepilogo → "Aggiungi al carrello"/"Concludi" → checkout multi-articolo stesso shop, dati cliente una volta, totale +acconto, "Concludi prenotazione" prenota tutte le postazioni. Build ok, CSS `?v=20260603a`.
- **Fase 4 = incasso reale via Stripe Connect** (i soldi vanno al LIDO, non a Puntify → marketplace, non subscription).

### Stato codice rilevato
- Checkout: `Puntify.Vetrina/Components/Booking/CartCheckout.razor`. Oggi `Confirm()` chiama solo `BookingPublicService.ReserveResourceAsync` per ogni risorsa → registra prenotazione, nessun incasso. Bottone "Vai al pagamento" mostrato se `DueNow>0` ma non paga. Nota "pagamento Stripe in arrivo" su item a pagamento (`PaymentMode` free|full|deposit, `DueNow`=acconto/saldo).
- `CartItem.cs`: PaymentMode, GrandTotal, DueNow.
- API server resource reserve: `POST /api/public/booking/table/resource/reserve` (Puntify.Server).
- Chiavi Stripe test salvate in `Puntify.Server/appsettings.Development.json` (gitignored riga 348, chmod 600) → sezione `Stripe` {PublishableKey, SecretKey, WebhookSecret:""}. Webhook secret da generare.

### Decisioni Connect CONFERMATE (Stefano 2026-06-03)
- Account = **Express**.
- Commissione Puntify = **0**; fee Stripe a carico del lido sull'incasso.
- Modello addebito = **"Stripe gestisce le tariffe"** (Stripe addebita il lido, Puntify 0). Costi Express IT: 2€/mese lido attivo + 0,25%+0,10€/payout + 1,5%+0,25€/txn, tutti sul lido.
- Onboarding = nuova pagina **"Pagamenti"** in Puntify.App dal menu home, responsive.
- Flusso = carrello → Checkout → webhook conferma; acconto = paga ora, saldo in loco.

### Fatto 2026-06-03
- FAQ vetrina: Boo8 (pagamento/acconto → "supportato via Stripe") + Boo9 in 9 lingue + JSON-LD. Boo9 RICORRETTA: ora "Puntify trattiene commissione di servizio 6%+0,30€" (prima diceva 0). Doc product-overview idem. Live IT/EN.
- Commissione CONFERMATA da Stefano: **6% + 0,30€** (configurabile UI). Modello: Puntify assorbe fee Stripe, lido vede una sola trattenuta.
- LEGALE: nuova pagina `CondizioniPrenotazione.razor` (IT+EN, route /condizioni-prenotazione) live su CAT per review — intermediario, due contratti, Stripe Connect (fondi al lido), cancellazione per-lido (Puntify non responsabile), esclusione recesso art.59, foro consumatore, ODR. Parte = "Puntify (gestore in definizione)" (no P.IVA finta). Privacy.razor aggiornata (riga contanti + Stripe Connect + ruoli). Link in Footer.razor + CartCheckout spunta GDPR. Build+restart OK.
  - Risposte legali Stefano: (1) nessuna società ancora → SRLS; (2) cancellazione/rimborso = policy lido, Puntify non responsabile; (3) esclusione recesso art.59 SI; (4) lingue IT + EN.
  - 2026-06-03: generalizzato a TUTTI gli esercenti (non solo lidi). Commissione 6%+0,30€ RIMOSSA dalle condizioni cliente (come spiagge.it che non mette numeri): lì resta generica "a carico dell'Esercente". Il 6%+0,30€ va messo nei **Termini Esercente** + **pagina Pagamenti** (da fare).
  - DA FARE: review Stefano → poi portare in prod (commit/deploy).
- SRLS: pagina vault `puntify-costi-srls`. Fisso ~6,7–8,3k€/anno (INPS dominante ~4.612€), break-even ~56–70 esercenti/mese. Inviato a Stefano.

### CAMBIO 2026-06-03 (msg 3025): Puntify PRENDE commissione sulle prenotazioni
Stefano ha ribaltato il "Puntify 0 commissione". Ora: commissione (application_fee) a Puntify che copre 2€/mese Stripe + transazione + margine.
- Modello proposto: cliente paga pieno → Puntify trattiene application_fee e gira il resto al lido → Puntify si fa carico delle fee Stripe (lido vede una sola trattenuta = commissione Puntify). = "platform manages pricing" + destination/direct charge con application_fee.
- Commissione default proposta: **6% + 0,30€** a prenotazione (la quota fissa copre lo 0,25€ Stripe sui ticket piccoli). CONFIGURABILE da UI (memoria ui-editable).
- IN ATTESA conferma % da Stefano ("vai" = parto col default).
- DA RIFARE dopo conferma: FAQ Boo9 (ora dice "Puntify 0 commissione" — sbagliata; solo su CAT, non prod) + doc product-overview + clausola pagamento nelle Condizioni di Prenotazione.

### Task legale parallelo (msg 3024): Condizioni di Prenotazione stile spiagge.it
- Puntify intermediario cliente↔lido. Nuova pagina "Condizioni Generali di Prenotazione" (cliente-facing) + update Privacy.
- Studiati spiagge.it/terms (12 art.) + /privacy. Termini.razor attuale = contratto Puntify↔Commerciante (IT-only hardcoded). Privacy.razor IT-only, cita già Stripe sub-resp. ma ha riga "pagamenti in contanti" DA CORREGGERE.
- BLOCCANTE: P.IVA sito = 12345678912 = PLACEHOLDER, serve quella vera. + decisioni: policy cancellazione/rimborso per-lido?, esclusione recesso art.59 Cod.Consumo?, lingue IT-only vs tutte.
- Piano: bozza su CAT, review Stefano prima di prod.

### Prossimi passi (implementazione Connect) — dopo conferma commissione
- Server: SDK Stripe.net, create Express account + AccountLink onboarding, Checkout Session su account connesso con application_fee, webhook handler. Colonne DB (shops.stripe_account_id + stato onboarding, stato pagamento prenotazione). Webhook secret whsec_ da generare. Commissione configurabile (settings/DB).
- App: pagina Pagamenti (collega Stripe + stato onboarding) dal menu home, responsive.
- Vetrina: CartCheckout → redirect a Checkout + pagine success/cancel; conferma prenotazione solo su webhook pagato.

---

# Working context · 2026-05-28

## Stato attuale: Puntify — Menu per tipologia shop (prodotti vs servizi)

**FASI 1-2 fatte e verificate. Restano: edit campi servizio (foto/video/tag), FASE 3 cascata, FASE 4 cross-sell.**

### Contesto / decisioni raccolte da Stefano
- Tipo shop dedotto AUTOMATICAMENTE dalla categoria (`shop.categoryid` → tabella `puntify.category`).
- Categorie "a servizi" (3 Parrucchiere, 4 Centro Estetico, 5 Barbiere, e simili: estetica, tatuatore, fisio, ecc.) → menu MISTO: servizi + prodotti (es. barbiere: taglio/piega + shampoo).
- Ristorante/Bar/retail → menu solo prodotti (comportamento attuale).
- Fonte unica servizi = `shop_services` (durata, prezzo) già usata per le prenotazioni. Il menu li RIFLETTE/RIUSA, NON li duplica. Servizio lato prenotazione = tempo+costo stimato; lato menu = vetrina prezzi pubblica.

### Architettura attuale rilevata
- Menu: `shop_menus` → `shop_menu_sections` → `shop_menu_dishes` (allergeni, ingredienti, dietary_tags, feature_tags, opzioni, abbinamenti `shop_menu_dish_pairings`, carrello via `menu_public_orders`).
- Servizi prenotazione: `shop_services` (BookingService: name, description, duration_minutes, price, price_display, buffer_before/after, service_kind). Operatori: `shop_operator_services`.
- Classificazione categoria esistente da riusare: `Puntify.Server/Services/Booking/BookingModesDefaults.FromCategoryId` (bit appointments/tables/takeaway).
- Editor: `Puntify.App/Pages/Merchant/Menu/MenuEditor.razor`. Pubblico: `Puntify.Vetrina/Pages/MerchantMenuPreview.razor` + `Components/Menu/MenuView.razor`.

### Piano proposto (4 fasi)
1. Classificazione categoria→tipo + menu pubblico misto (servizi nome/durata/costo, no carrello; prodotti con carrello). Terminologia + niente allergeni sui servizi.
2. Editor: "Aggiungi servizio" pesca da shop_services nelle sezioni (link table sezione↔servizio); durata/prezzo editati solo nel modulo Prenotazioni.
3. Prenotazione servizi in cascata: selezione multipla → durata = somma (+buffer), slot ricalcolati.
4. Cross-selling in prenotazione: proporre servizio aggiuntivo (estendere il meccanismo abbinamenti dei piatti).

### Da decidere con Stefano
- Info specifiche servizio oltre durata+prezzo (le fornirà lui).
- Tutto in sequenza vs partire solo da Fase 1 (menu) e rimandare 3-4 (prenotazione).

### Prossimi passi
- Attendere OK/correzioni → poi creare pagina decisione in `wiki/decisions/` e iniziare Fase 1.

---

## STATO 2026-05-28 fine sessione

FATTE e VERIFICATE (build+restart+test live), COMMITTATE (55081be, push su master 2026-05-28):
- FASE 1 (servizi nel menu pubblico) — vedi daily.
- FASE 2 (editor: servizi nelle sezioni) — vedi daily, E2E verificato.
- Point A: campi servizio foto/video/etichette in `ShopServices.razor`.

Decisioni Stefano per FASE 3-4 (raccolte 2026-05-28):
- Cascata: operatore OPZIONALE (uno o nessuno, sceglie il cliente). Slot calcolati sulla durata TOTALE. Se sceglie un operatore, dev'essere uno che offre i servizi scelti; se nessuno → assegna il negozio.
- Cross-sell (FASE 4): AUTOMATICO (servizi più abbinati), nessuna config merchant.

### PIANO FASE 3 (additivo, retro-compatibile — singolo servizio resta identico)
Chiave: `SlotEngine.GetAvailableSlots` (Punto.Shared/Services/SlotEngine.cs) usa `service.BufferBefore + DurationMinutes + BufferAfter` (riga 32). → passare un BookingService SINTETICO con durata sommata.
1. DB: tabella `booking_services (id, booking_id FK ON DELETE CASCADE, service_id FK, sort_order)`. Modello `BookingServiceLink`.
2. `IBookingService`/`BookingServiceImpl`: overload `GetSlotsAsync(shopId, List<Guid> serviceIds, date, operatorId?)` → costruisce servizio sintetico (Duration=Σdurate; BufferBefore=primo.BufferBefore; BufferAfter=ultimo.BufferAfter) e riusa l'engine. Il metodo singolo delega a quello a lista.
3. `PublicBookingController`: `GetSlots` accetta `serviceIds` (csv) oltre a `serviceId`; `GetOperators` (riga ~168) filtra operatori che offrono TUTTI i serviceIds; `CreateBooking` accetta `ServiceIds` (fallback singolo), EndAt=start+durata totale, salva righe in booking_services, `bookings.service_id`=primo (compat), prezzo=Σ.
4. UI `Components/Booking/ServiceStep.razor` + `PublicBookingFlow.razor`: multi-selezione servizi (checkbox/aggiungi), mostra durata e prezzo totali; passa serviceIds. `ConfirmationStep` + notifiche/email elencano i servizi (join booking_services). Reschedule (PublicBookingController ~539) usa durata totale.
5. Verifica E2E come Fase 2: creare servizi+operatore+availability di test, controllare slot con durata combinata, poi pulire.

### PIANO FASE 4 (cross-sell automatico)
- In `PublicBookingFlow` dopo la scelta servizio, proporre 1-2 servizi aggiuntivi "più abbinati": calcolo da co-occorrenza in `booking_services` (quali servizi vengono prenotati insieme) con fallback ai più prenotati del PV. Endpoint pubblico `GET /api/public/booking/{slug}/service-suggestions?serviceIds=...`. Aggiungere al carrello servizi → confluisce in Fase 3.

### Backlog
- Comprimere foto prima di upload MinIO (strategia da concordare).
- (Sicurezza minore) valutare RLS su shop_menu_section_services / booking_services (ora accesso solo via server service_role).
- Auth JWT FASE A committata (32dad34). FASE B (enforcement per-shop) da fare con test coordinato. JwtSecret recuperato dai container.

## 2026-06-02 — Puntify: prenotazione unificata risorse+operatori (IN ATTESA risposte Stefano)
Richiesta: su /m/{slug}/book mostrare TUTTE le prenotazioni attive del locale (es. lido: tavolo + ombrellone + lettino) da un solo tasto "Prenota". Sulla pagina merchant /services ogni servizio deve indicare: unità di prenotazione (giornata / slot orario con durata min / periodo) e se riguarda una RISORSA (es. campo) o un OPERATORE (consulente). Se risorsa: associare una mappa risorse + flag "mostra in prenotazione coi posti liberi"; nel pubblico, dopo la scelta del periodo, mostrare la mappa con le risorse libere.

ARCHITETTURA ESISTENTE rilevata (gran parte già c'è):
- shop_services (BookingModels.cs ~143): ServiceKind appointment|takeaway_window, DurationMinutes, Price, PriceDisplay, SlotCapacity. NESSUN campo tipo(risorsa/operatore) né booking_unit → da aggiungere.
- shop_operators (~249): Type operator|resource|table (OperatorTypes), ResourceKind, **BookingUnit slot|day|period**, Price, Capacity/Zone, campi planimetria (RoomId,Shape,PosX/Y,W/H,Rotation), QrToken.
- ResourceKinds.cs: catalogo (table,umbrella,lettino,sdraio,gazebo,cabina,court_soccer/tennis,room,posto_auto…) con DefaultBookingUnit e DefaultShape.
- Mappe: shop_floors (IsPublic, Scenario beach/cinema/…), shop_rooms, shop_floor_decorations. Editor Puntify.App/Pages/Merchant/Tables/TablesPlanimetry.razor.
- Modalità pubbliche: bitmask BookingModes (1 appointments,2 tables,4 takeaway) — NO bit "resources". ModeStep + QuickTableBooking + QuickTakeawayBooking + flusso appuntamenti (ServiceStep→Operator→DateTime→…). Endpoint GET /merchants/{slug}/resources già ritorna risorse con bookingUnit, mapScenario, aree, prezzo stagionale, disponibilità, addons.
- Editor servizi: Puntify.App/Pages/Merchant/Booking/ShopServices.razor (oggi solo nome/descr/durata/prezzo/buffer/foto/video/tag).

DOMANDE INVIATE a Stefano (msg 2945), proposte default mie:
1) /services elenco unico tipizzato (operatore/risorsa); mappa+risorse restano nell'editor Risorse → DEFAULT sì.
2) unità = Giornata/Slot(min)/Periodo, guida il selettore pubblico → DEFAULT sì.
3) servizio-risorsa mostra auto tutte le risorse di quel tipo sulla mappa, libero/occupato per periodo → DEFAULT automatico per tipo.
4) tavolo/asporto restano modalità ma confluiscono nello stesso "Prenota" → DEFAULT sì.
RISPOSTE STEFANO (msg 2946):
1) CONFERMATO: /services elenco unico tipizzato; mappa+risorse restano nell'editor Risorse.
2) Unità: decido io, allargare per coprire più situazioni (oltre giornata/slot/periodo: es. fascia intera, evento a data, ecc.).
3) Se servizio ha MAPPA associata → mostra mappa, cliente seleziona 1+ entità (max selezionabili configurabile nel servizio). Se NO mappa → mostra le risorse come lista, seleziona fino al max. → servizio ha campo "max entità selezionabili per prenotazione".
4) (msg 2949) Flag per-servizio: il cliente può SCEGLIERE la risorsa o no. Sì→mostra tavoli/risorse (mappa o lista). No→assegna il sistema per caratteristiche (es. tavolo 3 posti per 3 persone).

DESIGN PROPOSTO (msg 2950, in attesa OK finale):
Nuovi campi shop_services:
- booking_target: operator|resource
- booking_unit (set scelto da me): slot(durata min) | day(giornata) | half_day(mezza giornata mattina/pomeriggio) | period(multi-giorno) | event(ingresso a data, capienza, no orario)
- se resource: resource_kind + resource_map_id(floor, opz) + show_map_in_booking(bool)
- max_selectable (max entità per prenotazione)
- customer_can_choose_resource (bool; false→auto-assegna per caratteristiche)
Flusso pubblico unico "Prenota": lista voci attive → servizio → periodo (selettore per unità) → se risorsa & può scegliere: mappa(se assoc.) o lista, fino a max → dati → conferma. Tavolo/asporto confluiscono.
FASI: A) DB+editor /services unificato; B) flusso pubblico+mappa/lista+auto-assegna. Verifica live ad ogni fase.
Stefano: OK (msg 2951) → procedere.

### FASE A — FATTA + verificata (2026-06-02)
- DB: ALTER shop_services + colonne booking_target, booking_unit, resource_kind, resource_map_id (FK shop_floors ON DELETE SET NULL), show_map_in_booking, max_selectable, customer_can_choose_resource, event_capacity. NOTIFY pgrst reload.
- Modello `BookingService` (BookingModels.cs) esteso con i campi; nuove costanti `BookingTargets` (operator|resource) e `BookingUnits` (slot|day|half_day|period|event, con .All e .Label).
- Editor `Puntify.App/Pages/Merchant/Booking/ShopServices.razor`: nuovi campi — Tipo (Operatore/Risorsa, segmented), Unità (select), Durata slot (solo unit=slot), Capienza (solo unit=event), Prezzo con help dinamico, Buffer (solo operatore), e blocco risorsa: tipo risorsa (ResourceKinds per ambito), max selezionabili, "cliente può scegliere", mappa associata (shop_floors dello shop), "mostra mappa in prenotazione". RowMeta in lista riflette tipo/unità. Salvataggio via Supabase client su tutti i campi.
- Build App OK (0 err). Restart app+server+vetrina. Verifiche live: round-trip DB su colonne risorsa OK; server GetServices lido 200 (modello deserializza); PostgREST /rest/v1 espone le nuove colonne (200) → path scrittura editor OK.
- NON committato.
### FASE B — in corso (incrementi verificati)
B.1 FATTO+verificato (2026-06-02): ServicePublicDto esteso con bookingTarget/bookingUnit/resourceKind/resourceMapId/showMapInBooking/maxSelectable/customerCanChooseResource/eventCapacity; helper `ToServiceDto` in PublicBookingController usato da GetServices e service-suggestions. Build Server+Vetrina OK, restart server, curl GetServices lido mostra i nuovi campi (default operator/slot). Il client Vetrina (GetPublicServicesAsync→ServicePublicDto) li riceve già.
B.2 TODO (la parte grossa, UI pubblica): flusso unico "Prenota":
- ServiceStep già lista TUTTI i servizi attivi (no filtro kind) → ok come elenco unico.
- Routing per servizio selezionato: se target=operator→flusso attuale (slot/operatore). Se target=resource→nuovo step risorsa.
- Selettore periodo per unità: slot→data+orari; day→data; half_day→data+mattina/pomeriggio; period→intervallo date; event→data (+capienza).
- Se resource & customerCanChoose: mappa (se resourceMapId & showMapInBooking) con liberi/occupati, oppure lista risorse del resource_kind; selezione fino a maxSelectable. Se !customerCanChoose: auto-assegna per caratteristiche (riusa fn_find_best_table per tavoli; per risorse a giornata assegna prima libera).
- Backend riuso: GET /merchants/{slug}/resources (già ritorna risorse+mappa+disponibilità per data) — da estendere per accettare il service_id e derivare resource_kind/map/periodo; reservation via TableBookingController ReserveResourceAsync.
- Tavolo/asporto confluiscono nello stesso "Prenota".
NON committato (tutta la feature).

### Test data lido + regola UI-editable (2026-06-02)
Stefano (msg 2955): tutto ciò che configuro deve essere fruibile/modificabile da lui dall'interfaccia → salvata memory feedback_ui_editable. I dati di test li metto solo con campi già editabili nell'editor.
Lido ha già: floor "Spiaggia" (beach, pubblico) + "Cinema"; rooms Area Spiaggia/Area 1; risorse type=table con resource_kind umbrella×10, lettino×4, sdraio×6, table×6, court_*, cabina, gazebo, ecc.
Convertiti i 2 servizi lido (campi editabili):
- "Prenotazione Tavolo" → resource/table/slot, customer_can_choose=false (auto per posti), max 1.
- "Ombrellone e Lettino" → resource/umbrella/day, mappa=Spiaggia(40a8d224), show_map=true, customer_can_choose=true, max 2.
Verificato: GET /merchants/lido.../resources?kind=umbrella&date= ritorna mapScenario=beach, aree, 6 ombrelloni con pos/prezzo(stagione Media ×1.2)/disponibilità + addon Lettino/Sdraio. Data-path B.2 (ombrellone) pronto.
### FASE B.2 — flusso pubblico risorsa (incremento fatto 2026-06-02)
- Nuovo componente `Puntify.Vetrina/Components/Booking/ResourceBooking.razor` (autonomo, stile QuickTableBooking): per servizi resource a data (day/half_day/period/event). Scelta data (MiniCalendar; +data fine per period; +mattina/pomeriggio per half_day) → carica GetResourcesAsync(slug, resourceKind, data) → vista LISTA o MAPPA (toggle, mappa con marker posizionati per pos/shape, verde libero/grigio occupato/accent selezionato) → selezione fino a MaxSelectable (o auto-assegna prime disponibili se !CustomerCanChooseResource) → dati cliente → submit = loop ReserveResourceAsync per risorsa. Conferma + totale (prezzo×giorni per period).
- `PublicBookingFlow`: campo `_resourceService`; in cima render `<ResourceBooking>` quando settato; `ToggleService` → se target=resource: unit=slot→`_selectedMode="table"` (riusa QuickTableBooking per tavoli/campi a slot), altrimenti `_resourceService=svc`. Auto-select singolo servizio e Reset gestiti.
- CSS rb-* in booking.css. Build Vetrina OK (0 err), restart.
- VERIFICA: GetResources lido ok; reserve E2E reale (POST /booking/table/resource/reserve su ombrellone A1) → success, disponibilità→occupata, poi cleanup. UI compila e chiama esattamente questi endpoint. NB: click-through visivo non verificabile via curl (Blazor Server interattivo) → da provare in browser.
### FASE B.3 — entry unico "Prenota" (FATTO + verificato prerender 2026-06-02)
Confermato da Stefano (msg 2961). Rimosso il bivio ModeStep: il tasto "Prenota" porta direttamente all'elenco unico (ServiceStep) con TUTTI i servizi + voci sintetiche tavolo/asporto quando il PV ha quelle modalità ma nessun servizio le copre (così nessuna modalità si perde, vale per tutti i merchant).
- PublicBookingFlow: rimosso branch ModeStep; carica sempre servizi+gruppi+`BuildModeEntries()`. Helper `AllEntries()`, `BuildModeEntries()` (sentinel ServiceKind __mode_table__/__mode_takeaway__), `IsModeEntry()`, `RouteEntry(svc, autoSingle)`. `ToggleService`: voci non-operatore (mode/takeaway_window/resource) → RouteEntry; operatore → multi-select cart. Auto-route se un'unica voce. Reset rifà l'elenco.
- ServiceStep: nuovo param `ModeEntries` (rese come card con icona+descrizione+freccia, RenderModeCard); messaggio "nessun servizio" solo se servizi E mode entries vuoti; `CardMeta()` unit-aware (es. "Ombrellone · Giornata intera", "Asporto", "30 min"). Subtitle "Scegli cosa prenotare".
- Build Vetrina OK, restart. Verifica prerender /it/m/lido.../book: elenca direttamente "Ombrellone e Lettino" + "Prenotazione Tavolo", prompt "Scegli cosa prenotare", NESSUNa card ModeStep. Casi merchant analizzati (solo-tavolo, tavolo+asporto senza servizi, takeaway-service+tavoli) → nessuna modalità persa.
- Click-through interattivo (tap → ResourceBooking/QuickTableBooking) ancora da provare in browser.
### Rifiniture calendario (2026-06-02, msg 2963) — FATTO
- MiniCalendar esteso (retro-compatibile): `WeekView` (una settimana per volta, nav settimanale, header "2 – 8 giu"), `RangeMode` (dal/al con giorni evidenziati: in-range/range-start/range-end, callback RangeChanged), `ShowQuickButtons` (Oggi/Domani/Questo weekend sotto il calendario; weekend = sabato, in range sab→dom).
- QuickTableBooking: MiniCalendar ora WeekView+ShowQuickButtons.
- ResourceBooking: periodo → un solo calendario RangeMode+quick (sostituite le 2 mini); giorno/mezza/evento → WeekView+quick. OnRangeChanged aggiorna start/end (ricarica risorse sulla data inizio). CSS .in-range/.range-*/.mini-cal-quick in booking.css.
- Build Vetrina OK, restart, /book 200.

### Skip scelta servizio se unico (msg 2964) — GIÀ implementato in B.3
- Auto-route: `entries.Count == 1` → RouteEntry diretto (resource→ResourceBooking, operatore→datetime, mode→tavolo/asporto), salta la lista.
- NB: "entries" = servizi + voci sintetiche tavolo/asporto. Test col lido a 1 servizio: lista comparsa lo stesso perché il lido HasTables senza service-tavolo → +voce sintetica Tavolo = 2 voci (corretto). Col lido normale (2 servizi) lista corretta. Per shop davvero a 1 voce → salta.
- Da chiarire con Stefano se intende: shop con 1 SERVIZIO ma con tavoli/operatori configurati deve comunque saltare al servizio (regola diversa).

### ResourceBooking a STEP (mobile-first) — FATTO (msg "wizard")
Stefano: la prenotazione deve essere a step (data → risorse → dati), una schermata per volta, ottima su smartphone.
- ResourceBooking riscritto come WIZARD: enum Step {Period, Resource, Customer}; _steps dinamico (Resource solo se CustomerCanChooseResource); stepper in alto, una card per step, barra azioni sticky in basso (Indietro/Annulla + Continua/Prenota). Validazione per step. Conferma finale.
- Layout single-column max 560px, sticky actionbar (statica ≥640px). Nuove classi rb-wizard/rb-head/rb-steps/rb-step/rb-card/rb-field/rb-actionbar/rb-rescard in booking.css. Resta MiniCalendar week/range/quick dentro lo step Data.
- Build Vetrina OK, restart, /book 200. Click-through da verificare in browser.
NB: QuickTableBooking e il flusso appuntamenti sono già a step/mobile. Per ora ho reso a step il flusso RISORSA (descrizione esplicita di Stefano data→risorse→dati).
### Weekend = sab+dom (msg 2967)
Regola già nel codice: il tasto "Questo weekend" in MiniCalendar RangeMode seleziona sab→dom (RangeChanged(Sat, Sat+1)); in modalità singola (risorse a giornata) seleziona un solo giorno. = "se la risorsa la consente" (consente = unit period/multi-giorno).
Per dimostrarlo sul lido ho cambiato ombrellone day→period (campo editabile). Ora ResourceBooking usa RangeMode → weekend = sab+dom. Period copre sia giorno singolo (click 1 giorno) sia weekend/più giorni.
### Micro-fix UI (2026-06-02)
- (msg 2969) Rimosso titolo "Scegli la data"/"Scegli il periodo" nello step Period del wizard risorsa (ridondante con lo stepper).
- (msg 2971) Flusso TAVOLO (QuickTableBooking): riepilogo selezione spostato in BASSO (nuova .tb-bottom-summary a fondo form); nascosti il riepilogo laterale (.booking-summary-card) e quello in alto (.mobile-summary).
- (msg 2972) MiniCalendar: tasti rapidi Oggi/Domani/Questo weekend ora mostrano lo stato ATTIVO (_activeQuick, .mini-cal-quick button.active); click su un giorno manuale azzera l'evidenza.
- Build Vetrina OK, restart. Da verificare in browser.
### CACHE-BUST booking.css (2026-06-02) — IMPORTANTE
- (msg 2974 "dal>al sempre a destra sullo smartphone") CAUSA: `Book.razor` linkava `css/booking.css?v=20260529c` (versione vecchia) → il browser usava il CSS cachato SENZA le regole nuove (rb-wizard, .tb-bottom-summary, .mini-cal-quick.active, range). Tutte le mie modifiche CSS recenti NON arrivavano al device.
- FIX: bump a `booking.css?v=20260602a` in Book.razor. Verificato nel render.
- ⚠️ REGOLA: ogni volta che modifico Puntify.Vetrina/wwwroot/css/booking.css devo bumpare il `?v=` in Book.razor (e se serve Risorse.razor). Stesso pattern di menu-public.css.
### Fix layout+range (2026-06-02, screenshot lido)
- (msg 2976) BUG: riepilogo "dal→al" a destra del calendario. CAUSA: residuo CSS `.rb-card{display:flex}` della prima B.2 in conflitto col `.rb-card` del wizard → step-body diventava flex-row (calendario+recap affiancati). FIX: rimosse le regole obsolete `.rb-card*`/`.rb-auto` (il wizard usa .rb-rescard). Ora recap va sotto i tasti.
- (msg 2977) Range a 2 click: MiniCalendar ora usa stato INTERNO _selStart/_selEnd (prima la logica leggeva i param RangeStart/RangeEnd che il parent teneva =today → ogni stato sembrava "completo" e il 2° click resettava). Ora: 1° click=inizio (azzera fine), 2° click(>=inizio)=fine. QuickPick aggiorna lo stato interno (weekend=sab+dom). Highlight da stato interno.
- ⚠️ Ribumpato booking.css → ?v=20260602b in Book.razor (modifiche CSS devono sempre bumpare la versione).
- Screenshot confermava: wizard step OK, weekend evidenziato OK, sab+dom selezionati OK.
### Full-width mobile + conteggio giorni (2026-06-02)
- (msg 2979) Smartphone full width: media query max-width 639px → .rb-wizard max-width 100%, padding laterale 0; .rb-card edge-to-edge (no border-radius/laterali, padding 14px 10px); head/steps/powered con piccolo padding 10px. Calendario (grid 7×1fr) ora pieno.
- (msg 2980) Riepilogo periodo mostra i giorni: "6 giu → 7 giu (2 giorni)" (PeriodDays = end-start+1).
- CSS bump → ?v=20260602c.
### Full-width fix + tasti grigi (2026-06-02, 2° screenshot)
- (msg 2982 "fasce bianche ai lati") CAUSA: breakpoint full-width era max-width:639px ma la viewport di test era ~642px → restava il `max-width:560px` centrato (bande). FIX: breakpoint alzato → full-width fino a max-width:767px (resetta max-width/margin), desktop centrato da min-width:768px.
- (msg 2983) Tasti Oggi/Domani/Weekend: grigio chiaro (#f3f4f6, testo #6b7280) se non selezionati; hover accent-light; attivo rosso pieno.
- CSS bump → ?v=20260602e.
### Mappa booking = mappa risorse (msg 2987)
- Stefano: se il merchant abilita la mappa → mostrala di DEFAULT in booking; dev'essere ESATTAMENTE la mappa risorse; verdi ok.
- Scoperto: esiste già pagina pubblica `/m/{slug}/risorse` (Risorse.razor) con la mappa vera (SVG viewBox 1000×700, scenario, disponibilità #34c759 verde). Il mio rb-map (marker %) era diverso.
- FATTO: 
  - `_mapView = Service.ShowMapInBooking` → mappa default quando abilitata.
  - Nuovo componente condiviso `Components/Booking/ResourceMapView.razor` = stesso SVG di Risorse.razor (scenario beach/cinema/garden/parking/sport/generic, risorse per forma round/rect, fill verde libera/grigio occupata/accent selezionata, classi rs-map*). Usa SelectedIds (multi-select) + OnResourceClick. Render anche decorazioni.
  - Esposte DECORAZIONI nel pubblico: nuovo `ResourceDecorationPublicDto` + `ResourcesResponse.Decorations`; endpoint GetResources fetcha shop_floor_decorations dei floor pubblici. DecoSvg semplice nel componente (albero/ombrellone/bar/piscina/casa/shape_*).
  - ResourceBooking: rb-map sostituito da `<ResourceMapView>` (passa _resources/_decorations/_mapScenario/selected/primary).
  - Verificato: endpoint lido ritorna decorations:1 (shape_roof) + 6 ombrelloni + scenario beach. Build Server+Vetrina OK, restart. Le classi rs-* già in booking.css (no bump).
- NB: Risorse.razor non ancora refactorato per usare il componente (duplica lo stesso markup; valutare per DRY). 
### Mappa: aspect-ratio + zoom + no pinch pagina (msg 2989/2990)
- (2989 "non vedo spiaggia/mare") Dati OK (scenario=beach, posizioni ok). Causa: SVG senza altezza definita (height:auto collassava). FIX: aspect-ratio:1000/700 inline sull'SVG in ResourceMapView → ora lo sfondo beach (mare+sabbia) si vede.
- (2990) Pagina prenotazione NON pinch-zoom (CSS .rb-wizard touch-action:pan-y); la MAPPA invece si ingrandisce con pulsanti +/− (rs-map-zoom; transform scale attorno al centro, zoom 1→4). Pinch nativo non implementato (no JS) — pulsanti.
- CSS bump → ?v=20260602f. Build Vetrina OK, restart.
### Scenario grigio + posizioni + pinch pagina (screenshot + msg)
- BUG scenario grigio: in Blazor `MapScenario="_mapScenario"` (param STRING) passava la stringa LETTERALE "_mapScenario", non il valore → mai "beach" → grigio. FIX: `MapScenario="@_mapScenario"` (con @). (Lezione: parametri string ai componenti richiedono @ per passare un'espressione.)
- Posizioni scenario invertite: avevo copiato da Risorse.razro (mare sopra/sabbia sotto) = CONTRARIO dell'editor. FIX: replicato ESATTAMENTE l'editor in ResourceMapView — sabbia = base #FBEFD2 su tutto, MARE in basso (#4FB0D6, battigia ondulata baseline 0.7·H) + schiuma bianca (ShoreTop 34/0/10) + "🌊 Mare" in basso; sport doghe, garden strisce+vialetto, cinema schermo, parking asfalto. Helper ShoreTop/SeaFill/BaseColor portati. (NB `<text>` va avvolto in `<g>` per Razor.)
- Pinch pagina: viewport meta `maximum-scale=1, user-scalable=no` in Book.razor HeadContent (touch-action da solo non basta per lo zoom-viewport). Zoom mappa resta via pulsanti +/−.
- Build Vetrina OK, restart. (Risorse.razro pubblica resta col suo SVG semplificato invertito — valutare se allinearla/refactor su ResourceMapView.)
TODO: verifica browser (scenario corretto + no pinch pagina + zoom mappa); allineare Risorse.razro; addons; half_day/event; uniformare tavolo. NON committato.

### NUOVA RICHIESTA GROSSA (2026-06-02 ~23:30, screenshot tipo Spiaggia.it): pagina RECAP risorsa + carrello + pagamento
Dopo aver selezionato la risorsa → pagina recap simile allo screenshot:
- Titolo risorsa + "Info utili"; banner condizione rimborso (voucher entro N giorni).
- Descrizione con "Leggi di più".
- "Allestimento" = addon con stepper (lettino/sedia/sdraio) — RIUSARE shop_resource_addons esistenti; con icone dedicate (lettino arancio, sedia regista, sdraio).
- "Totale sedute" con Min/Max (vincolo, es. 5/5).
- "Servizi inclusi".
- Breakdown prezzo: prezzo risorsa + "Costi di servizio" (fee) + "Totale per un giorno".
- Footer: "Aggiungi postazione al carrello" + "Concludi prenotazione" → pagina dati → pagamento.
- PAGAMENTO: totale anticipato / acconto / gratuito (es. tavoli ristorante).
- CONDIZIONI di prenotazione definite dalla STRUTTURA sul SERVIZIO (personalizzabili): es. "Pagamento anticipato", "Rimborsabile tramite voucher", "Orario di rimborso". Da mostrare nel recap.
DOMANDE INVIATE (prima di costruire):
1. Pagamento: gateway reale (Stripe/altro) già previsto o per ora solo stato (anticipato/acconto/gratuito) senza incasso online?
2. Carrello: più postazioni/servizi diversi insieme (multi-articolo) o una per volta?
3. Condizioni+tipo pagamento+% acconto+giorni cancellazione: li configuro sul servizio in /services (nuovi campi)?
RISPOSTE (msg 2994/2996): 1) Stripe sì. 2) carrello multi-servizio stesso shop. 3) condizioni su /services sì. A) soldi DIRETTI al merchant → **Stripe CONNECT** (account collegato per merchant). B) chiavi dopo.

### FASE 1 — config pagamento/condizioni sul servizio (FATTO + verificato 2026-06-02)
- DB shop_services + colonne: payment_mode (free|full|deposit), deposit_percent, service_fee_percent, refund_type (none|voucher), cancellation_days, min_seats, max_seats, conditions_note. NOTIFY pgrst.
- Modello BookingService esteso + costanti PaymentModes/RefundTypes.
- Editor ShopServices.razor: sezione "Pagamento e condizioni" (modalità pagamento + %acconto, costi servizio %, rimborso voucher + giorni, min/max sedute per risorse, nota). Save su insert/update.
- Build App OK, restart. PostgREST espone i campi (200), scrittura ok. Default free/none.
- Test data: ombrellone lido → payment_mode=full, fee 6%, refund=voucher, cancellation_days=2 (come screenshot).
### FASE 2 — pagina RECAP (FATTO 2026-06-02, da verificare in browser)
- ServicePublicDto + ToServiceDto espongono payment_mode/deposit_percent/service_fee_percent/refund_type/cancellation_days/min_seats/max_seats/conditions_note. Verificato: ombrellone DTO = full/6%/voucher/2gg.
- ResourceBooking: nuovo step Recap (tra Resource e Customer). Mostra: nome+data, descrizione servizio, ALLESTIMENTO (addon non inclusi con +/− stepper, icone AddonIcon lettino🛏️/sdraio🏖️/sedia🪑/ombrellone⛱️, totale sedute + min/max), SERVIZI INCLUSI (addon included), BREAKDOWN prezzo (risorse×giorni + costi servizio% + Totale + acconto se deposit), box CONDIZIONI generato (Pagamento anticipato/acconto, Rimborso voucher+giorni / non rimborsabile, nota). Validazione min/max sedute nel passaggio. Addon passati alla reserve (ResourceReserveRequest.Addons).
- _addons/_addonQty in ResourceBooking; LoadResources carica res.Addons. CSS rb-desc/rb-sub/rb-addon-row/rb-stepper/rb-seats/rb-inc/rb-breakdown*/rb-cond* in booking.css. Bump ?v=20260602g. Build OK, restart server+vetrina.
- NB: footer recap per ora ha solo "Continua"→Dati; "Aggiungi al carrello" arriva in F3.
### FASE 3 — carrello multi-servizio (FATTO 2026-06-03, da verificare browser)
- Modello `CartItem`/`CartAddon` (Components/Booking/CartItem.cs).
- ResourceBooking: rimosso step Customer interno; selezione risorsa SINGOLA → tap risorsa (mappa/lista) salta SUBITO al Recap (msg 3000). Recap footer: "Aggiungi al carrello 🛒" (→OnAddToCart, torna alla lista) + "Concludi" (→OnConclude, va al checkout). BuildCartItem() con servizio/risorse/date/addon/totali. (Submit/Customer vecchi resi morti, da pulire.)
- PublicBookingFlow: `_cart`, `_showCheckout`; AddToCart/Conclude/RemoveFromCart/OnCartDone; barra carrello nell'elenco servizi ("🛒 N · €tot · Vai al carrello"); render `<CartCheckout>` quando _showCheckout.
- Nuovo `CartCheckout.razor`: lista articoli (icona, nome, risorse, data, totale, rimuovi) + dati cliente (una volta) + gdpr + conferma → prenota TUTTI gli articoli (loop ReserveResourceAsync per risorsa, con addon). Totale + acconto. Se ci sono articoli a pagamento → nota "pagamento online (Stripe) in arrivo, prenotazione registrata" (F4).
- CSS cart-bar/cart-row*/tb-btn-outline. Bump ?v=20260603a. Build OK, restart vetrina 200.
- (msg 3002) Desktop: rb-wizard allargato a max-width 860px (era 560 → horror vacui) + condizioni recap su 2 colonne (.rb-conds grid). Bump ?v=20260603b. CartCheckout eredita (usa rb-wizard).
- NB: Book.razro ora usa @layout BookLayout (modificato da Stefano/linter).
TODO F4: Stripe CONNECT (incasso diretto merchant). Stefano (msg 3003) chiede come creare le chiavi → spiegate: dashboard.stripe.com, modalità Test, Developers→API keys (pk_test_/sk_test_), abilitare Connect (platform); webhook secret dopo. Attendo pk_test+sk_test da mettere in config server (non committate). Poi: sostituire la nota con pagamento reale (acconto/totale; gratuito salta). Pulire codice morto ResourceBooking (Customer/Submit/_done). Verifica browser intero flusso. NON committato.

## 2026-05-30 — Vetrina Puntify: funzionalità "Menu & Ordini" (FATTO + verificato live)
Richiesta Stefano: esporre nella vetrina che Puntify gestisce anche menu digitali e ordinazioni al tavolo/postazione (es. lidi) + ordini ritiro/asporto, tutto nel pacchetto standard; rivedere e integrare tutte le pagine.
FATTO:
- Nuova pagina `Puntify.Vetrina/Pages/Menu.razor` (route `/menu` + `/{Lang}/menu`), stile pagina Prenotazioni, riusa `css/prenotazioni.css` (classi bkg-*). Sezioni: hero, 6 feature (menu digitale, ordine tavolo, ordine postazione/lidi, ritiro/asporto, servizi+prodotti, tutto incluso), how-it-works 4 step, sectors 8 pill, CTA.
- Header.razor: voce mega-menu "Menu & Ordini" (/menu) + icona `menu`.
- Home.razor: 4ª card prodotto "Menu & Ordini" (griglia ora `sm:grid-cols-2 lg:grid-cols-4`), voce Home_Pricing_Incl6, rewording Home_ProductsTitle/Desc (non più "tre strumenti").
- Prezzi.razor: Prz_Feat8 + riga confronto Prz_Cmp8.
- FAQ.razor: categoria "Menu & Ordini" + 5 Q&A (Faq_Men1-5).
- i18n: 71 chiavi nuove tradotte in TUTTE e 10 le lingue (default,it,en,es,fr,pt,ar,bn,hi,zh) — XML valido tutti.
- Build OK, restart `puntify-vetrina.service` (porta interna 127.0.0.1:8003). Verificato live: /it/menu e /en/menu 200, zero chiavi non risolte; Home/Prezzi/FAQ integrati.
NOTA: pagine feature precedenti (Prenotazioni/Nemi) erano tradotte solo IT+EN+default; questa Menu è tradotta in tutte le lingue (regola Stefano).

### FASE 4 cross-sell servizi nell'APP — FATTO + verificato live (2026-05-30)
Richiesta Stefano: "includi nell'app anche la fase di cross sell se manca".
- Server `IBookingService`/`BookingServiceImpl.GetServiceSuggestionsAsync(shopId, selectedIds, max=2)`: co-occorrenza su `booking_service_items` (servizi prenotati insieme), fallback ai più prenotati del negozio, fallback finale per sort_order; esclude i selezionati; solo servizi attivi; try/catch → lista vuota.
- Endpoint pubblico `GET /api/public/merchants/{slug}/service-suggestions?serviceIds=csv&serviceId=&max=` (PublicBookingController), mappa a ServicePublicDto, max clamp 1-4.
- Client Vetrina `BookingPublicService.GetServiceSuggestionsAsync`.
- UI: `ServiceStep.razor` nuova sezione "Spesso aggiunti insieme" (param Suggestions, mostra max 2 non selezionati, riusa RenderServiceCard → tap = OnToggleService). `PublicBookingFlow.razor`: campo `_suggestions`, `ToggleService` ora async chiama `RefreshSuggestions()` (fetch endpoint sui selezionati). CSS `.service-suggestions*` in booking.css.
- NOTA tabella: il link booking↔servizio è `booking_service_items` (NON booking_services). Definizioni servizi in `shop_services`.
- Build Server+Vetrina OK (0 errori). Restart puntify-server + puntify-vetrina (server 127.0.0.1:8001, vetrina 8003).
- VERIFICA LIVE su shop reale `barbiere-classico-testaccio-roma`: "Piega seta"→[Piega cosmetica, Taglio donna]; "Taglio donna"→[Piega seta, Piega cosmetica]; combo 2 servizi→[Piega cosmetica + popolare], esclude i selezionati; nessuna selezione→3 più prenotati. Ranking co-occorrenza+fallback corretto.
- NON committato (Stefano non l'ha chiesto). Modifiche in working tree.

## 2026-05-30 — VERIFICA STATO (codice reale, note sotto erano stale)
Controllato il repo /home/progetti/puntify (master):
- Fase 1, Fase 2 ✅ committate.
- Fase 3 cascata ✅ FATTA: `BookingServiceImpl.GetSlotsAsync(shopId, IReadOnlyList<Guid> serviceIds, ...)` costruisce servizio sintetico (Duration=Σ, buffer primo/ultimo); serviceIds in PublicBookingFlow/BookingDtos/PublicBookingController.
- Recensioni ✅ FATTE ed estese: `Punto.Shared/Models/Review.cs` (rating_shop, rating_operator, rating_ambiente, rating_pulizia, commento, foto), pagina `Puntify.Vetrina/Pages/Recensione.razor`, sezione in Merchant.razor.
- Lavoro nuovo non tracciato qui: Risorse / Planimetria / Mappa risorse (molti commit recenti su master).
- Fase 4 cross-sell servizi: NON presente (nessun endpoint service-suggestions). → resta backlog, in attesa conferma scope da Stefano.

## 2026-05-29 — Treatwell-style home + recensioni (FATTO — vedi verifica 2026-05-30 sopra)
Ordine sezioni Treatwell (salone): Hero(nome+Prenota+rating+nrecensioni+foto) → Info/orari → Servizi evidenziati → Lista servizi → Recensioni(media,totale,filtri,singole con autore/data+operatore) → Team(operatori) → Amenità → Orari completi.
PIANO HOME (Merchant.razor): Hero con rating → Info/orari → Servizi(anteprima+link menu) → Recensioni → Staff → Fedeltà.
RECENSIONI: legate a prenotazione Puntify completata, voto LOCALE + OPERATORE + commento. Domande a Stefano: (1) solo chi ha prenotazione completata via link email post-appuntamento? (2) stelle 1-5 locale+operatore+commento? (3) pubblicazione immediata o approvazione merchant?
PIANO DB previsto: tabella reviews (id, shop_id, booking_id, operator_id, customer_name/id, rating_shop, rating_operator, comment, status, created_at) + token recensione su booking; endpoint pubblici submit/get; aggregati (media+count) per hero e sezione; sezione Recensioni in Merchant.razor + anchor #recensioni (nav menu già linka lì).

### msg 3298/3299 FATTO+DEPLOY (planning)
- 3298a URL vista: /booking/{giorno|settimana|planning}. BookingHub: _agendaViews mappano a sezione "agenda" + AgendaView→BookingAgenda.InitialView. BookingAgenda: SetView naviga (replace) + _appliedView guard; OnInitialized/OnParametersSet applicano la vista da URL.
- 3298b summary stile Stripe/Apple: .bk-plan-stats/.bk-stat card (label uppercase + valore grande, pos/warn).
- 3298c rimosso spazio sotto matrice: .agenda-card--planning min-height:0, padding-bottom:6px.
- 3299 ricerca filtra anche le risorse del planning (PlanningResources filtra _searchQuery su nome/kind/zona).
### msg 3300 IN ATTESA CHIARIMENTO: commissione non mostrata nel dettaglio appuntamento. NB: commissione Stripe (application_fee 3%+0.75 min 1€) NON è memorizzata su booking/transaction → calcolata da StripeService al checkout. Esiste anche service_fee_percent per-servizio (costi di servizio al cliente). Chiedere a Stefano QUALE commissione mostrare.

### msg 3302/3300 FATTO+DEPLOY
- 3302 popup Nuova prenotazione scelta Servizio/Risorsa: per risorsa selettore risorsa + periodo (Dal/Al) + prezzo (precompilato r.Price×giorni, modificabile). Nuovo endpoint server POST /api/booking/{slug}/manual-resource (owner auth, overlap check, total_price custom, email se email presente). BookingApiService.CreateManualResourceAsync. Default tipo "resource" nel planning. EmailHelper iniettato in BookingController.
- 3300 commissione: colonna transactions.commission_cents (migrazione 20260604_transactions_commission.sql). Popolata in StripeController (paid) e BookingServiceImpl.MarkPaidOnSiteAsync (in-loco) via IStripeService.CommissionCents (IStripeService iniettato in BookingServiceImpl). Email risorsa nominata "Kind Name" (es. Gazebo G1) in TableBookingController + manual-resource. Dettaglio agenda mostra Totale cliente / Commissione (stima o salvata) / Netto (CommissionFor helper, rispecchia 3%+0,75 min 1). Build 0 err server+app, riavviati.

### msg 3306/3307 FATTO+DEPLOY (planning)
- 3306 ricerca planning per cliente: nuovo PlanningSearchMatch (cliente nome/email/telefono OR risorsa nome/tipo/zona) + PlanningBookings (tipo+pagamento+match). PlanningResources con query mostra risorse che matchano O con prenotazione che matcha. CellBookings/PlanningTotals usano PlanningBookings. +email anche in _filteredBookings generico.
- 3307 sezione vuota sotto matrice: agenda-card--planning da width:100vw (causava overflow orizz + box vuoto) a margin -24px (annulla padding pagina). + .appointments-content/page :has(.agenda-card--planning) padding-bottom 0/12px e min-height:0.

### msg 3309 FATTO+DEPLOY: ClientDetail appuntamenti mostravano servizio sintetico+00:00 per le prenotazioni risorsa. Ora carica _resources (id→"Kind Name") e per b.ResourceId.HasValue mostra nome risorsa + periodo (singolo o dal→al·Ngiorni); appuntamenti veri invariati.

### [2026-06-10] msg 3372-3379 Puntify CAT
- 3372 FATTO+DEPLOY: PuntifyFeaturesTab.razor "Gestione tavoli"→"Gestione risorse" + descrizione "Planimetria, stato occupazione e ordini per ogni risorsa (tavoli, postazioni, sale)".
- 3375 FATTO: git commit+push master di TUTTO lo stato (area admin, pagamenti Stripe Connect/checkout, refactor Tables→Risorse, migrazioni DB). Commit 8f15b51.
- 3376 FATTO+DEPLOY: area /admin in alto a dx l'account (email·ruolo) ora è bottone cliccabile (.admin-pill-btn) → naviga a /account (ClientAccount), da cui: Cambia a negoziante / Cambia ad amministratore / Esci. Applicato in AdminTopBar.razor (tutte sottopagine) + AdminHome.razor (header proprio). CSS in admin.css (.admin-pill-btn hover accent, .admin-pill-email ellissi, .admin-pill-sep).
- 3374 IN ATTESA RISPOSTE 1-2-3 (msg 3378): servizio prenotabile = pagina a sé /merchant/shop/{id}/services/{serviceId} con tab bar (Anagrafica/Tipo/Disponibilità/Prezzo e pagamento/Media/Etichette); spostare orari-chiusure-blocchi da agenda al SERVIZIO (per-servizio, es. lido vs ristorante). Q: (1) sostituisce o default-shop sovrascrivibile? (2) dati esistenti ereditano orari shop o vuoti? (3) URL ok? DB: aggiungere service_id a booking_availability/booking_exceptions/booking_manual_blocks (oggi shop-wide; availability ha operator_id nullable, exceptions NO operator_id).
- 3377 IN ATTESA RISPOSTE A-B-C (msg 3379): sezione Fatturazione in pagina pagamenti esercente (Payments.razor /merchant/shop/{id}/payments): piano selezionato/scelta piano, metodo pagamento Stripe, elenco fatture con link Stripe, cancella piano. RICHIEDE Stripe Billing/Subscriptions = NON esiste (oggi solo Connect+checkout). Q: (A) prodotti/prezzi già su Stripe? quali piani? (B) test o live CAT? (C) UI cablata o mock prima?

### [2026-06-10] msg 3382-3384 Fatturazione (rifatta)
- Mock iniziale era in Payments.razor shop con piani Starter/Pro/Business → SBAGLIATO. Stefano: billing è PER-ACCOUNT (tutti gli shop), non per-shop; piani reali da cat.puntify.it/it/prezzi.
- MODELLO REALE: "Un piano. Prezzo per punto vendita." Tariffa per PV in base al N° totale PV dell'account: 1→9,99€/mese (99,99€/anno) per PV; 2-5→-10%→8,99 (89,99); 6+→-20%→7,99 (79,99). Annuale ≈ 2 mesi gratis. Nemi AI a consumo. (fonte: Puntify.Vetrina/Pages/Prezzi.razor:113-149).
- FATTO+DEPLOY: Payments.razor ripristinato (solo tab Configurazione/Stripe Connect, che resta per-shop). Nuova sezione "Fatturazione" in MerchantAccount.razor (dopo "Informazioni account"): toggle Mensile/Annuale, riepilogo PV reali (Supabase.GetShopperShops().Count) × tariffa con sconto, tabella scaglioni con riga corrente evidenziata, metodo pagamento mock (Visa 4242), fatture mock con link Stripe, Cancella abbonamento con modal conferma + toast. CSS .bill-* in config.css (rimosse .bill-plan*, aggiunte .bill-cycle/.bill-summary/.bill-tiers/.bill-block-label). Build OK :8002.
- IN ATTESA: validazione Stefano, poi guida creazione Prodotti/Prezzi Stripe (test) + connessione reale (Stripe Billing/Subscriptions, oggi inesistente).

### [2026-06-10] PIANO REFACTOR SERVIZI (3374) — approvato, NON ancora iniziato
Decisioni: (1) ogni servizio ha propri orari/chiusure/blocchi; shop-level = DEFAULT per servizi nuovi. (2) servizi esistenti ereditano (COPIA) orari shop attuali. (3) URL /merchant/shop/{id}/services/{serviceId}. (4) pagina servizio con tab: Anagrafica/Tipo/Disponibilità/Prezzo e pagamento/Media/Etichette (Disponibilità = orari+chiusure+blocchi del servizio). (5) orari/chiusure/blocchi shop-level si spostano in ShopEdit.razor (/edit) trasformando le sezioni in TAB.
CHOKEPOINT slot engine: BookingServiceImpl.GetSlotsForServiceAsync (BookingServiceImpl.cs:139-160) — unico punto da modificare per fetch service-scoped con FALLBACK shop (service_id IS NULL). SlotEngine.cs NON si tocca.
DB: migrazione 20260711_booking_service_scope.sql — ADD COLUMN service_id uuid NULL FK shop_services ON DELETE CASCADE su booking_availability/exceptions/manual_blocks; indici; UNIQUE availability include service_id; BACKFILL solo availability (copia righe shop-wide service_id IS NULL & operator_id IS NULL su ogni shop_services). Chiusure/blocchi NON copiati (restano shop-level via fallback).
Modelli: ServiceId su BookingAvailability/BookingException/BookingManualBlock in BookingModels.cs.
STAGE: 1 DB+modelli; 2 server slot fallback (RISCHIO ALTO, test golden slot prima/dopo); 3 BookingApiService+3 componenti (BookingSchedule/Closures/ManualBlocks) con param ServiceId?; 4 ShopEdit a tab + 3 componenti shop-level; 5 nuovo ServiceDetail.razor 6 tab + ShopServices a sola lista; 6 pulizia BookingHub (rimuove tab orari/chiusure/blocchi).
Pattern tab: bk-tabs/bk-tab + route {Tab} (vedi MerchantServices.razor:26-65).

### [2026-06-10] REFACTOR SERVIZI — STAGE 1-2-3 FATTI (server+DB+componenti)
- STAGE 1 DB: migrazione 20260711_booking_service_scope.sql APPLICATA su CAT (puntify_cat). service_id su booking_availability/exceptions/manual_blocks; indici; UNIQUE availability include service_id (vecchio constraint booking_availability_shop_id_operator_id_day_of_week_start__key droppato). Backfill: 104 righe orari copiate sui servizi (solo availability; chiusure/blocchi NO). Schema reale aveva anche resource_id (incluso nel backfill). Modelli: ServiceId? su 3 classi in BookingModels.cs.
- STAGE 2 server: BookingServiceImpl.GetSlotsForServiceAsync ora fetch service-scoped con fallback (operatorRows sempre + shop-wide del servizio se presenti altrimenti shop-level service_id null); exceptions/blocks = union shop-level + servizio. Fix anti-duplicazione su TableBookingController (schedule/closures/blocks + service_id=is.null), TakeawayBookingController (availability fallback su svc.Id + exceptions union), BookingController.SaveAvailability (+param serviceId, delete scoped service_id). Comportamento INVARIATO grazie al backfill (verificato: shop ad69804f 7 orari shop → 7 per servizio, no duplicati).
- STAGE 3 client: BookingApiService.SaveAvailabilityAsync(+serviceId). BookingSchedule/BookingClosures/BookingManualBlocks: param ServiceId? + filtro load (ServiceId match) + ServiceId su insert. Usati in BookingHub senza ServiceId → scope shop (display corretto).
- TEST: SlotEngine tests passano (87 pass; 33 fail = SocialStudioTests integrazione, preesistenti). Server buildato e UP. App in build.
- RESTANO STAGE 4-5-6 (UI): 4 ShopEdit sezioni→tab + 3 componenti shop-level (orari/chiusure/blocchi shop). 5 nuovo ServiceDetail.razor 6 tab (Anagrafica/Tipo/Disponibilità/Prezzo e pagamento/Media/Etichette) + ShopServices a sola lista. 6 pulizia BookingHub (rimuove tab orari/chiusure/blocchi). Servizi DB: puntify-server :? , app :8002, DDL via sudo docker exec ops-postgres psql -U postgres -d puntify_cat.

### [2026-06-10] REFACTOR SERVIZI — STAGE 4-5-6 FATTI (UI completa) — build 0 errori
- STAGE 5: nuovo ServiceDetail.razor (/merchant/shop/{id}/services/{serviceId}[/{Tab}]) con tab bar Anagrafica/Tipo/Disponibilità/Prezzo e pagamento/Media/Etichette. Disponibilità monta BookingSchedule+BookingClosures+BookingManualBlocks con ServiceId. Carica singolo servizio, salva via Supabase. ShopServices.razor ora SOLA LISTA: riga→naviga a ServiceDetail; "Nuovo servizio" crea bozza (IsActive=false) e apre il dettaglio. Route Guid disambigua da {Tab} di MerchantServices.
- STAGE 4: ShopEdit.razor (/edit[/{Tab}]) sezioni→tab: Anagrafica/Knowledge base/Fedeltà(se loyalty)/Immagini + Orari/Chiusure/Blocchi (montano i 3 componenti shop-level senza ServiceId). Actionbar Salva solo sui tab che editano _shop. ShowComponentToast per i componenti.
- STAGE 6: BookingHub.razor rimossi tab+case orari/chiusure/blocchi (spostati in /edit). Nessun link esterno rotto (grep ok).
- Billing CSS .bill-* in config.css; svc-disp in booking.css.
- TUTTO buildato (dotnet build Puntify.App = 0 Error, 38 warning preesistenti). REFACTOR COMPLETO stage 1-6.
- DA VALIDARE con Stefano: navigazione pagina servizio, tab Disponibilità per-servizio, orari shop in /edit, agenda senza le 3 tab.

### [2026-06-10] msg 3387-3389 Fatturazione + fix Disponibilità — FATTO+DEPLOY
- 3387: Fatturazione in MerchantAccount ora è solo una RIGA-LINK ("Gestisci fatturazione") → nuova pagina MerchantBilling.razor (/merchantAccount/fatturazione). Spostato lì tutto il contenuto (piano per-PV, metodo pagamento, fatture, cancella). Rimosso codice/markup billing inline da MerchantAccount, aggiunto GoToBilling (preserva from/shop querystring).
- 3388: nuova sezione "Periodo di prova" in MerchantBilling: Inizio=data iscrizione (account.InsertDate), Fine=inizio+1 mese+mesi bonus, stato attiva/scaduta, giorni rimanenti, "+N mesi bonus da inviti". Logica: 1 mese gratis per ogni PV invitato che si registra e inizia a pagare (mock _bonusMonths=0; da cablare con referral reali + Stripe).
- 3389 FIX: nella tab Disponibilità del servizio non si potevano inserire chiusure/blocchi perché i 3 componenti (Orari/Chiusure/Blocchi) impilati avevano ognuno la propria cfg-actionbar FISSA in fondo → si sovrapponevano (solo una cliccabile) + la actionbar pagina (Elimina) sopra. Risolto: SUB-TAB dentro Disponibilità (Orari/Chiusure/Blocchi, uno alla volta, _dispSub) + nascosta la actionbar pagina sul tab disponibilita. RLS exceptions/manual_blocks già permissiva (anon_all). Build 0 errori, app :8002 up.

### [2026-06-10] msg 3391-3394 — FATTO+DEPLOY
- 3391: cap referral a MAX 5 mesi gratuiti. MerchantBilling: const MaxBonusMonths=5, BonusMonthsCapped, testo "fino a max 5 mesi", badge "+N / 5". Vetrina: Earn_MerchRule2 + Faq_Ref2_A + Faq_Ref3_A cambiati 12→5 in TUTTE le 9 lingue (resx) + allineati i translations_*.xml (sorgente). NB: l'offerta lancio "3 mesi" (primi 300) è separata, NON toccata.
- 3392: MerchantBilling fatture, link "Apri su Stripe" → "Visualizza".
- 3393: ClientAccount (/account): "Cambia ad amministratore" spostato dentro la sezione "Cambia area di lavoro" (ora condizione Role 2/3 || _isAdmin, due bottoni dentro la stessa card; rimossa la card "Amministrazione" separata).
- 3394: Vetrina Prezzi.razor — aggiunto @rendermode InteractiveServer + toggle Mensile/Annuale (default ANNUALE, _annual=true); tabella ora con UNA sola colonna "Prezzo / PV (annuale|mensile)" che cambia col toggle.
- Build: App 0 err (riavviata), Vetrina 0 err (riavviata). Servizi: app :8002, vetrina (puntify-vetrina.service), server :? .

### [2026-06-10] msg 3396 — FAQ ordini per categorie esercenti — FATTO
- Vetrina FAQ Faq_Men3: da "Funziona per lidi e stabilimenti balneari?" a "Per quali attività funziona la gestione ordini?" con risposta che elenca TUTTE le categorie (ristoranti/trattorie/pizzerie, bar/caffetterie, pub/birrerie, gelaterie/pasticcerie, paninoteche/street food, chioschi/food truck, lidi/stabilimenti balneari, hotel/strutture ricettive) + modalità (tavolo/postazione ombrellone-lettino-cabina/ritiro-asporto). Aggiornato in tutte le 9 lingue resx (script /tmp/faq_men3.py, evitato '&' per XML). translations_*.xml NON contengono questa chiave (sottoinsieme; runtime usa resx). Build vetrina 0 err, restart.
