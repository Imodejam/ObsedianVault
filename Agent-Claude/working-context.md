# Working Context

## Sessione 2026-07-19 — Puntify hardening (H1-H4)
Obiettivo: fix hardening verificati in Puntify (no commit/push). Fuori scope: billing suspension gate, Stripe recurring/VAT, MerchantBilling.razor.

### Stato verifiche
- H1 Google token leak: CONFERMATO GoogleBusinessService.cs:83 + GenericOAuthProvider.cs:69,84 loggano body con token
- H2 AdminEvents email: CONFERMATO nessuna validazione email/esistenza account
- H3 OAuth state no nonce: CONFERMATO state prevedibile in GenericOAuthProvider + GoogleBusinessService
- H4a AI score NaN: da verificare (sqrt/divisioni)
- H4b sentiment constraint: nessun CHECK esistente; CAT ha valori 'positive' (EN) da test data -> normalizzare
- H4c upload magic-byte: SocialStudioController.UploadImage riceve bytes server-side (StorageController usa presigned URL, non applicabile). Riuso MenuOcrSanitizer.SniffContentType

### Approccio OAuth state (H3)
Nonce in-memory ConcurrentDictionary con TTL (pattern GodModeGrantStore) — evita migration, caveat multi-instance (attuale deploy single-instance).

### Task in corso
Implementazione fix.
