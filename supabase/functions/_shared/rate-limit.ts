import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.49.8";

const DAILY_LIMITS: Record<string, { free: number; premium: number }> = {
  translate: { free: 20, premium: 100 },
  "generate-sentence": { free: 15, premium: 100 },
  "text-to-speech": { free: 15, premium: 60 },
};

/**
 * Check and increment the per-user daily rate limit for the given function.
 * Returns { allowed: true } or { allowed: false, response: Response }.
 */
export async function checkRateLimit(
  supabase: SupabaseClient,
  userId: string,
  functionName: string,
): Promise<{ allowed: true } | { allowed: false; response: Response }> {
  const limits = DAILY_LIMITS[functionName];
  if (!limits) {
    return { allowed: true };
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("is_premium")
    .eq("id", userId)
    .maybeSingle();

  const isPremium = profile?.is_premium === true;
  const dailyLimit = isPremium ? limits.premium : limits.free;

  const { data, error } = await supabase.rpc("check_rate_limit", {
    p_function_name: functionName,
    p_daily_limit: dailyLimit,
  });

  if (error || data === false) {
    return {
      allowed: false,
      response: new Response(
        JSON.stringify({
          error: "Rate limit exceeded",
          limit: dailyLimit,
          function: functionName,
        }),
        {
          status: 429,
          headers: { "Content-Type": "application/json" },
        },
      ),
    };
  }

  return { allowed: true };
}
