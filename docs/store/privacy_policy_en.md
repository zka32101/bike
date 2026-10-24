# Privacy Policy (English) - Draft

> Status: draft. To be reviewed by Ops/legal before publication. `[Ops to confirm]` marks facts not yet confirmed.

Effective date: [Ops to confirm] / Last updated: [Ops to confirm]
Operator: [Ops to confirm: name] / Contact: [Ops to confirm: email]

This policy explains how "Moped & Motorcycle License Kore!" (原付・バイク免許コレ！, the "App") handles your information.

## 1. Information we handle and why

### (1) Study data (on your device and in the cloud)
- Answer history, study progress, settings such as license category and exam date, and the state of study coins and outfits.
- Stored on your device (SharedPreferences). If you sign in with a Google account, it is also stored in Cloud Firestore so it can follow you to another device.
- Purpose: providing study features and transferring your data.

### (2) Account information
- If you sign in with Google, Firebase Authentication handles your user ID (UID) and account details such as your email address.
- If you choose to continue offline, data stays on your device only. In that case the App creates a random ID on the device.
- Purpose: managing your own study data.

### (3) Usage measurement (Firebase Analytics)
- Events such as screen views, study start/completion, purchase completion and ad display, plus device/app information (such as an app instance ID).
- Purpose: improving the App and understanding feature use.

### (4) Crash reports (Firebase Crashlytics)
- Error information when the App crashes, device model and OS version.
- Purpose: finding and fixing bugs.

### (5) Ads (Google AdMob)
- The free version shows ads (a banner on the home screen and an interstitial ad when you finish your daily quota, i.e. your daily study goal). No ads are shown on the question, boss battle, or pass-prediction meter screens.
- Google may collect device identifiers such as the advertising ID to serve and measure ads.
- You can choose your ad consent on the screen shown at first launch (Google User Messaging Platform). In regions where consent is required, ad handling follows your choice.
- While you own "Ad-free" or "Premium", the ad SDK is not initialized and no ads are shown.

### (6) Purchase management (RevenueCat / Google Play)
- To manage and restore one-time purchases (Ad-free, Premium), your user ID and purchase information are sent to RevenueCat.
- Payments are processed by Google Play. Card numbers are never sent to the App.

### (7) Feedback
- If you send feedback from Settings, we store what you wrote and your signed-in user ID in Cloud Firestore.
- Purpose: handling bugs and improvements.

### (8) Notifications
- The App schedules review reminders locally on your device (it may ask for notification permission). Their content is created on the device and is not sent to a server. [Ops to confirm: no remote push is used]

### (9) Cross-promotion
- Firebase Remote Config is used to fetch a list of other apps to introduce. [Ops to confirm]

The App does not request access to your location, contacts, photos or microphone.

## 2. Service providers

To achieve the purposes above we use the following services, and information is sent to them. Each provider handles it under its own privacy policy.
- Google LLC (Firebase Authentication / Cloud Firestore / Analytics / Crashlytics / Remote Config, Google AdMob, Google Play, Google Sign-In)
- RevenueCat, Inc. (purchase management)

Except where required by law, we do not provide personal information to other third parties.

## 3. Retention and deletion

- Study data is kept until you delete it or delete your account. [Ops to confirm: retention period and deletion procedure (in-app deletion, contact for deletion requests)]
- Data on your device is removed when you uninstall the App or clear its data.
- Retention of analytics and crash data follows each service's settings and terms.

## 4. Your choices

- You can use the App without signing in (study data is then not stored in the cloud).
- You can choose ad consent on the consent screen. You can also reset your advertising ID or limit ad personalization in your OS settings.
- You can turn off notifications at any time in your device settings.

## 5. Children

The App is not primarily directed to children under 13, and we do not knowingly collect information from them. [Ops to confirm]

## 6. About the study content

The App is a study aid and does not guarantee passing any test or any result. Traffic rules and test content can change with legal revisions, so questions and explanations may be out of date. Please check the latest information from official sources such as the National Police Agency, your prefectural police and your driver's license center.

## 7. Changes

If we change this policy, we will announce it on this page.

## 8. Contact

[Ops to confirm: contact]
