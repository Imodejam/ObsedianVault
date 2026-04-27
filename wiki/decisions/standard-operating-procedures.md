# Standard Operating Procedures (SOP) per Agenti OpenClaw

Questo documento definisce gli standard obbligatori di interazione, documentazione e gestione per tutti i sub-agenti (Carlo, Luca, Massimo, Lidia).

## 1. AVVIO SESSIONE
Ogni volta che vieni spawnato, devi:
1. Leggere `[[wiki/index.md]]` per avere la panoramica dei progetti.
2. Leggere la pagina wiki del progetto specifico su cui stai lavorando (es. `[[wiki/projects/piratopoly]]`).
3. Verificare lo stato dei task in `tasks.json`.

## 2. GESTIONE KANBAN (tasks.json)
- **Aggiornamento stato**: Muovi il task in "In Progress" quando inizi e in "Completato" solo dopo verifica reale (no falsi positivi).
- **CRITICO - Formato Commenti**: I commenti devono essere SEMPRE oggetti JSON.
  ```json
  {
    "Text": "Descrizione tecnica di cosa ho fatto",
    "Author": "NomeAgente",
    "CreatedAt": "2026-04-27T15:00:00Z"
  }
  ```
- **Validazione**: Dopo ogni scrittura, esegui: `python3 -c "import json; json.load(open('tasks.json'))"`.

## 3. GESTIONE VAULT (Memoria Persistente)
Sei responsabile di mantenere aggiornata la memoria del team:
- **Wiki**: Se crei una nuova funzionalità o prendi una decisione tecnica, aggiorna la pagina wiki del progetto.
- **Log Globale**: Appendi una riga a `[[wiki/log.md]]` per ogni task completato rilevante.
  - Formato: `## [YYYY-MM-DD] task | NomeAgente: Descrizione sintetica`
- **Sync**: Dopo ogni scrittura nel vault, esegui SEMPRE: `/home/openclaw/obsidian-vault/vault-sync.sh`.

## 4. COMUNICAZIONE
- Sii tecnico, conciso e pragmatico (stile Alfred).
- Non fare promesse: riporta fatti, errori e risultati testati.
- Se sei bloccato, spiega esattamente il motivo e fornisci i comandi per lo sblocco manuale se necessario.

## 5. REGOLE HARD
- Non toccare mai la cartella `raw/` nel vault.
- Non inventare lo stato di un progetto: se non lo sai, cercalo o chiedi ad Alfred.
- Usa esclusivamente Claude come LLM (come da istruzioni di Stefano).
