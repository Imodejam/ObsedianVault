# Puntify — Verifica email reale (checklist per PRODUZIONE)

> Fatto su COLLAUDO il 2026-07-14 (richiesta Stefano 6122). Prod è un ambiente SEPARATO: applicare gli stessi passi sul server di produzione.

## Cosa è stato fatto su collaudo
Nel GoTrue `gotrue-puntify-cat` (`/opt/ops/docker-compose.yml`):
- `GOTRUE_MAILER_AUTOCONFIRM: "false"` (era "true").
- SMTP Resend aggiunto:
  - `GOTRUE_SMTP_HOST: smtp.resend.com`
  - `GOTRUE_SMTP_PORT: "587"`
  - `GOTRUE_SMTP_USER: resend`
  - `GOTRUE_SMTP_PASS: ${PUNTIFY_RESEND_SMTP_PASS}` (in /opt/ops/.env)
  - `GOTRUE_SMTP_ADMIN_EMAIL: noreply@puntify.it`
  - `GOTRUE_SMTP_SENDER_NAME: "Puntify CAT"`
  - `GOTRUE_MAILER_URLPATHS_CONFIRMATION: /auth/v1/verify`
- Container ricreato (`docker compose up -d gotrue-puntify-cat`).
- Trigger DB auto-approvazione (migrazione 2026-07-14_merchant_autoapprove_on_email_confirmed.sql) già presenti sul DB CAT.
- Testato: signup → email_verified false + confirmation_sent_at valorizzato, nessun errore SMTP (Resend accetta l'invio). Utente test cancellato.
- I 9 esercenti esistenti lasciati come sono (non ri-verificati), come da Stefano.

## Da applicare in PRODUZIONE (server separato)
1. Nel GoTrue di prod, impostare `GOTRUE_MAILER_AUTOCONFIRM=false` e aggiungere gli stessi 7 parametri SMTP Resend (con la **API key Resend di PROD** e un **sender verificato** sul dominio prod, es. noreply@puntify.it).
2. Ricreare il container GoTrue di prod.
3. Applicare la **migrazione dei 2 trigger** di auto-approvazione sul DB di prod (`2026-07-14_merchant_autoapprove_on_email_confirmed.sql`).
4. Verificare che il dominio mittente sia verificato su Resend (SPF/DKIM) per non finire in spam.
5. Testare un signup reale su prod (email arriva, click → confermato → esercente Approvato in automatico).
6. Verificare la UX di registrazione: dopo il signup l'utente NON può accedere finché non conferma → mostrare "controlla la tua email" (verificare MerchantRegistration).

## Note
- Con autoconfirm off, ogni nuovo iscritto deve cliccare il link prima di poter accedere. Utenti già confermati non sono impattati.
- Non mettere la Resend API key nel repo/vault in chiaro: sta in /opt/ops/.env (collaudo) e andrà in .env di prod.
