# Concilium

Piattaforma di deliberazione multi-agent per umani e agenti AI. Le richieste decisionali vengono inviate a un "senato" composto da più LLM con ruoli distinti; un **Synthesizer (Princeps Senatus)** produce una decisione finale unica con motivazione, confidenza, livello di rischio, condizioni e azioni suggerite.

**Sorgente specifiche:** [[../../raw/docs/concilium-mvp-spec_2026-05-03|Spec MVP del 2026-05-03]] (immutabile).

## Stato
- [2026-05-03] Specifiche ricevute da Stefano via Telegram. Piratopoly messo in pausa per dare priorità a Concilium.
- [2026-05-03] **MVP scaffold completo** in `/home/progetti/concilium/` — 59 file, 1 commit (`c549677`). Componenti: monorepo npm workspaces, packages/shared (zod schemi), apps/api (Fastify + storage markdown + Anthropic + orchestrator), apps/web (React + Vite + Tailwind, 4 pagine), apps/bot (telegraf, 4 comandi), data/senators (7 ruoli) + data/providers/anthropic-default, Docker compose multi-stage.
- [2026-05-03] **Ambiente live**: `concilium.service` systemd attivo (user claudebot, npm run dev), Nginx `concilium.duckdns.org` con SSL Let's Encrypt valido fino al 2026-08-01 (proxy `/api/*` → 7001, `/*` → 7002). Smoke test passati: `https://concilium.duckdns.org/` HTTP 200, `https://concilium.duckdns.org/api/health` ritorna `{"status":"ok","service":"concilium-api"}`.
- [2026-05-03] **Pubblicazione open-source**: licenza MIT in repo, README aperto al pubblico. **Push GitHub bloccato**: il PAT di Stefano (Imodejam) salvato in `~/.git-credentials` ha solo accesso al repo `ObsedianVault`, non può creare nuovi repo (`Resource not accessible by personal access token`). In attesa che Stefano crei manualmente `Imodejam/concilium` (public, vuoto, no auto-init) per pushare.
- [2026-05-03] Editor senatori in UI (`/configuration?tab=senators`): commit `f17422a`. Backend `GET /senators/:id`, `DELETE /senators/:id` con guardia "ultimo Synthesizer enabled".
- [2026-05-03] Editor provider in UI (`/configuration?tab=providers`): commit `bc89eac`. Backend `GET /providers/:id`, `DELETE /providers/:id` con guardia anti-orphan (rifiuta se ci sono senatori enabled che lo usano, HTTP 409 con elenco IDs).
- [2026-05-03] Layout responsive su tutte le pagine: commit `9a1ceca`. Header stack su mobile, nav scroll-x, grids 1→2 col, ids `break-all`.
- [2026-05-03] Provider kinds CLI (`claude-code`, `openai-codex`): commit `fb68173`. Subprocess spawn, parse JSON envelope di Claude Code, raw stdout per Codex; auth via login del binary (es. `~/.claude/`); api_key_ref opzionale per CLI; warning UI sui ToS dei subscription consumer (Stefano: "open source, ognuno usa come vuole").
- [2026-05-03] **Rebrand Senatum → Concilium** (commit `792ed2e`, merged con auto-init di github.com/Imodejam/Concilium come `4a9c83f`): rinominata directory `/home/progetti/concilium/`, packages `@concilium/{shared,api,web,bot}`, terminologia "Senator → Counselor / Praeses Concilii", `data/senators/` → `data/counselors/`, schema file `senator.ts → counselor.ts`. Tradotti in inglese: tutta UI web, bot Telegram, prompt orchestrator + Synthesizer, prompt di default dei 7 counselors, README, PLAN. Stefano: "facciamo Concilium" via Telegram. Nuovo dominio target: `concilium-cat.duckdns.org` (in attesa setup duckdns + nginx + certbot). Vecchio `senatum.duckdns.org` ancora puntato al vecchio nome — da dismettere.
- [2026-05-03] **systemd**: `senatum.service` rimosso, sostituito con `concilium.service` (stesso user claudebot, WorkingDirectory `/home/progetti/concilium`, SyslogIdentifier `concilium`). Live: API HTTP 200 su :7001, web 200 su :7002.
- [2026-05-03] **Push GitHub Concilium ancora bloccato**: il PAT di Stefano legge OK (`ls-remote` funziona, `pull` ok) ma rifiuta `push` (HTTP 403 "Permission denied to Imodejam"). Repo creato manualmente da Stefano con auto-init README — il mio README locale ha vinto il merge (strategy `-X ours`). In attesa che Stefano aggiorni lo scope del PAT (fine-grained: aggiungere `Imodejam/Concilium` con Contents Read+Write; classic: scope `repo` full).

## Architettura proposta — separazione Praeses / Synthesizer (2026-05-03, in discussione, NON implementata)

Stefano (via Telegram, msg 764) ha proposto di separare in due ruoli distinti quello che oggi nel codice è un'unica entity (`role: synthesizer`):

1. **Praeses Concilii** — orchestratore. Decide quali counselor convocare, costruisce i prompt, gestisce i round, evidenzia conflitti, applica policy (sicurezza, costi). **NON decide**.
2. **Synthesizer / Princeps** — decisore. Riceve i contributi dei counselor + il "conflict report" del Praeses, decide, produce l'output finale standard.

**Why (Stefano):** se uniti perdi controllo sulla discussione, qualità inferiore, no scalabilità. Separati abilitano logiche multi-round, escalation, swap del modello decisionale, policy dichiarative.

**Mappatura sull'attuale codice:**
- Oggi `apps/api/src/orchestrator/deliberate.ts` è codice deterministico che fa già il lavoro del Praeses (sceglie il Synthesizer, lancia counselor abilitati in parallelo, passa il batch al Synthesizer).
- Quel codice diventa lo *scheletro* del Praeses; il Praeses può essere potenziato con un LLM che decide adattivamente *quali* counselor convocare e *come* aggregare i conflitti prima della sintesi.
- Il file `data/counselors/synthesizer.md` resta (è il decisore Princeps). Va aggiunto un Praeses (in `data/praeses.md` o cartella separata `data/orchestrator/`).
- Schema `CounselorConfig.role` va esteso con `praeses` (oltre all'attuale `synthesizer` e ai ruoli specializzati).

**Risposte di Stefano (msg 768, 2026-05-03):**
1. **Praeses ibrido** — codice deterministico per lo scheletro (routing base, persistenza, log) + LLM per le decisioni adattive (chi convocare, come aggregare conflitti, quando rilanciare un round).
2. **Multi-round** subito (Praeses può rilanciare counselor con prompt aggiornati dopo il primo giro).
3. **Policy nel prompt del Praeses LLM** (opzione B). Niente YAML dichiarativo separato. Tutte le regole — sicurezza, costi, escalation, quando bloccare prima del Synthesizer — sono espresse in linguaggio naturale nel system prompt del Praeses, che le applica adattivamente. Trade-off accettato: meno predicibilità statica, ma flessibilità su casi nuovi e costo evolutivo basso.

**Status:** ✅ implementato 2026-05-03 (commit `57fb019`). Stefano ha dato il via con msg 770 "Implementa".

**Cosa è stato fatto:**
- Schema: aggiunto `praeses` a `CounselorRoleSchema`, nuovo `PraesesPlanSchema` (action: INVOKE/CONCLUDE/ABORT, counselors_to_invoke, rationale, conflict_report, abort_reason).
- `apps/api/src/orchestrator/praeses.ts` con system prompt che esprime tutte le policy in natural language.
- `deliberate.ts` riscritto come loop multi-round (max 3, env `MAX_ROUNDS`): Praeses → INVOKE counselor → Praeses → … → CONCLUDE (con conflict_report) → Synthesizer.
- Audit events nuovi: `praeses.invoked`, `praeses.planned`, `praeses.aborted`, `praeses.concluded`, `praeses.failed`. Counselor events ora includono il numero del round.
- Default `data/counselors/praeses.md` (claude-sonnet-4-6).
- Backend guard speculare al Synthesizer: ultimo Praeses non eliminabile.
- UI: badge purple "praeses" in CounselorsSection, nota nel form.
- README e PLAN aggiornati.
- E2E: non testato perché `ANTHROPIC_API_KEY` non è nel `.env` del server; audit log conferma comunque il flusso (praeses.invoked → praeses.failed su missing key → request.failed). Stefano deve aggiungere la chiave per testare la deliberazione completa.

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
🏛️ Concilium — Decisione
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
concilium/
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
- Dove vive il repo: `/home/progetti/concilium/`?
- I senatori "default" (file Markdown già pronti) li scrivo io o vuole farlo lui?
- Sequencer dei senatori: parallelo (più veloce, costoso) o sequenziale (più economico, può ottimizzare)?
- Come autenticare le richieste API e Telegram? (Telegram bot ha già allowlist via `/telegram:access`; API: token bearer? RBAC?)
- Quali provider LLM al lancio? Solo Anthropic, o anche OpenAI/Gemini?
- Limiti utente (rate limit, max richieste/giorno)?
