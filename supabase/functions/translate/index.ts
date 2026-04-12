import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.8";
import { checkRateLimit } from "../_shared/rate-limit.ts";

const DEEPL_API_KEY = Deno.env.get("DEEPL_API_KEY") ?? "";

function parseString(value: unknown): string | null {
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function extractPayloadObject(payload: unknown): Record<string, unknown> {
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
    return {};
  }

  const payloadRecord = payload as Record<string, unknown>;
  const nestedBody = payloadRecord["body"];

  if (nestedBody && typeof nestedBody === "object" && !Array.isArray(nestedBody)) {
    return nestedBody as Record<string, unknown>;
  }

  if (typeof nestedBody === "string") {
    try {
      const parsedBody = JSON.parse(nestedBody);
      if (parsedBody && typeof parsedBody === "object" && !Array.isArray(parsedBody)) {
        return parsedBody as Record<string, unknown>;
      }
    } catch {
      // ignore nested non-JSON string payloads
    }
  }

  return payloadRecord;
}

Deno.serve(async (req: Request) => {
  // CORS only needed for web clients; mobile clients don't send preflight.
  // If you have a web app, replace "*" with your actual domain.
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }

  const authHeader = req.headers.get("authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "Missing authorization" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const token = authHeader.replace(/^Bearer\s+/i, "");
  const { data: { user }, error: authError } = await supabase.auth.getUser(token);
  if (authError || !user) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  const rateCheck = await checkRateLimit(supabase, user.id, "translate");
  if (!rateCheck.allowed) return rateCheck.response;

  if (!DEEPL_API_KEY) {
    return new Response(JSON.stringify({ error: "DeepL API key not configured" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const rawBody = await req.text();
    const contentType = (req.headers.get("content-type") ?? "").toLowerCase();

    let parsedPayload: unknown = null;
    if (rawBody.trim().length > 0) {
      try {
        parsedPayload = JSON.parse(rawBody);
      } catch {
        if (contentType.includes("application/x-www-form-urlencoded")) {
          const formData = new URLSearchParams(rawBody);
          parsedPayload = Object.fromEntries(formData.entries());
        }
      }
    }

    const payload = extractPayloadObject(parsedPayload);
    const text = parseString(payload["text"]);
    const sourceLang = parseString(payload["source_lang"] ?? payload["sourceLanguage"]);
    const targetLang = parseString(payload["target_lang"] ?? payload["targetLanguage"]);
    const context = parseString(payload["context"]);

    if (!text || !sourceLang || !targetLang) {
      return new Response(JSON.stringify({ error: "Missing required fields: text, source_lang, target_lang" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (text.length > 5000) {
      return new Response(JSON.stringify({ error: "Text too long (max 5000 characters)" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const isFreeKey = DEEPL_API_KEY.endsWith(":fx");
    const host = isFreeKey ? "api-free.deepl.com" : "api.deepl.com";

    const bodyParts = [
      `text=${encodeURIComponent(text)}`,
      `source_lang=${encodeURIComponent(sourceLang)}`,
      `target_lang=${encodeURIComponent(targetLang)}`,
    ];
    if (context && context.trim()) {
      bodyParts.push(`context=${encodeURIComponent(context)}`);
    }

    const response = await fetch(`https://${host}/v2/translate`, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": `DeepL-Auth-Key ${DEEPL_API_KEY}`,
      },
      body: bodyParts.join("&"),
    });

    const responseBody = await response.text();
    if (!response.ok) {
      console.error(`DeepL error (${response.status}): ${responseBody}`);
      return new Response(JSON.stringify({ error: "Translation failed" }), {
        status: response.status,
        headers: { "Content-Type": "application/json" },
      });
    }

    const data = JSON.parse(responseBody);
    const translatedText = data?.translations?.[0]?.text ?? null;

    return new Response(JSON.stringify({ translated_text: translatedText }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("translate error:", e);
    return new Response(JSON.stringify({ error: "Internal error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
