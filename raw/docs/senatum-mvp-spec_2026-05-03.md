# Senatum — MVP Implementation (File-based Architecture)

## Obiettivo

Implementare Senatum, una piattaforma di deliberazione per umani e agenti AI.

Senatum consente di sottoporre richieste decisionali a un “senato” composto da più LLM configurabili.  
Il sistema deve produrre sempre un output uniforme:

- decisione finale  
- motivazione  
- confidenza  
- livello di rischio  
- condizioni  
- azioni suggerite  

I voti interni NON sono rilevanti nel risultato finale.

---

## Architettura generale

Flusso:

Input → Deliberazione multi-agent → Sintesi → Decisione

Elemento chiave:

Synthesizer (Princeps Senatus)  
→ produce sempre una decisione unica.

---

## Tecnologia

Non vincolata.

Chi implementa deve scegliere lo stack più adatto, ma deve includere:

- backend API  
- frontend web  
- integrazione LLM  
- integrazione Telegram  
- persistenza dati file-based  
- supporto Docker  

---

## Persistenza dati (MVP)

Per l’MVP usare file Markdown come database.

### Struttura directory

/data   /requests   /decisions   /senators   /providers   /contributions   /audit

---

## Regole file Markdown

Ogni file .md deve avere:

1. Frontmatter YAML → dati strutturati  
2. Contenuto Markdown → leggibile  
3. Blocchi JSON → payload e output  

---

## Input universale

json {   "request_id": "uuid",   "source": "telegram | api | mcp",   "actor": {     "type": "human | agent",     "id": "string"   },   "domain": "string",   "intent": "validate | decide | review | compare | approve | diagnose",   "title": "string",   "context": "string",   "payload": {},   "constraints": [],   "expected_output": {     "decision_required": true,     "allowed_decisions": [       "APPROVED",       "REJECTED",       "APPROVED_WITH_CONDITIONS",       "NEEDS_MORE_INFO"     ]   } } 

---

## Output universale

json {   "request_id": "uuid",   "status": "COMPLETED | FAILED | NEEDS_MORE_INFO",   "decision": "APPROVED | REJECTED | APPROVED_WITH_CONDITIONS | NEEDS_MORE_INFO",   "motivation": "string",   "confidence": 0.0,   "risk_level": "LOW | MEDIUM | HIGH",   "requires_human_confirmation": false,   "conditions": [],   "suggested_actions": [],   "data": {},   "audit": {     "models_used": [],     "created_at": "ISO-8601"   } } 

---

## Processo deliberativo

1. Ricezione richiesta  
2. Invio ai senatori (escluso Synthesizer)  
3. Raccolta contributi  
4. Salvataggio /contributions  
5. Invio al Synthesizer  
6. Produzione decisione finale  
7. Salvataggio /decisions  
8. Audit log  

---

## Senatori

Ogni senatore è configurato tramite file .md.

Ruoli suggeriti:

- Architect  
- Security  
- Product  
- Cost  
- UX  
- Legal  
- Critic  
- Synthesizer (obbligatorio)  

---

## Output senatori

json {   "recommendation": "APPROVED | REJECTED | APPROVED_WITH_CONDITIONS | NEEDS_MORE_INFO",   "summary": "string",   "risks": [],   "conditions": [],   "confidence": 0.0,   "risk_level": "LOW | MEDIUM | HIGH" } 

---

## Regole Synthesizer

- Deve produrre sempre una decisione unica  
- Non deve fare media matematica  
- Deve valutare i trade-off  
- Deve rispettare contesto e vincoli  
- Deve produrre motivazione chiara  
- Può usare NEEDS_MORE_INFO solo se necessario  

---

## UI richiesta

### /decisions
- lista decisioni  
- filtri  
- badge stato  

### /decisions/{id}
- dettaglio completo  
- motivazione  
- condizioni  
- azioni  
- debug collassabile  

### /requests/new
- creazione richiesta  

### /configuration
- gestione senatori  
- gestione provider  

---

## Telegram Bot

Comandi:

/new /status /decision /debug

Output:

🏛️ Senatum — Decisione  Decisione: APPROVED Motivazione: ... Rischio: LOW Confidenza: 0.91

---

## Sicurezza

- NON salvare API key in chiaro  
- usare riferimenti:

yaml api_key_ref: OPENAI_API_KEY 

- usare environment variables  

---

## Requisiti tecnici

- retry LLM  
- gestione timeout  
- logging  
- fallback su errori  
- no chain-of-thought salvato  
- Docker ready  

---

## MVP Deliverable

Deve essere possibile:

1. creare richiesta  
2. deliberare  
3. ottenere decisione  
4. salvare su file  
5. visualizzare UI  
6. usare Telegram  
7. usare API  

---

## Posizionamento

Senatum NON è una chat multi-AI.

È:

un sistema di decision-making orchestrato per umani e agenti AI.