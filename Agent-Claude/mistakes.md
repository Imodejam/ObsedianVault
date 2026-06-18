
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
