interface Env {
  GITHUB_CLIENT_ID: string;
  GITHUB_CLIENT_SECRET: string;
  ALLOWED_ORIGINS?: string;
  PUBLIC_SITE_ORIGIN?: string;
  GITHUB_SCOPE?: string;
}

const OAUTH_STATE_COOKIE = "xox_oauth_state";
const OAUTH_ORIGIN_COOKIE = "xox_oauth_origin";

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (request.method !== "GET") {
      return new Response("Method not allowed", { status: 405 });
    }

    if (url.pathname === "/health") {
      return Response.json({ ok: true, service: "xox-cms-auth" });
    }

    if (url.pathname === "/auth") {
      return handleAuth(url, env);
    }

    if (url.pathname === "/callback") {
      return handleCallback(request, url, env);
    }

    return new Response(
      "XOX CMS OAuth worker is running. Use /auth to start GitHub auth.",
      { status: 200 },
    );
  },
};

function handleAuth(url: URL, env: Env): Response {
  const origin = (url.searchParams.get("origin") || "").trim();
  const allowedOrigins = parseAllowedOrigins(env);

  if (!origin || !allowedOrigins.has(origin)) {
    return new Response("Origin is not allowed.", { status: 403 });
  }

  if (!env.GITHUB_CLIENT_ID) {
    return new Response("Missing GITHUB_CLIENT_ID secret.", { status: 500 });
  }

  const state = generateState();
  const redirectUri = `${url.origin}/callback`;
  const scope = env.GITHUB_SCOPE || "repo";

  const githubAuthorizeUrl = new URL("https://github.com/login/oauth/authorize");
  githubAuthorizeUrl.searchParams.set("client_id", env.GITHUB_CLIENT_ID);
  githubAuthorizeUrl.searchParams.set("redirect_uri", redirectUri);
  githubAuthorizeUrl.searchParams.set("scope", scope);
  githubAuthorizeUrl.searchParams.set("state", state);

  const response = Response.redirect(githubAuthorizeUrl.toString(), 302);
  response.headers.append(
    "Set-Cookie",
    buildCookie(OAUTH_STATE_COOKIE, state, { maxAge: 600 }),
  );
  response.headers.append(
    "Set-Cookie",
    buildCookie(OAUTH_ORIGIN_COOKIE, encodeURIComponent(origin), { maxAge: 600 }),
  );

  return response;
}

async function handleCallback(request: Request, url: URL, env: Env): Promise<Response> {
  const code = url.searchParams.get("code") || "";
  const state = url.searchParams.get("state") || "";
  const oauthError = url.searchParams.get("error") || "";

  const cookies = parseCookies(request.headers.get("Cookie") || "");
  const storedState = cookies[OAUTH_STATE_COOKIE] || "";
  const storedOrigin = decodeURIComponent(cookies[OAUTH_ORIGIN_COOKIE] || "");

  const allowedOrigins = parseAllowedOrigins(env);
  const clearCookieHeaders = [
    buildCookie(OAUTH_STATE_COOKIE, "", { maxAge: 0 }),
    buildCookie(OAUTH_ORIGIN_COOKIE, "", { maxAge: 0 }),
  ];

  if (!storedOrigin || !allowedOrigins.has(storedOrigin)) {
    return htmlResponse(
      failureHtml("Invalid or missing origin.", env.PUBLIC_SITE_ORIGIN || "*"),
      clearCookieHeaders,
    );
  }

  if (oauthError) {
    return htmlResponse(failureHtml(`GitHub OAuth error: ${oauthError}`, storedOrigin), clearCookieHeaders);
  }

  if (!code || !state || state !== storedState) {
    return htmlResponse(failureHtml("Invalid OAuth state.", storedOrigin), clearCookieHeaders);
  }

  if (!env.GITHUB_CLIENT_ID || !env.GITHUB_CLIENT_SECRET) {
    return htmlResponse(
      failureHtml("Server is missing GitHub OAuth secrets.", storedOrigin),
      clearCookieHeaders,
    );
  }

  const redirectUri = `${url.origin}/callback`;

  const tokenRes = await fetch("https://github.com/login/oauth/access_token", {
    method: "POST",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      client_id: env.GITHUB_CLIENT_ID,
      client_secret: env.GITHUB_CLIENT_SECRET,
      code,
      redirect_uri: redirectUri,
      state,
    }).toString(),
  });

  if (!tokenRes.ok) {
    return htmlResponse(
      failureHtml(`Token exchange failed (${tokenRes.status}).`, storedOrigin),
      clearCookieHeaders,
    );
  }

  const tokenJson = (await tokenRes.json()) as {
    access_token?: string;
    error?: string;
    error_description?: string;
  };

  if (!tokenJson.access_token) {
    const message = tokenJson.error_description || tokenJson.error || "Missing access token.";
    return htmlResponse(failureHtml(message, storedOrigin), clearCookieHeaders);
  }

  return htmlResponse(successHtml(tokenJson.access_token, storedOrigin), clearCookieHeaders);
}

function parseAllowedOrigins(env: Env): Set<string> {
  const configured = (env.ALLOWED_ORIGINS || "")
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);

  if (configured.length === 0 && env.PUBLIC_SITE_ORIGIN) {
    configured.push(env.PUBLIC_SITE_ORIGIN);
  }

  return new Set(configured);
}

function parseCookies(cookieHeader: string): Record<string, string> {
  const out: Record<string, string> = {};
  cookieHeader.split(";").forEach((part) => {
    const [rawKey, ...rest] = part.trim().split("=");
    if (!rawKey || rest.length === 0) {
      return;
    }
    out[rawKey] = rest.join("=");
  });
  return out;
}

function buildCookie(name: string, value: string, options: { maxAge: number }): string {
  return [
    `${name}=${value}`,
    "Path=/",
    "HttpOnly",
    "Secure",
    "SameSite=Lax",
    `Max-Age=${options.maxAge}`,
  ].join("; ");
}

function generateState(): string {
  const bytes = new Uint8Array(24);
  crypto.getRandomValues(bytes);
  return toBase64Url(bytes);
}

function toBase64Url(bytes: Uint8Array): string {
  let binary = "";
  bytes.forEach((byte) => {
    binary += String.fromCharCode(byte);
  });
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

function htmlResponse(html: string, cookieHeaders: string[]): Response {
  const response = new Response(html, {
    status: 200,
    headers: {
      "Content-Type": "text/html; charset=utf-8",
      "Cache-Control": "no-store",
    },
  });

  cookieHeaders.forEach((cookie) => {
    response.headers.append("Set-Cookie", cookie);
  });

  return response;
}

function successHtml(token: string, origin: string): string {
  const safeToken = jsEscape(token);
  const safeOrigin = jsEscape(origin);

  return `<!doctype html>
<html>
  <body>
    <p>Authentication complete. You can close this window.</p>
    <script>
      (function () {
        var payload = JSON.stringify({ token: "${safeToken}", provider: "github" });
        if (window.opener) {
          window.opener.postMessage("authorization:github:success:" + payload, "${safeOrigin}");
        }
        window.close();
      })();
    </script>
  </body>
</html>`;
}

function failureHtml(message: string, origin: string): string {
  const safeMessage = jsEscape(message);
  const safeOrigin = jsEscape(origin);

  return `<!doctype html>
<html>
  <body>
    <p>Authentication failed: ${safeMessage}</p>
    <script>
      (function () {
        if (window.opener) {
          window.opener.postMessage("authorization:github:error:${safeMessage}", "${safeOrigin}");
        }
      })();
    </script>
  </body>
</html>`;
}

function jsEscape(value: string): string {
  return value.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, " ");
}
