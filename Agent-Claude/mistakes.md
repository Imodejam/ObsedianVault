
## [2026-05-20] Risposta solo nel transcript dopo richiesta da Telegram
**Errore**: Su richiesta arrivata via Telegram (msg 1609) ho risposto nel transcript ma non ho chiamato `reply` su Telegram. Stefano ha dovuto sollecitare con "?".
**Correzione**: Quando il messaggio in ingresso ha `source="telegram"`, la risposta sostanziale DEVE essere inviata via `mcp__plugin_telegram_telegram__reply`. Il transcript non arriva al telefono. Memoria già nota (`feedback_telegram_always_reply.md`) — ricaduta da rispettare per ogni risposta non solo per ack.
