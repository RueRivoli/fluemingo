import { createRemoteJWKSet, jwtVerify } from "https://deno.land/x/jose@v5.9.6/index.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const JWKS = createRemoteJWKSet(new URL(`${SUPABASE_URL}/auth/v1/.well-known/jwks.json`));

export interface AuthedUser {
  id: string;
  email?: string;
  role: string;
  aal?: string;
}

export class AuthError extends Error {
  readonly status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

export async function requireUser(req: Request): Promise<AuthedUser> {
  const authHeader = req.headers.get("authorization");
  if (!authHeader) throw new AuthError(401, "Missing authorization");
  const token = authHeader.replace(/^Bearer\s+/i, "");
  if (!token) throw new AuthError(401, "Missing authorization");

  try {
    const { payload } = await jwtVerify(token, JWKS, {
      issuer: `${SUPABASE_URL}/auth/v1`,
      audience: "authenticated",
    });
    if (!payload.sub) throw new AuthError(401, "Invalid token: missing sub");
    return {
      id: payload.sub,
      email: payload.email as string | undefined,
      role: (payload.role as string | undefined) ?? "authenticated",
      aal: payload.aal as string | undefined,
    };
  } catch (e) {
    if (e instanceof AuthError) throw e;
    throw new AuthError(401, "Invalid or expired token");
  }
}

export function authErrorResponse(e: unknown): Response {
  const status = e instanceof AuthError ? e.status : 500;
  const message = e instanceof AuthError ? e.message : "Internal error";
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
