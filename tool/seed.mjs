// Seeds the Firestore `beans` and `shops` collections from the bundled
// seed JSON (assets/seed/beans.json, assets/seed/shops.json).
//
// Usage (from the tool folder):
//   npm install firebase-admin
//   $env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\service-account.json"
//   $env:FIREBASE_PROJECT_ID="your-project-id"
//   node seed.mjs
//
// Document ids match the seed ids, so re-running refreshes the catalogue.
import { createRequire } from 'node:module';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const require = createRequire(import.meta.url);

let appMod, fsMod;
try {
  appMod = require('firebase-admin/app');
  fsMod = require('firebase-admin/firestore');
} catch {
  console.error('firebase-admin is not installed here.');
  console.error('Run this once in the tool folder: npm install firebase-admin');
  process.exit(1);
}

const { initializeApp, applicationDefault } = appMod;
const { getFirestore } = fsMod;
if (typeof initializeApp !== 'function' || typeof applicationDefault !== 'function') {
  console.error('firebase-admin did not load correctly. Reinstall it:');
  console.error('  Remove-Item -Recurse -Force node_modules; npm install firebase-admin');
  process.exit(1);
}

const projectId = process.env.FIREBASE_PROJECT_ID;
if (!projectId) {
  console.error('Set FIREBASE_PROJECT_ID first.');
  process.exit(1);
}
if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.error('Set GOOGLE_APPLICATION_CREDENTIALS first.');
  process.exit(1);
}

initializeApp({
  credential: applicationDefault(),
  projectId,
});
const db = getFirestore();

const __dirname = dirname(fileURLToPath(import.meta.url));

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
