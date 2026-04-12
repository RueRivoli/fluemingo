-- Remove the set_premium_status RPC that allowed any authenticated user
-- to self-grant premium status. Premium is now only set by the RevenueCat webhook.
revoke execute on function public.set_premium_status(boolean) from authenticated;
drop function if exists public.set_premium_status(boolean);
