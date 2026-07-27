
## [2026-05-20] Risposta solo nel transcript dopo richiesta da Telegram
**Errore**: Su richiesta arrivata via Telegram (msg 1609) ho risposto nel transcript ma non ho chiamato `reply` su Telegram. Stefano ha dovuto sollecitare con "?".
**Correzione**: Quando il messaggio in ingresso ha `source="telegram"`, la risposta sostanziale DEVE essere inviata via `mcp__plugin_telegram_telegram__reply`. Il transcript non arriva al telefono. Memoria già nota (`feedback_telegram_always_reply.md`) — ricaduta da rispettare per ogni risposta non solo per ack.

## [2026-06-10] CSS pinnato in cache → modifiche non visibili
ERRORE: dopo modifiche a booking.css/menu-public.css, Stefano vedeva "non funziona / problema css". Causa: i <link> CSS in Puntify.Vetrina/Pages/*.razor hanno una VERSIONE pinnata (es. booking.css?v=20260604a). Il browser serve il CSS cached finché ?v= non cambia.
CORREZIONE: ad OGNI modifica di un CSS della Vetrina, BUMPARE la versione nel <link> della/e pagina/e che lo usano (Book.razor=booking.css; MerchantMenuPreview/Merchant/Recensione=menu-public.css; Risorse=booking.css).

## [2026-06-12] Task eseguito ma NON tracciato nel vault
ERRORE: gli articoli del blog Puntify (10 post in puntify.blog_posts, richiesti da Stefano il 2026-06-11) sono stati scritti e pubblicati, ma il task NON è stato registrato nel vault (niente working-context, daily, log). Alla sua domanda "hai finito?" non avevo traccia → ho dovuto ricostruire dallo stato del DB. Stefano (msg 3518): "come ti ho sempre detto tutto deve essere tracciato nel vault".
CORREZIONE: ogni task — anche se completato in fretta — va loggato in tempo reale: working-context.md (in corso) + daily + wiki/log.md a fine. Vale anche per lavori "creativi"/contenuti, non solo codice. Niente lavoro silenzioso fuori dal vault.

## [2026-06-14] Bug script normalizzazione resx → quasi-perdita testi IT (0 impatto live)
- BUG: regex-replace su SharedResource.resx con `body=m.group(2)` che puntava al gruppo ATTRS (named group conta come gruppo) non al body → ogni <value> IT sovrascritto. 2500 nodi corrotti su disco.
- IMPATTO: ZERO live (mai ricompilato col file rotto).
- RECOVERY: estratti testi originali dal binario .resources compilato pre-bug (mini-tool .NET ResourceReader→JSON) + ricostruzione resx + normalizzatore corretto. EN intatto; Home_/Faq_ stanno in it.resx.
- LEZIONE: mai regex-replace strutturale di massa su XML senza `cp .bak` prima; usare parser XML che tocca solo i .text; attenzione agli indici quando si mischiano gruppi named/positional; il binario .resources è una rete di recupero.

## [2026-06-18] Autoresponder email — tono sbagliato
Per le risposte automatiche (info@/sales@) avevo scritto in tono personale, firmando "Stefano Gitto" e promettendo "ti rispondo personalmente entro poche ore".
Correzione Stefano: una risposta automatica deve essere **impersonale** (non firmata da una persona, niente promesse personali) ma scritta in **prima persona plurale** — "è un team che risponde": "Abbiamo ricevuto", "ti ricontatteremo", "il team Puntify". Inoltre sales@ non deve assumere che il contatto cerchi solo Nemi.

## [2026-06-19] Outreach Puntify — oggetto e modello email
- ERRORE: nell'oggetto avevo messo il nome dell'officina ("...per Clerici Auto Milano"). Stefano: NON mettere il nome dell'officina nell'oggetto.
- ERRORE: il corpo non seguiva il modello canonico. Stefano ha fornito il modello ESATTO da usare (Buongiorno → "sono Stefano Gitto di Puntify, vi scrivo perché [aggancio] e vorrei proporvi..." → domanda personalizzata → paragrafo Puntify catalogo/agenda → bullet Nemi 24/7 → caso studio +8.000€ → demo 15min + 3 mesi gratis Codice Amico + app gratis → "Resto a disposizione..." → firma "— Stefano Gitto · Puntify · puntify.it · sales@puntify.it").
- CORREZIONE: oggetto fisso senza nome = "Ottimizzazione prenotazioni e assistenza 24/7 per la vostra attività". Variano solo aggancio (tipo+zona) e domanda (per categoria).

## [2026-07-05] Collaudo Puntify si rompe quando si edita il codice dal vivo (dotnet-watch hot-reload)
ERRORE/CAUSA RICORRENTE (Stefano: "non è la prima volta che capita"): i servizi di collaudo (puntify-server/vetrina/app) girano sotto `dotnet-watch`. Mentre un subagent (o io) edita il codice del server dal vivo, l'hot-reload prova ad applicare a caldo le modifiche; le "rude edit" (es. cambio forma di un tipo anonimo di un endpoint) corrompono l'assembly in memoria → `TypeLoadException: Could not load type '<>f__AnonymousType...'` → backend HTTP 500 → app WASM in **loading perenne**. Non è la VPS, non è la memoria: è l'hot-reload sul codice in modifica.
SINTOMO tipico riferito da Stefano: "app-cat in loading perenne / non riesco a usarla".
RECOVERY IMMEDIATO: `sudo systemctl restart puntify-server.service` (forza build pulita, l'errore sparisce) + hard-refresh Ctrl+F5 lato client (WASM).
CURA DEFINITIVA proposta: (a) avviare i servizi con hot-reload OFF (`dotnet watch --no-hot-reload` o `DOTNET_WATCH_RESTART_ON_RUDE_EDIT=1`) così una modifica fa restart pulito invece di corrompere a caldo; oppure (b) far lavorare i subagent su git worktree isolato e deployare solo a fine lavoro.
LEZIONE: quando delego modifiche pesanti al codice server, mettere in conto che destabilizzano collaudo finché il lavoro non è finito; avvisare Stefano e fare restart pulito a fine batch.

## [2026-06-30] REGOLA — modifiche a sistemi esterni vanno comunicate per la PROD
Stefano (msg 4629): ogni volta che modifico sistemi esterni (DB schema/ALTER, firewall, config infra, Supabase, PostgREST, cron esterni, ecc.) DEVO avvisarlo esplicitamente, perché vanno replicate anche in PRODUZIONE (prod = box separato 82.165.223.68, non gestibile da CAT).
**Perché:** errore "Invio fallito" su ordine prod nato proprio da ALTER fatte su CAT e non su prod (colonne timezone, customer_email).
**Come applicare:** dopo ogni modifica esterna su CAT → messaggio Telegram con l'SQL/comando esatto da eseguire in prod + salvare in docs/DB Migrations/.

## [2026-07-07] Errore creazione negozio: shops_ivr_code_key duplicate (sequenza disallineata)
SINTOMO: "Impossibile creare il negozio: duplicate key value violates unique constraint shops_ivr_code_key" (23505).
CAUSA: shops.ivr_code (codice IVR 5 cifre) ha DEFAULT lpad(nextval('public.shops_ivr_code_seq'),5,'0') UNIQUE. Il modello C# Shop NON manda ivr_code (Insert via Postgrest) → default DB. La SEQUENZA public.shops_ivr_code_seq era rimasta INDIETRO rispetto ai codici esistenti (58 negozi seed con codici fino a 58, seq più bassa) → nextval generava codici già usati → collisione. (Tipico dopo import/seed con codici espliciti senza avanzare la sequenza; le sequenze sono non-transazionali → i tentativi falliti l'hanno comunque avanzata.)
FIX: `SELECT setval('public.shops_ivr_code_seq', (SELECT max(ivr_code::int) FROM puntify.shops WHERE ivr_code ~ '^[0-9]+$'), true);` → sequenza oltre il max, prossimo codice libero. GOTCHA: la sequenza è in schema `public`, la tabella shops in `puntify`.
PROD: se ricapita in prod, stesso fix (riallineare la sequenza).

## [2026-07-07] ALTER TABLE senza reload schema cache PostgREST → scritture perse in silenzio
SINTOMO: Stefano attivava il toggle "Stampa biglietto al totem" nella config coda, salvava, rientrava → di nuovo OFF. Il DB restava false (updated_at fermo).
CAUSA REALE (dai log server): `Supabase UPDATE queues → 400 PGRST204: "Could not find the 'totem_print_enabled' column of 'queues' in the schema cache"`. La colonna era stata aggiunta con ALTER TABLE (migration applicata su collaudo) ma PostgREST (api-cat) aveva la SCHEMA CACHE VECCHIA → non conosceva la colonna → rifiutava PATCH/GET. Anche le letture tornavano il default false (select non includeva la colonna). AGGRAVANTE: QueueController.Create/Update ignoravano il bool di ritorno di InsertAsync/UpdateAsync → rispondevano 200 anche col fallimento → perdita SILENZIOSA (nessun errore a video, ore di confusione).
FIX: (1) `NOTIFY pgrst, 'reload schema';` sul DB puntify_cat (docker exec ops-postgres) → PostgREST rilegge lo schema. Verifica: GET PostgREST con la colonna torna 200 (prima 400); PATCH service_role scrive ok. (2) QueueController Create/Update ora propagano il fallimento (StatusCode 500 se !ok) invece di 200 fisso.
LEZIONE / REGOLA: dopo OGNI DDL (ALTER/CREATE TABLE/colonna) su un DB servito da PostgREST, RICARICARE la schema cache (`NOTIFY pgrst, 'reload schema'` o restart container PostgREST). Vale per collaudo E prod. Inserire SEMPRE questo step nel deploy delle migration (già nelle note prod, ma va eseguito davvero). Inoltre: i controller NON devono ignorare il bool di InsertAsync/UpdateAsync (niente 200 silenzioso su scrittura fallita).

## [2026-07-08] "Fatto/coperto" dichiarato senza verifica a RUNTIME (traduzione menu)
ERRORE: sulla richiesta di tradurre la pagina menu pubblica ho detto a Stefano che gli ingredienti/campi erano "già coperti" basandomi SOLO sulla lettura del codice (il subagent aveva verificato la struttura, non aperto la pagina). Aprendo il menu in ucraino c'era un MIX IT/EN/UK: dizionario etichette UiStrings incompleto per le lingue secondarie (88 vs 111 chiavi → fallback EN), badge "Best seller"/"Top" hardcoded EN, tagline/sottotitolo negozio non tradotti. Stefano (msg 5655): "Devi controllare le cose prima di dire che hai fatto".
CORREZIONE/REGOLA: NON dichiarare "fatto/coperto/funziona" per feature UI o comportamenti osservabili basandosi solo sul codice. Verificare a RUNTIME l'output reale (aprire la pagina/headless, fetch dell'endpoint col caso reale, controllare le stringhe effettive) PRIMA di riferire a Stefano. Se un subagent dice "verificato dal codice", non basta: serve il render/output reale. Vale doppio per i18n/traduzioni (coperture parziali silenziose) e per qualsiasi cosa che l'utente "vede".

## [2026-07-07] RICADUTA: risposta solo nel transcript (Telegram non ricevuto)
Ricaduta dell'errore [2026-05-20]: ho risposto alla domanda di Stefano sui provider Vapi (11labs/Claude keys) scrivendo SOLO nel transcript, senza chiamare mcp reply → Stefano "non vedo più le tue risposte". Reinviato via reply. LEZIONE (di nuovo): OGNI risposta sostanziale a un messaggio Telegram DEVE passare da mcp__plugin_telegram_telegram__reply; il testo inline NON arriva. Controllare sempre di aver chiamato il tool reply, non solo scritto.

## [2026-07-10] Sintomo "CORS / pagine senza dati" su app-cat = puntify-server in RIAVVIO
Stefano navigava app-cat e vedeva pagine vuote + in console "blocked by CORS policy: No Access-Control-Allow-Origin" + net::ERR_FAILED su /api/*. NON è un bug CORS: la config è corretta (verificato: preflight OPTIONS → 204 con access-control-allow-origin=https://app-cat.puntify.it; GET con header presente). CAUSA: il backend puntify-server era GIÙ/in rebuild perché lo stavo RIAVVIANDO ripetutamente (molti systemctl restart per applicare fix di prompt Nemi uno alla volta). Durante la finestra di restart, Caddy non ha un backend → il browser riporta l'assenza di header CORS come errore CORS.
LEZIONE/REGOLA: ACCORPARE le modifiche e riavviare puntify-server il MENO possibile, MAI mentre Stefano sta testando dal vivo. Quando compare "CORS/ERR_FAILED/pagine vuote" su collaudo, il primo sospetto è "server in restart", non la config CORS. (Collegato a [2026-06-30] e [2026-07-05] sul collaudo che si rompe con edit/restart dal vivo.)

## [2026-07-11] Falso allarme "7 lingue Vetrina indietro" — artefatto conteggio grep su resx minificati
ERRORE: per 2 giorni ho riportato (routine 9:00) che 7 lingue Vetrina erano "ferme a 3750 chiavi vs 5377 → ~1627 mancanti". FALSO. Causa: `grep -c "<data "` conta le RIGHE, ma i SharedResource.{lang}.resx sono MINIFICATI (più <data> per riga), quindi sottostimava. Conteggio reale (regex `<data name="`): tutte le 10 lingue avevano TUTTE le chiavi (0 mancanti). Il vero gap erano ~240-360 valori == italiano per lingua, ma il 95% NON traducibili (numeri, valute ~30.500€, ROI ≈11×, nomi demo Marco/Giulia, brand Instagram/Nemi Business) che restano legittimamente uguali. Frasi vere ancora da tradurre: 2-12 per lingua (quasi tutte brand/policy).
LEZIONE: per contare chiavi/entry in file strutturati NON usare grep di righe; usare un parser reale (regex sull'elemento, o XML). Verificare l'ipotesi con un secondo metodo PRIMA di riportare numeri a Stefano (già in tema "verifica a runtime"). Ho corretto Stefano (msg 5833).

## [2026-07-17] Feature spedita con save rotto per vincolo DB non aggiornato
Ho rilasciato il photo picker "Dal tuo menu" (source="catalog") senza verificare il CHECK su shop_menu_dishes.photo_source, che ammetteva solo user_upload/ai_generated/ocr -> "Save error" per Stefano. Lezione: quando una feature scrive un valore in una colonna con dominio ristretto (enum/CHECK), verificare SEMPRE il vincolo DB prima di considerarla completa. Testare il salvataggio end-to-end reale, non solo il build.

## [2026-07-17] Bind-mount di singolo file + editor che cambia inode
Editando /opt/ops/caddy/Caddyfile (montato come singolo file in ops-caddy) con perl -i, l'inode e' cambiato e il container ha continuato a vedere il vecchio contenuto (bind-mount legato all'inode originale). Lezione: per file bind-mounted singoli, editare in modo inode-preserving (tee/cp truncate) OPPURE fare docker restart del container per ri-risolvere il mount. `caddy reload` non funzionava (admin API :2019 disabilitata) -> usato docker restart.

## [2026-07-18] Diagnosi "e' la cache" sbagliata + "verificato" senza prova reale
Ho detto 2 volte a Stefano che il bug "2 giorni" prenotazione era cache/service-worker (avevo verificato che l'assembly servito conteneva i simboli del fix). In incognito il bug persisteva -> NON era cache: era un bug di fuso in DESERIALIZZAZIONE (STJ converte "+00:00" al fuso browser). Lezione: verificare col caso reale end-to-end (riprodurre il fuso del browser) PRIMA di dire "fatto"; una scheda incognito esclude la cache; leggere il JSON/dato reale, non fidarsi del solo "il codice c'e'". Vedi [[feedback_dev_verify_process]].

## [2026-07-23] Telegram: doppio poller = conflitto 409
Le disconnessioni ricorrenti del canale Telegram erano causate da DUE processi che facevano getUpdates sullo stesso bot token (@claude4imodejam_bot): il plugin ufficiale `--channels plugin:telegram` + un vecchio bridge fatto a mano `/home/claudebot/claude-tg-bot/bot.py` (service claude-tg-bot.service). Telegram permette un solo getUpdates per token -> 409, uno cade. Rimosso il vecchio bridge (obsoleto, rimpiazzato dal plugin). REGOLA: un solo consumatore per bot token; se serve un secondo bot, token diverso.

## [2026-07-23] Messaggio Telegram perso (plugin disconnessa)
- La plugin telegram MCP della sessione si e' disconnessa a meta' sessione: tool reply/react non piu' disponibili.
- Conseguenza: NON ho ricevuto notifica di un'immagine inviata da Stefano alle 12:53 (screenshot bug prenotazione) -> l'ho scoperta solo dopo, controllando ~/.claude/channels/telegram/inbox/.
- Correzione: quando la plugin cade, (a) rispondere via fallback Bot API curl (token ~/.claude/channels/telegram/.env, chat 505161324); (b) controllare periodicamente l'inbox per messaggi non notificati.

## [2026-07-26] Escape unicode in SQL: servono le parentesi
Ho sostituito un carattere accentato in una regex con `E'\uXXXX'` concatenato, ma senza parentesi:
`AND name_lower ~* 'a' || E'è' || 'b'` -> in Postgres `~*` e `||` hanno la STESSA precedenza e
associativita' a sinistra, quindi valuta `((name_lower ~* 'a') || ...)` = boolean||text -> errore
"argument of AND must be type boolean, not type text". Stefano l'ha scoperto eseguendo in PROD.
CORREZIONE: sempre `~* ('a' || E'è' || 'b')`. LEZIONE: dopo aver modificato una migration,
ESEGUIRLA/validarla (anche solo in BEGIN...ROLLBACK) prima di considerarla pronta — non fidarsi della
sola lettura. Inoltre: la migration interrotta a meta' lascia l'ambiente incompleto (mancavano le RPC).

## [2026-07-27] Agent paralleli + `git add -A` = commit che inghiottono lavoro altrui
Mentre un agent stava scrivendo i fix di sicurezza, i miei commit sull'area Android (fatti con
`git add -A`) hanno incluso i suoi file a metà lavoro e li hanno pushati. Nessun danno (il codice era
corretto e completo) ma la history e' mescolata e avrei potuto pushare codice non finito.
REGOLA: con piu' agent attivi sullo stesso repo, committare SOLO i path del proprio ambito
(`git add <path>`), mai `git add -A`; oppure serializzare i commit.

## [2026-07-27] Modifica a Punto.Shared senza riavviare il server = server "vivo" ma vuoto
Ho modificato `Punto.Shared/Services/SupabaseStatsService.cs` (filtro PV demo) mentre `puntify-server`
girava sotto `dotnet watch`. Il watch ha tentato l'hot reload, ha trovato prima un errore di
compilazione transitorio (metodo non ancora definito) e poi `IOException: Puntify.Shared.dll is being
used by another process` -> e' rimasto in "Waiting for a file to change" per ~4 ORE. Il servizio
systemd risultava `active` ma l'app dentro non girava: tutte le chiamate dati fallivano (Stefano se
n'e' accorto perche' la pagina Risorse non caricava piu').
REGOLA: dopo OGNI modifica a Punto.Shared (o a qualsiasi progetto condiviso) riavviare esplicitamente
`puntify-server` (uno alla volta, mai i 3 insieme) e VERIFICARE con una chiamata reale che risponda.
Non fidarsi del watch. Sintomo diagnostico: si svuotano TUTTE le pagine che leggono dati, non una sola.
