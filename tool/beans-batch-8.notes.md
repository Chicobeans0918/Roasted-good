# Batch 8 research notes (Toronto shops, Oct 17 2026)

## Beans included: 42 total across 5 distinct shop names

| Shop (whereToBuy) | Beans | Source |
|---|---|---|
| Reunion Island Coffee Bar | 12 | reunioncoffeeroasters.com (Shopify product API) |
| Library Coffee | 11 | librarycoffee.ca (Shopify product API) |
| Boxcar Social | 12 | subtext.coffee (Shopify product API) — Subtext is Boxcar's premier/sister roaster |
| Dark Horse Espresso Bar | 4 | Dark Horse's official Oct 15 2026 posts (mirrored on restaurant/café directories) |
| Rooster Coffee House | 3 | awifiplace.com (blend names); urbaneer.com (Pilot roasting partnership) |

## Skipped shops (3)

- **Quantum Coffee** (460 King St W) — café only. Their site (quantumcoffee.io) sells no retail beans and lists no bean catalog; they describe a "curated selection of locally roasted and blended beans" from third-party producers but no product names are verifiable.
- **Found Coffee** (189 Shaw St) — could not verify any retail bean sales. Their site (found.coffee) timed out on fetch (single attempt, not retried per policy) and no bean catalog surfaced in search results. Australian-inspired café; treat as café-only unless verified later.
- **Goldstruck Coffee** (130 Cumberland St / 133 Richmond St W) — café only. Their site (goldstruckcoffee.ca) and Square ordering site list drinks/pastries only; no retail bean product names or details are verifiable.

## Data caveats

- **Reunion**: the company rebranded from "Reunion Island Coffee" to **Reunion Coffee Roasters** in 2014 — the roaster field uses the current legal name; whereToBuy keeps the app's shop name "Reunion Island Coffee Bar". House Blend on their site is soft-pods-only (no whole-bean variant), so it was excluded. Tasting notes come from each product's `message-2-` tag on their site (e.g. "Black Current | Milk Chocolate | Jammy"). Blend origins recorded as "Blend".
- **Boxcar Social**: Boxcar is a multi-roaster café with a rotating seasonal lineup and no fixed bean catalog of its own, so this set mirrors the **current retail lineup of Subtext Coffee Roasters**, Boxcar's sister company and premier coffee supplier (verified via CB Insights/boxcarsocial sources). These are dated micro-lots that rotate — this snapshot may go stale; a re-run before seeding is advised. Tasting notes and roast levels are not published on Subtext's site: notes are `[]` and roast levels are best judgment (Light for "Filter Beans", Medium for "Espresso Beans", per Subtext's no-dark-roast philosophy). The `imageUrl` values are Subtext's real lot-tile images, not bag photos. Excluded "Test Batch (1kg)" and "Seasonal Sample Box".
- **Dark Horse Espresso Bar**: the 4 exclusive roasts (Northern Dancer, 20 Grand Espresso, Touch Gold, Easy Goer Decaf) are verified from Dark Horse's own Oct 15 2026 announcement; no tasting notes, roast details, or product photos are published, so those fields are empty/omitted and roast levels are best judgment ("old-skool" espresso blends → Dark; decaf and Touch Gold → Medium). Caveat: Detour Coffee Roasters is Dark Horse's sister-company "home roaster" (per The Roasters Pack, Aug 2024); the roaster field uses "Dark Horse Espresso Bar" since these are Dark Horse-branded exclusive roasts sold in their cafés.
- **Rooster Coffee House**: blend names (House Blend, Atomic Rooster Blend, Bold Beaver Blend) verified via awifiplace; the roaster field is "Pilot Coffee Roasters" — verified via Urbaneer that Rooster partnered with Pilot to roast their signature blends. No tasting notes or photos published; roast levels are best judgment (House → Medium, the two "bold" blends → Dark).
- **Library Coffee**: all data from librarycoffee.ca product pages (region/variety/process/cup notes). Roast levels are best judgment (their singles are light-roast specialty; Moonlight Blend is described "rich and bold... perfect for espresso" → Dark; ZZ Decaf and Seasonal Blend → Medium). "Businde - Burundi" and "Claudio Nakamura - Brazil" use the product titles as shown on the site.
- All `local` flags are `false` (Toronto roasters; only Gatineau/Ottawa-area roasters get `true`).
