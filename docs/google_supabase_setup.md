# Google Console + Supabase Setup

This guide matches the current mobile auth flow in the app.

## 1. Important project values

- Supabase mode is enabled only when you pass `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
- If those values are missing, the app now falls back to local demo mode.
- The mobile auth deep link used by the app is:

```text
com.mohamedahmet.studyflow://login-callback/
```

## 2. Files involved in auth

- [lib/core/constants/app_constants.dart](/c:/Users/moham/studyflow/lib/core/constants/app_constants.dart)
- [lib/core/services/supabase_service.dart](/c:/Users/moham/studyflow/lib/core/services/supabase_service.dart)
- [lib/shared/data/auth_repository.dart](/c:/Users/moham/studyflow/lib/shared/data/auth_repository.dart)
- [lib/shared/providers/app_providers.dart](/c:/Users/moham/studyflow/lib/shared/providers/app_providers.dart)
- [lib/features/auth/presentation/auth_screens.dart](/c:/Users/moham/studyflow/lib/features/auth/presentation/auth_screens.dart)
- [android/app/src/main/AndroidManifest.xml](/c:/Users/moham/studyflow/android/app/src/main/AndroidManifest.xml)
- [ios/Runner/Info.plist](/c:/Users/moham/studyflow/ios/Runner/Info.plist)

## 3. Supabase setup

### 3.1 Create the project

1. Open `https://supabase.com`.
2. Create a new project.
3. Open `Project Settings -> API`.
4. Copy:
   - `Project URL`
   - `anon public key`

### 3.2 Run the SQL migrations

Run these files in `SQL Editor` in this order:

1. [supabase/migrations/001_initial_schema.sql](/c:/Users/moham/studyflow/supabase/migrations/001_initial_schema.sql)
2. [supabase/migrations/002_mobile_premium_upgrade.sql](/c:/Users/moham/studyflow/supabase/migrations/002_mobile_premium_upgrade.sql)

### 3.3 Authentication providers

Open `Authentication -> Providers`:

1. Enable `Email`.
2. Enable `Google`.
3. Do not save Google until you finish the Google Cloud section below.

### 3.4 URL configuration

Open `Authentication -> URL Configuration`.

Use these values:

- `Site URL`
  - use your real website if you have one
  - if this is mobile-only for now, `http://localhost` is acceptable
- `Redirect URLs`
  - add `com.mohamedahmet.studyflow://login-callback/`

This redirect URL is used by both:

- Google OAuth return to the mobile app
- Password reset return to the mobile app

### 3.5 Google provider values inside Supabase

After creating the Google OAuth client, return to:

`Authentication -> Providers -> Google`

Paste:

- `Client ID`
- `Client Secret`

Then save.

## 4. Google Cloud Console setup

### 4.1 Create or choose a project

1. Open `https://console.cloud.google.com`.
2. Create a project or select an existing one.
3. Go to `APIs & Services`.

### 4.2 Configure the OAuth consent screen

Open `OAuth consent screen` and complete:

1. User type: usually `External`
2. App name
3. Support email
4. Developer contact email
5. Add test users if the app is still in testing mode

### 4.3 Create the OAuth client

Open `Credentials -> Create Credentials -> OAuth client ID`.

Choose:

- `Application type`: `Web application`

This is correct for Supabase Google auth because Google redirects to Supabase first, not directly to the app.

### 4.4 Authorized redirect URI

Add this exact URI in Google Cloud:

```text
https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback
```

Replace `YOUR_PROJECT_REF` with your real Supabase project ref.

You do not put the mobile custom scheme in Google Cloud for this Supabase flow.
The custom scheme belongs in Supabase `Redirect URLs`.

## 5. App environment values

Create a local `.env.json` file like this:

```json
{
  "SUPABASE_URL": "https://your-project-ref.supabase.co",
  "SUPABASE_ANON_KEY": "your-public-anon-key"
}
```

Run the app with:

```bash
flutter run --dart-define-from-file=.env.json
```

If you run without these values, the app will stay in local demo mode.

## 6. Password reset flow

The app now completes the password reset flow end-to-end:

1. The user requests a reset email from the app.
2. Supabase sends the email with:
   `redirectTo = com.mohamedahmet.studyflow://login-callback/`
3. The email link returns to the mobile app.
4. Supabase emits the `passwordRecovery` auth event.
5. The app opens the in-app reset password screen.
6. The user submits a new password.

Because of that, the redirect URL in `Authentication -> URL Configuration` must be present.

## 7. Platform deep link values already configured in code

### Android

Configured in:

- [android/app/src/main/AndroidManifest.xml](/c:/Users/moham/studyflow/android/app/src/main/AndroidManifest.xml)

Current values:

- scheme: `com.mohamedahmet.studyflow`
- host: `login-callback`

### iOS

Configured in:

- [ios/Runner/Info.plist](/c:/Users/moham/studyflow/ios/Runner/Info.plist)

Current value:

- URL scheme: `com.mohamedahmet.studyflow`

If you ever change the bundle id or package name, update:

- Flutter auth constants
- Android manifest deep link
- iOS URL scheme
- Supabase redirect URL

## 8. Quick verification checklist

Test these flows on a real phone:

1. Email sign up
2. Email sign in
3. Google sign in
4. Forgot password
5. Open the reset email on the same device
6. Set a new password inside the app
7. Sign out and sign in again with the new password

## 9. Common failures

### Google opens and returns without a session

Check all of these:

- Google provider is enabled in Supabase
- Google client ID and secret are saved in Supabase
- Google Cloud redirect URI is exactly `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback`
- Supabase `Redirect URLs` contains `com.mohamedahmet.studyflow://login-callback/`

### Password reset email sends, but the app does not open the reset screen

Check all of these:

- Supabase `Redirect URLs` contains `com.mohamedahmet.studyflow://login-callback/`
- the email link was opened on a device with the app installed
- Android manifest and iOS URL scheme still match the values in code

### The app keeps using local demo mode

Check all of these:

- you passed `--dart-define-from-file=.env.json`
- `SUPABASE_URL` is not empty
- `SUPABASE_ANON_KEY` is not empty

## 10. Useful commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter run --dart-define-from-file=.env.json
flutter build apk --release
flutter build ios --release
```
