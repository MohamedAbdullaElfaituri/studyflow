# StudyFlow

Premium, multilingual, RTL-aware study planner built with Flutter for Android and iOS.

## 1. Project Summary

StudyFlow is a polished mobile productivity app for students. It combines:

- onboarding and authentication
- dashboard and planner
- tasks, notes, courses, exams, and assignments
- Pomodoro focus mode
- local notifications
- analytics and streaks
- habit tracking and lightweight gamification
- Turkish, English, and Arabic support with RTL readiness
- local-first demo mode with Supabase-ready architecture

The app is designed for an HCI / Human-Computer Interaction course submission, but the codebase is structured to feel much closer to a real product than a simple classroom demo.

## 2. Technology Stack And Packages

- `flutter`
- `flutter_riverpod`
- `go_router`
- `shared_preferences`
- `supabase_flutter`
- `flutter_local_notifications`
- `fl_chart`
- `table_calendar`
- `google_fonts`
- `intl`
- `uuid`

### Architectural choices

- Null safety enabled
- Feature-oriented clean structure
- Repository pattern
- Riverpod for state and dependency injection
- GoRouter for navigation
- SharedPreferences-backed demo mode
- Supabase-ready repositories and SQL migration

## 3. Full Feature List

### Core

- Splash flow
- Onboarding with first-launch language selection
- Login, sign up, forgot password
- Demo account flow for presentation use
- Dashboard with XP, level, streak, goals, habits, deadlines, and recent activity
- Daily, weekly, and monthly progress views

### Planning

- Course management
- Task management with subtasks, priority, status, due date, filters, search, and sorting
- Calendar-based planner with tasks, focus sessions, and exams in agenda
- Exams and assignments tracking with countdowns
- Notes with pinning and course linking
- Habit tracker
- Smart search across courses, tasks, notes, and exams

### Productivity

- Pomodoro / focus mode
- Study session logging
- Goal tracking
- Weekly challenge messaging
- Motivation quotes
- XP and level system
- Achievement cards

### Product polish

- Light and dark themes
- Premium gradient and glass-like surfaces
- Micro-interaction friendly components
- Empty, loading, and error states
- Haptic feedback hooks
- Local notification preview and permission flow
- Supabase sync-ready status

## 4. UI / UX Approach

The visual direction aims for a premium mobile product rather than a generic student app.

- Layered background gradients and ambient color orbs
- Soft glass-inspired cards with depth and rounded geometry
- Strong dashboard hero section with progress and level system
- Calm but vivid palette: deep navy, cyan, amber, coral accents
- Arabic-aware typography with `Noto Sans Arabic`
- Latin-focused premium typography with `Plus Jakarta Sans`
- High-contrast layout and large tap targets
- Consistent spacing, card hierarchy, and feedback patterns
- Lightweight motion through animated page transitions, progress, and segmented flows

## 5. File / Folder Tree

```text
studyflow/
  android/
  ios/
  assets/
    animations/
      README.md
    branding/
      README.md
    illustrations/
      README.md
  lib/
    app/
      app.dart
      app_router.dart
    core/
      constants/
        app_constants.dart
      errors/
        app_exception.dart
      localization/
        app_en.arb
        app_tr.arb
        app_ar.arb
        app_copy.dart
        generated/
          app_localizations.dart
          app_localizations_en.dart
          app_localizations_tr.dart
          app_localizations_ar.dart
      services/
        demo_seed_service.dart
        local_storage_service.dart
        reminder_service.dart
        supabase_service.dart
      theme/
        app_colors.dart
        app_spacing.dart
        app_theme.dart
      utils/
        date_time_utils.dart
        validators.dart
      widgets/
        app_widgets.dart
    features/
      analytics/presentation/analytics_screen.dart
      auth/presentation/auth_screens.dart
      calendar/presentation/calendar_screen.dart
      courses/presentation/courses_screens.dart
      exams/presentation/exams_screens.dart
      focus/presentation/focus_screen.dart
      goals/presentation/goals_screen.dart
      habits/presentation/habits_screen.dart
      home/presentation/home_screen.dart
      notes/presentation/notes_screens.dart
      onboarding/presentation/onboarding_screen.dart
      profile/presentation/profile_screens.dart
      search/presentation/search_screen.dart
      settings/presentation/settings_screen.dart
      tasks/presentation/tasks_screens.dart
    shared/
      data/
        auth_repository.dart
        study_repository.dart
        supabase_study_repository.dart
      extensions/
        build_context_x.dart
      models/
        app_models.dart
      providers/
        app_providers.dart
    main.dart
  supabase/
    migrations/
      001_initial_schema.sql
  test/
    widget_test.dart
  .env.example
  pubspec.yaml
  l10n.yaml
```

## 6. pubspec.yaml

Main dependencies already configured in [`pubspec.yaml`](/c:/Users/moham/studyflow/pubspec.yaml).

Highlights:

- localization generation enabled
- branding / illustration / animation asset folders registered
- chart, calendar, notifications, routing, and state management packages included

## 7. Main Flutter Entry Files

- App entry: [`main.dart`](/c:/Users/moham/studyflow/lib/main.dart)
- Root app: [`app.dart`](/c:/Users/moham/studyflow/lib/app/app.dart)
- Routing: [`app_router.dart`](/c:/Users/moham/studyflow/lib/app/app_router.dart)
- Theme system: [`app_theme.dart`](/c:/Users/moham/studyflow/lib/core/theme/app_theme.dart)
- Shared widgets: [`app_widgets.dart`](/c:/Users/moham/studyflow/lib/core/widgets/app_widgets.dart)
- App state: [`app_providers.dart`](/c:/Users/moham/studyflow/lib/shared/providers/app_providers.dart)
- Models: [`app_models.dart`](/c:/Users/moham/studyflow/lib/shared/models/app_models.dart)

## 8. Important Screens

### Main user flows

- Onboarding: [`onboarding_screen.dart`](/c:/Users/moham/studyflow/lib/features/onboarding/presentation/onboarding_screen.dart)
- Auth: [`auth_screens.dart`](/c:/Users/moham/studyflow/lib/features/auth/presentation/auth_screens.dart)
- Dashboard: [`home_screen.dart`](/c:/Users/moham/studyflow/lib/features/home/presentation/home_screen.dart)
- Tasks: [`tasks_screens.dart`](/c:/Users/moham/studyflow/lib/features/tasks/presentation/tasks_screens.dart)
- Planner: [`calendar_screen.dart`](/c:/Users/moham/studyflow/lib/features/calendar/presentation/calendar_screen.dart)
- Focus mode: [`focus_screen.dart`](/c:/Users/moham/studyflow/lib/features/focus/presentation/focus_screen.dart)
- Analytics: [`analytics_screen.dart`](/c:/Users/moham/studyflow/lib/features/analytics/presentation/analytics_screen.dart)
- Profile: [`profile_screens.dart`](/c:/Users/moham/studyflow/lib/features/profile/presentation/profile_screens.dart)
- Settings: [`settings_screen.dart`](/c:/Users/moham/studyflow/lib/features/settings/presentation/settings_screen.dart)

### Extra modules

- Exams & assignments: [`exams_screens.dart`](/c:/Users/moham/studyflow/lib/features/exams/presentation/exams_screens.dart)
- Habit tracker: [`habits_screen.dart`](/c:/Users/moham/studyflow/lib/features/habits/presentation/habits_screen.dart)
- Smart search: [`search_screen.dart`](/c:/Users/moham/studyflow/lib/features/search/presentation/search_screen.dart)

## 9. Localization Structure And Example Files

Primary localization files:

- [`app_en.arb`](/c:/Users/moham/studyflow/lib/core/localization/app_en.arb)
- [`app_tr.arb`](/c:/Users/moham/studyflow/lib/core/localization/app_tr.arb)
- [`app_ar.arb`](/c:/Users/moham/studyflow/lib/core/localization/app_ar.arb)

Generated delegates:

- [`app_localizations.dart`](/c:/Users/moham/studyflow/lib/core/localization/generated/app_localizations.dart)
- [`app_localizations_en.dart`](/c:/Users/moham/studyflow/lib/core/localization/generated/app_localizations_en.dart)
- [`app_localizations_tr.dart`](/c:/Users/moham/studyflow/lib/core/localization/generated/app_localizations_tr.dart)
- [`app_localizations_ar.dart`](/c:/Users/moham/studyflow/lib/core/localization/generated/app_localizations_ar.dart)

Supplemental localized copy used by newly added premium modules:

- [`app_copy.dart`](/c:/Users/moham/studyflow/lib/core/localization/app_copy.dart)

Runtime locale sources:

1. Authenticated user settings
2. Current user profile preference
3. First-launch local language preference stored in local storage

## 10. RTL Support Details

Arabic support is handled at app level.

- Supported locale includes `Locale('ar')`
- Material directionality switches automatically for Arabic
- Theme typography swaps to `Noto Sans Arabic`
- Onboarding and settings can change language at runtime
- Navigation, segmented controls, cards, and list layouts use directional alignment
- Calendar, date, and time formatting rely on `intl`

## 11. Notification System

Notification service:

- [`reminder_service.dart`](/c:/Users/moham/studyflow/lib/core/services/reminder_service.dart)

Current infrastructure includes:

- initialization for Android and iOS
- notification permission request flow
- preview notification action
- focus completion notification hook
- ready extension points for task, exam, daily briefing, and evening review reminders

Recommended next production step:

- add timezone-aware scheduled notifications with `zonedSchedule`

## 12. Theme System

Theme system files:

- [`app_colors.dart`](/c:/Users/moham/studyflow/lib/core/theme/app_colors.dart)
- [`app_spacing.dart`](/c:/Users/moham/studyflow/lib/core/theme/app_spacing.dart)
- [`app_theme.dart`](/c:/Users/moham/studyflow/lib/core/theme/app_theme.dart)

Included:

- light mode
- dark mode
- premium color palette
- adaptive typography for Arabic vs non-Arabic
- Material 3 configuration
- rounded controls and cards
- floating-style navigation shell

## 13. State Management

Riverpod state lives mainly in:

- [`app_providers.dart`](/c:/Users/moham/studyflow/lib/shared/providers/app_providers.dart)

Key providers:

- auth repository provider
- study repository provider
- router provider
- locale preference provider
- auth controller
- study data controller
- locale provider
- theme mode provider

The `StudyDataController` is the main app state aggregator. It loads:

- courses
- tasks
- notes
- exams
- habits
- sessions
- goals
- settings
- reminder preferences

## 14. Supabase Integration Infrastructure

Supabase-ready files:

- client bootstrap: [`supabase_service.dart`](/c:/Users/moham/studyflow/lib/core/services/supabase_service.dart)
- auth repository: [`auth_repository.dart`](/c:/Users/moham/studyflow/lib/shared/data/auth_repository.dart)
- data repository abstraction: [`study_repository.dart`](/c:/Users/moham/studyflow/lib/shared/data/study_repository.dart)
- Supabase data repository: [`supabase_study_repository.dart`](/c:/Users/moham/studyflow/lib/shared/data/supabase_study_repository.dart)
- SQL migration: [`001_initial_schema.sql`](/c:/Users/moham/studyflow/supabase/migrations/001_initial_schema.sql)

Current Supabase-ready tables:

- `profiles`
- `courses`
- `tasks`
- `subtasks`
- `notes`
- `exams`
- `habits`
- `study_sessions`
- `goals`
- `user_settings`
- `reminder_preferences`

## 15. Supabase Setup Guide Step By Step

### 1. Create a Supabase account

- Go to `https://supabase.com`
- Create an account or sign in

### 2. Create a new project

- Click `New project`
- Choose organization
- Set project name, database password, and region
- Wait for provisioning to finish

### 3. Get the Project URL

- Open the project dashboard
- Go to `Project Settings > API`
- Copy `Project URL`

### 4. Get the anon key

- In the same API page
- Copy the `anon public` key

### 5. Add it to Flutter

StudyFlow reads Supabase values from compile-time environment:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

The bootstrap file is [`supabase_service.dart`](/c:/Users/moham/studyflow/lib/core/services/supabase_service.dart).

### 6. Configure env values

Reference file:

- [`.env.example`](/c:/Users/moham/studyflow/.env.example)
- [`.env.json.example`](/c:/Users/moham/studyflow/.env.json.example)

Recommended workflow:

1. Copy `.env.example` to `.env` for local reference
2. Create a Flutter-friendly define file such as `.env.json`
3. Run the app with `--dart-define` or `--dart-define-from-file`

Example `.env.json`:

```json
{
  "SUPABASE_URL": "https://your-project-ref.supabase.co",
  "SUPABASE_ANON_KEY": "your_anon_key_here"
}
```

### 7. Install packages

Already present in `pubspec.yaml`:

- `supabase_flutter`

If needed manually:

```bash
flutter pub get
```

### 8. Initialize Supabase

Initialization happens in [`main.dart`](/c:/Users/moham/studyflow/lib/main.dart):

```dart
await SupabaseService.initialize();
```

### 9. Enable auth tables and custom tables

- Enable Email auth in `Authentication > Providers`
- Run the SQL migration in the SQL editor

### 10. SQL table creation examples

The full SQL file is here:

- [`001_initial_schema.sql`](/c:/Users/moham/studyflow/supabase/migrations/001_initial_schema.sql)

Example:

```sql
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  description text not null default '',
  due_date_time timestamptz,
  priority text not null default 'medium',
  status text not null default 'pending'
);
```

### 11. Enable Row Level Security

RLS is enabled in the migration for all core tables.

### 12. Write policies

Example policy pattern:

```sql
create policy "tasks_own_all" on public.tasks
for all using (auth.uid() = user_id)
with check (auth.uid() = user_id);
```

### 13. Use storage if needed

If later you add avatars or note attachments:

- go to `Storage`
- create a bucket such as `public-assets`
- upload or sign URLs
- store returned URL inside `profiles.avatar_url` or note attachment metadata

### 14. Test the connection

1. Add your environment values
2. Run the app
3. Register a user
4. Confirm `profiles`, `goals`, `user_settings`, and `reminder_preferences` rows are created
5. Create tasks or notes and confirm they appear in Supabase tables

### 15. Troubleshooting checklist

- Wrong URL or anon key
- Email auth not enabled
- RLS policy blocking insert or select
- Profile trigger missing
- Migration not fully executed
- Device has no internet access
- Table names differ from repository code

### 16. Android and iOS concerns

- verify internet permission defaults
- verify auth deep link / reset flow if you later add full email redirect handling
- verify notification permissions separately per platform

### 17. Test on a real device

- run Android and iOS on physical devices
- confirm login, session restore, notifications, and language switching

### 18. Before production build

- replace placeholder legal copy
- replace placeholder brand assets
- set real launcher icons and splash assets
- verify store-safe package name and bundle identifier
- verify RLS and remove any temporary dev policies
- run full analyzer, widget tests, and release build checks

## 16. Android Configuration Notes

Relevant files:

- [`AndroidManifest.xml`](/c:/Users/moham/studyflow/android/app/src/main/AndroidManifest.xml)
- [`build.gradle.kts`](/c:/Users/moham/studyflow/android/app/build.gradle.kts)

Notes:

- `POST_NOTIFICATIONS` permission added
- app label updated to `StudyFlow`
- Java 17 / desugaring already configured
- `adjustResize` already enabled for keyboard handling

Recommended next steps:

- add launcher icon with `flutter_launcher_icons`
- add branded splash with `flutter_native_splash`
- verify package name if publishing

## 17. iOS Configuration Notes

Relevant files:

- [`Info.plist`](/c:/Users/moham/studyflow/ios/Runner/Info.plist)
- [`AppDelegate.swift`](/c:/Users/moham/studyflow/ios/Runner/AppDelegate.swift)

Notes:

- display name updated to `StudyFlow`
- `CFBundleLocalizations` includes `en`, `tr`, and `ar`
- scene-based app lifecycle already in place

Recommended next steps:

- configure bundle identifier in Xcode
- verify notification permission prompts on real device
- test Arabic RTL layout on iPhone sizes

## 18. How To Run

### Demo mode

```bash
flutter pub get
flutter run
```

Demo credentials:

- email: `student@studyflow.app`
- password: `studyflow123`

### Supabase mode

With individual defines:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key_here
```

With JSON define file:

```bash
flutter run --dart-define-from-file=.env.json
```

## 19. Build Commands

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS release

```bash
flutter build ios --release
```

For App Store submission, archive in Xcode after a successful iOS release build.

## 20. Common Errors And Fixes

### Flutter localization not updating

- run `flutter gen-l10n`
- ensure `l10n.yaml` matches the correct ARB folder

### App starts in demo mode unexpectedly

- verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` were passed correctly
- confirm they are available as compile-time defines

### Login works but data is empty

- local demo mode may need seeded data, which happens automatically after sign-in
- Supabase mode needs migration and RLS setup

### Notifications do not appear

- grant permission manually in device settings
- test on a real device
- confirm Android 13+ notification permission is accepted

### Arabic layout looks wrong

- switch app language to Arabic from onboarding or settings
- confirm locale changed at app level
- test on a physical device and multiple screen sizes

### Forms overflow on smaller devices

- most screens already use `SingleChildScrollView` or `ListView`
- if you expand forms further, keep `SafeArea` and scroll containers

### Release build fails on iOS

- verify signing in Xcode
- verify bundle identifier
- run `pod install` if native dependencies changed

## Key Implementation Notes

- The app is runnable without Supabase because local repositories seed demo content automatically.
- Supabase support is not a mock. Repository contracts and migration are already aligned for real backend use.
- `.env.example` is included as reference, but the current secure runtime path uses Flutter compile-time defines.
- Extra modules added in this version: exams, habits, smart search, onboarding language selection, app-level locale persistence, and improved dashboard design.
