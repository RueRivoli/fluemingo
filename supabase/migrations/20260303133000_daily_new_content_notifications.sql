-- Daily push notification support for new articles/audiobooks.

alter table public.profiles
  add column if not exists notification_tokens text[] not null default '{}',
  add column if not exists notifications_enabled boolean not null default true,
  add column if not exists notification_tokens_updated_at timestamptz null,
  add column if not exists last_new_content_notification_at timestamptz null;

comment on column public.profiles.notification_tokens is
  'Registered push tokens for this user (multi-device support).';
comment on column public.profiles.notifications_enabled is
  'Whether the user accepts push notifications.';
comment on column public.profiles.notification_tokens_updated_at is
  'Last time notification_tokens was updated.';
comment on column public.profiles.last_new_content_notification_at is
  'Last successful daily new-content push notification timestamp.';

create or replace function public.count_new_content_for_language(
  p_target_language text,
  p_content_type integer,
  p_since timestamptz
)
returns integer
language plpgsql
stable
as $$
declare
  normalized_language text;
  relation_name text;
  new_count integer;
begin
  normalized_language := lower(trim(coalesce(p_target_language, '')));

  if normalized_language = '' then
    return 0;
  end if;

  -- Defensive check before using the language code in dynamic SQL.
  if normalized_language !~ '^[a-z]{2}$' then
    return 0;
  end if;

  relation_name := format('public.%I_content', normalized_language);

  if to_regclass(relation_name) is null then
    return 0;
  end if;

  execute format(
    'select count(*)::int from %I_content where content_type = $1 and created_at >= $2',
    normalized_language
  )
  into new_count
  using p_content_type, p_since;

  return coalesce(new_count, 0);
end;
$$;

create or replace function public.get_profiles_to_notify_new_content(
  p_now timestamptz default now()
)
returns table (
  profile_id uuid,
  target_language text,
  notification_tokens text[],
  new_articles_count integer,
  new_audiobooks_count integer,
  message_title text,
  message_body text
)
language plpgsql
stable
as $$
declare
  profile_row record;
  since_ts timestamptz;
  article_count integer;
  audiobook_count integer;
begin
  for profile_row in
    select
      p.id,
      p.target_language,
      p.notification_tokens,
      p.last_new_content_notification_at
    from public.profiles p
    where p.notifications_enabled is true
      and coalesce(array_length(p.notification_tokens, 1), 0) > 0
      and p.target_language is not null
      and (
        p.last_new_content_notification_at is null
        or (p.last_new_content_notification_at at time zone 'UTC')::date
           < (p_now at time zone 'UTC')::date
      )
  loop
    since_ts := coalesce(
      profile_row.last_new_content_notification_at,
      p_now - interval '1 day'
    );

    article_count := public.count_new_content_for_language(
      profile_row.target_language,
      1,
      since_ts
    );

    audiobook_count := public.count_new_content_for_language(
      profile_row.target_language,
      2,
      since_ts
    );

    if article_count + audiobook_count > 0 then
      return query
      select
        profile_row.id::uuid,
        profile_row.target_language::text,
        profile_row.notification_tokens::text[],
        article_count,
        audiobook_count,
        'New content is available'::text,
        format(
          'You have %s new article%s and %s new audiobook%s to explore.',
          article_count,
          case when article_count = 1 then '' else 's' end,
          audiobook_count,
          case when audiobook_count = 1 then '' else 's' end
        )::text;
    end if;
  end loop;
end;
$$;

create or replace function public.mark_profiles_new_content_notified(
  p_profile_ids uuid[],
  p_notified_at timestamptz default now()
)
returns integer
language plpgsql
as $$
declare
  updated_rows integer;
begin
  if p_profile_ids is null or array_length(p_profile_ids, 1) is null then
    return 0;
  end if;

  update public.profiles p
  set last_new_content_notification_at = p_notified_at
  where p.id = any (p_profile_ids);

  get diagnostics updated_rows = row_count;
  return updated_rows;
end;
$$;

revoke all on function public.count_new_content_for_language(text, integer, timestamptz) from public;
revoke all on function public.get_profiles_to_notify_new_content(timestamptz) from public;
revoke all on function public.mark_profiles_new_content_notified(uuid[], timestamptz) from public;

grant execute on function public.count_new_content_for_language(text, integer, timestamptz) to service_role;
grant execute on function public.get_profiles_to_notify_new_content(timestamptz) to service_role;
grant execute on function public.mark_profiles_new_content_notified(uuid[], timestamptz) to service_role;

-- Optional scheduling example (Supabase SQL editor):
--
-- create extension if not exists pg_net with schema extensions;
-- create extension if not exists pg_cron with schema extensions;
--
-- select cron.schedule(
--   'daily-new-content-notifications',
--   '0 9 * * *',
--   $$
--   select net.http_post(
--     url := 'https://<project-ref>.supabase.co/functions/v1/daily-new-content-notifications',
--     headers := jsonb_build_object(
--       'Content-Type', 'application/json',
--       'Authorization', 'Bearer <service-role-key>'
--     ),
--     body := '{"source":"pg_cron"}'::jsonb
--   );
--   $$
-- );
