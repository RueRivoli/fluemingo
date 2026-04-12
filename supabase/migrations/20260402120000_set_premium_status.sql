-- RPC to let the app update is_premium for the authenticated user.
-- Used as a fast-path after RevenueCat purchase; the webhook is the source of truth.
create or replace function public.set_premium_status(p_is_premium boolean)
returns void
language plpgsql
security definer
as $$
begin
  update public.profiles
  set is_premium = p_is_premium
  where id = auth.uid();
end;
$$;

grant execute on function public.set_premium_status(boolean) to authenticated;
