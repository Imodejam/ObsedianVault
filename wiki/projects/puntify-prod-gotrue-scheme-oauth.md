# Prompt per Claude (in PRODUZIONE) — aggiungere lo scheme OAuth nativo alla allow-list GoTrue

Sei un SRE prudente sul server di PRODUZIONE Puntify. Obiettivo: abilitare il login OAuth Google/Apple dell'app iOS nativa aggiungendo il redirect URL con scheme custom **`it.puntify.app://auth-callback`** alla allow-list del GoTrue (Supabase Auth) di **produzione** di Puntify. Serve perché l'app nativa usa `ASWebAuthenticationSession` e Supabase deve accettare il redirect verso quello scheme, altrimenti il login fallisce.

## Contesto (com'è fatto sul COLLAUDO, per riconoscere il pattern in prod)
- Su collaudo il GoTrue di Puntify è il container Docker **`gotrue-puntify-cat`** (immagine `supabase/auth`), definito in **`/opt/ops/docker-compose.yml`**.
- La allow-list è l'env **`GOTRUE_URI_ALLOW_LIST`**, valorizzata da una variabile in **`/opt/ops/.env`** (su collaudo: `PUNTIFY_URI_ALLOW_LIST`). Valore collaudo, a titolo d'esempio:
  `https://cat.puntify.it/*,https://api-cat.puntify.it/*,https://www.puntify.it/app,https://puntify.it/app,https://app-cat.puntify.it/**,it.puntify.app://auth-callback`
- GoTrue supporta gli scheme custom (deep link mobile) nella allow-list.

## Cosa fare in PRODUZIONE
1. **Individua** il container GoTrue di produzione di Puntify (NON quello di collaudo, NON quello di Piracity). Cerca: `docker ps` (nome tipo `gotrue-puntify` / `gotrue-puntify-prod` / simile), e trova il suo docker-compose e il file `.env` che definisce la sua `GOTRUE_URI_ALLOW_LIST` (probabilmente `/opt/ops/docker-compose.yml` + `/opt/ops/.env`, ma VERIFICA sul server di prod: la variabile potrebbe chiamarsi diversamente, es. `PUNTIFY_PROD_URI_ALLOW_LIST` o essere inline nel compose).
2. **Mostrami** (prima di modificare) il valore attuale della allow-list di prod di Puntify e conferma di aver individuato il container/variabile GIUSTI.
3. **Backup**: copia il file che modifichi (`cp .env .env.bak-AAAAMMGG`).
4. **Aggiungi** in coda alla allow-list di Puntify PROD, solo se non già presente:
   `,it.puntify.app://auth-callback`
   Non rimuovere né riordinare gli URL esistenti. Non toccare altre variabili/segreti.
5. **Ricrea SOLO** il container GoTrue di Puntify prod perché rilegga l'env, es.:
   `cd <dir-compose> && docker compose up -d --force-recreate <nome-servizio-gotrue-puntify-prod>`
   (NON fare `up -d` dell'intero stack, NON riavviare Piracity né altri servizi.)
6. **Verifica**:
   - `docker inspect <container> --format '{{range .Config.Env}}{{println .}}{{end}}' | grep GOTRUE_URI_ALLOW_LIST` → deve contenere `it.puntify.app://auth-callback`.
   - Il container GoTrue è `Up`/healthy e risponde (es. `docker logs` senza errori di boot; endpoint auth di prod raggiungibile).
   - Fai un test rapido che il login web esistente (email/password e Google via web) continui a funzionare (nessuna regressione).

## Regole di sicurezza (IMPORTANTE)
- Ambiente di PRODUZIONE: agisci con cautela, un servizio alla volta.
- Modifica SOLTANTO la allow-list del GoTrue di **Puntify prod**. Non toccare Piracity, non toccare altri env/segreti, non stampare in chiaro chiavi/segreti non necessari.
- Se non sei sicuro di aver individuato il container/variabile giusti, FERMATI e chiedi conferma a Stefano invece di indovinare.
- Recupero: se qualcosa va storto, ripristina dal backup `.env.bak-*` e ricrea il container.

## Esito atteso
La allow-list del GoTrue di Puntify PROD include `it.puntify.app://auth-callback`, il container è stato ricreato e verificato, il login web esistente non è regredito. Riporta a Stefano il valore prima/dopo e l'esito delle verifiche.
