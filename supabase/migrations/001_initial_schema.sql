create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '',
  email text not null unique,
  avatar_url text,
  preferred_language text not null default 'en' check (preferred_language in ('en', 'tr', 'ar')),
  theme_mode text not null default 'system' check (theme_mode in ('system', 'light', 'dark')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  description text not null default '',
  instructor_name text,
  color bigint not null default 4061291,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  course_id uuid references public.courses (id) on delete set null,
  title text not null,
  description text not null default '',
  due_date_time timestamptz,
  priority text not null default 'medium' check (priority in ('low', 'medium', 'high', 'urgent')),
  status text not null default 'pending' check (status in ('pending', 'inProgress', 'completed')),
  estimated_minutes integer not null default 0,
  is_archived boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.subtasks (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks (id) on delete cascade,
  title text not null,
  is_completed boolean not null default false,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  course_id uuid references public.courses (id) on delete set null,
  title text not null,
  content text not null default '',
  is_pinned boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.exams (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  course_id uuid references public.courses (id) on delete set null,
  title text not null,
  description text not null default '',
  date_time timestamptz not null,
  type text not null default 'exam' check (type in ('exam', 'assignment', 'quiz')),
  priority text not null default 'high' check (priority in ('low', 'medium', 'high', 'urgent')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  description text not null default '',
  color bigint not null default 2863098,
  frequency text not null default 'daily' check (frequency in ('daily', 'weekly')),
  goal_count integer not null default 1,
  completed_count integer not null default 0,
  streak_count integer not null default 0,
  last_completed_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  task_id uuid references public.tasks (id) on delete set null,
  course_id uuid references public.courses (id) on delete set null,
  start_time timestamptz not null,
  end_time timestamptz not null,
  duration_minutes integer not null default 0,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles (id) on delete cascade,
  daily_target_minutes integer not null default 120,
  weekly_target_minutes integer not null default 600,
  monthly_target_minutes integer not null default 2400,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.user_settings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles (id) on delete cascade,
  language text not null default 'en' check (language in ('en', 'tr', 'ar')),
  theme_mode text not null default 'system' check (theme_mode in ('system', 'light', 'dark')),
  notifications_enabled boolean not null default true,
  accessibility_mode boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.reminder_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles (id) on delete cascade,
  tasks_enabled boolean not null default true,
  study_enabled boolean not null default true,
  daily_enabled boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists courses_user_id_idx on public.courses (user_id);
create index if not exists tasks_user_id_idx on public.tasks (user_id);
create index if not exists tasks_course_id_idx on public.tasks (course_id);
create index if not exists notes_user_id_idx on public.notes (user_id);
create index if not exists exams_user_id_idx on public.exams (user_id);
create index if not exists exams_course_id_idx on public.exams (course_id);
create index if not exists habits_user_id_idx on public.habits (user_id);
create index if not exists study_sessions_user_id_idx on public.study_sessions (user_id);
create index if not exists subtasks_task_id_idx on public.subtasks (task_id);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists courses_set_updated_at on public.courses;
create trigger courses_set_updated_at
before update on public.courses
for each row execute function public.set_updated_at();

drop trigger if exists tasks_set_updated_at on public.tasks;
create trigger tasks_set_updated_at
before update on public.tasks
for each row execute function public.set_updated_at();

drop trigger if exists notes_set_updated_at on public.notes;
create trigger notes_set_updated_at
before update on public.notes
for each row execute function public.set_updated_at();

drop trigger if exists exams_set_updated_at on public.exams;
create trigger exams_set_updated_at
before update on public.exams
for each row execute function public.set_updated_at();

drop trigger if exists habits_set_updated_at on public.habits;
create trigger habits_set_updated_at
before update on public.habits
for each row execute function public.set_updated_at();

drop trigger if exists goals_set_updated_at on public.goals;
create trigger goals_set_updated_at
before update on public.goals
for each row execute function public.set_updated_at();

drop trigger if exists user_settings_set_updated_at on public.user_settings;
create trigger user_settings_set_updated_at
before update on public.user_settings
for each row execute function public.set_updated_at();

drop trigger if exists reminder_preferences_set_updated_at on public.reminder_preferences;
create trigger reminder_preferences_set_updated_at
before update on public.reminder_preferences
for each row execute function public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.courses enable row level security;
alter table public.tasks enable row level security;
alter table public.subtasks enable row level security;
alter table public.notes enable row level security;
alter table public.exams enable row level security;
alter table public.habits enable row level security;
alter table public.study_sessions enable row level security;
alter table public.goals enable row level security;
alter table public.user_settings enable row level security;
alter table public.reminder_preferences enable row level security;

create policy "profiles_select_own" on public.profiles
for select using (auth.uid() = id);
create policy "profiles_update_own" on public.profiles
for update using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles
for insert with check (auth.uid() = id);

create policy "courses_own_all" on public.courses
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "tasks_own_all" on public.tasks
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "subtasks_own_all" on public.subtasks
for all using (
  exists (
    select 1 from public.tasks
    where tasks.id = subtasks.task_id and tasks.user_id = auth.uid()
  )
) with check (
  exists (
    select 1 from public.tasks
    where tasks.id = subtasks.task_id and tasks.user_id = auth.uid()
  )
);

create policy "notes_own_all" on public.notes
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "exams_own_all" on public.exams
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "habits_own_all" on public.habits
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "sessions_own_all" on public.study_sessions
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "goals_own_all" on public.goals
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "settings_own_all" on public.user_settings
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "reminders_own_all" on public.reminder_preferences
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    coalesce(new.email, '')
  )
  on conflict (id) do nothing;

  insert into public.user_settings (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  insert into public.reminder_preferences (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  insert into public.goals (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();
