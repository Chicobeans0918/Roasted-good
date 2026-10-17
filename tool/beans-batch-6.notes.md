# beans-batch-6 notes

Researched 2026-10-17 (Toronto roasters). 36 beans across 6 of 8 distinct roaster names.

## Skipped shops (2)

- **Ethica Coffee Roasters** (ethica-coffee) — SKIPPED. Their site (ethicaroasters.com) is a
  JS-rendered Next.js app; no shop or product pages surfaced through search or text fetch, so no
  product names, details, or photos could be verified on the roaster's own site. Their lineup
  (filter + espresso, origins like Ethiopia/Colombia/El Salvador) would need a live-browser visit
  to research.
- **Moonbean Coffee Company** (moonbean) — SKIPPED. moonbeancoffee.com has no accessible shop
  navigation in text fetch and no product URLs surfaced in search. The homepage confirms they sell
  a large bean range (~50 varieties) and a current "New Arrival: Kenya Kii", but names, details,
  and photos are not verifiable without a live-browser visit.

## Data caveats

- **Roast-level judgments**: only Light/Medium/Dark allowed. Pilot's own FAQ says their whole
  scale sits "within our medium roast profile", so mapping was: Heritage "Medium-Developed" →
  Medium; Monument "Developed"/dark roast title → Dark; Academy "Medium-Light" → Light;
  Community "Medium" → Medium; Catalyst Decaf (no stated level) → Medium. Propeller's Turbo
  Espresso is explicitly "Med-Dark" → Dark. Single origins with no stated roast → Light.
  Hale's "Taste Scale" was used where available (5 → Medium, 8 → Light, 2-Traditional → Dark/Medium
  per product page text).
- **Te Aro**: product pages carry only generic roastery copy — no tasting notes, origin, roast,
  or photos published. Both beans included on name+roaster verification only (per spec); origin
  "Blend" for Little Bro is an assumption (it is not confirmed to be a blend); no imageUrl.
- **De Mello**: only Dancing Goats got a full product-story page (hellodemello.com blog). Rwanda
  Cyiya and Indonesia Mt Ijen names + tasting notes come from the homepage's current-release
  banner. Blog images existed but were editorial, not verifiable product photos → no imageUrl.
  (De Mello's site is now branded "De Mello Coffee"; the canonical name "De Mello Palheta Coffee
  Roasters" was kept for roaster/whereToBuy per the shop list.)
- **Propeller**: product pages expose no product images in text fetch → no imageUrl on any of the
  6. Four more shop items existed but had no readable names (alt text missing) → skipped rather
  than guessed. The previously-seen "Skyhawk Dark Roast", "Rivet", and "Organic Swiss Water Decaf"
  could not be verified on current product pages.
- **Subtext**: no tasting notes published on product pages → all []. Product images exist on their
  CDN but had no alt text, so no bag photo could be verified → no imageUrl. The anaerobic-washed
  Arbegona Rumudamo lot was sold out → excluded. Espresso-collection product names were derived
  from the site's own product URL slugs (full names not rendered in the listing).
- **Hale**: bag-photo URLs (halebags*.jpg) are taken from the product gallery links; the first
  image in each gallery is the bag shot. Estelí Nicaragua and Anahi Brazil have no accessible
  product pages — included from collection-card data (names + notes) only, no imageUrl.
- **Pilot single origins**: only the current limited edition (Sumava Black Moon) was included;
  their regular single-origin lineup rotates and no individual product pages were reachable, so
  they were left out rather than invented.
- **Pilot Black Moon** photo: used the Web-badges shot (the primary product image on the page).
- All imageUrl values are verbatim from the roaster's own CDN/site. Where no verifiable product
  photo existed, the field was omitted entirely (not guessed).
