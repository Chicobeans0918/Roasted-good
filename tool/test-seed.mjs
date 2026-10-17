// Quick layout check: verifies the seed JSON files resolve and parse,
// using the same path logic as seed-firestore.mjs. Run: node test-seed.mjs
import { readFile } from 'fs/promises';

const beans = JSON.parse(
  await readFile(new URL('../assets/seed/beans.json', import.meta.url), 'utf8'),
);
const shops = JSON.parse(
  await readFile(new URL('../assets/seed/shops.json', import.meta.url), 'utf8'),
);
console.log(
  `beans: ${beans.length} | shops: ${shops.length} | with photos: ${
    beans.filter((b) => b.imageUrl).length
  }`,
);
