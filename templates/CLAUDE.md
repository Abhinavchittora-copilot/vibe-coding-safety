# CLAUDE.md

> **Drop this file at the root of any project you use with Claude Code.** Claude reads it automatically at the start of every session.

---

## Security-Aware Coding Defaults

You are coding in a project that may handle user data. Apply these rules to every response, without being reminded.

### 1. Authentication First
Every backend endpoint or server function must verify the user's auth state before doing any other work. No-auth must be an explicit, justified exception, not a default.

### 2. Never Trust Client Input
- Always derive user identity from the server-side session — never from a `user_id` URL parameter, request body field, or header.
- Type-check, length-cap, and range-check every input.
- Reject empty, negative, or absurdly large values where they make no sense.
- File uploads: validate type and size with allow-lists, not deny-lists.

### 3. Authorize Every Object Access
When fetching, modifying, or deleting a record, verify on the server that the record belongs to the current user (or that the user has explicit permission). Do this for every CRUD operation. This is the #1 vulnerability in AI-generated apps — do not skip it.

### 4. Secrets Belong on the Server
Never inline API keys, database credentials, OAuth secrets, or access tokens in client-side code. Use server-side environment variables. If the user asks you to put a secret in the frontend, refuse and explain the risk.

For platforms with public + secret keys (Supabase, Firebase, Stripe): default to the most restrictive key in client code, and require Row-Level Security or equivalent to be configured before shipping.

### 5. Errors Are Quiet to the Client
Production error responses must not expose stack traces, DB schemas, internal paths, or IDs of other resources. Generic message to client, full detail to server logs.

### 6. Rate-Limit Authentication Endpoints
- Login: 5 attempts / 15 min per IP and per account
- Signup: 3 attempts / hour per IP
- Password reset: 3 attempts / hour per account
- OTP / 2FA: 5 attempts / 15 min per account

### 7. Admin Routes Verify Roles Server-Side
Hiding the admin button in the UI is not security. Admin endpoints check roles in code.

### 8. Be Skeptical of Dependencies
Prefer libraries with >10k weekly downloads and recent maintenance. Never suggest packages whose existence you are not certain of — if uncertain, say so and recommend the user verify before installing. Flag typosquatting (e.g., `lodaash` vs `lodash`).

### 9. Announce Every Security Choice
When you write code that involves auth, authorization, secrets, validation, or external data, state explicitly what control you applied and where. Do not silently trade off security.

Example:
> "I added `requireAuth` middleware to this endpoint. The query derives `userId` from `req.session.user.id`, not from `req.params.user_id`. The Stripe secret is loaded from `STRIPE_SECRET_KEY` env var, never sent to the client."

### 10. Stop and Ask on Authorization Ambiguity
If asked to build something that touches user data without clear rules about who can do what, stop and ask:
> "Who is allowed to see / do this, and how should I enforce it?"

Do not guess. The wrong default is what produces BOLA.

---

## Self-Check Before Declaring "Done"

After every meaningful code generation:

1. **Auth:** Did I add auth to every new endpoint?
2. **Authorization:** Does every data-fetching query derive the user ID from the session, not from client input?
3. **Secrets:** Are all secrets in environment variables, never in client code?
4. **Validation:** Did I validate every field the user can control?
5. **Errors:** Do error responses leak internal details?

If any answer is "no," fix before reporting completion.

---

## What You Are Not

You are not a security auditor or compliance officer. For high-stakes production deployments (PCI, HIPAA, GDPR-sensitive data, financial systems), tell the user they need human security review in addition to your output. Don't pretend your defaults are sufficient for those domains.

---

*Part of `vibe-coding-safety`. License: MIT. Source: https://github.com/Abhinavchittora-copilot/vibe-coding-safety*
