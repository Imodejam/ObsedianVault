# Working context

## Ultimo task (2026-07-20) — Catalogo con tipologia (feedback Stefano 6866)
Rinominare "Menu" -> "Catalogo" (etichette, non rotte) su App+Vetrina + tipologia catalogo.

### Fatto da me (foundation)
- Modello: `ShopMenu.CatalogType` (default restaurant) + costanti `CatalogTypes`
  (Restaurant/Services/Retail/Generic, .All, .IsFood()) in Punto.Shared/Models/Menu/MenuModels.cs.
- Migration `docs/DB Migrations/2026-07-20_catalog_type.sql`: ADD COLUMN catalog_type
  su puntify.shop_menus, CHECK in (restaurant,services,retail,generic), NOTIFY pgrst. Applicata a CAT (3 menu = restaurant).
- Server: CreateMenu/UpdateMenu persistono (full-model); duplicate copia CatalogType. Build+restart server OK (8001=200).

### Delegato a 2 subagent (in corso)
- A (Puntify.App): selettore tipologia catalogo in MenuEditor "dati" (card), tipo-sezione Cibo/Bevande
  SOLO se restaurant + combo ridisegnata (fondo bianco/separata, CSS in booking.css - app NON linka scoped css),
  DishEditor: titolo "Modifica prodotto" + sezioni food (kind/allergeni/dieta/caratteristiche/ingredienti)
  SOLO se restaurant, altrimenti generiche per tipologia; rename label Menu->Catalogo App (no rotte, no bottomnav).
  Build+restart puntify-app.
- B (Puntify.Vetrina): rename label Menu->Catalogo (no rotte/URL, no nav generica), resx SharedResource
  (+it.resx override), conservativo su SEO. Build+restart puntify-vetrina.

### 4 tipologie catalogo (decise, comunicate a Stefano msg 6868)
restaurant (Ristorazione/Menu, food+drink+allergeni) | services (Servizi, durata/prezzo) |
retail (Negozio, varianti/disponibilita) | generic (minimale).

## Prossimi passi
- Attendere i 2 subagent, verificare, riavvii uno alla volta.
- Report a Stefano (chat_id 505161324). Aggiornare vault + vault-sync.sh.
- In coda: commit/push blocco Puntify (solo su "committa"), remote repo vetrina Piracity, deploy prod.
