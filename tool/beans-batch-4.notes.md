# Beans batch 4 — research notes (2026-10-17)

## Skipped shops (7 of 9)

- **bluebird-coffee (Bluebird Coffee)** — Skipped. Their site (bluebirdcoffeeottawa.ca) is a single
  page with no named retail bean list (only says bags are sold in-store), and Google Business
  currently lists the café as "Permanently Closed" — conflicting status. No bean names could be
  verified without inventing them.
- **fraser-cafe (Fraser Cafe)** — Skipped. It's a New Edinburgh restaurant ("seasonal kitchen"),
  not a roaster; no retail bean offering. Also listed as permanently closed.
- **uji-cafe (Uji Café)** — Skipped. Japanese dessert/matcha café on Rideau St; no coffee-bean
  retail offering (their tea products are matcha, not coffee beans).
- **kafia-coffee (International Kafia Coffee)** — Skipped despite being a real roaster (since 1978,
  30 kg Petroncini, sells beans in-store at 842 Boyd Ave). Their official site (kafia.ca) lists
  NO bean names — customer-reported names (Ethiopia Yirgacheffe, Sumatra Mandheling, Tanzania
  Peaberry, House Blend, French Roast, Costa Rica, etc.) come only from review sites, so none
  meet the verification rule. Excluded per "if you can't verify it on the shop's site, skip the bean."
- **wise-town-cafe (Wise Town Cafe)** — Skipped. Family-owned café (espresso, matcha, food);
  their site shows no retail bean offering.
- **cafe-morala (Café Morala)** — Skipped. Small Latin-inspired café in the Glebe that serves
  Happy Goat coffee; no retail bean offering of its own (and no official site of its own).
- **art-house (Art House)** — Skipped. Art-gallery café/event venue; no retail bean offering.

## Data caveats

- **No imageUrl fields included** — neither The Ministry of Coffee nor Joe the Dog Coffee
  expose verifiable product-bag photos on the pages that could be fetched (Joe the Dog's site
  shows only retailer logos; Ministry's site shows lifestyle photos). Omitted rather than faked.
- **Joe the Dog Coffee bean names** (Best in Show, Diggin' It, Red Sea, Princess of Darkness,
  Neutered Dog, Gotta Go) were NOT found on their own site's fetched pages; they are
  corroborated by the Google Business "selection of offerings" (Best in Show, Diggin' It),
  TurnipSeed Travel's Ottawa roasters guide (Red Sea, Princess of Darkness as darkest roast,
  Neutered Dog as decaf), and a local coffee guide (Gotta Go). Origins/roast levels are
  unlisted everywhere, so origin defaults to "Blend" and roastLevel to "Medium" except
  Princess of Darkness (Dark — stated "their darkest roast") and Neutered Dog (decaf: true).
- **Ministry of Coffee "Dark Matter"** verified on their own blog ("we recently released our
  Dark Matter blend"; description paraphrased from there). Roast set to Light based on their
  stated house style ("definitely on the lighter side of the spectrum").
- **Ministry of Coffee "Ground Work"** verified via the CMHA Ottawa announcement (quotes their
  Head of Coffee; $5/bag donated, beans rotate). Details come from that announcement, not
  their own site — no tasting notes listed anywhere. ToastTab listings for "MOC Signature
  Blend / Decaf Espresso" were traced to a Los Angeles "Ministry of Coffee" (mocaustralia),
  NOT the Ottawa shop, and were excluded.
- All tastingNotes are [] — no tasting notes published on any fetched source.
