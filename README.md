# StudyFlow

StudyFlow is a premium, multilingual, mobile-first Flutter productivity app for university students. It brings courses, tasks, study sessions, calendar planning, notes, goals, reminders, analytics, and profile/settings into one polished Android and iOS experience.

## Project Overview

This project was designed as a Human-Computer Interaction / Computer Interaction course application with strong emphasis on:

- elegant mobile UX
- inclusive and accessible interaction patterns
- multilingual design for English, Turkish, and Arabic
- RTL-aware layout support for Arabic
- clean architecture and scalable folder organization
- Supabase-ready backend structure with local demo mode for presentation

## Target Platforms

- Android
- iOS

The implementation is mobile-first and intentionally avoids web-specific or desktop-specific app logic.

## Key Features

- Authentication: sign up, login, logout, forgot password structure, persistent session
- Onboarding: feature introduction with skip / next / finish flow
- Home dashboard: welcome hero, today plan, progress, quick actions, achievements, recent activity
- Courses: create, edit, delete, color assignment, instructor field, course detail
- Tasks: create, edit, delete, subtasks, search, filters, sorting, status updates, archive completed
- Calendar / planner: monthly and weekly calendar formats with daily agenda
- Focus mode: Pomodoro timer with custom focus and break durations and saved session history
- Notes: create, edit, delete, pin, search, optional course linking
- Goals: daily / weekly / monthly study goals with progress management
- Analytics: study minutes, completed tasks, streaks, focus history, course distribution chart
- Notifications structure: local notification preview flow and reminder preference settings
- Profile and settings: edit profile, language switcher, theme mode selector, reminder toggles

## Screenshots

Add project screenshots here during presentation prep:

- `docs/screenshots/splash.png`
- `docs/screenshots/onboarding.png`
- `docs/screenshots/dashboard.png`
- `docs/screenshots/tasks.png`
- `docs/screenshots/calendar.png`
- `docs/screenshots/focus.png`
- `docs/screenshots/analytics.png`

## Technologies Used

- Flutter
- Riverpod
- GoRouter
- Supabase
- Shared Preferences
- Material 3
- Flutter internationalization (`gen_l10n`)
- Table Calendar
- FL Chart
- Flutter Local Notifications

## Architecture Summary

StudyFlow uses a clean, modular, feature-oriented structure:

- `core/`: constants, theme, localization, services, utilities, common widgets
- `shared/`: shared models, providers, repository abstractions, extensions
- `features/`: presentation modules for auth, onboarding, home, courses, tasks, calendar, focus, notes, analytics, goals, profile, and settings

The app runs in two modes:

1. Demo/local mode
   Uses Shared Preferences-backed repositories and seeded sample data so the app is runnable without backend credentials.
2. Supabase mode
   Uses Supabase auth and data repositories when `SUPABASE_URL` and `SUPABASE_ANON_KEY` are provided.

## Folder Structure Summary

```text
lib/
  app/
  core/
    constants/
    errors/
    localization/
    services/
    theme/
    utils/
    widgets/
  shared/
    data/
    extensions/
    models/
    providers/
  features/
    analytics/
    auth/
    calendar/
    courses/
    focus/
    goals/
    home/
    notes/
    onboarding/
    profile/
    settings/
    tasks/
supabase/
  migrations/
```

## Localization Support

StudyFlow supports:

- English (`en`)
- Turkish (`tr`)
- Arabic (`ar`)

All visible interface text is sourced through Flutter localization files in:

- `lib/core/localization/app_en.arb`
- `lib/core/localization/app_tr.arb`
- `lib/core/localization/app_ar.arb`

## RTL Support for Arabic

Arabic support is designed for full RTL usage:

- Flutter locale-based directionality is enabled automatically
- navigation, alignment, and component flow respect RTL layout
- labels and action text are localized
- settings allow switching language at runtime

## Accessibility Support Summary

The current implementation includes:

- large touch-friendly buttons and cards
- scalable Material typography
- readable spacing and contrast
- validation messages for forms
- empty, loading, and error states
- icons paired with labels instead of color-only meaning
- mobile-friendly hierarchy and structure suitable for beginner users

## Setup Requirements

- Flutter SDK `>=3.3.0 <4.0.0`
- Dart SDK compatible with the Flutter version above
- Android Studio and/or Xcode for mobile builds
- Supabase project if backend mode is desired

## Supabase Setup

1. Create a Supabase project.
2. Open the SQL migration file:
   - `supabase/migrations/001_initial_schema.sql`
3. Run the migration in the Supabase SQL editor.
4. Enable Email authentication in Supabase Auth.
5. Provide the app with:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

Example run command:

```bash
flutter run \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

If these values are not provided, the app falls back to local demo mode automatically.

## Environment and Configuration Notes

- Demo mode persists session and app data locally with Shared Preferences.
- Supabase mode is available through the repository layer without changing the UI architecture.
- Notification scheduling is scaffolded through `ReminderService`; deeper scheduling and permission polishing can be extended per platform.

## How to Run the Project

```bash
flutter pub get
flutter run
```

For a specific device:

```bash
flutter run -d android
flutter run -d ios
```

## How to Change App Name and Package / Bundle Identifiers

### App name

- Update `AppConstants.appName` in `lib/core/constants/app_constants.dart`
- Update platform-level app display names in:
  - `android/app/src/main/AndroidManifest.xml`
  - `ios/Runner/Info.plist`

### Android package name

- Change `applicationId` in `android/app/build.gradle.kts` or `build.gradle`
- Rename Kotlin package folders if needed

### iOS bundle identifier

- Open the iOS project in Xcode
- Update the Bundle Identifier under the Runner target

## Demo Credentials

The login screen is prefilled for presentation flow:

- Email: `student@studyflow.app`
- Password: `studyflow123`

You can also create a new account from the sign-up flow.

## Known Limitations

- Local demo mode is the default until Supabase keys are supplied
- Notification scheduling is preview-ready rather than fully production-scheduled
- Native platform branding assets and store metadata are not yet customized
- Some premium extensions, such as a dedicated global search screen and more advanced achievements, can be expanded further

## Future Improvements

- real scheduled notifications with full permission onboarding
- richer accessibility preferences such as reduced motion and larger layout presets
- file attachments for notes
- recurring tasks and smarter planner suggestions
- real-time sync indicators and offline conflict resolution
- richer onboarding illustrations and branded asset pack
- unit, widget, and integration tests

## Course Project Presentation Summary

StudyFlow can be presented as a mobile HCI project focused on:

- reducing student overload through information architecture and visual hierarchy
- supporting multilingual and RTL-first inclusive design
- balancing premium aesthetics with practical productivity workflows
- using clean architecture to keep the project scalable beyond a course demo
- demonstrating both frontend polish and backend readiness with Supabase
