# StudyFlow Uygulama Calisma Semasi

Bu dokuman, mevcut koda gore StudyFlow uygulamasinin nasil acildigini,
hangi katmanlardan gectigini ve verinin local demo ya da Supabase modunda
nereye yazildigini gosterir.

## 1. Genel Uygulama Akisi

```mermaid
flowchart TD
    User["Kullanici"]
    OS["Android / iOS / Web / Windows"]
    Main["main.dart<br/>WidgetsFlutterBinding<br/>Portrait lock"]
    SupabaseInit{"SupabaseService.initialize()<br/>SUPABASE_URL + ANON_KEY var mi?"}
    SupabaseMode["BackendMode.supabase<br/>Supabase.initialize(PKCE, deep link)"]
    LocalMode["BackendMode.local<br/>Supabase baslatilmaz"]
    Storage["LocalStorageService<br/>SharedPreferences"]
    Reminder["ReminderService<br/>flutter_local_notifications"]
    ProviderScope["ProviderScope overrides<br/>storage + reminders"]
    App["StudyFlowApp<br/>MaterialApp.router"]
    ThemeLocale["Theme / Locale / Accessibility<br/>Riverpod providers"]
    Router["GoRouter<br/>AppRouter.build"]
    AuthCtrl["AuthController<br/>oturum + onboarding + password reset"]
    StudyCtrl["StudyDataController<br/>kurs, gorev, not, sinav, aliskanlik,<br/>oturum, hedef, ayar, hatirlatici"]

    User --> OS --> Main
    Main --> SupabaseInit
    SupabaseInit -->|Anahtarlar var| SupabaseMode
    SupabaseInit -->|Anahtarlar yok| LocalMode
    Main --> Storage
    Main --> Reminder
    SupabaseMode --> ProviderScope
    LocalMode --> ProviderScope
    Storage --> ProviderScope
    Reminder --> ProviderScope
    ProviderScope --> App
    App --> ThemeLocale
    App --> Router
    Router --> AuthCtrl
    AuthCtrl --> StudyCtrl
```

## 2. Repository Secimi ve Veri Katmani

```mermaid
flowchart LR
    BackendMode{"backendModeProvider"}

    AuthRepo{"authRepositoryProvider"}
    StudyRepo{"studyRepositoryProvider"}

    LocalAuth["LocalAuthRepository<br/>demo login, local signup,<br/>onboarding, local profile"]
    LocalStudy["LocalStudyRepository<br/>SharedPreferences koleksiyonlari<br/>DemoSeedService ile seed"]

    SupabaseAuth["SupabaseAuthRepository<br/>email/password, Google OAuth,<br/>password reset, profile, avatar"]
    SupabaseStudy["SupabaseStudyRepository<br/>Supabase tablolarina CRUD"]

    SharedPrefs[("SharedPreferences")]
    SupabaseAuthSvc["Supabase Auth<br/>auth.users + PKCE"]
    SupabaseDb[("Supabase Postgres<br/>RLS protected tables")]
    SupabaseStorage[("Supabase Storage<br/>avatars bucket")]

    BackendMode -->|local| AuthRepo
    BackendMode -->|local| StudyRepo
    BackendMode -->|supabase| AuthRepo
    BackendMode -->|supabase| StudyRepo

    AuthRepo -->|local| LocalAuth --> SharedPrefs
    StudyRepo -->|local| LocalStudy --> SharedPrefs

    AuthRepo -->|supabase| SupabaseAuth --> SupabaseAuthSvc
    SupabaseAuth --> SupabaseDb
    SupabaseAuth --> SupabaseStorage
    StudyRepo -->|supabase| SupabaseStudy --> SupabaseDb
```

## 3. Acilis ve Yonlendirme Karari

```mermaid
flowchart TD
    Start["Uygulama acilir"]
    SplashDone{"launchSplashCompleted?"}
    AuthLoading{"authControllerProvider<br/>loading mi?"}
    AuthState{"AuthViewState hazir mi?"}
    AuthNavPending{"Google/deep link auth<br/>beklemede mi?"}
    PasswordReset{"requiresPasswordReset?"}
    IsAuthed{"user var mi?"}
    StudyLoading{"studyDataControllerProvider<br/>ilk veri yukleniyor mu?"}
    Onboarding{"onboardingCompleted?"}

    Splash["/splash"]
    AuthLoadingScreen["/auth-loading"]
    Reset["/reset-password"]
    Home["/home"]
    OnboardingScreen["/onboarding"]
    Login["/login"]

    Start --> SplashDone
    SplashDone -->|Hayir| Splash
    SplashDone -->|Evet| AuthLoading
    AuthLoading -->|Evet| Splash
    AuthLoading -->|Hayir| AuthState
    AuthState -->|Hazir degil| Splash
    AuthState -->|Hazir| AuthNavPending
    AuthNavPending -->|Evet ve user yok| AuthLoadingScreen
    AuthNavPending -->|Hayir| PasswordReset
    PasswordReset -->|Evet| Reset
    PasswordReset -->|Hayir| IsAuthed
    IsAuthed -->|Evet| StudyLoading
    StudyLoading -->|Evet| AuthLoadingScreen
    StudyLoading -->|Hayir| Home
    IsAuthed -->|Hayir| Onboarding
    Onboarding -->|Hayir| OnboardingScreen
    Onboarding -->|Evet| Login
```

## 4. Ekranlar ve Islem Akisi

```mermaid
flowchart TD
    Shell["MainNavigationShell<br/>bottom navigation"]
    Home["HomeScreen<br/>ozet, bugunku gorevler,<br/>hedef ve ilerleme"]
    Tasks["TasksScreen<br/>TaskDetail / TaskEditor"]
    Calendar["CalendarScreen<br/>takvim gorunumu"]
    Focus["FocusScreen<br/>pomodoro / study session"]
    Profile["ProfileScreen<br/>ProfileEditScreen"]

    Extra["Detay ekranlari"]
    Courses["Courses<br/>CourseDetail / CourseEditor"]
    Notes["Notes<br/>NoteEditor"]
    Exams["Exams<br/>ExamEditor"]
    Habits["Habits<br/>HabitEditor"]
    Analytics["Analytics"]
    Goals["Goals"]
    Search["Search"]
    Settings["Settings"]

    StudyCtrl["StudyDataController"]
    AuthCtrl["AuthController"]
    Repository["StudyRepository / AuthRepository"]

    Shell --> Home
    Shell --> Tasks
    Shell --> Calendar
    Shell --> Focus
    Shell --> Profile

    Home --> Extra
    Tasks --> Extra
    Profile --> Extra
    Extra --> Courses
    Extra --> Notes
    Extra --> Exams
    Extra --> Habits
    Extra --> Analytics
    Extra --> Goals
    Extra --> Search
    Extra --> Settings

    Home --> StudyCtrl
    Tasks --> StudyCtrl
    Calendar --> StudyCtrl
    Focus -->|"addStudySession()"| StudyCtrl
    Courses --> StudyCtrl
    Notes --> StudyCtrl
    Exams --> StudyCtrl
    Habits -->|"completeHabit(), saveHabit()"| StudyCtrl
    Goals --> StudyCtrl
    Settings -->|"updateSettings(), signOut()"| StudyCtrl
    Settings --> AuthCtrl
    Profile --> AuthCtrl

    StudyCtrl --> Repository
    AuthCtrl --> Repository
```

## 5. Supabase Veritabani ER Semasi

Bu ER semasi `supabase/migrations/001_initial_schema.sql`,
`002_mobile_premium_upgrade.sql` ve `003_auth_profile_defaults.sql`
dosyalarina gore hazirlanmistir.

```mermaid
erDiagram
    AUTH_USERS ||--|| PROFILES : "id"
    PROFILES ||--o{ COURSES : "user_id"
    PROFILES ||--o{ TASKS : "user_id"
    PROFILES ||--o{ NOTES : "user_id"
    PROFILES ||--o{ EXAMS : "user_id"
    PROFILES ||--o{ HABITS : "user_id"
    PROFILES ||--o{ STUDY_SESSIONS : "user_id"
    PROFILES ||--|| GOALS : "user_id unique"
    PROFILES ||--|| USER_SETTINGS : "user_id unique"
    PROFILES ||--|| REMINDER_PREFERENCES : "user_id unique"
    PROFILES ||--o{ STUDY_PLANS : "user_id"
    PROFILES ||--o{ ACHIEVEMENTS : "user_id"
    PROFILES ||--o{ NOTIFICATIONS : "user_id"

    COURSES ||--o{ TASKS : "course_id set null"
    COURSES ||--o{ NOTES : "course_id set null"
    COURSES ||--o{ EXAMS : "course_id set null"
    COURSES ||--o{ STUDY_SESSIONS : "course_id set null"
    TASKS ||--o{ SUBTASKS : "task_id cascade"
    TASKS ||--o{ STUDY_SESSIONS : "task_id set null"

    AUTH_USERS {
        uuid id PK
        text email
    }

    PROFILES {
        uuid id PK
        text full_name
        text email UK
        text username UK
        text bio
        text avatar_url
        text university
        text department
        text preferred_language
        text theme_mode
        timestamptz created_at
        timestamptz updated_at
    }

    COURSES {
        uuid id PK
        uuid user_id FK
        text title
        text description
        text instructor_name
        bigint color
        timestamptz created_at
        timestamptz updated_at
    }

    TASKS {
        uuid id PK
        uuid user_id FK
        uuid course_id FK
        text title
        text description
        timestamptz due_date_time
        text priority
        text status
        int estimated_minutes
        boolean is_archived
        timestamptz created_at
        timestamptz updated_at
    }

    SUBTASKS {
        uuid id PK
        uuid task_id FK
        text title
        boolean is_completed
        timestamptz created_at
    }

    NOTES {
        uuid id PK
        uuid user_id FK
        uuid course_id FK
        text title
        text content
        boolean is_pinned
        timestamptz created_at
        timestamptz updated_at
    }

    EXAMS {
        uuid id PK
        uuid user_id FK
        uuid course_id FK
        text title
        text description
        timestamptz date_time
        text type
        text priority
        timestamptz created_at
        timestamptz updated_at
    }

    HABITS {
        uuid id PK
        uuid user_id FK
        text title
        text description
        bigint color
        text frequency
        int goal_count
        int completed_count
        int streak_count
        timestamptz last_completed_at
        timestamptz created_at
        timestamptz updated_at
    }

    STUDY_SESSIONS {
        uuid id PK
        uuid user_id FK
        uuid task_id FK
        uuid course_id FK
        timestamptz start_time
        timestamptz end_time
        int duration_minutes
        timestamptz created_at
    }

    GOALS {
        uuid id PK
        uuid user_id FK
        int daily_target_minutes
        int weekly_target_minutes
        int monthly_target_minutes
        timestamptz created_at
        timestamptz updated_at
    }

    USER_SETTINGS {
        uuid id PK
        uuid user_id FK
        text language
        text theme_mode
        boolean notifications_enabled
        boolean accessibility_mode
        timestamptz created_at
        timestamptz updated_at
    }

    REMINDER_PREFERENCES {
        uuid id PK
        uuid user_id FK
        boolean tasks_enabled
        boolean study_enabled
        boolean daily_enabled
        timestamptz created_at
        timestamptz updated_at
    }

    STUDY_PLANS {
        uuid id PK
        uuid user_id FK
        text title
        text view_mode
        date start_date
        date end_date
        text ai_summary
        timestamptz created_at
        timestamptz updated_at
    }

    ACHIEVEMENTS {
        uuid id PK
        uuid user_id FK
        text slug
        text title
        text description
        text icon
        int progress
        int target
        timestamptz unlocked_at
        timestamptz created_at
        timestamptz updated_at
    }

    NOTIFICATIONS {
        uuid id PK
        uuid user_id FK
        text type
        text title
        text body
        text deep_link
        timestamptz scheduled_for
        boolean is_read
        timestamptz created_at
    }
```

## 6. En Kritik Davranislar

- Supabase anahtarlari yoksa uygulama crash olmaz; local demo moda gecer.
- Local modda auth, profil ve study data `SharedPreferences` uzerinde tutulur.
- Supabase modda auth islemleri Supabase Auth ile; uygulama verileri Supabase
  tablolarinda RLS ile sadece kullanicinin kendi verisine aciktir.
- Kullanici login/signup/Google OAuth ile oturum actiginda `AuthController`
  profil bilgisini alir, `StudyRepository.ensureSeeded()` cagrilir, sonra
  `StudyDataController` tum ana koleksiyonlari yukler.
- Ekranlar dogrudan veritabanina gitmez; Riverpod controller ve repository
  katmani uzerinden okuma/yazma yapar.
- Ayar degisikligi once Riverpod state/local preference tarafina yansir,
  sonra repository uzerinden kalici hale getirilir.
- Focus ekrani calisma suresi bitince `addStudySession()` ile yeni
  `study_sessions` kaydi olusturur.
- Habit tamamlama `completeHabit()` ile `completed_count`, gerekirse
  `streak_count` gunceller.
