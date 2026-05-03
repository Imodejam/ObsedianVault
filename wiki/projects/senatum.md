# Senatum

Piattaforma di deliberazione multi-agent per umani e agenti AI. Le richieste decisionali vengono inviate a un "senato" composto da più LLM con ruoli distinti; un **Synthesizer (Princeps Senatus)** produce una decisione finale unica con motivazione, confidenza, livello di rischio, condizioni e azioni suggerite.

**Sorgente specifiche:** [[../../raw/docs/senatum-mvp-spec_2026-05-03|Spec MVP del 2026-05-03]] (immutabile).

## Stato
- [2026-05-03] Specifiche ricevute da Stefano via Telegram. Piratopoly messo in pausa per dare priorità a Senatum.
- [2026-05-03] **MVP scaffold completo** in `/home/progetti/senatum/` — 59 file, 1 commit (`c549677`). Componenti: monorepo npm workspaces, packages/shared (zod schemi), apps/api (Fastify + storage markdown + Anthropic + orchestrator), apps/web (React + Vite + Tailwind, 4 pagine), apps/bot (telegraf, 4 comandi), data/senators (7 ruoli) + data/providers/anthropic-default, Docker compose multi-stage.
- [2026-05-03] **Ambiente live**: `senatum.service` systemd attivo (user claudebot, npm run dev), Nginx `senatum.duckdns.org` con SSL Let's Encrypt valido fino al 2026-08-01 (proxy `/api/*` → 7001, `/*` → 7002). Smoke test passati: `https://senatum.duckdns.org/` HTTP 200, `https://senatum.duckdns.org/api/health` ritorna `{"status":"ok","service":"senatum-api"}`.
- [2026-05-03] **Pubblicazione open-source**: licenza MIT in repo, README aperto al pubblico. **Push GitHub bloccato**: il PAT di Stefano (Imodejam) salvato in `~/.git-credentials` ha solo accesso al repo `ObsedianVault`, non può creare nuovi repo (`Resource not accessible by personal access token`). In attesa che Stefano crei manualmente `Imodejam/senatum` (public, vuoto, no auto-init) per pushare.

## Requisiti chiave (dalla spec)

### Architettura
```
Input → Deliberazione multi-agent → Sintesi → Decisione
```
- Senatori (LLM con ruolo) producono **contributi** strutturati.
- Il **Synthesizer** è obbligatorio e produce **sempre** una decisione unica. Non fa media matematica, valuta i trade-off, rispetta contesto/vincoli.
- I voti dei senatori non sono rilevanti nel risultato finale (peso = qualità del ragionamento).

### Persistenza file-based (MVP)
Tutti i dati come Markdown con frontmatter YAML + blocchi JSON in:
```
/data/
├── requests/
├── decisions/
├── senators/        # uno .md per senatore
├── providers/       # config LLM provider (no API keys in chiaro!)
├── contributions/   # output dei singoli senatori per richiesta
└── audit/
```

### Senatori — ruoli suggeriti
Architect · Security · Product · Cost · UX · Legal · Critic · **Synthesizer (obbligatorio)**.

### Input universale
```json
{
  "request_id": "uuid",
  "source": "telegram | api | mcp",
  "actor": { "type": "human | agent", "id": "string" },
  "domain": "string",
  "intent": "validate | decide | review | compare | approve | diagnose",
  "title": "string",
  "context": "string",
  "payload": {},
  "constraints": [],
  "expected_output": {
    "decision_required": true,
    "allowed_decisions": ["APPROVED","REJECTED","APPROVED_WITH_CONDITIONS","NEEDS_MORE_INFO"]
  }
}
```

### Output universale
```json
{
  "request_id": "uuid",
  "status": "COMPLETED | FAILED | NEEDS_MORE_INFO",
  "decision": "APPROVED | REJECTED | APPROVED_WITH_CONDITIONS | NEEDS_MORE_INFO",
  "motivation": "string",
  "confidence": 0.0,
  "risk_level": "LOW | MEDIUM | HIGH",
  "requires_human_confirmation": false,
  "conditions": [],
  "suggested_actions": [],
  "data": {},
  "audit": { "models_used": [], "created_at": "ISO-8601" }
}
```

### Output per singolo senatore
```json
{
  "recommendation": "APPROVED | REJECTED | APPROVED_WITH_CONDITIONS | NEEDS_MORE_INFO",
  "summary": "string",
  "risks": [],
  "conditions": [],
  "confidence": 0.0,
  "risk_level": "LOW | MEDIUM | HIGH"
}
```

### UI richiesta
- `/decisions` — lista con filtri e badge stato
- `/decisions/{id}` — dettaglio (motivazione, condizioni, azioni, debug collassabile)
- `/requests/new` — creazione richiesta
- `/configuration` — gestione senatori e provider

### Telegram bot
Comandi: `/new`, `/status`, `/decision`, `/debug`. Output formattato:
```
🏛️ Senatum — Decisione
Decisione: APPROVED
Motivazione: ...
Rischio: LOW
Confidenza: 0.91
```

### Sicurezza
- API key **mai** in chiaro nei file. Usare `api_key_ref: OPENAI_API_KEY` come puntatore a env.
- `.env` non committato.

### Requisiti tecnici
- Retry LLM, gestione timeout, logging, fallback su errori.
- **No chain-of-thought salvato** (privacy + costo storage).
- Docker ready (compose).

## Stack proposto (da confermare con Stefano)
- **Backend:** Node.js 20 + TypeScript + Fastify (più leggero di Express, OpenAPI nativo). Oppure Express se Stefano preferisce coerenza con Piratopoly.
- **Frontend:** React 18 + TypeScript + Vite + TailwindCSS (coerente con Piratopoly).
- **LLM:** Anthropic SDK (Claude Sonnet/Opus) come senatore di default; provider plugabili (OpenAI, Gemini) via interfaccia comune.
- **Telegram:** [`telegraf`](https://telegraf.js.org/) o `node-telegram-bot-api`.
- **Persistenza:** filesystem + `gray-matter` per parsare frontmatter YAML.
- **Containerizzazione:** docker-compose con servizi `api`, `web`, `bot`, volume condiviso `/data`.

## Architettura proposta
```
senatum/
├── apps/
│   ├── api/          # backend Fastify (HTTP + orchestrazione deliberazione)
│   ├── web/          # frontend React/Vite
│   └── bot/          # telegram bot (telegraf)
├── packages/
│   └── shared/       # tipi Input/Output, schema senator, validators (zod)
├── data/             # storage markdown (volume Docker)
├── docker-compose.yml
└── README.md
```

## TODO MVP (alta-livello)
- [ ] Conferma stack con Stefano
- [ ] Setup repo + workspaces npm + Docker
- [ ] Schemi `shared` per Input/Output universali (zod)
- [ ] `api`: endpoints `POST /requests`, `GET /requests/:id`, `GET /decisions`, `GET /decisions/:id`, `POST /senators`, `POST /providers`
- [ ] Orchestrator: invio in parallelo ai senatori, raccolta contributi, invio al Synthesizer, persistenza
- [ ] LLM provider abstraction con retry/timeout
- [ ] `web`: tre pagine principali + configuration
- [ ] `bot`: comandi Telegram + formattazione output
- [ ] Audit log append-only

## Aperto / da decidere con Stefano
- Stack definitivo (Fastify vs Express; libreria Telegram).
- Dove vive il repo: `/home/progetti/senatum/`?
- I senatori "default" (file Markdown già pronti) li scrivo io o vuole farlo lui?
- Sequencer dei senatori: parallelo (più veloce, costoso) o sequenziale (più economico, può ottimizzare)?
- Come autenticare le richieste API e Telegram? (Telegram bot ha già allowlist via `/telegram:access`; API: token bearer? RBAC?)
- Quali provider LLM al lancio? Solo Anthropic, o anche OpenAI/Gemini?
- Limiti utente (rate limit, max richieste/giorno)?
