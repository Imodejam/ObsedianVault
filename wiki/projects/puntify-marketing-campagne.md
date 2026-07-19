# Puntify — Catalogo campagne marketing preconfigurate

Stato: 14 campagne PROPOSTE a Stefano il 2026-07-19 (msg 6737), in attesa di OK per costruirle. Base tecnica Marketing FASE-1 (email) gia' su CAT: tipi campagna nel codice finora solo `manual | scheduled | birthday | flash` (Campaign.cs:21). Il catalogo qui sotto e' la roadmap dei preset da implementare.

Convenzioni: **Auto** = parte da sola; **Nemi** = proposta da Nemi, invio SOLO dopo approvazione Stefano/esercente; **Manuale** = lanciata a mano. Tutte consenso-gated (account_profiles.consent_email_promo) + isolate per negozio (RLS) + suppression per opt-out. Automatismi SPENTI di default, l'esercente li accende dalla sua area.

## Universali (ogni categoria)
1. **Compleanno -10%** — avviso 10gg prima, voucher valido 15gg (configurabile), 1/anno. [Auto] — GIA' FATTA
2. **Benvenuto / prima visita** — voucher al primo acquisto dopo iscrizione. [Auto]
3. **Riattivazione (win-back)** — cliente inattivo da 60gg (configurabile): "ci manchi" + incentivo. [Auto]
4. **Anniversario iscrizione** — 1 anno dal primo acquisto, premio fedelta'. [Auto]
5. **Quasi premio** — "sei a 80/100 punti": spinta al riscatto. [Auto]
6. **Chiedi recensione** — post visita/servizio, grafica step-by-step (riusa flusso Recensione). [Auto]
7. **Porta un amico (referral)** — bonus a chi porta un cliente nuovo. [Manuale]
8. **Offerta flash orari morti** — su previsione bassa affluenza (LowTrafficAnalyzer). [Nemi] — GIA' FATTA
9. **Premio/punti in scadenza** — promemoria prima della scadenza. [Auto]

## Per categoria esercente
10. **Ristorazione** — "Weekend a tavola / pranzo infrasettimanale": promo su fasce deboli. [Nemi/Manuale]
11. **Bar-Caffe'** — "Colazione fedelta' / Happy hour": incentivo fascia mattino o aperitivo. [Manuale]
12. **Parrucchiere-Estetista** — richiamo appuntamento periodico (dopo 4-6 settimane) con prenotazione diretta. [Auto]
13. **Retail-Negozio** — "Anteprima saldi VIP / svuota magazzino": accesso anticipato ai fedeli. [Manuale]
14. **Palestra-Servizi ricorrenti** — promemoria rinnovo/scadenza abbonamento con offerta. [Auto]

## Note implementazione
- Compleanno (#1) e Flash orari morti (#8) gia' costruite in FASE-1. Le altre 12 sono da fare dopo OK Stefano.
- Le [Auto] trigger-based servono un scheduler (CampaignSchedulerService gia' esiste per il compleanno; estendere a inattivita'/anniversario/scadenze/milestone/recensione/richiamo-appuntamento).
- Le [Nemi] passano dal gate proposte + approvazione (NemiMarketingProposalService, anti-auto-send blindato).
- Dati gia' disponibili: birth_day/birth_month (compleanno), transactions (inattivita'/anniversario/milestone), bookings (richiamo appuntamento), rewards/account_reward (scadenze/quasi-premio).
