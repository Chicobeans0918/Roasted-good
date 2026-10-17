// Seeds the Firestore `beans` and `shops` collections from the bundled
// seed JSON (assets/seed/beans.json, assets/seed/shops.json).
//
// Usage:
//   cd tool
//   npm install firebase-admin
//   $env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\service-account.json"
//   $env:FIREBASE_PROJECT_ID="your-project-id"
//   node seed-firestore.mjs
//
// Document ids match the seed ids, so re-running refreshes the catalogue.

import { createRequire } from 'module';
import { readFile } from 'fs/promises';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const require = createRequire(import.meta.url);
const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectId = process.env.FIREBASE_PROJECT_ID;
if (!projectId) {
  console.error('Set FIREBASE_PROJECT_ID first.');
  process.exit(1);
}

initializeApp({
  credential: applicationDefault(),
  projectId,
});
const db = getFirestore();

async function seed(collection, file) {
  const raw = await readFile(join(__dirname, '..', 'assets', 'seed', file), 'utf8');
  const docs = JSON.parse(raw);
  const batch = db.batch();
  for (const doc of docs) {
    const { id, ...data } = doc;
    batch.set(db.collection(collection).doc(id), data);
  }
  await batch.commit();
  console.log(`Seeded ${docs.length} docs into "${collection}".`);
}

await seed('beans', 'beans.json');
await seed('shops', 'shops.json');
console.log('Done.');
