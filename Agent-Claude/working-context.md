# Working Context

## Fatto (2026-07-19): Marketing FASE-1 backend Puntify (EMAIL)
CONSEGNATO (no commit). Vedi report finale. Bug trovato+risolto in test: rewards_minpoints_check(>0) bloccava marketing_voucher(minpoints=0) -> sostituito con rewards_minpoints_by_kind (voucher>=0, loyalty>0) nella migrazione voucher.

## Prossimi passi
- Frontend agent: costruire UI su endpoint api/shop/{shopId}/marketing/* (vedi report per DTO/rotte).
- FASE-2: SMS reale (oggi NoopSmsSender), acquisto crediti via Stripe (oggi grant manuale).
