create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  metadata jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  preferred_language_value text := case
    when metadata ->> 'preferred_language' in ('en', 'tr', 'ar')
      then metadata ->> 'preferred_language'
    else 'en'
  end;
  theme_mode_value text := case
    when metadata ->> 'theme_mode' in ('system', 'light', 'dark')
      then metadata ->> 'theme_mode'
    else 'system'
  end;
begin
  insert into public.profiles (
    id,
    full_name,
    email,
    username,
    bio,
    preferred_language,
    theme_mode
  )
  values (
    new.id,
    coalesce(metadata ->> 'full_name', ''),
    coalesce(new.email, ''),
    nullif(metadata ->> 'username', ''),
    coalesce(metadata ->> 'bio', ''),
    preferred_language_value,
    theme_mode_value
  )
  on conflict (id) do nothing;

  insert into public.user_settings (user_id, language, theme_mode)
  values (new.id, preferred_language_value, theme_mode_value)
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

update public.profiles as profiles
set
  full_name = case
    when coalesce(profiles.full_name, '') = ''
      then coalesce(users.raw_user_meta_data ->> 'full_name', profiles.full_name, '')
    else profiles.full_name
  end,
  email = case
    when coalesce(profiles.email, '') = ''
      then coalesce(users.email, profiles.email, '')
    else profiles.email
  end,
  username = coalesce(
    profiles.username,
    nullif(users.raw_user_meta_data ->> 'username', '')
  ),
  bio = case
    when coalesce(profiles.bio, '') = ''
      then coalesce(users.raw_user_meta_data ->> 'bio', '')
    else profiles.bio
  end,
  preferred_language = case
    when profiles.preferred_language = 'en'
      and users.raw_user_meta_data ->> 'preferred_language' in ('tr', 'ar')
      then users.raw_user_meta_data ->> 'preferred_language'
    else profiles.preferred_language
  end,
  theme_mode = case
    when profiles.theme_mode = 'system'
      and users.raw_user_meta_data ->> 'theme_mode' in ('light', 'dark')
      then users.raw_user_meta_data ->> 'theme_mode'
    else profiles.theme_mode
  end
from auth.users as users
where profiles.id = users.id;

update public.user_settings as settings
set
  language = profiles.preferred_language,
  theme_mode = profiles.theme_mode
from public.profiles as profiles
where settings.user_id = profiles.id
  and (
    settings.language is distinct from profiles.preferred_language or
    settings.theme_mode is distinct from profiles.theme_mode
  );
