# Roasted catalog expansion — beans research report (2026-10-17)

## Headline numbers

- **255 new beans** merged into `tool/beans-new-all.json` (from 262 raw researched; 7 dropped as Boxcar/Subtext duplicates — see below)
- **28 roasters** across **38 distinct shop names** (all `whereToBuy` values verified character-for-character against `assets/seed/shops.json`)
- **178 beans (70%) have real product photo URLs** from the roasters' own sites; **77 (30%) have no photo** (field omitted, never faked)
- **167 local=true** (Gatineau/Ottawa roasters), **88 local=false** (Toronto)
- Validation: 0 errors — every bean has a unique id, name, roaster, valid roastLevel (Light/Medium/Dark), boolean decaf/local, null rating, and a `whereToBuy` matching a real shop. No id collisions with the existing 19 beans.

## Per-roaster breakdown

| Roaster | Beans | Photos |
|---|---|---|
| Happy Goat Coffee Co. | 52 | 52 |
| Bridgehead | 24 | 24 |
| Subtext Coffee Roasters | 15 | 5 |
| Brûlerie Aladdin | 12 | 12 |
| La Brûlerie | 12 | 12 |
| Brûlerie Élixir | 12 | 12 |
| Reunion Coffee Roasters | 12 | 12 |
| Little Victories Coffee Roasters | 11 | 11 |
| Library Coffee | 11 | 11 |
| Pilot Coffee Roasters | 9 | 6 |
| Hale Coffee Company | 9 | 7 |
| Sam James Coffee Bar | 9 | 0 |
| Moca Loca | 8 | 0 |
| Equator Coffee | 8 | 8 |
| CloudForest | 6 | 6 |
| Morning Owl | 6 | 0 |
| Joe the Dog Coffee | 6 | 0 |
| Propeller Coffee Co. | 6 | 0 |
| Z3 Specialty Coffee | 5 | 0 |
| Jimmy's Coffee | 4 | 0 |
| Dark Horse Espresso Bar | 4 | 0 |
| Ondarez Coffee | 3 | 0 |
| De Mello Palheta Coffee Roasters | 3 | 0 |
| The Ministry of Coffee | 2 | 0 |
| Café William | 2 | 0 |
| Te Aro Coffee Roasters | 2 | 0 |
| Dineen Coffee Co. | 1 | 0 |
| Neo Coffee Bar | 1 | 0 |

Note: Bridgehead's 6 core beans are emitted under each of its 4 location names (24 entries) — by design, so every Bridgehead shop page shows its beans. Same pattern for Happy Goat's 4 Ottawa location variants (40) + the Gatineau "Maison du Café" location (12).

## Shops skipped (no beans — cafés without retail, closed, or unverifiable)

- **Gatineau:** Café Vasanti, Café Aux Trois Licornes, Café Mulligan, Café British (a pub), Café 3 Portages (site "Launching Soon"), Les Cafés Aroma Select (roaster, but no verifiable named products), Le Café Bour-Joie (no web presence at all), Cascara Café & Bistro (Happy Goat café, no own line), Brown Bag (already in catalog)
- **Ottawa:** Bluebird Coffee (permanently closed), Fraser Cafe (closed), Uji Café (matcha café), International Kafia Coffee (roasts in-store but lists zero bean names), Wise Town Cafe, Café Morala, Art House (cafés, no retail), Origin Trade (appears closed), Parliament Café (no site/retail), Ten Toes Coffee House ×3 (serves Equator, no retail bags), Black Squirrel Books (no retail), Red Door Provisions (serves Pilot, no retail), Drip House, Ottawa Bike Cafe (cafés), Arlington Five, Planet Coffee, Bar Robo (cafés, no retail)
- **Toronto:** Versus Coffee (sells third-party De Mello bags, no own line), Quantum Coffee, Goldstruck Coffee (no verifiable retail catalog), Found Coffee (site unreachable), Ethica Coffee Roasters (JS-rendered site — needs a live-browser visit), Moonbean Coffee Company (no product URLs reachable — needs a live-browser visit)
- Café Cloudforest (Ottawa) was intentionally covered once under the shared name by the Gatineau batch.

## Data quality caveats

1. **77 beans have no photo** (`imageUrl` omitted): Sam James ×9, Moca Loca ×8, Morning Owl ×6, Joe the Dog ×6, Propeller ×6, Z3 ×5, Jimmy's ×4, Dark Horse ×4, Ondarez ×3, De Mello ×3, Ministry of Coffee ×2, Café William ×2, Te Aro ×2, Dineen ×1, Neo ×1, Subtext ×10 of 15, Pilot ×3 of 9, Hale ×2 of 9. A live-browser photo pass over the roasters' sites would fill most of these.
2. **73 beans have no tasting notes** (empty array) — mostly the same roasters as above.
3. **Roast levels are best-judgment** where sites don't state them explicitly (La Brûlerie ×5, Élixir ×1, Moca Loca ×1, Z3, Ondarez ×2, Pilot mapped from their "within medium" scale, Hale from their taste scale, Propeller Turbo Espresso "Med-Dark" → Dark).
4. **Boxcar Social**: Boxcar is a rotating multi-roaster café; 7 of its 12 researched beans duplicated Subtext's lineup and were dropped in favor of Subtext's entries (Subtext is the roaster and has its own shop page). The 5 kept Boxcar entries are Subtext micro-lots that may rotate — refresh before seeding.
5. **La Brûlerie "Parfum des Andes"**: site says "Description à venir!" — included with a placeholder description; revisit.
6. **Te Aro**: no per-product details published at all — included on name+roaster verification only.
7. **Ondarez Coffee** (sold at Beandigen Cafe): blend names come from 2021 reporting; Beandigen's shop currently lists "three blends" without names.
8. **La Brûlerie's site misspells** "Colombien Décaféiné" as "clombien décaféiné" — the file uses the corrected spelling.
9. **Élixir Costa Rica Honey Process** and **La Brûlerie Guji GR1** are flagged as limited-time offerings that may rotate out.
10. **Rooster Coffee House** blends are roasted by Pilot Coffee Roasters (per Urbaneer) — filed under roaster "Pilot Coffee Roasters", whereToBuy "Rooster Coffee House".
11. **Café William** beans (served at Volume Coffee House) and **Ondarez** beans (sold at Beandigen Cafe) are third-party roasters stocked at those cafés — `roaster` is the actual roaster, `whereToBuy` the café.

## Method notes

- 8 parallel research workers, one per shop batch; each verified beans against the roaster's own website via search + text fetch (no live browser available to workers).
- Merge deduped by id and by (name, roaster, whereToBuy); multi-location brands intentionally keep per-location entries so every shop page shows its beans.
- `assets/seed/beans.json` was NOT modified. To go live: append `beans-new-all.json` entries to the seed array and re-run `node tool/seed.mjs` (full overwrite — local seed files must be current first).
