# Roasted Push Notifications — Setup

The app code (1.0.0+13) registers for push and saves each device's FCM token
to Firestore. Cloud Functions send the actual notifications. Three one-time
console steps remain:

## 1. Enable Push for the App ID (Apple Developer portal)

1. Go to developer.apple.com → Certificates, Identifiers & Profiles → Identifiers
2. Open `com.beanquest.coffeeBeans` → check **Push Notifications** → Save

## 2. APNs key → Firebase console

1. Apple portal → Keys → **+** → name it `Roasted APNs` → check **Apple Push
   Notifications service (APNs)** → Continue → Register → **Download** the `.p8`
   (one-time download — keep it safe). Note the **Key ID** and your **Team ID**.
2. Firebase console → roasted-app-579f9 → Project Settings → **Cloud Messaging**
3. Under "Apple app configuration", upload the `.p8`, enter Key ID + Team ID.

## 3. Blaze plan + deploy the functions

Cloud Functions need the pay-as-you-go Blaze plan (free tier is generous;
notifications cost essentially nothing at this scale):

1. Firebase console → Upgrade → Blaze
2. On your machine, from the `coffee-app` folder:
   ```
   cd functions
   npm install
   ```
3. Install the Firebase CLI once: `npm install -g firebase-tools`, then
   `firebase login`
4. Deploy: `firebase deploy --only functions`

## What you get

- Someone comments on your post → you get a push with their name + comment
- Someone likes your post → you get a push
- No notification for your own actions; dead tokens clean themselves up

## Testing

After installing the TestFlight build: log in, accept the notification
permission prompt, then comment on your own post from another account (or the
web prototype). The push should arrive within seconds.
