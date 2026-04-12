# StudyFlow

Mobile-first study planner built with Flutter for Android and iPhone.

## What changed

This project now runs in two clear modes:

- `Local demo mode`: no Supabase keys required, safe seeded data, fast presentation flow.
- `Supabase cloud mode`: real auth, real sync, Google OAuth through Supabase.

Secrets are no longer hardcoded in the app source. Use `.env.example` or `.env.json.example`.

## Core stack

- Flutter
- Riverpod
- GoRouter
- Supabase
- SharedPreferences
- Flutter Local Notifications

## Main folders

```text
lib/
  app/
  core/
  features/
  shared/
supabase/
  migrations/
docs/
test/
```

## Run locally

Demo mode:

```bash
flutter pub get
flutter run
```

Supabase mode:

```bash
flutter run --dart-define-from-file=.env.json
```

Example `.env.json`:

```json
{
  "SUPABASE_URL": "https://your-project-ref.supabase.co",
  "SUPABASE_ANON_KEY": "your-public-anon-key"
}
```

## Demo account

- Email: `student@studyflow.app`
- Password: `studyflow123`

## Supabase and Google setup

The full production setup guide is here:

- [Google & Supabase Setup](docs/google_supabase_setup.md)

It includes:

- exact Supabase steps
- Google Cloud Console steps
- redirect URLs
- Android and iOS deep link notes
- migration order
- iPhone and Samsung test checklist

## Important paths

- App entry: [lib/main.dart](/c:/Users/moham/studyflow/lib/main.dart)
- App shell: [lib/app/app.dart](/c:/Users/moham/studyflow/lib/app/app.dart)
- Theme: [lib/core/theme/app_theme.dart](/c:/Users/moham/studyflow/lib/core/theme/app_theme.dart)
- Shared widgets: [lib/core/widgets/app_widgets.dart](/c:/Users/moham/studyflow/lib/core/widgets/app_widgets.dart)
- Auth repository: [lib/shared/data/auth_repository.dart](/c:/Users/moham/studyflow/lib/shared/data/auth_repository.dart)
- Data repository: [lib/shared/data/study_repository.dart](/c:/Users/moham/studyflow/lib/shared/data/study_repository.dart)
- Supabase bootstrap: [lib/core/services/supabase_service.dart](/c:/Users/moham/studyflow/lib/core/services/supabase_service.dart)
- Migrations: [supabase/migrations/001_initial_schema.sql](/c:/Users/moham/studyflow/supabase/migrations/001_initial_schema.sql), [supabase/migrations/002_mobile_premium_upgrade.sql](/c:/Users/moham/studyflow/supabase/migrations/002_mobile_premium_upgrade.sql)

## Verification

Recommended checks before release:

```bash
flutter test
flutter analyze
flutter build apk --release
flutter build ios --release
```

## Notes

- The app is portrait-first for a cleaner phone experience.
- Arabic, English, and Turkish are supported.
- When Supabase keys are missing, the app no longer crashes and falls back to local demo mode.
