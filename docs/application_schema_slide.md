# StudyFlow Slayt Icin Tek Sayfalik Sema

Bu sema sunuma koymak icin sade tutuldu. Detayli teknik sema
`docs/application_schema.md` dosyasinda duruyor.

```mermaid
flowchart LR
    User["Kullanici"]
    App["StudyFlow Flutter App<br/>MaterialApp + GoRouter"]
    Riverpod["Riverpod State Layer<br/>AuthController + StudyDataController"]
    Repos["Repository Layer<br/>AuthRepository + StudyRepository"]
    Mode{"Backend Mode"}
    Local["Local Demo Mode<br/>SharedPreferences<br/>DemoSeedService"]
    Cloud["Supabase Cloud Mode<br/>Auth + Postgres + Storage"]

    Features["Uygulama Ekranlari<br/>Home, Tasks, Calendar, Focus, Profile,<br/>Courses, Notes, Exams, Habits, Goals, Settings"]
    Data["Study Data<br/>courses, tasks, subtasks, notes,<br/>exams, habits, study_sessions,<br/>goals, user_settings, reminders"]

    User --> App
    App --> Features
    Features --> Riverpod
    Riverpod --> Repos
    Repos --> Mode
    Mode -->|"Supabase anahtarlari yoksa"| Local
    Mode -->|"Supabase anahtarlari varsa"| Cloud
    Local --> Data
    Cloud --> Data
    Data --> Riverpod
    Riverpod --> App
```

## Slayt Altina Kisa Aciklama

StudyFlow, Flutter ile gelistirilmis bir calisma planlama uygulamasidir.
Uygulama acildiginda GoRouter kullaniciyi auth durumuna gore yonlendirir.
Ekranlar veriye dogrudan erismez; Riverpod controller katmani uzerinden
repository katmanina gider. Supabase ayarlari varsa veri bulutta saklanir,
yoksa uygulama local demo modda SharedPreferences ile calisir.

## Sunum Icin Daha Kisa Versiyon

StudyFlow'da kullanici islemleri once Flutter ekranlarindan Riverpod state
katmanina gider. Auth ve study data controller'lari repository katmanini
kullanarak veriyi local demo modda SharedPreferences'a, cloud modda ise
Supabase Auth, Postgres ve Storage'a yazar.
