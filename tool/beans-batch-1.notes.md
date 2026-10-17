# Beans batch 1 — research notes (2026-10-17)

62 beans across 6 distinct shop names. All beans are from roasters based in the
Gatineau/Ottawa region, so `local` is true for every entry.

## Skipped shops (no beans emitted)

- **Café Vasanti** (`cafe-vasanti`) — healthy-food marketplace café (salads, hot
  buffet, sandwiches); no retail bean sales found.
- **Café Aux Trois Licornes** (`cafe-trois-licornes`) — neighbourhood café
  (coffee, sandwiches, pastries); no retail beans sold.
- **Café Mulligan** (`cafe-mulligan`) — restaurant-style café (breakfast, vegan
  lunch); no retail bean sales found.
- **Café British** (`cafe-british`) — the site is The British Hotel Restaurant &
  Pub (Aylmer); no retail coffee beans.
- **Café 3 Portages** (`cafe-3-portages`) — community café; its website shows
  only "Launching Soon", no retail beans.
- **Les Cafés Aroma Select** (`aroma-select`) — a roasting house ("Maison de
  torréfaction") with coffee categories (Café d'origine, Mélanges exclusifs,
  Espresso), but no verifiable named retail bean products with details/photos
  on aromaselect.ca; skipped per the no-invention rule.
- **Le Café Bour-Joie** (`cafe-bour-joie`) — no web presence found at all; the
  similar "Café Le Bourg-Joie" (121 Rue Maclaren E, Buckingham) is listed as
  permanently closed. No retail beans verifiable; skipped.
- **Cascara Café & Bistro (Happy Goat)** (`cascara-cafe`) — a Happy Goat café
  location (Canevas, 425 Boul Saint-Joseph); it sells/serves Happy Goat
  coffee but has no separate bean line. The Happy Goat beans are covered under
  "Maison du Café Happy Goat Coffee Company".
- **Brown Bag Coffee Roasters** (`brown-bag`) — per instructions, skipped
  (already in the catalog).

## Beans emitted per shop name

- Brulerie Aladdin (coffee.ca) — 12 beans (core "Café de Choix" range; their
  store also sells light/dark duplicates, teas and treats, excluded)
- La Brûlerie (Café La Brûlerie) (labrulerie.ca) — 12 beans
- Brûlerie Élixir (brulerieelixir.ca) — 12 beans
- Café Cloudforest (cloudforestcoffee.ca) — 6 beans (entire retail range:
  Dark, Extra Dark, Medium, Golden, Espresso, Decaf)
- Moca Loca Café Co (mocalocacafe.com) — 8 beans (entire retail range)
- Maison du Café Happy Goat Coffee Company (happygoatcoffee.com) — 12 beans
  (core retail range; trios/gift sets and espresso duplicates excluded)

## Data caveats

- **Moca Loca (all 8 beans): no `imageUrl`.** Their product pages showed no
  verifiable per-product photo in the fetch (the catalogue page only shows a
  generic bag image). Fields omitted rather than guessed.
- **La Brûlerie — "Parfum des Andes":** the site literally says "Description à
  venir!". Included (name + roaster + photo verifiable) with a placeholder
  description; revisit when their site fills it in.
- **Moca Loca — "Colombien Décaféiné":** their site spells it "clombien
  décaféiné" (their product URL slug is cafe-colombien-decafeine, confirming
  the typo). The file uses the corrected spelling; consider matching the site
  if exact-spelling matters.
- **Roast levels for some La Brûlerie beans** (Tanzanie Peaberry, Costa Rica
  Tarrazu, Pérou Chanchamayo, Colombien Suprémo, Guatémala Antigua Équitable)
  are best-judgment from their generic roast-bag imagery and descriptions,
  not explicit on the site.
- **Happy Goat — Colombia Finca San Gabriel** is explicitly marked "LIGHT
  ROAST" on their site; notes taken from their capitals line
  ("CRISP / RASPBERRY JAM / RICH & SWEET").
- **Élixir "Costa Rica Honey process"** is listed as limited quantity / limited
  time; it may disappear from their store.
- **La Brûlerie — "Éthiopie Guji GR1 Naturel"** is listed as limited time
  ("Pour une durée limitée"); may rotate out.
- **La Brûlerie (Gatineau, 69 Boul Saint-Joseph)** is unrelated to
  boutique.cafedelabrulerie.com (Granby, QC) — beans were taken only from
  labrulerie.ca.
- **Moca Loca** also has two addresses in the shop list (Taché + Gappe); one
  bean set was emitted under the first id (`moca-loca-tache`) with
  whereToBuy "Moca Loca Café Co".
