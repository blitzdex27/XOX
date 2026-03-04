# XOX Website + CMS Setup

This folder is intended to be published via GitHub Pages (`main` branch, `/docs` source).

## Structure

- `index.html`, `about/`, `contact/`, `privacy/`: public pages
- `content/*.md`: editable page content
- `admin/`: Decap CMS entrypoint and config
- `admin/oauth-worker/`: Cloudflare Worker OAuth helper for GitHub login

## 1. Enable GitHub Pages

In repository settings:

- Source: `Deploy from a branch`
- Branch: `main`
- Folder: `/docs`

Site URL should be:

- `https://blitzdex27.github.io/XOX/`

## 2. Configure Cloudflare Worker OAuth

From `docs/admin/oauth-worker/`:

```bash
npm create cloudflare@latest .
# keep existing files, then:
npm install
npx wrangler secret put GITHUB_CLIENT_ID
npx wrangler secret put GITHUB_CLIENT_SECRET
npx wrangler deploy
```

Then copy worker URL into `/docs/admin/config.yml`:

- `backend.base_url`

## 3. GitHub OAuth App

Create a GitHub OAuth App and set:

- Authorization callback URL: `https://<your-worker-domain>/callback`

Use its client ID and secret as Worker secrets.

## 4. App Store metadata targets

- Privacy Policy URL: `https://blitzdex27.github.io/XOX/privacy/`
- Support URL: `https://blitzdex27.github.io/XOX/contact/`

## 5. Important

Replace the placeholder support email in:

- `docs/content/contact.md`
- `docs/content/privacy.md`

before submitting to App Store review.
