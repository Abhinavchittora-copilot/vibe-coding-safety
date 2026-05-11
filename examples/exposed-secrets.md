# Failure Mode: Exposed Secrets in Client-Side Code

**Real-world pattern observed in:** A vibe-coded social network that exposed 1.5 million database access tokens (publicly reported in the Wired investigation of vibe-coded apps).

**The technical name:** Hardcoded credentials / secrets in client-side code.

**The plain-language name:** *"The key under the doormat."*

---

## What it looks like

The developer builds an app that needs to talk to a database (or any external service: payment processor, email provider, cloud storage). The AI generates code that uses the database's connection string or API key.

The AI puts that key directly into the frontend code.

The developer assumes that because the code is "compiled" or "bundled," nobody can see the key. They are wrong. Anyone can right-click on the live website, choose "View Page Source," and read the key.

In the most-cited real-world case: **1.5 million database tokens** were exposed this way across a single vibe-coded app. Each token was a working credential. Each token, used by an attacker, would give read or write access to a real database.

---

## A concrete example

### The prompt that creates the problem

```
Build me a social network where users can post short messages
and follow each other. Use Supabase for the backend.
```

### The code the AI generates (simplified)

```javascript
// src/lib/supabase.js — sent to the user's browser
import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = 'https://xyzproject.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGc...truncated...long_jwt_token'  // ❌ in client code

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
```

### Why this fails

Even though this is the **"anon" key** (which has limited permissions if Row-Level Security is configured), the key is now public. Anyone on the internet can extract it from the page source and start making calls to your database.

It gets dramatically worse when the AI uses the **service-role key** by mistake — which it does, in roughly 30% of vibe-coded Supabase apps audited by independent researchers. The service-role key has **full read/write access to the entire database, bypassing all access controls**. If that's in client-side code, your entire database is publicly readable and writable.

### The code that should have been generated

**Client-side code (sent to browser):**
```javascript
// src/lib/api.js
export async function fetchPosts() {
  const res = await fetch('/api/posts')
  return res.json()
}
```

**Server-side code (kept private):**
```javascript
// api/posts.js — runs on server only
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL,           // ✅ env var
  process.env.SUPABASE_SERVICE_KEY    // ✅ env var, never sent to browser
)

export default async function handler(req, res) {
  const posts = await supabase.from('posts').select('*')
  res.json(posts.data)
}
```

The secrets stay on the server. The client calls *your* server, and *your* server makes the privileged database call.

---

## Why the AI gets this wrong

### 1. The simplest tutorial pattern is insecure

Most "getting started" guides for Supabase, Firebase, and other backend-as-a-service tools demonstrate client-side SDK usage — for ease of teaching. The AI reproduces this pattern, missing the production-grade architecture.

### 2. The AI conflates "anon key" with "safe key"

Vendor documentation sometimes calls the anon/publishable key "safe to expose." This is *only* true if Row-Level Security is correctly configured — which the AI rarely sets up by default. In practice, exposing the anon key without RLS is equivalent to exposing the database.

### 3. There is no compile-time error for this

The code compiles. The app runs. The tests pass. The vulnerability is invisible at runtime — it only becomes apparent when someone right-clicks "View Source." Without explicit checks, this slips through.

---

## How the [Guardrails Prompt](../prompts/guardrails-prompt-template.md) prevents this

The Guardrails Prompt includes:

> **SECRETS: No API keys, database passwords, access tokens, or other secrets may appear in client-side code or network responses. All secrets must be referenced through server-side environment variables.**

If this is in your first prompt, the AI defaults to server-side environment variables. If it is not, you get the convenient-but-leaky version.

---

## How [Check 2 of the Anti-Vibe Checklist](../checklist.md#check-2-the-right-click-test--5-minutes) catches this

The Right-Click Test is built for this exact failure mode. In 5 minutes:

1. Open your live app in an incognito window.
2. Right-click → View Page Source.
3. Search for: `key`, `token`, `password`, `secret`, `api_key`, `sk_`, `AKIA`, `eyJ` (JWT prefix), `https://*.supabase.co`, `firebase`.
4. Open DevTools → Network tab → reload → scan response bodies.

If any of these terms appear with what looks like a real secret value (not just the word "key" in a comment), you have this failure.

---

## What a real-world consequence looks like

The Wired investigation documented the vibe-coded social network with **1.5 million access tokens** in plain sight. Each token represented a working credential. The researcher who found them could have:

- Read every user's private data
- Modified or deleted records arbitrarily
- Sent fraudulent updates from any user's account
- Run up the database bill of the platform owner

The fix was a five-line change: move the keys to environment variables, route through a server function. The damage potential, had a malicious actor found it first, was unbounded.

---

## Remediation checklist

If you found this failure in your app:

1. **Immediately:** Take the app offline. Do not just "rotate the secret and re-deploy" — the secret has been public for as long as the app has been live, which means it may already be in someone's harvested credentials database.
2. **Within minutes:** Rotate every exposed secret. Generate new keys for every service involved (database, payment provider, email provider, OAuth providers).
3. **Within hours:** Move all secrets to server-side environment variables. Refactor any client-side code that touches secrets to instead call your own server, which then calls the privileged service.
4. **Within a day:** Audit your database access logs (if available) for the exposure window. Look for unusual access patterns from unexpected IPs.
5. **Within a week:** Notify affected users per your jurisdiction's data breach notification rules. The exposed secret may give compliance authorities grounds to consider this a reportable incident.
6. **Before re-deploying:** Add the [Guardrails Prompt](../prompts/guardrails-prompt-template.md) and run [the full checklist](../checklist.md).
