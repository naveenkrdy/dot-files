---
name: site-clone
description: "Clone a website including its UI and functional features by observation, then rebuild it in a stack matching the original. Use when the user asks to clone this website, copy this site, rebuild/replicate a site or its features. Trigger: /site-clone <url>"
trigger: /site-clone
---

# /site-clone

Clone a website's design *and* behavior by observing it, writing a spec, and rebuilding from scratch in a stack that matches the original. This is reverse-engineering, not scraping: mirrored HTML is unmaintainable and features cannot be copied - they must be observed and reimplemented.

## Guardrails (state these to the user up front)

- Rebuild from observation only. Never paste the original site's source, minified bundles, or proprietary JS.
- Do not copy proprietary assets: logos, brand imagery, licensed fonts, copy text. Use placeholders and note them.
- Respect the target's `robots.txt` and Terms of Service. Do not attempt auth bypass, scraping behind paywalls, or hammering the server.
- Cloning someone else's branded product for anything beyond personal learning is the user's legal responsibility - say so once, then proceed.

## Workflow

### 1. Recon and stack detection

- Fetch headers and HTML: `curl -sIL <url>` and `curl -sL <url>`. Pipe to a file and grep rather than dumping.
- Detect the stack from markers: `__NEXT_DATA__`/`/_next/` = Next.js; `wp-content` = WordPress; `data-v-`/`__NUXT__` = Vue/Nuxt; `ng-version` = Angular; `_astro/` = Astro; `x-powered-by`, `server`, and `set-cookie` headers.
- Pull `robots.txt` and `sitemap.xml` for a route map.
- Pick the closest rebuild stack to the original (per the user's "match the original" preference). Confirm scope with the user: which pages and which features are in vs out. Do not capture everything blindly.

### 2. Capture (claude-in-chrome MCP)

Load the browser tools first (one ToolSearch call): `tabs_context_mcp, tabs_create_mcp, navigate, read_page, computer, javascript_tool, read_network_requests, read_console_messages`.

Per key page:
- Screenshot at desktop (~1440) and mobile (~390) widths.
- `read_page` for DOM structure and content hierarchy.
- `javascript_tool` to extract design tokens from computed styles: font families and sizes, color palette, spacing scale, border radius, shadows, breakpoints. Log them, don't eyeball.
- Exercise each in-scope feature (search, filter, auth, forms, cart, pagination) while `read_network_requests` records endpoints: method, path, request payload shape, response shape, status. This is the API contract you will reimplement against.
- Note client-side behaviors: modals, transitions, validation rules, optimistic updates, empty/error states.

Avoid triggering native `alert`/`confirm` dialogs - they freeze the extension.

### 3. Write `clone-spec.md`

In the project directory, write a spec (use the native Write tool):
- Route map and navigation.
- Component inventory (header, cards, forms, etc.) with the extracted design tokens.
- One section per feature: user-visible behavior + observed API contract + inferred data model.

**Checkpoint:** show the spec to the user before building. Fix gaps now, not after scaffolding.

### 4. Rebuild

- Scaffold the matched stack (confirm the exact framework version via Context7 rather than guessing).
- Build the UI from screenshots + tokens. Apply the `frontend-design`/`design` skill standards for quality; match layout to the originals, not a generic template.
- Implement each feature fresh against its observed API contract, with your own backend/data layer (mock or real as the user wants). Never wire the clone to the original's endpoints.

### 5. Verify

- Run locally via the `run`/`verify` skills.
- Screenshot the clone at the same viewports and compare side by side with the originals; iterate on spacing, type, and color until they match.
- Walk each feature flow end to end and confirm it behaves like the observed original, including error and empty states.

## Notes

- For a purely static offline copy (no rebuild), the user wants `wget --mirror`, not this skill. Say so and stop.
- Large sites: clone one representative page and feature fully, get sign-off, then fan out - don't capture 50 pages up front.
