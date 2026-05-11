# The 30-Minute Anti-Vibe Checklist

Four named checks. 30 minutes total. Designed to catch the security gaps AI coding tools systematically miss.

Run this **before deploying** an AI-generated app to production, or **against any AI-generated app already live**.

When you're done, score yourself with the [Self-Audit Scoring Rubric](./scoring.md).

---

## Check 1: The Guardrails Prompt — 5 minutes

> **The principle:** Most vibe-coding prompts describe what a feature should *do*. Almost none describe what it should *prevent*. The AI optimizes for the happy path because that's what you asked for.

### Before you prompt, answer these four questions

| Question | Why it matters |
|---|---|
| **What happens if the user is not logged in?** | The AI builds login flows that work for valid users. It rarely blocks unauthenticated access to backend endpoints. |
| **What happens if the input is empty, negative, or absurdly large?** | The Tenzai study found 4 of 5 AI tools allowed users to buy negative quantities. The AI builds for valid inputs, not malicious ones. |
| **What happens if someone changes the user ID in the URL?** | This is the #1 vulnerability in AI-generated apps. The AI builds "show me my data" — it does not build "block me from seeing your data." |
| **What data should this feature never be allowed to touch?** | Explicit boundaries beat implicit assumptions. If you don't say *"this feature must not access the payments table,"* the AI may give it access. |

### What to do

Paste your answers into the **first prompt** of your build session, before the feature request. The AI will not invent these constraints. You must.

See [prompts/guardrails-prompt-template.md](./prompts/guardrails-prompt-template.md) for a copy-paste template.

### Pass criteria

- [ ] The four questions are answered explicitly in your prompt history.
- [ ] The AI's response references your security constraints, not just the feature.
- [ ] You can point to where in the generated code each constraint is enforced.

---

## Check 2: The Right-Click Test — 5 minutes

> **The principle:** If a password, API key, or access token is anywhere in your client-side code, it is public. The Moltbook social network leaked 1.5 million tokens this way.

### How to run it

1. Open your live app in a browser (use a private/incognito window).
2. Right-click anywhere on the page → **"View Page Source"** (or press `Ctrl+U`).
3. Press `Ctrl+F` and search for each of these terms, one at a time:
   - `key`
   - `token`
   - `password`
   - `secret`
   - `api_key`
   - `apikey`
   - `auth`
   - `bearer`
   - `sk_` (Stripe secret keys start with this)
   - `AKIA` (AWS access keys start with this)
4. Open browser DevTools → **Network tab** → reload the page. Scan response bodies for the same terms.

### Pass criteria

- [ ] No actual secret values appear in the page source.
- [ ] No actual secret values appear in any network response body.
- [ ] All secrets are referenced through server-side environment variables, not client-side code.

### What to do if you fail

Move every secret to a server-side environment variable immediately. Rotate any secret that was ever in client-side code — assume it has been harvested.

**See the full failure mode in [examples/exposed-secrets.md](./examples/exposed-secrets.md).**

---

## Check 3: The Negative Test — 10 minutes

> **The principle:** An attacker does not use your app the way you designed it. They probe for what *should not* work. Your job is to probe before they do.

### Five things to try, in order

#### 3a. Try to use your app without logging in

- Visit your app's main URL while logged out (or in an incognito window).
- Does it let you see any user data? Any admin pages? Any internal dashboards?
- **Expected:** You should be redirected to a login screen or get a 401/403 error.

#### 3b. Try to access another user's data by changing the ID in the URL

- Log in as user A. Find a URL with your user ID in it (e.g., `/dashboard?user_id=123` or `/api/users/123/profile`).
- Change the ID to a different number (e.g., `/dashboard?user_id=124`).
- **Expected:** You should get a 403 error or "not found" — *never* see another user's data.
- This is the **single most common vulnerability** in AI-generated apps. It is called BOLA (Broken Object-Level Authorization). The AI builds "show me my data" — it forgets to enforce "you can only see your own."

#### 3c. Try to submit invalid input

- If your app has a number field (price, quantity, age), enter `-1`, `0`, `999999999`.
- If your app has a text field, paste 10,000 characters of random text.
- If your app has a file upload, try uploading a 1GB file, or a `.exe` instead of an image.
- **Expected:** The app should reject these gracefully — not crash, not accept them, not show internal errors.

#### 3d. Try to call API endpoints directly

- Open browser DevTools → **Network tab** → use your app normally.
- Note the API endpoints (e.g., `POST /api/orders`, `GET /api/users/123`).
- Try calling them directly using `curl` or Postman — with no authentication token, with a token from a different user, with malformed payloads.
- **Expected:** Unauthenticated requests get 401. Cross-user requests get 403. Malformed payloads get 400 (not 500).

#### 3e. Try the admin path

- If your app has an admin section, try visiting `/admin`, `/dashboard/admin`, `/api/admin/users` while logged in as a regular user.
- **Expected:** Forbidden. Not just hidden from the UI — actively rejected by the server.

### Pass criteria

- [ ] No URL gives access to data the current user shouldn't see.
- [ ] No API call works without proper authentication.
- [ ] No invalid input crashes the app or exposes internal details.
- [ ] No admin route is accessible to non-admin users.

**See the full failure mode in [examples/happy-path-trap.md](./examples/happy-path-trap.md) and [examples/platform-id-reuse.md](./examples/platform-id-reuse.md).**

---

## Check 4: The Hallucination Audit — 10 minutes

> **The principle:** Roughly 20% of AI-generated code references software libraries that *do not exist*. Attackers have started registering those fake names in public package directories and filling them with malware. The AI recommends it. You trust the AI. The malware installs itself.

### How to run it

1. Open your project's dependency file:
   - JavaScript/Node: `package.json`
   - Python: `requirements.txt` or `pyproject.toml`
   - Ruby: `Gemfile`
   - Go: `go.mod`

2. For **every dependency the AI added** (especially ones you don't recognize), verify:

| Check | Where to look |
|---|---|
| **Does it exist?** | Search the official package registry (npmjs.com, pypi.org, rubygems.org). |
| **Does it have real users?** | Check weekly download counts. < 100/week is a red flag. < 10/week is a serious red flag. |
| **Is it actively maintained?** | Last commit date. Anything older than 2 years for a security-adjacent library is risky. |
| **Does it have a history?** | A package registered last week with weird names ("fast-auth-validator", "secure-jwt-helper-v2") is almost certainly malicious. |
| **Does the package name match what it claims to do?** | Typosquatting: `lodash` vs `lodaash`. The AI sometimes "remembers" library names wrong; attackers exploit this. |

3. **Cross-check with a real source.** If the AI says *"use library X to handle authentication,"* search for *"library X authentication tutorial"* on a search engine. If real tutorials exist from before 2024, the library is probably real.

### Pass criteria

- [ ] Every dependency exists on the official package registry.
- [ ] Every dependency has > 100 weekly downloads or is from a recognized publisher (e.g., Facebook, Google, Microsoft, Vercel).
- [ ] No dependency was created within the last 3 months unless you have a specific reason to trust it.
- [ ] No package names look suspiciously similar to popular libraries (typosquatting).

### What to do if you fail

Remove the suspicious dependency immediately. Replace with a verified equivalent. Run a malware scan on your development machine — if the package was installed, its install scripts may have already executed.

---

## The 30-Minute Checklist Summary

| # | Check | Time | What it catches |
|---|---|---|---|
| 1 | **Guardrails Prompt** | 5 min | Missing security constraints in your prompts. |
| 2 | **Right-Click Test** | 5 min | Secrets in client-side code (the Moltbook pattern). |
| 3 | **Negative Test** | 10 min | Broken auth, BOLA, missing input validation (the Lovable & Base44 pattern). |
| 4 | **Hallucination Audit** | 10 min | Malicious dependencies the AI invented. |
| | **Total** | **30 min** | |

---

## What to do next

→ **[Score yourself](./scoring.md)** — get a number out of 10 that tells you whether to ship.

→ **[Read the failure mode examples](./examples/)** — see what each of these checks looks like when it fails in a real app.

→ **[Use the Guardrails Prompt template](./prompts/guardrails-prompt-template.md)** — make this checklist mostly obsolete by prompting better in the first place.
