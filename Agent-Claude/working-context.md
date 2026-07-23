# Working Context

## Sessione 2026-07-23 — Puntify CAT (Telegram, iterazione live con Stefano)

Lunga sessione di sviluppo POS su collaudo (app-cat / puntify_cat). Tutto delegato a subagent, io orchestro. Build sempre verdi. Nessun deploy prod.

### FATTO (build ok, CAT)
- POS/Configurazione: toggle servizi ordinazione + "Modalità"(toggle verde)/"Quando incassare"; tab Finestre-asporto sotto POS (asporto sorgente unica, sync booking_modes); servizio off non selezionabile.
- Scan → design cfg-page. PhotoPicker → libreria cataloghi + tag/filtro. Menu M1: mostra sempre un menu (attivo→prossimo→primo).
- Course firing: course_status jsonb, "Manda portata N" (tavolo+singolo), lock R1(portata mandata)/R5(pagato, +server order_paid), KDS hold. Clausole in puntify/docs/order-rules.md (R1-R5, M1).
- Cassa vari: coperti header=campo, popup coperti all'ingresso, gate coperti su Incassa (R4), back ingresso diretto→Ordini, header conto "Tav.·stato" (via riga #/stato/prezzo), riga Coperto (totale torna), "Portata" non crea portate vuote, via riga "Nuovo giro".
- Cassa draft: persistito in localStorage (cassa-draft.js), sopravvive al reload, pulito su invia/incasso.
- Cassa mobile: footer fisso Incassa+Invia, via "Nuovo ordine" (breakpoint 719.98px).
- IVA COPERTO country-aware: segue somministrazione ridotta (IT 10%, tabella per paese in VatRates.Catering/CoverRate), coerente conto+scontrino+archivio, totale invariato. Server riavviato.
- POS Risorse: Mappa/Griglia toggle (toolbar condivisa: day-strip sotto tab bar + riga toggle-sx/Pranzo-Cena-dx); griglia stile foto (card compatte per zona, prenotato blu/occupato rosso, sedie 4 lati=solo se sopra/sotto pieni a 4, frecce settimana nascoste mobile, no header "Altro"); mappa compatta (viewBox bbox top-align, sedie chiare, selettore Sala in flusso in alto → tavoli sotto). Search unica "cerca tavolo o prenotazione" su tutte le tab POS.
- Watchdog/run durevoli: /home/claudebot/durable-jobs (durable-run.sh via sudo systemd-run = cgroup separato, sopravvive restart claude-rc.service; durable-status.sh; hook SessionStart in ~/.claude/settings.json). Testato.

### APERTO (dipende da Stefano)
- SOCIAL POST: post sconto 2026-07-24 SCHEDULATO su Buffer per domani 13:00 (RIFIUTATO — tema+umorismo). daily_propose.py cron 16:17 pubblica in AUTONOMIA (direttiva 22/07) → da ri-gate su approvazione. Stefano vuole umorismo Taffo/KiRweb (scena concreta+twist, vedi puntify-social/planning/kirweb-study.md). Ultima proposta mia: no-show "PRENOTANO IN OTTO. SPARISCONO IN OTTO / ALMENO SONO COERENTI". In attesa che scelga headline; poi genero immagine, gliela mostro, sostituisco il post schedulato. → task #18: TOGLIERE/sostituire il post sconto PRIMA di domani 13:00 (buffer ids in posts/2026-07-24_raccolta_punti/meta.json; buffer lib NON ha delete → aggiungere mutation).
- Coperti non impostati: tengo A ("da definire"); B=default 1?
- MerchantPos.razor /neworder pagina morta: eliminare?
- Aliquote catering non-IT da validare (VatRates.Catering).

### Regole sessione
- Ogni richiesta Stefano: rispondere via tool reply Telegram (chat 505161324). Aggiornare vault + vault-sync.sh. Build prima di dire "fatto". WASM → Stefano fa Ctrl+F5.
