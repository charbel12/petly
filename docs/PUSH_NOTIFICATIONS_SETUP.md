# Push Notifications — Manual Setup

The mobile app and backend now have all the code needed for push
notifications (Firebase Cloud Messaging), but a few things can only be done
by a human with access to a Firebase project / Apple Developer account.
Nothing will crash without these — the app degrades gracefully and simply
doesn't register a push token — but no pushes will be delivered until this
checklist is complete.

## 1. Create a Firebase project

1. Go to the [Firebase console](https://console.firebase.google.com/) and
   create a project (or reuse an existing one) for Petly.
2. Add an Android app with package name `com.petly.petly` (see
   `mobile/android/app/build.gradle.kts` → `namespace`/`applicationId`).
3. Add an iOS app with the bundle identifier configured in
   `mobile/ios/Runner.xcodeproj` (check `PRODUCT_BUNDLE_IDENTIFIER`).

## 2. Android — `google-services.json`

1. Download `google-services.json` from the Firebase console (Project
   settings → General → Your apps → Android app).
2. Place it at `mobile/android/app/google-services.json`.
3. That's it — `mobile/android/app/build.gradle.kts` only applies the
   Google Services Gradle plugin when this file exists, so no other change
   is needed. Do not commit this file's real production values to a public
   repo without checking your org's policy on client config secrets.

## 3. iOS — `GoogleService-Info.plist` + APNs

1. Download `GoogleService-Info.plist` from the Firebase console (Project
   settings → General → Your apps → iOS app).
2. Add it to `mobile/ios/Runner/` via Xcode (File → Add Files to "Runner"),
   making sure it's included in the Runner target.
3. In Xcode, select the Runner target → Signing & Capabilities → "+
   Capability" → add **Push Notifications**.
4. In the [Apple Developer portal](https://developer.apple.com/account),
   create an APNs authentication key (Certificates, Identifiers & Profiles →
   Keys) and upload it to Firebase (Project settings → Cloud Messaging →
   Apple app configuration → APNs Authentication Key).

## 4. Backend environment variables

The backend needs a Firebase service account to send pushes via the Admin
SDK. In the Firebase console: Project settings → Service accounts → Generate
new private key. Then set in `backend/.env`:

```
FCM_PROJECT_ID=<project id>
FCM_CLIENT_EMAIL=<service account client_email>
FCM_PRIVATE_KEY=<service account private_key, with literal \n for newlines>
```

## 5. Verify

- Rebuild the app (`flutter run`) after adding the config files above.
- Log in as a user; the app should register a device token
  (`POST /notifications/device-tokens`) — check backend logs or the
  `DeviceToken`-equivalent table.
- Trigger a test push from the backend/partner dashboard and confirm it
  arrives (foreground messages show as a SnackBar; background/terminated
  behavior depends on OS-level notification display, which this phase does
  not customize further).

No mobile or backend code changes are required once the above is done — the
client-side wiring (`mobile/lib/core/services/push_notification_service.dart`)
already requests permission, fetches the token, and calls the registration
endpoint as soon as `Firebase.initializeApp()` succeeds.
