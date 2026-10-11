# Firebase setup for Roasted

The app runs fully offline on its bundled seed data until you complete these
steps. Everything below uses the free **Spark** plan.

## 1. Install the tooling

```bash
# Firebase CLI (needs Node.js)
npm install -g firebase-tools

# FlutterFire CLI
dart pub global activate flutterfire_cli
```

## 2. Create the Firebase project

1. Go to <https://console.firebase.google.com> and click **Add project**.
2. Name it `roasted-app` (or anything you like). Google Analytics is optional.
3. Once created, open **Build → Authentication → Sign-in method** and enable:
   - **Email/Password**
   - **Apple** (needed for Sign in with Apple; follow the console's steps to
     register your Services ID — Apple Developer account required)
4. Open **Build → Firestore Database → Create database** (production mode is
   fine; start in test mode only temporarily if you prefer, then tighten rules).

### Suggested Firestore rules (after seeding)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Public catalogue: anyone signed in can read, nobody writes from clients
    match /beans/{bean}  { allow read: if true;  allow write: if false; }
    match /shops/{shop}  { allow read: if true;  allow write: if false; }
    // Personal data: only the owning user
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## 3. iOS: enable Sign in with Apple capability

1. In Xcode, open `ios/Runner.xcworkspace`.
2. Select the **Runner** target → **Signing & Capabilities** → **+ Capability** →
   **Sign in with Apple**.
3. In the Firebase console → Authentication → Sign-in method → Apple, make sure
   your bundle ID is registered.

## 4. Generate the Firebase options

From the project root:

```bash
flutterfire configure
```

Select your Firebase project and the iOS app (bundle id as in Xcode).
This **replaces** `lib/firebase_options.dart` (currently a placeholder) with
the real config and sets `isConfigured` to true. The app will then
automatically use Firebase Auth + Firestore, with the bundled seed data as
offline fallback.

## 5. Seed the catalogue collections

The seed JSON lives in `assets/seed/beans.json` and `assets/seed/shops.json`
(28 beans, 7 Gatineau–Ottawa shops — generated from the Dart seed data via
`dart run tool/gen_seed_json.dart`, so they always match).

```bash
cd tool
npm install firebase-admin
# Create a service account in the Firebase console:
# Project settings → Service accounts → Generate new private key,
# then point GOOGLE_APPLICATION_CREDENTIALS at the downloaded JSON.
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
export FIREBASE_PROJECT_ID=your-project-id
node seed-firestore.mjs
```

This writes the `beans` and `shops` collections (document ids match the seed
ids). Re-run any time to refresh the catalogue.

## 6. Build & run

```bash
flutter pub get
flutter run
```

Log in with email/password or Apple, or continue as guest (anonymous auth).
Tastings and wishlist sync to `users/{uid}/tastings` and
`users/{uid}/wishlist` when signed in; everything keeps working offline.
