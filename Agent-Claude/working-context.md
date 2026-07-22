# Working context

## Task 2026-07-22 — Guard coperti pagamenti dine_in (Puntify CAT)
Regola Stefano: un dine_in pagato DEVE avere coperti definiti. Guard server aggiunto in
Puntify.Server/Controllers/MenuController.cs:
- /{orderId}/pay: dine_in && covers NULL → covers_required, ECCETTO giro-successivo di tavolo
  con master (covers not null) già confermato (query covers=not.is.null sul table_resource_id).
- /pay-table: se conto dine_in e NESSUN giro del tavolo ha covers not null → covers_required.
Build 0 errori, restart puntify-server ok (:8001 200, log puliti). Verificato su A07
(e1e804a7-... dine_in covers NULL, tavolo senza master): guard scatta.

Stato: COMPLETATO. Solo CAT, nessun commit/push.

## Task 2026-07-22 — POS Cassa: pannello coperti inline + stato vuoto (Puntify.App CAT)
File: Puntify.App/Pages/Merchant/Dashboard.razor
MOD1: rimosso div .cassa-confirm-covers dal footer conto. Conferma coperti dell'ordine in attesa
ora passa dal pulsante "Coperti" (nuovo helper OpenGuestsClick: se CassaAwaitingCoversOrder!=null ->
OpenGuestsForConfirm, altrimenti OpenGuests). GuestsConfirm reso async: in modalita' confirm, dopo
aver settato _confirmCovers, chiama ConfirmCoversSendAsync (invia in cucina). Popup auto ingresso
(MaybePromptCoversOnEntry) invariato. Gate server/CassaDineInNeedsCovers invariati.
MOD2: flag _cassaOrderStarted. Pannelli .cassa-wrap visibili solo se (CassaFocused||_cassaOrderStarted);
altrimenti stato vuoto (.cfg-empty + "Crea un ordine per iniziare" + bottone NewOrder). true in
LoadTableConto/LoadOrderIntoCassa/NoConfirmAsync/NoSelectDirectAsync/ApplyOrderRef(via load); false in
SwitchTab(cassa)/OnInitialized(cassa senza ref)/guardia reset ApplyOrderRefAsync.
Resx: cassa_empty_state aggiunta in 10 lingue (it/en/es/fr/de/nl/pl/ro/ru/uk). Bottone riusa dashboard_new_order.
Build Release 0 errori. deploy-cat-app.sh :8002 -> HTTP 200. WASM: hard-refresh lato Stefano.
Stato: COMPLETATO. Solo CAT, nessun commit/push.

## Sessione 2026-07-22 msg 7106-7139 — altri task COMPLETATI (CAT, oltre ai due sopra)
Gate coperti obbligatori prima cucina (default 0, no preset capienza); pannello sx Cassa stile Stripe
(meno rosso); clic tab Cassa = pagina vuota + ritorno "+ Nuovo ordine"; card board Ordini come template
Stefano (rosso #A07, "x min fa", "· N coperti"/"Coperti da definire", pill, badge N×, CTA scura) poi
compattate (booking.css .ord-card*); Nuovo ordine->Diretto entra in Cassa vendita diretta; correzione dato
A07 paid true->false ("da pagare"). Template card in Agent-Claude/assets/ordini-card-template*.jpg.
GOTCHA confermato: colonna tavolo reale = table_resource_id (non table_operator_id legacy).

## Task 2026-07-22 (msg 7140) — Modale coperti init 0 + auto-open (Dashboard.razor CAT)
OpenGuests draft parte da 0 se coperti non definiti (era _cassaCovers=1). GuestsConfirm draft: tolto default
v=1 indovinato (v>=1 -> set; v<1 -> non definito + toast, invio bloccato). Anti-loop nuovo draft
_coversPromptedForDraft (reset in StartNewCassaOrder). NoConfirmAsync ramo dine_in+tavolo apre OpenGuests una
volta. Diretto/takeaway/delivery esclusi. _cassaCovers default resta 1 (calcoli), ma modale mostra 0 e gate
CassaDineInNeedsCovers blocca. Build 0 err, deploy :8002. COMPLETATO.

## Task 2026-07-22 (msg 7141) — FIX bug fuso reminder prenotazioni (server CAT)
File: Puntify.Server/Services/BackgroundServices/BookingReminderService.cs. Causa: finestra reminder calcolata
in UTC reale ma start_at in DB e' wall-clock negozio marcato +00 (offset0) -> reminder "2h prima" partiva 2h
tardi (all'ora appuntamento, = scarto CEST +2). Dato reale Pepto: start_at=2026-07-22 20:30:00+00. Fix:
confronto wall-clock negozio vs wall-clock via TimeZoneHelper.NowInZone(shop.Timezone) + BookingEntry.StartLocal;
dateStr/timeStr da StartLocal. Verifica: 20:30 -> reminder 18:30. Testo "tra 2 ore" e' fisso (solo scheduling).
Build 0 err, restart puntify-server ok. COMPLETATO.
Aperti (segnalati a Stefano, NON toccati): (1) rischio DOPPIO INVIO reminder — manca colonna reminder_sent_at
+ dedup (poll 5min, finestra +-5min); serve migration. (2) incoerenza write-path: booking vocale scrive vero
UTC (TimeZoneHelper.ToUtc), booking tavolo/web scrive offset0; su CAT tutti shop Europe/Rome quindi fix regge.

## IN ATTESA / decisione aperta
- **MerchantPos (wizard /neworder, POS alternativo)**: stepper coperti default 1 (min 1). Chiesto piu' volte
  a Stefano (msg 7113/7130/7139) se allinearlo a 0/obbligo come la Cassa Dashboard o lasciare 1. Nessuna
  risposta ancora.
- **Reminder doppio invio + write-path**: chiesto a Stefano (msg 7145) se sistemare. In attesa.
- Prova reale di Stefano su tutte le modifiche (dopo Ctrl+F5) + feedback.
- Commit/push blocco Puntify solo su richiesta esplicita (WIP grosso nel working tree).

## Sessione 2026-07-22 sera — Marketing Director + schedulazione social
Stefano: post social ripetitivi, vuole un agent "Marketing Director" con responsabilita' TOTALE di diffusione
Puntify + acquisizione clienti, che decide cosa/quando. Creato:
- /home/progetti/puntify-social/planning/strategy.md + calendar.json (30gg 23/07-21/08, 10 pilastri x3,
  12 formati, nessun topic adiacente, tutti bright) + growth-plan.md (ICP automotive validato 8431 officine,
  outreach Resend, sales machine Lead Hunter/Copywriter/Sender gated/Reply Monitor, settimana-tipo, KPI).
- Runner giornaliero /home/progetti/puntify-social/skin/daily_propose.py: pesca entry calendario per DOMANI,
  genera draft (run_draft override), manda proposta a Stefano su Telegram (token da appsettings BotToken,
  chat 505161324). Cron INSTALLATO: "17 16 * * *" (18:17 IT) -> proposta per il giorno dopo. Pubblicazione
  resta gated (publish.py dopo OK Stefano). Se calendario finito -> avvisa Stefano.
- Governance: direttore decide/pianifica in autonomia; invii esterni reali (email/DM) + publish restano
  approvati da Stefano.
DECISIONE APERTA (msg 7162): Stefano contesta che le creativita' non hanno una vera "battuta stile KiRweb"
(una gag visiva/verbale). Proposte 3 gag per il post fedelta' di domani (boomerang consigliata). Se approva il
registro -> far rifare al direttore TUTTO il calendario con standard "una gag vera al giorno". In attesa scelta.
Approvazione post 23/07 ancora pendente.

## Sessione 2026-07-22 notte — Marketing Director AUTONOMO (direttiva Stefano msg 7174)
Stefano: il direttore deve essere autonomo e contattarlo DIRETTAMENTE, non attendere Claude.
- daily_propose.py ora AUTONOMO: genera + PUBBLICA su Buffer (due-at giorno 11:00Z) + informa Stefano
  diretto via Bot API (non chiede approvazione); marca entry published in calendar.json. Cron 17 16 * * *.
- director_review.sh NUOVO: cron 23 5 * * 1 (lun 07:23 IT). Lancia `claude -p` headless come Direttore
  (bypassPermissions): estende calendar.json se <10 giorni futuri, prepara batch outreach (BOZZE gated in
  planning/next-outreach-batch.md), stampa BRIEF settimanale inviato a Stefano via Bot API. claude CLI:
  /home/claudebot/.nvm/versions/node/v20.20.2/bin/claude (v2.1.195), headless testato OK.
- GATE tenuto: invii email reali a prospect solo dopo "ok" Stefano (puo' togliere con "ok outreach automatico").
- Token Telegram per gli script: appsettings BotToken (come puntify-morning-report.sh), chat 505161324.
- NOTA OPERATIVA: il server MCP plugin:telegram si e' disconnesso in sessione -> per rispondere a Stefano
  uso il fallback Bot API via curl (stesso token/chat). Se riconnette, torno al tool reply.
- Calendario: 29 giorni futuri (fino 21/08). 23/07 prenotazioni GIA' pubblicato; 24/07 fedelta' (primo giro auto).
