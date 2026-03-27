# StudyFlow Mobile Blueprint

## 1. Product Architecture

StudyFlow is a Flutter-first mobile product for Android and iOS with Supabase as the backend. The architecture is feature-oriented and intentionally presentation-ready:

- `app/`: app root and router
- `core/`: theme, localization, services, validators, shared widgets
- `features/`: auth, onboarding, home, tasks, calendar, focus, analytics, profile, settings
- `shared/data/`: repository contracts and local/Supabase implementations
- `shared/models/`: app-wide domain models
- `shared/providers/`: Riverpod controllers, derived state, and app session logic
- `supabase/migrations/`: SQL schema and RLS definitions

Why this matters for HCI:

- It keeps interaction rules consistent across screens.
- It lowers maintenance cost, which protects UI quality over time.
- It separates data and presentation so visual iteration stays fast.

## 2. Folder Structure

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
  features/
    analytics/
    auth/
    calendar/
    courses/
    exams/
    focus/
    goals/
    habits/
    home/
    notes/
    onboarding/
    profile/
    search/
    settings/
    tasks/
  shared/
    data/
    extensions/
    models/
    providers/
supabase/
  migrations/
docs/
```

## 3. Packages

- `flutter_riverpod`: state and dependency graph
- `go_router`: flow-safe navigation
- `supabase_flutter`: auth, database, storage
- `shared_preferences`: local-first demo mode
- `flutter_local_notifications`: reminders
- `fl_chart`: analytics
- `table_calendar`: planner/calendar
- `google_fonts`: premium typography
- `image_picker`: mobile avatar upload
- `uuid`, `intl`, `collection`

## 4. UI Design System

Visual direction:

- Deep ambient gradients instead of flat scaffold colors
- Glass-inspired cards with soft borders and layered shadows
- Large rounded geometry for mobile friendliness
- High-contrast typography with deliberate whitespace
- Premium stat surfaces and identity-first profile layout

HCI rationale:

- Rounded large targets improve touch accuracy.
- Layered cards create strong hierarchy, reducing search time.
- Repeated card language increases learnability.

## 5. Color Palette

- Primary: deep Atlantic blue
- Secondary: aqua-mint
- Tertiary: warm amber
- Danger: muted coral
- Surface: frosted white or dark navy glass
- Background: soft luminous gradient

Why:

- Blue anchors trust and academic seriousness.
- Mint signals progress and calm focus.
- Amber highlights urgency without aggressive red overuse.

## 6. Typography System

- Latin: `Plus Jakarta Sans`
- Arabic: `Noto Sans Arabic`
- Headings: 700-800 weight
- Body: 1.4 line-height minimum
- Labels: 600-700 weight for quick scanning

Why:

- Rounded modern sans fonts support premium SaaS quality.
- Arabic-specific font avoids broken joins and awkward rhythm.

## 7. Motion Principles

- Reveal on build for sections and hero blocks
- Animated counters for performance metrics
- Progress rings and animated bars for visual feedback
- Motion kept under one second for responsiveness
- No toy-like elastic motion on critical flows

Why:

- Motion is used as orientation feedback, not decoration alone.
- Short durations preserve perceived speed.

## 8. Page Inventory

- Splash
- Onboarding
- Login
- Signup
- Forgot password
- Dashboard
- Tasks
- Calendar
- Focus mode
- Analytics
- Profile
- Profile edit
- Settings
- Courses
- Notes
- Exams
- Habits
- Search

## 9. Component Inventory

- `AppPage`
- `SectionCard`
- `GradientBanner`
- `RevealOnBuild`
- `AnimatedMetricValue`
- `ProgressRing`
- `WeekSparkBars`
- `MetricTile`
- `StatusPill`
- `EmptyState`
- `ErrorStateCard`
- `QuickActionTile`
- `ProfileAvatar`

## 10. Database Schema

Core tables:

- `profiles`: identity, avatar, language, theme, bio, academic context
- `study_plans`: daily/weekly/monthly planning containers
- `subjects` or `courses`: course metadata and color system
- `tasks`: tasks, deadlines, priority, status, estimates
- `study_sessions`: focus sessions and Pomodoro history
- `achievements`: badge logic and progress
- `settings`: notification/theme/accessibility preferences
- `notifications`: reminder center

Why each exists:

- `profiles` supports personal identity and settings sync.
- `study_plans` models explicit planning artifacts for the planner UX.
- `tasks` and `study_sessions` power progress visibility.
- `achievements` turns effort into visible feedback.
- `notifications` supports system status and reminders.

RLS rule pattern:

- Every user-owned table enforces `auth.uid() = user_id`.
- Child records inherit ownership through foreign keys.
- Storage policies restrict writes to user folders.

## 11. Supabase Setup

1. Create a new Supabase project.
2. Copy project URL and anon key.
3. Run Flutter with:

```bash
flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

4. Apply SQL migrations in `supabase/migrations/`.
5. Create the `avatars` bucket.

Local development model:

- If Supabase env vars are missing, the app falls back to local demo mode.
- This makes demos resilient and keeps UI iteration fast.

## 12. Auth Flow

- Email/password sign up creates auth user plus profile row.
- Login restores the profile and seeds local demo data when needed.
- Session persistence is handled by `supabase_flutter`.
- `AuthController` listens to auth state changes and refreshes UI state.
- Protected navigation is enforced by the splash gate and router entry flow.

## 13. Google Auth

Flutter mobile strategy:

- Use Supabase OAuth with PKCE.
- Redirect URI in this app is `com.mohamedahmet.studyflow://login-callback/`.

Google Cloud steps:

1. Open Google Cloud Console.
2. Create or select a project.
3. Configure OAuth consent screen.
4. Add Supabase redirect URL from the Supabase Google provider page.
5. Create OAuth credentials.

Supabase steps:

1. Enable Google provider.
2. Paste Google client ID and secret.
3. Add mobile redirect URL to allowed redirects.

Common issues:

- Redirect mismatch: ensure exact URI match.
- Consent screen not published: OAuth will fail for non-test users.
- Missing Android/iOS deep links: the browser returns but the app does not capture the session.

Security notes:

- Use PKCE for mobile.
- Never ship the service role key inside the app.
- Restrict all user data with RLS.

## 14. Profile Page Strategy

The profile page is intentionally not a plain settings list. It acts as a productivity identity surface:

- hero banner with avatar, username, streak, and quick identity chips
- animated counters for XP, tasks, weekly focus
- progress ring for weekly target completion
- mini weekly bar chart
- editable academic identity fields
- action area for settings and security

HCI rationale:

- Users immediately see who they are, how they are doing, and what to change.
- This reduces hidden information and increases system transparency.

## 15. Dashboard Strategy

- top command-center banner
- today metrics
- quick actions
- deadlines and routines
- motivation card
- progress to daily/weekly/monthly goals

Why:

- It supports recognition over recall.
- Users can act without navigating through heavy menus.

## 16. Study Planner Flow

1. Add subjects with consistent color identity.
2. Create tasks with deadlines, priority, and estimates.
3. Plan day/week/month through calendar and goals.
4. Run focus sessions.
5. Review analytics and adjust routine.

## 17. Responsive Mobile Strategy

- Single-column layouts only
- Dense cards split into smaller vertical stacks
- Touch targets stay large
- Charts and metrics use compact cards with legible spacing

## 18. Accessibility Strategy

- Strong contrast on dark mode
- Large tap zones
- Label-based inputs, not placeholder-only
- Progressive disclosure instead of overcrowded screens
- Motion used carefully so it supports orientation

## 19. RTL and Arabic Support

Recommended Arabic font:

- Primary: `Noto Sans Arabic`
- Fallbacks: `SF Arabic`, system Arabic sans, generic `sans-serif`

Best practices:

- Switch typography by locale instead of forcing one font family globally.
- Use `Directionality` from Flutter locale resolution so layout mirrors correctly.
- Increase line-height for Arabic text to at least `1.45`.
- Avoid positive letter-spacing on Arabic.
- Keep font weight between 400 and 700 for body/content.
- Use separate headline tuning if Arabic headings feel too dense.

Mixed Latin + Arabic strategy:

- Use Arabic font for Arabic locale.
- Keep numbers and metric chips visually stable with medium-weight styles.
- Test usernames and email strings inside RTL layouts.

Rendering safety:

- Do not use fonts with weak Arabic shaping.
- Avoid text clipping inside tightly constrained pills.
- Prefer generous vertical padding in buttons and chips.

## 20. Roadmap

1. Finalize premium theme tokens and background language.
2. Complete auth polishing and verify OAuth callbacks on device.
3. Expand profile editing and avatar storage on Supabase.
4. Connect planner views to `study_plans`.
5. Add push/reminder orchestration.
6. Add smart rescheduling and AI study suggestion mocks.
7. Run usability tests for HCI evaluation.
