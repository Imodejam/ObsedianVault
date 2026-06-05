# Puntify — Area Admin di sistema

Stato: **pianificazione → Fase 1 (fondamenta)** · avvio 2026-06-05

## Obiettivo
Area amministrativa multi-tenant in Puntify App (`/admin`) per gestire/consultare l'intera piattaforma (clienti, esercenti, pagamenti, configurazione), sopra al modello esistente scoped-per-negozio.

## Decisioni chiave
1. **admin_users** tabella dedicata (separata da account cliente/esercente). Primo admin: Stefano.gitto@hotmail.com.
   - Login: admin-only → `/admin`; se anche cliente/esercente → area normale + tasto "Amministrazione".
2. **RBAC v1**: Super Admin (tutto), Support (clienti+esercenti R/O), Finance (pagamenti).
3. **v1 = sola consultazione** (no edit).
4. Sezioni home: Pagamenti, Clienti, Esercenti, Configurazione sistema.
5. Pagamenti: ricavi Puntify (application fee), transazioni piattaforma, payout, per-esercente, con grafici.
6. Configurazione: scaglioni application fee, feature flag, listino abbonamenti.
7. **Architettura**: tutto via endpoint SERVER (service-role + check ruolo admin), no Supabase client diretto.
8. **URL**: ricerca / dettaglio / ogni tab = route separate (vedi struttura sotto).

## Struttura URL
- `/admin` (home icone)
- `/admin/clienti` → `/admin/clienti/{id}` → `/anagrafica` `/punti` `/appuntamenti` `/transazioni`
- `/admin/esercenti` → `/admin/esercenti/{id}` (+lista PV) → `/admin/esercenti/{id}/pv/{shopId}` (+tab)
- `/admin/pagamenti` · `/admin/configurazione`

## Vincoli
- UI iper curata, ispirazione **Stripe + Apple**, responsive desktop+mobile.
- **Audit log**: ogni attività admin tracciata (chi/quando/cosa).

## Piano per fasi
- **F1 fondamenta**: tabelle `admin_users` + `admin_activity_log`; auth/role admin + routing + tasto Amministrazione; endpoint server admin (base + middleware check ruolo); shell `/admin` + home icone.
- **F2 clienti**: ricerca + dettaglio + tab (anagrafica/punti/appuntamenti/transazioni).
- **F3 esercenti**: ricerca + dettaglio + lista PV + dettaglio shop + tab.
- **F4 pagamenti**: dashboard ricavi/transazioni/payout + grafici.
- **F5 configurazione**: fee tiers, feature flag, listino.

## Prossimi passi
Attendere conferma piano → eseguire F1.
