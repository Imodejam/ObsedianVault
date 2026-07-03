# Stato revisione errori (cron giornaliero 8:00)
Firme errori GIÀ esaminati/risolti (non ri-segnalare):

## 2026-06-30 (review live + cron 07-01)
- admin_activity_log "Could not find 'Action' column" → FIX JsonPropertyName (commit 966a946)
- social_reviews deserializzazione jsonb (topics/raw/targets/metadata) → FIX converter (35c47ed)
- social_kpi_snapshots duplicate key (shop_id,snapshot_date) → FIX upsert delete+insert
- queue_take_ticket PGRST202 (param null omessi) → FIX DEFAULT NULL (già in migration)
- queue_take_ticket duplicate key idx_queue_tickets_qnum → transiente (pulizia manuale test), non bug
- queue_call_next riga-NULL su coda vuota → FIX RETURNS SETOF
- notification_queue/email_queue "Token ModuleHandle" → artefatto dotnet-watch, non bug
- [CLIENT/vetrina] "No interop methods are registered for renderer" (roadmap/coda) → transiente Blazor enhanced-nav, NON auto-fixato (framework)

## 2026-07-02 (cron 8:00)
- [CLIENT/vetrina] "Cannot send data if the connection is not in the 'Connected' State" (~236 oggi, 360 ieri) → interop Header Blazor Server (UpdateScrollState/CloseMenusOnNavigation) su circuito disconnesso (amplificato dai restart Vetrina). FIX .catch() (commit 324d2c1).
- [CLIENT/vetrina] "dots is not defined" (1×, carosello home) → residuo JS di una versione intermedia del carosello (pallini→counter); riferimento gia' rimosso dai rework successivi. Risolto, nessun `dots` nel codice attuale.

## 2026-07-03 (cron 8:00)
- [DescribeAi] Claude 400 "Your credit balance is too low to access the Anthropic API" (3×, 21:26-21:37 del 02-07) → vecchio ClaudeDishAiService su API Anthropic senza credito (riservata a Concilium). GIÀ RISOLTO: switch generazione testo a MiniMax (commit 75e675e); ultima occorrenza 21:37, nessuna dopo. ClaudeDishAiService non più registrato in DI.
- Method not found: Shop.get_KioskTotemEnabled() (2×, 09:37 del 02-07) → mismatch Puntify.Shared.dll stale durante hot-reload/deploy. Property esiste (Shop.cs:68), nessuna ricorrenza dopo 09:37 → transiente dotnet-watch, non bug.
- ModuleHandle "Token ... not valid" ancora presente (213× su notification_queue/email_queue/social_drafts/generate-photo/storico notifiche) → stesso artefatto dotnet-watch già classificato (non bug, solo su CAT/dev con watch; prod gira DLL pubblicate).
- Vetrina "Cannot send data ... Connected State" e "dots is not defined" → già coperti 02-07 (fix 324d2c1 / risolto).
- 2026-07-03: nessun error-*.log generato oggi = pulito. NESSUN bug nuovo azionabile.
