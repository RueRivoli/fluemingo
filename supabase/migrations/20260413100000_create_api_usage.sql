-- Per-user daily rate limiting for Edge Functions that call paid APIs.
create table if not exists public.api_usage (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  function_name text not null,
  usage_date date not null default current_date,
  request_count int not null default 0,
  constraint api_usage_unique unique (user_id, function_name, usage_date)
);

alter table public.api_usage enable row level security;

-- Users can only read their own usage.
create policy "Users can read own usage"
  on public.api_usage for select
  using (auth.uid() = user_id);

-- No direct insert/update from clients; only the check_rate_limit function (security definer) writes.

-- Atomically increment usage and return whether the request is allowed.
-- Returns true if under the limit, false if rate-limited.
create or replace function public.check_rate_limit(
  p_function_name text,
  p_daily_limit int
)
returns boolean
language plpgsql
security definer
as $$
declare
  v_count int;
begin
  insert into public.api_usage (user_id, function_name, usage_date, request_count)
  values (auth.uid(), p_function_name, current_date, 1)
  on conflict (user_id, function_name, usage_date)
  do update set request_count = api_usage.request_count + 1
  where api_usage.request_count < p_daily_limit
  returning request_count into v_count;

  return v_count is not null;
end;
$$;

grant execute on function public.check_rate_limit(text, int) to authenticated;

-- Index for fast lookups.
create index if not exists idx_api_usage_user_date
  on public.api_usage (user_id, function_name, usage_date);
