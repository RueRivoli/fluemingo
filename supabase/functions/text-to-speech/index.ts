import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.8";
import { checkRateLimit } from "../_shared/rate-limit.ts";
import { AuthError, authErrorResponse, requireUser } from "../_shared/auth.ts";

const ELEVENLABS_API_KEY = Deno.env.get("ELEVENLABS_API_KEY") ?? "";
const ELEVENLABS_TTS_URL = "https://api.elevenlabs.io/v1/text-to-speech/";

const VOICE_IDS: Record<string, string> = {
  fr: "necQJzI1X0vLpdnJteap", // Mr Laurent
  en: "UaYTS0wayjmO9KD1LR4R", // Asher
  es: "htFfPSZGJwjBv1CL0aMD", // Antonio
};

const ALLOWED_LANGUAGES = new Set(["fr", "en", "es"]);

const ACCENTS: Record<string, string> = {
  "à": "a", "â": "a", "ä": "a", "á": "a", "ã": "a", "å": "a",
  "è": "e", "é": "e", "ê": "e", "ë": "e",
  "ì": "i", "î": "i", "ï": "i", "í": "i",
  "ò": "o", "ó": "o", "ô": "o", "ö": "o", "õ": "o", "ø": "o",
  "ù": "u", "ú": "u", "û": "u", "ü": "u",
  "ý": "y", "ÿ": "y",
  "ç": "c", "ñ": "n", "œ": "oe", "æ": "ae",
};

function slugify(text: string): string {
  const noAccents = text
    .toLowerCase()
    .split("")
    .map((c) => ACCENTS[c] ?? c)
    .join("");
  return noAccents
    .replace(/\s+/g, "-")
    .replace(/[^a-z0-9-]/g, "")
    .replace(/-+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function buildStoragePath(
  language: string,
  word: string,
  contentType?: number,
  contentTitle?: string,
  chapterOrder?: number,
): string {
  const wordSlug = slugify(word);

  if (contentTitle) {
    const titleSlug = slugify(contentTitle);
    // content_type 2 = audiobook chapter
    if (contentType === 2 && chapterOrder != null) {
      return `extra_vocabulary/${language}/audiobooks/${titleSlug}/chapters/chapter_${chapterOrder}/${wordSlug}.mp3`;
    }
    // content_type 1 = article (or default when title is provided)
    return `extra_vocabulary/${language}/articles/${titleSlug}/${wordSlug}.mp3`;
  }

  // Fallback: no content context
  return `extra_vocabulary/${language}/${wordSlug}_${Date.now()}.mp3`;
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

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseServiceRoleKey = Deno.env.get("SB_SECRET_KEY") ?? "";
  const supabase = createClient(
    supabaseUrl,
    Deno.env.get("SB_PUBLISHABLE_KEY") ?? "",
    { global: { headers: { Authorization: req.headers.get("authorization")! } } },
  );

  const rateCheck = await checkRateLimit(supabase, user.id, "text-to-speech");
  if (!rateCheck.allowed) return rateCheck.response;

  if (!ELEVENLABS_API_KEY) {
    return new Response(JSON.stringify({ error: "ElevenLabs API key not configured" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const { word, language, content_type, content_title, chapter_order } = await req.json();

    if (!word || !language) {
      return new Response(JSON.stringify({ error: "Missing required fields: word, language" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (!ALLOWED_LANGUAGES.has(language)) {
      return new Response(JSON.stringify({ error: "Invalid language" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (word.length > 200) {
      return new Response(JSON.stringify({ error: "Word too long" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (content_title && content_title.length > 500) {
      return new Response(JSON.stringify({ error: "Content title too long" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Compute storage path server-side (never trust client-supplied paths)
    const storagePath = buildStoragePath(language, word, content_type, content_title, chapter_order);

    // Check if audio already exists
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey);
    const { data: existingFile } = await supabaseAdmin.storage
      .from("content")
      .createSignedUrl(storagePath, 60);
    if (existingFile?.signedUrl) {
      const headRes = await fetch(existingFile.signedUrl, { method: "HEAD" });
      if (headRes.ok) {
        const publicUrl = `${supabaseUrl}/storage/v1/object/public/content/${storagePath}`;
        return new Response(JSON.stringify({ audio_url: publicUrl }), {
          headers: { "Content-Type": "application/json" },
        });
      }
    }

    const voiceId = VOICE_IDS[language] ?? VOICE_IDS["en"];
    const sanitizedWord = word.replace(/[\u0000-\u001F\u007F]/g, " ").trim() || word.trim();

    const response = await fetch(`${ELEVENLABS_TTS_URL}${voiceId}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "audio/mpeg",
        "xi-api-key": ELEVENLABS_API_KEY,
      },
      body: JSON.stringify({
        text: `${sanitizedWord}.`,
        model_id: "eleven_multilingual_v2",
        language_code: language,
        voice_settings: {
          stability: 0.85,
          similarity_boost: 0.75,
          style: 0.0,
          use_speaker_boost: false,
        },
      }),
    });

    if (!response.ok) {
      const body = await response.text();
      console.error(`ElevenLabs error (${response.status}): ${body}`);
      return new Response(JSON.stringify({ error: "TTS generation failed" }), {
        status: response.status,
        headers: { "Content-Type": "application/json" },
      });
    }

    const audioData = new Uint8Array(await response.arrayBuffer());
    if (audioData.length < 100) {
      return new Response(JSON.stringify({ error: "Audio response too small" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    const { error: uploadError } = await supabaseAdmin.storage
      .from("content")
      .upload(storagePath, audioData, {
        contentType: "audio/mpeg",
        upsert: true,
      });

    if (uploadError) {
      console.error("Storage upload error:", uploadError);
      return new Response(JSON.stringify({ error: "Upload failed" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    const publicUrl = `${supabaseUrl}/storage/v1/object/public/content/${storagePath}`;
    return new Response(JSON.stringify({ audio_url: publicUrl }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("text-to-speech error:", e);
    return new Response(JSON.stringify({ error: "Internal error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
