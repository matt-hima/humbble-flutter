# Humbble Flutter

Humbble is a Firebase-powered Flutter dating app, migrated from the original Expo project.

## Stack

- Flutter for web, Android, and iOS
- Firebase Authentication for email/password accounts
- Cloud Firestore for profiles, reactions, conversations, and messages
- Firebase Storage for profile media
- Firebase Hosting for web deployment

## Run locally

```sh
cd flutter_app
flutter pub get
flutter run -d chrome
```

## Validate and build

```sh
cd flutter_app
flutter analyze
flutter test
flutter build web --release --no-wasm-dry-run
```

## Deploy

```sh
firebase deploy --only hosting:photo-hubble,firestore --project photo-hubble
```

The deployed web app is available at [photo-hubble.web.app](https://photo-hubble.web.app).

## Firebase data model

- `profiles/{uid}`: public dating profile fields
- `reactions/{fromUid_toUid}`: likes and passes
- `conversations/{conversationId}`: member list and conversation summary
- `conversations/{conversationId}/messages/{messageId}`: immutable messages

Firestore security rules are stored in `firestore.rules` and deployed through `firebase.json`.
