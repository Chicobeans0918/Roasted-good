// Seeds the Firestore `beans` and `shops` collections from the bundled
// seed JSON (assets/seed/beans.json, assets/seed/shops.json).
//
// Usage:
//   cd tool
//   npm install firebase-admin
//   export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
//   export FIREBASE_PROJECT_ID=your-project-id
//   node seed-firestore.mjs
//
// Document ids match the seed ids, so re-running refreshes the catalogue.

import admin from 'firebase-admin';
import { readFile } from 'fs/promises';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectId = process.env.FIREBASE_PROJECT_ID;
if (!projectId) {
  console.error('Set FIREBASE_PROJECT_ID first.');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId,
});
const db = admin.firestore();

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
