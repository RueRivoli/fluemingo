import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.8";
import { checkRateLimit } from "../_shared/rate-limit.ts";
import { AuthError, authErrorResponse, requireUser } from "../_shared/auth.ts";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY") ?? "";
const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";

const MODELS = [
  "claude-sonnet-4-20250514",
  "claude-3-5-sonnet-latest",
  "claude-3-5-haiku-latest",
];

const ALLOWED_LANGUAGES = new Set([
  "English", "French", "Spanish", "German", "Dutch", "Italian", "Portuguese", "Japanese",
]);

function sanitizeForPrompt(text: string): string {
  return text.replace(/["\n\r\\]/g, " ").trim();
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }

  let user;
  try {
    user = await requireUser(req);
  } catch (e) {
    if (e instanceof AuthError) return authErrorResponse(e);
    throw e;
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SB_PUBLISHABLE_KEY") ?? "",
    { global: { headers: { Authorization: req.headers.get("authorization")! } } },
  );

  const rateCheck = await checkRateLimit(supabase, user.id, "generate-sentence");
  if (!rateCheck.allowed) return rateCheck.response;

  if (!ANTHROPIC_API_KEY) {
    return new Response(JSON.stringify({ error: "Anthropic API key not configured" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const { word, translated_word, target_language_name, source_language_name } = await req.json();

    if (!word || !translated_word || !target_language_name || !source_language_name) {
      return new Response(JSON.stringify({ error: "Missing required fields: word, translated_word, target_language_name, source_language_name" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (word.length > 200 || translated_word.length > 200) {
      return new Response(JSON.stringify({ error: "Input too long (max 200 characters)" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (!ALLOWED_LANGUAGES.has(target_language_name) || !ALLOWED_LANGUAGES.has(source_language_name)) {
      return new Response(JSON.stringify({ error: "Invalid language" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const safeWord = sanitizeForPrompt(word);
    const safeTranslation = sanitizeForPrompt(translated_word);

    const prompt = `Create exactly one short natural sentence in ${target_language_name} with less than 20 words using the word "${safeWord}" with the meaning "${safeTranslation}". Then translate this sentence into ${source_language_name}, making sure the word "${safeWord}" is translated as "${safeTranslation}". Return ONLY valid JSON: {"sentence": "...", "translation": "..."}`;

    for (const model of MODELS) {
      const response = await fetch(ANTHROPIC_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": ANTHROPIC_API_KEY,
          "anthropic-version": "2023-06-01",
        },
        body: JSON.stringify({
          model,
          max_tokens: 200,
          temperature: 0.3,
          messages: [{ role: "user", content: prompt }],
        }),
      });

      const body = await response.text();

      if (!response.ok) {
        const isModelIssue =
          (response.status === 400 || response.status === 404) &&
          (body.toLowerCase().includes("model") || body.toLowerCase().includes("not_found_error"));

        if (isModelIssue && model !== MODELS[MODELS.length - 1]) {
          console.log(`Model ${model} unavailable, trying next...`);
          continue;
        }

        console.error(`Anthropic error (${response.status}): ${body}`);
        return new Response(JSON.stringify({ error: "Generation failed" }), {
          status: response.status,
          headers: { "Content-Type": "application/json" },
        });
      }

      const data = JSON.parse(body);
      const text = data?.content?.[0]?.text?.trim() ?? null;

      if (text) {
        try {
          const parsed = JSON.parse(text);
          if (parsed.sentence) {
            return new Response(JSON.stringify({ sentence: parsed.sentence, translation: parsed.translation ?? null }), {
              headers: { "Content-Type": "application/json" },
            });
          }
        } catch {
          return new Response(JSON.stringify({ sentence: text, translation: null }), {
            headers: { "Content-Type": "application/json" },
          });
        }
      }
    }

    return new Response(JSON.stringify({ sentence: null, translation: null }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("generate-sentence error:", e);
    return new Response(JSON.stringify({ error: "Internal error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
