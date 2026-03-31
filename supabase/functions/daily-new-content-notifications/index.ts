import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.8";

type NotificationCandidate = {
  profile_id: string;
  target_language: string;
  notification_tokens: string[];
  new_articles_count: number;
  new_audiobooks_count: number;
  message_title: string;
  message_body: string;
};

type FailedDispatch = {
  profileId: string;
  error: string;
};

type OneSignalPayload = {
  app_id: string;
  target_channel: "push";
  include_subscription_ids: string[];
  headings: Record<string, string>;
  contents: Record<string, string>;
  data: {
    source: "daily_new_content";
    route: "library";
    profileId: string;
    targetLanguage: string;
    newArticles: number;
    newAudiobooks: number;
  };
};

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function isAllowedBySecret(request: Request): boolean {
  const expectedSecret = Deno.env.get("CRON_SECRET");
  if (!expectedSecret) return false;

  const providedSecret = request.headers.get("x-cron-secret");
  return providedSecret === expectedSecret;
}

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  if (!isAllowedBySecret(request)) {
    return json({ error: "Unauthorized" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const oneSignalAppId = Deno.env.get("ONESIGNAL_APP_ID");
  const oneSignalRestApiKey = Deno.env.get("ONESIGNAL_REST_API_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    return json(
      { error: "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY" },
      500,
    );
  }

  if (!oneSignalAppId) {
    return json({ error: "Missing ONESIGNAL_APP_ID" }, 500);
  }

  if (!oneSignalRestApiKey) {
    return json({ error: "Missing ONESIGNAL_REST_API_KEY" }, 500);
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey);

  const { data, error } = await supabase
    .rpc("get_profiles_to_notify_new_content")
    .returns<NotificationCandidate[]>();

  if (error) {
    return json({ error: "RPC failed", details: error.message }, 500);
  }

  const candidates = data ?? [];
  if (candidates.length === 0) {
    return json({ checked: 0, sent: 0, skipped: 0, failed: [] });
  }

  const sentProfileIds: string[] = [];
  const failed: FailedDispatch[] = [];

  for (const candidate of candidates) {
    const subscriptionIds = candidate.notification_tokens
      .map((token) => token.trim())
      .filter((token) => token.length > 0);

    if (subscriptionIds.length === 0) {
      failed.push({
        profileId: candidate.profile_id,
        error: "No valid OneSignal subscription ids",
      });
      continue;
    }

    const payload: OneSignalPayload = {
      app_id: oneSignalAppId,
      target_channel: "push",
      include_subscription_ids: subscriptionIds,
      headings: {
        en: candidate.message_title,
      },
      contents: {
        en: candidate.message_body,
      },
      data: {
        source: "daily_new_content",
        route: "library",
        profileId: candidate.profile_id,
        targetLanguage: candidate.target_language,
        newArticles: candidate.new_articles_count,
        newAudiobooks: candidate.new_audiobooks_count,
      },
    };

    try {
      const oneSignalResponse = await fetch(
        "https://api.onesignal.com/notifications",
        {
          method: "POST",
          headers: {
            Authorization: `Key ${oneSignalRestApiKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(payload),
        },
      );

      if (!oneSignalResponse.ok) {
        const responseText = await oneSignalResponse.text();
        failed.push({
          profileId: candidate.profile_id,
          error: `OneSignal ${oneSignalResponse.status}: ${responseText}`,
        });
        continue;
      }

      sentProfileIds.push(candidate.profile_id);
    } catch (dispatchError) {
      failed.push({
        profileId: candidate.profile_id,
        error: dispatchError instanceof Error
          ? dispatchError.message
          : String(dispatchError),
      });
    }
  }

  if (sentProfileIds.length > 0) {
    const { error: markError } = await supabase.rpc(
      "mark_profiles_new_content_notified",
      { p_profile_ids: sentProfileIds },
    );

    if (markError) {
      return json(
        {
          error: "Failed to mark profiles as notified",
          details: markError.message,
          sentProfileIds,
          failed,
        },
        500,
      );
    }
  }

  return json({
    checked: candidates.length,
    sent: sentProfileIds.length,
    skipped: candidates.length - sentProfileIds.length,
    failed,
  });
});
