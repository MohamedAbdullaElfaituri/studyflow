alter table public.profiles
  add column if not exists username text unique,
  add column if not exists bio text not null default '',
  add column if not exists university text,
  add column if not exists department text;

create table if not exists public.study_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  view_mode text not null default 'weekly'
    check (view_mode in ('daily', 'weekly', 'monthly')),
  start_date date not null,
  end_date date not null,
  ai_summary text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  slug text not null,
  title text not null,
  description text not null default '',
  icon text not null default 'workspace_premium',
  progress integer not null default 0,
  target integer not null default 1,
  unlocked_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  unique (user_id, slug)
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  type text not null default 'reminder'
    check (type in ('reminder', 'deadline', 'achievement', 'system')),
  title text not null,
  body text not null,
  deep_link text,
  scheduled_for timestamptz,
  is_read boolean not null default false,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists study_plans_user_id_idx on public.study_plans (user_id);
create index if not exists achievements_user_id_idx on public.achievements (user_id);
create index if not exists notifications_user_id_idx on public.notifications (user_id);

drop trigger if exists study_plans_set_updated_at on public.study_plans;
create trigger study_plans_set_updated_at
before update on public.study_plans
for each row execute function public.set_updated_at();

drop trigger if exists achievements_set_updated_at on public.achievements;
create trigger achievements_set_updated_at
before update on public.achievements
for each row execute function public.set_updated_at();

alter table public.study_plans enable row level security;
alter table public.achievements enable row level security;
alter table public.notifications enable row level security;

create policy "study_plans_own_all" on public.study_plans
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "achievements_own_all" on public.achievements
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "notifications_own_all" on public.notifications
for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "avatars_public_read" on storage.objects;
create policy "avatars_public_read" on storage.objects
for select using (bucket_id = 'avatars');

drop policy if exists "avatars_owner_insert" on storage.objects;
create policy "avatars_owner_insert" on storage.objects
for insert to authenticated with check (
  bucket_id = 'avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "avatars_owner_update" on storage.objects;
create policy "avatars_owner_update" on storage.objects
for update to authenticated using (
  bucket_id = 'avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
) with check (
  bucket_id = 'avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "avatars_owner_delete" on storage.objects;
create policy "avatars_owner_delete" on storage.objects
for delete to authenticated using (
  bucket_id = 'avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
);
