# beans-batch-5 — research notes (Oct 17, 2026)

## Beans included: 10 from 3 shops

### Z3 Specialty Coffee — 5 beans (in-house roasted, Ottawa/Kanata)
Names, origins, tasting notes and details taken from the shop's own Shopify
store data (z3specialtycoffee.com/products.json, read Oct 17, 2026):
- Z3 Blend (Peru & Ethiopia, fully washed; toffee, lemon, chocolate, orange)
- Grape Lollipop (Tolima, Colombia, co-fermentation; red grape, dried plum,
  red floral, muscat grape, whisky)
- Geisha (Geisha Village, Ethiopia, semi-washed; cherry, clove, tangerine,
  lime, mint, guava juice)
- The Last Apple (Loja, Ecuador, Green Tip Geisha, washed; white flower,
  empire apple, peach, persimmon, red honey)
- Yirgacheffe (West Arsi, Ethiopia, Grade 1 natural; juicy plum, red apple,
  blueberry, green tea finish)
Caveats: the store tags all product images as "placeholder-image" and the
product photos were not verified as real bag shots, so imageUrl is omitted
for every Z3 bean. Roast levels are inferred (Z3 lists no roast info):
single origins marked Light, the house blend Medium. The Yirgacheffe is an
older product (created Jan 2025, vendor field reads "My Store" but it is
listed on Z3's own store as part of their range).

### Beandigen Cafe — 3 beans (Ondarez Coffee, sold in 340g bags in-store)
Beandigen's site confirms "Ondarez Coffee in 340g bags. Locally roasted...
Three blends available", but the online shop collection is empty (products
unpublished — the products.json endpoint failed too), so blend names come
from the Ottawa Tourism profile of Ondarez:
- Coffee with My Aunties (tribute to the owner's mother/aunts)
- On the Land (described by the source as a bold dark roast)
- Pow Wow Love (dedication to Pow Wow love / the owner's husband)
Caveats: no photos, no tasting notes, and no roast info except for On the
Land (Dark); the other two are inferred Medium. Ondarez coffee is roasted
with a local Gatineau roaster, so local=true. All three ship without
imageUrl. The blend names are from 2021 reporting; Beandigen still lists
"three blends" of Ondarez as of today, but individual blend availability
was not re-verifiable on their site.

### Volume Coffee House — 2 beans (roasted by Café William)
Volume's own site says their organic fair-trade espresso and decaf are
"crafted with care by Café William": Vision (arabica blend, chocolate and
black cherry) and Evolution (naturally decaffeinated with water, berries
and herbs). Included as name+roaster-verifiable per the rules, no imageUrl
(retail bag details/photos not on their site; the GoDaddy shop page did not
render product listings). local=false: Café William roasts in Sherbrooke, QC.

## Skipped shops (5 distinct names)

1. **Origin Trade** (111 York St) — no official website found; the location
   appears closed (111 York St now shows as an active, different business).
   apt613 notes they never roasted in-house anyway.
2. **Parliament Café** (189 Sparks St) — café with no official site and no
   retail bean offering found; appears to be drinks-only.
3. **Ten Toes Coffee House** (all 3 locations: Somerset, Glebe, Cyrville) —
   family-owned café that serves beans from Equator Coffee Roasters (Almonte,
   ON); no retail bean shop or bag offering on their site (tentoescoffeeco.com).
4. **Black Squirrel Books & Espresso Bar** — used-bookstore/espresso bar that
   serves Cloudforest and Little Victories beans; no retail bean offering of
   its own found.
5. **Red Door Provisions** — preservation-kitchen café serving Pilot Coffee
   Roasters (Toronto) espresso; no retail bean offering on their site.
