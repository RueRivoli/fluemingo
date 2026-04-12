import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.8";

/** RevenueCat event types that grant premium access. */
const PREMIUM_EVENTS = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
  "PRODUCT_CHANGE",
  "NON_RENEWING_PURCHASE",
]);

/** RevenueCat event types that revoke premium access. */
const REVOKE_EVENTS = new Set([
  "EXPIRATION",
]);

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  // Validate webhook authorization
  const expectedKey = Deno.env.get("REVENUECAT_WEBHOOK_AUTH_KEY");
  if (!expectedKey) {
    return json({ error: "Missing REVENUECAT_WEBHOOK_AUTH_KEY" }, 500);
  }

  const authHeader = request.headers.get("authorization");
  if (authHeader !== `Bearer ${expectedKey}`) {
    return json({ error: "Unauthorized" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) {
    return json(
      { error: "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY" },
      500,
    );
  }

  let body: { event?: { type?: string; app_user_id?: string } };
  try {
    body = await request.json();
  } catch {
    return json({ error: "Invalid JSON body" }, 400);
  }

  const eventType = body?.event?.type;
  const appUserId = body?.event?.app_user_id;

  if (!eventType || !appUserId) {
    return json({ error: "Missing event.type or event.app_user_id" }, 400);
  }

  // Determine new premium status
  let isPremium: boolean | null = null;
  if (PREMIUM_EVENTS.has(eventType)) {
    isPremium = true;
  } else if (REVOKE_EVENTS.has(eventType)) {
    isPremium = false;
  }

  // Event type doesn't affect premium status (e.g. CANCELLATION — user keeps access until expiration)
  if (isPremium === null) {
    return json({ event_type: eventType, action: "ignored" });
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  const { error } = await supabase
    .from("profiles")
    .update({ is_premium: isPremium })
    .eq("id", appUserId);

  if (error) {
    return json(
      { error: "Failed to update profile", details: error.message },
      500,
    );
  }

  return json({
    event_type: eventType,
    app_user_id: appUserId,
    is_premium: isPremium,
  });
});
