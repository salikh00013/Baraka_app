# BARAKA

BARAKA is a multi-store shopping and delivery platform launching in To‘raqo‘rg‘on, Namangan, Uzbekistan.

## Planned clients
- Flutter Android application
- Web admin dashboard
- Future customer web store

## Business model
- Customers choose products and quantities, not source stores.
- A courier collects items from one or more partner stores and delivers one combined order.
- Customers see BARAKA retail prices only.
- Substitutions or changes require customer approval.
- Sale prices and actual source costs are recorded separately for accurate profit reporting.

## Technology
- Flutter mobile application
- Firebase Authentication for Google sign-in
- Cloud Firestore for user, product, and order data
- Firebase project: `baraka-013`

## Current implementation status
- Firebase Android configuration is stored at `android/app/google-services.json`.
- Phone authentication is being migrated from Supabase to Firebase Authentication.
- User profiles are stored in the Firestore `users` collection.
- Customer category browsing and search use a starter catalog.
- A session-only shopping cart is implemented; quantities can be increased/decreased and the cart can be cleared.
- Cart contents are currently in memory only and are not persisted between app restarts.
- Product price/stock persistence, checkout, and order workflows are not yet complete.
- Firestore security rules are provided in `firestore.rules` and must be published in the Firebase Console before production use.

## Firebase Console setup required
1. Enable **Authentication → Google** and add Android SHA-1/SHA-256 fingerprints, then download an updated `google-services.json` if Firebase provides one.
2. Create a **Cloud Firestore** database.
3. Publish the rules from `firestore.rules`.
4. Add the Android app SHA-1/SHA-256 fingerprints in Firebase project settings if required by the app-verification flow.
5. Test with Firebase Authentication test phone numbers before sending real SMS.

Never put service-account credentials or private server keys in the mobile app.
